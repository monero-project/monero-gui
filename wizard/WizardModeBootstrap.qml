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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

Rectangle {
    id: wizardModeBootstrapWarning

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property string viewName: "wizardModeBootstrap"
    property bool understood: false

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;
        KeyNavigation.tab: aboutBootStrapModeHeader

        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            WizardHeader {
                id: aboutBootStrapModeHeader
                title: qsTr("About the bootstrap mode") + translationManager.emptyString
                subtitle: ""
                Accessible.role: Accessible.StaticText
                Accessible.name: title
                Keys.onUpPressed: wizardNav.btnNext.forceActiveFocus();
                Keys.onBacktabPressed: wizardNav.btnNext.forceActiveFocus();
                KeyNavigation.down: text1
                KeyNavigation.tab: text1
            }

            ColumnLayout {
                spacing: 20

                Layout.topMargin: 10
                Layout.fillWidth: true

                MoneroComponents.TextPlain {
                    id: text1
                    text: qsTr("This mode will use a remote node whilst also syncing the blockchain. This is different from the first menu option (Simple mode), since it will only use the remote node until the blockchain is fully synced locally. It is a reasonable tradeoff for most people who care about privacy but also want the convenience of an automatic fallback option.") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.topMargin: 14
                    Layout.fillWidth: true
                    textFormat: Text.RichText

                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    color: MoneroComponents.Style.lightGreyFontColor
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text
                    KeyNavigation.up: aboutBootStrapModeHeader
                    KeyNavigation.backtab: aboutBootStrapModeHeader
                    KeyNavigation.down: text2
                    KeyNavigation.tab: text2
                }

                MoneroComponents.TextPlain {
                    id: text2
                    text: qsTr("Temporary use of remote nodes is useful in order to use Monero immediately (hence the name bootstrap), however be aware that when using remote nodes (including with the bootstrap setting), nodes could track your IP address, track your \"restore height\" and associated block request data, and send you inaccurate information to learn more about transactions you make.") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.topMargin: 8
                    Layout.fillWidth: true

                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    color: MoneroComponents.Style.lightGreyFontColor
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text
                    KeyNavigation.up: text1
                    KeyNavigation.backtab: text1
                    KeyNavigation.down: warningBox
                    KeyNavigation.tab: warningBox
                }

                MoneroComponents.WarningBox{
                    id: warningBox
                    Layout.topMargin: 14
                    Layout.bottomMargin: 6
                    text: qsTr("Remain aware of these limitations.") + " <b>" + qsTr("Users who prioritize privacy and decentralization must use a full node instead.") + "</b>" + translationManager.emptyString
                    Accessible.role: Accessible.AlertMessage
                    Accessible.name: qsTr("Remain aware of these limitations.") + " " + qsTr("Users who prioritize privacy and decentralization must use a full node instead.") + translationManager.emptyString
                    KeyNavigation.up: text2
                    KeyNavigation.backtab: text2
                    KeyNavigation.down: understoodCheckbox
                    KeyNavigation.tab: understoodCheckbox
                }

                MoneroComponents.CheckBox {
                    id: understoodCheckbox
                    Layout.topMargin: 20
                    fontSize: 16
                    text: qsTr("I understand the privacy implications of using a third-party server.") + translationManager.emptyString
                    onClicked: {
                        wizardModeBootstrapWarning.understood = !wizardModeBootstrapWarning.understood
                    }
                    Accessible.role: Accessible.CheckBox
                    Accessible.name: text
                    KeyNavigation.up: warningBox
                    KeyNavigation.backtab: warningBox
                    KeyNavigation.down: wizardNav.btnPrev
                    KeyNavigation.tab: wizardNav.btnPrev
                }

                WizardNav {
                    id: wizardNav
                    Layout.topMargin: 4
                    btnNext.enabled: wizardModeBootstrapWarning.understood
                    progressEnabled: false
                    btnPrevKeyNavigationBackTab: understoodCheckbox
                    btnNextKeyNavigationTab: aboutBootStrapModeHeader

                    onPrevClicked: {
                        wizardController.wizardState = 'wizardModeSelection';
                        wizardStateView.wizardModeSelectionView.pageRoot.forceActiveFocus();
                    }

                    onNextClicked: {
                        appWindow.changeWalletMode(1);
                        wizardController.wizardState = 'wizardHome';
                        wizardStateView.wizardHomeView.pageRoot.forceActiveFocus();
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
        wizardModeBootstrapWarning.understood = false;
        understoodCheckbox.checked = false;
    }
}
