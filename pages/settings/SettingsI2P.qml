// Copyright (c) 2014-2023, The Monero Project
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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

import moneroComponents.Clipboard 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.PendingTransaction 1.0
import moneroComponents.Wallet 1.0

Rectangle {
    property var i2pStatus: i2pDaemonManager.status
    property bool i2pRunning: i2pDaemonManager.running
    property var daemonAddress: ""
    property int daemonPort: 0
    property string i2pOptions: persistentSettings.i2pOptions
    property bool useI2P: persistentSettings.useI2P
    
    color: "transparent"
    height: 1400
    Layout.fillWidth: true

    Clipboard { id: clipboard }
    
    ColumnLayout {
        id: mainLayout
        anchors.margins: 20
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 20

        MoneroComponents.Label {
            id: i2pHeaderText
            fontSize: 24
            text: qsTr("I2P Network Settings") + translationManager.emptyString
        }

        MoneroComponents.TextPlain {
            text: qsTr("I2P allows you to route your Monero transactions through the I2P anonymous network, making your connection even more private and secure.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.WarningBox {
            text: qsTr("The I2P feature is experimental. Support and configuration may change.") + translationManager.emptyString
            visible: true
        }

        MoneroComponents.LabelSubheader {
            text: qsTr("I2P Status") + translationManager.emptyString
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 20

            RowLayout {
                MoneroComponents.StandardSwitch {
                    id: enableI2PCheckbox
                    checked: useI2P
                    onClicked: {
                        if (checked && !i2pRunning) {
                            i2pDaemonManager.start();
                        } else if (!checked && i2pRunning) {
                            i2pDaemonManager.stop();
                        }
                        persistentSettings.useI2P = checked;
                        if (currentWallet) {
                            currentWallet.setI2PEnabled(checked);
                        }
                    }
                }
                
                MoneroComponents.Label {
                    text: qsTr("Enable I2P") + translationManager.emptyString
                    fontSize: 16
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            RowLayout {
                MoneroComponents.Label {
                    text: qsTr("Status:") + translationManager.emptyString
                    fontSize: 16
                }
                
                MoneroComponents.Label {
                    text: i2pRunning ? qsTr("Active") : qsTr("Not Active") + translationManager.emptyString
                    fontSize: 16
                    color: i2pRunning ? "#2EB358" : MoneroComponents.Style.defaultFontColor
                }
            }

            RowLayout {
                MoneroComponents.Label {
                    text: qsTr("Status details:") + translationManager.emptyString
                    fontSize: 16
                }
                
                MoneroComponents.Label {
                    text: i2pStatus + translationManager.emptyString
                    fontSize: 16
                }
            }

            RowLayout {
                MoneroComponents.StandardButton {
                    id: startButton
                    small: true
                    text: qsTr("Start I2P") + translationManager.emptyString
                    enabled: !i2pRunning && useI2P
                    onClicked: {
                        i2pDaemonManager.start();
                    }
                }
                
                MoneroComponents.StandardButton {
                    id: stopButton
                    small: true
                    text: qsTr("Stop I2P") + translationManager.emptyString
                    enabled: i2pRunning
                    onClicked: {
                        i2pDaemonManager.stop();
                    }
                }
            }
        }

        MoneroComponents.LabelSubheader {
            text: qsTr("I2P Configuration") + translationManager.emptyString
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                
                MoneroComponents.Label {
                    text: qsTr("I2P Options:") + translationManager.emptyString
                    fontSize: 16
                }
                
                TextField {
                    id: i2pOptionsField
                    Layout.fillWidth: true
                    text: i2pOptions
                    placeholderText: qsTr("Example: sam.host=127.0.0.1 sam.port=7656") + translationManager.emptyString
                    onTextChanged: {
                        // Update local property
                        i2pOptions = text;
                    }
                }
            }

            RowLayout {
                MoneroComponents.StandardSwitch {
                    id: useBuiltInI2PCheckbox
                    checked: persistentSettings.useBuiltInI2P
                    onClicked: {
                        persistentSettings.useBuiltInI2P = checked;
                    }
                }
                
                MoneroComponents.Label {
                    text: qsTr("Use Built-in I2P Router") + translationManager.emptyString
                    fontSize: 16
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                MoneroComponents.Label {
                    text: qsTr("I2P Address:") + translationManager.emptyString
                    fontSize: 16
                }
                
                TextField {
                    id: i2pAddressField
                    Layout.fillWidth: true
                    text: persistentSettings.i2pAddress
                    placeholderText: "127.0.0.1"
                    onTextChanged: {
                        persistentSettings.i2pAddress = text;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                MoneroComponents.Label {
                    text: qsTr("I2P Port:") + translationManager.emptyString
                    fontSize: 16
                }
                
                TextField {
                    id: i2pPortField
                    Layout.fillWidth: true
                    text: persistentSettings.i2pPort
                    placeholderText: "7656"
                    onTextChanged: {
                        persistentSettings.i2pPort = text;
                    }
                }
            }

            RowLayout {
                MoneroComponents.StandardSwitch {
                    id: allowMixedCheckbox
                    checked: persistentSettings.i2pMixedMode
                    onClicked: {
                        persistentSettings.i2pMixedMode = checked;
                    }
                }
                
                MoneroComponents.Label {
                    text: qsTr("Allow Mixed Mode") + translationManager.emptyString
                    fontSize: 16
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                MoneroComponents.Label {
                    text: qsTr("Tunnel Length:") + translationManager.emptyString
                    fontSize: 16
                }
                
                ComboBox {
                    id: tunnelLengthComboBox
                    model: [1, 2, 3, 4, 5, 6, 7]
                    currentIndex: persistentSettings.i2pTunnelLength - 1
                    onCurrentIndexChanged: {
                        persistentSettings.i2pTunnelLength = currentIndex + 1;
                    }
                }
            }

            MoneroComponents.StandardButton {
                id: saveButton
                text: qsTr("Save I2P Configuration") + translationManager.emptyString
                enabled: i2pOptionsField.text !== persistentSettings.i2pOptions
                onClicked: {
                    applyI2PSettings();
                }
            }

            MoneroComponents.TextPlain {
                text: qsTr("For best privacy, run your own I2P router and use the sam.host=127.0.0.1 option.") + translationManager.emptyString
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: MoneroComponents.Style.dimmedFontColor
            }
        }

        MoneroComponents.LabelSubheader {
            text: qsTr("I2P Router Information") + translationManager.emptyString
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 20
            
            MoneroComponents.TextPlain {
                text: qsTr("I2P router console address:") + translationManager.emptyString
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: MoneroComponents.Style.defaultFontColor
            }
            
            RowLayout {
                Layout.fillWidth: true

                MoneroComponents.TextPlain {
                    text: "http://127.0.0.1:7070"
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 14
                    color: MoneroComponents.Style.defaultFontColor
                }
                
                MoneroComponents.StandardButton {
                    id: copyButton
                    text: qsTr("Copy") + translationManager.emptyString
                    small: true
                    onClicked: {
                        clipboard.setText("http://127.0.0.1:7070");
                        appWindow.showStatusMessage(qsTr("Copied to clipboard"), 3);
                    }
                }
            }
        }
        
        MoneroComponents.LabelSubheader {
            text: qsTr("Documentation") + translationManager.emptyString
        }
        
        MoneroComponents.TextPlain {
            text: qsTr("Visit the <a href='https://getmonero.org/resources/user-guides/i2p-tor.html'>Monero documentation</a> for more information.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
            textFormat: Text.RichText
            onLinkActivated: Qt.openUrlExternally(link)
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }

    // Helper functions for I2P settings
    function getI2PAddress() {
        return persistentSettings.i2pAddress;
    }

    function getI2PPort() {
        return persistentSettings.i2pPort;
    }

    function getI2PStatus() {
        return i2pStatus;
    }

    function applyI2PSettings() {
        persistentSettings.i2pOptions = i2pOptionsField.text;
        if (currentWallet) {
            currentWallet.setI2POptions(i2pOptionsField.text);
        }
        // Restart I2P if it's running
        if (i2pRunning) {
            i2pDaemonManager.stop();
            i2pDaemonManager.start();
        }
    }
} 