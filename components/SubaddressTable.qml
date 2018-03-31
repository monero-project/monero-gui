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

import QtQuick 2.0
import moneroComponents.Clipboard 1.0

import "../components" as MoneroComponents

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds
    highlightMoveDuration: 0
    highlightFollowsCurrentItem: true
    anchors.topMargin: 0
    spacing: 0

    delegate: Rectangle {
        id: delegate
        height: 80
        color: 'transparent';
        anchors.topMargin: 0
        width: listView.width
        clip: true

        MoneroComponents.LineEditMulti {
            id: addressLine

            fontSize: 14
            readOnly: true
            width: parent.width
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.topMargin: 12
            anchors.rightMargin: 54
            anchors.bottomMargin: 0
            text: address

            showingHeader: false
            showBorder: false
            addressValidation: false
        }

        MoneroComponents.IconButton {
            id: clipboardButton
            imageSource: "../images/copyToClipboard.png"

            onClicked: {
                console.log(addressLine.text + " copied to clipboard");
                clipboard.setText(addressLine.text);
                appWindow.showStatusMessage(qsTr("Address copied to clipboard"),3);
            }

            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: indexText
            anchors.top: addressLine.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            font.family: "Arial"
            font.bold: true
            font.pixelSize: 12
            color: "#444444"
            text: "#" + index
        }

        Text {
            id: labelText
            anchors.top: addressLine.bottom
            anchors.left: indexText.right
            anchors.right: parent.right
            anchors.leftMargin: 10
            font.family: "Arial"
            font.bold: true
            font.pixelSize: 12
            color: MoneroComponents.Style.greyFontColor
            text: label
        }

        MouseArea {
            z: 5
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: clipboardButton.width
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                listView.currentIndex = index;
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: MoneroComponents.Style.grey
            z: 6
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: MoneroComponents.Style.grey
            z: 6
        }

        Rectangle {
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            color: MoneroComponents.Style.grey
            height: 1
            z: 6
        }

        Rectangle {
            width: 3
            color: 'white'
            visible: listView.currentIndex == index
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
    }
}
