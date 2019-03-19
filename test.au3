#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <GuiMenu.au3>
#include <Timers.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>


; Startup SQLite

Local $aResult, $iRows, $iColumns, $iRval
_SQLite_Startup()
ConsoleWrite("_SQLite_LibVersion=" & _SQLite_LibVersion() & @CRLF)
_SQLite_Open()
_SQLite_Exec(-1, "PRAGMA synchronous = OFF;")		; this should speed up DB transactions
_SQLite_Exec(-1, "CREATE TABLE node (level int,type,name,attribs,text);") ; CREATE a Table


;WinActivate("Modules across all disciplines - Janison CLS - Google Chrome")
;ControlSend("Modules across all disciplines - Janison CLS - Google Chrome", "", "", "{APPSKEY}")
;Sleep(500)
;ControlSend("Modules across all disciplines - Janison CLS - Google Chrome", "", "", "c{ENTER}{UP}{ENTER}")
;Sleep(500)
;ControlSend("Modules across all disciplines - Janison CLS - Google Chrome", "", "", "{CTRLDOWN}{SHIFTDOWN}j{SHIFTUP}{CTRLUP}")
;Sleep(500)
;ControlSend("Modules across all disciplines - Janison CLS - Google Chrome", "", "", "{CTRLDOWN}{SHIFTDOWN}j{SHIFTUP}{CTRLUP}")
;Sleep(500)
;ControlSend("Modules across all disciplines - Janison CLS - Google Chrome", "", "", "document.documentElement.innerHTML{ENTER}")
;Exit

;//*[@id="btnPerformSearch"]/span[1]

Global $num_levels = 0

Local $chrome_xpath = "//*[@id=""btnPerformSearch""]/span[1]"

$chrome_xpath = StringReplace($chrome_xpath, """", "\""")

;$out0 = get_node_attribs($chrome_xpath)
local $out_arr[0][5]


get_siblings_attribs($chrome_xpath, 1, $out_arr)


$iRval = _SQLite_GetTable2d(-1, "SELECT * FROM node;", $aResult, $iRows, $iColumns)
_SQLite_Display2DResult($aResult)


for $level_num = 1 to $num_levels

	Local $correct_locator = ""

	; if the ancestor node has an id attribute, then the ancestor "id" is the correct locator

	if StringLen($correct_locator) = 0 Then

		$iRval = _SQLite_GetTable2d(-1, "SELECT attribs FROM node WHERE level = " & $level_num & " AND type = 'A';", $aResult, $iRows, $iColumns)

		if StringInStr($aResult[1][0], "id=""") > 0 Then

			$correct_locator = $aResult[1][0]
		EndIf
	EndIf

	; if there is only one node in the level (no sibling nodes), then the ancestor "name" is the correct locator

	if StringLen($correct_locator) = 0 Then

		$iRval = _SQLite_GetTable2d(-1, "SELECT count(*) FROM node WHERE level = " & $level_num & ";", $aResult, $iRows, $iColumns)

		if $aResult[1][0] = 1 Then

			$iRval = _SQLite_GetTable2d(-1, "SELECT name FROM node WHERE level = " & $level_num & ";", $aResult, $iRows, $iColumns)
			$correct_locator = $aResult[1][0]
		EndIf
	EndIf

	; if there are no siblings with the same name as the ancestor node, then the ancestor "name" is the correct locator

	if StringLen($correct_locator) = 0 Then

		$iRval = _SQLite_GetTable2d(-1, "SELECT name FROM node WHERE level = " & $level_num & " AND type = 'A';", $aResult, $iRows, $iColumns)
		Local $name = $aResult[1][0]
		$iRval = _SQLite_GetTable2d(-1, "SELECT count(*) FROM node WHERE level = " & $level_num & " AND name = '" & $name & "';", $aResult, $iRows, $iColumns)

		if $aResult[1][0] = 1 Then

			$correct_locator = $name
		EndIf
	EndIf

	Local $level_locator = "level " & $level_num & " = " & $correct_locator
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $level_locator = ' & $level_locator & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console


Next






_SQLite_Close()
_SQLite_Shutdown()

;$rr = StringSplit($sOutput, @CRLF)
;_ArrayDisplay($out_arr)


