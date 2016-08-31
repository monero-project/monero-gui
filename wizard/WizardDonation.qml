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
import "../components"

Item {
    opacity: 0
    visible: false
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    function onPageOpened(settingsObject) {
        enableAutoDonationCheckBox.checked = settingsObject.auto_donations_enabled
        autoDonationAmountText.text = settingsObject.auto_donations_amount
        allowBackgroundMiningCheckBox.checked = settingsObject.allow_background_mining

    }

    function onPageClosed(settingsObject) {
        settingsObject['auto_donations_enabled'] = enableAutoDonationCheckBox.checked;
        settingsObject['auto_donations_amount']  = parseInt(autoDonationAmountText.text);
        settingsObject['allow_background_mining'] = allowBackgroundMiningCheckBox.checked;
        return true;
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
            ListElement { dotColor: "#FFE00A" }
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

    Text {
        id: headerText
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 74
        anchors.leftMargin: 16
        width: parent.width - dotsRow.width - 16

        font.family: "Arial"
        font.pixelSize: 28
        wrapMode: Text.Wrap
        //renderType: Text.NativeRendering
        color: "#3F3F3F"
        text: qsTr("Monero development is solely supported by donations") + translationManager.emptyString
    }

    Column {
        anchors.top: headerText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 34
        spacing: 12

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 2

            CheckBox {
                id: enableAutoDonationCheckBox
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Enable auto-donations of?") + translationManager.emptyString
                background: "#F0EEEE"
                fontColor: "#4A4646"
                fontSize: 18
                checkedIcon: "../images/checkedVioletIcon.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
                checked: true
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                height: 30
                width: 41

                TextInput {
                    id: autoDonationAmountText
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Arial"
                    font.pixelSize: 18
                    color: "#6B0072"
                    text: "50"
                    validator: IntValidator { bottom: 0; top: 100 }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: "#DBDBDB"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Arial"
                font.pixelSize: 18
                color: "#4A4646"
                text: qsTr("% of my fee added to each transaction") + translationManager.emptyString
            }
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 15
            color: "#4A4646"
            wrapMode: Text.Wrap
            text: qsTr("For every transaction, a small transaction fee is charged. This option lets you add an additional amount, " +
                       "as a percentage of that fee, to your transaction to support Monero development. For instance, a 50% " +
                       "autodonation take a transaction fee of 0.005 XMR and add a 0.0025 XMR to support Monero development.")
                    + translationManager.emptyString
        }
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            CheckBox {
                id: allowBackgroundMiningCheckBox
                text: qsTr("Allow background mining?") + translationManager.emptyString
                anchors.left: parent.left
                anchors.right: parent.right
                background: "#F0EEEE"
                fontColor: "#4A4646"
                fontSize: 18
                checkedIcon: "../images/checkedVioletIcon.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
                checked: true
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                font.family: "Arial"
                font.pixelSize: 15
                color: "#4A4646"
                wrapMode: Text.Wrap
                text: qsTr("Mining secures the Monero network, and also pays a small reward for the work done. This option " +
                           "will let Monero mine when your computer is on mains power and is idle. It will stop mining when you continue working.")
                      + translationManager.emptyString
            }
        }
    }
}
