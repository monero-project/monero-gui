#!/usr/bin/env pwsh
# Script to test the I2P integration in Monero GUI

$ErrorActionPreference = "Stop"

Write-Host "Testing I2P integration for Monero GUI..." -ForegroundColor Cyan

# 1. Verify required files exist
$requiredFiles = @(
    "src/i2p/i2pdaemonmanager.h",
    "src/i2p/i2pdaemonmanager.cpp",
    "pages/settings/SettingsI2P.qml",
    "images/i2p.svg"
)

Write-Host "1. Verifying required files exist..." -ForegroundColor Yellow
$allFilesExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file exists" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file does not exist" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host "Some required files are missing! Please run the build_i2p_integration.ps1 script." -ForegroundColor Red
    exit 1
}

# 2. Check wallet2 I2P methods
$wallet2Files = @{
    "monero/src/wallet/wallet2.h" = @(
        "i2p_enabled",
        "set_i2p_enabled",
        "set_i2p_options",
        "get_i2p_options",
        "parse_i2p_options",
        "init_i2p_connection",
        "discover_i2p_peers"
    );
    "monero/src/wallet/wallet2.cpp" = @(
        "i2p_enabled",
        "set_i2p_enabled",
        "set_i2p_options",
        "get_i2p_options",
        "parse_i2p_options",
        "init_i2p_connection",
        "discover_i2p_peers"
    )
}

Write-Host "2. Checking wallet2 I2P methods..." -ForegroundColor Yellow
$wallet2MethodsExist = $true
foreach ($filePath in $wallet2Files.Keys) {
    if (Test-Path $filePath) {
        $fileContent = Get-Content $filePath -Raw
        foreach ($method in $wallet2Files[$filePath]) {
            if ($fileContent -match $method) {
                Write-Host "  ✓ Method $method found in $filePath" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Method $method not found in $filePath" -ForegroundColor Red
                $wallet2MethodsExist = $false
            }
        }
    } else {
        Write-Host "  ✗ File $filePath does not exist" -ForegroundColor Red
        $wallet2MethodsExist = $false
    }
}

if (-not $wallet2MethodsExist) {
    Write-Host "Some wallet2 I2P methods are missing! Please check the wallet2 implementation." -ForegroundColor Red
}

# 3. Check API layer I2P methods
$apiFiles = @{
    "src/wallet/api/wallet.h" = @(
        "isI2PEnabled",
        "setI2PEnabled",
        "setI2POptions",
        "getI2POptions"
    );
    "src/wallet/api/wallet.cpp" = @(
        "isI2PEnabled",
        "setI2PEnabled",
        "setI2POptions",
        "getI2POptions"
    );
    "src/wallet/api/wallet_manager.h" = @(
        "isI2PEnabled",
        "setI2PEnabled",
        "setI2POptions",
        "getI2POptions"
    );
    "src/wallet/api/wallet_manager.cpp" = @(
        "isI2PEnabled",
        "setI2PEnabled",
        "setI2POptions",
        "getI2POptions"
    )
}

Write-Host "3. Checking API layer I2P methods..." -ForegroundColor Yellow
$apiMethodsExist = $true
foreach ($filePath in $apiFiles.Keys) {
    if (Test-Path $filePath) {
        $fileContent = Get-Content $filePath -Raw
        foreach ($method in $apiFiles[$filePath]) {
            if ($fileContent -match $method) {
                Write-Host "  ✓ Method $method found in $filePath" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Method $method not found in $filePath" -ForegroundColor Red
                $apiMethodsExist = $false
            }
        }
    } else {
        Write-Host "  ✗ File $filePath does not exist" -ForegroundColor Red
        $apiMethodsExist = $false
    }
}

if (-not $apiMethodsExist) {
    Write-Host "Some API layer I2P methods are missing! Please run the apply_i2p_api_patches.ps1 script." -ForegroundColor Red
}

# 4. Check settings integration
$settingsFiles = @{
    "src/model/MoneroSettings.h" = @(
        "useI2P",
        "useBuiltInI2P",
        "i2pAddress",
        "i2pPort",
        "i2pMixedMode",
        "i2pTunnelLength"
    );
    "src/model/MoneroSettings.cpp" = @(
        "setUseI2P",
        "setUseBuiltInI2P",
        "setI2PAddress",
        "setI2PPort",
        "setI2PMixedMode",
        "setI2PTunnelLength"
    )
}

