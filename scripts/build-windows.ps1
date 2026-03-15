# Monero GUI - Windows Build Script
# Run this in PowerShell as Administrator

$ErrorActionPreference = "Stop"

Write-Host "=== Monero GUI Windows Build ===" -ForegroundColor Cyan

# --- Check prerequisites ---
Write-Host "`n[1/5] Checking prerequisites..." -ForegroundColor Yellow

# Check Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Git not found. Install from https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

# Check CMake
if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: CMake not found. Install from https://cmake.org/download/" -ForegroundColor Red
    exit 1
}

# Check Ninja
if (-not (Get-Command ninja -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Ninja via winget..." -ForegroundColor Yellow
    winget install Ninja-build.Ninja -e --silent
    $env:PATH += ";$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Ninja-build.Ninja*\ninja.exe"
}

# Check Qt5
$QtPath = @(
    "C:\Qt\5.15.2\msvc2019_64",
    "C:\Qt\5.15.13\msvc2019_64",
    "C:\Qt\5.15\msvc2019_64"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $QtPath) {
    Write-Host "ERROR: Qt5 not found." -ForegroundColor Red
    Write-Host "Install Qt 5.15 from https://www.qt.io/download-open-source" -ForegroundColor Red
    Write-Host "Select: MSVC 2019 64-bit component" -ForegroundColor Red
    exit 1
}
Write-Host "Found Qt5 at: $QtPath" -ForegroundColor Green

# --- Clone repo ---
Write-Host "`n[2/5] Cloning repository..." -ForegroundColor Yellow
$BuildDir = "$env:USERPROFILE\monero-gui"
if (Test-Path $BuildDir) {
    Write-Host "Directory exists, pulling latest..." -ForegroundColor Yellow
    Set-Location $BuildDir
    git pull
} else {
    git clone --recursive https://github.com/IamOneInx/monero-gui.git -b feat/i2p-integration $BuildDir
    Set-Location $BuildDir
}

# --- Configure ---
Write-Host "`n[3/5] Configuring with CMake..." -ForegroundColor Yellow
$env:CMAKE_PREFIX_PATH = $QtPath
cmake -S . -B build -GNinja `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_PREFIX_PATH="$QtPath" `
    -DUSE_DEVICE_TREZOR=OFF `
    -DCMAKE_MAKE_PROGRAM=ninja

# --- Build ---
Write-Host "`n[4/5] Building (this will take 20-40 minutes)..." -ForegroundColor Yellow
$cores = (Get-WmiObject Win32_Processor).NumberOfLogicalProcessors
ninja -C build -j $cores

# --- Package ---
Write-Host "`n[5/5] Packaging installer..." -ForegroundColor Yellow

# Check for Inno Setup
$InnoSetup = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($InnoSetup) {
    # Copy built binaries to installer staging area
    Copy-Item "build\bin\monero-wallet-gui.exe" "installers\windows\bin\" -Force
    Copy-Item "build\bin\monerod.exe" "installers\windows\bin\" -Force
    Copy-Item "build\bin\i2pd.exe" "installers\windows\bin\" -Force

    Set-Location "installers\windows"
    & $InnoSetup Monero.iss
    Write-Host "Installer built: installers\windows\Output\monero-wallet-gui-installer.exe" -ForegroundColor Green
} else {
    Write-Host "Inno Setup not found - skipping installer." -ForegroundColor Yellow
    Write-Host "Install from https://jrsoftware.org/isdl.php" -ForegroundColor Yellow
    Write-Host "Binaries are at: $BuildDir\build\bin\" -ForegroundColor Green
}

Write-Host "`n=== BUILD COMPLETE ===" -ForegroundColor Cyan
Write-Host "Test: run build\bin\monero-wallet-gui.exe" -ForegroundColor Green
Write-Host "Then go to Settings -> Node and enable i2p" -ForegroundColor Green
