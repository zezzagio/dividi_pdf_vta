;-*- mode: VBasic; tab-size: 4 -*-
#include <EditConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>
#include <File.au3>

Global $ini_file = StringFormat("%s\%s.ini", @ScriptDir, @ScriptName)
Global $nome_script = "genera_pdf.bat"
Global $dir_lavoro
Global $nome_file_batch

main()

Func main()
	; Create a constant variable in Local scope of the message to display in FileOpenDialog.
	Local Const $sMessage = "Seleziona il pdf VTA da dividere."
	; Display an open dialog to select a list of file(s).
    Local $sFileOpenDialog = FileOpenDialog($sMessage, @WindowsDir & "\", "Documenti pdf (*.pdf)|Tutti (*.*)", $FD_FILEMUSTEXIST)

	If @error Then
		; Display the error message.
		MsgBox($MB_SYSTEMMODAL, "", "Nessun file selezionato.")

		; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
		FileChangeDir(@WorkingDir)
     Else
        Local $sDrive, $sDir, $sFileName, $sExtension
        $percorsi = _PathSplit($sFileOpenDialog, $sDrive, $sDir, $sFileName, $sExtension)
        
        $dir_lavoro = _PathMake($sDrive, $sDir, "", "")
        
        $nome_file_batch = StringFormat("%s\%s", $dir_lavoro, $nome_script)
        
		FileChangeDir($dir_lavoro)
        
		; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.

		; Replace instances of "|" with @CRLF in the string returned by FileOpenDialog.
        ;$sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)
        
        dividi($sFileOpenDialog)
        RunWait($nome_file_batch)
	EndIf
EndFunc

Func dividi($file)
    FileChangeDir($dir_lavoro)
    ;log_window()
    $pdf2text = IniRead($ini_file, "programmi", "pdftotext", "" )
    $text_file = StringFormat("%s.txt", $file)
    $comando = StringFormat('"%s" -layout "%s" "%s"', $pdf2text, $file, $text_file)
	$esito = RunWait($comando)
    If @error <> 0 Then
        MsgBox($MB_SYSTEMMODAL, "", "C'è stato qualche problema")
        Exit
    EndIf
    leggi_file($text_file)
    ;stampa("--- FINE LAVORO ---")
    ;aspetta_fine()
EndFunc

Func leggi_file($file)
    FileChangeDir($dir_lavoro)
    Local $hLeggi = FileOpen($file, $FO_READ)
    Local $hScrivi = FileOpen($nome_file_batch, $FO_OVERWRITE)
    Local $da_pag = 1
    Local $a_pag = 1
    Local $pag = 1
    Local $albero = ""
    Local $result
    Local $data
    Local $pdf_rel
    Local $sDrive, $sDir, $sFileName, $sExtension 
    Local $qpdf = IniRead($ini_file, "programmi", "qpdf", "" )
    $percorsi = _PathSplit($file, $sDrive, $sDir, $sFileName, $sExtension)
    $pdf_rel = $percorsi[$PATH_FILENAME]
    If $hLeggi = -1 Then
        MsgBox($MB_SYSTEMMODAL, "", "Non sono riuscito ad aprire il file.")
        Exit
    EndIf
    While 1
       $riga = FileReadLine($hLeggi)
       If @error = -1 Then ExitLoop
       $result = StringRegExp($riga, '^\f', $STR_REGEXPMATCH)
       If $result then
          $pag = $pag + 1
          ContinueLoop
       EndIf
       $result = StringRegExp($riga, '(?i)^\s*nr\. albero (\d+)', $STR_REGEXPARRAYFULLMATCH)
       If @error = 0 then
          If $albero <> "" Then
             stampa_comando($hScrivi, $qpdf, $albero, $data, $da_pag, $pag - 1, $pdf_rel)
             ;stampa(StringFormat("ECCOLO: %s-%s %d-%d", $albero, $data, $da_pag, $pag - 1))
             $da_pag = $pag
          EndIf
          $albero = $result[1]
          ContinueLoop
       EndIf
       $result = StringRegExp($riga, '(?i)\s*vsa - data:\s*(\S+)', $STR_REGEXPARRAYFULLMATCH)
       If @error = 0 then
          $data = $result[1]
          ContinueLoop
       EndIf
    Wend
    stampa_comando($hScrivi, $qpdf, $albero, $data, $da_pag, 'z', $pdf_rel)
    FileClose($hLeggi)
    FileClose($hScrivi)
EndFunc

Func log_window()

    Local $dim_desktop = WinGetClientSize("Program Manager")
    Local $larghezza_log = $dim_desktop[0] / 2
    Local $altezza_log = $dim_desktop[1]

    $gui = GUICreate("Dividi grafici", $larghezza_log, $altezza_log, 0, 0)
    
    MsgBox($MB_SYSTEMMODAL, "", $ES_AUTOVSCROLL)
 
    Local $log_wnd = GUICtrlCreateEdit("", 10, 10, $larghezza_log - 20, $altezza_log - 20, $ES_AUTOVSCROLL + $WS_VSCROLL)

    stampa("", $log_wnd)

    GUISetState(@SW_SHOW, $gui)

    Send("{END}")

EndFunc

Func aspetta_fine()
    While 1
       Switch GUIGetMsg()
       Case $GUI_EVENT_CLOSE
          ExitLoop
       EndSwitch
    WEnd

    GUIDelete()
EndFunc

Func stampa($messaggio, $handle = 0)
    Static Local $hwnd
    If $handle <> 0 Then
        $hwnd = $handle
        Return
    Else
        GUICtrlSetData($hwnd, $messaggio & @CRLF, 1)
    EndIf
EndFunc

Func stampa_comando($hout, $qpdf, $albero, $sdata, $da_pag, $a_pag, $file_pdf)
    $data = StringSplit($sdata, "/")
    $comando = StringFormat('"%s" "%s" --pages . %s-%s -- %s_%s-%s-%s_strumentale.pdf\n', $qpdf, $file_pdf, $da_pag, $a_pag, $albero, $data[3], $data[2], $data[1])
    FileWrite($hout, $comando)
EndFunc
    