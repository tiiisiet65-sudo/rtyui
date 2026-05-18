$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\PortableShellLink.ps1"

$out = Join-Path $PSScriptRoot 'Download-macOSx-from-Cloud.lnk'
$vbs = Join-Path $PSScriptRoot 'Download.macOSx.vbs'
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

if (-not (Test-Path -LiteralPath $vbs)) {
    Write-Error "Not found: $vbs"
}

# Create portable .lnk: SLDF_FORCE_NO_* to let Windows find target by relative path when copying folder.
[LnkPortable.PortableShortcut]::Create(
    $out,
    $vbs,
    $ps,
    'Download macOSx from Cloud (portable shortcut, just copy the folder)'
)

Write-Host "Created (portable): $out"
Write-Host "You can copy the entire folder to another machine/drive; fixed D:\ path is not needed."
