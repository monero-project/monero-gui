// Copyright (c) 2014-2015, The Monero Project
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


import "components"
import "wizard"

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
    property alias password : passwordDialog.password
    property bool isNewWallet: false
    property int restoreHeight:0
    property bool daemonSynced: false
    property int maxWindowHeight: (Screen.height < 900)? 720 : 800;
    property bool daemonRunning: false
    property alias toolTip: toolTip
    property string walletName
    property bool viewOnly: false
    property bool foundNewBlock: false
    property int timeToUnlock: 0
    property bool qrScannerEnabled: (typeof builtWithScanner != "undefined") && builtWithScanner
    property int blocksToSync: 1
    property var isMobile: (appWindow.width > 700) ? false : true
    property var cameraUi

    // true if wallet ever synchronized
    property bool walletInitialized : false

    function altKeyReleased() { ctrlPressed = false; }

    function showPageRequest(page) {
        middlePanel.state = page
        leftPanel.selectItem(page)
    }

    function sequencePressed(obj, seq) {
        if(seq === undefined)
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
        else if(seq === "Ctrl+E") middlePanel.state = "Settings"
        else if(seq === "Ctrl+D") middlePanel.state = "Advanced"
        else if(seq === "Ctrl+Tab" || seq === "Alt+Tab") {
            /*
            if(middlePanel.state === "Dashboard") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "Settings"
            else if(middlePanel.state === "Settings") middlePanel.state = "Dashboard"
            */
            if(middlePanel.state === "Settings") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "Settings"
        } else if(seq === "Ctrl+Shift+Backtab" || seq === "Alt+Shift+Backtab") {
            /*
            if(middlePanel.state === "Dashboard") middlePanel.state = "Settings"
            if(middlePanel.state === "Settings") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Dashboard"
            */
            if(middlePanel.state === "Settings") middlePanel.state = "Sign"
            else if(middlePanel.state === "Sign") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "TxKey"
            else if(middlePanel.state === "TxKey") middlePanel.state = "Receive"
            else if(middlePanel.state === "Receive") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Settings"
        }

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
        appWindow.password = ""
        fileDialog.open();
    }

    function initialize() {
        console.log("initializing..")
        walletInitialized = false;

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
        } else {

            // set page to transfer if not changing daemon
            middlePanel.state = "Transfer";
            leftPanel.selectItem(middlePanel.state)

        }

        walletManager.setDaemonAddress(persistentSettings.daemon_address)
        // wallet already opened with wizard, we just need to initialize it
        if (typeof wizard.settings['wallet'] !== 'undefined') {
            console.log("using wizard wallet")
            //Set restoreHeight
            if(persistentSettings.restore_height > 0){
                // We store restore height in own variable for performance reasons.
                restoreHeight = persistentSettings.restore_height
            }

            connectWallet(wizard.settings['wallet'])

            isNewWallet = true
            // We don't need the wizard wallet any more - delete to avoid conflict with daemon adress change
            delete wizard.settings['wallet']
        }  else {
            var wallet_path = walletPath();
            if(isIOS)
                wallet_path = moneroAccountsDir + wallet_path;
            // console.log("opening wallet at: ", wallet_path, "with password: ", appWindow.password);
            console.log("opening wallet at: ", wallet_path, ", testnet: ", persistentSettings.testnet);
            walletManager.openWalletAsync(wallet_path, appWindow.password,
                                              persistentSettings.testnet);
        }

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
            middlePanel.checkPaymentClicked.disconnect(handleCheckPayment);
        }
        currentWallet = undefined;
        if (isIOS) {
            console.log("closing sync - ios")
            walletManager.closeWallet();
        } else
            walletManager.closeWalletAsync();
    }

    function connectWallet(wallet) {
        currentWallet = wallet
        walletName = usefulName(wallet.path)
        updateSyncing(false)

        viewOnly = currentWallet.viewOnly;

        // New wallets saves the testnet flag in keys file.
        if(persistentSettings.testnet != currentWallet.testnet) {
            console.log("Using testnet flag from keys file")
            persistentSettings.testnet = currentWallet.testnet;
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
        middlePanel.checkPaymentClicked.connect(handleCheckPayment);

        console.log("initializing with daemon address: ", persistentSettings.daemon_address)
        console.log("Recovering from seed: ", persistentSettings.is_recovering)
        console.log("restore Height", persistentSettings.restore_height)

        // Use saved daemon rpc login settings
        currentWallet.setDaemonLogin(persistentSettings.daemonUsername, persistentSettings.daemonPassword);

        currentWallet.initAsync(persistentSettings.daemon_address, 0, persistentSettings.is_recovering, persistentSettings.restore_height);
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

    function onWalletConnectionStatusChanged(status){
        console.log("Wallet connection status changed " + status)
        middlePanel.updateStatus();
        leftPanel.networkStatus.connected = status
        leftPanel.progressBar.visible = (status === Wallet.ConnectionStatus_Connected) && !daemonSynced

        // Update fee multiplier dropdown on transfer page
        middlePanel.transferView.updatePriorityDropdown();

        // If wallet isnt connected and no daemon is running - Ask
        if(isDaemonLocal() && !walletInitialized && status === Wallet.ConnectionStatus_Disconnected && !daemonManager.running(persistentSettings.testnet)){
            daemonManagerDialog.open();
        }
        // initialize transaction history once wallet is initialized first time;
        if (!walletInitialized) {
            currentWallet.history.refresh()
            walletInitialized = true
        }
     }

    function onWalletOpened(wallet) {
        walletName = usefulName(wallet.path)
        console.log(">>> wallet opened: " + wallet)
        if (wallet.status !== Wallet.Status_Ok) {
            if (appWindow.password === '') {
                console.error("Error opening wallet with empty password: ", wallet.errorString);
                console.log("closing wallet async : " + wallet.address)
                closeWallet();
                // try to open wallet with password;
                passwordDialog.open(walletName);
            } else {
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
        middlePanel.unlockedBalanceText = leftPanel.unlockedBalanceText =  walletManager.displayAmount(currentWallet.unlockedBalance);
        middlePanel.balanceText = leftPanel.balanceText = walletManager.displayAmount(currentWallet.balance);
        // Update history if new block found since last update
        if(foundNewBlock) {
            foundNewBlock = false;
            console.log("New block found - updating history")
            currentWallet.history.refresh()
            timeToUnlock = currentWallet.history.minutesToUnlock
            leftPanel.minutesToUnlockTxt = (timeToUnlock > 0)? (timeToUnlock == 20)? qsTr("Unlocked balance (waiting for block)").arg(timeToUnlock) : qsTr("Unlocked balance (~%1 min)").arg(timeToUnlock) : qsTr("Unlocked balance");
        }
    }

    function onWalletRefresh() {
        console.log(">>> wallet refreshed")

        // Daemon connected
        leftPanel.networkStatus.connected = currentWallet.connected()

        // Check daemon status
        var dCurrentBlock = currentWallet.daemonBlockChainHeight();
        var dTargetBlock = currentWallet.daemonBlockChainTargetHeight();
        // Daemon fully synced
        // TODO: implement onDaemonSynced or similar in wallet API and don't start refresh thread before daemon is synced
        // targetBlock = currentBlock = 1 before network connection is established.
        daemonSynced = dCurrentBlock >= dTargetBlock && dTargetBlock != 1
        // Update daemon sync progress
        leftPanel.progressBar.updateProgress(dCurrentBlock,dTargetBlock);
        leftPanel.progressBar.visible =  !daemonSynced && currentWallet.connected() !== Wallet.ConnectionStatus_Disconnected
        // Update wallet sync progress
        updateSyncing((currentWallet.connected() !== Wallet.ConnectionStatus_Disconnected) && !daemonSynced)
        // Update transfer page status
        middlePanel.updateStatus();

        // Refresh is succesfull if blockchain height > 1
        if (currentWallet.blockChainHeight() > 1){

            // Save new wallet after first refresh
            // Wallet is nomrmally saved to disk on app exit. This prevents rescan from block 0 after app crash
            if(isNewWallet){
                console.log("Saving wallet after first refresh");
                currentWallet.store()
                isNewWallet = false

                // Update History
                currentWallet.history.refresh();
            }

            // recovering from seed is finished after first refresh
            if(persistentSettings.is_recovering) {
                persistentSettings.is_recovering = false
            }
        }

        onWalletUpdate();
    }

    function startDaemon(flags){
        // Pause refresh while starting daemon
        currentWallet.pauseRefresh();

        appWindow.showProcessingSplash(qsTr("Waiting for daemon to start..."))
        daemonManager.start(flags, persistentSettings.testnet, persistentSettings.blockchainDataDir);
        persistentSettings.daemonFlags = flags
    }

    function stopDaemon(){
        appWindow.showProcessingSplash(qsTr("Waiting for daemon to stop..."))
        daemonManager.stop(persistentSettings.testnet);
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
        foundNewBlock = true;
    }

    function onWalletMoneyReceived(txId, amount) {
        // refresh transaction history here
        currentWallet.refresh()
        currentWallet.history.refresh() // this will refresh model
    }

    function onWalletUnconfirmedMoneyReceived(txId, amount) {
        // refresh history
        console.log("unconfirmed money found")
        currentWallet.history.refresh()
    }

    function onWalletMoneySent(txId, amount) {
        // refresh transaction history here
        currentWallet.refresh()
        currentWallet.history.refresh() // this will refresh model
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

            transactionConfirmationPopup.title = qsTr("Confirmation") + translationManager.emptyString
            transactionConfirmationPopup.text  = qsTr("Please confirm transaction:\n")
                        + (address === "" ? "" : (qsTr("\nAddress: ") + address))
                        + (paymentId === "" ? "" : (qsTr("\nPayment ID: ") + paymentId))
                        + qsTr("\n\nAmount: ") + walletManager.displayAmount(transaction.amount)
                        + qsTr("\nFee: ") + walletManager.displayAmount(transaction.fee)
                        + qsTr("\n\nRingsize: ") + (mixinCount + 1)
                        + qsTr("\n\Number of transactions: ") + transaction.txCount
                        + (transactionDescription === "" ? "" : (qsTr("\n\nDescription: ") + transactionDescription))
                        + translationManager.emptyString
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
            informationPopup.text  = (viewOnly)? qsTr("Transaction saved to file: %1").arg(path) : qsTr("Money sent successfully: %1 transaction(s) ").arg(txid.length) + txid_text + translationManager.emptyString
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

    // called on "checkPayment"
    function handleCheckPayment(address, txid, txkey) {
        console.log("Checking payment: ")
        console.log("\taddress: ", address,
                    ", txid: ", txid,
                    ", txkey: ", txkey);

        var result = walletManager.checkPayment(address, txid, txkey, persistentSettings.daemon_address);
        var results = result.split("|");
        if (results.length < 4) {
            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
            informationPopup.text = "internal error";
            informationPopup.icon = StandardIcon.Critical
            informationPopup.onCloseCallback = null
            informationPopup.open()
            return
        }
        var success = results[0] == "true";
        var received = results[1]
        var height = results[2]
        var error = results[3]
        if (success) {
            informationPopup.title  = qsTr("Payment check") + translationManager.emptyString;
            informationPopup.icon = StandardIcon.Information
            if (received > 0) {
                received = received / 1e12
                if (height == 0) {
                    informationPopup.text = qsTr("This address received %1 monero, but the transaction is not yet mined").arg(received);
                }
                else {
                    var dCurrentBlock = currentWallet.daemonBlockChainHeight();
                    var confirmations = dCurrentBlock - height
                    informationPopup.text = qsTr("This address received %1 monero, with %2 confirmation(s).").arg(received).arg(confirmations);
                }
            }
            else {
                informationPopup.text = qsTr("This address received nothing");
            }
        }
        else {
            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
            informationPopup.text = error;
            informationPopup.icon = StandardIcon.Critical
        }
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
//    width: Screen.width //rightPanelExpanded ? 1269 : 1269 - 300
//    height: 900 //300//maxWindowHeight;
    color: "#FFFFFF"
    flags: persistentSettings.customDecorations ? (Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint) : (Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint | Qt.WindowTitleHint | Qt.WindowMaximizeButtonHint)
    onWidthChanged: x -= 0

    function setCustomWindowDecorations(custom) {
      var x = appWindow.x
      var y = appWindow.y
      if (x < 0)
        x = 0
      if (y < 0)
        y = 0
      persistentSettings.customDecorations = custom
      if (custom)
        appWindow.flags = Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint
      else
        appWindow.flags = Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint | Qt.WindowTitleHint | Qt.WindowMaximizeButtonHint
      appWindow.hide()
      appWindow.x = x
      appWindow.y = y
      appWindow.show()
    }

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
                initialize(persistentSettings);
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
        property bool   testnet: false
        property string daemon_address: testnet ? "localhost:28081" : "localhost:18081"
        property string payment_id
        property int    restore_height : 0
        property bool   is_recovering : false
        property bool   customDecorations : true
        property string daemonFlags
        property int logLevel: 0
        property string logCategories: ""
        property string daemonUsername: ""
        property string daemonPassword: ""
        property bool transferShowAdvanced: false
        property string blockchainDataDir: ""
    }

    // Information dialog
    StandardDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: informationPopup
        cancelVisible: false
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    // Confrirmation aka question dialog
    StandardDialog {
        id: transactionConfirmationPopup
        onAccepted: {
            close();
            transactionConfirmationPasswordDialog.onAcceptedCallback = function() {
                if(appWindow.password === transactionConfirmationPasswordDialog.password){
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
                        transactionConfirmationPasswordDialog.open()
                    }
                }
                transactionConfirmationPasswordDialog.password = ""
            }
            transactionConfirmationPasswordDialog.open()
        }
    }

    StandardDialog {
        id: confirmationDialog
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

        onAccepted: {
            persistentSettings.wallet_path = walletManager.urlToLocalPath(fileDialog.fileUrl)
            initialize();
        }
        onRejected: {
            console.log("Canceled")
            rootItem.state = "wizard";
        }

    }

    PasswordDialog {
        id: passwordDialog

        onAccepted: {
            appWindow.initialize();
        }
        onRejected: {
            //appWindow.enableUI(false)
            rootItem.state = "wizard"
        }

    }

    PasswordDialog {
        id: transactionConfirmationPasswordDialog
        property var onAcceptedCallback
        onAccepted: {
            if (onAcceptedCallback())
                onAcceptedCallback();
        }
    }

    DaemonManagerDialog {
        id: daemonManagerDialog
        onRejected: {
            loadPage("Settings");
        }

    }

    ProcessingSplash {
        id: splash
        width: appWindow.width / 1.5
        height: appWindow.height / 2
        x: (appWindow.width - width) / 2 + appWindow.x
        y: (appWindow.height - height) / 2 + appWindow.y
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
                PropertyChanges { target: appWindow; width: (Screen.width < 930)? Screen.width : 930; }
                PropertyChanges { target: appWindow; height: maxWindowHeight; }
                PropertyChanges { target: resizeArea; visible: false }
                PropertyChanges { target: titleBar; maximizeButtonVisible: false }
//                PropertyChanges { target: frameArea; blocked: true }
                PropertyChanges { target: titleBar; visible: false }
                PropertyChanges { target: titleBar; y: 0 }
                PropertyChanges { target: titleBar; title: qsTr("Program setup wizard") + translationManager.emptyString }
            }, State {
                name: "normal"
                PropertyChanges { target: leftPanel; visible: (isMobile)? false : true }
                PropertyChanges { target: rightPanel; visible: true }
                PropertyChanges { target: middlePanel; visible: true }
                PropertyChanges { target: titleBar; basicButtonVisible: true }
                PropertyChanges { target: wizard; visible: false }
                PropertyChanges { target: appWindow; width:  (Screen.width < 969)? Screen.width : 969 } //rightPanelExpanded ? 1269 : 1269 - 300;
                PropertyChanges { target: appWindow; height: maxWindowHeight; }
                PropertyChanges { target: resizeArea; visible: true }
                PropertyChanges { target: titleBar; maximizeButtonVisible: true }
//                PropertyChanges { target: frameArea; blocked: true }
                PropertyChanges { target: titleBar; visible: true }
//                PropertyChanges { target: titleBar; y: 0 }
                PropertyChanges { target: titleBar; title: qsTr("Monero") + translationManager.emptyString }
            }
        ]

        MobileHeader {
            id: mobileHeader
            visible: isMobile
            anchors.left: parent.left
            anchors.right: parent.right
            height: visible? 65 : 0
        }

        LeftPanel {
            id: leftPanel
            anchors.top: mobileHeader.bottom
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            onDashboardClicked: {middlePanel.state = "Dashboard"; if(isMobile) hideMenu()}
            onTransferClicked: {middlePanel.state = "Transfer"; if(isMobile) hideMenu()}
            onReceiveClicked: {middlePanel.state = "Receive"; if(isMobile) hideMenu()}
            onTxkeyClicked: {middlePanel.state = "TxKey"; if(isMobile) hideMenu()}
            onHistoryClicked: {middlePanel.state = "History"; if(isMobile) hideMenu()}
            onAddressBookClicked: {middlePanel.state = "AddressBook"; if(isMobile) hideMenu()}
            onMiningClicked: {middlePanel.state = "Mining"; if(isMobile) hideMenu()}
            onSignClicked: {middlePanel.state = "Sign"; if(isMobile) hideMenu()}
            onSettingsClicked: {middlePanel.state = "Settings"; if(isMobile) hideMenu()}
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

//        MouseArea {
//            id: frameArea
//            property bool blocked: false
//            anchors.top: parent.top
//            anchors.left: parent.left
//            anchors.right: parent.right
//            height: 30
//            z: 1
//            hoverEnabled: true
//            propagateComposedEvents: true
//            onPressed: mouse.accepted = false
//            onReleased: mouse.accepted = false
//            onMouseXChanged: titleBar.mouseX = mouseX
//            onContainsMouseChanged: titleBar.containsMouse = containsMouse
//        }

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
            anchors.left: parent.left
            anchors.right: parent.right
            x: 0
            y: 0
            customDecorations: persistentSettings.customDecorations
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
                font.pixelSize: 12
                color: "#FFFFFF"
            }
        }

        Notifier {
            visible:false
            id: notifier
        }
    }

    onClosing: {

        // If daemon is running - prompt user before exiting
        if(typeof daemonManager != "undefined" && daemonManager.running(persistentSettings.testnet)) {
            close.accepted = false;

            // Show confirmation dialog
            confirmationDialog.title = qsTr("Daemon is running") + translationManager.emptyString;
            confirmationDialog.text  = qsTr("Daemon will still be running in background when GUI is closed.");
            confirmationDialog.icon = StandardIcon.Question
            confirmationDialog.cancelText = qsTr("Stop daemon")
            confirmationDialog.onAcceptedCallback = function() {
                closeAccepted();
            }

            confirmationDialog.onRejectedCallback = function() {
                daemonManager.stop(persistentSettings.testnet);
                closeAccepted();
            };

            confirmationDialog.open()

        } else {
            closeAccepted();
        }
    }

    function closeAccepted(){
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

    function isDaemonLocal() {
        var daemonAddress = appWindow.persistentSettings.daemon_address
        if (daemonAddress === "")
            return false
        var daemonHost = daemonAddress.split(":")[0]
        if (daemonHost === "127.0.0.1" || daemonHost === "localhost")
            return true
        return false
    }

}
