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

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

Rectangle {
    id: wizardModeSelection1
    color: "transparent"

    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property string viewName: "wizardModeSelection1"
    property bool portable: persistentSettings.portable

    function applyWalletMode(mode, wizardState) {
        if (!persistentSettings.setPortable(portable)) {
            appWindow.showStatusMessage(qsTr("Failed to configure portable mode"), 3);
            return;
        }

        logger.resetLogFilePath(portable);
        appWindow.changeWalletMode(mode);
        wizardController.wizardStackView.backTransition = false;
        wizardController.wizardState = wizardState;
    }

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;
        KeyNavigation.tab: modeSelectionHeader

        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            WizardHeader {
                id: modeSelectionHeader
                title: qsTr("Mode selection") + translationManager.emptyString
                subtitle: qsTr("Please select the statement that best matches you.") + translationManager.emptyString
                Accessible.role: Accessible.StaticText
                Accessible.name: title + ". " + subtitle
                Keys.onUpPressed: wizardNav.btnPrev.forceActiveFocus();
                Keys.onBacktabPressed: wizardNav.btnPrev.forceActiveFocus();
                KeyNavigation.down: simpleModeItem
                KeyNavigation.tab: simpleModeItem
            }

            WizardMenuItem {
                id: simpleModeItem
                opacity: appWindow.persistentSettings.nettype == 0 ? 1.0 : 0.5
                Layout.topMargin: 20
                headerText: qsTr("Simple mode") + translationManager.emptyString
                bodyText: {
                    if(appWindow.persistentSettings.nettype == 0){
                        return qsTr("Easy access to sending, receiving and basic functionality.") + translationManager.emptyString;
                    } else {
                        return "Available on mainnet.";
                    }
                }

                imageIcon: "qrc:///images/remote-node.png"
                selected: appWindow.walletMode == 0

                onMenuClicked: {
                    if(appWindow.persistentSettings.nettype == 0){
                        applyWalletMode(0, 'wizardModeRemoteNodeWarning');
                        wizardStateView.wizardModeRemoteNodeWarningView.pageRoot.forceActiveFocus();
                    }
                }
                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText + " " + (selected ? qsTr("Selected") : qsTr("Not selected")) + translationManager.emptyString
                KeyNavigation.up: modeSelectionHeader
                KeyNavigation.backtab: modeSelectionHeader
                KeyNavigation.down: simpleModeBootstrapItem
                KeyNavigation.tab: simpleModeBootstrapItem
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 5
                Layout.bottomMargin: 10
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                id: simpleModeBootstrapItem
                opacity: appWindow.persistentSettings.nettype == 0 ? 1.0 : 0.5
                headerText: qsTr("Simple mode") + " (bootstrap)" + translationManager.emptyString
                bodyText: {
                    if(appWindow.persistentSettings.nettype == 0){
                        return qsTr("Easy access to sending, receiving and basic functionality. The blockchain is downloaded to your computer.") + translationManager.emptyString;
                    } else {
                        return "Available on mainnet.";
                    }
                }
                imageIcon: "qrc:///images/local-node.png"
                selected: appWindow.walletMode == 1

                onMenuClicked: {
                    if(appWindow.persistentSettings.nettype == 0){
                        appWindow.persistentSettings.pruneBlockchain = true;
                        applyWalletMode(1, 'wizardModeBootstrap');
                        wizardStateView.wizardModeBootstrapView.pageRoot.forceActiveFocus();
                    }
                }
                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText + " " + (selected ? qsTr("Selected") : qsTr("Not selected")) + translationManager.emptyString
                KeyNavigation.up: simpleModeItem
                KeyNavigation.backtab: simpleModeItem
                KeyNavigation.down: advancedModeItem
                KeyNavigation.tab: advancedModeItem
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 5
                Layout.bottomMargin: 10
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                id: advancedModeItem
                headerText: qsTr("Advanced mode") + translationManager.emptyString
                bodyText: qsTr("Includes extra features like mining and message verification. The blockchain is downloaded to your computer.") + translationManager.emptyString
                imageIcon: "qrc:///images/local-node-full.png"
                selected: appWindow.walletMode >= 2

                onMenuClicked: {
                    appWindow.persistentSettings.pruneBlockchain = false; // can be toggled on next page
                    applyWalletMode(2, 'wizardHome');
                    wizardStateView.wizardHomeView.pageRoot.forceActiveFocus();
                }
                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText + " " + (selected ? qsTr("Selected") : qsTr("Not selected")) + translationManager.emptyString
                KeyNavigation.up: simpleModeBootstrapItem
                KeyNavigation.backtab: simpleModeBootstrapItem
                KeyNavigation.down: optionalFeaturesHeader
                KeyNavigation.tab: optionalFeaturesHeader
            }

            WizardHeader {
                id: optionalFeaturesHeader
                Layout.topMargin: 20
                title: qsTr("Optional features") + translationManager.emptyString
                subtitle: qsTr("Select enhanced functionality you would like to enable.") + translationManager.emptyString
                Accessible.role: Accessible.StaticText
                Accessible.name: title + ". " + subtitle
                KeyNavigation.up: advancedModeItem
                KeyNavigation.backtab: advancedModeItem
                KeyNavigation.down: portableModeItem
                KeyNavigation.tab: portableModeItem
            }

            WizardMenuItem {
                id: portableModeItem
                Layout.topMargin: 20
                headerText: qsTr("Portable mode") + translationManager.emptyString
                bodyText: qsTr("Create portable wallets and use them on any PC. Enable if you installed Monero on a USB stick, an external drive, or any other portable storage medium.") + translationManager.emptyString
                checkbox: true
                checked: wizardModeSelection1.portable
                Accessible.role: Accessible.CheckBox
                Accessible.name: headerText + ". " + bodyText
                KeyNavigation.up: optionalFeaturesHeader
                KeyNavigation.backtab: optionalFeaturesHeader
                KeyNavigation.down: wizardNav.btnPrev
                KeyNavigation.tab: wizardNav.btnPrev

                onMenuClicked: wizardModeSelection1.portable = !wizardModeSelection1.portable
            }

            WizardNav {
                id: wizardNav
                Layout.topMargin: 5
                btnPrevText: qsTr("Back to menu") + translationManager.emptyString
                btnNext.visible: false
                progressEnabled: false
                autoTransition: false
                btnPrevKeyNavigationBackTab: portableModeItem
                btnNextKeyNavigationTab: modeSelectionHeader

                onPrevClicked: {
                    if (wizardController.wizardStackView.backTransition) {
                        applyWalletMode(persistentSettings.walletMode, 'wizardHome');
                        portableModeItem.focus = false;
                    } else {
                        wizardController.wizardStackView.backTransition = true;
                        wizardController.wizardState = 'wizardLanguage';
                        wizardStateView.wizardLanguageView.pageRoot.forceActiveFocus();
                        portableModeItem.focus = false;
                    }
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
}
