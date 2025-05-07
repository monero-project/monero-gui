# I2P Integration Testing Script
# This script performs automated testing of the I2P integration in Monero GUI wallet

# Set error preference to stop on any error
$ErrorActionPreference = "Stop"

# Define color codes for output
$GREEN = [char]27 + "[32m"
$RED = [char]27 + "[31m"
$YELLOW = [char]27 + "[33m"
$RESET = [char]27 + "[0m"

# Configuration
$LOG_FILE = "i2p_test_results.log"
$MONERO_GUI_DIR = (Get-Location).Path
$TEST_WALLET_NAME = "i2p_test_wallet"
$TEST_WALLET_PASSWORD = "testpassword"

# Initialize log file
"[$(Get-Date)] I2P Integration Test Started" | Out-File -FilePath $LOG_FILE

function Write-TestHeader {
    param (
        [string]$text
    )
    
    $header = "`n==== $text ====`n"
    Write-Host "$YELLOW$header$RESET"
    $header | Out-File -FilePath $LOG_FILE -Append
}

function Write-Success {
    param (
        [string]$text
    )
    
    Write-Host "$GREEN[SUCCESS]$RESET $text"
    "[SUCCESS] $text" | Out-File -FilePath $LOG_FILE -Append
}

function Write-Error {
    param (
        [string]$text
    )
    
    Write-Host "$RED[ERROR]$RESET $text"
    "[ERROR] $text" | Out-File -FilePath $LOG_FILE -Append
}

function Test-FileExists {
    param (
        [string]$filePath,
        [string]$description
    )
    
    if (Test-Path $filePath) {
        Write-Success "$description file exists: $filePath"
        return $true
    } else {
        Write-Error "$description file is missing: $filePath"
        return $false
    }
}

# Check if the script is running from the Monero GUI directory
Write-TestHeader "Environment Verification"

# Test if build was done with I2P support
$cmakeCache = Get-Content -Path "$MONERO_GUI_DIR/CMakeCache.txt" -ErrorAction SilentlyContinue
if ($cmakeCache -match "WITH_I2P:BOOL=ON") {
    Write-Success "Build includes I2P support"
} else {
    Write-Error "Build does not include I2P support. Please rebuild with -DWITH_I2P=ON option."
    exit 1
}

# Test component files existence
Write-TestHeader "File Existence Tests"

$testFiles = @(
    @{ Path = "src/i2p/i2pdaemonmanager.h"; Description = "I2P Daemon Manager header" },
    @{ Path = "src/i2p/i2pdaemonmanager.cpp"; Description = "I2P Daemon Manager implementation" },
    @{ Path = "pages/settings/SettingsI2P.qml"; Description = "I2P Settings QML" },
    @{ Path = "images/i2p.svg"; Description = "I2P icon" }
)

$fileTestsPassed = $true
foreach ($file in $testFiles) {
    $result = Test-FileExists -filePath "$MONERO_GUI_DIR/$($file.Path)" -description $file.Description
    if (-not $result) {
        $fileTestsPassed = $false
    }
}

if (-not $fileTestsPassed) {
    Write-Error "Some required files are missing. Check the log for details."
}

# Test for MoneroSettings I2P properties
Write-TestHeader "MoneroSettings I2P Properties Test"

$moneroSettingsFile = "$MONERO_GUI_DIR/src/model/MoneroSettings.h"
$moneroSettingsContent = Get-Content -Path $moneroSettingsFile -ErrorAction SilentlyContinue

if ($moneroSettingsContent -match "Q_PROPERTY\(bool useI2P READ useI2P WRITE setUseI2P NOTIFY useI2PChanged\)") {
    Write-Success "MoneroSettings contains useI2P property"
} else {
    Write-Error "MoneroSettings missing useI2P property"
}

if ($moneroSettingsContent -match "Q_PROPERTY\(bool useBuiltInI2P READ useBuiltInI2P WRITE setUseBuiltInI2P NOTIFY useBuiltInI2PChanged\)") {
    Write-Success "MoneroSettings contains useBuiltInI2P property"
} else {
    Write-Error "MoneroSettings missing useBuiltInI2P property"
}

# Test I2P icon in status bar
Write-TestHeader "StatusBar I2P Integration Test"

$statusBarFile = "$MONERO_GUI_DIR/components/StatusBar.qml"
$statusBarContent = Get-Content -Path $statusBarFile -ErrorAction SilentlyContinue

if ($statusBarContent -match "i2p\.svg") {
    Write-Success "StatusBar includes I2P icon reference"
} else {
    Write-Error "StatusBar is missing I2P icon reference"
}

# Test I2P menu in left panel
Write-TestHeader "LeftPanel I2P Integration Test"

