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

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import FontAwesome 1.0

import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents
import "../../js/Wizard.js" as Wizard
import "../../version.js" as Version

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias settingsHeight: settingsWallet.height

    ColumnLayout {
        id: settingsWallet
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 20

        RowLayout {

            Rectangle {
                id: imageRectangle
                Layout.rightMargin: 10
                color: "transparent"
                Layout.fillWidth: true
                Layout.minimumWidth: 120
                Layout.fillHeight: true
                Layout.minimumHeight: 165

                Image {
                    anchors.centerIn: imageRectangle
                    source: appWindow.viewOnly ? "qrc:///images/view-only-wallet.png"
                                               : (appWindow.currentWallet.isTrezor() ? "qrc:///images/trezor.png"
                                                             : (appWindow.currentWallet.isLedger() ? "qrc:///images/ledgerNano.png"
                                                                           : "qrc:///images/wallet.png"))
                    height: 165
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
            }

            GridLayout {
                columns: 2
                columnSpacing: 0

                MoneroComponents.TextBlock {
                    font.pixelSize: 26
                    text: walletName
                    Layout.columnSpan: 2
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                MoneroComponents.TextBlock {
                    font.pixelSize: 14
                    text: qsTr("Type") + ":" + translationManager.emptyString
                }

                MoneroComponents.TextBlock {
                    font.pixelSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                    text: {
                        if (appWindow.currentWallet.isTrezor())
                            return qsTr("Hardware wallet (Trezor Model T)")
                        if (appWindow.currentWallet.isLedger())
                            return qsTr("Hardware wallet (Ledger Nano)")
                        if (appWindow.viewOnly)
                            return qsTr("View-only wallet")
                        if (!appWindow.viewOnly)
                            return qsTr("Normal wallet (spendable wallet)") + translationManager.emptyString;
                    }
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                MoneroComponents.TextBlock {
                    font.pixelSize: 14
                    text: qsTr("Restore height") + ":" + translationManager.emptyString
                }

                MoneroComponents.TextBlock {
                    id: restoreHeightText
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    color: MoneroComponents.Style.dimmedFontColor
                    font.pixelSize: 14
                    text: "\
                            <style type='text/css'>\
                                a {cursor:pointer;text-decoration: none; color: #FF6C3C}\
                            </style>\
                            <a href='#'>%1</a>".arg(currentWallet.walletCreationHeight.toFixed(0))
                    onLinkActivated: {
                        inputDialog.labelText = qsTr("Set a new restore height.\nYou can enter a block height or a date (YYYY-MM-DD):") + translationManager.emptyString;
                        inputDialog.onAcceptedCallback = function() {
                            var _restoreHeight;
                            if (inputDialog.inputText) {
                                var restoreHeightText = inputDialog.inputText;
                                // Parse date string or restore height as integer
                                if(restoreHeightText.indexOf('-') === 4 && restoreHeightText.length === 10) {
                                    _restoreHeight = Wizard.getApproximateBlockchainHeight(restoreHeightText, Utils.netTypeToString());
                                } else {
                                    _restoreHeight = parseInt(restoreHeightText)
                                }
                            }
                            if (!isNaN(_restoreHeight)) {
                                if(_restoreHeight >= 0) {
                                    currentWallet.walletCreationHeight = _restoreHeight
                                    // Restore height is saved in .keys file. Set password to trigger rewrite.
                                    currentWallet.setPassword(appWindow.walletPassword)

                                    // Show confirmation dialog
                                    confirmationDialog.title = qsTr("Rescan wallet cache") + translationManager.emptyString;
                                    confirmationDialog.text  = qsTr("Are you sure you want to rebuild the wallet cache?\n"
                                                                    + "The following information will be deleted\n"
                                                                    + "- Recipient addresses\n"
                                                                    + "- Tx keys\n"
                                                                    + "- Tx descriptions\n\n"
                                                                    + "The old wallet cache file will be renamed and can be restored later.\n"
                                                                    );
                                    confirmationDialog.icon = StandardIcon.Question
                                    confirmationDialog.onAcceptedCallback = function() {
                                        appWindow.closeWallet(function() {
                                            walletManager.clearWalletCache(persistentSettings.wallet_path);
                                            walletManager.openWalletAsync(persistentSettings.wallet_path, appWindow.walletPassword,
                                                                            persistentSettings.nettype, persistentSettings.kdfRounds);
                                        });
                                    }

                                    confirmationDialog.onRejectedCallback = null;
                                    confirmationDialog.open()
                                    return;
                                }
                            }
                            appWindow.showStatusMessage(qsTr("Invalid restore height specified. Must be a number or a date formatted YYYY-MM-DD"),3);
                        }
                        inputDialog.onRejectedCallback = null;
                        inputDialog.open(currentWallet ? currentWallet.walletCreationHeight.toFixed(0) : "0")
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                MoneroComponents.TextBlock {
                    id: restoreHeight
                    font.pixelSize: 14
                    textFormat: Text.RichText
                    text: qsTr("Location") + ":" + translationManager.emptyString
                }

                MoneroComponents.TextBlock {
                    id: walletLocation2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dimmedFontColor
                    font.pixelSize: 14
                    property string walletPath: (isIOS ?  appWindow.accountsDir : "") + persistentSettings.wallet_path
                    text: "\
                        <style type='text/css'>\
                            a {cursor:pointer;text-decoration: none; color: #FF6C3C}\
                        </style>\
                        <a href='#'>%1</a>".arg(walletPath)
                    textFormat: Text.RichText
                    onLinkActivated: oshelper.openContainingFolder(walletPath)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                MoneroComponents.TextBlock {
                    Layout.fillWidth: true
                    font.pixelSize: 14
                    text: qsTr("Total balance") + ":" + translationManager.emptyString
                }

                ColumnLayout {
                    MoneroComponents.TextBlock {
                        Layout.fillWidth: true
                        font.pixelSize: 14
                        color: MoneroComponents.Style.dimmedFontColor
                        text: walletManager.displayAmount(appWindow.currentWallet.balanceAll()) + " XMR"
                    }

                    MoneroComponents.TextBlock {
                        Layout.fillWidth: true
                        font.pixelSize: 14
                        color: MoneroComponents.Style.dimmedFontColor
                        visible: persistentSettings.fiatPriceEnabled
                        text: fiatApiConvertToFiat(walletManager.displayAmount(appWindow.currentWallet.balanceAll())) + " " + appWindow.fiatApiCurrencySymbol()
                    }
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                MoneroComponents.TextBlock {
                    Layout.fillWidth: true
                    font.pixelSize: 14
                    text: qsTr("Wallet accounts: ") + translationManager.emptyString
                }

                MoneroComponents.TextBlock {
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dimmedFontColor
                    font.pixelSize: 14
                    text: "\
                        <style type='text/css'>\
                            a {cursor:pointer;text-decoration: none; color: #FF6C3C}\
                        </style>\
                        <a href='#'>%1".arg(accountList.count) + " " + (accountList.count >1 ? qsTr("accounts") : qsTr("account")) + "</a>" + translationManager.emptyString;
                    textFormat: Text.RichText
                    onLinkActivated: {
                        middlePanel.state = "Account";
                        middlePanel.flickable.contentY = 0;
                        updateBalance();
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                ListView {
                    id: accountList
                    model: currentWallet.subaddressAccountModel
                    visible: false
                    delegate: Item {}
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                Rectangle {
                    height: 1
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                }

                MoneroComponents.TextBlock {
                    Layout.fillWidth: true
                    font.pixelSize: 14
                    text: qsTr("Address book: ") + translationManager.emptyString
                }

                MoneroComponents.TextBlock {
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.dimmedFontColor
                    font.pixelSize: 14
                    text: "\
                        <style type='text/css'>\
                            a {cursor:pointer;text-decoration: none; color: #FF6C3C}\
                        </style>\
                        <a href='#'>%1".arg(addressBookContactList.count) + " " + (addressBookContactList.count >1 || addressBookContactList.count == 0 ? qsTr("contacts") : qsTr("contact")) + "</a>" + translationManager.emptyString;
                    textFormat: Text.RichText
                    onLinkActivated: {
                        middlePanel.state = "AddressBook";
                        middlePanel.flickable.contentY = 0;
                        updateBalance();
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

                ListView {
                    id: addressBookContactList
                    model: currentWallet.addressBookModel
                    visible: false
                    delegate: Item {}
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            GridLayout {
                columns: 3
                columnSpacing: 20
                rowSpacing: 20

                MoneroComponents.SettingsListItem {
                    iconText: FontAwesome.signOutAlt
                    tooltip: qsTr("Close this wallet and return to main menu") + translationManager.emptyString
                    title: qsTr("Close this wallet") + translationManager.emptyString

                    onClicked: appWindow.showWizard()
                }

                MoneroComponents.SettingsListItem {
                    iconText: FontAwesome.eye
                    tooltip: qsTr("Creates a new wallet that can only view and initiate transactions, but requires a spendable wallet to sign transactions before sending") + translationManager.emptyString
                    title: qsTr("Create view-only wallet") + translationManager.emptyString
                    visible: appWindow.walletMode >= 2 && !appWindow.viewOnly && (currentWallet ? !currentWallet.isLedger() : true)

                    onClicked: {
                        var newPath = currentWallet.path + "_viewonly";
                        if (currentWallet.createViewOnly(newPath, appWindow.walletPassword)) {
                            console.log("view only wallet created in " + newPath);
                            informationPopup.title  = qsTr("Success") + translationManager.emptyString;
                            informationPopup.text = qsTr('The view only wallet has been created with the same password as the current wallet. You can open it by closing this current wallet, clicking the "Open wallet from file" option, and selecting the view wallet in: \n%1\nYou can change the password in the wallet settings.').arg(newPath);
                            informationPopup.open()
                            informationPopup.onCloseCallback = null
                        } else {
                            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                            informationPopup.text = currentWallet.errorString;
                            informationPopup.open()
                        }
                    }
                }

                MoneroComponents.SettingsListItem {
                    iconText: FontAwesome.key
                    tooltip: qsTr("Store this information as a backup to safely recover your wallet in the future") + translationManager.emptyString
                    title: qsTr("Seed & keys") + translationManager.emptyString

                    onClicked: {
                        Utils.showSeedPage();
                    }
                }

                MoneroComponents.SettingsListItem {
                    iconText: FontAwesome.repeat
                    tooltip: qsTr("Click on this button if you think the shown balance is not accurate") + translationManager.emptyString
                    title: qsTr("Rescan balance") + translationManager.emptyString
                    visible: appWindow.walletMode >= 2

                    onClicked: {
                        if (!currentWallet.rescanSpent()) {
                            console.error("Error: ", currentWallet.errorString);
                            informationPopup.title = qsTr("Error") + translationManager.emptyString;
                            informationPopup.text  = qsTr("Error: ") + currentWallet.errorString
                            informationPopup.icon  = StandardIcon.Critical
                            informationPopup.onCloseCallback = null
                            informationPopup.open();
                        } else {
                            informationPopup.title = qsTr("Information") + translationManager.emptyString
                            informationPopup.text  = qsTr("Successfully rescanned spent outputs.") + translationManager.emptyString
                            informationPopup.icon  = StandardIcon.Information
                            informationPopup.onCloseCallback = null
                            informationPopup.open();
                        }
                    }
                }

                MoneroComponents.SettingsListItem {
                    iconText: FontAwesome.ellipsisH
                    tooltip: qsTr("Change the password of your wallet") + translationManager.emptyString
                    title: qsTr("Change password") + translationManager.emptyString

                    onClicked: {
                        passwordDialog.onAcceptedCallback = function() {
                            if(appWindow.walletPassword === passwordDialog.password){
                                passwordDialog.openNewPasswordDialog()
                            } else {
                                informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                                informationPopup.text = qsTr("Wrong password") + translationManager.emptyString;
                                informationPopup.open()
                                informationPopup.onCloseCallback = function() {
                                    passwordDialog.open()
                                }
                            }
                        }
                        passwordDialog.onRejectedCallback = null;
                        passwordDialog.open()
                    }
                }

                MoneroComponents.SettingsListItem {
                    iconText: FontAwesome.cashRegister
                    visible: appWindow.walletMode >= 2
                    tooltip: qsTr("Receive Monero for your business, easily.") + translationManager.emptyString
                    title: qsTr("Merchant mode") + translationManager.emptyString

                    onClicked: {
                        middlePanel.state = "Merchant";
                        middlePanel.flickable.contentY = 0;
                        updateBalance();
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log('SettingsWallet loaded');
    }
}
