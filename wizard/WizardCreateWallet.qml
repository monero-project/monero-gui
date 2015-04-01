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
import moneroComponents 1.0
import QtQuick.Dialogs 1.2

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
            ListElement { dotColor: "#FFE00A" }
            ListElement { dotColor: "#DBDBDB" }
            ListElement { dotColor: "#DBDBDB" }
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
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
            text: qsTr("A new wallet has been created for you")
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 18
            wrapMode: Text.Wrap
            //renderType: Text.NativeRendering
            color: "#4A4646"
            text: qsTr("This is the name of your wallet. You can change it to a different name if you’d like:")
        }
    }

    Item {
        id: walletNameItem
        anchors.top: headerColumn.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        width: 300
        height: 62

        TextInput {
            anchors.fill: parent
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            font.family: "Arial"
            font.pixelSize: 32
            renderType: Text.NativeRendering
            color: "#FF6C3C"
            text: qsTr("My account name")
            focus: true
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
        id: frameHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.top: walletNameItem.bottom
        anchors.topMargin: 24
        font.family: "Arial"
        font.pixelSize: 18
        //renderType: Text.NativeRendering
        color: "#4A4646"
        elide: Text.ElideRight
        text: qsTr("This is the 24 word mnemonic for your wallet")
    }

    Rectangle {
        id: wordsRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: frameHeader.bottom
        anchors.topMargin: 16
        height: 182
        border.width: 1
        border.color: "#DBDBDB"

        TextEdit {
            id: wordsText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: tipRect.top
            anchors.margins: 16
            font.family: "Arial"
            font.pixelSize: 24
            wrapMode: Text.Wrap
            selectByMouse: true
            readOnly: true
            color: "#3F3F3F"
            text: "bound class paint gasp task soul forgot past pleasure physical circle appear shore bathroom glove women crap busy beauty bliss idea give needle burden"
        }

        Image {
            anchors.right: parent.right
            anchors.bottom: tipRect.top
            source: "qrc:///images/greyTriangle.png"

            Image {
                anchors.centerIn: parent
                source: "qrc:///images/copyToClipboard.png"
            }

            Clipboard { id: clipboard }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: clipboard.setText(wordsText.text)
            }
        }

        Rectangle {
            id: tipRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 65
            color: "#DBDBDB"

            Text {
                anchors.fill: parent
                anchors.margins: 16
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Arial"
                font.pixelSize: 15
                color: "#4A4646"
                wrapMode: Text.Wrap
                text: qsTr("It is very important to write it down as this is the only backup you will need for your wallet. You will be asked to confirm the seed in the next screen to ensure it has copied down correctly.")
            }
        }
    }

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: wordsRect.bottom
        anchors.topMargin: 24
        spacing: 16

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Arial"
            font.pixelSize: 18
            //renderType: Text.NativeRendering
            color: "#4A4646"
            text: qsTr("Your wallet is stored in")
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x
            height: 34

            FileDialog {
                id: fileDialog
                selectMultiple: false
                title: "Please choose a file"
                onAccepted: {
                    fileUrlInput.text = fileDialog.fileUrl
                    fileDialog.visible = false
                }
                onRejected: {
                    fileDialog.visible = false
                }
            }

            TextInput {
                id: fileUrlInput
                anchors.fill: parent
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                clip: true
                font.family: "Arial"
                font.pixelSize: 18
                color: "#6B0072"
                verticalAlignment: Text.AlignVCenter
                selectByMouse: true
                text: "~/.monero/mywallet/"
                onFocusChanged: {
                    if(focus) {
                        fileDialog.visible = true
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: "#DBDBDB"
            }
        }
    }
}
