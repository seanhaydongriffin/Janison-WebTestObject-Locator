#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <GuiMenu.au3>
#include <Timers.au3>

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

Local $chrome_xpath = "//*[@id=""btnPerformSearch""]/span[1]"

$chrome_xpath = StringReplace($chrome_xpath, """", "\""")

;$out0 = get_node_attribs($chrome_xpath)
local $out_arr[0][5]


;Local $hStarttime = _Timer_Init()
get_siblings_attribs($chrome_xpath, 1, $out_arr)
;Local $end_time = _Timer_Diff($hStarttime)
;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $end_time = ' & $end_time & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
;MsgBox(0, "a", $end_time)

;$out1 = get_node_attribs($chrome_xpath & "/../*[1]")
;$out2 = get_node_attribs($chrome_xpath & "/../*[2]")
;$out3 = get_node_attribs($chrome_xpath & "/../*[3]")

;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $out0 = ' & $out0 & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $out1 = ' & $out1 & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $out2 = ' & $out2 & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $out3 = ' & $out3 & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console


;$rr = StringSplit($sOutput, @CRLF)
_ArrayDisplay($out_arr)


Func get_siblings_attribs($node_xpath, $node_ancestor_num, ByRef $out_arr)

	Local $out

	for $ancestor_num = 1 to 100

		Local $ancestor_node_name = get_node_name($node_xpath)
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $ancestor_node_name = ' & $ancestor_node_name & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

		if StringLen($ancestor_node_name) = 0 or StringCompare($ancestor_node_name, "body") = 0 Then

			ExitLoop
		EndIf

		Local $ancestor_node_attribs = get_node_attribs($node_xpath)
		Local $ancestor_node_text = get_node_text($node_xpath)
		Local $ansestor_node = $ancestor_node_name & "|" & $ancestor_node_attribs & "|" & $ancestor_node_text
		Local $out = $ancestor_num & "|A|" & $ansestor_node
		_ArrayAdd($out_arr, $out)

		$node_xpath = $node_xpath & "/.."

		Local $child_count = get_node_child_count($node_xpath)
;		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $node_count = ' & $node_count & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

		for $i = 1 to $child_count

			Local $sibling_node_name = get_node_name($node_xpath & "/*[" & $i & "]")
			Local $sibling_node_attribs = get_node_attribs($node_xpath & "/*[" & $i & "]")
			Local $sibling_node_text = get_node_text($node_xpath & "/*[" & $i & "]")
			Local $sibling_node = $sibling_node_name & "|" & $sibling_node_attribs & "|" & $sibling_node_text

			if StringCompare($ansestor_node, $sibling_node) <> 0 Then

				Local $out = $ancestor_num & "|S|" & $sibling_node
;				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $out = ' & $out & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

				_ArrayAdd($out_arr, $out, 0, "|", "~")
			EndIf
		Next
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

