#!/usr/bin/env pwsh
# Script to build the I2P integration for Monero GUI

$ErrorActionPreference = "Stop"

Write-Host "Building I2P integration for Monero GUI..." -ForegroundColor Cyan

# 1. Apply API implementation patches
Write-Host "1. Applying API implementation patches..." -ForegroundColor Yellow
& ./apply_i2p_api_patches.ps1

# 2. Create directory for I2P implementation files
$i2pDir = "src/i2p"
if (-not (Test-Path $i2pDir)) {
    Write-Host "Creating directory: $i2pDir" -ForegroundColor Yellow
    New-Item -Path $i2pDir -ItemType Directory -Force | Out-Null
}

# 3. Copy I2PDaemonManager implementation
Write-Host "3. Copying I2PDaemonManager implementation..." -ForegroundColor Yellow
Copy-Item -Path "src/i2p/i2pdaemonmanager.h" -Destination "$i2pDir/" -Force
Copy-Item -Path "src/i2p/i2pdaemonmanager.cpp" -Destination "$i2pDir/" -Force

# 4. Apply MoneroSettings patches
Write-Host "4. Applying MoneroSettings patches..." -ForegroundColor Yellow
$moneroSettingsHPatch = Get-Content "src/model/MoneroSettings.h.patch" -Raw
$moneroSettingsCppPatch = Get-Content "src/model/MoneroSettings.cpp.patch" -Raw

$moneroSettingsH = "src/model/MoneroSettings.h"
$moneroSettingsCpp = "src/model/MoneroSettings.cpp"

# Apply MoneroSettings.h patch
$moneroSettingsHContent = Get-Content $moneroSettingsH -Raw
if ($moneroSettingsHContent -match "bool useI2P\(\) const") {
    Write-Host "I2P methods already exist in $moneroSettingsH - skipping" -ForegroundColor Green
} else {
    Write-Host "Applying patch to $moneroSettingsH..." -ForegroundColor Yellow
    
    # Add I2P properties
    $pattern = '    // How to buy Monero dialog(\r?\n)    Q_PROPERTY\(QString fiatApiCurrencyQuery READ fiatApiCurrencyQuery\)(\r?\n)    Q_PROPERTY\(QString fiatApiAltCurrencyQuery READ fiatApiAltCurrencyQuery\)(\r?\n)'
    $replacement = '    // How to buy Monero dialog$1    Q_PROPERTY(QString fiatApiCurrencyQuery READ fiatApiCurrencyQuery)$2    Q_PROPERTY(QString fiatApiAltCurrencyQuery READ fiatApiAltCurrencyQuery)$3$3    // I2P settings$3    Q_PROPERTY(bool useI2P READ useI2P WRITE setUseI2P NOTIFY useI2PChanged)$3    Q_PROPERTY(bool useBuiltInI2P READ useBuiltInI2P WRITE setUseBuiltInI2P NOTIFY useBuiltInI2PChanged)$3    Q_PROPERTY(QString i2pAddress READ i2pAddress WRITE setI2PAddress NOTIFY i2pAddressChanged)$3    Q_PROPERTY(QString i2pPort READ i2pPort WRITE setI2PPort NOTIFY i2pPortChanged)$3    Q_PROPERTY(bool i2pMixedMode READ i2pMixedMode WRITE setI2PMixedMode NOTIFY i2pMixedModeChanged)$3    Q_PROPERTY(int i2pTunnelLength READ i2pTunnelLength WRITE setI2PTunnelLength NOTIFY i2pTunnelLengthChanged)$3'
    
    $moneroSettingsHContent = $moneroSettingsHContent -replace $pattern, $replacement
    
    # Add I2P member variables
    $pattern = 'private:(\r?\n)    QString m_portRange;'
    $replacement = 'private:$1    QString m_portRange;$1$1    // I2P settings$1    bool m_useI2P;$1    bool m_useBuiltInI2P;$1    QString m_i2pAddress;$1    QString m_i2pPort;$1    bool m_i2pMixedMode;$1    int m_i2pTunnelLength;$1'
    
    $moneroSettingsHContent = $moneroSettingsHContent -replace $pattern, $replacement
    
    # Add I2P signals
    $pattern = '    void hideBalanceChanged\(\) const;(\r?\n)    void askPasswordBeforeSendingChanged\(\) const;(\r?\n)    void shareTransactionHistoryFileChanged\(\) const;(\r?\n)'
    $replacement = '    void hideBalanceChanged() const;$1    void askPasswordBeforeSendingChanged() const;$2    void shareTransactionHistoryFileChanged() const;$3$3    // I2P signals$3    void useI2PChanged() const;$3    void useBuiltInI2PChanged() const;$3    void i2pAddressChanged() const;$3    void i2pPortChanged() const;$3    void i2pMixedModeChanged() const;$3    void i2pTunnelLengthChanged() const;$3'
    
    $moneroSettingsHContent = $moneroSettingsHContent -replace $pattern, $replacement
    
    # Add I2P methods
    $pattern = '    void setAskPasswordBeforeSending\(bool askPasswordBeforeSending\);(\r?\n)    bool askPasswordBeforeSending\(\) const;(\r?\n)    Q_INVOKABLE void setShareTransactionHistoryFile\(bool shareTransactionHistoryFile\);(\r?\n)};'
    $replacement = '    void setAskPasswordBeforeSending(bool askPasswordBeforeSending);$1    bool askPasswordBeforeSending() const;$2    Q_INVOKABLE void setShareTransactionHistoryFile(bool shareTransactionHistoryFile);$3$3    // I2P methods$3    bool useI2P() const {$3        return m_useI2P;$3    }$3    void setUseI2P(bool useI2P);$3    $3    bool useBuiltInI2P() const {$3        return m_useBuiltInI2P;$3    }$3    void setUseBuiltInI2P(bool useBuiltInI2P);$3    $3    QString i2pAddress() const {$3        return m_i2pAddress;$3    }$3    void setI2PAddress(const QString &i2pAddress);$3    $3    QString i2pPort() const {$3        return m_i2pPort;$3    }$3    void setI2PPort(const QString &i2pPort);$3    $3    bool i2pMixedMode() const {$3        return m_i2pMixedMode;$3    }$3    void setI2PMixedMode(bool i2pMixedMode);$3    $3    int i2pTunnelLength() const {$3        return m_i2pTunnelLength;$3    }$3    void setI2PTunnelLength(int i2pTunnelLength);$3};'
    
    $moneroSettingsHContent = $moneroSettingsHContent -replace $pattern, $replacement
    
    # Save changes
    Set-Content -Path $moneroSettingsH -Value $moneroSettingsHContent -NoNewline
    Write-Host "Successfully updated $moneroSettingsH" -ForegroundColor Green
}

