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


    property var currentItem
    property bool whatIsEnable: false
    property bool ctrlPressed: false
    property bool rightPanelExpanded: false
    property bool osx: false
    property alias persistentSettings : persistentSettings
    property var currentWallet;
    property var transaction;
    property alias password : passwordDialog.password
    property int splashCounter: 0
    property bool isNewWallet: false
    property int restoreHeight:0

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

        if(seq === "Ctrl+D") middlePanel.state = "Dashboard"
        else if(seq === "Ctrl+H") middlePanel.state = "History"
        else if(seq === "Ctrl+T") middlePanel.state = "Transfer"
        else if(seq === "Ctrl+B") middlePanel.state = "AddressBook"
        else if(seq === "Ctrl+M") middlePanel.state = "Mining"
        else if(seq === "Ctrl+S") middlePanel.state = "Settings"
        else if(seq === "Ctrl+Tab" || seq === "Alt+Tab") {
            if(middlePanel.state === "Dashboard") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "Settings"
            else if(middlePanel.state === "Settings") middlePanel.state = "Dashboard"
        } else if(seq === "Ctrl+Shift+Backtab" || seq === "Alt+Shift+Backtab") {
            if(middlePanel.state === "Dashboard") middlePanel.state = "Settings"
            else if(middlePanel.state === "Settings") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Dashboard"
        }

        leftPanel.selectItem(middlePanel.state)
    }

    function sequenceReleased(obj, seq) {
        if(seq === "Ctrl")
            ctrlPressed = false
    }

    function mousePressed(obj, mouseX, mouseY) {
//        if(obj.objectName === "appWindow")
//            obj = rootItem

//        var tmp = rootItem.mapFromItem(obj, mouseX, mouseY)
//        if(tmp !== undefined) {
//            mouseX = tmp.x
//            mouseY = tmp.y
//        }

//        if(currentItem !== undefined) {
//            var tmp_x = rootItem.mapToItem(currentItem, mouseX, mouseY).x
//            var tmp_y = rootItem.mapToItem(currentItem, mouseX, mouseY).y

//            if(!currentItem.containsPoint(tmp_x, tmp_y)) {
//                currentItem.hide()
//                currentItem = undefined
//            }
//        }
    }

    function mouseReleased(obj, mouseX, mouseY) {

    }

    function openWalletFromFile(){
        persistentSettings.restore_height = 0
        persistentSettings.is_recovering = false
        appWindow.password = ""
        fileDialog.open();
    }

    function initialize() {
        console.log("initializing..")

        // setup language
        var locale = persistentSettings.locale
        if (locale !== "") {
            translationManager.setLanguage(locale.split("_")[0]);
        }

        middlePanel.paymentClicked.connect(handlePayment);
        // basicPanel.paymentClicked.connect(handlePayment);

        // currentWallet is defined on daemon address change - close/reopen
        // TODO: strict comparison here (!==) causes crash after passwordDialog on previously crashed unsynced wallets
        if (currentWallet != undefined) {
            console.log("closing currentWallet")
            walletManager.closeWallet(currentWallet);
        } else {

            // set page to transfer if not changing daemon
            middlePanel.state = "Transfer";
            leftPanel.selectItem(middlePanel.state)

        }

        // wallet already opened with wizard, we just need to initialize it
        if (typeof wizard.settings['wallet'] !== 'undefined') {
            console.log("using wizard wallet")
            //Set restoreHeight
            if(persistentSettings.restore_height > 0){
                restoreHeight = persistentSettings.restore_height
            }

            connectWallet(wizard.settings['wallet'])

            isNewWallet = true
            // We don't need the wizard wallet any more - delete to avoid conflict with daemon adress change
            delete wizard.settings['wallet']
        }  else {
            var wallet_path = walletPath();
            // console.log("opening wallet at: ", wallet_path, "with password: ", appWindow.password);
            console.log("opening wallet at: ", wallet_path, ", testnet: ", persistentSettings.testnet);
            walletManager.openWalletAsync(wallet_path, appWindow.password,
                                              persistentSettings.testnet);
        }

    }


    function connectWallet(wallet) {
        showProcessingSplash()
        currentWallet = wallet
        currentWallet.refreshed.connect(onWalletRefresh)
        currentWallet.updated.connect(onWalletUpdate)
        currentWallet.newBlock.connect(onWalletNewBlock)
        currentWallet.moneySpent.connect(onWalletMoneySent)
        currentWallet.moneyReceived.connect(onWalletMoneyReceived)
        console.log("initializing with daemon address: ", persistentSettings.daemon_address)
        console.log("Recovering from seed: ", persistentSettings.is_recovering)
        console.log("restore Height", persistentSettings.restore_height)
        currentWallet.initAsync(persistentSettings.daemon_address, 0, persistentSettings.is_recovering, persistentSettings.restore_height);
    }

    function walletPath() {
        var wallet_path = persistentSettings.wallet_path
        return wallet_path;
    }

    function onWalletOpened(wallet) {
        console.log(">>> wallet opened: " + wallet)
        if (wallet.status !== Wallet.Status_Ok) {
            if (appWindow.password === '') {
                console.error("Error opening wallet with empty password: ", wallet.errorString);
                console.log("closing wallet async : " + wallet.address)
                walletManager.closeWalletAsync(wallet)
                // try to open wallet with password;
                passwordDialog.open();
            } else {
                // opening with password but password doesn't match
                console.error("Error opening wallet with password: ", wallet.errorString);

                informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                informationPopup.text = qsTr("Couldn't open wallet: ") + wallet.errorString;
                informationPopup.icon = StandardIcon.Critical
                console.log("closing wallet async : " + wallet.address)
                walletManager.closeWalletAsync(wallet);
                informationPopup.open()
                informationPopup.onCloseCallback = function() {
                    passwordDialog.open()
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
    }

    function onWalletRefresh() {
        console.log(">>> wallet refreshed")
        if (splash.visible) {
            hideProcessingSplash()
        }
        var dCurrentBlock = currentWallet.daemonBlockChainHeight();
        var dTargetBlock = currentWallet.daemonBlockChainTargetHeight();
        leftPanel.daemonProgress.updateProgress(dCurrentBlock,dTargetBlock);

        // Store wallet after every refresh.
        if (currentWallet.blockChainHeight() > 1){

            //TODO: Doesn't need path after creation. Change libwalletqt
            currentWallet.store("")
            console.log("Saving wallet");

            // recovering from seed is finished after first refresh
            if(persistentSettings.is_recovering) {
                persistentSettings.is_recovering = false
            }
        }

        isNewWallet = false

        // initialize transaction history once wallet is initializef first time;
        if (!walletInitialized) {
            currentWallet.history.refresh()
            walletInitialized = true
        }

        leftPanel.networkStatus.connected = currentWallet.connected

        onWalletUpdate();
    }

    function onWalletNewBlock(blockHeight) {
        if (splash.visible) {
            var currHeight = blockHeight

            //fast refresh until restoreHeight is reached
            var increment = ((restoreHeight == 0) || currHeight < restoreHeight)? 1000 : 10

            if(currHeight > splashCounter + increment){
              splashCounter = currHeight
              var locale = Qt.locale()
              var currHeightString = currHeight.toLocaleString(locale,"f",0)
              var targetHeightString = currentWallet.daemonBlockChainHeight().toLocaleString(locale,"f",0)
              var progressText = qsTr("Synchronizing blocks %1 / %2").arg(currHeightString).arg(targetHeightString);
              console.log("Progress text: " + progressText);
              splash.heightProgressText = progressText
            }
        }
    }

    function onWalletMoneyReceived(txId, amount) {
        // refresh transaction history here
        currentWallet.refresh()
        currentWallet.history.refresh() // this will refresh model
    }

    function onWalletMoneySent(txId, amount) {
        // refresh transaction history here
        currentWallet.refresh()
        currentWallet.history.refresh() // this will refresh model
    }



    function walletsFound() {
        if (persistentSettings.wallet_path.length > 0) {
            var lastOpenedExists = walletManager.walletExists(persistentSettings.wallet_path);
            if (lastOpenedExists) {
                console.log("Last opened wallet exists in:",persistentSettings.wallet_path)
            }
         }

        // Check if wallets exists in default path
        var wallets = walletManager.findWallets(moneroAccountsDir);
        if (wallets.length === 0) {
            wallets = walletManager.findWallets(applicationDirectory);
        }
        return (wallets.length > 0 || lastOpenedExists);
    }




    // called on "transfer"
    function handlePayment(address, paymentId, amount, mixinCount, priority) {
        console.log("Creating transaction: ")
        console.log("\taddress: ", address,
                    ", payment_id: ", paymentId,
                    ", amount: ", amount,
                    ", mixins: ", mixinCount,
                    ", priority: ", priority);


        // validate amount;
        var amountxmr = walletManager.amountFromString(amount);
        console.log("integer amount: ", amountxmr);
        console.log("integer unlocked",currentWallet.unlockedBalance)
        if (amountxmr <= 0) {
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
            informationPopup.title = qsTr("Error") + translationManager.emptyString;
            informationPopup.text  = qsTr("insufficient funds. Unlocked balance: %1")
                    .arg(walletManager.displayAmount(currentWallet.unlockedBalance))
                    + translationManager.emptyString

            informationPopup.icon  = StandardIcon.Critical
            informationPopup.onCloseCallback = null
            informationPopup.open()
            return;
        }

        // validate address;
        transaction = currentWallet.createTransaction(address, paymentId, amountxmr, mixinCount, priority);
        if (transaction.status !== PendingTransaction.Status_Ok) {
            console.error("Can't create transaction: ", transaction.errorString);
            informationPopup.title = qsTr("Error") + translationManager.emptyString;
            informationPopup.text  = qsTr("Can't create transaction: ") + transaction.errorString
            informationPopup.icon  = StandardIcon.Critical
            informationPopup.onCloseCallback = null
            informationPopup.open();
            // deleting transaction object, we don't want memleaks
            currentWallet.disposeTransaction(transaction);

        } else {
            console.log("Transaction created, amount: " + walletManager.displayAmount(transaction.amount)
                    + ", fee: " + walletManager.displayAmount(transaction.fee));

            // here we show confirmation popup;

            transactionConfirmationPopup.title = qsTr("Confirmation") + translationManager.emptyString
            transactionConfirmationPopup.text  = qsTr("Please confirm transaction:\n\n")
                        + qsTr("\nAddress: ") + address
                        + qsTr("\nPayment ID: ") + paymentId
                        + qsTr("\nAmount: ") + walletManager.displayAmount(transaction.amount)
                        + qsTr("\nFee: ") + walletManager.displayAmount(transaction.fee)
                        + translationManager.emptyString
            transactionConfirmationPopup.icon = StandardIcon.Question
            transactionConfirmationPopup.open()
            // committing transaction
        }
    }

    // called after user confirms transaction
    function handleTransactionConfirmed() {
        if (!transaction.commit()) {
            console.log("Error committing transaction: " + transaction.errorString);
            informationPopup.title = qsTr("Error") + translationManager.emptyString
            informationPopup.text  = qsTr("Couldn't send the money: ") + transaction.errorString
            informationPopup.icon  = StandardIcon.Critical
        } else {
            informationPopup.title = qsTr("Information") + translationManager.emptyString
            informationPopup.text  = qsTr("Money sent successfully") + translationManager.emptyString
            informationPopup.icon  = StandardIcon.Information
        }
        informationPopup.onCloseCallback = null
        informationPopup.open()
        currentWallet.refresh()
        currentWallet.disposeTransaction(transaction)
    }

    // blocks UI if wallet can't be opened or no connection to the daemon
    function enableUI(enable) {
        middlePanel.enabled = enable;
        leftPanel.enabled = enable;
        rightPanel.enabled = enable;
        // basicPanel.enabled = enable;
    }

    function showProcessingSplash(message) {
        console.log("Displaying processing splash")
        if (typeof message != 'undefined') {
            splash.message = message
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
        splashCounter = 0;
        // we can't close async here. Gui crashes if wallet is open
        walletManager.closeWallet(currentWallet);
        wizard.restart();
        rootItem.state = "wizard"

    }


    objectName: "appWindow"
    visible: true
    width: rightPanelExpanded ? 1269 : 1269 - 300
    height: 800
    color: "#FFFFFF"
    flags: Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint
    onWidthChanged: x -= 0


    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
        //
        walletManager.walletOpened.connect(onWalletOpened);
        walletManager.walletClosed.connect(onWalletClosed);

        if(!walletsFound()) {
            rootItem.state = "wizard"
        } else {
            rootItem.state = "normal"
                initialize(persistentSettings);
        }

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
        property bool   auto_donations_enabled : true
        property int    auto_donations_amount : 50
        property bool   allow_background_mining : true
        property bool   testnet: true
        property string daemon_address: "localhost:38081"
        property string payment_id
        property int    restore_height : 0
        property bool   is_recovering : false
    }

    // TODO: replace with customized popups

    // Information dialog
    MessageDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: informationPopup
        standardButtons: StandardButton.Ok
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    // Confrirmation aka question dialog
    MessageDialog {
        id: transactionConfirmationPopup
        standardButtons: StandardButton.Ok  + StandardButton.Cancel
        onAccepted: {
            handleTransactionConfirmed()
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
        standardButtons: StandardButton.Ok  + StandardButton.Cancel
        onAccepted: {
            appWindow.currentWallet = null
            appWindow.initialize();
        }
        onRejected: {
            //appWindow.enableUI(false)
            rootItem.state = "wizard"
        }
        onDiscard: {
            appWindow.enableUI(false)
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
                PropertyChanges { target: appWindow; width: 930; }
                PropertyChanges { target: appWindow; height: 595; }
                PropertyChanges { target: resizeArea; visible: false }
                PropertyChanges { target: titleBar; maximizeButtonVisible: false }
                PropertyChanges { target: frameArea; blocked: true }
                PropertyChanges { target: titleBar; y: 0 }
                PropertyChanges { target: titleBar; title: qsTr("Program setup wizard") + translationManager.emptyString }
            }, State {
                name: "normal"
                PropertyChanges { target: leftPanel; visible: true }
                PropertyChanges { target: rightPanel; visible: true }
                PropertyChanges { target: middlePanel; visible: true }
                PropertyChanges { target: titleBar; basicButtonVisible: true }
                PropertyChanges { target: wizard; visible: false }
                PropertyChanges { target: appWindow; width: rightPanelExpanded ? 1269 : 1269 - 300; }
                PropertyChanges { target: appWindow; height: 800; }
                PropertyChanges { target: resizeArea; visible: true }
                PropertyChanges { target: titleBar; maximizeButtonVisible: true }
                PropertyChanges { target: frameArea; blocked: false }
                PropertyChanges { target: titleBar; y: -titleBar.height }
                PropertyChanges { target: titleBar; title: qsTr("Monero") + translationManager.emptyString }
            }
        ]

        LeftPanel {
            id: leftPanel
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: parent.height
            onDashboardClicked: middlePanel.state = "Dashboard"
            onHistoryClicked: middlePanel.state = "History"
            onTransferClicked: middlePanel.state = "Transfer"
            onReceiveClicked: middlePanel.state = "Receive"
            onAddressBookClicked: middlePanel.state = "AddressBook"
            onMiningClicked: middlePanel.state = "Minning"
            onSettingsClicked: middlePanel.state = "Settings"
        }

        RightPanel {
            id: rightPanel
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height
            width: appWindow.rightPanelExpanded ? 300 : 0
            visible: appWindow.rightPanelExpanded
        }


        MiddlePanel {
            id: middlePanel
            anchors.bottom: parent.bottom
            anchors.left: leftPanel.visible ?  leftPanel.right : parent.left
            anchors.right: rightPanel.left
            height: parent.height
            state: "Transfer"
        }

        TipItem {
            id: tipItem
            text: qsTr("send to the same destination") + translationManager.emptyString
            visible: false
        }

        MouseArea {
            id: frameArea
            property bool blocked: false
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            z: 1
            hoverEnabled: true
            onEntered: if(!blocked) titleBar.y = 0
            onExited: if(!blocked) titleBar.y = -titleBar.height
            propagateComposedEvents: true
            onPressed: mouse.accepted = false
            onReleased: mouse.accepted = false
            onMouseXChanged: titleBar.mouseX = mouseX
            onContainsMouseChanged: titleBar.containsMouse = containsMouse
        }

        SequentialAnimation {
            id: goToBasicAnimation
            PropertyAction {
                target: appWindow
                properties: "visibility"
                value: Window.Windowed
            }
            PropertyAction {
                target: titleBar
                properties: "maximizeButtonVisible"
                value: false
            }
            PropertyAction {
                target: frameArea
                properties: "blocked"
                value: true
            }
            PropertyAction {
                target: resizeArea
                properties: "visible"
                value: false
            }
            NumberAnimation {
                target: appWindow
                properties: "height"
                to: 30
                easing.type: Easing.InCubic
                duration: 200
            }
            NumberAnimation {
                target: appWindow
                properties: "width"
                to: 470
                easing.type: Easing.InCubic
                duration: 200
            }
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

            NumberAnimation {
                target: appWindow
                properties: "height"
                to: middlePanel.height
                easing.type: Easing.InCubic
                duration: 200
            }

            onStopped: {
                // middlePanel.visible = false
                rightPanel.visible = false
                leftPanel.visible = false
            }
        }

        SequentialAnimation {
            id: goToProAnimation
            NumberAnimation {
                target: appWindow
                properties: "height"
                to: 30
                easing.type: Easing.InCubic
                duration: 200
            }
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
            NumberAnimation {
                target: appWindow
                properties: "width"
                to: rightPanelExpanded ? 1269 : 1269 - 300
                easing.type: Easing.InCubic
                duration: 200
            }
            NumberAnimation {
                target: appWindow
                properties: "height"
                to: 800
                easing.type: Easing.InCubic
                duration: 200
            }
            PropertyAction {
                target: frameArea
                properties: "blocked"
                value: false
            }
            PropertyAction {
                target: titleBar
                properties: "maximizeButtonVisible"
                value: true
            }
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

        property int maxWidth: leftPanel.width + 655 + rightPanel.width
        property int maxHeight: 700
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

                if(appWindow.width - dx > parent.maxWidth)
                    appWindow.width -= dx
                else appWindow.width = parent.maxWidth

                if(appWindow.height - dy > parent.maxHeight)
                    appWindow.height -= dy
                else appWindow.height = parent.maxHeight
                previousPosition = pos
            }
        }

        TitleBar {
            id: titleBar
            anchors.left: parent.left
            anchors.right: parent.right
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
    }
    onClosing: {
       //walletManager.closeWallet(currentWallet);
    }
}
