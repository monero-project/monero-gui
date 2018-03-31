// Copyright (c) 2014-2018, The Monero Project
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

import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import moneroComponents.Clipboard 1.0
import "../version.js" as Version
import "../components"
import "." 1.0


Rectangle {
    property bool viewOnly: false
    id: page

    color: "transparent"

    Clipboard { id: clipboard }

    ColumnLayout {
        id: mainLayout

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        anchors.margins: (isMobile)? 17 : 20
        anchors.topMargin: 40 * scaleRatio

        spacing: 30 * scaleRatio
        Layout.fillWidth: true

        RowLayout{
            // TODO: Move the warning box to its own component, so it can be used in multiple places
            visible: warningText.text !== ""
  
            Rectangle {
                id: statusRect
                Layout.preferredHeight: warningText.height + 26
                Layout.fillWidth: true
  
                radius: 2
                border.color: Qt.rgba(255, 255, 255, 0.25)
                border.width: 1
                color: "transparent"
  
                GridLayout{
                    Layout.fillWidth: true
                    Layout.preferredHeight: warningText.height + 40
  
                    Image {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredHeight: 33
                        Layout.preferredWidth: 33
                        Layout.leftMargin: 10
                        Layout.topMargin: 10
                        source: "../images/warning.png"
                    }
  
                    Text {
                        id: warningText
                        Layout.topMargin: 12 * scaleRatio
                        Layout.preferredWidth: statusRect.width - 80
                        Layout.leftMargin: 6
                        text: qsTr("WARNING: Do not reuse your Monero keys on another fork, UNLESS this fork has key reuse mitigations built in. Doing so will harm your privacy." + translationManager.emptyString)
                        wrapMode: Text.Wrap
                        font.family: Style.fontRegular.name
                        font.pixelSize: 15 * scaleRatio
                        color: Style.defaultFontColor
                        textFormat: Text.RichText
                        onLinkActivated: {
                            appWindow.startDaemon(appWindow.persistentSettings.daemonFlags);
                        }
                    }
                }
            }
        }
        
        //! Manage wallet
        ColumnLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                fontSize: 22 * scaleRatio
                Layout.topMargin: 10 * scaleRatio
                text: qsTr("Mnemonic seed") + translationManager.emptyString
            }
            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: Style.dividerColor
                opacity: Style.dividerOpacity
                Layout.bottomMargin: 10 * scaleRatio
            }

            LineEditMulti{
                id: seedText
                spacing: 0
                copyButton: true
                addressValidation: false
                readOnly: true
                wrapAnywhere: false
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                fontSize: 22 * scaleRatio
                Layout.topMargin: 10 * scaleRatio
                text: qsTr("Keys") + translationManager.emptyString
            }
            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: Style.dividerColor
                opacity: Style.dividerOpacity
                Layout.bottomMargin: 10 * scaleRatio
            }
            TextEdit {
                id: keysText
                wrapMode: TextEdit.Wrap
                Layout.fillWidth: true;
                font.pixelSize: 14 * scaleRatio
                textFormat: TextEdit.RichText
                readOnly: true
                color: Style.defaultFontColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        appWindow.showStatusMessage(qsTr("Double tap to copy"),3)
                    }
                    onDoubleClicked: {
                        parent.selectAll()
                        parent.copy()
                        parent.deselect()
                        console.log("copied to clipboard");
                        appWindow.showStatusMessage(qsTr("Keys copied to clipboard"),3)
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                fontSize: 22 * scaleRatio
                Layout.topMargin: 10 * scaleRatio
                text: qsTr("Export wallet") + translationManager.emptyString
            }
            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: Style.dividerColor
                opacity: Style.dividerOpacity
                Layout.bottomMargin: 10 * scaleRatio
            }

            RowLayout {
                StandardButton {
                    enabled: !fullWalletQRCode.visible
                    id: showFullQr
                    small: true
                    text: qsTr("Spendable Wallet") + translationManager.emptyString
                    onClicked: {
                        viewOnlyQRCode.visible = false
                    }
                }
                StandardButton {
                    enabled: fullWalletQRCode.visible
                    id: showViewOnlyQr
                    small: true
                    text: qsTr("View Only Wallet") + translationManager.emptyString
                    onClicked: {
                        viewOnlyQRCode.visible = true
                    }
                }
                Layout.bottomMargin: 30 * scaleRatio
            }

            Image {
                visible: !viewOnlyQRCode.visible
                id: fullWalletQRCode
                Layout.fillWidth: true
                Layout.minimumHeight: 180 * scaleRatio
                smooth: false
                fillMode: Image.PreserveAspectFit
            }

            Image {
                visible: false
                id: viewOnlyQRCode
                Layout.fillWidth: true
                Layout.minimumHeight: 180 * scaleRatio
                smooth: false
                fillMode: Image.PreserveAspectFit
            }

            Text {
                Layout.fillWidth: true
                font.bold: true
                font.pixelSize: 16 * scaleRatio
                color: Style.defaultFontColor
                text: (viewOnlyQRCode.visible) ? qsTr("View Only Wallet") + translationManager.emptyString : qsTr("Spendable Wallet") + translationManager.emptyString
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // fires on every page load
    function onPageCompleted() {
        console.log("keys page loaded");

        keysText.text = "<b>" + qsTr("Secret view key") + ":</b> " + currentWallet.secretViewKey
        keysText.text += "<br><br><b>" + qsTr("Public view key") + ":</b> " + currentWallet.publicViewKey
        keysText.text += (!currentWallet.viewOnly) ? "<br><br><b>" + qsTr("Secret spend key") + ":</b> " + currentWallet.secretSpendKey : ""
        keysText.text += "<br><br><b>" + qsTr("Public spend key") + ":</b> " + currentWallet.publicSpendKey

        seedText.text = currentWallet.seed

        if(typeof currentWallet != "undefined") {
            viewOnlyQRCode.source = "image://qrcode/monero:" + currentWallet.address+"?secret_view_key="+currentWallet.secretViewKey+"&restore_height="+currentWallet.restoreHeight
            fullWalletQRCode.source = viewOnlyQRCode.source +"&secret_spend_key="+currentWallet.secretSpendKey

            if(currentWallet.viewOnly) {
                viewOnlyQRCode.visible = true
                showFullQr.visible = false
                showViewOnlyQr.visible = false
                seedText.text = qsTr("(View Only Wallet -  No mnemonic seed available)") + translationManager.emptyString
            }
        }
    }

    // fires only once
    Component.onCompleted: {

    }

}





