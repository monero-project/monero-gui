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

    color: "#F0EEEE"

    Clipboard { id: clipboard }

    function initSettings() {


        // Mnemonic seed settings
        memoTextInput.text = qsTr("Click button to show seed") + translationManager.emptyString
        showSeedButton.visible = true

        // Daemon settings

        daemonAddress = persistentSettings.daemon_address.split(":");
        console.log("address: " + persistentSettings.daemon_address)
        // try connecting to daemon
    }


    PasswordDialog {
        id: settingsPasswordDialog

        onAccepted: {
            if(appWindow.password === settingsPasswordDialog.password){
                memoTextInput.text = currentWallet.seed
                showSeedButton.visible = false
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


    ColumnLayout {
        id: mainLayout
        anchors.margins: 40
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 10


        Label {
            id: seedLabel
            color: "#4A4949"
            fontSize: 16
            text: qsTr("Mnemonic seed: ") + translationManager.emptyString
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignLeft
        }

        TextArea {
            id: memoTextInput
            textMargin: 6
            font.family: "Arial"
            font.pointSize: 14
            wrapMode: TextEdit.WordWrap
            readOnly: true
            selectByMouse: true

            Layout.fillWidth: true
            Layout.preferredHeight: 100
            Layout.alignment: Qt.AlignHCenter

            text: qsTr("Click button to show seed") + translationManager.emptyString

            Image {
                id : clipboardButton
                anchors.right: memoTextInput.right
                anchors.bottom: memoTextInput.bottom
                source: "qrc:///images/greyTriangle.png"

                Image {
                    anchors.centerIn: parent
                    source: "qrc:///images/copyToClipboard.png"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: clipboard.setText(memoTextInput.text)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                id: wordsTipText
                font.family: "Arial"
                font.pointSize: 12
                color: "#4A4646"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("This is very important to write down and keep secret. It is all you need to restore your wallet.")
                      + translationManager.emptyString
            }

            StandardButton {

                id: showSeedButton

                fontSize: 14
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Show seed")
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 100
                onClicked: {
                    settingsPasswordDialog.open();
                }
            }
        }




        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        RowLayout {
            id: daemonAddrRow
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.topMargin: 40
            spacing: 10

            Label {
                id: daemonAddrLabel

                Layout.fillWidth: true
                color: "#4A4949"
                text: qsTr("Daemon address") + translationManager.emptyString
                fontSize: 16
            }

            LineEdit {
                id: daemonAddr
                Layout.preferredWidth:  200
                Layout.fillWidth: true
                text: (daemonAddress !== undefined) ? daemonAddress[0] : ""
                placeholderText: qsTr("Hostname / IP")
            }


            LineEdit {
                id: daemonPort
                Layout.preferredWidth: 100
                Layout.fillWidth: true
                text: (daemonAddress !== undefined) ? daemonAddress[1] : "18081"
                placeholderText: qsTr("Port")
            }


            StandardButton {
                id: daemonAddrSave

                Layout.fillWidth: false

                Layout.leftMargin: 30
                Layout.minimumWidth: 100
                width: 60
                text: qsTr("Save") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                visible: true
                onClicked: {
                    console.log("saving daemon adress settings")
                    var newDaemon = daemonAddr.text + ":" + daemonPort.text
                    if(persistentSettings.daemon_address != newDaemon) {
                        persistentSettings.daemon_address = newDaemon
                        //reconnect wallet
                        appWindow.initialize();
                    }
                }
            }

        }


        RowLayout {
            Label {
                id: closeWalletLabel

                Layout.fillWidth: true
                color: "#4A4949"
                text: qsTr("Manage wallet") + translationManager.emptyString
                fontSize: 16
            }
        }
        RowLayout {

            Text {
                id: closeWalletTip
                font.family: "Arial"
                font.pointSize: 12
                color: "#4A4646"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Close current wallet and open wizard")
                      + translationManager.emptyString
            }


            StandardButton {
                id: closeWalletButton

//                Layout.leftMargin: 30
//                Layout.minimumWidth: 100
                width: 100
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
        }

        RowLayout {
            Label {
                id: manageDaemonLabel
                color: "#4A4949"
                text: qsTr("Manage daemon") + translationManager.emptyString
                fontSize: 16
            }

            StandardButton {
                visible: true
                enabled: !appWindow.daemonRunning
                id: startDaemonButton
                width: 110
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
                width: 110
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
             //  enabled: appWindow.daemonRunning
                id: daemonConsolePopupButton
                width: 110
                text: qsTr("Show log") + translationManager.emptyString
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                onClicked: {
                    daemonConsolePopup.open();
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
            CheckBox {
                id: customDecorationsCheckBox
                checked: persistentSettings.customDecorations
                onClicked: appWindow.setCustomWindowDecorations(checked)
                text: qsTr("Custom decorations") + translationManager.emptyString
                checkedIcon: "../images/checkedVioletIcon.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
            }
        }

        Label {
            id: guiVersion
            Layout.topMargin: 8
            color: "#4A4949"
            text: qsTr("GUI version: ") + Version.GUI_VERSION + translationManager.emptyString
            fontSize: 16
        }

        Label {
            id: guiMoneroVersion
            color: "#4A4949"
            text: qsTr("Embedded Monero version: ") + Version.GUI_MONERO_VERSION + translationManager.emptyString
            fontSize: 16
        }

    }

    // Daemon console
    StandardDialog {
        id: daemonConsolePopup
        height:500
        width:800
        cancelVisible: false
        title: qsTr("Daemon log")
        onAccepted: {
            close();
        }
    }


    // fires on every page load
    function onPageCompleted() {
        console.log("Settings page loaded");
        initSettings();
    }

    // fires only once
    Component.onCompleted: {
        daemonManager.daemonConsoleUpdated.connect(onDaemonConsoleUpdated)
    }

    function onDaemonConsoleUpdated(message){
        // Update daemon console
        daemonConsolePopup.textArea.append(message)
    }




}




