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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateWallet3

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardCreateWallet3"
    property alias pwField: passwordFields.password
    property alias pwConfirmField: passwordFields.passwordConfirm

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
            spacing: 0

            WizardAskPassword {
                id: passwordFields
            }

            WizardNav {
                progressSteps: appWindow.walletMode <= 1 ? 4 : 5
                progress: 2
                btnNext.enabled: passwordFields.calcStrengthAndVerify();
                onPrevClicked: {
                    if(wizardController.walletOptionsIsRecoveringFromDevice){
                        wizardStateView.state = "wizardCreateDevice1";
                    } else {
                        wizardStateView.state = "wizardCreateWallet2";
                        wizardStateView.wizardCreateWallet2View.pageRoot.forceActiveFocus();
                    }
                }
                onNextClicked: {
                    wizardController.walletOptionsPassword = passwordFields.password;

                    if (appWindow.walletMode < 2) {
                        wizardStateView.state = "wizardCreateWallet5";
                    } else {
                        wizardStateView.state = "wizardCreateWallet4";
                    }
                }
            }
        }
    }
}