# Apply MoneroSettings.cpp patch
$moneroSettingsCppContent = Get-Content $moneroSettingsCpp -Raw
if ($moneroSettingsCppContent -match "void MoneroSettings::setUseI2P\(bool useI2P\)") {
    Write-Host "I2P methods already exist in $moneroSettingsCpp - skipping" -ForegroundColor Green
} else {
    Write-Host "Applying patch to $moneroSettingsCpp..." -ForegroundColor Yellow
    
    # Update constructor to initialize I2P properties
    $pattern = 'MoneroSettings::MoneroSettings\(QObject \*parent\)(\r?\n)    : QObject\(parent\)(\r?\n)    , m_lockOnUserInactivityInterval\(1\)(\r?\n)    , m_hideBalance\(false\)(\r?\n)    , m_askPasswordBeforeSending\(true\)(\r?\n)\{ \}'
    $replacement = 'MoneroSettings::MoneroSettings(QObject *parent)$1    : QObject(parent)$2    , m_lockOnUserInactivityInterval(1)$3    , m_hideBalance(false)$4    , m_askPasswordBeforeSending(true)$5    , m_useI2P(false)$5    , m_useBuiltInI2P(true)$5    , m_i2pAddress("127.0.0.1")$5    , m_i2pPort("7656")$5    , m_i2pMixedMode(false)$5    , m_i2pTunnelLength(3)$5{ }'
    
    $moneroSettingsCppContent = $moneroSettingsCppContent -replace $pattern, $replacement
    
    # Add I2P method implementations
    $pattern = 'bool MoneroSettings::shareTransactionHistoryFile\(\) const(\r?\n)\{(\r?\n)    QSettings settings;(\r?\n)    return settings.value\("shareTransactionHistoryFile", false\).toBool\(\);(\r?\n)\}(\r?\n)'
    $replacement = 'bool MoneroSettings::shareTransactionHistoryFile() const$1{$2    QSettings settings;$3    return settings.value("shareTransactionHistoryFile", false).toBool();$4}$5$5// I2P methods$5void MoneroSettings::setUseI2P(bool useI2P)$5{$5    if (m_useI2P != useI2P) $5    {$5        m_useI2P = useI2P;$5        QSettings settings;$5        settings.setValue("useI2P", useI2P);$5        emit useI2PChanged();$5    }$5}$5$5void MoneroSettings::setUseBuiltInI2P(bool useBuiltInI2P)$5{$5    if (m_useBuiltInI2P != useBuiltInI2P) $5    {$5        m_useBuiltInI2P = useBuiltInI2P;$5        QSettings settings;$5        settings.setValue("useBuiltInI2P", useBuiltInI2P);$5        emit useBuiltInI2PChanged();$5    }$5}$5$5void MoneroSettings::setI2PAddress(const QString &i2pAddress)$5{$5    if (m_i2pAddress != i2pAddress) $5    {$5        m_i2pAddress = i2pAddress;$5        QSettings settings;$5        settings.setValue("i2pAddress", i2pAddress);$5        emit i2pAddressChanged();$5    }$5}$5$5void MoneroSettings::setI2PPort(const QString &i2pPort)$5{$5    if (m_i2pPort != i2pPort) $5    {$5        m_i2pPort = i2pPort;$5        QSettings settings;$5        settings.setValue("i2pPort", i2pPort);$5        emit i2pPortChanged();$5    }$5}$5$5void MoneroSettings::setI2PMixedMode(bool i2pMixedMode)$5{$5    if (m_i2pMixedMode != i2pMixedMode) $5    {$5        m_i2pMixedMode = i2pMixedMode;$5        QSettings settings;$5        settings.setValue("i2pMixedMode", i2pMixedMode);$5        emit i2pMixedModeChanged();$5    }$5}$5$5void MoneroSettings::setI2PTunnelLength(int i2pTunnelLength)$5{$5    if (m_i2pTunnelLength != i2pTunnelLength && i2pTunnelLength >= 1 && i2pTunnelLength <= 7) $5    {$5        m_i2pTunnelLength = i2pTunnelLength;$5        QSettings settings;$5        settings.setValue("i2pTunnelLength", i2pTunnelLength);$5        $5        // Update tunnel length in I2PDaemonManager$5        if (m_useBuiltInI2P && m_useI2P) {$5            I2PDaemonManager::instance().setTunnelLength(i2pTunnelLength);$5        }$5        $5        emit i2pTunnelLengthChanged();$5    }$5}$5'
    
    $moneroSettingsCppContent = $moneroSettingsCppContent -replace $pattern, $replacement
    
    # Save changes
    Set-Content -Path $moneroSettingsCpp -Value $moneroSettingsCppContent -NoNewline
    Write-Host "Successfully updated $moneroSettingsCpp" -ForegroundColor Green
}

