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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import moneroComponents.NetworkType 1.0

import "../components" as MoneroComponents

Rectangle {
    id: wizardHome
    color: "transparent"
    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property string viewName: "wizardHome"

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 10
        KeyNavigation.tab: wizardHeader

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
                    id: wizardHeader
                    Layout.bottomMargin: 7
                    Layout.fillWidth: true
                    title: qsTr("Welcome to Monero") + translationManager.emptyString
                    subtitle: ""
                    Accessible.role: Accessible.StaticText
                    Accessible.name: title
                    KeyNavigation.up: showAdvancedCheckbox.checked ? kdfRoundsText : showAdvancedCheckbox
                    KeyNavigation.backtab: showAdvancedCheckbox.checked ? kdfRoundsText : showAdvancedCheckbox
                    KeyNavigation.down: languageButton
                    KeyNavigation.tab: languageButton
                }

                MoneroComponents.LanguageButton {
                    id: languageButton
                    Layout.bottomMargin: 8
                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Selected language ") + persistentSettings.language  + translationManager.emptyString
                    KeyNavigation.up: wizardHeader
                    KeyNavigation.backtab: wizardHeader
                    KeyNavigation.down: createNewWalletMenuItem
                    KeyNavigation.tab: createNewWalletMenuItem
                }
            }

            WizardMenuItem {
                id: createNewWalletMenuItem
                headerText: qsTr("Create a new wallet") + translationManager.emptyString
                bodyText: qsTr("Choose this option if this is your first time using Monero.") + translationManager.emptyString
                imageIcon: "qrc:///images/create-wallet.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardController.createWallet();
                    wizardStateView.state = "wizardCreateWallet1"
                }

                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText
                KeyNavigation.up: languageButton
                KeyNavigation.backtab: languageButton
                KeyNavigation.down: createNewWalletFromHardwareMenuItem
                KeyNavigation.tab: createNewWalletFromHardwareMenuItem
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
                id: createNewWalletFromHardwareMenuItem
                headerText: qsTr("Create a new wallet from hardware") + translationManager.emptyString
                bodyText: qsTr("Connect your hardware wallet to create a new Monero wallet.") + translationManager.emptyString
                imageIcon: "qrc:///images/restore-wallet-from-hardware.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardStateView.state = "wizardCreateDevice1"
                }

                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText
                KeyNavigation.up: createNewWalletMenuItem
                KeyNavigation.backtab: createNewWalletMenuItem
                KeyNavigation.down: openWalletFromFileMenuItem
                KeyNavigation.tab: openWalletFromFileMenuItem
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
                id: openWalletFromFileMenuItem
                headerText: qsTr("Open a wallet from file") + translationManager.emptyString
                bodyText: qsTr("Import an existing .keys wallet file from your computer.") + translationManager.emptyString
                imageIcon: "qrc:///images/open-wallet-from-file.png"

                onMenuClicked: {
                    wizardStateView.state = "wizardOpenWallet1"
                    wizardStateView.wizardOpenWallet1View.pageRoot.forceActiveFocus();
                }

                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText
                KeyNavigation.up: createNewWalletFromHardwareMenuItem
                KeyNavigation.backtab: createNewWalletFromHardwareMenuItem
                KeyNavigation.down: restoreWalletFromKeysOrSeed
                KeyNavigation.tab: restoreWalletFromKeysOrSeed
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
                id: restoreWalletFromKeysOrSeed
                headerText: qsTr("Restore wallet from keys or mnemonic seed") + translationManager.emptyString
                bodyText: qsTr("Enter your private keys or 25-word mnemonic seed to restore your wallet.") + translationManager.emptyString
                imageIcon: "qrc:///images/restore-wallet.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardStateView.state = "wizardRestoreWallet1"
                }

                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText
                KeyNavigation.up: openWalletFromFileMenuItem
                KeyNavigation.backtab: openWalletFromFileMenuItem
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
                    KeyNavigation.up: restoreWalletFromKeysOrSeed
                    KeyNavigation.backtab: restoreWalletFromKeysOrSeed
                    KeyNavigation.down: showAdvancedCheckbox
                    KeyNavigation.tab: showAdvancedCheckbox
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
                Accessible.name: qsTr("Show advanced options") + translationManager.emptyString
                KeyNavigation.up: changeWalletModeButton
                KeyNavigation.backtab: changeWalletModeButton
                KeyNavigation.down: showAdvancedCheckbox.checked ? networkTypeDropdown : wizardHeader
                KeyNavigation.tab: showAdvancedCheckbox.checked ? networkTypeDropdown : wizardHeader
            }

            ListModel {
                id: networkTypeModel
                ListElement {column1: "Mainnet"; column2: ""; nettype: "mainnet"}
                ListElement {column1: "Testnet"; column2: ""; nettype: "testnet"}
                ListElement {column1: "Stagenet"; column2: ""; nettype: "stagenet"}
            }

            GridLayout {
                visible: showAdvancedCheckbox.checked && appWindow.walletMode >= 2
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

                    onChanged: {
                        var item = dataModel.get(currentIndex).nettype.toLowerCase();
                        if(item === "mainnet") {
                            persistentSettings.nettype = NetworkType.MAINNET
                        } else if(item === "stagenet"){
                            persistentSettings.nettype = NetworkType.STAGENET
                        } else if(item === "testnet"){
                            persistentSettings.nettype = NetworkType.TESTNET
                        }
                        appWindow.disconnectRemoteNode()
                    }
                    KeyNavigation.backtab: showAdvancedCheckbox
                    KeyNavigation.tab: kdfRoundsText
                }

                MoneroComponents.LineEdit {
                    id: kdfRoundsText
                    Layout.maximumWidth: 180

                    labelText: qsTr("Number of KDF rounds:") + translationManager.emptyString
                    labelFontSize: 14
                    fontSize: 16
                    placeholderFontSize: 16
                    placeholderText: "0"
                    validator: IntValidator { bottom: 1 }
                    text: persistentSettings.kdfRounds ? persistentSettings.kdfRounds : "1"
                    onTextChanged: {
                        persistentSettings.kdfRounds = parseInt(kdfRoundsText.text) >= 1 ? parseInt(kdfRoundsText.text) : 1;
                    }
                    Accessible.role: Accessible.EditableText
                    Accessible.name: labelText + text
                    KeyNavigation.up: networkTypeDropdown
                    KeyNavigation.backtab: networkTypeDropdown
                    KeyNavigation.down: wizardHeader
                    KeyNavigation.tab: wizardHeader
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

    function onPageCompleted(){
        wizardController.walletOptionsIsRecoveringFromDevice = false;
    }
}
