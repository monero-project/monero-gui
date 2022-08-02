// Copyright (c) 2021, The Monero Project
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

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateMultisig4

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardCreateMultisig4"

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
                title: qsTr("Key Exchange Round Booster") + translationManager.emptyString
                subtitle: qsTr("In order to initalize a multisig wallet both wallet managers must exchange this information") + translationManager.emptyString
            }

            RowLayout {
                id: secondKexRow
                property var secondKex: wizardController.walletOptionsMultisigKex3
                MoneroComponents.LineEditMulti {
                    id: multisigKexBooster

                    spacing: 0
                    inputPaddingLeft: 16
                    inputPaddingRight: 16
                    inputPaddingTop: 20
                    inputPaddingBottom: 20
                    inputRadius: 0
                    fontSize: 18
                    fontBold: true
                    wrapMode: Text.WordWrap
                    labelText: qsTr("Send this to information to other wallet managers") + translationManager.emptyString
                    labelFontSize: 14
                    copyButton: true
                    readOnly: true
                    text: parent.secondKex
                }
                MoneroComponents.StandardButton {
                    id: showQR
                    text: "Show QR Code"

                    onClicked: {
                        qrPopup.open()
                    }
                }
            }

            Popup {
                id: qrPopup
                anchors.centerIn: parent
                width: 200
                height: 200
                modal: true
                focus: true

                Image {
                    id: qrCode
                    anchors.fill: parent
                    anchors.margins: 1

                    smooth: false
                    fillMode: Image.PreserveAspectFit
                    source: "image://qrcode/" + secondKexRow.secondKex
                }

                closePolicy: Popup.CloseOnPressOutside
            }

            MoneroComponents.LineEdit {
                id: multisigKex4Input
                Layout.fillWidth: true
                labelFontSize: 14

                labelText: qsTr("Other participant's multisig kex output") + translationManager.emptyString
                text: wizardController.walletOptionsMultisigKex4
            }

            WizardNav {
                progressSteps: 5
                progress: 3
                btnNext.enabled: multisigKexBooster2Input.text != "" // TODO: some sort of validation on this
                onPrevClicked: {
                    wizardStateView.state = "wizardCreateMultisig3";
                }
                onNextClicked: {
                    wizardController.walletOptionsMultisigKex4 = multisigKex4Input.text;
                    var infoList = wizardController.walletOptionsMultisigKex4.trim().split(",");
                    wizardController.m_wallet.exchangeMultisigKeys(infoList);
                    wizardStateView.state = "wizardCreateWallet3";
                }
            }
        }
    }
}
