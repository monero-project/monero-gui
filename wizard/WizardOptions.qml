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
import QtQml 2.2
import QtQuick.Layouts 1.1
import moneroComponents.NetworkType 1.0
import "../components"

ColumnLayout {
    id: page
    signal createWalletClicked()
    signal recoveryWalletClicked()
    signal openWalletClicked()
    opacity: 0
    visible: false
    property int buttonSize: (isMobile) ? 80 * scaleRatio : 190 * scaleRatio
    property int buttonImageSize: (isMobile) ? buttonSize - 10 * scaleRatio : buttonSize - 30 * scaleRatio

    function onPageClosed() {
        // Save settings used in open from file.
        // other wizard settings are saved on last page in applySettings()
        appWindow.persistentSettings.language = wizard.settings.language
        appWindow.persistentSettings.locale   = wizard.settings.locale

        return true;
    }

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    ColumnLayout {
        id: headerColumn
        Layout.leftMargin: wizardLeftMargin
        Layout.rightMargin: wizardRightMargin
        Layout.bottomMargin: (!isMobile) ? 40 * scaleRatio : 20
        spacing: 30 * scaleRatio

        Text {
            Layout.fillWidth: true
            font.family: "Arial"
            font.pixelSize: 28 * scaleRatio
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Welcome to Monero!") + translationManager.emptyString
        }

        Text {
            Layout.fillWidth: true
            font.family: "Arial"
            font.pixelSize: 18 * scaleRatio
            //renderType: Text.NativeRendering
            color: "#4A4646"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Please select one of the following options:") + translationManager.emptyString
        }
    }

    GridLayout {
        Layout.leftMargin: wizardLeftMargin
        Layout.rightMargin: wizardRightMargin
        Layout.alignment: Qt.AlignCenter
        id: actionButtons
        columnSpacing: 40 * scaleRatio
        rowSpacing: 10 * scaleRatio
        Layout.fillWidth: true
        Layout.fillHeight: true
        flow: isMobile ? GridLayout.TopToBottom : GridLayout.LeftToRight

        GridLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            flow: !isMobile ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rowSpacing: 20 * scaleRatio
            columnSpacing: 10 * scaleRatio

            Rectangle {
                Layout.preferredHeight: page.buttonSize
                Layout.preferredWidth: page.buttonSize
                radius: page.buttonSize
                color: createWalletArea.containsMouse ? "#DBDBDB" : "#FFFFFF"


                Image {
                    width: page.buttonImageSize
                    height: page.buttonImageSize
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    verticalAlignment: Image.AlignTop
                    anchors.centerIn: parent
                    source: "qrc:///images/createWallet.png"
                }

                MouseArea {
                    id: createWalletArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        page.createWalletClicked()
                    }
                }
            }

            Text {
                Layout.preferredWidth: page.buttonSize
                font.family: "Arial"
                font.pixelSize: 16 * scaleRatio
                color: "#4A4949"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Create a new wallet") + translationManager.emptyString
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            flow: !isMobile ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rowSpacing: 20 * scaleRatio
            columnSpacing: 10 * scaleRatio

            Rectangle {
                Layout.preferredHeight: page.buttonSize
                Layout.preferredWidth:  page.buttonSize
                radius: page.buttonSize
                color: recoverWalletArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

                Image {
                    width: page.buttonImageSize
                    height: page.buttonImageSize
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                    source: "qrc:///images/recoverWallet.png"
                }

                MouseArea {
                    id: recoverWalletArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        page.recoveryWalletClicked()
                    }
                }
            }

            Text {
                Layout.preferredWidth: page.buttonSize
                font.family: "Arial"
                font.pixelSize: 16 * scaleRatio
                color: "#4A4949"
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Restore wallet from keys or mnemonic seed") + translationManager.emptyString
                width:page.buttonSize
                wrapMode: Text.WordWrap
            }
        }

        GridLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            flow: !isMobile ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rowSpacing: 20 * scaleRatio
            columnSpacing: 10 * scaleRatio

            Rectangle {
                Layout.preferredHeight: page.buttonSize
                Layout.preferredWidth:  page.buttonSize
                radius: page.buttonSize
                color: openWalletArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

                Image {
                    width: page.buttonImageSize
                    height: page.buttonImageSize
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                    source: "qrc:///images/openAccount.png"
                }

                MouseArea {
                    id: openWalletArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        page.openWalletClicked()
                    }
                }
            }

            Text {
                Layout.preferredWidth: page.buttonSize
                font.family: "Arial"
                font.pixelSize: 16 * scaleRatio
                color: "#4A4949"
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Open a wallet from file") + translationManager.emptyString
                wrapMode: Text.WordWrap
            }
        }
    }

    ColumnLayout {
        Layout.leftMargin: wizardLeftMargin
        Layout.rightMargin: wizardRightMargin
        Layout.topMargin: 30 * scaleRatio
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        spacing: 38 * scaleRatio

        RowLayout {
            CheckBox2 {
                id: showAdvancedCheckbox
                darkDropIndicator: true
                text: qsTr("Advanced options") + translationManager.emptyString
                fontColor: "#4A4646"
            }
        }

        Rectangle {
            width: 100 * scaleRatio
            RadioButton {
                visible: showAdvancedCheckbox.checked
                enabled: !this.checked
                id: mainNet
                text: qsTr("Mainnet") + translationManager.emptyString
                checkedColor: Qt.rgba(0, 0, 0, 0.75)
                borderColor: Qt.rgba(0, 0, 0, 0.45)
                fontColor: "#4A4646"
                fontSize: 16 * scaleRatio
                checked: appWindow.persistentSettings.nettype == NetworkType.MAINNET;
                onClicked: {
                    persistentSettings.nettype = NetworkType.MAINNET
                    testNet.checked = false;
                    stageNet.checked = false;
                    console.log("Network type set to MainNet")
                }
            }
        }

        Rectangle {
            width: 100 * scaleRatio
            RadioButton {
                visible: showAdvancedCheckbox.checked
                enabled: !this.checked
                id: testNet
                text: qsTr("Testnet") + translationManager.emptyString
                checkedColor: Qt.rgba(0, 0, 0, 0.75)
                borderColor: Qt.rgba(0, 0, 0, 0.45)
                fontColor: "#4A4646"
                fontSize: 16 * scaleRatio
                checked: appWindow.persistentSettings.nettype == NetworkType.TESTNET;
                onClicked: {
                    persistentSettings.nettype = testNet.checked ? NetworkType.TESTNET : NetworkType.MAINNET
                    mainNet.checked = false;
                    stageNet.checked = false;
                    console.log("Network type set to ", persistentSettings.nettype == NetworkType.TESTNET ? "Testnet" : "Mainnet")
                }
            }
        }

        Rectangle {
            width: 100 * scaleRatio
            RadioButton {
                visible: showAdvancedCheckbox.checked
                enabled: !this.checked
                id: stageNet
                text: qsTr("Stagenet") + translationManager.emptyString
                checkedColor: Qt.rgba(0, 0, 0, 0.75)
                borderColor: Qt.rgba(0, 0, 0, 0.45)
                fontColor: "#4A4646"
                fontSize: 16 * scaleRatio
                checked: appWindow.persistentSettings.nettype == NetworkType.STAGENET;
                onClicked: {
                    persistentSettings.nettype = stageNet.checked ? NetworkType.STAGENET : NetworkType.MAINNET
                    mainNet.checked = false;
                    testNet.checked = false;
                    console.log("Network type set to ", persistentSettings.nettype == NetworkType.STAGENET ? "Stagenet" : "Mainnet")
                }
            }
        }
    }
}

