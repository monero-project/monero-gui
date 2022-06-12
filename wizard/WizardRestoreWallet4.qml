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

import "../components" as MoneroComponents

import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0


Rectangle {
    id: wizardRestoreWallet4

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property alias wizardNav: wizardNav
    property string viewName: "wizardRestoreWallet4"

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            WizardHeader {
                title: qsTr("You're all set up!") + translationManager.emptyString
                subtitle: qsTr("New wallet details:") + translationManager.emptyString
            }

            WizardSummary {}

            WizardNav {
                id: wizardNav
                Layout.topMargin: 24
                btnNextText: qsTr("Create wallet") + translationManager.emptyString
                progressSteps: appWindow.walletMode <= 1 ? 3 : 4
                progress: appWindow.walletMode <= 1 ? 2 : 3

                onPrevClicked: {
                    if (appWindow.walletMode <= 1){
                        wizardStateView.state = "wizardRestoreWallet1";
                    } else {
                        wizardStateView.state = "wizardRestoreWallet3";
                    }
                }
                onNextClicked: {
                    btnNext.enabled = false;
                    wizardController.wizardStateView.wizardRestoreWallet2View.pwField = "";
                    wizardController.wizardStateView.wizardRestoreWallet2View.pwConfirmField = "";
                    wizardController.recoveryWallet();
                    wizardController.writeWallet(function() {
                        wizardController.useMoneroClicked();
                        btnNext.enabled = true;
                    });
                }
            }
        }
    }
}