Func get_siblings_attribs($node_xpath, $node_ancestor_num, ByRef $out_arr)

	Local $out

	for $ancestor_num = 1 to 100

		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $ancestor_num = ' & $ancestor_num & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

		Local $ancestor_node_name = get_node_name($node_xpath)
;		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $ancestor_node_name = ' & $ancestor_node_name & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

		if StringLen($ancestor_node_name) = 0 or StringCompare($ancestor_node_name, "body") = 0 Then

			$num_levels = $ancestor_num
			ExitLoop
		EndIf

		if StringCompare($ancestor_node_name, "script") <> 0 Then

			Local $ancestor_node_attribs = get_node_attribs($node_xpath)
			Local $ancestor_node_text = get_node_text($node_xpath)
			Local $ansestor_node = $ancestor_node_name & "|" & $ancestor_node_attribs & "|" & $ancestor_node_text
			Local $out = $ancestor_num & "|A|" & $ansestor_node
;			_ArrayAdd($out_arr, $out)
			$ancestor_node_attribs = StringReplace($ancestor_node_attribs, "'", "''")
			$ancestor_node_text = StringReplace($ancestor_node_text, "'", "''")
			$query = "INSERT INTO node (level,type,name,attribs,text) VALUES ('" & $ancestor_num & "','A','" & $ancestor_node_name & "','" & $ancestor_node_attribs & "','" & $ancestor_node_text & "');"
			_SQLite_Exec(-1, $query) ; INSERT Data


			$node_xpath = $node_xpath & "/.."

			Local $child_count = get_node_child_count($node_xpath)
	;		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $node_count = ' & $node_count & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

			for $i = 1 to $child_count

				Local $sibling_node_name = get_node_name($node_xpath & "/*[" & $i & "]")

				if StringCompare($sibling_node_name, "script") <> 0 Then

					Local $sibling_node_attribs = get_node_attribs($node_xpath & "/*[" & $i & "]")
					Local $sibling_node_text = get_node_text($node_xpath & "/*[" & $i & "]")
					Local $sibling_node = $sibling_node_name & "|" & $sibling_node_attribs & "|" & $sibling_node_text

					if StringCompare($ansestor_node, $sibling_node) <> 0 Then

						Local $out = $ancestor_num & "|S|" & $sibling_node
		;				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $out = ' & $out & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

;						_ArrayAdd($out_arr, $out, 0, "|", "~")
						$sibling_node_attribs = StringReplace($sibling_node_attribs, "'", "''")
						$sibling_node_attribs = StringStripCR($sibling_node_attribs)
						$sibling_node_text = StringReplace($sibling_node_text, "'", "''")
						$query = "INSERT INTO node (level,type,name,attribs,text) VALUES ('" & $ancestor_num & "','S','" & $sibling_node_name & "','" & $sibling_node_attribs & "','" & $sibling_node_text & "');"
						_SQLite_Exec(-1, $query) ; INSERT Data
					EndIf
				EndIf
			Next
		EndIf
	Next

EndFunc


Func get_node_name($xpath)

	Local $out = get_node("name(" & $xpath & ")")
	return $out
EndFunc

Func get_node_attribs($xpath)

	Local	$out = get_node($xpath & "/attribute::*")
	return $out
EndFunc


Func get_node_text($xpath)

	Local $out = get_node($xpath & "/text()")
	$out = StringStripWS($out, 3)
	return $out
EndFunc

Func get_node_child_count($xpath)

	Local $out = get_node("count(" & $xpath & "/*)")
	return $out

EndFunc


Func get_node($xpath)

	Local $sOutput = ""

	FileDelete("D:\dwn\xmllint\xpath.txt")
	Local $cmd = "xmllint.exe --html --xpath """ & $xpath & """ fred.html > xpath.txt"
;	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $cmd = ' & $cmd & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
	Local $iPID = RunWait(@ComSpec & " /c " & $cmd, "D:\dwn\xmllint", @SW_HIDE)

	if FileExists("D:\dwn\xmllint\xpath.txt") = True Then

		$sOutput = FileRead("D:\dwn\xmllint\xpath.txt")
	EndIf

	return $sOutput

EndFunc

