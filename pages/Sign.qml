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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import "../components"
import moneroComponents.Clipboard 1.0
import moneroComponents.WalletManager 1.0

Rectangle {
    id: mainLayout

    color: "transparent"

    Clipboard { id: clipboard }

    MessageDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: signatureVerificationMessage
        standardButtons: StandardButton.Ok
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    function displayVerificationResult(result) {
        if (result) {
            signatureVerificationMessage.title = qsTr("Good signature") + translationManager.emptyString
            signatureVerificationMessage.text  = qsTr("This is a good signature") + translationManager.emptyString
            signatureVerificationMessage.icon = StandardIcon.Information
        }
        else {
            signatureVerificationMessage.title = qsTr("Bad signature") + translationManager.emptyString
            signatureVerificationMessage.text  = qsTr("This signature did not verify") + translationManager.emptyString
            signatureVerificationMessage.icon = StandardIcon.Critical
        }
        signatureVerificationMessage.open()
    }

    // ================
    // Sign a message
    //   message:       [                   ] [SIGN]
    //   [SELECT] file: [                   ] [SIGN]
    //   signature:     [                   ]
    // ================
    // verify a message
    //   address:       [                   ]
    //   message:       [                   ] [VERIFY]
    //   [SELECT] file: [                   ] [VERIFY]
    //   signature:     [                   ]
    // ================

    // sign / verify
    ColumnLayout {
        anchors.top: parent.top
        anchors.margins: 40 * scaleRatio
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 20 * scaleRatio

        // sign
        ColumnLayout {
            id: signBox
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20 * scaleRatio

            Label {
                id: signTitleLabel
                fontSize: 24 * scaleRatio
                text: qsTr("Sign") + translationManager.emptyString
            }

            Text {
                text: qsTr("This page lets you sign/verify a message (or file contents) with your address.") + translationManager.emptyString
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.family: Style.fontRegular.name
                font.pixelSize: 14 * scaleRatio
                color: Style.defaultFontColor
            }

            ColumnLayout{
                id: signMessageRow

                RowLayout {
                    Layout.fillWidth: true

                    LineEdit {
                        id: signMessageLine
                        Layout.fillWidth: true
                        placeholderText: qsTr("Message to sign") + translationManager.emptyString;
                        labelText: qsTr("Message") + translationManager.emptyString;
                        readOnly: false
                        onTextChanged: signSignatureLine.text = ""
                    }
                }

                RowLayout{
                    Layout.fillWidth: true
                    Layout.topMargin: 18

                    StandardButton {
                        id: signMessageButton
                        text: qsTr("Sign") + translationManager.emptyString
                        enabled: signMessageLine.text !== ''
                        small: true
                        onClicked: {
                          var signature = appWindow.currentWallet.signMessage(signMessageLine.text, false)
                          signSignatureLine.text = signature
                        }
                    }
                }
            }

            ColumnLayout {
                id: signFileRow

                RowLayout {
                    LineEdit {
                        id: signFileLine
                        labelText: "Message from file"
                        placeholderText: qsTr("Path to file") + translationManager.emptyString;
                        readOnly: false
                        Layout.fillWidth: true
                        onTextChanged: signSignatureLine.text = ""
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 18

                    StandardButton {
                        id: loadFileToSignButton
                        small: true
                        text: qsTr("Browse") + translationManager.emptyString
                        enabled: true
                        onClicked: {
                          signFileDialog.open();
                        }
                    }

                    StandardButton {
                        id: signFileButton
                        small: true
                        anchors.left: loadFileToSignButton.right
                        anchors.leftMargin: 20
                        text: qsTr("Sign") + translationManager.emptyString
                        enabled: signFileLine.text !== ''
                        onClicked: {
                            var signature = appWindow.currentWallet.signMessage(signFileLine.text, true);
                            signSignatureLine.text = signature;
                        }
                    }
                }

            }

            ColumnLayout {
                id: signSignatureRow

                RowLayout {
                    LineEdit {
                        id: signSignatureLine
                        labelText: qsTr("Signature")
                        placeholderText: qsTr("Signature") + translationManager.emptyString;
                        readOnly: true
                        Layout.fillWidth: true
                        copyButton: true
                    }
                }
            }

            Label {
                id: verifyTitleLabel
                fontSize: 24 * scaleRatio
                Layout.topMargin: 40
                text: qsTr("Verify") + translationManager.emptyString
            }

            ColumnLayout {
                RowLayout {
                    id: verifyMessageRow

                    LineEdit {
                        id: verifyMessageLine
                        Layout.fillWidth: true
                        labelText: qsTr("Verify message")
                        placeholderText: qsTr("Message to verify") + translationManager.emptyString;
                        readOnly: false
                    }
                }

                RowLayout{
                    Layout.fillWidth: true
                    Layout.topMargin: 18

                    StandardButton {
                        id: verifyMessageButton
                        small: true
                        text: qsTr("Verify") + translationManager.emptyString
                        enabled: true
                        onClicked: {
                          var verified = appWindow.currentWallet.verifySignedMessage(verifyMessageLine.text, verifyAddressLine.text, verifySignatureLine.text, false)
                          displayVerificationResult(verified)
                        }
                    }
                }
            }

            ColumnLayout {
                RowLayout {
                    LineEdit {
                        id: verifyFileLine
                        labelText: qsTr("Verify file")
                        placeholderText: qsTr("Filename with message to verify") + translationManager.emptyString;
                        readOnly: false
                        Layout.fillWidth: true
                    }
                }

                RowLayout{
                    Layout.fillWidth: true
                    Layout.topMargin: 18

                    StandardButton {
                        id: loadFileToVerifyButton
                        small: true
                        text: qsTr("Browse") + translationManager.emptyString
                        enabled: true
                        onClicked: {
                          verifyFileDialog.open()
                        }
                    }

                    StandardButton {
                        id: verifyFileButton
                        small: true
                        anchors.left: loadFileToVerifyButton.right
                        anchors.leftMargin: 20
                        text: qsTr("Verify") + translationManager.emptyString
                        enabled: true
                        onClicked: {
                          var verified = appWindow.currentWallet.verifySignedMessage(verifyFileLine.text, verifyAddressLine.text, verifySignatureLine.text, true)
                          displayVerificationResult(verified)
                        }
                    }
                }
            }

            ColumnLayout {
                RowLayout{

                    LineEditMulti {
                        id: verifyAddressLine
                        Layout.fillWidth: true
                        labelText: qsTr("Address")
                        addressValidation: true
                        anchors.topMargin: 5 * scaleRatio
                        placeholderText: "4..."
                    }
                }
            }

            ColumnLayout {
                id: verifySignatureRow
                anchors.topMargin: 17 * scaleRatio

                Label {
                    id: verifySignatureLabel
                    text: qsTr("Signature") + translationManager.emptyString
                }

                LineEdit {
                    id: verifySignatureLine
                    placeholderText: qsTr("Signature") + translationManager.emptyString;
                    Layout.fillWidth: true
                    copyButton: true
                }
            }
        }


        FileDialog {
            id: signFileDialog
            title: qsTr("Please choose a file to sign") + translationManager.emptyString;
            folder: "file://"
            nameFilters: [ "*"]

            onAccepted: {
                signFileLine.text = walletManager.urlToLocalPath(signFileDialog.fileUrl)
            }
        }

        FileDialog {
            id: verifyFileDialog
            title: qsTr("Please choose a file to verify") + translationManager.emptyString;
            folder: "file://"
            nameFilters: [ "*"]

            onAccepted: {
                verifyFileLine.text = walletManager.urlToLocalPath(verifyFileDialog.fileUrl)
            }
        }
    }

    function onPageCompleted() {
        console.log("Sign/verify page loaded");
    }

}
