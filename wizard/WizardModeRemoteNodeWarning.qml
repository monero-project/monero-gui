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
    id: wizardModeRemoteNodeWarning

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardModeRemoteNodeWarning"
    property bool understood: false

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
                title: qsTr("About the simple mode") + translationManager.emptyString
                subtitle: ""
            }

            ColumnLayout {
                spacing: 20

                Layout.topMargin: 10
                Layout.fillWidth: true

                MoneroComponents.TextPlain {
                    text: qsTr("This mode is ideal for managing small amounts of Monero. You have access to basic features for making and managing transactions. It will automatically connect to the Monero network so you can start using Monero immediately.") + translationManager.emptyString
                    themeTransitionBlackColor: MoneroComponents.Style._b_lightGreyFontColor
                    themeTransitionWhiteColor: MoneroComponents.Style._w_lightGreyFontColor
                    wrapMode: Text.Wrap
                    Layout.topMargin: 14
                    Layout.fillWidth: true

                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    color: MoneroComponents.Style.lightGreyFontColor
                }

                MoneroComponents.TextPlain {
                    text: qsTr("Remote nodes are useful if you are not able/don't want to download the whole blockchain, but be advised that malicious remote nodes could compromise some privacy. They could track your IP address, track your \"restore height\" and associated block request data, and send you inaccurate information to learn more about transactions you make.") + translationManager.emptyString
                    themeTransitionBlackColor: MoneroComponents.Style._b_lightGreyFontColor
                    themeTransitionWhiteColor: MoneroComponents.Style._w_lightGreyFontColor
                    wrapMode: Text.Wrap
                    Layout.topMargin: 8
                    Layout.fillWidth: true

                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    color: MoneroComponents.Style.lightGreyFontColor
                }

                MoneroComponents.WarningBox {
                    Layout.topMargin: 14
                    Layout.bottomMargin: 6
                    text: qsTr("Remain aware of these limitations. <b>Users who prioritize privacy and decentralization must use a full node instead</b>.") + translationManager.emptyString
                }

                MoneroComponents.CheckBox {
                    id: understoodCheckbox
                    Layout.topMargin: 20
                    fontSize: 16
                    text: qsTr("I understand the privacy implications of using a third-party server.") + translationManager.emptyString
                    onClicked: {
                        wizardModeRemoteNodeWarning.understood = !wizardModeRemoteNodeWarning.understood
                    }
                }

                WizardNav {
                    Layout.topMargin: 4
                    btnNext.enabled: wizardModeRemoteNodeWarning.understood
                    progressSteps: 0

                    onPrevClicked: {
                        wizardController.wizardState = 'wizardModeSelection';
                    }

                    onNextClicked: {
                        appWindow.changeWalletMode(0);
                        wizardController.wizardState = 'wizardHome';
                    }
                }
            }
        }
    }

    ListModel {
        id: regionModel
        ListElement {column1: "Unspecified"; region: ""}
        ListElement {column1: "Africa"; region: "af"}
        ListElement {column1: "Asia"; region: "as"}
        ListElement {column1: "Central America"; region: "ca";}
        ListElement {column1: "North America"; region: "na";}
        ListElement {column1: "Europe"; region: "eu";}
        ListElement {column1: "Oceania"; region: "oc";}
        ListElement {column1: "South America"; region: "sa";}
    }

    function onPageCompleted(previousView){
        wizardModeRemoteNodeWarning.understood = false;
        understoodCheckbox.checked = false;
    }
}
