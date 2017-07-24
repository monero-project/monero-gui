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

        if(persistentSettings.lightWallet)
            walletTypeDropdown.currentIndex = 1
        else
            walletTypeDropdown.currentIndex = 0

        walletTypeDropdown.update()
    }

    ColumnLayout {
        id: mainLayout
        anchors.margins: 17 * scaleRatio
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 10 * scaleRatio

        //! Manage wallet
        RowLayout {
            Label {
                id: manageWalletLabel
                Layout.fillWidth: true
                color: "#4A4949"
                text: qsTr("Manage wallet") + translationManager.emptyString
                Layout.topMargin: 10 * scaleRatio
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        GridLayout {
            columns: (isMobile)? 1 : 4
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
                enabled: !persistentSettings.useRemoteNode && !persistentSettings.lightWallet
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

        // Wallet type dropdown
        RowLayout {
            Label {
                id: walletTypeLabel
                color: "#4A4949"
                text: qsTr("Wallet type") + translationManager.emptyString
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        ListModel {
             id: walletTypeModel

             ListElement { column1: qsTr("Full") ; column2: ""; type: "full"}
             ListElement { column1: qsTr("Light") ; column2: ""; type: "light" }

         }

        StandardDropdown {
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Layout.maximumWidth: 300
            id: walletTypeDropdown
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            z: parent.z + 1
            dataModel: walletTypeModel
            onChanged: {
                console.log("wallet type: ", walletTypeModel.get(walletTypeDropdown.currentIndex).type)
                console.log(walletTypeDropdown.currentIndex);

                // Enable Light Wallet
                if(!persistentSettings.lightWallet) {
                    console.log("enabling lightwallet");
                    confirmationDialog.title = qsTr("Warning") + translationManager.emptyString;
                    confirmationDialog.text = qsTr("Your view key will be sent to the light wallet server") + translationManager.emptyString;

                    confirmationDialog.icon = StandardIcon.Question
                    confirmationDialog.cancelText = qsTr("Cancel")

                    // Continue
                    confirmationDialog.onAcceptedCallback = function() {
                        appWindow.connectLightWallet()
                        walletTypeDropdown.currentIndex = 1
                    }

                    // Cancel
                    confirmationDialog.onRejectedCallback = function() {
                        persistentSettings.lightWallet = false
                        walletTypeDropdown.currentIndex = 0
                    };

                    confirmationDialog.open()

                // Disable light wallet
                } else {
                    appWindow.disconnectRemoteNode()
                }

            }
        }

        RowLayout {

            StandardButton {
                visible: !persistentSettings.lightWallet
                id: remoteDisconnect
                enabled: persistentSettings.useRemoteNode
                Layout.fillWidth: false
                text: qsTr("Local Node") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    appWindow.disconnectRemoteNode();
                }
            }

            StandardButton {
                visible: !persistentSettings.lightWallet
                id: remoteConnect
                enabled: !persistentSettings.useRemoteNode
                Layout.fillWidth: false
                text: qsTr("Remote Node") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    appWindow.connectRemoteNode();
                }
            }
        }

        //! Manage daemon
        RowLayout {
            visible: !isMobile
            Layout.topMargin: 20
            Label {
                id: manageDaemonLabel
                color: "#4A4949"
                text: qsTr("Manage Daemon") + translationManager.emptyString
            }

            CheckBox {
                id: daemonAdvanced
                Layout.leftMargin: 15
                text: qsTr("Show advanced") + translationManager.emptyString
                checkedIcon: "../images/checkedVioletIcon.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        GridLayout {
            visible: !isMobile
            id: daemonStatusRow
            columns: (isMobile) ?  2 : 4
            StandardButton {
                visible: !appWindow.daemonRunning
                id: startDaemonButton
                text: qsTr("Start Local Node") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    // Reset default daemon address settings
                    persistentSettings.daemon_address = (persistentSettings.testnet) ? "localhost:28081" :  "localhost:18081"
                    initSettings()
                    appWindow.startDaemon(daemonFlags.text)
                }
            }

            StandardButton {
                visible: appWindow.daemonRunning
                id: stopDaemonButton
                text: qsTr("Stop Local Node") + translationManager.emptyString
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

        ColumnLayout {
            id: blockchainFolderRow
            visible: !isMobile
            Label {
                id: blockchainFolderLabel
                color: "#4A4949"
                text: qsTr("Blockchain location") + translationManager.emptyString
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
            visible: daemonAdvanced.checked && !isMobile
            id: daemonFlagsRow
            Label {
                id: daemonFlagsLabel
                color: "#4A4949"
                text: qsTr("Local daemon startup flags") + translationManager.emptyString
            }
            LineEdit {
                id: daemonFlags
                Layout.preferredWidth:  200
                Layout.fillWidth: true
                text: appWindow.persistentSettings.daemonFlags;
                placeholderText: qsTr("(optional)") + translationManager.emptyString
            }
        }


//        RowLayout {
//            id: daemonAddrRow
//            Layout.fillWidth: true
//            spacing: 10

//            Label {
//                id: daemonAddrLabel
//                Layout.fillWidth: true
//                color: "#4A4949"
//                text: qsTr("Daemon address") + translationManager.emptyString
//            }
//        }


        RowLayout {
            Layout.fillWidth: true
            visible: daemonAdvanced.checked || isMobile
            Label {
                id: daemonLoginLabel
                Layout.fillWidth: true
                color: "#4A4949"
                text: qsTr("Node login (optional)") + translationManager.emptyString
            }

        }

        ColumnLayout {
            visible: daemonAdvanced.checked || isMobile
            LineEdit {
                id: daemonUsername
                Layout.preferredWidth:  100 * scaleRatio
                Layout.fillWidth: true
                text: persistentSettings.daemonUsername
                placeholderText: qsTr("Username") + translationManager.emptyString
            }


            LineEdit {
                id: daemonPassword
                Layout.preferredWidth: 100 * scaleRatio
                Layout.fillWidth: true
                text: persistentSettings.daemonPassword
                placeholderText: qsTr("Password") + translationManager.emptyString
                echoMode: TextInput.Password
            }
        }

        RowLayout {

            ColumnLayout {
                Label {
                    color: "#4A4949"
                    text: qsTr("Remote node") + translationManager.emptyString
                }
                RemoteNodeEdit {
                    id: remoteNodeEdit
                    visible: !persistentSettings.lightWallet
                    Layout.minimumWidth: 100 * scaleRatio
                    daemonAddrText: persistentSettings.remoteNodeAddress.split(":")[0]
                    daemonPortText: (persistentSettings.remoteNodeAddress.split(":")[1] == "") ? "18081" : persistentSettings.remoteNodeAddress.split(":")[1]
                    onEditingFinished: {
                        persistentSettings.remoteNodeAddress = remoteNodeEdit.getAddress();
                        console.log("setting remote node to " + persistentSettings.remoteNodeAddress)
                    }
                }

                StandardButton {
                    id: remoteNodeSave
                    text: qsTr("Connect") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    onClicked: {
                        // Update daemon login
                        persistentSettings.remoteNodeAddress = remoteNodeEdit.getAddress();
                        persistentSettings.daemonUsername = daemonUsername.text;
                        persistentSettings.daemonPassword = daemonPassword.text;
                        persistentSettings.useRemoteNode = true

                        currentWallet.setDaemonLogin(persistentSettings.daemonUsername, persistentSettings.daemonPassword);

                        appWindow.connectRemoteNode()
                    }
                }
            }
        }

        RowLayout {

            ColumnLayout {
                Label {
                    color: "#4A4949"
                    text: qsTr("Light Wallet server") + translationManager.emptyString
                }
                RemoteNodeEdit {
                    visible: persistentSettings.lightWallet
                    Layout.minimumWidth: 100 * scaleRatio
                    id: lightWalletServerEdit
                    daemonAddrText: persistentSettings.lightWalletServerAddress.split(":")[0]
                    daemonPortText: (persistentSettings.lightWalletServerAddress.split(":")[1] == "") ? "18081" : persistentSettings.lightWalletServerAddress.split(":")[1]
                    onEditingFinished: {
                        persistentSettings.lightWalletServerAddress = lightWalletServerEdit.getAddress();
                        console.log("setting remote node to " + persistentSettings.lightWalletServerAddress)
                    }
                }


                CheckBox {
                    id: useSSL
                    checked: persistentSettings.useSSL
                    onClicked: {
                        persistentSettings.useSSL = !persistentSettings.useSSL
                        currentWallet.setSSLMode(persistentSettings.useSSL)
                    }
                    text: qsTr("SSL") + translationManager.emptyString
                    checkedIcon: "../images/checkedVioletIcon.png"
                    uncheckedIcon: "../images/uncheckedIcon.png"
                }


                StandardButton {
                    id: lightWalletNodeSave
                    text: qsTr("Connect") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    onClicked: {
                        // Update daemon login
                        persistentSettings.lightWalletServerAddress = lightWalletServerEdit.getAddress();
                        appWindow.connectLightWallet()
                    }
                }
            }
        }


        RowLayout {
            visible: !isMobile
            Label {
                color: "#4A4949"
                text: qsTr("Layout settings") + translationManager.emptyString
                anchors.topMargin: 30 * scaleRatio
                Layout.topMargin: 30 * scaleRatio
            }
        }
        Rectangle {
            visible: !isMobile
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        RowLayout {
            CheckBox {
                visible: !isMobile
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
                anchors.topMargin: 30 * scaleRatio
                Layout.topMargin: 30 * scaleRatio
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
                text: qsTr("Version") + translationManager.emptyString
                anchors.topMargin: 30 * scaleRatio
                Layout.topMargin: 30 * scaleRatio
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }



        Text {
            id: guiVersion
            Layout.topMargin: 8 * scaleRatio
            color: "#4A4949"
            text: qsTr("GUI version: ") + Version.GUI_VERSION + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        Text {
            id: guiMoneroVersion
            color: "#4A4949"
            text: qsTr("Embedded Monero version: ") + Version.GUI_MONERO_VERSION + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
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

    StandardDialog {
        id: seedPopup
        cancelVisible: false
        okVisible: true

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




