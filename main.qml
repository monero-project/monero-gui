// Copyright (c) 2014-2018, The Monero Project
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

import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

import moneroComponents.Wallet 1.0
import moneroComponents.PendingTransaction 1.0
import moneroComponents.NetworkType 1.0


import "components"
import "wizard"
import "../js/Utils.js" as Utils
import "js/Windows.js" as Windows

ApplicationWindow {
    id: appWindow
    title: "Monero"

    property var currentItem
    property bool whatIsEnable: false
    property bool ctrlPressed: false
    property bool rightPanelExpanded: false
    property bool osx: false
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
    property int timeToUnlock: 0
    property bool qrScannerEnabled: (typeof builtWithScanner != "undefined") && builtWithScanner
    property int blocksToSync: 1
    property var isMobile: (appWindow.width > 700 && !isAndroid) ? false : true
    property var cameraUi
    property bool remoteNodeConnected: false
    property bool androidCloseTapped: false;
    // Default daemon addresses
    readonly property string localDaemonAddress : persistentSettings.nettype == NetworkType.MAINNET ? "localhost:18081" : persistentSettings.nettype == NetworkType.TESTNET ? "localhost:28081" : "localhost:38081"
    property string currentDaemonAddress;
    property bool startLocalNodeCancelled: false
    property int estimatedBlockchainSize: 50 // GB

    // true if wallet ever synchronized
    property bool walletInitialized : false

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

        // Dashboard is not implemented
        // if(seq === "Ctrl+") middlePanel.state = "Dashboard"
        if(seq === "Ctrl+S") middlePanel.state = "Transfer"
        else if(seq === "Ctrl+R") middlePanel.state = "Receive"
        else if(seq === "Ctrl+K") middlePanel.state = "TxKey"
        else if(seq === "Ctrl+H") middlePanel.state = "History"
        else if(seq === "Ctrl+B") middlePanel.state = "AddressBook"
        else if(seq === "Ctrl+M") middlePanel.state = "Mining"
        else if(seq === "Ctrl+I") middlePanel.state = "Sign"
        else if(seq === "Ctrl+G") middlePanel.state = "SharedRingDB"
        else if(seq === "Ctrl+E") middlePanel.state = "Settings"
        else if(seq === "Ctrl+Y") leftPanel.keysClicked()
        else if(seq === "Ctrl+D") middlePanel.state = "Advanced"
        else if(seq === "Ctrl+Tab" || seq === "Alt+Tab") {
            /*
            if(middlePanel.state === "Dashboard") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "SharedRingDB"
            else if(middlePanel.state === "SharedRingDB") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "Settings"
            else if(middlePanel.state === "Settings") middlePanel.state = "Dashboard"
            */
            if(middlePanel.state === "Settings") middlePanel.state = "Transfer"
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
            if(middlePanel.state === "Dashboard") middlePanel.state = "Settings"
            if(middlePanel.state === "Settings") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "SharedRingDB"
            else if(middlePanel.state === "SharedRingDB") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Dashboard"
            */
            if(middlePanel.state === "Settings") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "SharedRingDB"
            else if(middlePanel.state === "SharedRingDB") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Settings"
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

    function openWalletFromFile(){
        persistentSettings.restore_height = 0
        restoreHeight = 0;
        persistentSettings.is_recovering = false
        walletPassword = ""
        fileDialog.open();
    }

    function initialize() {
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
            currentWallet = undefined
        } else if (!walletInitialized) {

            // set page to transfer if not changing daemon
            middlePanel.state = "Transfer";
            leftPanel.selectItem(middlePanel.state)

        }


        // Local daemon settings
        walletManager.setDaemonAddress(localDaemonAddress)


        // wallet already opened with wizard, we just need to initialize it
        if (typeof wizard.m_wallet !== 'undefined') {
            console.log("using wizard wallet")
            //Set restoreHeight
            if (persistentSettings.restore_height == 0 && persistentSettings.is_recovering_from_device && walletManager.localDaemonSynced()) {
                persistentSettings.restore_height = walletManager.blockchainHeight() - 1;
            }
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
            walletManager.openWalletAsync(wallet_path, walletPassword,
                                              persistentSettings.nettype);
        }

        // Hide titlebar based on persistentSettings.customDecorations
        titleBar.visible = persistentSettings.customDecorations;
    }

    function closeWallet() {

        // Disconnect all listeners
        if (typeof currentWallet !== "undefined" && currentWallet !== null) {
            currentWallet.refreshed.disconnect(onWalletRefresh)
            currentWallet.updated.disconnect(onWalletUpdate)
            currentWallet.newBlock.disconnect(onWalletNewBlock)
            currentWallet.moneySpent.disconnect(onWalletMoneySent)
            currentWallet.moneyReceived.disconnect(onWalletMoneyReceived)
            currentWallet.unconfirmedMoneyReceived.disconnect(onWalletUnconfirmedMoneyReceived)
            currentWallet.transactionCreated.disconnect(onTransactionCreated)
            currentWallet.connectionStatusChanged.disconnect(onWalletConnectionStatusChanged)
            middlePanel.paymentClicked.disconnect(handlePayment);
            middlePanel.sweepUnmixableClicked.disconnect(handleSweepUnmixable);
            middlePanel.getProofClicked.disconnect(handleGetProof);
            middlePanel.checkProofClicked.disconnect(handleCheckProof);
        }

        currentWallet = undefined;
        walletManager.closeWallet();

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
        updateSyncing(false)

        viewOnly = currentWallet.viewOnly;

        // New wallets saves the testnet flag in keys file.
        if(persistentSettings.nettype != currentWallet.nettype) {
            console.log("Using network type from keys file")
            persistentSettings.nettype = currentWallet.nettype;
        }

        // connect handlers
        currentWallet.refreshed.connect(onWalletRefresh)
        currentWallet.updated.connect(onWalletUpdate)
        currentWallet.newBlock.connect(onWalletNewBlock)
        currentWallet.moneySpent.connect(onWalletMoneySent)
        currentWallet.moneyReceived.connect(onWalletMoneyReceived)
        currentWallet.unconfirmedMoneyReceived.connect(onWalletUnconfirmedMoneyReceived)
        currentWallet.transactionCreated.connect(onTransactionCreated)
        currentWallet.connectionStatusChanged.connect(onWalletConnectionStatusChanged)
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
        currentWallet.initAsync(currentDaemonAddress, 0, persistentSettings.is_recovering, persistentSettings.is_recovering_from_device, persistentSettings.restore_height);
        // save wallet keys in case wallet settings have been changed in the init
        currentWallet.setPassword(walletPassword);
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
        middlePanel.unlockedBalanceText = leftPanel.unlockedBalanceText =  middlePanel.state === "Receive" ? qsTr("HIDDEN") : walletManager.displayAmount(currentWallet.unlockedBalance(currentWallet.currentSubaddressAccount));
        middlePanel.balanceText = leftPanel.balanceText = middlePanel.state === "Receive" ? qsTr("HIDDEN") : walletManager.displayAmount(currentWallet.balance(currentWallet.currentSubaddressAccount));
    }

    function onWalletConnectionStatusChanged(status){
        console.log("Wallet connection status changed " + status)
        middlePanel.updateStatus();
        leftPanel.networkStatus.connected = status

        // update local daemon status.
        if(!isMobile && walletManager.isDaemonLocal(appWindow.persistentSettings.daemon_address))
            daemonRunning = status;

        // Update fee multiplier dropdown on transfer page
        middlePanel.transferView.updatePriorityDropdown();

        // If wallet isnt connected and no daemon is running - Ask
        if(!isMobile && walletManager.isDaemonLocal(appWindow.persistentSettings.daemon_address) && !walletInitialized && status === Wallet.ConnectionStatus_Disconnected && !daemonManager.running(persistentSettings.nettype)){
            daemonManagerDialog.open();
        }
        // initialize transaction history once wallet is initialized first time;
        if (!walletInitialized) {
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
            walletInitialized = true
        }
     }

    function onWalletOpened(wallet) {
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
                rootItem.state = "wizard";
            }
            // opening with password but password doesn't match
            console.error("Error opening wallet with password: ", wallet.errorString);
            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
            informationPopup.text = qsTr("Couldn't open wallet: ") + wallet.errorString;
            informationPopup.icon = StandardIcon.Critical
            console.log("closing wallet async : " + wallet.address)
            closeWallet();
            informationPopup.open()
            informationPopup.onCloseCallback = function() {
                passwordDialog.open(walletName)
            }
            return;
        }

        // wallet opened successfully, subscribing for wallet updates
        connectWallet(wallet)
    }


    function onWalletClosed(walletAddress) {
        console.log(">>> wallet closed: " + walletAddress)
    }

    function onWalletUpdate() {
        console.log(">>> wallet updated")
        updateBalance();
        // Update history if new block found since last update
        if(foundNewBlock) {
            foundNewBlock = false;
            console.log("New block found - updating history")
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
            timeToUnlock = currentWallet.history.minutesToUnlock
            leftPanel.minutesToUnlockTxt = (timeToUnlock > 0)? (timeToUnlock == 20)? qsTr("Unlocked balance (waiting for block)") : qsTr("Unlocked balance (~%1 min)").arg(timeToUnlock) : qsTr("Unlocked balance");
        }
    }

    function connectRemoteNode() {
        console.log("connecting remote node");
        persistentSettings.useRemoteNode = true;
        currentDaemonAddress = persistentSettings.remoteNodeAddress;
        currentWallet.initAsync(currentDaemonAddress);
        walletManager.setDaemonAddress(currentDaemonAddress);
        remoteNodeConnected = true;
    }

    function disconnectRemoteNode() {
        console.log("disconnecting remote node");
        persistentSettings.useRemoteNode = false;
        currentDaemonAddress = localDaemonAddress
        currentWallet.initAsync(currentDaemonAddress);
        walletManager.setDaemonAddress(currentDaemonAddress);
        remoteNodeConnected = false;
    }

    function onWalletRefresh() {
        console.log(">>> wallet refreshed")

        // Daemon connected
        leftPanel.networkStatus.connected = currentWallet.connected()

        // Wallet height
        var bcHeight = currentWallet.blockChainHeight();

        // Check daemon status
        var dCurrentBlock = currentWallet.daemonBlockChainHeight();
        var dTargetBlock = currentWallet.daemonBlockChainTargetHeight();
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
        updateSyncing((currentWallet.connected() !== Wallet.ConnectionStatus_Disconnected) && !daemonSynced)
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
        }

        // Update history on every refresh if it's empty
        if(currentWallet.history.count == 0)
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)

        onWalletUpdate();
    }

    function startDaemon(flags){
        // Pause refresh while starting daemon
        currentWallet.pauseRefresh();

        appWindow.showProcessingSplash(qsTr("Waiting for daemon to start..."))
        daemonManager.start(flags, persistentSettings.nettype, persistentSettings.blockchainDataDir, persistentSettings.bootstrapNodeAddress);
        persistentSettings.daemonFlags = flags
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
        currentWallet.refresh()
        console.log("Confirmed money found")
        // history refresh is handled by walletUpdated
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount) // this will refresh model
        currentWallet.subaddress.refresh(currentWallet.currentSubaddressAccount)
    }

    function onWalletUnconfirmedMoneyReceived(txId, amount) {
        // refresh history
        console.log("unconfirmed money found")
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
    }

    function onWalletMoneySent(txId, amount) {
        // refresh transaction history here
        console.log("monero sent found")
        currentWallet.refresh()
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount) // this will refresh model
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
            if(mixinCount !== 6){
                transactionConfirmationPopup.text +=  qsTr("\n\nWARNING: non default ring size, which may harm your privacy. Default of 7 is recommended.");
            }
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

        showProcessingSplash("Creating transaction");

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
        // grab transaction.txid before commit, since it clears it.
        // we actually need to copy it, because QML will incredibly
        // call the function multiple times when the variable is used
        // after commit, where it returns another result...
        // Of course, this loop is also calling the function multiple
        // times, but at least with the same result.
        var txid = [], txid_org = transaction.txid, txid_text = ""
        for (var i = 0; i < txid_org.length; ++i)
          txid[i] = txid_org[i]

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

        if (!transaction.commit()) {
            console.log("Error committing transaction: " + transaction.errorString);
            informationPopup.title = qsTr("Error") + translationManager.emptyString
            informationPopup.text  = qsTr("Couldn't send the money: ") + transaction.errorString
            informationPopup.icon  = StandardIcon.Critical
        } else {
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

        var result;
        if (address.length > 0)
            result = currentWallet.getTxProof(txid, address, message);
        if (!result || result.indexOf("error|") === 0)
            result = currentWallet.getSpendProof(txid, message);
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
                received = received / 1e12
                if (in_pool) {
                    informationPopup.text = qsTr("This address received %1 monero, but the transaction is not yet mined").arg(received);
                }
                else {
                    informationPopup.text = qsTr("This address received %1 monero, with %2 confirmation(s).").arg(received).arg(confirmations);
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

    function updateSyncing(syncing) {
        var text = (syncing ? qsTr("Balance (syncing)") : qsTr("Balance")) + translationManager.emptyString
        leftPanel.balanceLabelText = text
        middlePanel.balanceLabelText = text
    }

    // blocks UI if wallet can't be opened or no connection to the daemon
    function enableUI(enable) {
        middlePanel.enabled = enable;
        leftPanel.enabled = enable;
        rightPanel.enabled = enable;
    }

    function showProcessingSplash(message) {
        console.log("Displaying processing splash")
        if (typeof message != 'undefined') {
            splash.messageText = message
            splash.heightProgressText = ""
        }
        splash.show()
    }

    function hideProcessingSplash() {
        console.log("Hiding processing splash")
        splash.close()
    }

    // close wallet and show wizard
    function showWizard(){
        walletInitialized = false;
        closeWallet();
        currentWallet = undefined;
        wizard.restart();
        rootItem.state = "wizard"
        // reset balance
        leftPanel.balanceText = leftPanel.unlockedBalanceText = walletManager.displayAmount(0);
    }

    function hideMenu() {
        goToBasicAnimation.start();
        console.log(appWindow.width)
    }

    function showMenu() {
        goToProAnimation.start();
        console.log(appWindow.width)
    }


    objectName: "appWindow"
    visible: true
//    width: screenWidth //rightPanelExpanded ? 1269 : 1269 - 300
//    height: 900 //300//maxWindowHeight;
    color: "#FFFFFF"
    flags: persistentSettings.customDecorations ? Windows.flagsCustomDecorations : Windows.flags
    onWidthChanged: x -= 0

    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - maxWindowHeight) / 2
        //
        walletManager.walletOpened.connect(onWalletOpened);
        walletManager.walletClosed.connect(onWalletClosed);
        walletManager.checkUpdatesComplete.connect(onWalletCheckUpdatesComplete);

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
                rootItem.state = "wizard"
            }
            passwordDialog.open(usefulName(walletPath()))
        }

        checkUpdates();
    }

    onRightPanelExpandedChanged: {
        if (rightPanelExpanded) {
            rightPanel.updateTweets()
        }
    }


    Settings {
        id: persistentSettings
        property string language
        property string locale
        property string account_name
        property string wallet_path
        property bool   auto_donations_enabled : false
        property int    auto_donations_amount : 50
        property bool   allow_background_mining : false
        property bool   miningIgnoreBattery : true
        property var    nettype: NetworkType.MAINNET
        property string daemon_address: nettype == NetworkType.TESTNET ? "localhost:28081" : nettype == NetworkType.STAGENET ? "localhost:38081" : "localhost:18081"
        property string payment_id
        property int    restore_height : 0
        property bool   is_recovering : false
        property bool   is_recovering_from_device : false
        property bool   customDecorations : true
        property string daemonFlags
        property int logLevel: 0
        property string logCategories: ""
        property string daemonUsername: ""
        property string daemonPassword: ""
        property bool transferShowAdvanced: false
        property string blockchainDataDir: ""
        property bool useRemoteNode: false
        property string remoteNodeAddress: ""
        property string bootstrapNodeAddress: ""
        property bool segregatePreForkOutputs: true
        property bool keyReuseMitigation2: true
        property int segregationHeight: 0
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
                    informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                    informationPopup.text = qsTr("Wrong password");
                    informationPopup.open()
                    informationPopup.onCloseCallback = function() {
                        passwordDialog.open()
                    }
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


    //Open Wallet from file
    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: "file://" +moneroAccountsDir
        nameFilters: [ "Wallet files (*.keys)"]
        sidebarVisible: false


        onAccepted: {
            persistentSettings.wallet_path = walletManager.urlToLocalPath(fileDialog.fileUrl)
            if(isIOS)
                persistentSettings.wallet_path = persistentSettings.wallet_path.replace(moneroAccountsDir,"")
            console.log("ÖPPPPNA")
            console.log(moneroAccountsDir)
            console.log(fileDialog.fileUrl)
            console.log(persistentSettings.wallet_path)
            passwordDialog.onAcceptedCallback = function() {
                walletPassword = passwordDialog.password;
                initialize();
            }
            passwordDialog.onRejectedCallback = function() {
                console.log("Canceled")
                rootItem.state = "wizard";
            }
            passwordDialog.open(usefulName(walletPath()));
        }
        onRejected: {
            console.log("Canceled")
            rootItem.state = "wizard";
        }

    }

    // Choose blockchain folder
    FileDialog {
        id: blockchainFileDialog
        title: "Please choose a folder"
        selectFolder: true
        folder: "file://" + persistentSettings.blockchainDataDir

        onAccepted: {
            var dataDir = walletManager.urlToLocalPath(blockchainFileDialog.fileUrl)
            var validator = daemonManager.validateDataDir(dataDir);
            if(!validator.valid) {

                confirmationDialog.title = qsTr("Warning") + translationManager.emptyString;
                confirmationDialog.text = "";
                if(validator.readOnly)
                    confirmationDialog.text  += qsTr("Error: Filesystem is read only") + "\n\n"
                if(validator.storageAvailable < 20)
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
                confirmationDialog.onRejectedCallback = function() {
                };

                confirmationDialog.open()
            } else {
                persistentSettings.blockchainDataDir = dataDir
            }

            delete validator;


        }
        onRejected: {
            console.log("data dir selection canceled")
        }

    }


    PasswordDialog {
        id: passwordDialog
        visible: false
        z: parent.z + 1
        anchors.fill: parent
        property var onAcceptedCallback
        property var onRejectedCallback
        onAccepted: {
            if (onAcceptedCallback)
                onAcceptedCallback();
        }
        onRejected: {
            if (onRejectedCallback)
                onRejectedCallback();
        }
    }

    NewPasswordDialog {
        id: newPasswordDialog
        z: parent.z + 1
        visible:false
        anchors.fill: parent
        onAccepted: {
            if (currentWallet.setPassword(newPasswordDialog.password)) {
                appWindow.walletPassword = newPasswordDialog.password;
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
        onRejected: {
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
            loadPage("Settings");
            startLocalNodeCancelled = true
        }

    }

    ProcessingSplash {
        id: splash
        width: appWindow.width / 1.5
        height: appWindow.height / 2
        x: (appWindow.width - width) / 2
        y: (appWindow.height - height) / 2
        messageText: qsTr("Please wait...")
    }

    Item {
        id: rootItem
        anchors.fill: parent
        clip: true

        state: "wizard"
        states: [
            State {
                name: "wizard"
                PropertyChanges { target: leftPanel; visible: false }
                PropertyChanges { target: rightPanel; visible: false }
                PropertyChanges { target: middlePanel; visible: false }
                PropertyChanges { target: titleBar; basicButtonVisible: false }
                PropertyChanges { target: wizard; visible: true }
                PropertyChanges { target: appWindow; width: (screenWidth < 930 || isAndroid || isIOS)? screenWidth : 930; }
                PropertyChanges { target: appWindow; height: maxWindowHeight; }
                PropertyChanges { target: resizeArea; visible: true }
                PropertyChanges { target: titleBar; showMaximizeButton: false }
//                PropertyChanges { target: frameArea; blocked: true }
                PropertyChanges { target: titleBar; visible: false }
                PropertyChanges { target: titleBar; y: 0 }
                PropertyChanges { target: titleBar; title: qsTr("Program setup wizard") + translationManager.emptyString }
                PropertyChanges { target: mobileHeader; visible: false }
            }, State {
                name: "normal"
                PropertyChanges { target: leftPanel; visible: (isMobile)? false : true }
                PropertyChanges { target: rightPanel; visible: true }
                PropertyChanges { target: middlePanel; visible: true }
                PropertyChanges { target: titleBar; basicButtonVisible: true }
                PropertyChanges { target: wizard; visible: false }
                PropertyChanges { target: appWindow; width: (screenWidth < 969 || isAndroid || isIOS)? screenWidth : 969 } //rightPanelExpanded ? 1269 : 1269 - 300;
                PropertyChanges { target: appWindow; height: maxWindowHeight; }
                PropertyChanges { target: resizeArea; visible: true }
                PropertyChanges { target: titleBar; showMaximizeButton: true }
//                PropertyChanges { target: frameArea; blocked: true }
                PropertyChanges { target: titleBar; visible: true }
//                PropertyChanges { target: titleBar; y: 0 }
                PropertyChanges { target: titleBar; title: qsTr("Monero") + translationManager.emptyString }
                PropertyChanges { target: mobileHeader; visible: isMobile ? true : false }
            }
        ]

        MobileHeader {
            id: mobileHeader
            visible: isMobile
            anchors.left: parent.left
            anchors.right: parent.right
            height: visible? 65 * scaleRatio : 0

            MouseArea {
                enabled: persistentSettings.customDecorations
                property var previousPosition
                anchors.fill: parent
                propagateComposedEvents: true
                onPressed: previousPosition = globalCursor.getPosition()
                onPositionChanged: {
                    if (pressedButtons == Qt.LeftButton) {
                        var pos = globalCursor.getPosition()
                        var dx = pos.x - previousPosition.x
                        var dy = pos.y - previousPosition.y

                        appWindow.x += dx
                        appWindow.y += dy
                        previousPosition = pos
                    }
                }
            }
        }

        LeftPanel {
            id: leftPanel
            anchors.top: mobileHeader.bottom
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            onDashboardClicked: {
                middlePanel.state = "Dashboard";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onTransferClicked: {
                middlePanel.state = "Transfer";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onReceiveClicked: {
                middlePanel.state = "Receive";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onTxkeyClicked: {
                middlePanel.state = "TxKey";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onSharedringdbClicked: {
                middlePanel.state = "SharedRingDB";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onHistoryClicked: {
                middlePanel.state = "History";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onAddressBookClicked: {
                middlePanel.state = "AddressBook";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onMiningClicked: {
                middlePanel.state = "Mining";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onSignClicked: {
                middlePanel.state = "Sign";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onSettingsClicked: {
                middlePanel.state = "Settings";
                middlePanel.flickable.contentY = 0;
                if(isMobile) {
                    hideMenu();
                }
                updateBalance();
            }

            onKeysClicked: Utils.showSeedPage();
        }

        RightPanel {
            id: rightPanel
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: appWindow.rightPanelExpanded ? 300 : 0
            visible: appWindow.rightPanelExpanded
        }


        MiddlePanel {
            id: middlePanel
            anchors.top: mobileHeader.bottom
            anchors.bottom: parent.bottom
            anchors.left: leftPanel.visible ?  leftPanel.right : parent.left
            anchors.right: parent.right
            state: "Transfer"
        }

        TipItem {
            id: tipItem
            text: qsTr("send to the same destination") + translationManager.emptyString
            visible: false
        }

        SequentialAnimation {
            id: goToBasicAnimation
//            PropertyAction {
//                target: appWindow
//                properties: "visibility"
//                value: Window.Windowed
//            }
//            PropertyAction {
//                target: titleBar
//                properties: "maximizeButtonVisible"
//                value: false
//            }
//            PropertyAction {
//                target: frameArea
//                properties: "blocked"
//                value: true
//            }
            PropertyAction {
                target: resizeArea
                properties: "visible"
                value: true
            }
//            PropertyAction {
//                target: appWindow
//                properties: "height"
//                value: 30
//            }
//            PropertyAction {
//                target: appWindow
//                properties: "width"
//                value: 326
//            }
            PropertyAction {
                targets: [leftPanel, rightPanel]
                properties: "visible"
                value: false
            }
            PropertyAction {
                target: middlePanel
                properties: "basicMode"
                value: true
            }

//            PropertyAction {
//                target: appWindow
//                properties: "height"
//                value: middlePanel.height
//            }

            onStopped: {
                // middlePanel.visible = false
                rightPanel.visible = false
                leftPanel.visible = false
            }
        }

        SequentialAnimation {
            id: goToProAnimation
//            PropertyAction {
//                target: appWindow
//                properties: "height"
//                value: 30
//            }
            PropertyAction {
                target: middlePanel
                properties: "basicMode"
                value: false
            }
            PropertyAction {
                targets: [leftPanel, middlePanel, rightPanel, resizeArea]
                properties: "visible"
                value: true
            }
//            PropertyAction {
//                target: appWindow
//                properties: "width"
//                value: rightPanelExpanded ? 1269 : 1269 - 300
//            }
//            PropertyAction {
//                target: appWindow
//                properties: "height"
//                value: maxWindowHeight
//            }
//            PropertyAction {
//                target: frameArea
//                properties: "blocked"
//                value: false
//            }
//            PropertyAction {
//                target: titleBar
//                properties: "maximizeButtonVisible"
//                value: true
//            }
        }

        WizardMain {
            id: wizard
            anchors.fill: parent
            onUseMoneroClicked: {
                rootItem.state = "normal" // TODO: listen for this state change in appWindow;
                appWindow.initialize();
            }
            onOpenWalletFromFileClicked: {
                rootItem.state = "normal" // TODO: listen for this state change in appWindow;
                appWindow.openWalletFromFile();
            }
        }

        property int minWidth: 326
        property int minHeight: 400
        MouseArea {
            id: resizeArea
            hoverEnabled: true
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 30
            width: 30

            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse || parent.pressed ? "#111111" : "transparent"
            }

            Image {
                anchors.centerIn: parent
                source: parent.containsMouse || parent.pressed ? "images/resizeHovered.png" :
                                                                 "images/resize.png"
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
            x: 0
            y: 0
            anchors.left: parent.left
            anchors.right: parent.right
            showMinimizeButton: true
            showMaximizeButton: true
            showWhatIsButton: false
            showMoneroLogo: true
            onCloseClicked: appWindow.close();
            onMaximizeClicked: {
                appWindow.visibility = appWindow.visibility !== Window.Maximized ? Window.Maximized :
                                                                                    Window.Windowed
            }
            onMinimizeClicked: appWindow.visibility = Window.Minimized
            onGoToBasicVersion: {
                if (yes) {
                    // basicPanel.currentView = middlePanel.currentView
                    goToBasicAnimation.start()
                } else {
                    // middlePanel.currentView = basicPanel.currentView
                    goToProAnimation.start()
                }
            }

            MouseArea {
                enabled: persistentSettings.customDecorations
                property var previousPosition
                anchors.fill: parent
                propagateComposedEvents: true
                onPressed: previousPosition = globalCursor.getPosition()
                onPositionChanged: {
                    if (pressedButtons == Qt.LeftButton) {
                        var pos = globalCursor.getPosition()
                        var dx = pos.x - previousPosition.x
                        var dy = pos.y - previousPosition.y

                        appWindow.x += dx
                        appWindow.y += dy
                        previousPosition = pos
                    }
                }
            }
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
                source: "../images/tip.png"
            }

            Text {
                id: content
                anchors.horizontalCenter: parent.horizontalCenter
                y: 6
                lineHeight: 0.7
                font.family: "Arial"
                font.pixelSize: 12 * scaleRatio
                color: "#FFFFFF"
            }
        }

        Notifier {
            visible:false
            id: notifier
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

    Rectangle {
        id: statusMessage
        z: 99
        visible: false
        property alias text: statusMessageText.text
        anchors.bottom: parent.bottom
        width: statusMessageText.contentWidth + 20 * scaleRatio
        anchors.horizontalCenter: parent.horizontalCenter
        color: "black"
        height: 40 * scaleRatio
        Text {
            id: statusMessageText
            anchors.fill: parent
            anchors.margins: 10 * scaleRatio
            font.pixelSize: 14 * scaleRatio
            color: "white"
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
        if(typeof daemonManager != "undefined" && daemonManager.running(persistentSettings.nettype)) {

            // Show confirmation dialog
            confirmationDialog.title = qsTr("Daemon is running") + translationManager.emptyString;
            confirmationDialog.text  = qsTr("Daemon will still be running in background when GUI is closed.");
            confirmationDialog.icon = StandardIcon.Question
            confirmationDialog.cancelText = qsTr("Stop daemon")
            confirmationDialog.onAcceptedCallback = function() {
                closeAccepted();
            }

            confirmationDialog.onRejectedCallback = function() {
                daemonManager.stop(persistentSettings.nettype);
                closeAccepted();
            };

            confirmationDialog.open()

        } else {
            closeAccepted();
        }
    }

    function closeAccepted(){
        console.log("close accepted");
        // Close wallet non async on exit
        daemonManager.exit();
        walletManager.closeWallet();
        Qt.quit();
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
          var auto_url = parts[3]
          var msg = qsTr("New version of monero-wallet-gui is available: %1<br>%2").arg(version).arg(user_url) + translationManager.emptyString
          notifier.show(msg)
        }
        else {
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

    // background gradient
    Rectangle {
        id: inactiveOverlay
        visible: false
        anchors.fill: parent
        color: "black"
        opacity: 0.8
    }
}
