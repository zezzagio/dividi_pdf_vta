@ECHO OFF
IF [%1%]==[au3] (
"c:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2exe_x64.exe" /in dividi_pdf_vta.au3 /out dividi_pdf_vta.exe
copy dividi_pdf_vta.au3.ini dividi_pdf_vta.exe.ini
)
IF [%1%]==[ahk] (
"c:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in dividi_pdf_vta.ahk /base "c:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /icon iconfile1.ico /out dividi_pdf_vta.exe
copy dividi_pdf_vta.ahk.ini dividi_pdf_vta.exe.ini
)
