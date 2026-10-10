$ErrorActionPreference = "Stop"

$Root = $PSScriptRoot
$Backend = Join-Path $Root "library_management_backend"
$Frontend = Join-Path $Root "library_management_frontend"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Library Management System" -ForegroundColor Cyan
Write-Host " Backend + Flutter Mobile" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Verify project files

if (!(Test-Path (Join-Path $Backend "pubspec.yaml"))) {
throw "Backend pubspec.yaml not found: $Backend"
}

if (!(Test-Path (Join-Path $Frontend "pubspec.yaml"))) {
throw "Flutter pubspec.yaml not found: $Frontend"
}

# Verify required tools

foreach ($Tool in @("dart", "dart_frog", "flutter")) {
if (!(Get-Command $Tool -ErrorAction SilentlyContinue)) {
throw "$Tool is not installed or missing from PATH."
}
}

# Install backend dependencies

Write-Host "[1/4] Installing backend dependencies..." -ForegroundColor Yellow

Push-Location $Backend
try {
dart pub get
if ($LASTEXITCODE -ne 0) {
throw "Backend dependency installation failed."
}
}
finally {
Pop-Location
}

# Install Flutter dependencies

Write-Host "[2/4] Installing Flutter dependencies..." -ForegroundColor Yellow

Push-Location $Frontend
try {
flutter pub get
if ($LASTEXITCODE -ne 0) {
throw "Flutter dependency installation failed."
}
}
finally {
Pop-Location
}

# Check connected mobile devices

Write-Host "`nChecking Flutter mobile devices..." -ForegroundColor Yellow

flutter devices

if ($LASTEXITCODE -ne 0) {
throw "Unable to list Flutter devices."
}

# Find PowerShell

$PowerShellExe = (Get-Command powershell.exe).Source

# Terminal 1: Dart Frog backend

Write-Host "`n[3/4] Opening backend terminal..." -ForegroundColor Green

$BackendCommand = "Set-Location -LiteralPath '$Backend'; dart_frog dev"

Start-Process -FilePath $PowerShellExe -ArgumentList @(
"-NoExit",
"-Command",
$BackendCommand
)

Start-Sleep -Seconds 2

# Terminal 2: Flutter mobile app

Write-Host "[4/4] Opening Flutter mobile terminal..." -ForegroundColor Green

$MobileCommand = "Set-Location -LiteralPath '$Frontend'; flutter run"

Start-Process -FilePath $PowerShellExe -ArgumentList @(
"-NoExit",
"-Command",
$MobileCommand
)

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " Both terminals launched!" -ForegroundColor Green
Write-Host " Terminal 1: Dart Frog Backend" -ForegroundColor Cyan
Write-Host " Terminal 2: Flutter Mobile App" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Green
