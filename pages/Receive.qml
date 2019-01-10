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

import "../components" as MoneroComponents
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
    property alias receiveHeight: mainLayout.height

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
        anchors.margins: (isMobile)? 17 * scaleRatio : 20 * scaleRatio
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

            MoneroComponents.LabelSubheader {
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Addresses")
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
                            anchors.topMargin: 5
                            anchors.rightMargin: 80
                            color: "transparent"

                            MoneroComponents.Label {
                                id: idLabel
                                color: index === appWindow.current_subaddress_table_index ? "white" : "#757575"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: "#" + index
                            }

                            MoneroComponents.Label {
                                id: nameLabel
                                color: "#a5a5a5"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: idLabel.right
                                anchors.leftMargin: 6
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: label
                            }

                            MoneroComponents.Label {
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

                        MoneroComponents.IconButton {
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

                        MoneroComponents.IconButton {
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
                        appWindow.current_subaddress_table_index = subaddressListView.currentIndex;
                        appWindow.current_address = appWindow.currentWallet.address(
                            appWindow.currentWallet.currentSubaddressAccount,
                            subaddressListView.currentIndex
                        );
                    }
                }
            }

            // 'fake' row for 'create new address'
            ColumnLayout {
                id: createAddressRow
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    color: "#404040"
                    Layout.fillWidth: true
                    height: 1
                }

                Rectangle {
                    id: createAddressRect
                    Layout.preferredHeight: subaddressListRow.subaddressListItemHeight
                    color: "transparent"
                    Layout.fillWidth: true

                    MoneroComponents.Label {
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
                                current_subaddress_table_index = appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1
                            }
                            inputDialog.onRejectedCallback = null;
                            inputDialog.open()
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.topMargin: 22 * scaleRatio
            MoneroComponents.CheckBox2 {
                id: showAdvancedCheckbox
                checked: persistentSettings.receiveShowAdvanced
                onClicked: {
                    persistentSettings.receiveShowAdvanced = !persistentSettings.receiveShowAdvanced
                }
                text: qsTr("Advanced options") + translationManager.emptyString
            }
        }

        RowLayout {
            Layout.topMargin: 6 * scaleRatio
            visible: persistentSettings.receiveShowAdvanced
            Layout.fillWidth: true

            MoneroComponents.LineEditMulti {
                id: paymentUrl
                Layout.fillWidth: true

                labelText: qsTr("Payment URL") + translationManager.emptyString
                text: TxUtils.makeQRCodeString(appWindow.current_address)
                readOnly: true
                copyButton: true
                wrapMode: Text.WrapAnywhere
            }
        }

        GridLayout{
            visible: persistentSettings.receiveShowAdvanced
            Layout.topMargin: 10 * scaleRatio
            columns: 2
            columnSpacing: 30 * scaleRatio

            RowLayout {
                property int qrSize: 220 * scaleRatio
                Layout.fillWidth: true

                Rectangle {
                    id: qrContainer
                    radius: 4 * scaleRatio
                    color: "white"
                    Layout.preferredWidth: parent.qrSize
                    Layout.preferredHeight: parent.qrSize

                    Image {
                        id: qrCode
                        anchors.fill: parent
                        anchors.margins: 1 * scaleRatio

                        smooth: false
                        fillMode: Image.PreserveAspectFit
                        source: "image://qrcode/" + TxUtils.makeQRCodeString(appWindow.current_address)

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: {
                                if (mouse.button == Qt.RightButton){
                                    qrMenu.x = this.mouseX;
                                    qrMenu.y = this.mouseY;
                                    qrMenu.open()
                                }
                            }
                            onPressAndHold: qrFileDialog.open()
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
                }
            }
        }

        MessageDialog {
            id: receivePageDialog
            standardButtons: StandardButton.Ok
        }

        FileDialog {
            id: qrFileDialog
            title: qsTr("Please choose a name")
            folder: shortcuts.pictures
            selectExisting: false
            nameFilters: ["Image (*.png)"]
            onAccepted: {
                if(!walletManager.saveQrCode(TxUtils.makeQRCodeString(appWindow.current_address), walletManager.urlToLocalPath(fileUrl))) {
                    console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                    receivePageDialog.title = qsTr("Save QrCode") + translationManager.emptyString;
                    receivePageDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                    receivePageDialog.icon = StandardIcon.Error
                    receivePageDialog.open()
                }
            }
        }
    }

    function onPageCompleted() {
        console.log("Receive page loaded");
        subaddressListView.model = appWindow.currentWallet.subaddressModel;

        if (appWindow.currentWallet) {
            appWindow.current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, 0)
            appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
        }
    }

    function clearFields() {
    }

    function onPageClosed() {
    }
}
