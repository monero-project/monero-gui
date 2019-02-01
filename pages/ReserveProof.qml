// Copyright (c) 2018, The Monero Project
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

import "../components" as MoneroComponents
import "../js/TxUtils.js" as TxUtils
import moneroComponents.Clipboard 1.0


Rectangle {
    color: "transparent"

    Clipboard { id: clipboard }

    ColumnLayout {
        id: mainLayout
        anchors.margins: (isMobile)? 17 * scaleRatio : 20 * scaleRatio
        anchors.topMargin: 40 * scaleRatio

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20 * scaleRatio

        MoneroComponents.Label {
            fontSize: 24 * scaleRatio
            text: qsTr("Get Reserve Proof") + translationManager.emptyString
        }

        Text {
            text: qsTr("This page allows you to interact with the shared ring database. " +
                       "This database is meant for use by Monero wallets as well as wallets from Monero clones which reuse the Monero keys.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14 * scaleRatio
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.LineEdit {
            id: amountLine
            Layout.fillWidth: true

            labelText: qsTr("Amount") + translationManager.emptyString
            placeholderText: qsTr("Amount to prove") + translationManager.emptyString
            placeholderFontSize: 16 * scaleRatio
            inlineButtonText: qsTr("All") + translationManager.emptyString
            inlineButton.onClicked: amountLine.text = "(all)"
            enabled: amountLine.text === "(all)" || amountLine.text > 0
            fontSize: 16 * scaleRatio
            readOnly: false

            validator: DoubleValidator {
                bottom: 0.0
                top: 18446744.073709551615
                decimals: 12
                notation: DoubleValidator.StandardNotation
                locale: "C"
            }
        }

        MoneroComponents.LineEdit {
            id: getMessageLine
            Layout.fillWidth: true

            labelText: qsTr("Message") + translationManager.emptyString
            placeholderFontSize: 16 * scaleRatio
            fontSize: 16 * scaleRatio
            placeholderText: qsTr("Message") + translationManager.emptyString;
            readOnly: false
            copyButton: true
        }

        MoneroComponents.StandardButton {
            Layout.alignment: Qt.AlignLeft
            Layout.topMargin: 16 * scaleRatio

            small: true
            text: qsTr("Generate") + translationManager.emptyString
            enabled: amountLine.text > 0
            onClicked: {
                informationPopup.title  = qsTr("Reserve proof") + translationManager.emptyString;
                console.log("message: " + getMessageLine.text);
                var all = amountLine.text === "(all)";
                informationPopup.text  = appWindow.currentWallet.getReserveProof(all, all ? 0 : walletManager.amountFromString(amountLine.text), getMessageLine.text);
                informationPopup.onCloseCallback = null
                informationPopup.open()
            }
        }

        // underline
        Rectangle {
            height: 1
            color: "#404040"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            anchors.bottomMargin: 3 * scaleRatio
        }

        MoneroComponents.Label {
            fontSize: 24 * scaleRatio
            text: qsTr("Check Reserve Proof") + translationManager.emptyString
        }

        Text {
            text: qsTr("Verify the validity of a reserve proof") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14 * scaleRatio
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.LineEdit {
            id: addressLine
            Layout.fillWidth: true

            labelText: qsTr("Address") + translationManager.emptyString
            placeholderFontSize: 16 * scaleRatio
            fontSize: 16 * scaleRatio
            placeholderText: qsTr("Address") + translationManager.emptyString;
            readOnly: false
            copyButton: true
        }

        MoneroComponents.LineEdit {
            id: signatureLine
            Layout.fillWidth: true

            labelText: qsTr("Signature") + translationManager.emptyString
            placeholderText: qsTr("Proof to verify") + translationManager.emptyString;
            placeholderFontSize: 16 * scaleRatio
            fontSize: 16 * scaleRatio
            readOnly: false
            copyButton: true
        }

        MoneroComponents.LineEdit {
            id: proveMessageLine
            Layout.fillWidth: true

            labelText: qsTr("Message") + translationManager.emptyString
            placeholderFontSize: 16 * scaleRatio
            fontSize: 16 * scaleRatio
            placeholderText: qsTr("Optional message") + translationManager.emptyString;
            readOnly: false
            copyButton: true
        }

        MoneroComponents.StandardButton {
            Layout.alignment: Qt.AlignLeft
            Layout.topMargin: 16 * scaleRatio

            small: true
            text: qsTr("Verify") + translationManager.emptyString
            enabled: TxUtils.checkAddress(addressLine.text, appWindow.persistentSettings.nettype)
            onClicked: {
                informationPopup.title  = qsTr("Proof Result") + translationManager.emptyString;

                var result = appWindow.currentWallet.checkReserveProof(addressLine.text, proveMessageLine.text, signatureLine.text);
                var results = result.split("|");
                if (results[0] === "true") {
                    if (results[1] === "true") {
                        informationPopup.text = "Good signature: total " + walletManager.displayAmount(results[2]) + ", spent " + walletManager.displayAmount(results[3]);
                    } else {
                    informationPopup.text = "Bad signature";
                    }
                } else {
                    informationPopup.text = "Error: " + results[1];
                }

                informationPopup.onCloseCallback = null
                informationPopup.open();
            }
        }
    }
}
