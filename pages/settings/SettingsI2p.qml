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
        Layout.fillWidth: true
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

        MoneroComponents.RemoteNodeEdit {
            id: i2pRouterEdit
            Layout.leftMargin: 0
            Layout.topMargin: 10
            Layout.minimumWidth: 100
            placeholderFontSize: 15

            daemonAddrLabelText: qsTr("i2p Router Address") + translationManager.emptyString
            daemonPortLabelText: qsTr("i2p Router Port") + translationManager.emptyString

            initialAddress: persistentSettings.i2pAddress || "127.0.0.1:7656"
            onEditingFinished: {
                persistentSettings.i2pAddress = i2pRouterEdit.getAddress();
            }
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