# 5. Create I2P settings QML file
$i2pSettingsQmlDir = "pages/settings"
if (-not (Test-Path $i2pSettingsQmlDir)) {
    Write-Host "Creating directory: $i2pSettingsQmlDir" -ForegroundColor Yellow
    New-Item -Path $i2pSettingsQmlDir -ItemType Directory -Force | Out-Null
}

Write-Host "5. Creating I2P settings QML file..." -ForegroundColor Yellow
Copy-Item -Path "pages/settings/SettingsI2P.qml" -Destination "$i2pSettingsQmlDir/" -Force

# 6. Copy I2P icon
Write-Host "6. Copying I2P icon..." -ForegroundColor Yellow
Copy-Item -Path "images/i2p.svg" -Destination "images/" -Force

# 7. Apply patches to StatusBar and LeftPanel
Write-Host "7. Applying patches to StatusBar and LeftPanel..." -ForegroundColor Yellow
$statusBarPatch = Get-Content "components/StatusBar.qml.patch" -Raw
$leftPanelPatch = Get-Content "LeftPanel.qml.patch" -Raw
$mainQmlPatch = Get-Content "main.qml.patch" -Raw

# Apply StatusBar patch
$statusBarPath = "components/StatusBar.qml"
$statusBarContent = Get-Content $statusBarPath -Raw
if ($statusBarContent -match "i2pStatusIcon") {
    Write-Host "I2P status indicator already exists in $statusBarPath - skipping" -ForegroundColor Green
} else {
    Write-Host "Applying patch to $statusBarPath..." -ForegroundColor Yellow
    
    # Add I2P status indicator
    $pattern = '(Item \{(\r?\n)    id: statusBar(\r?\n).*?)(\r?\n.*?// network status)'
    $replacement = '$1$4$4    // I2P status indicator$4    Rectangle {$4        id: i2pStatusIcon$4        visible: appWindow.currentWallet ? appWindow.walletManager.isI2PEnabled(appWindow.currentWallet) : false$4        color: "transparent"$4        height: 24$4        width: 24$4        anchors.right: networkStatusIcon.left$4        anchors.rightMargin: 10$4        anchors.verticalCenter: parent.verticalCenter$4        $4        Image {$4            anchors.fill: parent$4            source: "../images/i2p.svg"$4            fillMode: Image.PreserveAspectFit$4        }$4        $4        MouseArea {$4            anchors.fill: parent$4            hoverEnabled: true$4            cursorShape: Qt.PointingHandCursor$4            onClicked: {$4                tooltip.text = qsTr("I2P routing active") + translationManager.emptyString$4                tooltip.tooltipPopup.open()$4            }$4        }$4    }'
    
    $statusBarContent = $statusBarContent -replace $pattern, $replacement
    
    # Save changes
    Set-Content -Path $statusBarPath -Value $statusBarContent -NoNewline
    Write-Host "Successfully updated $statusBarPath" -ForegroundColor Green
}

