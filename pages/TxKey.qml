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
    property alias addressText : addressLine.text
    property alias txIdText : txIdLine.text
    property alias txKeyText : txKeyLine.text

    Clipboard { id: clipboard }

    function checkAddress(address, testnet) {
      return walletManager.addressValid(address, testnet)
    }

    function check256(str) {
        if (str.length != 64)
            return false;
        for (var i = 0; i < 64; ++i) {
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
        return check256(txid)
    }

    function checkTxKey(txid) {
        return check256(txid)
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

        RowLayout {
            ColumnLayout {

                Text {
                    text: qsTr("Verify that a third party made a payment by supplying:") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true;
                }
                Text {
                    text: qsTr(" - the recipient address") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true;
                }
                Text {
                    text: qsTr(" - the transaction ID") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true;
                }
                Text {
                    text: qsTr(" - the secret transaction key supplied by the sender") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true;
                }
                Text {
                    text: qsTr("If a payment had several transactions then each must be checked and the results combined.") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true;
                }
            }
        }

        RowLayout {
            id: addressRow

            Label {
                id: addressLabel
                fontSize: 14
                text: qsTr("Address") + translationManager.emptyString
                width: mainLayout.labelWidth
            }

            LineEdit {
                id: addressLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Recipient's wallet address") + translationManager.emptyString;
                readOnly: false
                width: mainLayout.editWidth
                Layout.fillWidth: true
                onTextChanged: cursorPosition = 0

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (addressLine.text.length > 0) {
                            clipboard.setText(addressLine.text)
                        }
                    }
                }
            }
        }

        RowLayout {
            id: txIdRow
            Label {
                id: txIdLabel
                fontSize: 14
                text: qsTr("Transaction ID") + translationManager.emptyString
                width: mainLayout.labelWidth
            }


            LineEdit {

                id: txIdLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Paste tx ID") + translationManager.emptyString
                readOnly: false
                width: mainLayout.editWidth
                Layout.fillWidth: true

                onTextChanged: cursorPosition = 0

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (txIdLine.text.length > 0) {
                            clipboard.setText(txIdLine.text)
                        }
                    }
                }

            }
        }

        RowLayout {
            id: txKeyRow
            Label {
                id: paymentIdLabel
                fontSize: 14
                text: qsTr("Transaction key") + translationManager.emptyString
                width: mainLayout.labelWidth
            }


            LineEdit {
                id: txKeyLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Paste tx key") + translationManager.emptyString;
                readOnly: false

                width: mainLayout.editWidth
                Layout.fillWidth: true

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (TxKeyLine.text.length > 0) {
                            clipboard.setText(TxKeyLine.text)
                        }
                    }
                }
            }
        }

        StandardButton {
            id: checkButton
            anchors.left: parent.left
            anchors.top: txKeyRow.bottom
            anchors.topMargin: 17
            width: 60
            text: qsTr("Check") + translationManager.emptyString
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            enabled: checkAddress(addressLine.text, appWindow.persistentSettings.testnet) && checkTxID(txIdLine.text) && checkTxKey(txKeyLine.text)
            onClicked: {
                console.log("TxKey: Check clicked: address " + addressLine.text + ", txid " << txIdLine.text + ", tx key " + txKeyLine.text);
                root.checkPaymentClicked(addressLine.text, txIdLine.text, txKeyLine.text)
            }
        }

    }

    function onPageCompleted() {
        console.log("TxKey page loaded");

    }

}