$leftPanelFile = "$MONERO_GUI_DIR/LeftPanel.qml"
$leftPanelContent = Get-Content -Path $leftPanelFile -ErrorAction SilentlyContinue

if ($leftPanelContent -match 'text: "I2P"') {
    Write-Success "LeftPanel includes I2P menu item"
} else {
    Write-Error "LeftPanel is missing I2P menu item"
}

# Test wallet2 I2P methods
Write-TestHeader "wallet2 I2P Methods Test"

$wallet2File = "$MONERO_GUI_DIR/monero/src/wallet/wallet2.h"
$wallet2Content = Get-Content -Path $wallet2File -ErrorAction SilentlyContinue

$wallet2Methods = @(
    "set_i2p_enabled",
    "i2p_enabled",
    "set_i2p_options",
    "discover_i2p_peers"
)

foreach ($method in $wallet2Methods) {
    if ($wallet2Content -match $method) {
        Write-Success "wallet2 contains $method method"
    } else {
        Write-Error "wallet2 missing $method method"
    }
}

# Test implementations of methods in wallet2.cpp
Write-TestHeader "wallet2 Implementation Test"

$wallet2CppFile = "$MONERO_GUI_DIR/monero/src/wallet/wallet2.cpp"
$wallet2CppContent = Get-Content -Path $wallet2CppFile -ErrorAction SilentlyContinue

# Check for key implementation patterns
if ($wallet2CppContent -match "discover_i2p_peers") {
    Write-Success "wallet2.cpp contains discover_i2p_peers implementation"
} else {
    Write-Error "wallet2.cpp missing discover_i2p_peers implementation"
}

if ($wallet2CppContent -match "init_i2p_connection") {
    Write-Success "wallet2.cpp contains init_i2p_connection implementation"
} else {
    Write-Error "wallet2.cpp missing init_i2p_connection implementation"
}

# Test I2PDaemonManager functionality
Write-TestHeader "I2PDaemonManager Test"

$daemonManagerPath = "$MONERO_GUI_DIR/src/i2p/i2pdaemonmanager.cpp"
$daemonManagerContent = Get-Content -Path $daemonManagerPath -ErrorAction SilentlyContinue

$managerMethods = @(
    "start",
    "stop",
    "isRunning",
    "instance"
)

foreach ($method in $managerMethods) {
    if ($daemonManagerContent -match $method) {
        Write-Success "I2PDaemonManager contains $method method"
    } else {
        Write-Error "I2PDaemonManager missing $method method"
    }
}

# Test SettingsI2P QML file
Write-TestHeader "SettingsI2P QML Test"

$settingsI2PPath = "$MONERO_GUI_DIR/pages/settings/SettingsI2P.qml"
$settingsI2PContent = Get-Content -Path $settingsI2PPath -ErrorAction SilentlyContinue

$settingsElements = @(
    "useI2P",
    "useBuiltInI2P",
    "i2pAddress",
    "i2pPort"
)

foreach ($element in $settingsElements) {
    if ($settingsI2PContent -match $element) {
        Write-Success "SettingsI2P.qml contains $element element"
    } else {
        Write-Error "SettingsI2P.qml missing $element element"
    }
}

# Test if calls to I2PDaemonManager are implemented
if ($settingsI2PContent -match "I2PDaemonManager\.instance\(\)\.start\(\)") {
    Write-Success "SettingsI2P.qml includes call to I2PDaemonManager.start()"
} else {
    Write-Error "SettingsI2P.qml missing call to I2PDaemonManager.start()"
}

if ($settingsI2PContent -match "I2PDaemonManager\.instance\(\)\.stop\(\)") {
    Write-Success "SettingsI2P.qml includes call to I2PDaemonManager.stop()"
} else {
    Write-Error "SettingsI2P.qml missing call to I2PDaemonManager.stop()"
}

# End of tests
Write-TestHeader "Test Summary"

$logContent = Get-Content -Path $LOG_FILE
$successCount = ($logContent | Select-String -Pattern "\[SUCCESS\]").Count
$errorCount = ($logContent | Select-String -Pattern "\[ERROR\]").Count

Write-Host "Tests completed: $($successCount + $errorCount)"
Write-Host "Succeeded: $GREEN$successCount$RESET"
Write-Host "Failed: $RED$errorCount$RESET"

"Tests completed: $($successCount + $errorCount)" | Out-File -FilePath $LOG_FILE -Append
"Succeeded: $successCount" | Out-File -FilePath $LOG_FILE -Append
"Failed: $errorCount" | Out-File -FilePath $LOG_FILE -Append

if ($errorCount -gt 0) {
    Write-Host "$RED`nSome tests failed. Please check the log file for details: $LOG_FILE$RESET"
    exit 1
} else {
    Write-Host "$GREEN`nAll I2P integration tests passed successfully!$RESET"
    exit 0
} 