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
            ListElement { dotColor: "#FFE00A" }
            ListElement { dotColor: "#DBDBDB" }
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
        text: qsTr("We’re almost there - let’s just configure some Monero preferences") + translationManager.emptyString
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerText.bottom
        anchors.topMargin: 34
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 24

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            CheckBox {
                text: qsTr("Kickstart the Monero blockchain?") + translationManager.emptyString
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
                text: qsTr("It is very important to write it down as this is the only backup you will need for your wallet.")
                        + translationManager.emptyString
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            CheckBox {
                text: qsTr("Enable disk conservation mode?") + translationManager.emptyString
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
                text: qsTr("Disk conservation mode uses substantially less disk-space, but the same amount of bandwidth as " +
                           "a regular Monero instance. However, storing the full blockchain is beneficial to the security " +
                           "of the Monero network. If you are on a device with limited disk space, then this option is appropriate for you.")
                        + translationManager.emptyString
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            CheckBox {
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
