function initializeI2PSettings() {
    if (!currentWallet) {
        console.log("No wallet to initialize I2P settings");
        return;
    }

    console.log("Initializing I2P settings");
    
    // Apply I2P settings if enabled
    if (persistentSettings.useI2P) {
        // Construct I2P options
        var options = "--tx-proxy i2p," + persistentSettings.i2pAddress + "," + persistentSettings.i2pPort;
        
        // Add mixed mode option if enabled
        if (persistentSettings.i2pMixedMode) {
            options += " --allow-mismatched-daemon-version";
        }
        
        // Set options and enable I2P
        walletManager.setI2POptions(currentWallet, options);
        walletManager.setI2PEnabled(currentWallet, true);
        
        // Start I2P daemon if using built-in
        if (persistentSettings.useBuiltInI2P) {
            I2PDaemonManager.instance().start();
        }
    } else {
        walletManager.setI2PEnabled(currentWallet, false);
    }
}

function closeWallet() {
    if (currentWallet) {
        // Stop I2P daemon if using built-in
        if (persistentSettings.useBuiltInI2P) {
            I2PDaemonManager.instance().stop();
        }

        // Close wallet
        walletManager.closeWallet(currentWallet);
        currentWallet = null;
    }
}

onCurrentWalletChanged: {
    initializeWallet();
    initializeI2PSettings();
}

// Initialize wallet
currentWallet = walletManager.openWallet(walletPath, appWindow.walletPassword,
                                          persistentSettings.testnet)

// Initialize I2P settings
currentWallet.setI2PEnabled(appWindow.persistentSettings.useI2P)
if (appWindow.persistentSettings.useI2P) {
    currentWallet.setI2POptions(appWindow.persistentSettings.i2pOptions)
}

// Closing wallet
function closeWallet(walletSave) {
    // Stop I2P daemon if enabled
    if (persistentSettings.useI2P) {
        i2pDaemonManager.stop()
    }
    // ... existing wallet closing code ...
} 