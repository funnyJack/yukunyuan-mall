# Bootstrap script: install Flutter stable into D:\software\flutter
# Usage: powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool\install_flutter.ps1
# Safe to re-run: exits when installed, resumes a partial zip download.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$root = 'D:\software'
$dest = Join-Path $root 'flutter'
$zip = Join-Path $env:TEMP 'flutter-stable.zip'
$flutterBat = Join-Path $dest 'bin\flutter.bat'

if (Test-Path $flutterBat) {
    Write-Output "ALREADY_INSTALLED=$dest"
    exit 0
}

# Flutter China mirror is much faster than storage.googleapis.com here.
$url = 'https://storage.flutter-io.cn/flutter_infra_release/releases/stable/windows/flutter_windows_3.47.9-stable.zip'
$env:FLUTTER_STORAGE_BASE_URL = 'https://storage.flutter-io.cn'
$env:PUB_HOSTED_URL = 'https://pub.flutter-io.cn'

Write-Output "URL=$url"
& curl.exe -L -C - --retry 5 --retry-delay 3 --fail -o $zip $url
if ($LASTEXITCODE -ne 0) { throw "download failed, exit=$LASTEXITCODE" }
Write-Output "DOWNLOADED=$((Get-Item $zip).Length)"

New-Item -ItemType Directory -Force -Path $root | Out-Null
if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
& tar.exe -xf $zip -C $root
if ($LASTEXITCODE -ne 0) { throw "extract failed, exit=$LASTEXITCODE" }
Write-Output "EXTRACTED=$dest"

& (Join-Path $dest 'bin\flutter.bat') --version
Write-Output "INSTALL_DONE"
