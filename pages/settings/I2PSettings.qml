// Copyright (c) 2014-2024, The Monero Project
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

import "../../components" as MoneroComponents
import moneroComponents.Settings 1.0
import moneroComponents.I2P 1.0

ColumnLayout {
    spacing: 20
    Layout.fillWidth: true

    // I2P Node Selection
    ColumnLayout {
        spacing: 10
        Layout.fillWidth: true

        MoneroComponents.TextPlain {
            color: MoneroComponents.Style.defaultFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            font.bold: true
            text: qsTr("I2P Node Selection") + translationManager.emptyString
        }

        MoneroComponents.StandardDropdown {
            id: knownNodes
            Layout.fillWidth: true
            currentIndex: 0
            dataModel: ListModel {
                id: i2pNodeModel
                ListElement { 
                    text: "core5hzivg4v5ttxbor4a3haja6dssksqsmiootlptnsrfsgwqqa.b32.i2p:18089"
                    url: "core5hzivg4v5ttxbor4a3haja6dssksqsmiootlptnsrfsgwqqa.b32.i2p:18089"
                }
                ListElement { 
                    text: "dsc7fyzzultm7y6pmx2avu6tze3usc7d27nkbzs5qwuujplxcmzq.b32.i2p:18089"
                    url: "dsc7fyzzultm7y6pmx2avu6tze3usc7d27nkbzs5qwuujplxcmzq.b32.i2p:18089"
                }
                ListElement { 
                    text: "sel36x6fibfzujwvt4hf5gxolz6kd3jpvbjqg6o3ud2xtionyl2q.b32.i2p:18089"
                    url: "sel36x6fibfzujwvt4hf5gxolz6kd3jpvbjqg6o3ud2xtionyl2q.b32.i2p:18089"
                }
                ListElement { 
                    text: "yht4tm2slhyue42zy5p2dn3sft2ffjjrpuy7oc2lpbhifcidml4q.b32.i2p:18089"
                    url: "yht4tm2slhyue42zy5p2dn3sft2ffjjrpuy7oc2lpbhifcidml4q.b32.i2p:18089"
                }
                ListElement { 
                    text: qsTr("Custom...") + translationManager.emptyString
                    url: ""
                }
            }
            onChanged: {
                var selectedNode = i2pNodeModel.get(currentIndex)
                if (selectedNode && selectedNode.url && selectedNode.url.length > 0) {
                    persistentSettings.i2pAddress = selectedNode.url
                    I2PManager.setProxyForI2p()
                } else if (selectedNode && !selectedNode.url) {
                    // Custom node selected - open input dialog
                    customNodeDialog.open()
                }
            }
        }

        // Custom node input dialog
        MoneroComponents.InputDialog {
            id: customNodeDialog
            title: qsTr("Enter Custom I2P Node Address") + translationManager.emptyString
            placeholderText: qsTr("example.b32.i2p:18089") + translationManager.emptyString
            onAccepted: {
                if (inputText.length > 0) {
                    persistentSettings.i2pAddress = inputText
                    I2PManager.setProxyForI2p()
                }
            }
        }
    }

    // Create I2P Node Button
    MoneroComponents.StandardButton {
        id: createNodeButton
        Layout.fillWidth: true
        text: qsTr("Create I2P Node (Recommended)") + translationManager.emptyString
        enabled: !I2PManager.isRunning
        onClicked: {
            passwordDialog.open(
                "",
                "",
                qsTr("Create Node") + translationManager.emptyString,
                "",
                false
            )
        }
    }

    // Connection Status
    RowLayout {
        spacing: 10
        Layout.fillWidth: true

        MoneroComponents.TextPlain {
            color: MoneroComponents.Style.defaultFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            text: qsTr("Connection status:") + translationManager.emptyString
        }

        MoneroComponents.TextPlain {
            id: statusText
            color: I2PManager.connected ? "#00A000" : "#C00000"
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            text: I2PManager.connected ? qsTr("Connected") : qsTr("Not connected") + translationManager.emptyString
        }

        Timer {
            id: statusTimer
            interval: 5000
            running: persistentSettings.i2pEnabled
            repeat: true
            onTriggered: {
                // Refresh status periodically
                I2PManager.refreshStatus()
            }
        }
    }

    // Password Dialog for node creation
    Connections {
        target: passwordDialog
        function onAccepted() {
            I2PManager.startCreateNode()
            // Password will be provided when PASSWORD_PROMPT is received
        }
    }

    Connections {
        target: I2PManager
        function onPasswordRequested(reason) {
            passwordDialog.open(
                "",
                reason,
                qsTr("Enter Password") + translationManager.emptyString,
                "",
                false
            )
        }
        function onPasswordAccepted() {
            I2PManager.providePassword(passwordDialog.password)
        }
    }
}