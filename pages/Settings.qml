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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

import "../components"
import moneroComponents 1.0
import moneroComponents.Clipboard 1.0

Rectangle {

    color: "#F0EEEE"

    Clipboard { id: clipboard }


    ColumnLayout {
        id: mainLayout
        anchors.margins: 40
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20
        property int labelWidth: 120
        property int editWidth: 400
        property int lineEditFontSize: 12

        RowLayout {
            id: paymentIdRow
            Label {
                id: seedLabel
                color: "#4A4949"
                text: qsTr("Mnemonic seed") + translationManager.emptyString
            }

            TextArea {
                id: memoTextInput
                textMargin: 8
                font.family: "Arial"
                font.pointSize: 15
                wrapMode: TextEdit.WordWrap
                readOnly: true
                selectByMouse: true
                height: 300
                width: 500
                text: qsTr("Click button to show seed") + translationManager.emptyString
            }
           Image {
                id : clipboardButton
                anchors.right: memoTextInput.right
                anchors.bottom: memoTextInput.bottom
                source: "qrc:///images/greyTriangle.png"
                Image {
                    anchors.centerIn: parent
                    source: "qrc:///images/copyToClipboard.png"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: clipboard.setText(memoTextInput.text)
                }
            }


            StandardButton {
                id: showSeedbtn
                width: 80
                fontSize: 14
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Show seed")
                onClicked: {
                    memoTextInput.text = currentWallet.seed
                }
            }
        }

        RowLayout {
            id: wordsTipTextRow

            Text {
                id: wordsTipText
                font.family: "Arial"
                font.pixelSize: 15
                color: "#4A4646"
                wrapMode: Text.WordWrap
                text: qsTr("It is very important to write it down as this is the only backup you will need for your wallet.")
                    + translationManager.emptyString
            }
        }


       Component.onCompleted: {
        console.log("Settings page loaded");
       }

    }
}




