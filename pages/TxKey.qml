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
import moneroComponents.Clipboard 1.0

Rectangle {

    color: "#F0EEEE"

    Clipboard { id: clipboard }

    function checkAddress(address, testnet) {
      return walletManager.addressValid(address, testnet)
    }

    function check256(str, length) {
        if (str.length != length)
            return false;
        for (var i = 0; i < length; ++i) {
            if (str[i] >= '0' && str[i] <= '9')
                continue;
            if (str[i] >= 'a' && str[i] <= 'z')
                continue;
            if (str[i] >= 'A' && str[i] <= 'Z')
                continue;
            return false;
        }
        return true;
    }

    function checkTxID(txid) {
        return check256(txid, 64)
    }

    function checkSignature(signature) {
        return signature.startsWith("OutProofV") && check256(signature, 142) ||
               signature.startsWith("InProofV")  && check256(signature, 141)
    }

    /* main layout */
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

        Text {
            text: qsTr("Generate a proof of your incoming/outgoing payment by supplying the transaction ID, the recipient address and an optional message:") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true;
        }

        RowLayout {
            Label {
                fontSize: 14
                text: qsTr("Transaction ID") + translationManager.emptyString
                width: mainLayout.labelWidth
            }

            LineEdit {
                id: getProofTxIdLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Paste tx ID") + translationManager.emptyString
                readOnly: false
                width: mainLayout.editWidth
                Layout.fillWidth: true

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (getProofTxIdLine.text.length > 0) {
                            clipboard.setText(getProofTxIdLine.text)
                        }
                    }
                }

            }
        }

        RowLayout {
            Label {
                fontSize: 14
                text: qsTr("Address") + translationManager.emptyString
                width: mainLayout.labelWidth
            }

            LineEdit {
                id: getProofAddressLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Recipient's wallet address") + translationManager.emptyString;
                readOnly: false
                width: mainLayout.editWidth
                Layout.fillWidth: true

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (getProofAddressLine.text.length > 0) {
                            clipboard.setText(getProofAddressLine.text)
                        }
                    }
                }
            }
        }

        RowLayout {
            Label {
                fontSize: 14
                text: qsTr("Message") + translationManager.emptyString
                width: mainLayout.labelWidth
            }

            LineEdit {
                id: getProofMessageLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Optional message against which the signature is signed") + translationManager.emptyString;
                readOnly: false
                width: mainLayout.editWidth
                Layout.fillWidth: true

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (getProofMessageLine.text.length > 0) {
                            clipboard.setText(getProofMessageLine.text)
                        }
                    }
                }
            }
        }

        StandardButton {
            anchors.left: parent.left
            anchors.topMargin: 17
            width: 60
            text: qsTr("Generate") + translationManager.emptyString
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            enabled: checkTxID(getProofTxIdLine.text) && checkAddress(getProofAddressLine.text, appWindow.persistentSettings.testnet)
            onClicked: {
                console.log("getProof: Generate clicked: txid " + getProofTxIdLine.text + ", address " + getProofAddressLine.text + ", message: " + getProofMessageLine.text);
                root.getProofClicked(getProofTxIdLine.text, getProofAddressLine.text, getProofMessageLine.text)
            }
        }

        // underline
        Rectangle {
            height: 1
            color: "#DBDBDB"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            anchors.bottomMargin: 3

        }

        Text {
            text: qsTr("Verify that funds were paid to an address by supplying the transaction ID, the recipient address, the message used for signing and the signature:") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true;
        }

        RowLayout {
            Label {
                fontSize: 14
                text: qsTr("Transaction ID") + translationManager.emptyString
                width: mainLayout.labelWidth
            }

            LineEdit {
                id: checkProofTxIdLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Paste tx ID") + translationManager.emptyString
                readOnly: false
                width: mainLayout.editWidth
                Layout.fillWidth: true

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (checkProofTxIdLine.text.length > 0) {
                            clipboard.setText(checkProofTxIdLine.text)
                        }
                    }
                }

            }
        }

        RowLayout {
            Label {
                fontSize: 14
                text: qsTr("Address") + translationManager.emptyString
                width: mainLayout.labelWidth
            }

            LineEdit {
                id: checkProofAddressLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Recipient's wallet address") + translationManager.emptyString;
                readOnly: false
                width: mainLayout.editWidth
                Layout.fillWidth: true

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (checkProofAddressLine.text.length > 0) {
                            clipboard.setText(checkProofAddressLine.text)
                        }
                    }
                }
            }
        }

        RowLayout {
            Label {
                fontSize: 14
                text: qsTr("Message") + translationManager.emptyString
                width: mainLayout.labelWidth
            }

            LineEdit {
                id: checkProofMessageLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Optional message against which the signature is signed") + translationManager.emptyString;
                readOnly: false
                width: mainLayout.editWidth
                Layout.fillWidth: true

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (checkProofMessageLine.text.length > 0) {
                            clipboard.setText(checkProofMessageLine.text)
                        }
                    }
                }
            }
        }

        RowLayout {
            Label {
                fontSize: 14
                text: qsTr("Signature") + translationManager.emptyString
                width: mainLayout.labelWidth
            }


            LineEdit {
                id: checkProofSignatureLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Paste tx proof") + translationManager.emptyString;
                readOnly: false

                width: mainLayout.editWidth
                Layout.fillWidth: true

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (checkProofSignatureLine.text.length > 0) {
                            clipboard.setText(checkProofSignatureLine.text)
                        }
                    }
                }
            }
        }

        StandardButton {
            anchors.left: parent.left
            anchors.topMargin: 17
            width: 60
            text: qsTr("Check") + translationManager.emptyString
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            enabled: checkTxID(checkProofTxIdLine.text) && checkAddress(checkProofAddressLine.text, appWindow.persistentSettings.testnet) && checkSignature(checkProofSignatureLine.text)
            onClicked: {
                console.log("checkProof: Check clicked: txid " + checkProofTxIdLine.text + ", address " + checkProofAddressLine.text + ", message " + checkProofMessageLine.text + ", signature " + checkProofSignatureLine.text);
                root.checkProofClicked(checkProofTxIdLine.text, checkProofAddressLine.text, checkProofMessageLine.text, checkProofSignatureLine.text)
            }
        }

        // underline
        Rectangle {
            height: 1
            color: "#DBDBDB"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            anchors.bottomMargin: 3

        }

        Text {
            text: qsTr("If a payment had several transactions then each must be checked and the results combined.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true;
        }
    }

    function onPageCompleted() {
        console.log("TxKey page loaded");

    }

}