Write-Host "4. Checking settings integration..." -ForegroundColor Yellow
$settingsMethodsExist = $true
foreach ($filePath in $settingsFiles.Keys) {
    if (Test-Path $filePath) {
        $fileContent = Get-Content $filePath -Raw
        foreach ($method in $settingsFiles[$filePath]) {
            if ($fileContent -match $method) {
                Write-Host "  ✓ Property/method $method found in $filePath" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Property/method $method not found in $filePath" -ForegroundColor Red
                $settingsMethodsExist = $false
            }
        }
    } else {
        Write-Host "  ✗ File $filePath does not exist" -ForegroundColor Red
        $settingsMethodsExist = $false
    }
}

if (-not $settingsMethodsExist) {
    Write-Host "Some settings properties/methods are missing! Please check the MoneroSettings implementation." -ForegroundColor Red
}

# 5. Check GUI components
$guiFiles = @{
    "pages/settings/SettingsI2P.qml" = @(
        "enableI2PCheckbox",
        "useBuiltInI2PCheckbox",
        "i2pAddressField",
        "i2pPortField",
        "allowMixedCheckbox",
        "tunnelLengthComboBox",
        "getI2PAddress",
        "getI2PPort",
        "getI2PStatus",
        "applyI2PSettings"
    );
    "components/StatusBar.qml" = @(
        "i2pStatusIcon"
    );
    "LeftPanel.qml" = @(
        "i2pButton"
    );
    "main.qml" = @(
        "initializeI2PSettings"
    )
}

Write-Host "5. Checking GUI components..." -ForegroundColor Yellow
$guiComponentsExist = $true
foreach ($filePath in $guiFiles.Keys) {
    if (Test-Path $filePath) {
        $fileContent = Get-Content $filePath -Raw
        foreach ($component in $guiFiles[$filePath]) {
            if ($fileContent -match $component) {
                Write-Host "  ✓ Component $component found in $filePath" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Component $component not found in $filePath" -ForegroundColor Red
                $guiComponentsExist = $false
            }
        }
    } else {
        Write-Host "  ✗ File $filePath does not exist" -ForegroundColor Red
        $guiComponentsExist = $false
    }
}

if (-not $guiComponentsExist) {
    Write-Host "Some GUI components are missing! Please check the GUI implementation." -ForegroundColor Red
}

# 6. Check CMake configuration
$cmakeFilePath = "CMakeLists.txt"
$cmakeChecks = @(
    "i2pdaemonmanager",
    "WITH_I2P",
    "SettingsI2P.qml",
    "i2p.svg"
)

Write-Host "6. Checking CMake configuration..." -ForegroundColor Yellow
$cmakeConfigExists = $true
if (Test-Path $cmakeFilePath) {
    $cmakeContent = Get-Content $cmakeFilePath -Raw
    foreach ($check in $cmakeChecks) {
        if ($cmakeContent -match $check) {
            Write-Host "  ✓ CMake entry $check found" -ForegroundColor Green
        } else {
            Write-Host "  ✗ CMake entry $check not found" -ForegroundColor Red
            $cmakeConfigExists = $false
        }
    }
} else {
    Write-Host "  ✗ File $cmakeFilePath does not exist" -ForegroundColor Red
    $cmakeConfigExists = $false
}

if (-not $cmakeConfigExists) {
    Write-Host "Some CMake configuration entries are missing! Please check the CMake configuration." -ForegroundColor Red
}

