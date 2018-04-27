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
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import "../components"
import moneroComponents.Clipboard 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionHistoryModel 1.0
import moneroComponents.Subaddress 1.0
import moneroComponents.SubaddressModel 1.0

Rectangle {
    id: pageReceive
    color: "transparent"
    property var model
    property var current_address
    property alias addressText : pageReceive.current_address

    function makeQRCodeString() {
        var s = "monero:"
        var nfields = 0
        s += current_address;
        var amount = amountLine.text.trim()
        if (amount !== "") {
          s += (nfields++ ? "&" : "?")
          s += "tx_amount=" + amount
        }
        return s
    }

    function update() {
        if (!appWindow.currentWallet || !trackingEnabled.checked) {
            trackingLineText.text = "";
            return
        }
        if (appWindow.currentWallet.connected() == Wallet.ConnectionStatus_Disconnected) {
            trackingLineText.text = qsTr("WARNING: no connection to daemon");
            return
        }

        var model = appWindow.currentWallet.historyModel
        var count = model.rowCount()
        var totalAmount = 0
        var nTransactions = 0
        var blockchainHeight = 0
        var txs = []

        for (var i = 0; i < count; ++i) {
            var idx = model.index(i, 0)
            var isout = model.data(idx, TransactionHistoryModel.TransactionIsOutRole);
            var subaddrAccount = model.data(idx, TransactionHistoryModel.TransactionSubaddrAccountRole);
            var subaddrIndex = model.data(idx, TransactionHistoryModel.TransactionSubaddrIndexRole);
            if (!isout && subaddrAccount == appWindow.currentWallet.currentSubaddressAccount && subaddrIndex == table.currentIndex) {
                var amount = model.data(idx, TransactionHistoryModel.TransactionAtomicAmountRole);
                totalAmount = walletManager.addi(totalAmount, amount)
                nTransactions += 1

                var txid = model.data(idx, TransactionHistoryModel.TransactionHashRole);
                var blockHeight = model.data(idx, TransactionHistoryModel.TransactionBlockHeightRole);

                var in_txpool = false;
                var confirmations = 0;
                var displayAmount = 0;

                if (blockHeight == 0) {
                    in_txpool = true;
                } else {
                    if (blockchainHeight == 0)
                        blockchainHeight = walletManager.blockchainHeight()
                    confirmations = blockchainHeight - blockHeight - 1
                    displayAmount = model.data(idx, TransactionHistoryModel.TransactionDisplayAmountRole);
                }

                txs.push({
                    "amount": displayAmount,
                    "confirmations": confirmations,
                    "blockheight": blockHeight,
                    "in_txpool": in_txpool,
                    "txid": txid
                })
            }
        }

        // Update tracking status label
        if (nTransactions == 0) {
            trackingLineText.text = qsTr("No transaction found yet...") + translationManager.emptyString
            return
        }
        else if(nTransactions === 1){
            trackingLineText.text = qsTr("Transaction found") + translationManager.emptyString;
        } else {
            trackingLineText.text = qsTr("%1 transactions found").arg(nTransactions) + translationManager.emptyString
        }

        var max_tracking = 3;

        var expectedAmount = walletManager.amountFromString(amountLine.text)
        if (expectedAmount && expectedAmount != amount) {
            var displayTotalAmount = walletManager.displayAmount(totalAmount)
            if (amount > expectedAmount) {

                text += qsTr(" with more money (%1)").arg(displayTotalAmount) + translationManager.emptyString
            } else if (amount < expectedAmount) {
                text += qsTr(" with not enough money (%1)").arg(displayTotalAmount) + translationManager.emptyString
            }
        }

        trackingModel.clear();

        if (txs.length > 3) {
            txs.length = 3;
        }

        txs.forEach(function(tx){
            trackingModel.append({
                "amount": tx.amount,
                "confirmations": tx.confirmations,
                "blockheight": tx.blockHeight,
                "in_txpool": tx.in_txpool,
                "txid": tx.txid
            });
        });

        //setTrackingLineText(text + "<br>" + list.join("<br>"))
    }

    Clipboard { id: clipboard }

    /* main layout */
    ColumnLayout {
        id: mainLayout
        anchors.margins: (isMobile)? 17 : 40
        anchors.topMargin: 40 * scaleRatio

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20 * scaleRatio
        property int labelWidth: 120 * scaleRatio
        property int editWidth: 400 * scaleRatio
        property int lineEditFontSize: 12 * scaleRatio
        property int qrCodeSize: 220 * scaleRatio

        ColumnLayout {
            id: addressRow
            spacing: 0
            Label {
                id: addressLabel
                text: qsTr("Addresses") + translationManager.emptyString
                width: mainLayout.labelWidth
            }

            Rectangle {
                id: header
                Layout.fillWidth: true
                Layout.topMargin: 10
                visible: table.count > 0

                height: 10
                color: "transparent"

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.leftMargin: 10

                    height: 1
                    color: "#404040"
                }

                Image {
                    anchors.top: parent.top
                    anchors.left: parent.left

                    width: 10
                    height: 10

                    source: "../images/historyBorderRadius.png"
                }

                Image {
                    anchors.top: parent.top
                    anchors.right: parent.right

                    width: 10
                    height: 10

                    source: "../images/historyBorderRadius.png"
                    rotation: 90
                }
            }

            Rectangle {
                id: tableRect
                property int table_max_height: 260
                Layout.fillWidth: true
                Layout.preferredHeight: table.contentHeight < table_max_height ? table.contentHeight : table_max_height
                color: "transparent"

                Scroll {
                    id: flickableScroll
                    anchors.right: table.right
                    anchors.top: table.top
                    anchors.bottom: table.bottom
                    flickable: table
                }

                SubaddressTable {
                    id: table
                    anchors.fill: parent
                    onContentYChanged: flickableScroll.flickableContentYChanged()
                    onCurrentItemChanged: {
                        current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, table.currentIndex);
                    }
                }
            }

            RowLayout {
                spacing: 20
                Layout.topMargin: 20

                StandardButton {
                    small: true
                    text: qsTr("Create new address") + translationManager.emptyString;
                    onClicked: {
                        inputDialog.labelText = qsTr("Set the label of the new address:") + translationManager.emptyString
                        inputDialog.inputText = qsTr("(Untitled)")
                        inputDialog.onAcceptedCallback = function() {
                            appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, inputDialog.inputText)
                            table.currentIndex = appWindow.currentWallet.numSubaddresses() - 1
                        }
                        inputDialog.onRejectedCallback = null;
                        inputDialog.open()
                    }
                }

                StandardButton {
                    small: true
                    enabled: table.currentIndex > 0
                    text: qsTr("Rename") + translationManager.emptyString;
                    onClicked: {
                        inputDialog.labelText = qsTr("Set the label of the selected address:") + translationManager.emptyString
                        inputDialog.inputText = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, table.currentIndex)
                        inputDialog.onAcceptedCallback = function() {
                            appWindow.currentWallet.subaddress.setLabel(appWindow.currentWallet.currentSubaddressAccount, table.currentIndex, inputDialog.inputText)
                        }
                        inputDialog.onRejectedCallback = null;
                        inputDialog.open()
                    }
                }
            }
        }

        GridLayout {
            columns: (isMobile)? 1 : 2
            Layout.fillWidth: true
            columnSpacing: 32 * scaleRatio

            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                spacing: 20 * scaleRatio

                LabelSubheader {
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>" +
                          qsTr("QR Code") +
                          "<font size='2'> </font><a href='#'>" +
                          qsTr("Help") + "</a>" +
                          translationManager.emptyString
                    onLinkActivated: {
                        trackingHowToUseDialog.title  = qsTr("QR Code") + translationManager.emptyString;
                        trackingHowToUseDialog.text = qsTr(
                            "<p>This QR code includes the address you selected above and" +
                            "the amount you entered below. Share it with others (right-click->Save) " +
                            "so they can more easily send you exact amounts.</p>"
                        )
                        trackingHowToUseDialog.icon = StandardIcon.Information
                        trackingHowToUseDialog.open()
                    }
                }

                ColumnLayout {
                    id: amountRow

                    Layout.fillWidth: true
                    Layout.minimumWidth: 200
                    Layout.maximumWidth: mainLayout.qrCodeSize

                    LineEdit {
                        id: amountLine
                        Layout.fillWidth: true
                        labelText: qsTr("Amount") + translationManager.emptyString
                        placeholderText: qsTr("Amount to receive") + translationManager.emptyString
                        fontBold: true
                        inlineIcon: true
                        validator: DoubleValidator {
                            bottom: 0.0
                            top: 18446744.073709551615
                            decimals: 12
                            notation: DoubleValidator.StandardNotation
                            locale: "C"
                        }
                    }
                }

                Rectangle {
                    color: "white"
                    Layout.topMargin: parent.spacing - 4
                    Layout.fillWidth: true
                    Layout.maximumWidth: mainLayout.qrCodeSize
                    Layout.preferredHeight: width
                    radius: 4

                    Image {
                        id: qrCode
                        anchors.fill: parent
                        anchors.margins: 6

                        smooth: false
                        fillMode: Image.PreserveAspectFit
                        source: "image://qrcode/" + makeQRCodeString()
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: {
                                if (mouse.button == Qt.RightButton)
                                    qrMenu.open()
                            }
                            onPressAndHold: qrFileDialog.open()
                        }
                    }

                    Menu {
                        id: qrMenu
                        title: "QrCode"
                        y: parent.height / 2

                        MenuItem {
                           text: qsTr("Save As") + translationManager.emptyString;
                           onTriggered: qrFileDialog.open()
                        }
                    }
                }
            }

            ColumnLayout {
                id: trackingRow
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                spacing: 0 * scaleRatio

                LabelSubheader {
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>" +
                          qsTr("Tracking") +
                          "<font size='2'> </font><a href='#'>" +
                          qsTr("Help") + "</a>" +
                          translationManager.emptyString
                    onLinkActivated: {
                        trackingHowToUseDialog.title  = qsTr("Tracking payments") + translationManager.emptyString;
                        trackingHowToUseDialog.text = qsTr(
                            "<p><font size='+2'>This is a simple sales tracker:</font></p>" +
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

                ListModel {
                    id: trackingModel
                }

                RowLayout{
                    Layout.topMargin: 14
                    Layout.bottomMargin: 10
                    visible: trackingTableRow.visible

                    Label {
                        id: trackingLineText
                        color: "white"
                        fontFamily: Style.fontLight.name
                        fontSize: 16 * scaleRatio
                        text: ""
                    }
                }

                ColumnLayout {
                    id: trackingTableRow
                    visible: vv.count >= 1
                    Layout.fillWidth: true
                    Layout.minimumWidth: 240
                    Layout.preferredHeight: 46 * vv.count

                    ListView {
                        id: vv
                        Layout.fillWidth: true
                        anchors.fill: parent
                        clip: true
                        boundsBehavior: ListView.StopAtBounds
                        model: trackingModel
                        delegate: Item {
                            id: trackingTableItem
                            height: 46
                            width: parent.width
                            Layout.fillWidth: true

                            Rectangle{
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.top: parent.top
                                height: 1
                                color: "#404040"
                                visible: index !== 0
                            }

                            Image {
                                id: arrowImage
                                source: "../images/upArrow-green.png"
                                height: 18 * scaleRatio
                                width: 12 * scaleRatio
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                            }

                            Label {
                                id: trackingConfirmationLine
                                color: "white"
                                anchors.top: parent.top
                                anchors.topMargin: 6
                                anchors.left: arrowImage.right
                                anchors.leftMargin: 10
                                fontSize: 14 * scaleRatio
                                text: {
                                    if(in_txpool){
                                        return "Awaiting in txpool"
                                    } else {
                                        if(confirmations > 1){
                                            if(confirmations > 100){
                                                return "100+ " + qsTr("confirmations") + translationManager.emptyString;
                                            } else {
                                                return confirmations + " " + qsTr("confirmations") + translationManager.emptyString;
                                            }
                                        } else {
                                            return "1 " + qsTr("confirmation") + translationManager.emptyString;
                                        }
                                    }
                                }
                            }

                            Label {
                                id: trackingAmountLine
                                color: "#2eb358"
                                anchors.top: trackingConfirmationLine.bottom
                                anchors.left: arrowImage.right
                                anchors.leftMargin: 10
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: amount
                            }

                            IconButton {
                                id: clipboardButton
                                imageSource: "../images/copyToClipboard.png"

                                onClicked: {
                                    console.log("tx_id copied to clipboard");
                                    clipboard.setText(txid);
                                    appWindow.showStatusMessage(qsTr("Transaction ID copied to clipboard"),3);
                                }

                                anchors.right: parent.right
                                anchors.rightMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.topMargin: 32 * scaleRatio
                    Layout.fillWidth: true
                    Layout.minimumWidth: 200

                    CheckBox {
                        id: trackingEnabled
                        text: qsTr("Enable") + translationManager.emptyString
                    }
                }
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
            nameFilters: ["Image (*.png)"]
            onAccepted: {
                if(!walletManager.saveQrCode(makeQRCodeString(), walletManager.urlToLocalPath(fileUrl))) {
                    console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                    trackingHowToUseDialog.title = qsTr("Save QrCode") + translationManager.emptyString;
                    trackingHowToUseDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                    trackingHowToUseDialog.icon = StandardIcon.Error
                    trackingHowToUseDialog.open()
                }
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
        table.model = currentWallet.subaddressModel;

        if (appWindow.currentWallet) {
            current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, 0)
            appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
            table.currentIndex = 0
        }

        update()
        timer.running = true

        trackingEnabled.checked = false
    }

    function onPageClosed() {
        timer.running = false
    }
}
