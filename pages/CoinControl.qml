// Copyright (c) 2026, The Monero Project
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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects
import "../js/TxUtils.js" as TxUtils

import moneroComponents.Clipboard 1.0

Rectangle {
    id: root
    property alias panelHeight: mainLayout.height
    // public key of the output being frozen or thawed, empty when idle
    property string pendingPubKey: ""
    color: "transparent"

    Clipboard { id: clipboard }

    ColumnLayout {
        id: mainLayout
        anchors.margins: 20
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 20

        MoneroComponents.Label {
            fontSize: 24
            text: qsTr("Coins") + translationManager.emptyString
        }

        MoneroComponents.TextPlain {
            Layout.fillWidth: true
            text: qsTr("Unspent outputs of the current account. Frozen outputs are excluded from your balance and are never used to pay for a transaction until they are thawed.") + translationManager.emptyString
            wrapMode: Text.Wrap
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.TextPlain {
            visible: coinsListView.count == 0
            text: qsTr("No unspent outputs") + translationManager.emptyString
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.dimmedFontColor
        }

        ColumnLayout {
            id: coinsListRow
            property int coinsListItemHeight: 60
            Layout.fillWidth: true
            Layout.preferredHeight: coinsListItemHeight * coinsListView.count
            visible: coinsListView.count >= 1
            spacing: 0

            ListView {
                id: coinsListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                boundsBehavior: ListView.StopAtBounds
                interactive: false

                delegate: Rectangle {
                    height: coinsListRow.coinsListItemHeight
                    width: parent ? parent.width : undefined
                    color: "transparent"

                    Rectangle {
                        color: MoneroComponents.Style.appWindowBorderColor
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.top: parent.top
                        height: 1
                        visible: index !== 0

                        MoneroEffects.ColorTransition {
                            targetObj: parent
                            blackColor: MoneroComponents.Style._b_appWindowBorderColor
                            whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                        }
                    }

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: freezeButton.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        RowLayout {
                            spacing: 10

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontMonoRegular.name
                                font.pixelSize: 16
                                color: frozen ? MoneroComponents.Style.dimmedFontColor : MoneroComponents.Style.defaultFontColor
                                text: amount + " XMR"
                                themeTransition: false
                            }

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 14
                                color: frozen ? MoneroComponents.Style.orange : MoneroComponents.Style.dimmedFontColor
                                text: {
                                    var status = [];
                                    if (frozen)
                                        status.push(qsTr("Frozen"));
                                    if (!unlocked)
                                        status.push(qsTr("Locked"));
                                    return status.join(" · ") + translationManager.emptyString;
                                }
                                themeTransition: false
                            }
                        }

                        RowLayout {
                            spacing: 10

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 13
                                color: MoneroComponents.Style.dimmedFontColor
                                text: "#" + subaddrIndex + " " + addressLabel
                                themeTransition: false
                            }

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontMonoRegular.name
                                font.pixelSize: 13
                                color: MoneroComponents.Style.dimmedFontColor
                                text: TxUtils.addressTruncate(hash, 8) + ":" + outputIndex
                                tooltip: qsTr("Copy transaction ID to clipboard") + translationManager.emptyString
                                themeTransition: false

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: parent.tooltipPopup.open()
                                    onExited: parent.tooltipPopup.close()
                                    onClicked: {
                                        clipboard.setText(hash);
                                        appWindow.showStatusMessage(qsTr("Transaction ID copied to clipboard") + translationManager.emptyString, 3);
                                    }
                                }
                            }

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 13
                                color: MoneroComponents.Style.dimmedFontColor
                                text: qsTr("Height %1").arg(blockHeight) + translationManager.emptyString
                                themeTransition: false
                            }
                        }
                    }

                    MoneroComponents.StandardButton {
                        id: freezeButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        small: true
                        primary: !frozen
                        enabled: root.pendingPubKey === ""
                        text: (frozen ? qsTr("Thaw") : qsTr("Freeze")) + translationManager.emptyString
                        onClicked: root.setFrozen(pubKey, !frozen)
                    }
                }
            }
        }
    }

    function setFrozen(publicKey, freeze) {
        root.pendingPubKey = publicKey;
        appWindow.currentWallet.coins.setFrozenAsync(publicKey, freeze, function(success, error) {
            root.pendingPubKey = "";
            if (!success) {
                console.error("Failed to update output: " + error);
                appWindow.showStatusMessage(qsTr("Failed to update output") + translationManager.emptyString, 3);
                return;
            }

            appWindow.updateBalance();
            // store now rather than when the wallet is closed
            appWindow.currentWallet.storeAsync(function(success) {
                if (!success) {
                    appWindow.showStatusMessage(qsTr("Failed to store the wallet") + translationManager.emptyString, 3);
                }
            });
        });
    }

    function onPageCompleted() {
        if (appWindow.currentWallet !== undefined) {
            appWindow.currentWallet.coins.refresh(appWindow.currentWallet.currentSubaddressAccount);
            coinsListView.model = appWindow.currentWallet.coinsModel;
        }
    }
}
