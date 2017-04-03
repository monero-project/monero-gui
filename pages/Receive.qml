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
import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionHistoryModel 1.0

Rectangle {

    color: "#F0EEEE"
    property alias addressText : addressLine.text
    property alias paymentIdText : paymentIdLine.text
    property alias integratedAddressText : integratedAddressLine.text
    property var model
    property string trackingLineText: ""

    function updatePaymentId(payment_id) {
        if (typeof appWindow.currentWallet === 'undefined' || appWindow.currentWallet == null)
            return

        // generate a new one if not given as argument
        if (typeof payment_id === 'undefined') {
            payment_id = appWindow.currentWallet.generatePaymentId()
            paymentIdLine.text = payment_id
        }

        if (payment_id.length > 0) {
            integratedAddressLine.text = appWindow.currentWallet.integratedAddress(payment_id)
            if (integratedAddressLine.text === "")
              integratedAddressLine.text = qsTr("Invalid payment ID")
        }
        else {
            paymentIdLine.text = ""
            integratedAddressLine.text = ""
        }

        update()
    }

    function makeQRCodeString() {
        var s = "monero:"
        var nfields = 0
        s += addressLine.text
        var amount = amountLine.text.trim()
        if (amount !== "") {
          s += (nfields++ ? "&" : "?")
          s += "tx_amount=" + amount
        }
        var pid = paymentIdLine.text.trim()
        if (pid !== "") {
          s += (nfields++ ? "&" : "?")
          s += "tx_payment_id=" + pid
        }
        return s
    }

    function setTrackingLineText(text) {
        // don't replace with same text, it wrecks selection while the user is selecting
        // also keep track of text, because when we read back the text from the widget,
        // we do not get what we put it, but some extra HTML stuff on top
        if (text != trackingLineText) {
            trackingLine.text = text
            trackingLineText = text
        }
    }

    function update() {
        if (!appWindow.currentWallet) {
            setTrackingLineText("-")
            return
        }
        if (appWindow.currentWallet.connected() == Wallet.ConnectionStatus_Disconnected) {
            setTrackingLineText(qsTr("WARNING: no connection to daemon"))
            return
        }

        var model = appWindow.currentWallet.historyModel
        var count = model.rowCount()
        var totalAmount = 0
        var nTransactions = 0
        var list = ""
        var blockchainHeight = 0
        for (var i = 0; i < count; ++i) {
            var idx = model.index(i, 0)
            var isout = model.data(idx, TransactionHistoryModel.TransactionIsOutRole);
            var payment_id = model.data(idx, TransactionHistoryModel.TransactionPaymentIdRole);
            if (!isout && payment_id == paymentIdLine.text) {
                var amount = model.data(idx, TransactionHistoryModel.TransactionAtomicAmountRole);
                totalAmount = walletManager.addi(totalAmount, amount)
                nTransactions += 1

                var txid = model.data(idx, TransactionHistoryModel.TransactionHashRole);
                var blockHeight = model.data(idx, TransactionHistoryModel.TransactionBlockHeightRole);
                if (blockHeight == 0) {
                    list += qsTr("in the txpool: %1").arg(txid) + translationManager.emptyString
                } else {
                    if (blockchainHeight == 0)
                        blockchainHeight = walletManager.blockchainHeight()
                    var confirmations = blockchainHeight - blockHeight - 1
                    var displayAmount = model.data(idx, TransactionHistoryModel.TransactionDisplayAmountRole);
                    if (confirmations > 1) {
                        list += qsTr("%2 confirmations: %3 (%1)").arg(txid).arg(confirmations).arg(displayAmount) + translationManager.emptyString
                    } else {
                        list += qsTr("1 confirmation: %2 (%1)").arg(txid).arg(displayAmount) + translationManager.emptyString
                    }
                }
                list += "<br>"
            }
        }

        if (nTransactions == 0) {
            setTrackingLineText(qsTr("No transaction found yet...") + translationManager.emptyString)
            return
        }

        var text = ((nTransactions == 1) ? qsTr("Transaction found") : qsTr("%1 transactions found").arg(nTransactions)) + translationManager.emptyString

        var expectedAmount = walletManager.amountFromString(amountLine.text)
        if (expectedAmount && expectedAmount != amount) {
            var displayTotalAmount = walletManager.displayAmount(totalAmount)
            if (amount > expectedAmount) {
                text += qsTr(" with more money (%1)").arg(displayTotalAmount) + translationManager.emptyString
            } else if (amount < expectedAmount) {
                text += qsTr(" with not enough money (%1)").arg(displayTotalAmount) + translationManager.emptyString
            }
        }

        setTrackingLineText(text + "<br>" + list)
    }

    Clipboard { id: clipboard }


    /* main layout */
    ColumnLayout {
        id: mainLayout
        anchors.margins: (isMobile)? 17 : 40
        anchors.topMargin: 40

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20
        property int labelWidth: 120
        property int editWidth: 400
        property int lineEditFontSize: 12
        property int qrCodeSize: 240


        ColumnLayout {
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
                placeholderText: qsTr("ReadOnly wallet address displayed here") + translationManager.emptyString;
                readOnly: true
                width: mainLayout.editWidth
                Layout.fillWidth: true
                onTextChanged: cursorPosition = 0

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (addressLine.text.length > 0) {
                            console.log(addressLine.text + " copied to clipboard")
                            clipboard.setText(addressLine.text)
                        }
                    }
                }
            }
        }

        GridLayout {
            id: paymentIdRow
            columns:2
            Label {
                Layout.columnSpan: 2
                id: paymentIdLabel
                fontSize: 14
                text: qsTr("Payment ID") + translationManager.emptyString
                width: mainLayout.labelWidth
            }


            LineEdit {
                id: paymentIdLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("16 hexadecimal characters") + translationManager.emptyString;
                readOnly: false
                onTextChanged: updatePaymentId(paymentIdLine.text)

                width: mainLayout.editWidth
                Layout.fillWidth: true

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (paymentIdLine.text.length > 0) {
                            clipboard.setText(paymentIdLine.text)
                        }
                    }
                }
            }

            StandardButton {
                id: generatePaymentId
                width: 80
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Generate") + translationManager.emptyString;
                onClicked: updatePaymentId()
            }

            StandardButton {
                id: clearPaymentId
                enabled: !!paymentIdLine.text
                width: 80
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Clear") + translationManager.emptyString;
                onClicked: updatePaymentId("")
            }
        }
         
        ColumnLayout {
            id: integratedAddressRow
            Label {
                id: integratedAddressLabel
                fontSize: 14
                text: qsTr("Integrated address") + translationManager.emptyString
                width: mainLayout.labelWidth
            }


            LineEdit {

                id: integratedAddressLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Generate payment ID for integrated address") + translationManager.emptyString
                readOnly: true
                width: mainLayout.editWidth
                Layout.fillWidth: true

                onTextChanged: cursorPosition = 0

                IconButton {
                    imageSource: "../images/copyToClipboard.png"
                    onClicked: {
                        if (integratedAddressLine.text.length > 0) {
                            clipboard.setText(integratedAddressLine.text)
                        }
                    }
                }

            }
        }

        ColumnLayout {
            id: amountRow
            Label {
                id: amountLabel
                fontSize: 14
                text: qsTr("Amount") + translationManager.emptyString
                width: mainLayout.labelWidth
            }


            LineEdit {
                id: amountLine
                fontSize: mainLayout.lineEditFontSize
                placeholderText: qsTr("Amount to receive") + translationManager.emptyString
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
            id: trackingRow

            Label {
                id: trackingLabel
                fontSize: 14
                textFormat: Text.RichText
                text: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>\
                           Tracking <font size='2'> (</font><a href='#'>help</a><font size='2'>)</font>")
                           + translationManager.emptyString
                width: mainLayout.labelWidth
                onLinkActivated: {
                    trackingHowToUseDialog.title  = qsTr("Tracking payments") + translationManager.emptyString;
                    trackingHowToUseDialog.text = qsTr(
                        "<p><font size='+2'>This is a simple sales tracker:</font></p>" +
                        "<p>Click Generate to create a random payment id for a new customer</p> " +
                        "<p>Let your customer scan that QR code to make a payment (if that customer has software which " +
                        "supports QR code scanning).</p>" +
                        "<p>This page will automatically scan the blockchain and the tx pool " +
                        "for incoming transactions using this QR code. If you input an amount, it will also check " +
                        "that incoming transactions total up to that amount.</p>" +
                        "It's up to you whether to accept unconfirmed transactions or not. It is likely they'll be " +
                        "confirmed in short order, but there is still a possibility they might not, so for larger " +
                        "values you may want to wait for one or more confirmation(s).</p>"
                    )
                    trackingHowToUseDialog.icon = StandardIcon.Information
                    trackingHowToUseDialog.open()
                }
            }

            TextEdit {
                id: trackingLine
                anchors.top: trackingRow.top
                textFormat: Text.RichText
                text: ""
                readOnly: true
                width: mainLayout.editWidth
                Layout.fillWidth: true
                selectByMouse: true
            }

        }

        MessageDialog {
            id: trackingHowToUseDialog
            standardButtons: StandardButton.Ok
        }

        FileDialog {
            id: qrFileDialog
            title: "Please choose a name"
            folder: shortcuts.pictures
            selectExisting: false
            nameFilters: [ "Image (*.png)"]
            onAccepted: {
                if( ! walletManager.saveQrCode(makeQRCodeString(), walletManager.urlToLocalPath(fileUrl))) {
                    console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                    trackingHowToUseDialog.title  = qsTr("Save QrCode") + translationManager.emptyString;
                    trackingHowToUseDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                    trackingHowToUseDialog.icon = StandardIcon.Error
                    trackingHowToUseDialog.open()
                }
            }
        }

        Menu {
            id: qrMenu
            title: "QrCode"
            MenuItem {
               text: qsTr("Save As") + translationManager.emptyString;
               onTriggered: qrFileDialog.open()
            }
        }

        Image {
            id: qrCode
            anchors.margins: 50
            anchors.top: trackingRow.bottom
            Layout.fillWidth: true
            Layout.minimumHeight: mainLayout.qrCodeSize
            smooth: false
            fillMode: Image.PreserveAspectFit
            source: "image://qrcode/" + makeQRCodeString()
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton)
                        qrMenu.popup()
                }
                onPressAndHold: qrFileDialog.open()
            }
        }
    }

    Timer {
        id: timer
        interval: 2000; running: false; repeat: true
        onTriggered: update()
    }

    function onPageCompleted() {
        console.log("Receive page loaded");

        if (appWindow.currentWallet) {
            if (addressLine.text.length === 0 || addressLine.text !== appWindow.currentWallet.address) {
                addressLine.text = appWindow.currentWallet.address
            }
        }

        update()
        timer.running = true
    }

    function onPageClosed() {
        timer.running = false
    }
}
