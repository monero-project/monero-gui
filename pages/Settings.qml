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

import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../version.js" as Version
import "../js/Windows.js" as Windows
import "../js/Utils.js" as Utils


import "../components"
import moneroComponents.Clipboard 1.0

Rectangle {
    property bool viewOnly: false
    property alias settingsHeight: mainLayout.height
    id: page

    color: "transparent"

    // fires on every page load
    function onPageCompleted() {
        console.log("Settings page loaded");

        if(typeof daemonManager != "undefined"){
            appWindow.daemonRunning = persistentSettings.useRemoteNode ? false : daemonManager.running(persistentSettings.nettype);
        }

        logLevelDropdown.update()
    }

    Clipboard { id: clipboard }

    ColumnLayout {
        id: mainLayout
        anchors.margins: (isMobile)? 17 : 40
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 26 * scaleRatio

        //! Manage wallet
        RowLayout {
            Layout.fillWidth: true
            Label {
                id: manageWalletLabel
                fontSize: 22 * scaleRatio
                Layout.fillWidth: true
                text: qsTr("Manage wallet") + translationManager.emptyString
                Layout.topMargin: 10 * scaleRatio
            }

            Rectangle {
                anchors.top: manageWalletLabel.bottom
                anchors.topMargin: 4
                anchors.left: parent.left
                anchors.right: parent.right
                Layout.fillWidth: true
                height: 2
                color: Style.dividerColor
                opacity: Style.dividerOpacity
            }
        }

        GridLayout {
            columns: (isMobile)? 1 : 4
            StandardButton {
                id: closeWalletButton
                small: true
                text: qsTr("Close wallet") + translationManager.emptyString
                visible: true
                onClicked: {
                    console.log("closing wallet button clicked")
                    appWindow.showWizard();
                }
            }

            StandardButton {
                id: createViewOnlyWalletButton
                enabled: !viewOnly
                small: true
                text: qsTr("Create view only wallet") + translationManager.emptyString
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
                        walletManager.openWalletAsync(persistentSettings.wallet_path, appWindow.walletPassword,
                                                          persistentSettings.nettype);
                    }

                    confirmationDialog.onRejectedCallback = null;

                    confirmationDialog.open()

                }
            }
*/
            StandardButton {
                id: rescanSpentButton
                small: true
                enabled: !persistentSettings.useRemoteNode
                text: qsTr("Rescan wallet balance") + translationManager.emptyString
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
                        informationPopup.text  = qsTr("Successfully rescanned spent outputs.") + translationManager.emptyString
                        informationPopup.icon  = StandardIcon.Information
                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    }
                }
            }
        }

        RowLayout{
            Layout.fillWidth: true

            StandardButton {
                id: changePasswordButton
                small: true
                text: qsTr("Change password") + translationManager.emptyString
                onClicked: {
                    passwordDialog.onAcceptedCallback = function() {
                        if(appWindow.walletPassword === passwordDialog.password){
                            newPasswordDialog.open()
                        } else {
                            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                            informationPopup.text = qsTr("Wrong password");
                            informationPopup.open()
                            informationPopup.onCloseCallback = function() {
                                changePasswordDialog.open()
                            }
                            passwordDialog.open()
                        }
                    }
                    passwordDialog.onRejectedCallback = null;
                    passwordDialog.open()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            LabelSubheader {
                text: qsTr("Daemon mode") + translationManager.emptyString
            }
        }

        ColumnLayout {
            RadioButton {
                id: remoteDisconnect
                checked: !persistentSettings.useRemoteNode
                text: qsTr("Local Node") + translationManager.emptyString
                onClicked: {
                    persistentSettings.useRemoteNode = false;
                    remoteConnect.checked = false;
                    appWindow.disconnectRemoteNode();
                }
            }

            RadioButton {
                id: remoteConnect
                checked: persistentSettings.useRemoteNode
                text: qsTr("Remote Node") + translationManager.emptyString
                onClicked: {
                    persistentSettings.useRemoteNode = true;
                    remoteDisconnect.checked = false;
                    appWindow.connectRemoteNode();
                }
            }
        }

        RowLayout {
            visible: !isMobile && !persistentSettings.useRemoteNode
            Layout.fillWidth: true

            LabelSubheader {
                text:  qsTr("Bootstrap node") + translationManager.emptyString
            }
        }

        RowLayout {
            visible: !isMobile && !persistentSettings.useRemoteNode

            ColumnLayout {
                Layout.fillWidth: true

                RemoteNodeEdit {
                    id: bootstrapNodeEdit
                    Layout.minimumWidth: 100 * scaleRatio
                    Layout.bottomMargin: 20 * scaleRatio

                    lineEditBackgroundColor: "transparent"
                    lineEditFontColor: "white"
                    lineEditBorderColor: Style.inputBorderColorActive

                    daemonAddrLabelText: qsTr("Address")
                    daemonPortLabelText: qsTr("Port")
                    daemonAddrText: persistentSettings.bootstrapNodeAddress.split(":")[0].trim()
                    daemonPortText: {
                        var node_split = persistentSettings.bootstrapNodeAddress.split(":");
                        if(node_split.length == 2){
                            (node_split[1].trim() == "") ? "18081" : node_split[1];
                        } else {
                            return ""
                        }
                    }
                    onEditingFinished: {
                        persistentSettings.bootstrapNodeAddress = daemonAddrText ? bootstrapNodeEdit.getAddress() : "";
                        console.log("setting bootstrap node to " + persistentSettings.bootstrapNodeAddress)
                    }
                }
            }
        }

        RowLayout {
            visible: persistentSettings.useRemoteNode
            ColumnLayout {
                Layout.fillWidth: true

                RemoteNodeEdit {
                    id: remoteNodeEdit
                    Layout.minimumWidth: 100 * scaleRatio

                    lineEditBackgroundColor: "transparent"
                    lineEditFontColor: "white"
                    lineEditBorderColor: Qt.rgba(255, 255, 255, 0.35)

                    daemonAddrLabelText: qsTr("Address")
                    daemonPortLabelText: qsTr("Port")

                    property var rna: persistentSettings.remoteNodeAddress
                    daemonAddrText: rna.search(":") != -1 ? rna.split(":")[0].trim() : ""
                    daemonPortText: rna.search(":") != -1 ? (rna.split(":")[1].trim() == "") ? "18081" : rna.split(":")[1] : ""
                    onEditingFinished: {
                        persistentSettings.remoteNodeAddress = remoteNodeEdit.getAddress();
                        console.log("setting remote node to " + persistentSettings.remoteNodeAddress)
                    }
                }
            }
        }

        RowLayout{
            visible: persistentSettings.useRemoteNode
            Layout.fillWidth: true

            StandardButton {
                id: remoteNodeSave
                small: true
                text: qsTr("Connect") + translationManager.emptyString
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

        //! Manage daemon
        RowLayout {
            visible: !isMobile

            Label {
                id: manageDaemonLabel
                fontSize: 22 * scaleRatio
                text: qsTr("Manage Daemon") + translationManager.emptyString
            }

            Rectangle {
                anchors.top: manageDaemonLabel.bottom
                anchors.topMargin: 4
                anchors.left: parent.left
                anchors.right: parent.right
                Layout.fillWidth: true
                height: 2
                color: Style.dividerColor
                opacity: Style.dividerOpacity
            }
        }

        GridLayout {
            visible: !isMobile && !persistentSettings.useRemoteNode
            id: daemonStatusRow
            columns: (isMobile) ?  2 : 4
            StandardButton {
                id: startDaemonButton
                small: true
                visible: !appWindow.daemonRunning
                text: qsTr("Start Local Node") + translationManager.emptyString
                onClicked: {
                    // Update bootstrap daemon address
                    persistentSettings.bootstrapNodeAddress = bootstrapNodeEdit.daemonAddrText ? bootstrapNodeEdit.getAddress() : "";

                    // Set current daemon address to local
                    appWindow.currentDaemonAddress = appWindow.localDaemonAddress;
                    appWindow.startDaemon(daemonFlags.text);
                }
            }

            StandardButton {
                id: stopDaemonButton
                small: true
                visible: appWindow.daemonRunning
                text: qsTr("Stop Local Node") + translationManager.emptyString
                onClicked: {
                    appWindow.stopDaemon()
                }
            }

            StandardButton {
                id: daemonStatusButton
                small: true
                visible: true
                text: qsTr("Show status") + translationManager.emptyString
                onClicked: {
                    daemonManager.sendCommand("status",currentWallet.nettype);
                    daemonConsolePopup.open();
                }
            }
        }

        ColumnLayout {
            id: blockchainFolderRow
            visible: !isMobile && !persistentSettings.useRemoteNode

            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 14 * scaleRatio

                LabelSubheader {
                    text: qsTr("Blockchain location") + translationManager.emptyString
                }
            }

            RowLayout {
                visible: persistentSettings.blockchainDataDir.length > 0

                LineEdit {
                    id: blockchainFolder
                    Layout.preferredWidth: 200

                    Layout.fillWidth: true
                    text: persistentSettings.blockchainDataDir;
                    placeholderText: qsTr("(optional)") + translationManager.emptyString
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                StandardButton {
                    id: blockchainFolderButton
                    small: true
                    visible: true
                    text: qsTr("Change location") + translationManager.emptyString
                    onClicked: {
                        //mouse.accepted = false
                        if(persistentSettings.blockchainDataDir != "")
                            blockchainFileDialog.folder = "file://" + persistentSettings.blockchainDataDir
                        blockchainFileDialog.open()
                        blockchainFolder.focus = true
                    }
                }
            }
        }

        RowLayout{
            CheckBox {
                id: daemonAdvanced
                text: qsTr("Show advanced") + translationManager.emptyString
            }
        }

        RowLayout {
            visible: daemonAdvanced.checked && !isMobile && !persistentSettings.useRemoteNode
            id: daemonFlagsRow

            LineEdit {
                id: daemonFlags
                Layout.preferredWidth:  200
                Layout.fillWidth: true
                labelText: qsTr("Local daemon startup flags") + translationManager.emptyString
                text: appWindow.persistentSettings.daemonFlags;
                placeholderText: qsTr("(optional)") + translationManager.emptyString
            }
        }

        ColumnLayout {
            visible: (daemonAdvanced.checked || isMobile) && persistentSettings.useRemoteNode
            GridLayout {
                columns: (isMobile) ? 1 : 2
                columnSpacing: 32

                LineEdit {
                    id: daemonUsername
                    Layout.fillWidth: true
                    labelText: "Daemon username"
                    text: persistentSettings.daemonUsername
                    placeholderText: qsTr("Username") + translationManager.emptyString
                }

                LineEdit {
                    id: daemonPassword
                    Layout.fillWidth: true
                    labelText: "Daemon password"
                    text: persistentSettings.daemonPassword
                    placeholderText: qsTr("Password") + translationManager.emptyString
                    echoMode: TextInput.Password
                }
            }
        }

        RowLayout {
            visible: !isMobile
            Label {
                id: layoutSettingsLabel
                fontSize: 22 * scaleRatio
                text: qsTr("Layout settings") + translationManager.emptyString
            }

            Rectangle {
                anchors.top: layoutSettingsLabel.bottom
                anchors.topMargin: 4
                anchors.left: parent.left
                anchors.right: parent.right
                Layout.fillWidth: true
                height: 2
                color: Style.dividerColor
                opacity: Style.dividerOpacity
            }
        }

        RowLayout {
            CheckBox {
                visible: !isMobile
                id: customDecorationsCheckBox
                checked: persistentSettings.customDecorations
                onClicked: Windows.setCustomWindowDecorations(checked)
                text: qsTr("Custom decorations") + translationManager.emptyString
            }
        }

        // Log level

        RowLayout {
            Label {
                id: logLevelLabel
                fontSize: 22 * scaleRatio
                text: qsTr("Log level") + translationManager.emptyString
            }

            Rectangle {
                anchors.top: logLevelLabel.bottom
                anchors.topMargin: 4
                anchors.left: parent.left
                anchors.right: parent.right
                Layout.fillWidth: true
                height: 2
                color: Style.dividerColor
                opacity: Style.dividerOpacity
            }
        }

        GridLayout {
            columns: (isMobile)? 1 : 3
            Layout.fillWidth: true
            columnSpacing: 32

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                ListModel {
                     id: logLevel
                     ListElement { name: "none"; column1: "0"; }
                     ListElement { column1: "1"; }
                     ListElement { column1: "2"; }
                     ListElement { column1: "3"; }
                     ListElement { column1: "4"; }
                     ListElement { column1: "custom"; }
                 }

                StandardDropdown {
                    id: logLevelDropdown
                    dataModel: logLevel
                    currentIndex: appWindow.persistentSettings.logLevel;
                    onChanged: {
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
                    Layout.fillWidth: true
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#363636"
                    pressedColor: "#202020"
                }
                // Make sure dropdown is on top
            }

            ColumnLayout {
                Layout.fillWidth: true
            }

            ColumnLayout {
                Layout.fillWidth: true
            }

            z: parent.z + 1
        }

        ColumnLayout {
            LineEdit {
                id: logCategories
                Layout.fillWidth: true
                text: appWindow.persistentSettings.logCategories
                labelText: "Log Categories"
                placeholderText: "(e.g. *:WARNING,net.p2p:DEBUG)"
                enabled: logLevelDropdown.currentIndex === 5
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
                id: debugLabel
                text: qsTr("Debug info") + translationManager.emptyString
                fontSize: 22
                anchors.topMargin: 30 * scaleRatio
                Layout.topMargin: 30 * scaleRatio
            }

            Rectangle {
                anchors.top: debugLabel.bottom
                anchors.topMargin: 4
                anchors.left: parent.left
                anchors.right: parent.right
                Layout.fillWidth: true
                height: 2
                color: Style.dividerColor
                opacity: Style.dividerOpacity
            }
        }

        GridLayout {
            id: grid
            columns: 2
            columnSpacing: 20 * scaleRatio

            TextBlock {
                font.pixelSize: 14
                text: qsTr("GUI version: ") + translationManager.emptyString
            }

            TextBlock {
                font.pixelSize: 14
                font.bold: true
                text: Version.GUI_VERSION + " (Qt " + qtRuntimeVersion + ")" + translationManager.emptyString
            }

            TextBlock {
                id: guiMoneroVersion
                font.pixelSize: 14
                text: qsTr("Embedded Monero version: ") + translationManager.emptyString
            }

            TextBlock {
                font.pixelSize: 14
                font.bold: true
                text: Version.GUI_MONERO_VERSION + translationManager.emptyString
            }

            TextBlock {
                Layout.fillWidth: true
                font.pixelSize: 14
                text: qsTr("Wallet name: ") + translationManager.emptyString
            }

            TextBlock {
                Layout.fillWidth: true
                font.pixelSize: 14
                font.bold: true
                text: walletName + translationManager.emptyString
            }

            TextBlock {
                id: restoreHeight
                font.pixelSize: 14
                textFormat: Text.RichText
                text: (typeof currentWallet == "undefined") ? "" : qsTr("Wallet creation height: ") + translationManager.emptyString
            }

            TextBlock {
                id: restoreHeightText
                textFormat: Text.RichText
                font.pixelSize: 14
                font.bold: true
                property var style: "<style type='text/css'>a {cursor:pointer;text-decoration: none; color: #FF6C3C}</style>"
                text: (currentWallet ? currentWallet.walletCreationHeight : "") + style + qsTr(" <a href='#'> (Click to change)</a>") + translationManager.emptyString
                onLinkActivated: {
                    inputDialog.labelText = qsTr("Set a new restore height:") + translationManager.emptyString;
                    inputDialog.inputText = currentWallet ? currentWallet.walletCreationHeight : "0";
                    inputDialog.onAcceptedCallback = function() {
                        var _restoreHeight = inputDialog.inputText;
                        if(Utils.isNumeric(_restoreHeight)){
                            _restoreHeight = parseInt(_restoreHeight);
                            if(_restoreHeight >= 0) {
                                currentWallet.walletCreationHeight = restoreHeightEdit.text
                                // Restore height is saved in .keys file. Set password to trigger rewrite.
                                currentWallet.setPassword(appWindow.walletPassword)

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
                                    walletManager.openWalletAsync(persistentSettings.wallet_path, appWindow.walletPassword,
                                                                      persistentSettings.nettype);
                                }

                                confirmationDialog.onRejectedCallback = null;
                                confirmationDialog.open()
                                return;
                            }
                        }

                        appWindow.showStatusMessage(qsTr("Invalid restore height specified. Must be a number."),3);
                    }
                    inputDialog.onRejectedCallback = null;
                    inputDialog.open()
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            TextBlock {
                Layout.fillWidth: true
                font.pixelSize: 14
                text: qsTr("Wallet log path: ") + translationManager.emptyString
            }

            TextBlock {
                Layout.fillWidth: true
                font.pixelSize: 14
                text: walletLogPath
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
            var dataDir = walletManager.urlToLocalPath(blockchainFileDialog.fileUrl);
            console.log(dataDir);
            var validator = daemonManager.validateDataDir(dataDir);
            if(!validator.valid) {

                confirmationDialog.title = qsTr("Warning") + translationManager.emptyString;
                confirmationDialog.text = "";
                if(validator.readOnly) {
                    confirmationDialog.text  += qsTr("Error: Filesystem is read only") + "\n\n"                  
                }
                
                if(validator.storageAvailable < estimatedBlockchainSize) {
                    confirmationDialog.text  += qsTr("Warning: There's only %1 GB available on the device. Blockchain requires ~%2 GB of data.").arg(validator.storageAvailable).arg(estimatedBlockchainSize) + "\n\n"     
                } else {
                    confirmationDialog.text  += qsTr("Note: There's %1 GB available on the device. Blockchain requires ~%2 GB of data.").arg(validator.storageAvailable).arg(estimatedBlockchainSize) + "\n\n"
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

    // fires only once
    Component.onCompleted: {
        if(typeof daemonManager != "undefined")
            daemonManager.daemonConsoleUpdated.connect(onDaemonConsoleUpdated)
    }

    function onDaemonConsoleUpdated(message){
        // Update daemon console
        daemonConsolePopup.textArea.logMessage(message)
    }




}