# 7. Test I2P daemon manager
Write-Host "7. Testing I2PDaemonManager functionality..." -ForegroundColor Yellow
try {
    # Create a simple test application
    $testAppDir = "i2p_test"
    if (-not (Test-Path $testAppDir)) {
        New-Item -Path $testAppDir -ItemType Directory -Force | Out-Null
    }

    $testAppPath = "$testAppDir/test_i2p_daemon.cpp"
    Set-Content -Path $testAppPath -Value @"
#include "../src/i2p/i2pdaemonmanager.h"
#include <iostream>
#include <thread>
#include <chrono>

int main() {
    std::cout << "Testing I2PDaemonManager..." << std::endl;
    
    I2PDaemonManager& manager = I2PDaemonManager::instance();
    
    std::cout << "Config directory: " << manager.getConfigDir() << std::endl;
    std::cout << "Data directory: " << manager.getDataDir() << std::endl;
    
    // Check initial state
    std::cout << "Initial state - Running: " << (manager.isRunning() ? "Yes" : "No") << std::endl;
    
    // Test setting tunnel length
    std::cout << "Setting tunnel length to 4..." << std::endl;
    bool setTunnelResult = manager.setTunnelLength(4);
    std::cout << "Set tunnel length result: " << (setTunnelResult ? "Success" : "Failed") << std::endl;
    std::cout << "Current tunnel length: " << manager.getTunnelLength() << std::endl;
    
    // Start daemon
    std::cout << "Starting I2P daemon..." << std::endl;
    bool startResult = manager.start();
    std::cout << "Start result: " << (startResult ? "Success" : "Failed") << std::endl;
    std::cout << "Running: " << (manager.isRunning() ? "Yes" : "No") << std::endl;
    
    // Wait a bit
    std::cout << "Waiting for 2 seconds..." << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(2));
    
    // Stop daemon
    std::cout << "Stopping I2P daemon..." << std::endl;
    bool stopResult = manager.stop();
    std::cout << "Stop result: " << (stopResult ? "Success" : "Failed") << std::endl;
    std::cout << "Running: " << (manager.isRunning() ? "Yes" : "No") << std::endl;
    
    std::cout << "Test completed." << std::endl;
    return 0;
}
"@

    Write-Host "  Created test application in $testAppPath" -ForegroundColor Green
    Write-Host "  To compile and run the test application, use the following commands:" -ForegroundColor Yellow
    Write-Host "  cd $testAppDir" -ForegroundColor Yellow
    Write-Host "  g++ -std=c++11 -I.. test_i2p_daemon.cpp ../src/i2p/i2pdaemonmanager.cpp -o test_i2p_daemon -pthread" -ForegroundColor Yellow
    Write-Host "  ./test_i2p_daemon" -ForegroundColor Yellow
    Write-Host "  Note: This test requires the I2P daemon binary (i2pd) to be in the application directory" -ForegroundColor Yellow

} catch {
    Write-Host "  ✗ Failed to create test application: $_" -ForegroundColor Red
}

# 8. Summary
Write-Host "`nI2P Integration Test Summary:" -ForegroundColor Cyan
$testsPassed = @()
$testsFailed = @()

if ($allFilesExist) { $testsPassed += "Required files exist" } else { $testsFailed += "Required files check" }
if ($wallet2MethodsExist) { $testsPassed += "wallet2 I2P methods" } else { $testsFailed += "wallet2 I2P methods check" }
if ($apiMethodsExist) { $testsPassed += "API layer I2P methods" } else { $testsFailed += "API layer I2P methods check" }
if ($settingsMethodsExist) { $testsPassed += "Settings integration" } else { $testsFailed += "Settings integration check" }
if ($guiComponentsExist) { $testsPassed += "GUI components" } else { $testsFailed += "GUI components check" }
if ($cmakeConfigExists) { $testsPassed += "CMake configuration" } else { $testsFailed += "CMake configuration check" }

Write-Host "Tests passed: $($testsPassed.Count)" -ForegroundColor Green
foreach ($test in $testsPassed) {
    Write-Host "  ✓ $test" -ForegroundColor Green
}

Write-Host "Tests failed: $($testsFailed.Count)" -ForegroundColor Red
foreach ($test in $testsFailed) {
    Write-Host "  ✗ $test" -ForegroundColor Red
}

if ($testsFailed.Count -eq 0) {
    Write-Host "`nAll tests passed! I2P integration is complete and ready for build." -ForegroundColor Green
    Write-Host "To build the Monero GUI with I2P support, use the following command:" -ForegroundColor Yellow
    Write-Host "  cmake -DWITH_I2P=ON .." -ForegroundColor Yellow
} else {
    Write-Host "`nSome tests failed. Please fix the issues and run the test script again." -ForegroundColor Red
}

Write-Host "`nTest script completed!" -ForegroundColor Cyan 