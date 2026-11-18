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

import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import moneroComponents.NetworkType 1.0

import "../components" as MoneroComponents

Rectangle {
    id: wizardHome
    color: "transparent"
    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property alias createWalletButton: createWalletButton
    property alias openWalletButton: openWalletButton
    property alias restoreWalletButton: restoreWalletButton
    property alias changeWalletModeButton: changeWalletModeButton
    property string viewName: "wizardHome"

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;
        KeyNavigation.tab: welcomeHeader

        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                WizardHeader {
                    id: welcomeHeader
                    Layout.bottomMargin: 7
                    Layout.fillWidth: true
                    title: qsTr("Welcome to Monero") + translationManager.emptyString
                    subtitle: ""
                    Accessible.role: Accessible.StaticText
                    Accessible.name: title
                    Keys.onUpPressed: wizardHome.lastFocusItem().forceActiveFocus();
                    Keys.onBacktabPressed: wizardHome.lastFocusItem().forceActiveFocus();
                    KeyNavigation.down: languageButton
                    KeyNavigation.tab: languageButton
                }

                MoneroComponents.LanguageButton {
                    id: languageButton
                    Layout.bottomMargin: 8
                    KeyNavigation.up: welcomeHeader
                    KeyNavigation.backtab: welcomeHeader
                    KeyNavigation.down: createWalletButton
                    KeyNavigation.tab: createWalletButton
                }
            }

            WizardMenuItem {
                id: createWalletButton
                headerText: {
                    var nettype = persistentSettings.nettype;
                    return qsTr("Create a new wallet") + (nettype === 2 ? " (" + qsTr("stagenet") + ")"
                                                                        : nettype === 1 ? " (" + qsTr("testnet") + ")"
                                                                                        : "") + translationManager.emptyString
                }
                bodyText: qsTr("Choose this option if this is your first time using Monero.") + translationManager.emptyString
                imageIcon: "qrc:///images/create-wallet.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardController.createWallet();
                    wizardStateView.state = "wizardCreateWallet1"
                    wizardStateView.wizardCreateWallet1View.pageRoot.forceActiveFocus();
                }
                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText
                KeyNavigation.up: languageButton
                KeyNavigation.backtab: languageButton
                KeyNavigation.down: createWalletFromDeviceButton
                KeyNavigation.tab: createWalletFromDeviceButton
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                id: createWalletFromDeviceButton
                headerText: {
                    var nettype = persistentSettings.nettype;
                    return qsTr("Create a new wallet from hardware") + (nettype === 2 ? " (" + qsTr("stagenet") + ")"
                                                                        : nettype === 1 ? " (" + qsTr("testnet") + ")"
                                                                                        : "") + translationManager.emptyString
                }
                bodyText: qsTr("Connect your hardware wallet to create a new Monero wallet.") + translationManager.emptyString
                imageIcon: "qrc:///images/restore-wallet-from-hardware.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardStateView.state = "wizardCreateDevice1"
                }
                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText
                KeyNavigation.up: createWalletButton
                KeyNavigation.backtab: createWalletButton
                KeyNavigation.down: openWalletButton
                KeyNavigation.tab: openWalletButton
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                id: openWalletButton
                headerText: qsTr("Open a wallet from file") + translationManager.emptyString
                bodyText: qsTr("Import an existing .keys wallet file from your computer.") + translationManager.emptyString
                imageIcon: "qrc:///images/open-wallet-from-file.png"

                onMenuClicked: {
                    wizardStateView.state = "wizardOpenWallet1"
                    wizardStateView.wizardOpenWallet1View.pageRoot.forceActiveFocus();
                }
                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText
                KeyNavigation.up: createWalletFromDeviceButton
                KeyNavigation.backtab: createWalletFromDeviceButton
                KeyNavigation.down: restoreWalletButton
                KeyNavigation.tab: restoreWalletButton
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                id: restoreWalletButton
                headerText: qsTr("Restore wallet from keys or mnemonic seed") + translationManager.emptyString
                bodyText: qsTr("Enter your private keys or 25-word mnemonic seed to restore your wallet.") + translationManager.emptyString
                imageIcon: "qrc:///images/restore-wallet.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardStateView.state = "wizardRestoreWallet1"
                }
                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText
                KeyNavigation.up: openWalletButton
                KeyNavigation.backtab: openWalletButton
                KeyNavigation.down: changeWalletModeButton
                KeyNavigation.tab: changeWalletModeButton
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16
                spacing: 20

                MoneroComponents.StandardButton {
                    id: changeWalletModeButton
                    small: true
                    text: qsTr("Change wallet mode") + translationManager.emptyString

                    onClicked: {
                        wizardController.wizardStackView.backTransition = true;
                        wizardController.wizardState = 'wizardModeSelection';
                        wizardStateView.wizardModeSelectionView.pageRoot.forceActiveFocus();
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: text
                    Accessible.onPressAction: doClick()
                    KeyNavigation.up: restoreWalletButton
                    KeyNavigation.backtab: restoreWalletButton
                    Keys.onDownPressed: wizardHome.focusAfter(changeWalletModeButton);
                    Keys.onTabPressed: wizardHome.focusAfter(changeWalletModeButton);
                }
            }

            MoneroComponents.CheckBox2 {
                id: showAdvancedCheckbox
                Layout.topMargin: 30
                Layout.fillWidth: true
                fontSize: 15
                checked: false
                text: qsTr("Advanced options") + translationManager.emptyString
                visible: appWindow.walletMode >= 2
                Accessible.role: Accessible.CheckBox
                Accessible.name: text
                Accessible.checked: checked
                KeyNavigation.up: changeWalletModeButton
                KeyNavigation.backtab: changeWalletModeButton
                Keys.onDownPressed: wizardHome.focusAfter(showAdvancedCheckbox);
                Keys.onTabPressed: wizardHome.focusAfter(showAdvancedCheckbox);
                // Collapsing disables the grid, which drops focus if it was inside it
                onClicked: if (!checked) showAdvancedCheckbox.forceActiveFocus();
            }

            ListModel {
                id: networkTypeModel
                ListElement {column1: "Mainnet"; column2: ""; nettype: "mainnet"}
                ListElement {column1: "Testnet"; column2: ""; nettype: "testnet"}
                ListElement {column1: "Stagenet"; column2: ""; nettype: "stagenet"}
            }

            GridLayout {
                id: advancedOptionsGrid
                visible: showAdvancedCheckbox.checked && appWindow.walletMode >= 2
                enabled: visible
                columns: 4
                columnSpacing: 20
                Layout.fillWidth: true
                Layout.topMargin: 10

                MoneroComponents.StandardDropdown {
                    id: networkTypeDropdown
                    currentIndex: persistentSettings.nettype
                    dataModel: networkTypeModel
                    Layout.maximumWidth: 180
                    labelText: qsTr("Network") + ":" + translationManager.emptyString
                    labelFontSize: 14
                    Accessible.role: Accessible.ComboBox
                    Accessible.name: qsTr("Network") + ": " + dataModel.get(expanded ? highlightIndex : currentIndex).column1 + translationManager.emptyString
                    KeyNavigation.backtab: showAdvancedCheckbox
                    KeyNavigation.tab: kdfRoundsText

                    onChanged: {
                        var item = dataModel.get(currentIndex).nettype.toLowerCase();
                        var nettype = persistentSettings.nettype;
                        if(item === "mainnet") {
                            nettype = NetworkType.MAINNET
                        } else if(item === "stagenet"){
                            nettype = NetworkType.STAGENET
                        } else if(item === "testnet"){
                            nettype = NetworkType.TESTNET
                        }
                        if (nettype === persistentSettings.nettype) {
                            networkTypeDropdown.currentIndex = Qt.binding(function() { return persistentSettings.nettype });
                            return;
                        }
                        persistentSettings.nettype = nettype
                        appWindow.disconnectRemoteNode()
                        networkTypeDropdown.currentIndex = Qt.binding(function() { return persistentSettings.nettype });
                        persistentSettings.wallet_path = ""
                    }
                }

                MoneroComponents.LineEdit {
                    id: kdfRoundsText
                    Layout.maximumWidth: 180

                    property bool kdfWarningShown: false

                    labelText: qsTr("Number of KDF rounds:") + translationManager.emptyString
                    labelFontSize: 14
                    inputAccessibleName: labelText
                    KeyNavigation.backtab: networkTypeDropdown
                    KeyNavigation.tab: welcomeHeader
                    fontSize: 16
                    placeholderFontSize: 16
                    placeholderText: "0"
                    validator: IntValidator { bottom: 1 }
                    text: persistentSettings.kdfRounds ? persistentSettings.kdfRounds : "1"
                    onTextChanged: {
                        var wasDefault = persistentSettings.kdfRounds === 1;
                        var newValue = parseInt(kdfRoundsText.text) >= 1 ? parseInt(kdfRoundsText.text) : 1;
                        persistentSettings.kdfRounds = newValue;

                        if (newValue === 1) {
                            kdfRoundsText.kdfWarningShown = false;
                        } else if (wasDefault && !kdfRoundsText.kdfWarningShown) {
                            kdfRoundsText.kdfWarningShown = true;
                            confirmationDialog.title = qsTr("Warning") + translationManager.emptyString;
                            confirmationDialog.text = qsTr("You have selected a non-standard number of KDF rounds.\n\nThis value is set globally and is not stored in the wallet file. It must be remembered and re-entered every time this wallet is opened; otherwise, the wallet will not open due to the password being incorrect.\n\nHigher values make opening and saving the wallet significantly slower.") + translationManager.emptyString;
                            confirmationDialog.onAcceptedCallback = null;
                            confirmationDialog.onRejectedCallback = function() {
                                kdfRoundsText.text = "1";
                            }
                            confirmationDialog.cancelText = qsTr("Reset to 1") + translationManager.emptyString;
                            confirmationDialog.okText = qsTr("Keep") + translationManager.emptyString;
                            confirmationDialog.open();
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200;
            easing.type: Easing.InCubic;
        }
    }

    function lastFocusItem() {
        if (advancedOptionsGrid.visible) {
            return kdfRoundsText;
        }
        if (showAdvancedCheckbox.visible) {
            return showAdvancedCheckbox;
        }
        return changeWalletModeButton;
    }

    function focusAfter(item) {
        if (item === lastFocusItem()) {
            welcomeHeader.forceActiveFocus();
        } else if (item === changeWalletModeButton) {
            showAdvancedCheckbox.forceActiveFocus();
        } else {
            networkTypeDropdown.forceActiveFocus();
        }
    }

    function onPageCompleted(){
        pageRoot.forceActiveFocus();
        wizardController.walletOptionsIsRecoveringFromDevice = false;
        if (networkTypeDropdown.currentIndex != 0) {
            showAdvancedCheckbox.checked = true;
        }
    }
}
