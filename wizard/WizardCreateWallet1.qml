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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../js/Wizard.js" as Wizard
import "../js/Utils.js" as Utils
import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateWallet1
    
    color: "transparent"
    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property string viewName: "wizardCreateWallet1"

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 0
        KeyNavigation.down: createWalletHeader
        KeyNavigation.tab: createWalletHeader

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            WizardHeader {
                id: createWalletHeader
                title: {
                    var nettype = persistentSettings.nettype;
                    return qsTr("Create a new wallet") + (nettype === 2 ? " (" + qsTr("stagenet") + ")"
                                                                        : nettype === 1 ? " (" + qsTr("testnet") + ")"
                                                                                        : "") + translationManager.emptyString
                }
                subtitle: qsTr("Creates a new wallet on this computer.") + translationManager.emptyString
                Accessible.role: Accessible.StaticText
                Accessible.name: title + subtitle
                Keys.onUpPressed: wizardNav.btnNext.enabled ? wizardNav.btnNext.forceActiveFocus() : wizardNav.wizardProgress.forceActiveFocus()
                Keys.onBacktabPressed: wizardNav.btnNext.enabled ? wizardNav.btnNext.forceActiveFocus() : wizardNav.wizardProgress.forceActiveFocus()
                Keys.onDownPressed: walletInput.walletName.forceActiveFocus();
                Keys.onTabPressed: walletInput.walletName.forceActiveFocus();
            }

            WizardWalletInput{
                id: walletInput
                rowLayout: false
                walletNameKeyNavigationBackTab: createWalletHeader
                browseButtonKeyNavigationTab: wizardNav.btnPrev
            }

            WizardNav {
                id: wizardNav
                progressSteps: appWindow.walletMode <= 1 ? 4 : 5
                progress: 0
                btnNext.enabled: walletInput.verify();
                btnPrev.text: appWindow.width <= 506 ? "<" : qsTr("Back to menu") + translationManager.emptyString
                onPrevClicked: {
                    if (wizardStateView.wizardCreateWallet2View.seedListGrid) {
                        wizardStateView.wizardCreateWallet2View.seedListGrid.destroy();
                    }
                    wizardController.wizardStateView.wizardCreateWallet3View.pwField = "";
                    wizardController.wizardStateView.wizardCreateWallet3View.pwConfirmField = "";
                    wizardStateView.state = "wizardHome";
                }
                btnPrevKeyNavigationBackTab: walletInput.errorMessageWalletLocation.text != "" ? walletInput.errorMessageWalletLocation : walletInput.browseButton
                btnNextKeyNavigationTab: createWalletHeader
                onNextClicked: {
                    wizardController.walletOptionsName = walletInput.walletName.text;
                    wizardController.walletOptionsLocation = appWindow.walletMode >= 2 ? walletInput.walletLocation.text : appWindow.accountsDir;
                    wizardStateView.state = "wizardCreateWallet2";
                    wizardStateView.wizardCreateWallet2View.pageRoot.forceActiveFocus();
                }
            }
        }
    }

    function onPageCompleted(previousView){
        if(previousView.viewName == "wizardHome"){
            walletInput.reset();
        }
    }
}
