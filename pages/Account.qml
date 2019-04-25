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

import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

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
        anchors.margins: (isMobile)? 17 : 20
        anchors.topMargin: 40

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20

        ColumnLayout {
            id: balanceRow
            visible: !selectAndSend
            spacing: 0

            MoneroComponents.LabelSubheader {
                Layout.fillWidth: true
                fontSize: 24
                textFormat: Text.RichText
                text: qsTr("Balance All") + translationManager.emptyString
            }

            RowLayout {
                Layout.topMargin: 22

                MoneroComponents.TextPlain {
                    text: qsTr("Total balance: ") + translationManager.emptyString
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.defaultFontColor
                    font.pixelSize: 16
                    font.family: MoneroComponents.Style.fontRegular.name
                    themeTransition: false
                }

                MoneroComponents.TextPlain {
                    id: balanceAll
                    font.family: MoneroComponents.Style.fontMonoRegular.name;
                    font.pixelSize: 16
                    color: MoneroComponents.Style.dimmedFontColor
                    themeTransition: false

                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = MoneroComponents.Style.orange
                        onExited: parent.color = MoneroComponents.Style.defaultFontColor
                        onClicked: {
                            console.log("Copied to clipboard");
                            clipboard.setText(parent.text);
                            appWindow.showStatusMessage(qsTr("Copied to clipboard"),3)
                        }
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 10

                MoneroComponents.TextPlain {
                    text: qsTr("Total unlocked balance: ") + translationManager.emptyString
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.defaultFontColor
                    font.pixelSize: 16
                    font.family: MoneroComponents.Style.fontRegular.name
                    themeTransition: false
                }

                MoneroComponents.TextPlain {
                    id: unlockedBalanceAll
                    font.family: MoneroComponents.Style.fontMonoRegular.name;
                    font.pixelSize: 16
                    color: MoneroComponents.Style.dimmedFontColor
                    themeTransition: false

                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = MoneroComponents.Style.orange
                        onExited: parent.color = MoneroComponents.Style.defaultFontColor
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
                fontSize: 24
                textFormat: Text.RichText
                text: qsTr("Accounts") + translationManager.emptyString
            }

            ColumnLayout {
                id: subaddressAccountListRow
                property int subaddressAccountListItemHeight: 50
                Layout.topMargin: 6
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
                    interactive: false

                    delegate: Rectangle {
                        id: tableItem2
                        height: subaddressAccountListRow.subaddressAccountListItemHeight
                        width: parent.width
                        Layout.fillWidth: true
                        color: "transparent"

                        Rectangle {
                            color: MoneroComponents.Style.appWindowBorderColor
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 1
                            visible: index !== 0

                            MoneroEffects.ColorTransition {
                                targetObj: parent
                                blackColor: MoneroComponents.Style._b_appWindowBorderColor
                                whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 5
                            anchors.rightMargin: 80
                            color: "transparent"

                            MoneroComponents.Label {
                                id: idLabel
                                color: index === appWindow.current_subaddress_account_table_index ? MoneroComponents.Style.defaultFontColor : "#757575"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                fontSize: 16
                                text: "#" + index
                                themeTransition: false
                            }

                            MoneroComponents.Label {
                                id: nameLabel
                                color: MoneroComponents.Style.dimmedFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: idLabel.right
                                anchors.leftMargin: 6
                                fontSize: 16 
                                text: label
                                elide: Text.ElideRight
                                textWidth: addressLabel.x - nameLabel.x - 1
                                themeTransition: false
                            }

                            MoneroComponents.Label {
                                id: addressLabel
                                color: MoneroComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: mainLayout.width >= 590 ? balanceTextLabel.left : balanceNumberLabel.left
                                anchors.leftMargin: -addressLabel.width - 30
                                fontSize: 16
                                fontFamily: MoneroComponents.Style.fontMonoRegular.name;
                                text: TxUtils.addressTruncatePretty(address, mainLayout.width < 740 ? 1 : (mainLayout.width < 900 ? 2 : 3))
                                themeTransition: false
                            }

                            MoneroComponents.Label {
                                id: balanceTextLabel
                                visible: mainLayout.width >= 590
                                color: MoneroComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: balanceNumberLabel.left
                                anchors.leftMargin: -balanceTextLabel.width - 5
                                fontSize: 16
                                text: qsTr("Balance: ") + translationManager.emptyString
                                themeTransition: false
                            }

                            MoneroComponents.Label {
                                id: balanceNumberLabel
                                color: MoneroComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.right
                                anchors.leftMargin: -balanceNumberLabel.width
                                fontSize: 16
                                fontFamily: MoneroComponents.Style.fontMonoRegular.name;
                                text: balance
                                elide: Text.ElideRight
                                textWidth: mainLayout.width < 660 ? 70 : 135
                                themeTransition: false
                            }

                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: tableItem2.color = MoneroComponents.Style.titleBarButtonHoverColor
                                onExited: tableItem2.color = "transparent"
                                onClicked: {
                                    if (index == subaddressAccountListView.currentIndex && selectAndSend)
                                        appWindow.showPageRequest("Transfer");
                                    subaddressAccountListView.currentIndex = index;
                                }
                            }
                        }

                        RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            height: 21
                            spacing: 10

                            MoneroComponents.IconButton {
                                id: renameButton
                                image: "qrc:///images/edit.svg"
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 23
                                Layout.preferredHeight: 21

                                onClicked: pageAccount.renameSubaddressAccountLabel(index);
                            }

                            MoneroComponents.IconButton {
                                id: copyButton
                                image: "qrc:///images/copy.svg"
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 21

                                onClicked: {
                                    console.log("Address copied to clipboard");
                                    clipboard.setText(address);
                                    appWindow.showStatusMessage(qsTr("Address copied to clipboard"),3);
                                }
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
                color: MoneroComponents.Style.appWindowBorderColor
                Layout.fillWidth: true
                height: 1

                MoneroEffects.ColorTransition {
                    targetObj: parent
                    blackColor: MoneroComponents.Style._b_appWindowBorderColor
                    whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                }
            }

            MoneroComponents.CheckBox { 
                id: addNewAccountCheckbox 
                visible: !selectAndSend
                border: false
                checkedIcon: "qrc:///images/plus-in-circle-medium-white.png" 
                uncheckedIcon: "qrc:///images/plus-in-circle-medium-white.png" 
                fontSize: 16
                iconOnTheLeft: true
                Layout.fillWidth: true
                Layout.topMargin: 10
                text: qsTr("Create new account") + translationManager.emptyString; 
                onClicked: { 
                    inputDialog.labelText = qsTr("Set the label of the new account:") + translationManager.emptyString
                    inputDialog.inputText = qsTr("(Untitled)") + translationManager.emptyString
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
