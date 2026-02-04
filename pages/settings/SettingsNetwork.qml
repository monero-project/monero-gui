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
import QtQuick.Dialogs 1.2

import moneroComponents.I2PDManager 1.0
import moneroComponents.DaemonManager 1.0

import "../../components" as MoneroComponents

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias networkHeight: networkLayout.height

    ColumnLayout {
        id: networkLayout
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 30

        MoneroComponents.Label {
            id: networkTitleLabel
            fontSize: 24
            text: qsTr("Network traffic protection") + translationManager.emptyString
        }

        MoneroComponents.TextPlain {
            id: networkMainLabel
            text: qsTr("Your wallet communicates with a set node and other nodes on the\nMonero network. This communication can be used to identify you.\nUse the options below to protect your privacy. Please check your\nlocal laws and internet policies before protecting your connection\nusing i2p, an anonymizing software.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
        }

        ColumnLayout {
            id: modeButtonsColumn
            Layout.topMargin: 8

            MoneroComponents.RadioButton {
                id: handleProtectButton
                text: qsTr("Protect my network connection") + translationManager.emptyString
                fontSize: 16
                enabled: !checked
                checked: persistentSettings.protectConnectionMode > 0
                onClicked: {
                    handleProtectButton.checked = true;
                    handleUnprotectButton.checked = false;
                    persistentSettings.protectConnectionMode = 1;
                    startI2PD();
                }
            }

            MoneroComponents.RadioButton {
                id: handleUnprotectButton
                text: qsTr("Do not protect my connection") + translationManager.emptyString
                fontSize: 16
                enabled: !checked
                checked: persistentSettings.protectConnectionMode === 0
                onClicked: {
                    handleUnprotectButton.checked = true;
                    handleProtectButton.checked = false;
                    persistentSettings.protectConnectionMode = 0;
                    stopI2PD();
                }
            }
        }

        RowLayout
        {
            MoneroComponents.Label {
                id: networkProtectionStatusLabel
                fontSize: 20
                text: qsTr("Status: ") + translationManager.emptyString
            }

            MoneroComponents.Label {
                id: networkProtectionStatus
                fontSize: 20
                text: qsTr("Unprotected") + translationManager.emptyString
            }
        }
    }

    function startI2PD()
    {
        appWindow.stopDaemon(function() {
            appWindow.startDaemon("")
        });
    }

    function stopI2PD()
    {
        appWindow.stopDaemon(function() {
            appWindow.startDaemon("")
        });
    }

    function onI2PDStatus(isRunning)
    {

    }

    Component.onCompleted: {
        //i2pdManager.i2pdStatus.connect(onI2PDStatus); // figure out a way to keep up to date on the status
    }
}