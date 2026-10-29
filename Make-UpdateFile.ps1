# ShareBridge - makes version.json for the online update (develop by Binay)
# 1) Put the NEW ShareBridge_Main.exe and ShareBridge_User.exe in the same folder as this file.
# 2) Right-click this file > Run with PowerShell and answer the questions.
# 3) Upload version.json + both EXE files to your GitHub "download" folder (version.json goes in the main folder).
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$defBase = 'https://raw.githubusercontent.com/binoy81162-byte/sharebridge/refs/heads/main/download'
$ver = Read-Host 'New version number (must be HIGHER than the old one, example 3.5)'
$base = Read-Host ("Web folder of the EXE files [Enter = $defBase]")
if (-not $base) { $base = $defBase }
$base = $base.TrimEnd('/')
if (-not $base.StartsWith('https://')) { Write-Host 'The web folder must start with https://' -ForegroundColor Red; Read-Host 'Press Enter'; exit }
$notes = Read-Host 'What is new (one line)'
$m = Join-Path $here 'ShareBridge_Main.exe'; $u = Join-Path $here 'ShareBridge_User.exe'
if (-not (Test-Path $m) -or -not (Test-Path $u)) { Write-Host 'Put ShareBridge_Main.exe and ShareBridge_User.exe next to this file first.' -ForegroundColor Red; Read-Host 'Press Enter'; exit }
foreach ($f in @($m, $u)) {
  $v = (Get-Item $f).VersionInfo.FileVersion
  Write-Host ("{0} is version {1}" -f (Split-Path $f -Leaf), $v)
  try { if ([version]$v -le [version]$ver -and ([version]$v).ToString(2) -ne ([version]$ver).ToString(2)) { Write-Host '  WARNING: the EXE file version differs from the number you typed. Use the EXE version you were given.' -ForegroundColor Yellow } } catch {}
}
$j = [ordered]@{
  version = $ver; notes = $notes
  main = "$base/ShareBridge_Main.exe"; mainSha256 = (Get-FileHash $m -Algorithm SHA256).Hash
  user = "$base/ShareBridge_User.exe"; userSha256 = (Get-FileHash $u -Algorithm SHA256).Hash
}
# write WITHOUT the hidden BOM character
[System.IO.File]::WriteAllText((Join-Path $here 'version.json'), ($j | ConvertTo-Json), (New-Object System.Text.UTF8Encoding($false)))
Write-Host ('Done: ' + (Join-Path $here 'version.json')) -ForegroundColor Green
Read-Host 'Press Enter'
