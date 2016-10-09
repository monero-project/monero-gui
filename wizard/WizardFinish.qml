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

import QtQuick 2.2

Item {
    opacity: 0
    visible: false
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    function buildSettingsString() {
        var str = "<br>" + qsTr("<b>Language:</b> ") + wizard.settings['language'] + "<br>"
            + qsTr("<b>Account name:</b> ") + wizard.settings['account_name'] + "<br>"
            + qsTr("<b>Words:</b> ") + wizard.settings['wallet'].seed + "<br>"
            + qsTr("<b>Wallet Path: </b>") + wizard.settings['wallet_path'] + "<br>"
            + qsTr("<b>Enable auto donation: </b>") + wizard.settings['auto_donations_enabled'] + "<br>"
            + qsTr("<b>Auto donation amount: </b>") + wizard.settings['auto_donations_amount'] + "<br>"
            + qsTr("<b>Allow background mining: </b>") + wizard.settings['allow_background_mining'] + "<br>"
            + qsTr("<b>Daemon address: </b>") + wizard.settings['daemon_address'] + "<br>"
            + qsTr("<b>testnet: </b>") + wizard.settings['testnet'] + "<br>"
            + (wizard.settings['restore_height'] === undefined ? "" : qsTr("<b>Restore height: </b>") + wizard.settings['restore_height']) + "<br>"
            + translationManager.emptyString
        return str;
    }
    function updateSettingsSummary() {
        settingsText.text = qsTr("An overview of your Monero configuration is below:") + translationManager.emptyString
                            + "<br>"
                            + buildSettingsString();
    }

    function onPageOpened(settings) {
        updateSettingsSummary();
        wizard.nextButton.visible = false;
    }


    Row {
        id: dotsRow
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 85
        spacing: 6

        ListModel {
            id: dotsModel
            ListElement { dotColor: "#36B05B" }
            ListElement { dotColor: "#36B05B" }
            ListElement { dotColor: "#36B05B" }
            ListElement { dotColor: "#36B05B" }
        }

        Repeater {
            model: dotsModel
            delegate: Rectangle {
                width: 12; height: 12
                radius: 6
                color: dotColor
            }
        }
    }

    Column {
        id: headerColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.top: parent.top
        anchors.topMargin: 74
        spacing: 24

        Text {
            anchors.left: parent.left
            width: headerColumn.width - dotsRow.width - 16
            font.family: "Arial"
            font.pixelSize: 28
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
            text: qsTr("You’re all setup!") + translationManager.emptyString
        }

        Text {
            id: settingsText
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 18
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            horizontalAlignment: Text.AlignHCenter
            //renderType: Text.NativeRendering
            color: "#4A4646"
        }
    }
}
