; Create the MyGui window:
ini_file := Format("{1:s}\{2:s}.{3:s}", A_ScriptDir, A_ScriptName, "ini")
pdftotext := IniRead(ini_file, "programmi", "pdftotext")
qpdf := IniRead(ini_file, "programmi", "qpdf")

MyGui := Gui("+Resize", "Untitled")  ; Make the window resizable.
; Create the submenus for the menu bar:
FileMenu := Menu()
FileMenu.Add("&Apri", MenuFileOpen)
FileMenu.Add() ; Separator line.
FileMenu.Add("E&xit", MenuFileExit)
HelpMenu := Menu()
HelpMenu.Add("&About", MenuHelpAbout)

; Create the menu bar by attaching the submenus to it:
MyMenuBar := MenuBar()
MyMenuBar.Add("&File", FileMenu)

; Attach the menu bar to the window:
MyGui.MenuBar := MyMenuBar

; Create the main Edit control:
MainEdit := MyGui.Add("Edit", "WantTab W600 R20")

; Apply events:
;MyGui.OnEvent("DropFiles", Gui_DropFiles)
MyGui.OnEvent("Size", Gui_Size)

MenuFileNew()  ; Apply default settings.
MyGui.Show()  ; Display the window.

MenuFileNew(*)
{
    MainEdit.Value := ""  ; Clear the Edit control.
    MyGui.Title := "Dividi il report PDF delle VSA"
}

MenuFileOpen(*)
{
    MyGui.Opt("+OwnDialogs")  ; Force the user to dismiss the FileSelect dialog before returning to the main window.
    documento_pdf := FileSelect(3,, "Seleziona documento VSA da dividere", " (*.pdf)")
    if documento_pdf = "" ; No file selected.
        return
    GuiEditAppend(MainEdit, Format('File da dividere: "{1:s}"`r`n', documento_pdf))
    GuiEditAppend(MainEdit, '-- INIZIO LETTURA --`r`n')
    OutDir := ""
    SplitPath documento_pdf, , &OutDir
    text_file := documento_pdf . ".txt"
    
    comando := Format('"{1:s}" -layout "{2:s}" "{3:s}"', pdftotext, documento_pdf, text_file)
    esito := RunWait(comando, OutDir)
    
    If esito = 0 {
        nome_file_batch := Format("{1:s}\{2:s}", OutDir, "genera_pdf.bat")
        leggi_file(text_file, nome_file_batch)
        GuiEditAppend(MainEdit, "-- FINE LETTURA - FILE COMANDI GENERATO --`r`n")
        risposta := MsgBox("Vuoi procedere alla suddivisione del pdf? i pdf risultanti verrano generati nella stessa cartella dell'originale",
                            "Dividi pdf VSA",
                            "YesNo")
        if risposta = "Yes"
        {
            GuiEditAppend(MainEdit, Format('Adesso divido il file "{1:s}"`r`n', documento_pdf))
            RunWait(nome_file_batch, OutDir)
            GuiEditAppend(MainEdit, "-- FINE --`r`n")
        } else {
            GuiEditAppend(MainEdit, "-- DIVISIONE NON ESEGUITA --`r`n")
        }
    }
}

leggi_file(nome_file, nome_file_batch)
{
    dir_lavoro := ""
    da_pag := 1
    a_pag := 1
    pag := 1
    result := unset
    data := unset
    albero := ""
    in_file := FileOpen(nome_file, 'r')
    file_batch := FileOpen(nome_file_batch, 1)
    SplitPath nome_file,,,,&pdf_rel
    GuiEditAppend(MainEdit, format("{1:s}`t{2:s}`r`n", "pagina", "albero"))
    while not in_file.atEOF
    {
        riga := in_file.ReadLine()
        if RegExMatch(riga, "^\f")
        {
            pag++
            Continue
        }
        if RegExMatch(riga, '(?i)^\s*nr\. albero (\d+)', &result)
        {
            if albero
            {
                stampa_comando(file_batch, albero, data, da_pag, pag - 1, pdf_rel)
                GuiEditAppend(MainEdit, format("{1:d}`t{2:s}`r`n", da_pag, albero))
                da_pag := pag
            }
            albero := result[1]
            Continue
        }
        if RegExMatch(riga, '(?i)\s*vsa - data:\s*(\S+)', &result)
        {
            data := result[1]
            Continue
        }
    }
    GuiEditAppend(MainEdit, format("{1:d}`t{2:s}`r`n", da_pag, albero))
    stampa_comando(file_batch, albero, data, da_pag, 'z', pdf_rel)
    in_file.Close()
    file_batch.Close()
}

stampa_comando(hout, albero, sdata, da_pag, a_pag, file_pdf)
{
    data := StrSplit(sdata, "/")
    comando := Format('"{1:s}" "{2:s}" --pages . {3:s}-{4:s} -- {5:s}_{6:s}-{7:s}-{8:s}_strumentale.pdf', qpdf, file_pdf, da_pag, a_pag, albero, data[3], data[2], data[1])
    hout.WriteLine(comando)
}

MenuFileSave(*)
{
    saveContent(CurrentFileName)
}

MenuFileSaveAs(*)
{
    MyGui.Opt("+OwnDialogs")  ; Force the user to dismiss the FileSelect dialog before returning to the main window.
    SelectedFileName := FileSelect("S16",, "Save File", "Text Documents (*.txt)")
    if SelectedFileName = "" ; No file selected.
        return
    global CurrentFileName := saveContent(SelectedFileName)
}

MenuFileExit(*)  ; User chose "Exit" from the File menu.
{
    WinClose()
}

MenuHelpAbout(*)
{
    About := Gui("+owner" MyGui.Hwnd)  ; Make the main window the owner of the "about box".
    MyGui.Opt("+Disabled")  ; Disable main window.
    About.Add("Text",, "Text for about box.")
    About.Add("Button", "Default", "OK").OnEvent("Click", About_Close)
    About.OnEvent("Close", About_Close)
    About.OnEvent("Escape", About_Close)
    About.Show()

    About_Close(*)
    {
        MyGui.Opt("-Disabled")  ; Re-enable the main window (must be done prior to the next step).
        About.Destroy()  ; Destroy the about box.
    }
}

saveContent(FileName)
{
    try
    {
        if FileExist(FileName)
            FileDelete(FileName)
        FileAppend(MainEdit.Value, FileName)  ; Save the contents to the file.
    }
    catch
    {
        MsgBox("The attempt to overwrite '" FileName "' failed.")
        return
    }
    ; Upon success, Show file name in title bar (in case we were called by MenuFileSaveAs):
    MyGui.Title := FileName
    return FileName
}

Gui_Size(thisGui, MinMax, Width, Height)
{
    if MinMax = -1  ; The window has been minimized. No action needed.
        return
    ; Otherwise, the window has been resized or maximized. Resize the Edit control to match.
    MainEdit.Move(,, Width-20, Height-20)
}

GuiEditAppend(HED, Append) {
   ; SendMessage, 0x00B1, -2, -1, , ahk_id %HED%
   SendMessage(0x00B1, -1, -1, HED.Hwnd) ;//0x00C2
   SendMessage(0x00C2, False, StrPtr(Append), HED.Hwnd) ;//0x00C2
   SendMessage(0x00B1, -1, -1, HED.Hwnd) ;//0x00C2
   ; SendMessage, 0x00B7, 0, 0, , ahk_id %HED%
}