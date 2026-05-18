' .lnk -> wscript -> this file -> Run-Download-macOSx.cmd (always use the folder containing .vbs, even after copying to another drive/machine).
Option Explicit
Dim sh, fso, dir, cmd
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
cmd = dir & "\Run-Download-macOSx.cmd"
If Not fso.FileExists(cmd) Then
  MsgBox "Not found: " & cmd, vbCritical, "Download macOSx"
  WScript.Quit 1
End If
Set sh = CreateObject("WScript.Shell")
sh.Run Chr(34) & cmd & Chr(34), 1, True