# Apply LeftPanel patch
$leftPanelPath = "LeftPanel.qml"
$leftPanelContent = Get-Content $leftPanelPath -Raw
if ($leftPanelContent -match "i2pButton") {
    Write-Host "I2P button already exists in $leftPanelPath - skipping" -ForegroundColor Green
} else {
    Write-Host "Applying patch to $leftPanelPath..." -ForegroundColor Yellow
    
    # Add I2P menu button
    $pattern = '(                MoneroComponents\.MenuButton \{(\r?\n)                    id: settingsButton.*?)(\r?\n.*?)(\r?\n                MoneroComponents\.MenuButton \{(\r?\n)                    id: keysButton)'
    $replacement = '$1$3$4$4                // I2P settings menu$4                MoneroComponents.MenuButton {$4                    id: i2pButton$4                    anchors.left: parent.left$4                    anchors.right: parent.right$4                    text: qsTr("I2P") + translationManager.emptyString$4                    symbol: qsTr("I2P") + translationManager.emptyString$4                    dotColor: "#FFD781"$4                    under: settingsButton$4                    onClicked: {$4                        rightPanel.showSubViewFromSource("settings/SettingsI2P.qml")$4                    }$4                }$4$5'
    
    $leftPanelContent = $leftPanelContent -replace $pattern, $replacement
    
    # Save changes
    Set-Content -Path $leftPanelPath -Value $leftPanelContent -NoNewline
    Write-Host "Successfully updated $leftPanelPath" -ForegroundColor Green
}

# Apply main.qml patch
$mainQmlPath = "main.qml"
$mainQmlContent = Get-Content $mainQmlPath -Raw
if ($mainQmlContent -match "initializeI2PSettings") {
    Write-Host "I2P initialization already exists in $mainQmlPath - skipping" -ForegroundColor Green
} else {
    Write-Host "Applying patch to $mainQmlPath..." -ForegroundColor Yellow
    
    # Add I2P initialization
    $pattern = '(ApplicationWindow \{.*?)(\r?\n.*?progressBar\.visible = false;)'
    $replacement = '$1$2$2$2    // Initialize I2P settings when the wallet is created or opened$2    function initializeI2PSettings() {$2        if (!currentWallet) {$2            return;$2        }$2        $2        // Apply I2P settings from persistent settings$2        if (persistentSettings.useI2P) {$2            // Construct I2P options$2            var options = "--tx-proxy i2p," + $2                     persistentSettings.i2pAddress + "," + $2                     persistentSettings.i2pPort;$2            $2            // Add mixed mode option if enabled$2            if (persistentSettings.i2pMixedMode) {$2                options += " --allow-mismatched-daemon-version";$2            }$2            $2            // Apply settings to wallet$2            walletManager.setI2POptions(currentWallet, options);$2            walletManager.setI2PEnabled(currentWallet, true);$2            $2            // Start I2P daemon if using built-in$2            if (persistentSettings.useBuiltInI2P) {$2                I2PDaemonManager.instance().start();$2            }$2        }$2    }'
    
    $mainQmlContent = $mainQmlContent -replace $pattern, $replacement
    
    # Add I2P shutdown
    $pattern = '(    function closeWallet\(\) \{.*?walletManager\.walletClosed\(\);(\r?\n)            return true;(\r?\n)        \})'
    $replacement = '$1$2            return true;$3        } $3$3        // Stop I2P daemon if it is running$3        if (persistentSettings.useI2P && persistentSettings.useBuiltInI2P) {$3            I2PDaemonManager.instance().stop();$3        }'
    
    $mainQmlContent = $mainQmlContent -replace $pattern, $replacement
    
    # Save changes
    Set-Content -Path $mainQmlPath -Value $mainQmlContent -NoNewline
    Write-Host "Successfully updated $mainQmlPath" -ForegroundColor Green
}

