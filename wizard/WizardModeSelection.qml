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

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

Rectangle {
    id: wizardModeSelection1
    color: "transparent"

    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property string viewName: "wizardModeSelection1"
    property bool portable: portableSettings.portable
    property alias advancedModeButton: advancedModeButton
    property alias portableModeButton: portableModeButton
    property bool simpleModeAvailable: !isTails && appWindow.persistentSettings.nettype == 0 && !isAndroid

    function applyWalletMode(mode, wizardState) {
        if (!portableSettings.setPortable(portable)) {
            appWindow.showStatusMessage(qsTr("Failed to configure portable mode"), 3);
            return false;
        }

        logger.resetLogFilePath(portable);
        appWindow.changeWalletMode(mode);
        wizardController.wizardStackView.backTransition = false;
        wizardController.wizardState = wizardState;
        return true;
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
                KeyNavigation.down: simpleModeButton.enabled ? simpleModeButton : advancedModeButton
                KeyNavigation.tab: simpleModeButton.enabled ? simpleModeButton : advancedModeButton
            }

            WizardMenuItem {
                id: simpleModeButton
                enabled: simpleModeAvailable
                opacity: simpleModeAvailable ? 1.0 : 0.5
                Layout.topMargin: 20
                headerText: qsTr("Simple mode") + translationManager.emptyString
                bodyText: {
                    if (isTails) {
                        return qsTr("Not available on Tails.") + translationManager.emptyString;
                    } else {
                        if (appWindow.persistentSettings.nettype == 0) {
                            return qsTr("Easy access to sending, receiving and basic functionality.") + translationManager.emptyString;
                        } else {
                            return qsTr("Available on mainnet.") + translationManager.emptyString;
                        }
                    }
                }

                imageIcon: "qrc:///images/remote-node.png"
                selected: appWindow.walletMode == 0

                onMenuClicked: {
                    if (simpleModeAvailable) {
                        if (applyWalletMode(0, 'wizardModeRemoteNodeWarning')) {
                            wizardStateView.wizardModeRemoteNodeWarningView.pageRoot.forceActiveFocus();
                        }
                    }
                }
                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText + " " + (selected ? qsTr("Selected") : qsTr("Not selected")) + translationManager.emptyString
                KeyNavigation.up: modeSelectionHeader
                KeyNavigation.backtab: modeSelectionHeader
                KeyNavigation.down: advancedModeButton
                KeyNavigation.tab: advancedModeButton
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
                id: advancedModeButton
                headerText: qsTr("Advanced mode") + translationManager.emptyString
                bodyText: qsTr("Includes extra features like mining and message verification. The blockchain is downloaded to your computer.") + translationManager.emptyString
                imageIcon: "qrc:///images/local-node-full.png"
                selected: appWindow.walletMode >= 2

                onMenuClicked: {
                    appWindow.persistentSettings.pruneBlockchain = true;
                    applyWalletMode(2, 'wizardHome');
                }
                Accessible.role: Accessible.MenuItem
                Accessible.name: headerText + ". " + bodyText + " " + (selected ? qsTr("Selected") : qsTr("Not selected")) + translationManager.emptyString
                KeyNavigation.up: simpleModeButton.enabled ? simpleModeButton : modeSelectionHeader
                KeyNavigation.backtab: simpleModeButton.enabled ? simpleModeButton : modeSelectionHeader
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
                KeyNavigation.up: advancedModeButton
                KeyNavigation.backtab: advancedModeButton
                KeyNavigation.down: portableModeButton
                KeyNavigation.tab: portableModeButton
            }

            WizardMenuItem {
                id: portableModeButton
                Layout.topMargin: 20
                headerText: qsTr("Portable mode") + translationManager.emptyString
                bodyText: qsTr("Create portable wallets and use them on any PC. Enable if you installed Monero on a USB stick, an external drive, or any other portable storage medium.") + translationManager.emptyString
                checkbox: true
                checked: wizardModeSelection1.portable
                Accessible.role: Accessible.CheckBox
                Accessible.name: headerText + ". " + bodyText
                Accessible.checked: checked
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
                btnPrevKeyNavigationBackTab: portableModeButton
                btnNextKeyNavigationTab: modeSelectionHeader

                onPrevClicked: {
                    if (wizardController.wizardStackView.backTransition) {
                        applyWalletMode(persistentSettings.walletMode, 'wizardHome');
                    } else {
                        wizardController.wizardStackView.backTransition = true;
                        wizardController.wizardState = 'wizardLanguage';
                        wizardStateView.wizardLanguageView.pageRoot.forceActiveFocus();
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
