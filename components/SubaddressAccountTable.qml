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
import moneroComponents.Clipboard 1.0

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds
    highlightMoveDuration: 0

    delegate: Rectangle {
        id: delegate
        height: 96
        width: listView.width

        Text {
            id: indexText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 15
            anchors.leftMargin: 15
            font.family: "Arial"
            font.bold: true
            font.pixelSize: 16
            color: 'dimgray'
            text: "#" + index
        }

        Text {
            id: addressText
            anchors.top: parent.top
            anchors.left: indexText.right
            anchors.topMargin: 15
            anchors.leftMargin: 10
            font.family: "Arial"
            font.pixelSize: 16
            color: 'dimgray'
            text: address
        }

        Text {
            id: labelText
            anchors.top: parent.top
            anchors.left: addressText.right
            anchors.right: parent.right
            anchors.topMargin: 15
            anchors.leftMargin: 30
            font.family: "Arial"
            font.pixelSize: 16
            text: label
        }

        Text {
            id: balanceText
            anchors.top: indexText.bottom
            anchors.left: parent.left
            anchors.topMargin: 5
            anchors.leftMargin: 15
            font.family: "Arial"
            font.pixelSize: 16
            textFormat: Text.RichText
            text: "<font color='dimgray'>" + qsTr("Balance: ") + "</font> <font size='+1'>" + balance + "</font>"
        }

        Text {
            id: unlockedBalanceText
            anchors.top: balanceText.bottom
            anchors.left: parent.left
            anchors.topMargin: 5
            anchors.leftMargin: 15
            font.family: "Arial"
            font.pixelSize: 16
            textFormat: Text.RichText
            text: "<font color='dimgray'>" + qsTr("Unlocked balance") + ":</font> <font size='+1'>" + unlockedBalance + "</font>"
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: 'lightgray'
        }

        MouseArea {
            anchors.fill: parent
            onClicked: listView.currentIndex = index
        }
    }

    highlight: Rectangle {
        height: 96
        color: '#FF4304'
        opacity: 0.2
        z: 2
    }
}