# 8. Update CMake configuration for I2P
Write-Host "8. Updating CMake configuration..." -ForegroundColor Yellow
$cmakeFilePath = "CMakeLists.txt"
$cmakeContent = Get-Content $cmakeFilePath -Raw

if (-not ($cmakeContent -match "I2PDaemonManager")) {
    # Add I2P source files to CMake
    $pattern = '(set\(WALLET_SOURCES.*?)(\r?\n\s+)(?:\$\{CMAKE_CURRENT_SOURCE_DIR\}\/.*?\.cpp)'
    $replacement = '$1$2${CMAKE_CURRENT_SOURCE_DIR}/src/i2p/i2pdaemonmanager.cpp'
    $cmakeContent = $cmakeContent -replace $pattern, $replacement
    
    $pattern = '(set\(WALLET_HEADERS.*?)(\r?\n\s+)(?:\$\{CMAKE_CURRENT_SOURCE_DIR\}\/.*?\.h)'
    $replacement = '$1$2${CMAKE_CURRENT_SOURCE_DIR}/src/i2p/i2pdaemonmanager.h'
    $cmakeContent = $cmakeContent -replace $pattern, $replacement
    
    # Add I2P QML files
    $pattern = '(set\(QML_SOURCES.*?)(\r?\n\s+)(?:\$\{CMAKE_CURRENT_SOURCE_DIR\}\/.*?\.qml)'
    $replacement = '$1$2${CMAKE_CURRENT_SOURCE_DIR}/pages/settings/SettingsI2P.qml'
    $cmakeContent = $cmakeContent -replace $pattern, $replacement
    
    # Add I2P images
    $pattern = '(set\(RESOURCES.*?)(\r?\n\s+)(?:\$\{CMAKE_CURRENT_SOURCE_DIR\}\/images\/.*?\.svg)'
    $replacement = '$1$2${CMAKE_CURRENT_SOURCE_DIR}/images/i2p.svg'
    $cmakeContent = $cmakeContent -replace $pattern, $replacement
    
    # Add I2P option to CMake
    $pattern = '(option\(USE_DEVICE_.*? "Enable Device.*?)(\r?\n)'
    $replacement = '$1$2option(WITH_I2P "Enable I2P support" ON)$2'
    $cmakeContent = $cmakeContent -replace $pattern, $replacement
    
    # Add I2P define
    $pattern = '(if\(USE_DEVICE_TREZOR\).*?)(\r?\n\s+add_definitions\(\-DUSE_DEVICE_TREZOR\))'
    $replacement = '$1$2$2$2if(WITH_I2P)$2    add_definitions(-DWITH_I2P)$2endif()'
    $cmakeContent = $cmakeContent -replace $pattern, $replacement
    
    # Save changes
    Set-Content -Path $cmakeFilePath -Value $cmakeContent -NoNewline
    Write-Host "Successfully updated $cmakeFilePath" -ForegroundColor Green
} else {
    Write-Host "I2P already configured in $cmakeFilePath - skipping" -ForegroundColor Green
}

Write-Host "I2P integration build script completed!" -ForegroundColor Green
Write-Host "To enable I2P support, build with: -DWITH_I2P=ON" 