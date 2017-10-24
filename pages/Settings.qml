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

import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../version.js" as Version


import "../components"
import moneroComponents.Clipboard 1.0

Rectangle {
    property var daemonAddress
    property bool viewOnly: false
    id: page

    color: "#F0EEEE"

    Clipboard { id: clipboard }

    function initSettings() {
        //runs on every page load

        // Daemon settings
        daemonAddress = persistentSettings.daemon_address.split(":");
        console.log("address: " + persistentSettings.daemon_address)
        // try connecting to daemon
    }

    ColumnLayout {
        id: mainLayout
        anchors.margins: 17
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 10

        //! Manage wallet
        RowLayout {
            Label {
                id: manageWalletLabel
                Layout.fillWidth: true
                color: "#4A4949"
                text: qsTr("Manage wallet") + translationManager.emptyString
                fontSize: 16
                Layout.topMargin: 10
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        GridLayout {
            columns: (isMobile)? 2 : 4
            StandardButton {
                id: closeWalletButton
                text: qsTr("Close wallet") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                visible: true
                onClicked: {
                    console.log("closing wallet button clicked")
                    appWindow.showWizard();
                }
            }

            StandardButton {
                enabled: !viewOnly
                id: createViewOnlyWalletButton
                text: qsTr("Create view only wallet") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                visible: true
                onClicked: {
                    wizard.openCreateViewOnlyWalletPage();
                }
            }

            StandardButton {
                id: showSeedButton
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Show seed & keys") + translationManager.emptyString
                onClicked: {
                    settingsPasswordDialog.open();
                }
            }

/*          Rescan cache - Disabled until we know it's needed

            StandardButton {
                id: rescanWalletbutton
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Rescan wallet cache") + translationManager.emptyString
                onClicked: {
                    // Show confirmation dialog
                    confirmationDialog.title = qsTr("Rescan wallet cache") + translationManager.emptyString;
                    confirmationDialog.text  = qsTr("Are you sure you want to rebuild the wallet cache?\n"
                                                    + "The following information will be deleted\n"
                                                    + "- Recipient addresses\n"
                                                    + "- Tx keys\n"
                                                    + "- Tx descriptions\n\n"
                                                    + "The old wallet cache file will be renamed and can be restored later.\n"
                                                    );
                    confirmationDialog.icon = StandardIcon.Question
                    confirmationDialog.cancelText = qsTr("Cancel")
                    confirmationDialog.onAcceptedCallback = function() {
                        walletManager.closeWallet();
                        walletManager.clearWalletCache(persistentSettings.wallet_path);
                        walletManager.openWalletAsync(persistentSettings.wallet_path, appWindow.password,
                                                          persistentSettings.testnet);
                    }

                    confirmationDialog.onRejectedCallback = null;

                    confirmationDialog.open()

                }
            }
*/
            StandardButton {
                id: rescanSpentButton
                text: qsTr("Rescan wallet balance") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    if (!currentWallet.rescanSpent()) {
                        console.error("Error: ", currentWallet.errorString);
                        informationPopup.title = qsTr("Error") + translationManager.emptyString;
                        informationPopup.text  = qsTr("Error: ") + currentWallet.errorString
                        informationPopup.icon  = StandardIcon.Critical
                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    } else {
                        informationPopup.title = qsTr("Information") + translationManager.emptyString
                        informationPopup.text  = qsTr("Sucessfully rescanned spent outputs") + translationManager.emptyString
                        informationPopup.icon  = StandardIcon.Information
                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    }
                }
            }
        }

        //! Manage daemon
        RowLayout {
            Label {
                id: manageDaemonLabel
                Layout.fillWidth: true
                color: "#4A4949"
                text: qsTr("Manage daemon") + translationManager.emptyString
                fontSize: 16
                anchors.topMargin: 30
                Layout.topMargin: 30
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        GridLayout {
            id: daemonStatusRow
            columns: (isMobile) ?  2 : 4
            StandardButton {
                visible: true
                enabled: !appWindow.daemonRunning
                id: startDaemonButton
                text: qsTr("Start daemon") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    appWindow.startDaemon(daemonFlags.text)
                }
            }

            StandardButton {
                visible: true
                enabled: appWindow.daemonRunning
                id: stopDaemonButton
                text: qsTr("Stop daemon") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    appWindow.stopDaemon()
                }
            }

            StandardButton {
                visible: true
                id: daemonStatusButton
                text: qsTr("Show status") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    daemonManager.sendCommand("status",currentWallet.testnet);
                    daemonConsolePopup.open();
                }
            }

        }

        RowLayout {
            id: blockchainFolderRow
            Label {
                id: blockchainFolderLabel
                color: "#4A4949"
                text: qsTr("Blockchain location") + translationManager.emptyString
                fontSize: 16
            }
            LineEdit {
                id: blockchainFolder
                Layout.preferredWidth:  200
                Layout.fillWidth: true
                text: persistentSettings.blockchainDataDir
                placeholderText: qsTr("(optional)") + translationManager.emptyString

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mouse.accepted = false
                        if(persistentSettings.blockchainDataDir != "")
                            blockchainFileDialog.folder = "file://" + persistentSettings.blockchainDataDir
                        blockchainFileDialog.open()
                        blockchainFolder.focus = true
                    }
                }

            }
        }

        RowLayout {
            id: daemonFlagsRow
            Label {
                id: daemonFlagsLabel
                color: "#4A4949"
                text: qsTr("Daemon startup flags") + translationManager.emptyString
                fontSize: 16
            }
            LineEdit {
                id: daemonFlags
                Layout.preferredWidth:  200
                Layout.fillWidth: true
                text: appWindow.persistentSettings.daemonFlags;
                placeholderText: qsTr("(optional)") + translationManager.emptyString
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                id: daemonAddrLabel
                Layout.fillWidth: true
                color: "#4A4949"
                text: qsTr("Daemon address") + translationManager.emptyString
                fontSize: 16
            }
        }

        GridLayout {
            id: daemonAddrRow
            Layout.fillWidth: true
            columnSpacing: 10
            columns: (isMobile) ?  2 : 3

            LineEdit {
                id: daemonAddr
                Layout.preferredWidth:  100
                Layout.fillWidth: true
                text: (daemonAddress !== undefined) ? daemonAddress[0] : ""
                placeholderText: qsTr("Hostname / IP") + translationManager.emptyString
            }


            LineEdit {
                id: daemonPort
                Layout.preferredWidth: 100
                Layout.fillWidth: true
                text: (daemonAddress !== undefined) ? daemonAddress[1] : "18081"
                placeholderText: qsTr("Port") + translationManager.emptyString
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Label {
                id: daemonLoginLabel
                Layout.fillWidth: true
                color: "#4A4949"
                text: qsTr("Login (optional)") + translationManager.emptyString
                fontSize: 16
            }

        }

        RowLayout {

            LineEdit {
                id: daemonUsername
                Layout.preferredWidth:  100
                Layout.fillWidth: true
                text: persistentSettings.daemonUsername
                placeholderText: qsTr("Username") + translationManager.emptyString
            }


            LineEdit {
                id: daemonPassword
                Layout.preferredWidth: 100
                Layout.fillWidth: true
                text: persistentSettings.daemonPassword
                placeholderText: qsTr("Password") + translationManager.emptyString
                echoMode: TextInput.Password
            }

            StandardButton {
                id: daemonAddrSave
                Layout.fillWidth: false
                Layout.leftMargin: 30
                text: qsTr("Connect") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    console.log("saving daemon adress settings")
                    var newDaemon = daemonAddr.text.trim() + ":" + daemonPort.text.trim()
                    if(persistentSettings.daemon_address != newDaemon) {
                        persistentSettings.daemon_address = newDaemon
                    }

                    // Update daemon login
                    persistentSettings.daemonUsername = daemonUsername.text;
                    persistentSettings.daemonPassword = daemonPassword.text;
                    currentWallet.setDaemonLogin(persistentSettings.daemonUsername, persistentSettings.daemonPassword);

                    //Reinit wallet
                    currentWallet.initAsync(newDaemon);
                }
            }
        }

        RowLayout {
            Label {
                color: "#4A4949"
                text: qsTr("Layout settings") + translationManager.emptyString
                fontSize: 16
                anchors.topMargin: 30
                Layout.topMargin: 30
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        RowLayout {
            CheckBox {
                id: customDecorationsCheckBox
                checked: persistentSettings.customDecorations
                onClicked: appWindow.setCustomWindowDecorations(checked)
                text: qsTr("Custom decorations") + translationManager.emptyString
                checkedIcon: "../images/checkedVioletIcon.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
            }
        }

        // Log level

        RowLayout {
            Label {
                color: "#4A4949"
                text: qsTr("Log level") + translationManager.emptyString
                fontSize: 16
                anchors.topMargin: 30
                Layout.topMargin: 30
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }
        ColumnLayout {
            ComboBox {
                id: logLevel
                model: [0,1,2,3,4,"custom"]
                currentIndex : appWindow.persistentSettings.logLevel;
                onCurrentIndexChanged: {
                    if (currentIndex == 5) {
                        console.log("log categories changed: ", logCategories.text);
                        walletManager.setLogCategories(logCategories.text);
                    }
                    else {
                        console.log("log level changed: ",currentIndex);
                        walletManager.setLogLevel(currentIndex);
                    }
                    appWindow.persistentSettings.logLevel = currentIndex;
                }
            }

            LineEdit {
                id: logCategories
                Layout.preferredWidth:  200
                Layout.fillWidth: true
                text: appWindow.persistentSettings.logCategories
                placeholderText: qsTr("(e.g. *:WARNING,net.p2p:DEBUG)") + translationManager.emptyString
                enabled: logLevel.currentIndex == 5
                onEditingFinished: {
                    if(enabled) {
                        console.log("log categories changed: ", text);
                        walletManager.setLogCategories(text);
                        appWindow.persistentSettings.logCategories = text;
                    }
                }
            }
        }

        // Version
        RowLayout {
            Label {
                color: "#4A4949"
                text: qsTr("Debug info") + translationManager.emptyString
                fontSize: 16
                anchors.topMargin: 30
                Layout.topMargin: 30
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        TextBlock {
            Layout.topMargin: 8
            Layout.fillWidth: true
            text: qsTr("GUI version: ") + Version.GUI_VERSION + translationManager.emptyString
        }

        TextBlock {
            id: guiMoneroVersion
            Layout.fillWidth: true
            text: qsTr("Embedded Monero version: ") + Version.GUI_MONERO_VERSION + translationManager.emptyString
        }
        TextBlock {
            id: restoreHeightText
            Layout.fillWidth: true
            textFormat: Text.RichText
            property var txt: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C}</style>" + qsTr("Wallet creation height: ") + currentWallet.walletCreationHeight + translationManager.emptyString
            property var linkTxt: qsTr(" <a href='#'>(Click to change)</a>") + translationManager.emptyString
            text: (typeof currentWallet == "undefined") ? "" : txt + linkTxt

            onLinkActivated: {
                restoreHeightRow.visible = true;
            }

        }

        RowLayout {
            id: restoreHeightRow
            visible: false
            LineEdit {
                id: restoreHeight
                Layout.preferredWidth: 80
                Layout.fillWidth: true
                text: currentWallet.walletCreationHeight
                validator: IntValidator {
                    bottom:0
                }
            }

            StandardButton {
                id: restoreHeightSave
                Layout.fillWidth: false
                Layout.leftMargin: 30
                text: qsTr("Save") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"

                onClicked: {
                    currentWallet.walletCreationHeight = restoreHeight.text
                    // Restore height is saved in .keys file. Set password to trigger rewrite.
                    currentWallet.setPassword(appWindow.password)
                    restoreHeightRow.visible = false

                    // Show confirmation dialog
                    confirmationDialog.title = qsTr("Rescan wallet cache") + translationManager.emptyString;
                    confirmationDialog.text  = qsTr("Are you sure you want to rebuild the wallet cache?\n"
                                                    + "The following information will be deleted\n"
                                                    + "- Recipient addresses\n"
                                                    + "- Tx keys\n"
                                                    + "- Tx descriptions\n\n"
                                                    + "The old wallet cache file will be renamed and can be restored later.\n"
                                                    );
                    confirmationDialog.icon = StandardIcon.Question
                    confirmationDialog.cancelText = qsTr("Cancel")
                    confirmationDialog.onAcceptedCallback = function() {
                        walletManager.closeWallet();
                        walletManager.clearWalletCache(persistentSettings.wallet_path);
                        walletManager.openWalletAsync(persistentSettings.wallet_path, appWindow.password,
                                                          persistentSettings.testnet);
                    }

                    confirmationDialog.onRejectedCallback = null;

                    confirmationDialog.open()

                }
            }
        }



        TextBlock {
            Layout.fillWidth: true
            text:  (typeof currentWallet == "undefined") ? "" : qsTr("Wallet log path: ") + currentWallet.walletLogPath + translationManager.emptyString
        }
        TextBlock {
            Layout.fillWidth: true
            text:  (typeof currentWallet == "undefined") ? "" : qsTr("Daemon log path: ") + currentWallet.daemonLogPath + translationManager.emptyString
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

    PasswordDialog {
        id: settingsPasswordDialog

        onAccepted: {
            if(appWindow.password === settingsPasswordDialog.password){
                if(currentWallet.seedLanguage == "") {
                    console.log("No seed language set. Using English as default");
                    currentWallet.setSeedLanguage("English");
                }

                seedPopup.title  = qsTr("Wallet seed & keys") + translationManager.emptyString;
                seedPopup.text = "<b>Wallet Mnemonic seed</b> <br>" + currentWallet.seed
                        + "<br><br> <b>" + qsTr("Secret view key") + ":</b> " + currentWallet.secretViewKey
                        + "<br><b>" + qsTr("Public view key") + ":</b> " + currentWallet.publicViewKey
                        + "<br><b>" + qsTr("Secret spend key") + ":</b> " + currentWallet.secretSpendKey
                        + "<br><b>" + qsTr("Public spend key") + ":</b> " + currentWallet.publicSpendKey
                seedPopup.open()
                seedPopup.width = 600
                seedPopup.height = 300
                seedPopup.onCloseCallback = function() {
                    seedPopup.text = ""
                }

            } else {
                informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                informationPopup.text = qsTr("Wrong password");
                informationPopup.open()
                informationPopup.onCloseCallback = function() {
                    settingsPasswordDialog.open()
                }
            }

            settingsPasswordDialog.password = ""
        }
        onRejected: {

        }

    }

    StandardDialog {
        id: seedPopup
        cancelVisible: false
        okVisible: true
        width:600
        height:400

        property var onCloseCallback
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    // Choose blockchain folder
    FileDialog {
        id: blockchainFileDialog
        title: qsTr("Please choose a folder") + translationManager.emptyString;
        selectFolder: true
        folder: "file://" + persistentSettings.blockchainDataDir

        onAccepted: {
            var dataDir = walletManager.urlToLocalPath(blockchainFileDialog.fileUrl)
            var validator = daemonManager.validateDataDir(dataDir);
            if(!validator.valid) {

                confirmationDialog.title = qsTr("Warning") + translationManager.emptyString;
                confirmationDialog.text = "";
                if(validator.readOnly) {
                    confirmationDialog.text  += qsTr("Error: Filesystem is read only") + "\n\n"                  
                }
                
                if(validator.storageAvailable < 20) {
                    confirmationDialog.text  += qsTr("Warning: There's only %1 GB available on the device. Blockchain requires ~%2 GB of data.").arg(validator.storageAvailable).arg(15) + "\n\n"     
                } else {
                    confirmationDialog.text  += qsTr("Note: There's %1 GB available on the device. Blockchain requires ~%2 GB of data.").arg(validator.storageAvailable).arg(15) + "\n\n"
                }
                
                if(!validator.lmdbExists) {
                    confirmationDialog.text  += qsTr("Note: lmdb folder not found. A new folder will be created.") + "\n\n" 
                }
   

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

    // fires on every page load
    function onPageCompleted() {
        console.log("Settings page loaded");
        initSettings();
        viewOnly = currentWallet.viewOnly;

        if(typeof daemonManager != "undefined")
            appWindow.daemonRunning =  daemonManager.running(persistentSettings.testnet)
    }

    // fires only once
    Component.onCompleted: {
        if(typeof daemonManager != "undefined")
            daemonManager.daemonConsoleUpdated.connect(onDaemonConsoleUpdated)


    }

    function onDaemonConsoleUpdated(message){
        // Update daemon console
        daemonConsolePopup.textArea.append(message)
    }




}




