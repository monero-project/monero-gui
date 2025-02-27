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

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

Rectangle {
    id: wizardProtectConnection1

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardProtectConnection1"

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            WizardHeader {
                title: qsTr("Monero can protect your internet connection") + translationManager.emptyString
                subtitle: ""
            }

            ColumnLayout {
                spacing: 20

                Layout.topMargin: 10
                Layout.fillWidth: true

                MoneroComponents.TextPlain {
                    text: qsTr("Monero can optionally connect to the network using anonymizing software to better protect your identity. Would you like to enable this feature?") + translationManager.emptyString
                    themeTransitionBlackColor: MoneroComponents.Style._b_lightGreyFontColor
                    themeTransitionWhiteColor: MoneroComponents.Style._w_lightGreyFontColor
                    wrapMode: Text.Wrap
                    Layout.topMargin: 14
                    Layout.fillWidth: true

                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    color: MoneroComponents.Style.lightGreyFontColor
                }

                MoneroComponents.WarningBox {
                    Layout.topMargin: 14
                    Layout.bottomMargin: 6
                    text: qsTr("Some countries and ISPs may prohibit or censor use of these networks. Please check your local laws and internet policies before using them.") + translationManager.emptyString
                }

                MoneroComponents.RadioButton {
                    id: handleProtectButton
                    text: qsTr("Protect my network connection") + translationManager.emptyString
                    fontSize: 16
                    enabled: !checked
                    checked: false
                    onClicked: {
                        handleProtectButton.checked = true;
                        handleUnprotectButton.checked = false;
                        persistentSettings.protectConnectionMode = 1;
                    }
                }

                MoneroComponents.RadioButton {
                    id: handleUnprotectButton
                    text: qsTr("Do not protect my connection") + translationManager.emptyString
                    fontSize: 16
                    enabled: !checked
                    checked: false
                    onClicked: {
                        handleProtectButton.checked = false;
                        handleUnprotectButton.checked = true;
                        persistentSettings.protectConnectionMode = 0;
                    }
                }

                WizardNav {
                    Layout.topMargin: 4
                    btnNext.enabled: handleProtectButton.checked || handleUnprotectButton.checked
                    progressSteps: 0

                    onPrevClicked: {
                        wizardController.wizardState = 'wizardModeSelection';
                    }

                    onNextClicked: {
                        wizardController.wizardState = 'wizardHome';
                    }
                }
            }
        }
    }
}
