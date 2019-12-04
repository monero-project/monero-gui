// Copyright (c) 2014-2019, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.9
import QtQuick.Window 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Dialogs 1.2

import moneroComponents.Wallet 1.0
import moneroComponents.PendingTransaction 1.0
import moneroComponents.NetworkType 1.0
import moneroComponents.Settings 1.0

import "components"
import "components" as MoneroComponents
import "components/effects" as MoneroEffects
import "pages/merchant" as MoneroMerchant
import "wizard"
import "js/Utils.js" as Utils
import "js/Windows.js" as Windows

ApplicationWindow {
    id: appWindow
    title: "Monero" + (walletName ? " - " + walletName : "")

    property var currentItem
    property bool hideBalanceForced: false
    property bool ctrlPressed: false
    property alias persistentSettings : persistentSettings
    property var currentWallet;
    property var transaction;
    property var transactionDescription;
    property var walletPassword
    property bool isNewWallet: false
    property int restoreHeight:0
    property bool daemonSynced: false
    property bool walletSynced: false
    property int maxWindowHeight: (isAndroid || isIOS)? screenHeight : (screenHeight < 900)? 720 : 800;
    property bool daemonRunning: false
    property alias toolTip: toolTip
    property string walletName
    property bool viewOnly: false
    property bool foundNewBlock: false
    property bool qrScannerEnabled: (typeof builtWithScanner != "undefined") && builtWithScanner
    property int blocksToSync: 1
    property bool isMining: false
    property int walletMode: persistentSettings.walletMode
    property var cameraUi
    property bool androidCloseTapped: false;
    property int userLastActive;  // epoch
    // Default daemon addresses
    readonly property string localDaemonAddress : "localhost:" + getDefaultDaemonRpcPort(persistentSettings.nettype)
    property string currentDaemonAddress;
    property int disconnectedEpoch: 0
    property int estimatedBlockchainSize: 75 // GB
    property alias viewState: rootItem.state
    property string prevSplashText;
    property bool splashDisplayedBeforeButtonRequest;
    property int appEpoch: Math.floor((new Date).getTime() / 1000)
    property bool themeTransition: false

    // fiat price conversion
    property real fiatPriceXMRUSD: 0
    property real fiatPriceXMREUR: 0
    property var fiatPriceAPIs: {
        return {
            "kraken": {
                "xmrusd": "https://api.kraken.com/0/public/Ticker?pair=XMRUSD",
                "xmreur": "https://api.kraken.com/0/public/Ticker?pair=XMREUR"
            },
            "coingecko": {
                "xmrusd": "https://api.coingecko.com/api/v3/simple/price?ids=monero&vs_currencies=usd",
                "xmreur": "https://api.coingecko.com/api/v3/simple/price?ids=monero&vs_currencies=eur"
            },
            "cryptocompare": {
                "xmrusd": "https://min-api.cryptocompare.com/data/price?fsym=XMR&tsyms=USD",
                "xmreur": "https://min-api.cryptocompare.com/data/price?fsym=XMR&tsyms=EUR",
            }
        }
    }

    // true if wallet ever synchronized
    property bool walletInitialized : false

    // Current selected address / subaddress / (Receive/Account page)
    property var current_address
    property var current_address_label: "Primary"
    property int current_subaddress_table_index: 0

    function altKeyReleased() { ctrlPressed = false; }

    function showPageRequest(page) {
        middlePanel.state = page
        leftPanel.selectItem(page)
    }

    function sequencePressed(obj, seq) {
        if(seq === undefined || !leftPanel.enabled)
            return
        if(seq === "Ctrl") {
            ctrlPressed = true
            return
        }

        if(seq === "Ctrl+S") middlePanel.state = "Transfer"
        else if(seq === "Ctrl+R") middlePanel.state = "Receive"
        else if(seq === "Ctrl+K") middlePanel.state = "TxKey"
        else if(seq === "Ctrl+H") middlePanel.state = "History"
        else if(seq === "Ctrl+B") middlePanel.state = "AddressBook"
        else if(seq === "Ctrl+M") middlePanel.state = "Mining"
        else if(seq === "Ctrl+I") middlePanel.state = "Sign"
        else if(seq === "Ctrl+G") middlePanel.state = "SharedRingDB"
        else if(seq === "Ctrl+E") middlePanel.state = "Settings"
        else if(seq === "Ctrl+D") middlePanel.state = "Advanced"
        else if(seq === "Ctrl+T") middlePanel.state = "Account"
        else if(seq === "Ctrl+Tab" || seq === "Alt+Tab") {
            /*
            if(middlePanel.state === "Transfer") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "SharedRingDB"
            else if(middlePanel.state === "SharedRingDB") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "Settings"
            */
            if(middlePanel.state === "Settings") middlePanel.state = "Account"
            else if(middlePanel.state === "Account") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "SharedRingDB"
            else if(middlePanel.state === "SharedRingDB") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "Settings"
        } else if(seq === "Ctrl+Shift+Backtab" || seq === "Alt+Shift+Backtab") {
            /*
            if(middlePanel.state === "Settings") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "SharedRingDB"
            else if(middlePanel.state === "SharedRingDB") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "Transfer"
            */
            if(middlePanel.state === "Settings") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "SharedRingDB"
            else if(middlePanel.state === "SharedRingDB") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Account"
            else if(middlePanel.state === "Account") middlePanel.state = "Settings"
        }

        if (middlePanel.state !== "Advanced") updateBalance();

        leftPanel.selectItem(middlePanel.state)
    }

    function sequenceReleased(obj, seq) {
        if(seq === "Ctrl")
            ctrlPressed = false
    }

    function mousePressed(obj, mouseX, mouseY) {}
    function mouseReleased(obj, mouseX, mouseY) {}

    function loadPage(page) {
        middlePanel.state = page;
        leftPanel.selectItem(page);
    }

    function initialize() {
        appWindow.viewState = "normal";
        console.log("initializing..")

        // Use stored log level
        if (persistentSettings.logLevel == 5)
          walletManager.setLogCategories(persistentSettings.logCategories)
        else
          walletManager.setLogLevel(persistentSettings.logLevel)

        // setup language
        var locale = persistentSettings.locale
        if (locale !== "") {
            translationManager.setLanguage(locale.split("_")[0]);
        }

        // Reload transfer page with translations enabled
        middlePanel.transferView.onPageCompleted();

        // If currentWallet exists, we're just switching daemon - close/reopen wallet
        if (typeof currentWallet !== "undefined" && currentWallet !== null) {
            console.log("Daemon change - closing " + currentWallet)
            closeWallet();
        } else if (!walletInitialized) {
            // set page to transfer if not changing daemon
            middlePanel.state = "Transfer";
            leftPanel.selectItem(middlePanel.state)
        }

        // Local daemon settings
        walletManager.setDaemonAddressAsync(localDaemonAddress);

        // enable timers
        userInActivityTimer.running = true;
        simpleModeConnectionTimer.running = true;

        // wallet already opened with wizard, we just need to initialize it
        if (typeof wizard.m_wallet !== 'undefined') {
            console.log("using wizard wallet")
            //Set restoreHeight
            if(persistentSettings.restore_height > 0){
                // We store restore height in own variable for performance reasons.
                restoreHeight = persistentSettings.restore_height
            }

            connectWallet(wizard.m_wallet)

            isNewWallet = true
            // We don't need the wizard wallet any more - delete to avoid conflict with daemon adress change
            delete wizard.m_wallet
        }  else {
            var wallet_path = walletPath();
            if(isIOS)
                wallet_path = moneroAccountsDir + wallet_path;
            // console.log("opening wallet at: ", wallet_path, "with password: ", appWindow.walletPassword);
            console.log("opening wallet at: ", wallet_path, ", network type: ", persistentSettings.nettype == NetworkType.MAINNET ? "mainnet" : persistentSettings.nettype == NetworkType.TESTNET ? "testnet" : "stagenet");

            this.onWalletOpening();
            walletManager.openWalletAsync(wallet_path, walletPassword,
                                              persistentSettings.nettype, persistentSettings.kdfRounds);
        }

        // Hide titlebar based on persistentSettings.customDecorations
        titleBar.visible = persistentSettings.customDecorations;
    }

    function closeWallet(callback) {

        // Disconnect all listeners
        if (typeof currentWallet === "undefined" || currentWallet === null) {
            if (callback) {
                callback();
            }
            return;
        }

        currentWallet.heightRefreshed.disconnect(onHeightRefreshed);
        currentWallet.refreshed.disconnect(onWalletRefresh)
        currentWallet.updated.disconnect(onWalletUpdate)
        currentWallet.newBlock.disconnect(onWalletNewBlock)
        currentWallet.moneySpent.disconnect(onWalletMoneySent)
        currentWallet.moneyReceived.disconnect(onWalletMoneyReceived)
        currentWallet.unconfirmedMoneyReceived.disconnect(onWalletUnconfirmedMoneyReceived)
        currentWallet.transactionCreated.disconnect(onTransactionCreated)
        currentWallet.connectionStatusChanged.disconnect(onWalletConnectionStatusChanged)
        currentWallet.deviceButtonRequest.disconnect(onDeviceButtonRequest);
        currentWallet.deviceButtonPressed.disconnect(onDeviceButtonPressed);
        currentWallet.transactionCommitted.disconnect(onTransactionCommitted);
        middlePanel.paymentClicked.disconnect(handlePayment);
        middlePanel.sweepUnmixableClicked.disconnect(handleSweepUnmixable);
        middlePanel.getProofClicked.disconnect(handleGetProof);
        middlePanel.checkProofClicked.disconnect(handleCheckProof);

        appWindow.walletName = "";
        currentWallet = undefined;

        appWindow.showProcessingSplash(qsTr("Closing wallet..."));
        if (callback) {
            walletManager.closeWalletAsync(function() {
                hideProcessingSplash();
                callback();
            });
        } else {
            walletManager.closeWallet();
            hideProcessingSplash();
        }
    }

    function connectWallet(wallet) {
        currentWallet = wallet

        // TODO:
        // When the wallet variable is undefined, it yields a zero balance.
        // This can scare users, restart the GUI (as a quick fix).
        //
        // To reproduce, follow these steps:
        // 1) Open the GUI, load up a wallet that has a balance
        // 2) Settings -> close wallet
        // 3) Create a new wallet
        // 4) Settings -> close wallet
        // 5) Open the wallet from step 1

        if(!wallet || wallet === undefined || wallet.path === undefined){
            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
            informationPopup.text = qsTr("Couldn't open wallet: ") + 'please restart GUI.';
            informationPopup.icon = StandardIcon.Critical
            informationPopup.open()
            informationPopup.onCloseCallback = function() {
                appWindow.close();
            }
        }

        walletName = usefulName(wallet.path)

        viewOnly = currentWallet.viewOnly;

        // New wallets saves the testnet flag in keys file.
        if(persistentSettings.nettype != currentWallet.nettype) {
            console.log("Using network type from keys file")
            persistentSettings.nettype = currentWallet.nettype;
        }

        // connect handlers
        currentWallet.heightRefreshed.connect(onHeightRefreshed);
        currentWallet.refreshed.connect(onWalletRefresh)
        currentWallet.updated.connect(onWalletUpdate)
        currentWallet.newBlock.connect(onWalletNewBlock)
        currentWallet.moneySpent.connect(onWalletMoneySent)
        currentWallet.moneyReceived.connect(onWalletMoneyReceived)
        currentWallet.unconfirmedMoneyReceived.connect(onWalletUnconfirmedMoneyReceived)
        currentWallet.transactionCreated.connect(onTransactionCreated)
        currentWallet.connectionStatusChanged.connect(onWalletConnectionStatusChanged)
        currentWallet.deviceButtonRequest.connect(onDeviceButtonRequest);
        currentWallet.deviceButtonPressed.connect(onDeviceButtonPressed);
        currentWallet.transactionCommitted.connect(onTransactionCommitted);
        middlePanel.paymentClicked.connect(handlePayment);
        middlePanel.sweepUnmixableClicked.connect(handleSweepUnmixable);
        middlePanel.getProofClicked.connect(handleGetProof);
        middlePanel.checkProofClicked.connect(handleCheckProof);


        console.log("Recovering from seed: ", persistentSettings.is_recovering)
        console.log("restore Height", persistentSettings.restore_height)

        // Use saved daemon rpc login settings
        currentWallet.setDaemonLogin(persistentSettings.daemonUsername, persistentSettings.daemonPassword)

        if(persistentSettings.useRemoteNode)
            currentDaemonAddress = persistentSettings.remoteNodeAddress
        else
            currentDaemonAddress = localDaemonAddress

        console.log("initializing with daemon address: ", currentDaemonAddress)
        currentWallet.initAsync(
            currentDaemonAddress,
            isTrustedDaemon(),
            0,
            persistentSettings.is_recovering,
            persistentSettings.is_recovering_from_device,
            persistentSettings.restore_height);
        // save wallet keys in case wallet settings have been changed in the init
        currentWallet.setPassword(walletPassword);
    }

    function isTrustedDaemon() {
        return !persistentSettings.useRemoteNode || persistentSettings.is_trusted_daemon;
    }

    function walletPath() {
        var wallet_path = persistentSettings.wallet_path
        return wallet_path;
    }

    function usefulName(path) {
        // arbitrary "short enough" limit
        if (path.length < 32)
            return path
        return path.replace(/.*[\/\\]/, '').replace(/\.keys$/, '')
    }

    function updateBalance() {
        if (!currentWallet)
            return;

        var balance = "?.??";
        var balanceU = "?.??";
        if(!hideBalanceForced && !persistentSettings.hideBalance){
            balance = walletManager.displayAmount(currentWallet.balance(currentWallet.currentSubaddressAccount));
            balanceU = walletManager.displayAmount(currentWallet.unlockedBalance(currentWallet.currentSubaddressAccount));
        }

        if (persistentSettings.fiatPriceEnabled) {
            appWindow.fiatApiUpdateBalance(balance);
        }

        leftPanel.minutesToUnlock = (balance !== balanceU) ? currentWallet.history.minutesToUnlock : "";
        leftPanel.balanceString = balance
        leftPanel.balanceUnlockedString = balanceU
    }

    function onUriHandler(uri){
        if(uri.startsWith("monero://")){
            var address = uri.substring("monero://".length);

            var params = {}
            if(address.length === 0) return;
            var spl = address.split("?");

            if(spl.length > 2) return;
            if(spl.length >= 1) {
                // parse additional params
                address = spl[0];

                if(spl.length === 2){
                    spl.shift();
                    var item = spl[0];

                    var _spl = item.split("&");
                    for (var param in _spl){
                        var _item = _spl[param];
                        if(!_item.indexOf("=") > 0) continue;

                        var __spl = _item.split("=");
                        if(__spl.length !== 2) continue;

                        params[__spl[0]] = __spl[1];
                    }
                }
            }

            // Fill fields
            middlePanel.transferView.sendTo(address, params["tx_payment_id"], params["tx_description"], params["tx_amount"]);

            // Raise window
            appWindow.raise();
            appWindow.show();
        }
    }

    function onWalletConnectionStatusChanged(status){
        console.log("Wallet connection status changed " + status)
        middlePanel.updateStatus();
        leftPanel.networkStatus.connected = status

        // update local daemon status.
        const isDisconnected = status === Wallet.ConnectionStatus_Disconnected;
        if (walletManager.isDaemonLocal(currentDaemonAddress)) {
            daemonRunning = !isDisconnected;
        } else {
            daemonRunning = false;
        }

        // Update fee multiplier dropdown on transfer page
        middlePanel.transferView.updatePriorityDropdown();

        // If wallet isnt connected, advanced wallet mode and no daemon is running - Ask
        if (appWindow.walletMode >= 2 && walletManager.isDaemonLocal(currentDaemonAddress) && !walletInitialized && isDisconnected) {
            daemonManager.runningAsync(persistentSettings.nettype, function(running) {
                if (!running) {
                    daemonManagerDialog.open();
                }
            });
        }
        // initialize transaction history once wallet is initialized first time;
        if (!walletInitialized) {
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
            walletInitialized = true

            // check if daemon was already mining and add mining logo if true
            middlePanel.miningView.update();
        }
    }

    function onDeviceButtonRequest(code){
        prevSplashText = splash.messageText;
        splashDisplayedBeforeButtonRequest = splash.visible;
        appWindow.showProcessingSplash(qsTr("Please proceed to the device..."));
    }

    function onDeviceButtonPressed(){
        if (splashDisplayedBeforeButtonRequest){
           appWindow.showProcessingSplash(prevSplashText);
        } else {
           hideProcessingSplash();
        }
    }

    function onWalletOpening(){
        appWindow.showProcessingSplash(qsTr("Opening wallet ..."));
    }

    function onWalletOpened(wallet) {
        hideProcessingSplash();
        walletName = usefulName(wallet.path)
        console.log(">>> wallet opened: " + wallet)
        if (wallet.status !== Wallet.Status_Ok) {
            passwordDialog.onAcceptedCallback = function() {
                walletPassword = passwordDialog.password;
                appWindow.initialize();
            }
            passwordDialog.onRejectedCallback = function() {
                walletPassword = "";
                //appWindow.enableUI(false)
                wizard.wizardState = "wizardHome";
                rootItem.state = "wizard";
            }
            // try to resolve common wallet cache errors automatically
            switch (wallet.errorString) {
                case "basic_string::_M_replace_aux":
                    walletManager.clearWalletCache(wallet.path);
                    walletPassword = passwordDialog.password;
                    appWindow.initialize();
                    console.error("Repairing wallet cache with error: ", wallet.errorString);
                    appWindow.showStatusMessage(qsTr("Repairing incompatible wallet cache. Resyncing wallet."),6);
                    return;
                case "std::bad_alloc":
                    walletManager.clearWalletCache(wallet.path);
                    walletPassword = passwordDialog.password;
                    appWindow.initialize();
                    console.error("Repairing wallet cache with error: ", wallet.errorString);
                    appWindow.showStatusMessage(qsTr("Repairing incompatible wallet cache. Resyncing wallet."),6);
                    return;
                default:
                    // opening with password but password doesn't match
                    console.error("Error opening wallet with password: ", wallet.errorString);
                    passwordDialog.showError(qsTr("Couldn't open wallet: ") + wallet.errorString);
                    console.log("closing wallet async : " + wallet.address)
                    closeWallet();
                    return;
            }
        }

        // wallet opened successfully, subscribing for wallet updates
        connectWallet(wallet)

        // Force switch normal view
        rootItem.state = "normal";

        // Process queued IPC command
        if(typeof IPC !== "undefined" && IPC.queuedCmd().length > 0){
            var queuedCmd = IPC.queuedCmd();
            if(/^\w+:\/\/(.*)$/.test(queuedCmd)) appWindow.onUriHandler(queuedCmd); // uri
        }
    }

    function onWalletPassphraseNeeded(){
        if(rootItem.state !== "normal") return;

        hideProcessingSplash();

        console.log(">>> wallet passphrase needed: ")
        passwordDialog.onAcceptedPassphraseCallback = function() {
            walletManager.onPassphraseEntered(passwordDialog.password);
            this.onWalletOpening();
        }
        passwordDialog.onRejectedPassphraseCallback = function() {
            walletManager.onPassphraseEntered("", true);
            this.onWalletOpening();
        }
        passwordDialog.openPassphraseDialog()
    }

    function onWalletUpdate() {
        console.log(">>> wallet updated")
        updateBalance();
        // Update history if new block found since last update
        if(foundNewBlock) {
            foundNewBlock = false;
            console.log("New block found - updating history")
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)

            if(middlePanel.state == "History")
                middlePanel.historyView.update();
        }
    }

    function connectRemoteNode() {
        console.log("connecting remote node");

        const callback = function() {
            persistentSettings.useRemoteNode = true;
            currentDaemonAddress = persistentSettings.remoteNodeAddress;
            currentWallet.initAsync(currentDaemonAddress, isTrustedDaemon());
            walletManager.setDaemonAddressAsync(currentDaemonAddress);
        };

        if (typeof daemonManager != "undefined" && daemonRunning) {
            showDaemonIsRunningDialog(callback);
        } else {
            callback();
        }
    }

    function disconnectRemoteNode() {
        if (typeof currentWallet === "undefined" || currentWallet === null)
            return;

        console.log("disconnecting remote node");
        persistentSettings.useRemoteNode = false;
        currentDaemonAddress = localDaemonAddress
        currentWallet.initAsync(currentDaemonAddress, isTrustedDaemon());
        walletManager.setDaemonAddressAsync(currentDaemonAddress);
    }

    function onHeightRefreshed(bcHeight, dCurrentBlock, dTargetBlock) {
        // Daemon fully synced
        // TODO: implement onDaemonSynced or similar in wallet API and don't start refresh thread before daemon is synced
        // targetBlock = currentBlock = 1 before network connection is established.
        daemonSynced = dCurrentBlock >= dTargetBlock && dTargetBlock != 1
        walletSynced = bcHeight >= dTargetBlock

        // Update progress bars
        if(!daemonSynced) {
            leftPanel.daemonProgressBar.updateProgress(dCurrentBlock,dTargetBlock, dTargetBlock-dCurrentBlock);
            leftPanel.progressBar.updateProgress(0,dTargetBlock, dTargetBlock, qsTr("Waiting for daemon to sync"));
        } else {
            leftPanel.daemonProgressBar.updateProgress(dCurrentBlock,dTargetBlock, 0, qsTr("Daemon is synchronized (%1)").arg(dCurrentBlock.toFixed(0)));
            if(walletSynced)
                leftPanel.progressBar.updateProgress(bcHeight,dTargetBlock,dTargetBlock-bcHeight, qsTr("Wallet is synchronized"))
        }

        // Update wallet sync progress
        leftPanel.isSyncing = (currentWallet.connected() !== Wallet.ConnectionStatus_Disconnected) && !daemonSynced
        // Update transfer page status
        middlePanel.updateStatus();

        // Refresh is succesfull if blockchain height > 1
        if (bcHeight > 1){
            // Save new wallet after first refresh
            // Wallet is nomrmally saved to disk on app exit. This prevents rescan from block 0 after app crash
            if(isNewWallet){
                console.log("Saving wallet after first refresh");
                currentWallet.store()
                isNewWallet = false

                // Update History
                currentWallet.history.refresh(currentWallet.currentSubaddressAccount);
            }

            // recovering from seed is finished after first refresh
            if(persistentSettings.is_recovering) {
                persistentSettings.is_recovering = false
            }
            if (persistentSettings.is_recovering_from_device) {
                persistentSettings.is_recovering_from_device = false;
            }
        }

        // Update history on every refresh if it's empty
        if(currentWallet.history.count == 0)
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)

        onWalletUpdate();
    }

    function onWalletRefresh() {
        console.log(">>> wallet refreshed")

        // Daemon connected
        leftPanel.networkStatus.connected = currentWallet.connected()

        currentWallet.refreshHeightAsync();
    }

    function startDaemon(flags){
        // Pause refresh while starting daemon
        currentWallet.pauseRefresh();

        // Pause simplemode connection timer
        simpleModeConnectionTimer.stop();

        appWindow.showProcessingSplash(qsTr("Waiting for daemon to start..."))
        const noSync = appWindow.walletMode === 0;
        daemonManager.start(flags, persistentSettings.nettype, persistentSettings.blockchainDataDir, persistentSettings.bootstrapNodeAddress, noSync);
    }

    function stopDaemon(){
        appWindow.showProcessingSplash(qsTr("Waiting for daemon to stop..."))
        daemonManager.stop(persistentSettings.nettype);
    }

    function onDaemonStarted(){
        console.log("daemon started");
        daemonRunning = true;
        hideProcessingSplash();
        currentWallet.connected(true);
        // resume refresh
        currentWallet.startRefresh();
        // resume simplemode connection timer
        appWindow.disconnectedEpoch = Utils.epoch();
        simpleModeConnectionTimer.start();
    }
    function onDaemonStopped(){
        console.log("daemon stopped");
        hideProcessingSplash();
        daemonRunning = false;
        currentWallet.connected(true);
    }

    function onDaemonStartFailure(){
        console.log("daemon start failed");
        hideProcessingSplash();
        // resume refresh
        currentWallet.startRefresh();
        daemonRunning = false;
        informationPopup.title = qsTr("Daemon failed to start") + translationManager.emptyString;
        informationPopup.text  = qsTr("Please check your wallet and daemon log for errors. You can also try to start %1 manually.").arg((isWindows)? "monerod.exe" : "monerod")
        informationPopup.icon  = StandardIcon.Critical
        informationPopup.onCloseCallback = null
        informationPopup.open();
    }

    function onWalletNewBlock(blockHeight, targetHeight) {
        // Update progress bar
        var remaining = targetHeight - blockHeight;
        if(blocksToSync < remaining) {
            blocksToSync = remaining;
        }

        leftPanel.progressBar.updateProgress(blockHeight,targetHeight, blocksToSync);

        // If wallet is syncing, daemon is already synced
        leftPanel.daemonProgressBar.updateProgress(1,1,0,qsTr("Daemon is synchronized"));

        foundNewBlock = true;
    }

    function onWalletMoneyReceived(txId, amount) {
        // refresh transaction history here
        console.log("Confirmed money found")
        // history refresh is handled by walletUpdated
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount) // this will refresh model
        currentWallet.subaddress.refresh(currentWallet.currentSubaddressAccount)

        if(middlePanel.state == "History")
            middlePanel.historyView.update();
    }

    function onWalletUnconfirmedMoneyReceived(txId, amount) {
        // refresh history
        console.log("unconfirmed money found")
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount);

        if(middlePanel.state == "History")
            middlePanel.historyView.update();
    }

    function onWalletMoneySent(txId, amount) {
        // refresh transaction history here
        console.log("monero sent found")
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount); // this will refresh model

        if(middlePanel.state == "History")
            middlePanel.historyView.update();
    }

    function walletsFound() {
        if (persistentSettings.wallet_path.length > 0) {
            if(isIOS)
                return walletManager.walletExists(moneroAccountsDir + persistentSettings.wallet_path);
            else
                return walletManager.walletExists(persistentSettings.wallet_path);
        }
        return false;
    }

    function onTransactionCreated(pendingTransaction,address,paymentId,mixinCount){
        console.log("Transaction created");
        hideProcessingSplash();
        transaction = pendingTransaction;
        // validate address;
        if (transaction.status !== PendingTransaction.Status_Ok) {
            console.error("Can't create transaction: ", transaction.errorString);
            informationPopup.title = qsTr("Error") + translationManager.emptyString;
            if (currentWallet.connected() == Wallet.ConnectionStatus_WrongVersion)
                informationPopup.text  = qsTr("Can't create transaction: Wrong daemon version: ") + transaction.errorString
            else
                informationPopup.text  = qsTr("Can't create transaction: ") + transaction.errorString
            informationPopup.icon  = StandardIcon.Critical
            informationPopup.onCloseCallback = null
            informationPopup.open();
            // deleting transaction object, we don't want memleaks
            currentWallet.disposeTransaction(transaction);

        } else if (transaction.txCount == 0) {
            informationPopup.title = qsTr("Error") + translationManager.emptyString
            informationPopup.text  = qsTr("No unmixable outputs to sweep") + translationManager.emptyString
            informationPopup.icon = StandardIcon.Information
            informationPopup.onCloseCallback = null
            informationPopup.open()
            // deleting transaction object, we don't want memleaks
            currentWallet.disposeTransaction(transaction);
        } else {
            console.log("Transaction created, amount: " + walletManager.displayAmount(transaction.amount)
                    + ", fee: " + walletManager.displayAmount(transaction.fee));

            // here we show confirmation popup;
            transactionConfirmationPopup.title = qsTr("Please confirm transaction:\n") + translationManager.emptyString;
            transactionConfirmationPopup.text = "";
            transactionConfirmationPopup.text += (address === "" ? "" : (qsTr("Address: ") + address));
            transactionConfirmationPopup.text += (paymentId === "" ? "" : (qsTr("\nPayment ID: ") + paymentId));
            transactionConfirmationPopup.text +=  qsTr("\n\nAmount: ") + walletManager.displayAmount(transaction.amount);
            transactionConfirmationPopup.text +=  qsTr("\nFee: ") + walletManager.displayAmount(transaction.fee);
            transactionConfirmationPopup.text +=  qsTr("\nRingsize: ") + (mixinCount + 1);
            transactionConfirmationPopup.text +=  qsTr("\n\nNumber of transactions: ") + transaction.txCount
            transactionConfirmationPopup.text +=  (transactionDescription === "" ? "" : (qsTr("\nDescription: ") + transactionDescription))
            for (var i = 0; i < transaction.subaddrIndices.length; ++i){
                transactionConfirmationPopup.text += qsTr("\nSpending address index: ") + transaction.subaddrIndices[i];
            }

            transactionConfirmationPopup.text += translationManager.emptyString;
            transactionConfirmationPopup.icon = StandardIcon.Question
            transactionConfirmationPopup.open()
        }
    }


    // called on "transfer"
    function handlePayment(address, paymentId, amount, mixinCount, priority, description, createFile) {
        console.log("Creating transaction: ")
        console.log("\taddress: ", address,
                    ", payment_id: ", paymentId,
                    ", amount: ", amount,
                    ", mixins: ", mixinCount,
                    ", priority: ", priority,
                    ", description: ", description);

        var splashMsg = qsTr("Creating transaction...");
        splashMsg += appWindow.currentWallet.isLedger() ? qsTr("\n\nPlease check your hardware wallet –\nyour input may be required.") : "";
        showProcessingSplash(splashMsg);

        transactionDescription = description;

        // validate amount;
        if (amount !== "(all)") {
            var amountxmr = walletManager.amountFromString(amount);
            console.log("integer amount: ", amountxmr);
            console.log("integer unlocked",currentWallet.unlockedBalance)
            if (amountxmr <= 0) {
                hideProcessingSplash()
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                informationPopup.text  = qsTr("Amount is wrong: expected number from %1 to %2")
                        .arg(walletManager.displayAmount(0))
                        .arg(walletManager.maximumAllowedAmountAsSting())
                        + translationManager.emptyString

                informationPopup.icon  = StandardIcon.Critical
                informationPopup.onCloseCallback = null
                informationPopup.open()
                return;
            } else if (amountxmr > currentWallet.unlockedBalance) {
                hideProcessingSplash()
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                informationPopup.text  = qsTr("Insufficient funds. Unlocked balance: %1")
                        .arg(walletManager.displayAmount(currentWallet.unlockedBalance))
                        + translationManager.emptyString

                informationPopup.icon  = StandardIcon.Critical
                informationPopup.onCloseCallback = null
                informationPopup.open()
                return;
            }
        }

        if (amount === "(all)")
            currentWallet.createTransactionAllAsync(address, paymentId, mixinCount, priority);
        else
            currentWallet.createTransactionAsync(address, paymentId, amountxmr, mixinCount, priority);
    }

    //Choose where to save transaction
    FileDialog {
        id: saveTxDialog
        title: "Please choose a location"
        folder: "file://" +moneroAccountsDir
        selectExisting: false;

        onAccepted: {
            handleTransactionConfirmed()
        }
        onRejected: {
            // do nothing

        }

    }


    function handleSweepUnmixable() {
        console.log("Creating transaction: ")

        transaction = currentWallet.createSweepUnmixableTransaction();
        if (transaction.status !== PendingTransaction.Status_Ok) {
            console.error("Can't create transaction: ", transaction.errorString);
            informationPopup.title = qsTr("Error") + translationManager.emptyString;
            informationPopup.text  = qsTr("Can't create transaction: ") + transaction.errorString
            informationPopup.icon  = StandardIcon.Critical
            informationPopup.onCloseCallback = null
            informationPopup.open();
            // deleting transaction object, we don't want memleaks
            currentWallet.disposeTransaction(transaction);

        } else if (transaction.txCount == 0) {
            informationPopup.title = qsTr("Error") + translationManager.emptyString
            informationPopup.text  = qsTr("No unmixable outputs to sweep") + translationManager.emptyString
            informationPopup.icon = StandardIcon.Information
            informationPopup.onCloseCallback = null
            informationPopup.open()
            // deleting transaction object, we don't want memleaks
            currentWallet.disposeTransaction(transaction);
        } else {
            console.log("Transaction created, amount: " + walletManager.displayAmount(transaction.amount)
                    + ", fee: " + walletManager.displayAmount(transaction.fee));

            // here we show confirmation popup;

            transactionConfirmationPopup.title = qsTr("Confirmation") + translationManager.emptyString
            transactionConfirmationPopup.text  = qsTr("Please confirm transaction:\n")
                        + qsTr("\n\nAmount: ") + walletManager.displayAmount(transaction.amount)
                        + qsTr("\nFee: ") + walletManager.displayAmount(transaction.fee)
                        + translationManager.emptyString
            transactionConfirmationPopup.icon = StandardIcon.Question
            transactionConfirmationPopup.open()
            // committing transaction
        }
    }

    // called after user confirms transaction
    function handleTransactionConfirmed(fileName) {
        // View only wallet - we save the tx
        if(viewOnly && saveTxDialog.fileUrl){
            // No file specified - abort
            if(!saveTxDialog.fileUrl) {
                currentWallet.disposeTransaction(transaction)
                return;
            }

            var path = walletManager.urlToLocalPath(saveTxDialog.fileUrl)

            // Store to file
            transaction.setFilename(path);
        }

        appWindow.showProcessingSplash(qsTr("Sending transaction ..."));
        currentWallet.commitTransactionAsync(transaction);
    }

    function onTransactionCommitted(success, transaction, txid) {
        hideProcessingSplash();
        if (!success) {
            console.log("Error committing transaction: " + transaction.errorString);
            informationPopup.title = qsTr("Error") + translationManager.emptyString
            informationPopup.text  = qsTr("Couldn't send the money: ") + transaction.errorString
            informationPopup.icon  = StandardIcon.Critical
        } else {
            var txid_text = ""
            informationPopup.title = qsTr("Information") + translationManager.emptyString
            for (var i = 0; i < txid.length; ++i) {
                if (txid_text.length > 0)
                    txid_text += ", "
                txid_text += txid[i]
            }
            informationPopup.text  = (viewOnly)? qsTr("Transaction saved to file: %1").arg(path) : qsTr("Monero sent successfully: %1 transaction(s) ").arg(txid.length) + txid_text + translationManager.emptyString
            informationPopup.icon  = StandardIcon.Information
            if (transactionDescription.length > 0) {
                for (var i = 0; i < txid.length; ++i)
                  currentWallet.setUserNote(txid[i], transactionDescription);
            }

            // Clear tx fields
            middlePanel.transferView.clearFields()

        }
        informationPopup.onCloseCallback = null
        informationPopup.open()
        currentWallet.refresh()
        currentWallet.disposeTransaction(transaction)
        currentWallet.store();
    }

    // called on "getProof"
    function handleGetProof(txid, address, message) {
        console.log("Getting payment proof: ")
        console.log("\ttxid: ", txid,
                    ", address: ", address,
                    ", message: ", message);

        function spendProofFallback(txid, result){
            if (!result || result.indexOf("error|") === 0) {
                currentWallet.getSpendProofAsync(txid, message, txProofComputed);
            } else {
                txProofComputed(txid, result);
            }
        }

        if (address.length > 0)
            currentWallet.getTxProofAsync(txid, address, message, spendProofFallback);
        else
            spendProofFallback(txid, null);
    }

    function txProofComputed(txid, result){
        informationPopup.title  = qsTr("Payment proof") + translationManager.emptyString;
        if (result.indexOf("error|") === 0) {
            var errorString = result.split("|")[1];
            informationPopup.text = qsTr("Couldn't generate a proof because of the following reason: \n") + errorString + translationManager.emptyString;
            informationPopup.icon = StandardIcon.Critical;
        } else {
            informationPopup.text  = result;
            informationPopup.icon = StandardIcon.Critical;
        }
        informationPopup.onCloseCallback = null
        informationPopup.open()
    }

    // called on "checkProof"
    function handleCheckProof(txid, address, message, signature) {
        console.log("Checking payment proof: ")
        console.log("\ttxid: ", txid,
                    ", address: ", address,
                    ", message: ", message,
                    ", signature: ", signature);

        var result;
        if (address.length > 0)
            result = currentWallet.checkTxProof(txid, address, message, signature);
        else
            result = currentWallet.checkSpendProof(txid, message, signature);
        var results = result.split("|");
        if (address.length > 0 && results.length == 5 && results[0] === "true") {
            var good = results[1] === "true";
            var received = results[2];
            var in_pool = results[3] === "true";
            var confirmations = results[4];

            informationPopup.title  = qsTr("Payment proof check") + translationManager.emptyString;
            informationPopup.icon = StandardIcon.Information
            if (!good) {
                informationPopup.text = qsTr("Bad signature");
                informationPopup.icon = StandardIcon.Critical;
            } else if (received > 0) {
                if (in_pool) {
                    informationPopup.text = qsTr("This address received %1 monero, but the transaction is not yet mined").arg(walletManager.displayAmount(received));
                }
                else {
                    informationPopup.text = qsTr("This address received %1 monero, with %2 confirmation(s).").arg(walletManager.displayAmount(received)).arg(confirmations);
                }
            }
            else {
                informationPopup.text = qsTr("This address received nothing");
            }
        }
        else if (results.length == 2 && results[0] === "true") {
            var good = results[1] === "true";
            informationPopup.title = qsTr("Payment proof check") + translationManager.emptyString;
            informationPopup.icon = good ? StandardIcon.Information : StandardIcon.Critical;
            informationPopup.text = good ? qsTr("Good signature") : qsTr("Bad signature");
        }
        else {
            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
            informationPopup.text = currentWallet.errorString;
            informationPopup.icon = StandardIcon.Critical
        }
        informationPopup.onCloseCallback = null
        informationPopup.open()
    }

    // blocks UI if wallet can't be opened or no connection to the daemon
    function enableUI(enable) {
        middlePanel.enabled = enable;
        leftPanel.enabled = enable;
    }

    function showProcessingSplash(message) {
        console.log("Displaying processing splash")
        if (typeof message != 'undefined') {
            splash.messageText = message
            splash.heightProgressText = ""
        }

        leftPanel.enabled = false;
        middlePanel.enabled = false;
        titleBar.enabled = false;
        inactiveOverlay.visible = true;
        splash.show();
    }

    function hideProcessingSplash() {
        console.log("Hiding processing splash")
        splash.close();

        if (!passwordDialog.visible) {
            leftPanel.enabled = true
            middlePanel.enabled = true
            titleBar.enabled = true
            inactiveOverlay.visible = false;
        }
    }

    // close wallet and show wizard
    function showWizard(){
        walletInitialized = false;
        closeWallet(function() {
            wizard.restart();
            wizard.wizardState = "wizardHome";
            rootItem.state = "wizard"
            // reset balance
            clearMoneroCardLabelText();
            // disable timers
            userInActivityTimer.running = false;
            simpleModeConnectionTimer.running = false;
        });
    }


    objectName: "appWindow"
    visible: true
    width: screenWidth > 980 ? 980 : 800
    height: screenHeight > maxWindowHeight ? maxWindowHeight : 700
    color: MoneroComponents.Style.appWindowBackgroundColor
    flags: persistentSettings.customDecorations ? Windows.flagsCustomDecorations : Windows.flags
    onWidthChanged: x -= 0

    Timer {
        id: fiatPriceTimer
        interval: 1000 * 60;
        running: persistentSettings.fiatPriceEnabled;
        repeat: true
        onTriggered: {
            if(persistentSettings.fiatPriceEnabled)
                appWindow.fiatApiRefresh();
        }
        triggeredOnStart: false
    }

    function fiatApiParseTicker(resp, currency){
        // parse & validate incoming JSON
        if(resp._url.startsWith("https://api.kraken.com/0/")){
            if(resp.hasOwnProperty("error") && resp.error.length > 0 || !resp.hasOwnProperty("result")){
                appWindow.fiatApiError("Kraken API has error(s)");
                return;
            }

            var key = currency === "xmreur" ? "XXMRZEUR" : "XXMRZUSD";
            var ticker = resp.result[key]["o"];
            return ticker;
        } else if(resp._url.startsWith("https://api.coingecko.com/api/v3/")){
            var key = currency === "xmreur" ? "eur" : "usd";
            if(!resp.hasOwnProperty("monero") || !resp["monero"].hasOwnProperty(key)){
                appWindow.fiatApiError("Coingecko API has error(s)");
                return;
            }
            return resp["monero"][key];
        } else if(resp._url.startsWith("https://min-api.cryptocompare.com/data/")){
            var key = currency === "xmreur" ? "EUR" : "USD";
            if(!resp.hasOwnProperty(key)){
                appWindow.fiatApiError("cryptocompare API has error(s)");
                return;
            }
            return resp[key];
        }
    }

    function fiatApiGetCurrency(resp){
        // map response to `appWindow.fiatPriceAPIs` object
        if (!resp.hasOwnProperty('_url')){
            appWindow.fiatApiError("invalid JSON");
            return;
        }

        var apis = appWindow.fiatPriceAPIs;
        for (var api in apis){
            if (!apis.hasOwnProperty(api))
               continue;

            for (var cur in apis[api]){
                if(!apis[api].hasOwnProperty(cur))
                    continue;

                var url = apis[api][cur];
                if(url === resp._url){
                    return cur;
                }
            }
        }
    }

    function fiatApiJsonReceived(resp){
        // handle incoming JSON, set ticker
        var currency = appWindow.fiatApiGetCurrency(resp);
        if(typeof currency == "undefined"){
            appWindow.fiatApiError("could not get currency");
            return;
        }

        var ticker = appWindow.fiatApiParseTicker(resp, currency);
        if(ticker <= 0){
            appWindow.fiatApiError("could not get ticker");
            return;
        }

        if(persistentSettings.fiatPriceCurrency === "xmrusd")
            appWindow.fiatPriceXMRUSD = ticker;
        else if(persistentSettings.fiatPriceCurrency === "xmreur")
            appWindow.fiatPriceXMREUR = ticker;

        appWindow.updateBalance();
    }

    function fiatApiRefresh(){
        // trigger API call
        if(!persistentSettings.fiatPriceEnabled)
            return;

        var userProvider = persistentSettings.fiatPriceProvider;
        if(!appWindow.fiatPriceAPIs.hasOwnProperty(userProvider)){
            appWindow.fiatApiError("provider \"" + userProvider + "\" not implemented");
            return;
        }

        var provider = appWindow.fiatPriceAPIs[userProvider];
        var userCurrency = persistentSettings.fiatPriceCurrency;
        if(!provider.hasOwnProperty(userCurrency)){
            appWindow.fiatApiError("currency \"" + userCurrency + "\" not implemented");
        }

        var url = provider[userCurrency];
        Prices.getJSON(url);
    }

    function fiatApiCurrencySymbol() {
        switch (persistentSettings.fiatPriceCurrency) {
            case "xmrusd":
                return "USD";
            case "xmreur":
                return "EUR";
            default:
                console.error("unsupported currency", persistentSettings.fiatPriceCurrency);
                return "UNSUPPORTED";
        }
    }

    function fiatApiConvertToFiat(amount) {
        var ticker = persistentSettings.fiatPriceCurrency === "xmrusd" ? appWindow.fiatPriceXMRUSD : appWindow.fiatPriceXMREUR;
        if(ticker <= 0){
            console.log(fiatApiError("Invalid ticker value: " + ticker));
            return "?.??";
        }
        return (amount * ticker).toFixed(2);
    }

    function fiatApiUpdateBalance(balance){
        // update balance card
        var bFiat = "?.??"
        if (!hideBalanceForced && !persistentSettings.hideBalance) {
            bFiat = fiatApiConvertToFiat(balance);
        }
        leftPanel.balanceFiatString = bFiat;
    }

    function fiatTimerStart(){
        fiatPriceTimer.start();
    }

    function fiatTimerStop(){
        fiatPriceTimer.stop();
    }

    function fiatApiError(msg){
        console.log("fiatPriceError: " + msg);
    }

    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - maxWindowHeight) / 2

        applyWalletMode(persistentSettings.walletMode);

        //
        walletManager.walletOpened.connect(onWalletOpened);
        walletManager.deviceButtonRequest.connect(onDeviceButtonRequest);
        walletManager.deviceButtonPressed.connect(onDeviceButtonPressed);
        walletManager.checkUpdatesComplete.connect(onWalletCheckUpdatesComplete);
        walletManager.walletPassphraseNeeded.connect(onWalletPassphraseNeeded);
        IPC.uriHandler.connect(onUriHandler);
        Prices.priceJsonReceived.connect(appWindow.fiatApiJsonReceived);

        if(typeof daemonManager != "undefined") {
            daemonManager.daemonStarted.connect(onDaemonStarted);
            daemonManager.daemonStartFailure.connect(onDaemonStartFailure);
            daemonManager.daemonStopped.connect(onDaemonStopped);
        }

        // Connect app exit to qml window exit handling
        mainApp.closing.connect(appWindow.close);

        if( appWindow.qrScannerEnabled ){
            console.log("qrScannerEnabled : load component QRCodeScanner");
            var component = Qt.createComponent("components/QRCodeScanner.qml");
            if (component.status == Component.Ready) {
                console.log("Camera component ready");
                cameraUi = component.createObject(appWindow);
            } else {
                console.log("component not READY !!!");
                appWindow.qrScannerEnabled = false;
            }
        } else console.log("qrScannerEnabled disabled");

        if(!walletsFound()) {
            rootItem.state = "wizard"
        } else {
            rootItem.state = "normal"
            passwordDialog.onAcceptedCallback = function() {
                walletPassword = passwordDialog.password;
                initialize(persistentSettings);
            }
            passwordDialog.onRejectedCallback = function() {
                wizard.wizardState = "wizardHome";
                rootItem.state = "wizard"
            }
            passwordDialog.open(usefulName(walletPath()))
        }

        checkUpdates();

        if(persistentSettings.fiatPriceEnabled){
            appWindow.fiatApiRefresh();
            appWindow.fiatTimerStart();
        }
    }

    MoneroSettings {
        id: persistentSettings
        fileName: {
            if(isTails && tailsUsePersistence)
                return homePath + "/Persistent/Monero/monero-core.conf";
            return "";
        }

        property string language
        property string locale
        property string account_name
        property string wallet_path
        property bool   auto_donations_enabled : false
        property int    auto_donations_amount : 50
        property bool   allow_background_mining : false
        property bool   miningIgnoreBattery : true
        property var    nettype: NetworkType.MAINNET
        property string payment_id
        property int    restore_height : 0
        property bool   is_trusted_daemon : false
        property bool   is_recovering : false
        property bool   is_recovering_from_device : false
        property bool   customDecorations : true
        property string daemonFlags
        property int logLevel: 0
        property string logCategories: ""
        property string daemonUsername: ""
        property string daemonPassword: ""
        property bool transferShowAdvanced: false
        property bool receiveShowAdvanced: false
        property bool historyShowAdvanced: false
        property bool historyHumanDates: true
        property string blockchainDataDir: ""
        property bool useRemoteNode: false
        property string remoteNodeAddress: ""
        property string bootstrapNodeAddress: ""
        property bool segregatePreForkOutputs: true
        property bool keyReuseMitigation2: true
        property int segregationHeight: 0
        property int kdfRounds: 1
        property bool hideBalance: false
        property bool lockOnUserInActivity: true
        property int walletMode: 2
        property int lockOnUserInActivityInterval: 10  // minutes
        property bool blackTheme: true

        property bool fiatPriceEnabled: false
        property bool fiatPriceToggle: false
        property string fiatPriceProvider: "kraken"
        property string fiatPriceCurrency: "xmrusd"

        Component.onCompleted: {
            MoneroComponents.Style.blackTheme = persistentSettings.blackTheme
        }
    }

    // Information dialog
    StandardDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: informationPopup
        anchors.fill: parent
        z: parent.z + 1
        cancelVisible: false
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    // Confrirmation aka question dialog
    StandardDialog {
        z: parent.z + 1
        id: transactionConfirmationPopup
        onAccepted: {
            close();
            passwordDialog.onAcceptedCallback = function() {
                if(walletPassword === passwordDialog.password){
                    // Save transaction to file if view only wallet
                    if(viewOnly) {
                        saveTxDialog.open();
                    } else {
                        handleTransactionConfirmed()
                    }
                } else {
                    passwordDialog.showError(qsTr("Wrong password") + translationManager.emptyString);
                }
            }
            passwordDialog.onRejectedCallback = null;
            passwordDialog.open()
        }
    }

    StandardDialog {
        z: parent.z + 1
        id: confirmationDialog
        anchors.fill: parent
        property var onAcceptedCallback
        property var onRejectedCallback
        onAccepted:  {
            if (onAcceptedCallback)
                onAcceptedCallback()
        }
        onRejected: {
            if (onRejectedCallback)
                onRejectedCallback();
        }
    }

    // Choose blockchain folder
    FileDialog {
        id: blockchainFileDialog
        property string directory: ""
        signal changed();

        title: "Please choose a folder"
        selectFolder: true
        folder: "file://" + persistentSettings.blockchainDataDir

        onRejected: console.log("data dir selection canceled")
        onAccepted: {
            var dataDir = walletManager.urlToLocalPath(blockchainFileDialog.fileUrl)
            var validator = daemonManager.validateDataDir(dataDir);
            if(validator.valid) {
                persistentSettings.blockchainDataDir = dataDir;
            } else {
                confirmationDialog.title = qsTr("Warning") + translationManager.emptyString;
                confirmationDialog.text = "";
                if(validator.readOnly)
                    confirmationDialog.text  += qsTr("Error: Filesystem is read only") + "\n\n"
                if(validator.storageAvailable < estimatedBlockchainSize)
                    confirmationDialog.text  += qsTr("Warning: There's only %1 GB available on the device. Blockchain requires ~%2 GB of data.").arg(validator.storageAvailable).arg(estimatedBlockchainSize) + "\n\n"
                else
                    confirmationDialog.text  += qsTr("Note: There's %1 GB available on the device. Blockchain requires ~%2 GB of data.").arg(validator.storageAvailable).arg(estimatedBlockchainSize) + "\n\n"
                if(!validator.lmdbExists)
                    confirmationDialog.text  += qsTr("Note: lmdb folder not found. A new folder will be created.") + "\n\n"

                confirmationDialog.icon = StandardIcon.Question
                confirmationDialog.cancelText = qsTr("Cancel")

                // Continue
                confirmationDialog.onAcceptedCallback = function() {
                    persistentSettings.blockchainDataDir = dataDir
                }

                // Cancel
                confirmationDialog.onRejectedCallback = function() { };
                confirmationDialog.open()
            }

            blockchainFileDialog.directory = blockchainFileDialog.fileUrl;
            delete validator;
        }
    }

    PasswordDialog {
        id: passwordDialog
        visible: false
        z: parent.z + 1
        anchors.fill: parent
        property var onAcceptedCallback
        property var onRejectedCallback
        property var onAcceptedPassphraseCallback
        property var onRejectedPassphraseCallback
        onAccepted: {
            if (onAcceptedCallback)
                onAcceptedCallback();
        }
        onRejected: {
            if (onRejectedCallback)
                onRejectedCallback();
        }
        onAcceptedNewPassword: {
            if (currentWallet.setPassword(passwordDialog.password)) {
                appWindow.walletPassword = passwordDialog.password;
                informationPopup.title = qsTr("Information") + translationManager.emptyString;
                informationPopup.text  = qsTr("Password changed successfully") + translationManager.emptyString;
                informationPopup.icon  = StandardIcon.Information;
            } else {
                informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                informationPopup.text  = qsTr("Error: ") + currentWallet.errorString;
                informationPopup.icon  = StandardIcon.Critical;
            }
            informationPopup.onCloseCallback = null;
            informationPopup.open();
        }
        onRejectedNewPassword: {}
        onAcceptedPassphrase: {
            if (onAcceptedPassphraseCallback)
                onAcceptedPassphraseCallback();
        }
        onRejectedPassphrase: {
            if (onRejectedPassphraseCallback)
                onRejectedPassphraseCallback();
        }
    }

    InputDialog {
        id: inputDialog
        visible: false
        z: parent.z + 1
        anchors.fill: parent
        property var onAcceptedCallback
        property var onRejectedCallback
        onAccepted:  {
            if (onAcceptedCallback)
                onAcceptedCallback()
        }
        onRejected:  {
            if (onRejectedCallback)
                onRejectedCallback()
        }
    }

    DaemonManagerDialog {
        id: daemonManagerDialog
        onRejected: {
            middlePanel.settingsView.settingsStateViewState = "Node";
            loadPage("Settings");
        }

    }

    ProcessingSplash {
        id: splash
        width: appWindow.width / 1.5
        height: appWindow.height / 2
        x: (appWindow.width - width) / 2
        y: (appWindow.height - height) / 2
        messageText: qsTr("Please wait...") + translationManager.emptyString
    }

    Item {
        id: rootItem
        anchors.fill: parent
        clip: true

        state: "wizard"
        states: [
            State {
                name: "wizard"
                PropertyChanges { target: middlePanel; visible: false }
                PropertyChanges { target: wizard; visible: true }
                PropertyChanges { target: resizeArea; visible: true }
                PropertyChanges { target: titleBar; state: "essentials" }
            }, State {
                name: "normal"
                PropertyChanges { target: middlePanel; visible: true }
                PropertyChanges { target: wizard; visible: false }
                PropertyChanges { target: resizeArea; visible: true }
                PropertyChanges { target: titleBar; state: "default" }
            }
        ]

        LeftPanel {
            id: leftPanel
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            visible: rootItem.state == "normal" && middlePanel.state != "Merchant"
            currentAccountIndex: currentWallet ? currentWallet.currentSubaddressAccount : 0
            currentAccountLabel: {
                if (currentWallet) {
                    return currentWallet.getSubaddressLabel(currentWallet.currentSubaddressAccount, 0);
                }
                return qsTr("Primary account") + translationManager.emptyString;
            }

            onTransferClicked: {
                middlePanel.state = "Transfer";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }

            onReceiveClicked: {
                middlePanel.state = "Receive";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }

            onMerchantClicked: {
                middlePanel.state = "Merchant";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }

            onTxkeyClicked: {
                middlePanel.state = "TxKey";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }

            onSharedringdbClicked: {
                middlePanel.state = "SharedRingDB";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }

            onHistoryClicked: {
                middlePanel.state = "History";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }

            onAddressBookClicked: {
                middlePanel.state = "AddressBook";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }

            onMiningClicked: {
                middlePanel.state = "Mining";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }

            onSignClicked: {
                middlePanel.state = "Sign";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }

            onSettingsClicked: {
                middlePanel.state = "Settings";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }
            
            onAccountClicked: {
                middlePanel.state = "Account";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }
        }


        MiddlePanel {
            id: middlePanel
            accountView.currentAccountIndex: currentWallet ? currentWallet.currentSubaddressAccount : 0
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: leftPanel.visible ?  leftPanel.right : parent.left
            anchors.right: parent.right
            state: "Transfer"
        }

        WizardController {
            id: wizard
            anchors.fill: parent
            onUseMoneroClicked: {
                rootItem.state = "normal";
                appWindow.initialize();
            }
        }

        WizardLang {
            id: languageView
            visible: false
            anchors.fill: parent
        }

        property int minWidth: 326
        property int minHeight: 400
        MouseArea {
            id: resizeArea
            enabled: persistentSettings.customDecorations
            hoverEnabled: true
            cursorShape: persistentSettings.customDecorations ? Qt.PointingHandCursor : Qt.ArrowCursor
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 34
            width: 34

            MoneroEffects.ImageMask {
                anchors.centerIn: parent
                visible: persistentSettings.customDecorations
                image: "qrc:///images/resize.png"
                color: MoneroComponents.Style.defaultFontColor
                width: 12
                height: 12
                opacity: (parent.containsMouse || parent.pressed) ? 0.5 : 1.0
            }

            property var previousPosition

            onPressed: {
                previousPosition = globalCursor.getPosition()
            }

            onPositionChanged: {
                if(!pressed) return
                var pos = globalCursor.getPosition()
                //var delta = previousPosition - pos
                var dx = previousPosition.x - pos.x
                var dy = previousPosition.y - pos.y

                if(appWindow.width - dx > parent.minWidth)
                    appWindow.width -= dx
                else appWindow.width = parent.minWidth

                if(appWindow.height - dy > parent.minHeight)
                    appWindow.height -= dy
                else appWindow.height = parent.minHeight
                previousPosition = pos
            }
        }

        TitleBar {
            id: titleBar
            visible: persistentSettings.customDecorations && middlePanel.state !== "Merchant"
            walletName: appWindow.walletName
            anchors.left: parent.left
            anchors.right: parent.right
            onCloseClicked: appWindow.close();
            onLanguageClicked: appWindow.toggleLanguageView();
            onCloseWalletClicked: appWindow.showWizard();
            onMaximizeClicked: appWindow.visibility = appWindow.visibility !== Window.Maximized ? Window.Maximized : Window.Windowed
            onMinimizeClicked: appWindow.visibility = Window.Minimized
        }

        MoneroMerchant.MerchantTitlebar {
            id: titleBarOrange
            visible: persistentSettings.customDecorations && middlePanel.state === "Merchant"
            anchors.left: parent.left
            anchors.right: parent.right
            onCloseClicked: appWindow.close();
            onMaximizeClicked: appWindow.visibility = appWindow.visibility !== Window.Maximized ? Window.Maximized : Window.Windowed
            onMinimizeClicked: appWindow.visibility = Window.Minimized
        }

        // new ToolTip
        Rectangle {
            id: toolTip
            property alias text: content.text
            width: content.width + 12
            height: content.height + 17
            color: "#FF6C3C"
            //radius: 3
            visible:false;

            Image {
                id: tip
                anchors.top: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 5
                source: "qrc:///images/tip.png"
            }

            MoneroComponents.TextPlain {
                id: content
                anchors.horizontalCenter: parent.horizontalCenter
                y: 6
                lineHeight: 0.7
                font.family: "Arial"
                font.pixelSize: 12
                color: "#FFFFFF"
            }
        }

        Notifier {
            visible:false
            id: notifier
        }
    }

    function toggleLanguageView(){
        middlePanel.visible = !middlePanel.visible;
        languageView.visible = !languageView.visible
        resetLanguageFields()
        // update after changing language from settings page
        if (persistentSettings.language != wizard.language_language) {
            persistentSettings.language = wizard.language_language
            persistentSettings.locale   = wizard.language_locale
        }
    }

    // TODO: Make the callback dynamic
    Timer {
        id: statusMessageTimer
        interval: 5;
        running: false;
        repeat: false
        onTriggered: resetAndroidClose()
        triggeredOnStart: false
    }

    Timer {
        id: userInActivityTimer
        interval: 2000; running: false; repeat: true
        onTriggered: checkInUserActivity()
    }

    Timer {
        // enables theme transition animations after 500ms
        id: appThemeTransition
        running: true
        repeat: false
        interval: 500
        onTriggered: appWindow.themeTransition = true;
    }

    function checkNoSyncFlag() {
        if (!appWindow.daemonRunning) {
            return true;
        }
        if (appWindow.walletMode == 0 && !daemonManager.noSync()) {
            return false;
        }
        if (appWindow.walletMode == 1 && daemonManager.noSync()) {
            return false;
        }
        return true;
    }

    function checkSimpleModeConnection(){
        // auto-connection mechanism for simple mode
        if(appWindow.walletMode >= 2) return;

        const disconnectedTimeoutSec = 30;
        const firstCheckDelaySec = 2;

        const connected = leftPanel.networkStatus.connected !== Wallet.ConnectionStatus_Disconnected;
        const firstRun = appWindow.disconnectedEpoch == 0;
        if (firstRun) {
            appWindow.disconnectedEpoch = Utils.epoch() + firstCheckDelaySec - disconnectedTimeoutSec;
        } else if (connected) {
            appWindow.disconnectedEpoch = Utils.epoch();
        }

        const sinceLastConnect = Utils.epoch() - appWindow.disconnectedEpoch;
        if (sinceLastConnect < disconnectedTimeoutSec && checkNoSyncFlag()) {
            return;
        }

        if (appWindow.daemonRunning) {
            appWindow.stopDaemon();
        }
        appWindow.startDaemon("");
    }

    Timer {
        // Simple mode connection check timer
        id: simpleModeConnectionTimer
        interval: 2000; running: false; repeat: true
        onTriggered: appWindow.checkSimpleModeConnection()
    }

    Rectangle {
        id: statusMessage
        z: 99
        visible: false
        property alias text: statusMessageText.text
        anchors.bottom: parent.bottom
        width: statusMessageText.contentWidth + 20
        anchors.horizontalCenter: parent.horizontalCenter
        color: MoneroComponents.Style.blackTheme ? "black" : "white"
        height: 40
        MoneroComponents.TextPlain {
            id: statusMessageText
            anchors.fill: parent
            anchors.margins: 10
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
            themeTransition: false
        }
    }

    function resetAndroidClose() {
        console.log("resetting android close");
        androidCloseTapped = false;
        statusMessage.visible = false
    }

    function showStatusMessage(msg,timeout) {
        console.log("showing status message")
        statusMessageTimer.interval = timeout * 1000;
        statusMessageTimer.start()
        statusMessageText.text = msg;
        statusMessage.visible = true
    }

    function showDaemonIsRunningDialog(onClose) {
        // Show confirmation dialog
        confirmationDialog.title = qsTr("Local node is running") + translationManager.emptyString;
        confirmationDialog.text  = qsTr("Do you want to stop local node or keep it running in the background?") + translationManager.emptyString;
        confirmationDialog.icon = StandardIcon.Question;
        confirmationDialog.cancelText = qsTr("Force stop") + translationManager.emptyString;
        confirmationDialog.okText = qsTr("Keep it running") + translationManager.emptyString;
        confirmationDialog.onAcceptedCallback = function() {
            onClose();
        }
        confirmationDialog.onRejectedCallback = function() {
            daemonManager.stop(persistentSettings.nettype);
            onClose();
        };
        confirmationDialog.open();
    }

    onClosing: {
        close.accepted = false;
        console.log("blocking close event");
        if(isAndroid) {
            console.log("blocking android exit");
            if(qrScannerEnabled)
                cameraUi.state = "Stopped"

            if(!androidCloseTapped) {
                androidCloseTapped = true;
                appWindow.showStatusMessage(qsTr("Tap again to close..."),3)

                // first close
                return;
            }


        }

        // If daemon is running - prompt user before exiting
        if(typeof daemonManager != "undefined" && daemonRunning) {
            if (appWindow.walletMode == 0) {
                stopDaemon();
                closeAccepted();
            } else {
                showDaemonIsRunningDialog(closeAccepted);
            }
        } else {
            closeAccepted();
        }
    }

    function closeAccepted(){
        console.log("close accepted");
        // Close wallet non async on exit
        daemonManager.exit();
        
        closeWallet(Qt.quit);
    }

    function onWalletCheckUpdatesComplete(update) {
        if (update === "")
            return
        print("Update found: " + update)
        var parts = update.split("|")
        if (parts.length == 4) {
            var version = parts[0]
            var hash = parts[1]
            var user_url = parts[2]
            var msg = ""
            if (isMac || isWindows || isLinux) {
                msg = qsTr("New version of Monero v%1 is available.<br><br>Download:<br>%2<br><br>SHA256 Hash:<br>%3").arg(version).arg(user_url).arg(hash) + translationManager.emptyString
            } else {
                msg = qsTr("New version of Monero v%1 is available. Check out getmonero.org").arg(version) + translationManager.emptyString
            }
            notifier.show(msg)
        } else {
            print("Failed to parse update spec")
        }
    }

    function checkUpdates() {
        walletManager.checkUpdatesAsync("monero-gui", "gui")
    }

    Timer {
        id: updatesTimer
        interval: 3600*1000; running: true; repeat: true
        onTriggered: checkUpdates()
    }

    function releaseFocus() {
        // Workaround to release focus from textfield when scrolling (https://bugreports.qt.io/browse/QTBUG-34867)
        if(isAndroid) {
            console.log("releasing focus")
            middlePanel.focus = true
            middlePanel.focus = false
        }
    }

    // reset label text. othewise potential privacy leak showing unlock time when switching wallets
    function clearMoneroCardLabelText(){
        leftPanel.balanceString = "?.??"
        leftPanel.balanceFiatString = "?.??"
    }

    // some fields need an extra nudge when changing languages
    function resetLanguageFields(){
        clearMoneroCardLabelText()
        if (currentWallet) {
            onWalletRefresh();
        }
    }

    function userActivity() {
        // register user activity
        var epoch = Math.floor((new Date).getTime()/1000);
        appWindow.userLastActive = epoch;
    }

    function checkInUserActivity() {
        if(rootItem.state !== "normal") return;
        if(!persistentSettings.lockOnUserInActivity) return;
        if(passwordDialog.visible) return;

        // prompt password after X seconds of inactivity
        var epoch = Math.floor((new Date).getTime() / 1000);
        var inactivity = epoch - appWindow.userLastActive;
        if(inactivity < (persistentSettings.lockOnUserInActivityInterval * 60)) return;

        passwordDialog.onAcceptedCallback = function() {
            if(walletPassword === passwordDialog.password){
                passwordDialog.close();
            } else {
                passwordDialog.showError(qsTr("Wrong password"));
            }
        }

        passwordDialog.onRejectedCallback = function() { appWindow.showWizard(); }
        passwordDialog.open();
    }

    function getDefaultDaemonRpcPort(networkType) {
        switch (networkType) {
            case NetworkType.STAGENET:
                return 38081;
            case NetworkType.TESTNET:
                return 28081;
            default:
                return 18081;
        }
    }

    function changeWalletMode(mode){
        appWindow.disconnectedEpoch = 0;
        appWindow.walletMode = mode;
        persistentSettings.walletMode = mode;
        applyWalletMode(mode);
    }

    function applyWalletMode(mode){
        if (mode < 2) {
            persistentSettings.useRemoteNode = false;
            persistentSettings.bootstrapNodeAddress = "auto";

            if (middlePanel.settingsView.settingsStateViewState === "Node" || middlePanel.settingsView.settingsStateViewState === "Log") {
                middlePanel.settingsView.settingsStateViewState = "Wallet"
            }
        }
        console.log("walletMode: " + (mode === 0 ? "simple": mode === 1 ? "simple (bootstrap)" : "Advanced"));
    }

    // Daemon console
    DaemonConsole {
        id: daemonConsolePopup
        height:500
        width:800
        title: qsTr("Daemon log") + translationManager.emptyString
        onAccepted: {
            close();
        }
    }

    Rectangle {
        id: inactiveOverlay
        visible: false
        anchors.fill: parent
        anchors.topMargin: titleBar.height
        color: MoneroComponents.Style.blackTheme ? "black" : "white"
        opacity: MoneroComponents.Style.blackTheme ? 0.8 : 0.9

        MoneroEffects.ColorTransition {
            targetObj: parent
            blackColor: "black"
            whiteColor: "white"
        }
    }

    // borders on white theme + linux
    Rectangle {
        visible: isLinux && !MoneroComponents.Style.blackTheme && middlePanel.state !== "Merchant"
        z: parent.z + 1
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: MoneroComponents.Style.appWindowBorderColor

        MoneroEffects.ColorTransition {
            targetObj: parent
            blackColor: MoneroComponents.Style._b_appWindowBorderColor
            whiteColor: MoneroComponents.Style._w_appWindowBorderColor
        }
    }

    Rectangle {
        visible: isLinux && !MoneroComponents.Style.blackTheme && middlePanel.state !== "Merchant"
        z: parent.z + 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: MoneroComponents.Style.appWindowBorderColor

        MoneroEffects.ColorTransition {
            targetObj: parent
            blackColor: MoneroComponents.Style._b_appWindowBorderColor
            whiteColor: MoneroComponents.Style._w_appWindowBorderColor
        }
    }

    Rectangle {
        visible: isLinux && !MoneroComponents.Style.blackTheme && middlePanel.state !== "Merchant"
        z: parent.z + 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.left: parent.left
        height: 1
        color: MoneroComponents.Style.appWindowBorderColor

        MoneroEffects.ColorTransition {
            targetObj: parent
            blackColor: MoneroComponents.Style._b_appWindowBorderColor
            whiteColor: MoneroComponents.Style._w_appWindowBorderColor
        }
    }

    Rectangle {
        visible: isLinux && !MoneroComponents.Style.blackTheme && middlePanel.state !== "Merchant"
        z: parent.z + 1
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 1
        color: MoneroComponents.Style.appWindowBorderColor

        MoneroEffects.ColorTransition {
            targetObj: parent
            blackColor: MoneroComponents.Style._b_appWindowBorderColor
            whiteColor: MoneroComponents.Style._w_appWindowBorderColor
        }
    }

// @TODO: QML type 'Drawer' has issues with buildbot; debug after Qt 5.9 migration
//    MoneroComponents.LanguageSidebar {
//        id: languageSidebar
//    }
}
