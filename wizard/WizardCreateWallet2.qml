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

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateWallet2
    
    color: "transparent"
    property string viewName: "wizardCreateWallet2"

    ColumnLayout {
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
            spacing: 0 * scaleRatio

            WizardAskPassword {
                id: passwordFields
            }

            WizardNav {
                progressSteps: 4
                progress: 2
                btnNext.enabled: passwordFields.calcStrengthAndVerify();
                onPrevClicked: {
                    if(wizardController.walletOptionsIsRecoveringFromDevice){
                        wizardStateView.state = "wizardCreateDevice1";
                    } else {
                        wizardStateView.state = "wizardCreateWallet1";
                    }
                }
                onNextClicked: {
                    wizardController.walletOptionsPassword = passwordFields.password;

                    if(appWindow.walletMode === 0 || appWindow.walletMode === 1){
                        wizardController.fetchRemoteNodes(function(){
                            wizardStateView.state = "wizardCreateWallet4";
                        }, function(){
                            appWindow.showStatusMessage(qsTr("Failed to fetch remote nodes from third-party server."), 5);
                            wizardStateView.state = "wizardCreateWallet4";
                        });
                    } else {
                        wizardStateView.state = "wizardCreateWallet3";
                    }
                }
            }
        }
    }
}
