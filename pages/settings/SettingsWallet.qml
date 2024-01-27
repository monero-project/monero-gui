// Copyright (c) 2014-2024, The Monero Project
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
import QtQuick.Dialogs 1.2
import FontAwesome 1.0

import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents

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
        spacing: 0

        MoneroComponents.SettingsListItem {
            iconText: FontAwesome.lock
            description: qsTr("Locks the wallet on demand.") + translationManager.emptyString
            title: qsTr("Lock this wallet") + translationManager.emptyString
            symbol: (isMac ? "⌃" : qsTr("Ctrl+")) + "L" + translationManager.emptyString
            onClicked: appWindow.lock();
        }

        MoneroComponents.SettingsListItem {
            iconText: FontAwesome.signOutAlt
            description: qsTr("Logs out of this wallet.") + translationManager.emptyString
            title: qsTr("Close this wallet") + translationManager.emptyString

            onClicked: appWindow.showWizard()
        }

        MoneroComponents.SettingsListItem {
            iconText: FontAwesome.eye
            description: qsTr("Creates a new wallet that can only view and initiate transactions, but requires a spendable wallet to sign transactions before sending.") + translationManager.emptyString
            title: qsTr("Create a view-only wallet") + translationManager.emptyString
            visible: !appWindow.viewOnly && (currentWallet ? !currentWallet.isLedger() : true)

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
            description: qsTr("Store this information safely to recover your wallet in the future.") + translationManager.emptyString
            title: qsTr("Show seed & keys") + translationManager.emptyString

            onClicked: {
                Utils.showSeedPage();
            }
        }

        MoneroComponents.SettingsListItem {
            enabled: leftPanel.progressBar.fillLevel == 100
            iconText: FontAwesome.repeat
            description: qsTr("Use this feature if you think the shown balance is not accurate.") + translationManager.emptyString
            title: qsTr("Rescan wallet balance") + translationManager.emptyString
            visible: appWindow.walletMode >= 2

            onClicked: {
                if (!currentWallet.rescanSpent()) {
                    console.error("Error: ", currentWallet.errorString);
                    informationPopup.title = qsTr("Error") + translationManager.emptyString;
                    if (currentWallet.errorString == "Rescan spent can only be used with a trusted daemon") {
                        informationPopup.text = qsTr("Error: ") + qsTr("Rescan spent can only be used with a trusted remote node. If you trust the current node you are connected to (%1), you can mark it as trusted in Settings > Node page.").arg(remoteNodesModel.currentRemoteNode().address) + translationManager.emptyString;
                    } else {
                        informationPopup.text = qsTr("Error: ") + currentWallet.errorString;
                    }
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
            enabled: leftPanel.progressBar.fillLevel == 100
            iconText: FontAwesome.magnifyingGlass
            description: qsTr("Use this feature if a transaction is missing in your wallet history. This will expose the transaction ID to the remote node, which can harm your privacy.") + translationManager.emptyString
            title: qsTr("Scan transaction") + translationManager.emptyString

            onClicked: {
                inputDialog.labelText = qsTr("Enter a transaction ID:") + translationManager.emptyString;
                inputDialog.onAcceptedCallback = function() {
                    var txid = inputDialog.inputText.trim();
                    if (currentWallet.scanTransactions([txid])) {
                        updateBalance();
                        appWindow.showStatusMessage(qsTr("Transaction successfully scanned"), 3);
                    } else {
                        console.error("Error: ", currentWallet.errorString);
                        if (currentWallet.errorString == "The wallet has already seen 1 or more recent transactions than the scanned tx") {
                            informationPopup.title = qsTr("Error") + translationManager.emptyString;
                            informationPopup.text = qsTr("The wallet has already seen 1 or more recent transactions than the scanned transaction.\n\nIn order to rescan the transaction, you can re-sync your wallet by resetting the wallet restore height in the Settings > Info page. Make sure to use a restore height from before your wallet's earliest transaction.") + translationManager.emptyString;
                            informationPopup.icon = StandardIcon.Critical
                            informationPopup.onCloseCallback = null
                            informationPopup.open();
                        } else {
                            appWindow.showStatusMessage(qsTr("Failed to scan transaction") + ": " + currentWallet.errorString, 5);
                        }
                    }
                }
                inputDialog.onRejectedCallback = null;
                inputDialog.open()
            }
        }

        MoneroComponents.SettingsListItem {
            iconText: FontAwesome.ellipsisH
            description: qsTr("Change the password of your wallet.") + translationManager.emptyString
            title: qsTr("Change wallet password") + translationManager.emptyString

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
            isLast: true
            description: qsTr("Receive Monero for your business, easily.") + translationManager.emptyString
            title: qsTr("Enter merchant mode") + translationManager.emptyString

            onClicked: {
                middlePanel.state = "Merchant";
                middlePanel.flickable.contentY = 0;
                updateBalance();
            }
        }
    }

    Component.onCompleted: {
        console.log('SettingsWallet loaded');
    }
}

