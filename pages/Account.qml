// Copyright (c) 2014-2019, The Monero Project
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
import "../js/TxUtils.js" as TxUtils

Rectangle {
    id: pageAccount
    color: "transparent"
    property var model
    property alias accountHeight: mainLayout.height
    property bool selectAndSend: false

    function renameSubaddressAccountLabel(_index){
        inputDialog.labelText = qsTr("Set the label of the selected account:") + translationManager.emptyString;
        inputDialog.inputText = appWindow.currentWallet.getSubaddressLabel(_index, 0);
        inputDialog.onAcceptedCallback = function() {
            appWindow.currentWallet.subaddressAccount.setLabel(_index, inputDialog.inputText)
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

        ColumnLayout {
            id: balanceRow
            visible: !selectAndSend
            spacing: 0

            MoneroComponents.LabelSubheader {
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Balance All")
            }

            RowLayout {
                Layout.topMargin: 22 * scaleRatio
                Text {
                    text: qsTr("Total balance: ")
                    Layout.fillWidth: true
                    color: "#757575"
                    font.pixelSize: 14
                    font.family: MoneroComponents.Style.fontRegular.name
                }
                Text {
                    id: balanceAll
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 14 
                    color: MoneroComponents.Style.white 
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            parent.color = MoneroComponents.Style.orange
                        }
                        onExited: {
                            parent.color = MoneroComponents.Style.white
                        }
                        onClicked: {
                                console.log("Copied to clipboard");
                                clipboard.setText(parent.text);
                                appWindow.showStatusMessage(qsTr("Copied to clipboard"),3)
                        }
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 10 * scaleRatio
                Text {
                    text: qsTr("Total unlocked balance: ")
                    Layout.fillWidth: true
                    color: "#757575"
                    font.pixelSize: 14 
                    font.family: MoneroComponents.Style.fontRegular.name
                }
                Text {
                    id: unlockedBalanceAll
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 14
                    color: MoneroComponents.Style.white
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            parent.color = MoneroComponents.Style.orange
                        }
                        onExited: {
                            parent.color = MoneroComponents.Style.white
                        }
                        onClicked: {
                                console.log("Copied to clipboard");
                                clipboard.setText(parent.text);
                                appWindow.showStatusMessage(qsTr("Copied to clipboard"),3)
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: addressRow
            spacing: 0

            MoneroComponents.LabelSubheader {
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Accounts")
            }

            ColumnLayout {
                id: subaddressAccountListRow
                property int subaddressAccountListItemHeight: 50 * scaleRatio
                Layout.topMargin: 6 * scaleRatio
                Layout.fillWidth: true
                Layout.minimumWidth: 240
                Layout.preferredHeight: subaddressAccountListItemHeight * subaddressAccountListView.count
                visible: subaddressAccountListView.count >= 1

                ListView {
                    id: subaddressAccountListView
                    Layout.fillWidth: true
                    anchors.fill: parent
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
                    delegate: Rectangle {
                        id: tableItem2
                        height: subaddressAccountListRow.subaddressAccountListItemHeight
                        width: parent.width
                        Layout.fillWidth: true
                        color: "transparent"
                        Rectangle {
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 1
                            color: "#404040"
                            visible: index !== 0
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 5 * scaleRatio
                            anchors.rightMargin: 80 * scaleRatio
                            color: "transparent"

                            MoneroComponents.Label {
                                id: idLabel
                                color: index === appWindow.current_subaddress_account_table_index ? "white" : "#757575"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6 * scaleRatio
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: "#" + index
                            }

                            MoneroComponents.Label {
                                id: nameLabel
                                color: "#a5a5a5"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: idLabel.right
                                anchors.leftMargin: 6 * scaleRatio
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: label
                                elide: Text.ElideRight
                                textWidth: addressLabel.x - nameLabel.x - 1
                            }

                            MoneroComponents.Label {
                                id: addressLabel
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: balanceLabel.left
                                anchors.leftMargin: (mainLayout.width < 510 ? -70 : -125) * scaleRatio
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: TxUtils.addressTruncate(address, mainLayout.width < 510 ? 3 : 6)
                            }

                            MoneroComponents.Label {
                                id: balanceLabel
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.right
                                anchors.leftMargin: (mainLayout.width < 510 ? -120 : -180) * scaleRatio
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: qsTr("Balance: ") + balance
                                elide: mainLayout.width < 510 ? Text.ElideRight : Text.ElideNone
                                textWidth: 120 
                            }

                            MouseArea {
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
                                    if (index == subaddressAccountListView.currentIndex && selectAndSend) {
                                        appWindow.showPageRequest("Transfer");
                                    }
                                    subaddressAccountListView.currentIndex = index;
                                }
                            }
                        }

                        MoneroComponents.IconButton {
                            id: renameButton
                            imageSource: "../images/editIcon.png"
                            anchors.right: parent.right
                            anchors.rightMargin: 30 * scaleRatio
                            anchors.topMargin: 1 * scaleRatio

                            onClicked: {
                                renameSubaddressAccountLabel(index);
                            }
                        }

                        MoneroComponents.IconButton {
                            id: copyButton
                            imageSource: "../images/dropdownCopy.png"
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
                        appWindow.current_subaddress_account_table_index = subaddressAccountListView.currentIndex;
                        appWindow.currentWallet.switchSubaddressAccount(appWindow.current_subaddress_account_table_index);
                        appWindow.onWalletUpdate();
                    }

                    onCurrentIndexChanged: {
                        if (selectAndSend) {
                            appWindow.showPageRequest("Transfer");
                        }
                    }
                }
            }

            Rectangle {
                color: "#404040"
                Layout.fillWidth: true
                height: 1
            }

            MoneroComponents.CheckBox { 
                id: addNewAccountCheckbox 
                visible: !selectAndSend
                border: false
                checkedIcon: "qrc:///images/plus-in-circle-medium-white.png" 
                uncheckedIcon: "qrc:///images/plus-in-circle-medium-white.png" 
                fontSize: 14 * scaleRatio 
                iconOnTheLeft: true
                Layout.fillWidth: true
                Layout.topMargin: 10 * scaleRatio
                text: qsTr("Create new account") + translationManager.emptyString; 
                onClicked: { 
                    inputDialog.labelText = qsTr("Set the label of the new account:") + translationManager.emptyString
                    inputDialog.inputText = qsTr("(Untitled)")
                    inputDialog.onAcceptedCallback = function() {
                        appWindow.currentWallet.subaddressAccount.addRow(inputDialog.inputText)
                        appWindow.currentWallet.switchSubaddressAccount(appWindow.currentWallet.numSubaddressAccounts() - 1)
                        current_subaddress_account_table_index = appWindow.currentWallet.numSubaddressAccounts() - 1
                        appWindow.onWalletUpdate();
                    }
                    inputDialog.onRejectedCallback = null;
                    inputDialog.open()
                }
            }
        }
    }

    function onPageCompleted() {
        console.log("account");
        if (appWindow.currentWallet !== undefined) {
            appWindow.currentWallet.subaddressAccount.refresh();
            subaddressAccountListView.model = appWindow.currentWallet.subaddressAccountModel;
            appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)

            balanceAll.text = walletManager.displayAmount(appWindow.currentWallet.balanceAll())
            unlockedBalanceAll.text = walletManager.displayAmount(appWindow.currentWallet.unlockedBalanceAll()) 
        }
    }

    function onPageClosed() {
        selectAndSend = false;
    }
}
