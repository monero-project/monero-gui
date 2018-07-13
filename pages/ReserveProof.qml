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

import "../components"
import moneroComponents.Clipboard 1.0

import "../js/TxUtils.js" as TxUtils

Rectangle {

    color: "transparent"

    Clipboard { id: clipboard }

    /* main layout */
    ColumnLayout {
        id: mainLayout
        anchors.margins: 40 * scaleRatio
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 20 * scaleRatio

        // solo
        ColumnLayout {
            id: soloBox
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 20 * scaleRatio

            Label {
                fontSize: 24 * scaleRatio
                text: qsTr("Get Reserve Proof") + translationManager.emptyString
            }

            Text {
                text: qsTr("Generate a verifiable cryptographic proof that your own at least a certain amount of Monero") + translationManager.emptyString
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.family: Style.fontRegular.name
                font.pixelSize: 14 * scaleRatio
                color: Style.defaultFontColor
            }

            ColumnLayout {
                id: amountColumn
                Label {
                    id: amountLabel
                    text: qsTr("Amount") + translationManager.emptyString
                    width: mainLayout.labelWidth
                }

                LineEdit {
                    id: amountLine
                    placeholderText: qsTr("Amount to prove") + translationManager.emptyString
                    readOnly: false
                    width: mainLayout.editWidth
                    Layout.fillWidth: true
                    validator: DoubleValidator {
                        bottom: 0.0
                        top: 18446744.073709551615
                        decimals: 12
                        notation: DoubleValidator.StandardNotation
                        locale: "C"
                    }
                }
            }

            RowLayout {
                LineEdit {
                    id: getMessageLine
                    labelText: qsTr("Message") + translationManager.emptyString
                    fontSize: 16 * scaleRatio
                    placeholderText: qsTr("Message") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true
                    copyButton: true
                }
            }

            StandardButton {
                anchors.left: parent.left
                anchors.topMargin: 17 * scaleRatio
                width: 60 * scaleRatio
                text: qsTr("Generate") + translationManager.emptyString
                enabled: amountLine.text > 0
                onClicked: {
                  informationPopup.title  = qsTr("Reserve proof") + translationManager.emptyString;
                  console.log("message: " + getMessageLine.text);
                  informationPopup.text  = appWindow.currentWallet.getReserveProof(amountLine.text, getMessageLine.text);
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

            Label {
                fontSize: 24 * scaleRatio
                text: qsTr("Check Reserve Proof") + translationManager.emptyString
            }

            Text {
                text: qsTr("Verify the validity of a reserve proof") + translationManager.emptyString
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.family: Style.fontRegular.name
                font.pixelSize: 14 * scaleRatio
                color: Style.defaultFontColor
            }

            RowLayout {
                LineEdit {
                    id: addressLine
                    labelText: qsTr("Address") + translationManager.emptyString
                    fontSize: 16 * scaleRatio
                    placeholderText: qsTr("Address") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true
                    copyButton: true
                }
            }

            RowLayout {
                LineEdit {
                    id: signatureLine
                    labelText: qsTr("Siganture") + translationManager.emptyString
                    fontSize: 16 * scaleRatio
                    placeholderText: qsTr("Proof to verify") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true
                    copyButton: true
                }
            }

            RowLayout {
                LineEdit {
                    id: proveMessageLine
                    labelText: qsTr("Message") + translationManager.emptyString
                    fontSize: 16 * scaleRatio
                    placeholderText: qsTr("Optional message") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true
                    copyButton: true
                }
            }

            StandardButton {
                anchors.left: parent.left
                anchors.topMargin: 17 * scaleRatio
                width: 60 * scaleRatio
                text: qsTr("Verify") + translationManager.emptyString
                enabled: TxUtils.checkAddress(addressLine.text, appWindow.persistentSettings.nettype)
                onClicked: {
                  informationPopup.title  = qsTr("Proof Result") + translationManager.emptyString;
                  var result;
                  if(appWindow.currentWallet.checkReserveProof(addressLine.text, proveMessageLine.text, signatureLine.text))
                      result = "True Proof";
                  else
                      result = "False Proof";
                  informationPopup.text  = result
                  informationPopup.onCloseCallback = null
                  informationPopup.open();
                }
            }
        }
    }
}
