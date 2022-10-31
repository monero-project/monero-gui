// Copyright (c) 2014-2021, The Monero Project
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

import moneroComponents.Wallet 1.0
import "../js/Wizard.js" as Wizard
import "../js/Utils.js" as Utils
import "../components"
import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateDevice2

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardCreateDevice2"

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
                title: qsTr("Write down your restore height") + translationManager.emptyString
                subtitle: qsTr("Please write down the number below on a paper and store it together with your hardware device. It is your restore height and it will help you restore your wallet faster in case you need in the future.") + translationManager.emptyString
            }

            MoneroComponents.LineEditMulti {
                id: restoreHeight

                spacing: 0
                inputPaddingLeft: 16
                inputPaddingRight: 16
                inputPaddingTop: 20
                inputPaddingBottom: 20
                inputRadius: 0
                fontSize: 18
                fontBold: true
                wrapMode: Text.WordWrap
                labelText: qsTr("Wallet restore height") + translationManager.emptyString
                labelFontSize: 14
                copyButton: false
                readOnly: true
                text: Utils.roundDownToNearestThousand(wizardController.m_wallet ? wizardController.m_wallet.walletCreationHeight : 0)
            }

            WizardNav {
                progressSteps: appWindow.walletMode <= 1 ? 3 : 4
                progress: 0
                btnPrev.text: qsTr("Back") + translationManager.emptyString
                btnNext.text: qsTr("Next") + translationManager.emptyString
                onPrevClicked: {
                    wizardStateView.state = "wizardCreateDevice1";
                }
                onNextClicked: {
                    wizardStateView.state = "wizardCreateWallet2";
                }
            }
        }
    }
}
