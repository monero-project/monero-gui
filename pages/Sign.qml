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
import QtQuick.Dialogs 1.2

import "../components"
import moneroComponents.Clipboard 1.0
import moneroComponents.WalletManager 1.0

Rectangle {
    id: mainLayout

    color: "#F0EEEE"

    Clipboard { id: clipboard }

    function checkAddress(address, testnet) {
      return walletManager.addressValid(address, testnet)
    }

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
        anchors.margins: 17 * scaleRatio
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        spacing: 20 * scaleRatio

        // sign
        ColumnLayout {
            id: signBox

            RowLayout {

                Text {
                    text: qsTr("Sign a message or file contents with your address:") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    font.pixelSize: 14 * scaleRatio
                    Layout.fillWidth: true
                }
            }

            Label {
                id: signMessageLabel
                text: qsTr("Either message:") + translationManager.emptyString
            }

            RowLayout {
                id: signMessageRow
                anchors.topMargin: 17
                anchors.left: parent.left
                anchors.right: parent.right

                LineEdit {
                    id: signMessageLine
                    anchors.left: parent.left
                    anchors.right: signMessageButton.left
                    placeholderText: qsTr("Message to sign") + translationManager.emptyString;
                    readOnly: false
                    onTextChanged: signSignatureLine.text = ""

                    IconButton {
                        imageSource: "../images/copyToClipboard.png"
                        onClicked: {
                            if (signMessageLine.text.length > 0) {
                                clipboard.setText(signMessageLine.text)
                            }
                        }
                    }
                }

                StandardButton {
                    id: signMessageButton
                    anchors.right: parent.right
                    text: qsTr("Sign") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    enabled: true
                    onClicked: {
                      var signature = appWindow.currentWallet.signMessage(signMessageLine.text, false)
                      signSignatureLine.text = signature
                    }
                }
            }

            Label {
                id: signMessageFileLabel
                text: qsTr("Or file:") + translationManager.emptyString
            }

            RowLayout {
                id: signFileRow
                anchors.topMargin: 17
                anchors.left: parent.left
		anchors.right: parent.right

                FileDialog {
                    id: signFileDialog
                    title: qsTr("Please choose a file to sign") + translationManager.emptyString;
                    folder: "file://"
                    nameFilters: [ "*"]

                    onAccepted: {
                        signFileLine.text = walletManager.urlToLocalPath(signFileDialog.fileUrl)
                    }
                }

                StandardButton {
                    id: loadFileToSignButton
                    anchors.rightMargin: 17 * scaleRatio
                    text: qsTr("Select") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    enabled: true
                    onClicked: {
                      signFileDialog.open()
                    }
                }
                LineEdit {
                    id: signFileLine
                    anchors.left: loadFileToSignButton.right
                    anchors.right: signFileButton.left
                    placeholderText: qsTr("Filename with message to sign") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true
                    onTextChanged: signSignatureLine.text = ""

                    IconButton {
                        imageSource: "../images/copyToClipboard.png"
                        onClicked: {
                            if (signFileLine.text.length > 0) {
                                clipboard.setText(signFileLine.text)
                            }
                        }
                    }
                }

                StandardButton {
                    id: signFileButton
                    anchors.right: parent.right
                    text: qsTr("Sign") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    enabled: true
                    onClicked: {
                      var signature = appWindow.currentWallet.signMessage(signFileLine.text, true)
                      signSignatureLine.text = signature
                    }
                }
            }

            ColumnLayout {
                id: signSignatureRow
                anchors.topMargin: 17 * scaleRatio

                Label {
                    id: signSignatureLabel
                    text: qsTr("Signature") + translationManager.emptyString
                }

                LineEdit {
                    id: signSignatureLine
                    placeholderText: qsTr("Signature") + translationManager.emptyString;
                    readOnly: true
                    Layout.fillWidth: true

                    IconButton {
                        imageSource: "../images/copyToClipboard.png"
                        onClicked: {
                            if (signSignatureLine.text.length > 0) {
                                clipboard.setText(signSignatureLine.text)
                            }
                        }
                    }
                }
            }
        }


        // verify
        ColumnLayout {
            id: verifyBox

            RowLayout {  
                Text {
                    text: qsTr("Verify a message or file signature from an address:") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    font.pixelSize: 14 * scaleRatio
                    Layout.fillWidth: true
                }

            }

            Label {
                id: verifyMessageLabel
                text: qsTr("Either message:") + translationManager.emptyString
            }

            RowLayout {
                id: verifyMessageRow
                anchors.topMargin: 17 * scaleRatio
                anchors.left: parent.left
                anchors.right: parent.right

                LineEdit {
                    id: verifyMessageLine
                    anchors.left: parent.left
                    anchors.right: verifyMessageButton.left
                    placeholderText: qsTr("Message to verify") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true

                    IconButton {
                        imageSource: "../images/copyToClipboard.png"
                        onClicked: {
                            if (verifyMessageLine.text.length > 0) {
                                clipboard.setText(verifyMessageLine.text)
                            }
                        }
                    }
                }

                StandardButton {
                    id: verifyMessageButton
                    anchors.right: parent.right
                    text: qsTr("Verify") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    enabled: true
                    onClicked: {
                      var verified = appWindow.currentWallet.verifySignedMessage(verifyMessageLine.text, verifyAddressLine.text, verifySignatureLine.text, false)
                      displayVerificationResult(verified)
                    }
                }
            }

            Label {
                id: verifyMessageFileLabel
                text: qsTr("Or file:") + translationManager.emptyString
            }

            RowLayout {
                id: verifyFileRow
                anchors.topMargin: 17 * scaleRatio
                anchors.left: parent.left
                anchors.right: parent.right

                FileDialog {
                    id: verifyFileDialog
                    title: qsTr("Please choose a file to verify") + translationManager.emptyString;
                    folder: "file://"
                    nameFilters: [ "*"]

                    onAccepted: {
                        verifyFileLine.text = walletManager.urlToLocalPath(verifyFileDialog.fileUrl)
                    }
                }

                StandardButton {
                    id: loadFileToVerifyButton
                    anchors.rightMargin: 17 * scaleRatio
                    text: qsTr("Select") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    enabled: true
                    onClicked: {
                      verifyFileDialog.open()
                    }
                }
                LineEdit {
                    id: verifyFileLine
                    anchors.left: loadFileToVerifyButton.right
                    anchors.right: verifyFileButton.left
                    placeholderText: qsTr("Filename with message to verify") + translationManager.emptyString;
                    readOnly: false
                    Layout.fillWidth: true

                    IconButton {
                        imageSource: "../images/copyToClipboard.png"
                        onClicked: {
                            if (verifyFileLine.text.length > 0) {
                                clipboard.setText(verifyFileLine.text)
                            }
                        }
                    }
                }

                StandardButton {
                    id: verifyFileButton
                    anchors.right: parent.right
                    text: qsTr("Verify") + translationManager.emptyString
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#FF6C3C"
                    pressedColor: "#FF4304"
                    enabled: true
                    onClicked: {
                      var verified = appWindow.currentWallet.verifySignedMessage(verifyFileLine.text, verifyAddressLine.text, verifySignatureLine.text, true)
                      displayVerificationResult(verified)
                    }
                }
            }

            Text {
                id: verifyAddressLabel
                text: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>\
                            Signing address <font size='2'>  ( Paste in  or select from </font> <a href='#'>Address book</a><font size='2'> )</font>")
                      + translationManager.emptyString
                wrapMode: Text.Wrap
                font.pixelSize: 14 * scaleRatio
                Layout.fillWidth: true
                textFormat: Text.RichText
                onLinkActivated: appWindow.showPageRequest("AddressBook")
            }

            LineEdit {
                id: verifyAddressLine
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: verifyAddressLabel.bottom
                anchors.topMargin: 5 * scaleRatio
                placeholderText: "4..."
                // validator: RegExpValidator { regExp: /[0-9A-Fa-f]{95}/g }
            }

            ColumnLayout {
                id: verifySignatureRow
                anchors.topMargin: 17 * scaleRatio

                Label {
                    id: verifySignatureLabel
                    text: qsTr("Signature") + translationManager.emptyString
                    Layout.fillWidth: true
                }

                LineEdit {
                    id: verifySignatureLine
                    placeholderText: qsTr("Signature") + translationManager.emptyString;
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft

                    IconButton {
                        imageSource: "../images/copyToClipboard.png"
                        onClicked: {
                            if (verifySignatureLine.text.length > 0) {
                                clipboard.setText(verifySignatureLine.text)
                            }
                        }
                    }
                }
            }
        }
    }

    function onPageCompleted() {
        console.log("Sign/verify page loaded");
    }

}
