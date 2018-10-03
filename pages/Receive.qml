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
import "../js/TxUtils.js" as TxUtils

Rectangle {
    id: pageReceive
    color: "transparent"
    property var model
    property var current_address
    property int current_subaddress_table_index: 0
    property bool advancedRowVisible: false
    property alias receiveHeight: mainLayout.height
    property alias addressText : pageReceive.current_address

    function makeQRCodeString() {
        var s = "monero:"
        var nfields = 0
        s += current_address;
        var amount = amountToReceiveLine.text.trim()
        if (amount !== "" && amount.slice(-1) !== ".") {
          s += (nfields++ ? "&" : "?")
          s += "tx_amount=" + amount
        }
        return s
    }

    function update() {
        if (!appWindow.currentWallet || !trackingEnabled.checked) {
            trackingLineText.text = "";
            trackingModel.clear();
            return
        }
        if (appWindow.currentWallet.connected() == Wallet.ConnectionStatus_Disconnected) {
            trackingLineText.text = qsTr("WARNING: no connection to daemon");
            trackingModel.clear();
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
            if (!isout && subaddrAccount == appWindow.currentWallet.currentSubaddressAccount && subaddrIndex == current_subaddress_table_index) {
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
            trackingLineText.text = qsTr("Transaction found") + ":" + translationManager.emptyString;
        } else {
            trackingLineText.text = qsTr("%1 transactions found").arg(nTransactions) + ":" + translationManager.emptyString
        }

        var max_tracking = 3;
        toReceiveSatisfiedLine.text = "";
        var expectedAmount = walletManager.amountFromString(amountToReceiveLine.text)
        if (expectedAmount && expectedAmount != amount) {
            var displayTotalAmount = walletManager.displayAmount(totalAmount)
            if (amount > expectedAmount) toReceiveSatisfiedLine.text += qsTr("With more Monero");
            else if (amount < expectedAmount) toReceiveSatisfiedLine.text = qsTr("With not enough Monero")
            toReceiveSatisfiedLine.text += ": " + "<br>" +
                    qsTr("Expected") + ": " + amountToReceiveLine.text + "<br>" +
                    qsTr("Total received") + ": " + displayTotalAmount + translationManager.emptyString;
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

    function renameSubaddressLabel(_index){
        inputDialog.labelText = qsTr("Set the label of the selected address:") + translationManager.emptyString;
        inputDialog.inputText = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, _index);
        inputDialog.onAcceptedCallback = function() {
            appWindow.currentWallet.subaddress.setLabel(appWindow.currentWallet.currentSubaddressAccount, _index, inputDialog.inputText);
        }
        inputDialog.onRejectedCallback = null;
        inputDialog.open()
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

            LabelSubheader {
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>" +
                      qsTr("Addresses") +
                      "<font size='2'> </font><a href='#'>" +
                      qsTr("Help") + "</a>" +
                      translationManager.emptyString
                onLinkActivated: {
                    receivePageDialog.title  = qsTr("Tracking payments") + translationManager.emptyString;
                    receivePageDialog.text = qsTr(
                        "<p>This QR code includes the address you selected above and" +
                        "the amount you entered below. Share it with others (right-click->Save) " +
                        "so they can more easily send you exact amounts.</p>"
                    )
                    receivePageDialog.icon = StandardIcon.Information
                    receivePageDialog.open()
                }
            }

            ColumnLayout {
                id: subaddressListRow
                property int subaddressListItemHeight: 32 * scaleRatio
                Layout.topMargin: 22 * scaleRatio
                Layout.fillWidth: true
                Layout.minimumWidth: 240
                Layout.preferredHeight: subaddressListItemHeight * subaddressListView.count
                visible: subaddressListView.count >= 1

                ListView {
                    id: subaddressListView
                    Layout.fillWidth: true
                    anchors.fill: parent
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
                    delegate: Rectangle {
                        id: tableItem2
                        height: subaddressListRow.subaddressListItemHeight
                        width: parent.width
                        Layout.fillWidth: true
                        color: "transparent"

                        Rectangle{
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 1
                            color: "#404040"
                            visible: index !== 0
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.rightMargin: 80
                            color: "transparent"

                            Label {
                                id: idLabel
                                color: index === current_subaddress_table_index ? "white" : "#757575"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: "#" + index
                            }

                            Label {
                                id: nameLabel
                                color: "#a5a5a5"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: idLabel.right
                                anchors.leftMargin: 6
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: label
                            }

                            Label {
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: nameLabel.right
                                anchors.leftMargin: 6
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: {
                                    if(isMobile){
                                        TxUtils.addressTruncate(address, 6);
                                    } else {
                                        return TxUtils.addressTruncate(address, 10);
                                    }
                                }
                            }

                            MouseArea{
                                cursorShape: Qt.PointingHandCursor
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    tableItem2.color = "#26FFFFFF"
                                }
                                onExited: {
                                    tableItem2.color = "transparent"
                                }
                                onClicked: {
                                    subaddressListView.currentIndex = index;
                                }
                            }
                        }

                        IconButton {
                            id: renameButton
                            imageSource: "../images/editIcon.png"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: index !== 0 ? copyButton.left : parent.right
                            anchors.rightMargin: index !== 0 ? 0 : 6
                            anchors.top: undefined
                            visible: index !== 0

                            onClicked: {
                                renameSubaddressLabel(index);
                            }
                        }

                        IconButton {
                            id: copyButton
                            imageSource: "../images/copyToClipboard.png"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.top: undefined
                            anchors.right: parent.right

                            onClicked: {
                                console.log("Address copied to clipboard");
                                clipboard.setText(address);
                                appWindow.showStatusMessage(qsTr("Address copied to clipboard"),3);
                            }
                        }
                    }
                    onCurrentItemChanged: {
                        // reset global vars
                        current_subaddress_table_index = subaddressListView.currentIndex;
                        current_address = appWindow.currentWallet.address(
                            appWindow.currentWallet.currentSubaddressAccount,
                            subaddressListView.currentIndex
                        );

                        // reset tracking table
                        trackingModel.clear();
                    }
                }
            }

            // 'fake' row for 'create new address'
            ColumnLayout{
                id: createAddressRow
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    color: "#404040"
                    Layout.fillWidth: true
                    height: 1
                }

                Rectangle{
                    id: createAddressRect
                    Layout.preferredHeight: subaddressListRow.subaddressListItemHeight
                    color: "transparent"
                    Layout.fillWidth: true

                    Label {
                        color: "#757575"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 6
                        fontSize: 14 * scaleRatio
                        fontBold: true
                        text: "+ " + qsTr("Create new address") + translationManager.emptyString;
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            createAddressRect.color = "#26FFFFFF"
                        }
                        onExited: {
                            createAddressRect.color = "transparent"
                        }
                        onClicked: {
                            inputDialog.labelText = qsTr("Set the label of the new address:") + translationManager.emptyString
                            inputDialog.inputText = qsTr("(Untitled)")
                            inputDialog.onAcceptedCallback = function() {
                                appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, inputDialog.inputText)
                                current_subaddress_table_index = appWindow.currentWallet.numSubaddresses() - 1
                            }
                            inputDialog.onRejectedCallback = null;
                            inputDialog.open()
                        }
                    }
                }
            }
        }

        RowLayout {
            CheckBox2 {
                id: showAdvancedCheckbox
                checked: false
                onClicked: {
                    advancedRowVisible = !advancedRowVisible;
                }
                text: qsTr("Advanced options") + translationManager.emptyString
            }
        }
        
        GridLayout {
            id: advancedRow
            columns: (isMobile)? 1 : 2
            Layout.fillWidth: true
            columnSpacing: 32 * scaleRatio
            visible: advancedRowVisible

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
                        receivePageDialog.title  = qsTr("QR Code") + translationManager.emptyString;
                        receivePageDialog.text = qsTr(
                            "<p>This QR code includes the address you selected above and " +
                            "the amount you entered below. Share it with others (right-click->Save) " +
                            "so they can more easily send you exact amounts.</p>"
                        )
                        receivePageDialog.icon = StandardIcon.Information
                        receivePageDialog.open()
                    }
                }

                ColumnLayout {
                    id: amountRow

                    Layout.fillWidth: true
                    Layout.minimumWidth: 200
                    Layout.maximumWidth: mainLayout.qrCodeSize

                    LineEdit {
                        id: amountToReceiveLine
                        Layout.fillWidth: true
                        labelText: qsTr("Amount") + translationManager.emptyString
                        placeholderText: qsTr("Amount to receive") + translationManager.emptyString
                        fontBold: true
                        inlineIcon: true
                        validator: RegExpValidator {
                            regExp: /(\d{1,8})([.]\d{1,12})?$/
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
                        receivePageDialog.title  = qsTr("Tracking payments") + translationManager.emptyString;
                        receivePageDialog.text = qsTr(
                            "<p><font size='+2'>This is a simple sales tracker:</font></p>" +
                            "<p>Let your customer scan that QR code to make a payment (if that customer has software which " +
                            "supports QR code scanning).</p>" +
                            "<p>This page will automatically scan the blockchain and the tx pool " +
                            "for incoming transactions using this QR code. If you input an amount, it will also check " +
                            "that incoming transactions total up to that amount.</p>" +
                            "<p>It's up to you whether to accept unconfirmed transactions or not. It is likely they'll be " +
                            "confirmed in short order, but there is still a possibility they might not, so for larger " +
                            "values you may want to wait for one or more confirmation(s).</p>"
                        )
                        receivePageDialog.icon = StandardIcon.Information
                        receivePageDialog.open()
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
                    visible: trackingListView.count >= 1
                    Layout.fillWidth: true
                    Layout.minimumWidth: 240
                    Layout.preferredHeight: 46 * trackingListView.count

                    ListView {
                        id: trackingListView
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
                                anchors.leftMargin: 8
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
                                anchors.top: undefined
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                RowLayout {
                    visible: trackingTableRow.visible && x.text !== "" && amountToReceiveLine.text !== ""
                    Layout.topMargin: 14 * scaleRatio
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40 * scaleRatio

                    Label {
                        id: toReceiveSatisfiedLine
                        color: "white"
                        fontFamily: Style.fontLight.name
                        fontSize: 14 * scaleRatio
                        textFormat: Text.RichText
                        text: ""
                        height: 40 * scaleRatio
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 200
                    Layout.topMargin: trackingTableRow.visible ? 20 * scaleRatio : 32 * scaleRatio

                    CheckBox {
                        id: trackingEnabled
                        text: qsTr("Enable") + translationManager.emptyString
                    }
                }
            }
        }

        MessageDialog {
            id: receivePageDialog
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
                    receivePageDialog.title = qsTr("Save QrCode") + translationManager.emptyString;
                    receivePageDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                    receivePageDialog.icon = StandardIcon.Error
                    receivePageDialog.open()
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
        subaddressListView.model = appWindow.currentWallet.subaddressModel;

        if (appWindow.currentWallet) {
            current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, 0)
            appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
            current_subaddress_table_index = 0;
            subaddressListView.currentIndex = 0;
        }

        update()
        timer.running = true

        trackingEnabled.checked = false
    }

    function onPageClosed() {
        timer.running = false
        trackingEnabled.checked = false
        trackingModel.clear()
    }
}
