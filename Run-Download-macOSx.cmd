@echo off
setlocal
REM Always run script in the same folder with this .cmd (even when copied to another drive/machine).
cd /d "%~dp0"

echo.
echo [Run-Download-macOSx] Folder: %CD%
echo.

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: powershell.exe not found in PATH.
    goto :end
)

if not exist "%~dp0restore-macOSx-from-cloud.ps1" (
    echo ERROR: File not found: restore-macOSx-from-cloud.ps1
    echo Please run this .cmd file in the copied folder (do not use old shortcut from another machine).
    goto :end
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File "%~dp0restore-macOSx-from-cloud.ps1"
set ERR=%ERRORLEVEL%

echo.
if %ERR% neq 0 (
    echo PowerShell exited with error code: %ERR%
) else (
    echo PowerShell exited normally: 0
)

:end
echo.
pause
