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

import QtQuick 6.6
import QtQuick.Layouts 6.6
import QtQuick.Controls 6.6
import QtQuick.Dialogs 6.6

import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias i2pHeight: settingsI2p.height

    ColumnLayout {
        id: settingsI2p
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 20

        MoneroComponents.TextPlain {
            Layout.topMargin: 10
            font.pixelSize: 18
            font.bold: true
            color: MoneroComponents.Style.defaultFontColor
            text: qsTr("i2p Configuration") + translationManager.emptyString
        }

        MoneroComponents.TextPlain {
            font.pixelSize: 14
            color: MoneroComponents.Style.dimmedFontColor
            text: qsTr("Configure your i2p router settings. The i2p router must be running and accessible at the specified address and port.") + translationManager.emptyString
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        MoneroComponents.TextPlain {
            font.pixelSize: 12
            color: MoneroComponents.Style.dimmedFontColor
            text: qsTr("⚠️ Important: When i2p is enabled, you may need to use i2p-accessible remote nodes. Regular nodes may not be reachable through i2p. Also, the i2p router needs time to establish tunnels (usually 1-5 minutes after starting).") + translationManager.emptyString
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            visible: persistentSettings.i2pEnabled
        }

        MoneroComponents.TextPlain {
            font.pixelSize: 12
            color: "#FF6B6B"
            text: qsTr("🚨 CRITICAL: The remote node MUST be fully synced for transactions to work! Check the sync status in the left panel. If the daemon shows 'Synchronizing', wait until it's fully synced before sending transactions. Unsynced nodes may cause transactions to be lost or delayed.") + translationManager.emptyString
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            visible: persistentSettings.i2pEnabled && (typeof appWindow !== "undefined" && !appWindow.daemonSynced)
        }

        MoneroComponents.RemoteNodeEdit {
            id: i2pRouterEdit
            Layout.leftMargin: 0
            Layout.topMargin: 10
            Layout.minimumWidth: 100
            placeholderFontSize: 15

            daemonAddrLabelText: qsTr("i2p Router Address") + translationManager.emptyString
            daemonPortLabelText: qsTr("i2p Router Port") + translationManager.emptyString

            initialAddress: persistentSettings.i2pAddress || "127.0.0.1:4447"
            onEditingFinished: {
                persistentSettings.i2pAddress = i2pRouterEdit.getAddress();
                // Update wallet proxy if i2p is enabled and wallet is connected
                if (persistentSettings.i2pEnabled && currentWallet && currentWallet.connected()) {
                    currentWallet.proxyAddress = persistentSettings.getI2pProxyAddress();
                    currentWallet.connectToDaemon();
                }
            }
        }

        // Port presets dropdown
        RowLayout {
            Layout.topMargin: 5
            Layout.fillWidth: true
            spacing: 10

            MoneroComponents.TextPlain {
                Layout.preferredWidth: 150
                font.pixelSize: 14
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("Common Ports:") + translationManager.emptyString
            }

            MoneroComponents.StandardDropdown {
                id: portPresetDropdown
                Layout.preferredWidth: 250
                labelText: ""
                labelFontSize: 0
                dropdownHeight: 35
                fontSize: 13
                dataModel: portPresetModel
                currentIndex: 0

                onChanged: {
                    var selectedPort = portPresetModel.get(currentIndex).port;
                    if (selectedPort !== "custom") {
                        i2pRouterEdit.daemonPortText = selectedPort;
                        // Trigger address update
                        i2pRouterEdit.editingFinished();
                    }
                }
            }
        }

        ListModel {
            id: portPresetModel
            Component.onCompleted: {
                append({column1: qsTr("i2pd SOCKS (4447) - Recommended"), port: "4447"});
                append({column1: qsTr("Java i2p SOCKS (4444)"), port: "4444"});
                append({column1: qsTr("SAM Port (7656) - Not SOCKS"), port: "7656"});
                append({column1: qsTr("Custom Port"), port: "custom"});
            }
        }

        MoneroComponents.TextPlain {
            Layout.topMargin: 5
            font.pixelSize: 12
            color: MoneroComponents.Style.dimmedFontColor
            text: qsTr("Note: Port 4447 is the default SOCKS proxy port for i2pd. Port 4444 is for Java i2p router. Port 7656 is the SAM port (not SOCKS).") + translationManager.emptyString
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        MoneroComponents.StandardButton {
            Layout.topMargin: 20
            Layout.preferredWidth: 200
            text: qsTr("Test i2p Connection") + translationManager.emptyString

            onClicked: {
                // Save current settings before testing
                persistentSettings.i2pAddress = i2pRouterEdit.getAddress();
                
                // Clear previous result
                i2pTestResult.text = "";
                
                // Call function to test connection
                var result = appWindow.testI2pConnection(persistentSettings.i2pAddress);
                if (result && result.message) {
                    updateTestResult(result.success, result.message);
                }
            }
        }

        MoneroComponents.TextPlain {
            id: i2pTestResult
            Layout.topMargin: 10
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
            visible: text !== ""
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    Component.onCompleted: {
        console.log('SettingsI2p loaded');
        
        // Sync port preset dropdown with current port
        var currentAddress = persistentSettings.i2pAddress || "127.0.0.1:4447";
        var parts = currentAddress.split(":");
        var currentPort = parts.length > 1 ? parts[1] : "4447";
        
        // Find matching preset or default to custom
        var presetIndex = 0;
        for (var i = 0; i < portPresetModel.count; i++) {
            if (portPresetModel.get(i).port === currentPort) {
                presetIndex = i;
                break;
            }
            if (i === portPresetModel.count - 1) {
                // Last item is "Custom", use it if no match
                presetIndex = i;
            }
        }
        portPresetDropdown.currentIndex = presetIndex;
    }

    // Cleanup function called when page is closed
    function onPageClosed() {
        // Close dropdown if it's open to prevent glitches
        // Clear currentItem immediately to allow popup to close
        if (portPresetDropdown && portPresetDropdown.expanded) {
            appWindow.currentItem = null;
        }
    }

    Component.onDestruction: {
        // Ensure dropdown is closed when component is destroyed
        // This prevents the popup from staying visible after navigation
        if (portPresetDropdown && portPresetDropdown.expanded) {
            appWindow.currentItem = null;
        }
    }

    // Function to update test result message
    function updateTestResult(success, message) {
        if (success) {
            i2pTestResult.color = "#4CAF50"; // Green for success
            i2pTestResult.text = qsTr("Success! ") + message + translationManager.emptyString;
        } else {
            i2pTestResult.color = "#F44336"; // Red for failure
            i2pTestResult.text = qsTr("Connection Failed: ") + message + translationManager.emptyString;
        }
    }
}

