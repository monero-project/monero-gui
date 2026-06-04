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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import moneroComponents.Clipboard 1.0
import "../version.js" as Version
import "../components" as MoneroComponents
import "." 1.0


Rectangle {
    id: page
    property bool viewOnly: false
    property int keysHeight: mainLayout.height + 100 // Ensure sufficient height for QR code, even in minimum width window case.
    property var seed: ""
    property var walletCreationHeight: ""
    property var currentWalletAddress: ""
    property var secretViewKey: ""
    property var publicViewKey: ""
    property var secretSpendKey: ""
    property var publicSpendKey: ""

    color: "transparent"

    Clipboard { id: clipboard }

    state: "default"
    states: [
        State {
            // normal spend wallet
            name: "default";
            when: typeof currentWallet != "undefined" && !page.viewOnly && !currentWallet.isHwBacked()
            PropertyChanges { target: seedWarningBox; visible: true}
            PropertyChanges { target: seedText; text: page.seed}
            PropertyChanges { target: seedText; copyButton: true}
            PropertyChanges { target: secretSpendKey; text: page.secretSpendKey}
            PropertyChanges { target: secretSpendKey; copyButton: true}
            PropertyChanges { target: exportWalletAsQRCodeColumn; visible: false }
        }, State {
            // view-only wallet
            name: "viewonly";
            when: typeof currentWallet != "undefined" && page.viewOnly
            PropertyChanges { target: seedWarningBox; visible: false}
            PropertyChanges { target: seedText; text: qsTr("(View-only wallet - No mnemonic seed available)") + translationManager.emptyString }
            PropertyChanges { target: seedText; copyButton: false}
            PropertyChanges { target: secretSpendKey; text: qsTr("(View-only wallet - No secret spend key available)") + translationManager.emptyString }
            PropertyChanges { target: secretSpendKey; copyButton: false}
            PropertyChanges { target: exportWalletAsQRCodeColumn; visible: false }
        }, State {
            // hardware wallet
            name: "hardwarewallet";
            when: typeof currentWallet != "undefined" && currentWallet.isHwBacked()
            PropertyChanges { target: seedWarningBox; visible: false}
            PropertyChanges { target: seedText; text: qsTr("Mnemonic seed protected by hardware device.") + translationManager.emptyString }
            PropertyChanges { target: seedText; copyButton: false}
            PropertyChanges { target: secretSpendKey; text: qsTr("(Hardware device wallet - No secret spend key available)") + translationManager.emptyString }
            PropertyChanges { target: secretSpendKey; copyButton: false}
            PropertyChanges { target: exportWalletAsQRCodeColumn; visible: false }
        }
    ]

    ColumnLayout {
        id: mainLayout

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        anchors.margins: 20
        anchors.topMargin: 40

        spacing: 30
        Layout.fillWidth: true

        MoneroComponents.WarningBox {
            text: qsTr("WARNING: Do not reuse your Monero keys on another fork, UNLESS this fork has key reuse mitigations built in. Doing so will harm your privacy.") + translationManager.emptyString;
        }

        //! Manage wallet
        ColumnLayout {
            Layout.fillWidth: true

            MoneroComponents.Label {
                Layout.fillWidth: true
                fontSize: 22
                Layout.topMargin: 10
                text: qsTr("Mnemonic seed") + translationManager.emptyString
            }

            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
                Layout.bottomMargin: 10
            }

            MoneroComponents.WarningBox {
                id: seedWarningBox
                text: qsTr("WARNING: Copying your seed to clipboard can expose you to malicious software, which may record your seed and steal your Monero. Please write down your seed manually.") + translationManager.emptyString
            }

            MoneroComponents.LineEditMulti {
                id: seedText
                spacing: 0
                copyButton: true
                addressValidation: false
                readOnly: true
                wrapMode: Text.WordWrap
                fontColor: MoneroComponents.Style.defaultFontColor
                text: page.seed
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            MoneroComponents.Label {
                Layout.fillWidth: true
                fontSize: 22
                Layout.topMargin: 10
                text: qsTr("Wallet restore height") + translationManager.emptyString
            }

            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
                Layout.bottomMargin: 10
            }

            MoneroComponents.LineEdit {
                Layout.fillWidth: true
                id: walletCreationHeight
                readOnly: true
                copyButton: true
                labelText: qsTr("Block #") + translationManager.emptyString
                fontSize: 16
                text: page.walletCreationHeight
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            MoneroComponents.Label {
                Layout.fillWidth: true
                fontSize: 22
                Layout.topMargin: 10
                text: qsTr("Primary address & Keys") + translationManager.emptyString
            }
            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
                Layout.bottomMargin: 10
            }
            MoneroComponents.LineEditMulti {
                Layout.fillWidth: true
                id: primaryAddress
                readOnly: true
                copyButton: true
                wrapMode: Text.Wrap
                labelText: qsTr("Primary address") + translationManager.emptyString
                fontSize: 16
                text: page.currentWalletAddress
            }
            MoneroComponents.LineEdit {
                Layout.fillWidth: true
                Layout.topMargin: 25
                id: secretViewKey
                readOnly: true
                copyButton: true
                labelText: qsTr("Secret view key") + translationManager.emptyString
                fontSize: 16
                text: page.secretViewKey
            }
            MoneroComponents.LineEdit {
                Layout.fillWidth: true
                Layout.topMargin: 25
                id: publicViewKey
                readOnly: true
                copyButton: true
                labelText: qsTr("Public view key") + translationManager.emptyString
                fontSize: 16
                text: page.publicViewKey
            }
            MoneroComponents.LineEdit {
                Layout.fillWidth: true
                Layout.topMargin: 25
                id: secretSpendKey
                readOnly: true
                copyButton: true
                labelText: qsTr("Secret spend key") + translationManager.emptyString
                fontSize: 16
                text: page.secretSpendKey
            }
            MoneroComponents.LineEdit {
                Layout.fillWidth: true
                Layout.topMargin: 25
                id: publicSpendKey
                readOnly: true
                copyButton: true
                labelText: qsTr("Public spend key") + translationManager.emptyString
                fontSize: 16
                text: page.publicSpendKey
            }
        }

        ColumnLayout {
            id: exportWalletAsQRCodeColumn
            Layout.fillWidth: true

            MoneroComponents.Label {
                Layout.fillWidth: true
                fontSize: 22
                Layout.topMargin: 10
                text: qsTr("Export wallet") + translationManager.emptyString
            }
            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
                Layout.bottomMargin: 10
            }

            ColumnLayout {
                id: walletTypeRadioButtons
                Layout.bottomMargin: 30

                MoneroComponents.RadioButton {
                    id: showFullQr
                    checked: true
                    enabled: !this.checked
                    text: qsTr("Spendable Wallet") + translationManager.emptyString
                    onClicked: {
                        showViewOnlyQr.checked = false
                    }
                }
                MoneroComponents.RadioButton {
                    id: showViewOnlyQr
                    checked: false
                    enabled: !this.checked
                    text: qsTr("View Only Wallet") + translationManager.emptyString
                    onClicked: {
                        showFullQr.checked = false
                    }
                }
            }

            Image {
                id: fullWalletQRCode
                visible: showFullQr.checked
                Layout.fillWidth: true
                Layout.minimumHeight: 180
                smooth: false
                fillMode: Image.PreserveAspectFit
                source: viewOnlyQRCode.source +"&spend_key="+page.secretSpendKey
            }

            Image {
                id: viewOnlyQRCode
                visible: showViewOnlyQr.checked
                Layout.fillWidth: true
                Layout.minimumHeight: 180
                smooth: false
                fillMode: Image.PreserveAspectFit
                source: "image://qrcode/monero_wallet:" + page.currentWalletAddress + "?view_key="+page.secretViewKey+"&height="+page.walletCreationHeight
                }

            MoneroComponents.TextPlain {
                Layout.fillWidth: true
                font.bold: true
                font.pixelSize: 16
                color: MoneroComponents.Style.defaultFontColor
                text: (viewOnlyQRCode.visible) ? qsTr("View Only Wallet") + translationManager.emptyString : qsTr("Spendable Wallet") + translationManager.emptyString
                horizontalAlignment: Text.AlignHCenter
            }
        }

        MoneroComponents.StandardButton {
            Layout.alignment: Qt.AlignCenter
            width: 135
            small: true
            text: qsTr("Done") + translationManager.emptyString
            onClicked: {
                loadPage("Settings")
            }
        }
    }

    // fires on every page load
    function onPageCompleted() {
        console.log("keys page loaded");
        if (appWindow.currentWallet) {
            page.viewOnly = currentWallet.viewOnly;
            page.seed = currentWallet.seed;
            page.secretSpendKey = currentWallet.secretSpendKey;
            page.publicSpendKey = currentWallet.publicSpendKey;
            page.secretViewKey = currentWallet.secretViewKey;
            page.publicViewKey = currentWallet.publicViewKey;
            page.walletCreationHeight = currentWallet.walletCreationHeight;
            page.currentWalletAddress = currentWallet.address(0, 0)
        }
    }

    // fires only once
    Component.onCompleted: {

    }

}





