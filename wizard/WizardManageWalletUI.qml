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
import moneroComponents.TranslationManager 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "../components"

// Reusable component for managing wallet (account name, path, private key)

Item {

    property alias titleText: titleText.text
    property alias accountNameText: accountName.text
    property alias wordsTextTitle: frameHeader.text
    property alias walletPath: fileUrlInput.text
    property alias wordsTextItem : memoTextItem
    property alias restoreHeight : restoreHeightItem.text
    property alias restoreHeightVisible: restoreHeightItem.visible


    // TODO extend properties if needed

    anchors.fill: parent
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
            id: titleText
            anchors.left: parent.left
            width: headerColumn.width - dotsRow.width - 16
            font.family: "Arial"
            font.pixelSize: 28
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 18
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            //renderType: Text.NativeRendering
            color: "#4A4646"
            text: qsTr("This is the name of your wallet. You can change it to a different name if you’d like:") + translationManager.emptyString
        }
    }

    Item {
        id: walletNameItem
        anchors.top: headerColumn.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        width: 300
        height: 62

        TextEdit {
            id: accountName
            anchors.fill: parent
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            font.family: "Arial"
            font.pixelSize: 32
            renderType: Text.NativeRendering
            color: "#FF6C3C"
            focus: true
            text: qsTr("My account name") + translationManager.emptyString
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
        font.pixelSize: 24
        font.bold: true
        //renderType: Text.NativeRendering
        color: "#4A4646"
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
    }


    WizardMemoTextInput {
        id : memoTextItem
        width: parent.width
        anchors.top : frameHeader.bottom
        anchors.topMargin: 16
    }

    // Restore Height
    LineEdit {
        id: restoreHeightItem
        anchors.top: memoTextItem.bottom
        width: 250
        anchors.topMargin: 20
        placeholderText: qsTr("Restore height")
        Layout.alignment: Qt.AlignCenter
        validator: IntValidator {
            bottom:0
        }
    }
    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: (restoreHeightItem.visible)? restoreHeightItem.bottom : memoTextItem.bottom
        anchors.topMargin: 24
        spacing: 16

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Arial"
            font.pixelSize: 18
            //renderType: Text.NativeRendering
            color: "#4A4646"
            text: qsTr("Your wallet is stored in") + translationManager.emptyString
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x
            height: 34

            FileDialog {
                id: fileDialog
                selectMultiple: false
                selectFolder: true
                title: qsTr("Please choose a directory")  + translationManager.emptyString
                onAccepted: {
                    fileUrlInput.text = walletManager.urlToLocalPath(fileDialog.folder)
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

                text: moneroAccountsDir + "/"
                // workaround for the bug "filechooser only opens once"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mouse.accepted = false
                        fileDialog.folder = walletManager.localPathToUrl(fileUrlInput.text)
                        fileDialog.open()
                        fileUrlInput.focus = true
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

