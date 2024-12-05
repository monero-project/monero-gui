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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import Qt.labs.folderlistmodel 2.1
import moneroComponents.NetworkType 1.0
import moneroComponents.WalletKeysFilesModel 1.0
import FontAwesome 1.0

import "../js/Wizard.js" as Wizard
import "../components"
import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

Rectangle {
    id: wizardOpenWallet1

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property string viewName: "wizardOpenWallet1"
    property int walletCount: walletKeysFilesModel.rowCount()

    WalletKeysFilesModel {
        id: walletKeysFilesModel
    }

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;
        KeyNavigation.tab: openWalletFromFileHeader

        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            WizardHeader {
                id: openWalletFromFileHeader
                title: qsTr("Open a wallet from file") + translationManager.emptyString
                subtitle: qsTr("Import an existing .keys wallet file from your computer.") + translationManager.emptyString
                Accessible.role: Accessible.StaticText
                Accessible.name: title + ". " + subtitle
                Keys.onUpPressed: wizardNav.btnNext.forceActiveFocus();
                Keys.onBacktabPressed: wizardNav.btnNext.forceActiveFocus();
                Keys.onDownPressed: recentList.itemAt(0).forceActiveFocus();
                Keys.onTabPressed: recentList.itemAt(0).forceActiveFocus();
            }

            GridLayout {
                visible: (walletKeysFilesModel ? walletKeysFilesModel.rowCount() : 0) > 0
                Layout.topMargin: 10
                Layout.fillWidth: true
                columnSpacing: 20
                columns: 2

                MoneroComponents.TextPlain {
                    Layout.fillWidth: true
                    text: qsTr("Recently opened") + ":" + translationManager.emptyString
                    font.family: MoneroComponents.Style.fontLight.name
                    font.pixelSize: 16
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            Flow {
                id: flow
                visible: wizardOpenWallet1.walletCount > 0
                spacing: 0
                clip: true

                property int _height: 0
                property int itemHeight: 50
                property int maxRows: 6

                Layout.topMargin: 10
                Layout.fillWidth: true
                Layout.preferredHeight: _height

                function calcHeight(){
                    var itemsHeight = Math.ceil(wizardOpenWallet1.walletCount / 3) * itemHeight;
                    if(itemsHeight >= (flow.itemHeight * flow.maxRows))
                        return flow.itemHeight * flow.maxRows;
                    else
                        return itemsHeight;
                }

                Repeater {
                    id: recentList
                    clip: true
                    model: walletKeysFilesModel.proxyModel
                    Layout.fillWidth: true
                    Layout.minimumWidth: flow.itemHeight
                    Layout.preferredHeight: parent.height

                    function moveUp(itemIndex) {
                        if (itemIndex == 0) {
                            openWalletFromFileHeader.forceActiveFocus();
                        } else {
                            recentList.itemAt(itemIndex - 1).forceActiveFocus();
                        }
                    }

                    function moveDown(itemIndex) {
                        if (itemIndex + 1 == recentList.count) {
                            wizardNav.btnPrev.forceActiveFocus();
                        } else {
                            recentList.itemAt(itemIndex + 1).forceActiveFocus();
                        }
                    }

                    function openSelectedWalletFile(networktype, path) {
                        persistentSettings.nettype = parseInt(networktype);
                        wizardController.openWalletFile(path);
                    }

                    delegate: Rectangle {
                        // inherited roles from walletKeysFilesModel:
                        // index, fileName, modified, accessed, path, networktype, address
                        id: item
                        height: flow.itemHeight
                        width: {
                            if(wizardController.layoutScale <= 1)
                                return parent.width / 2
                            return parent.width / 3
                        }
                        property string networkType: {
                            if(networktype === 0 && appWindow.walletMode >= 2) return qsTr("Mainnet");
                            else if(networktype === 1) return qsTr("Testnet");
                            else if(networktype === 2) return qsTr("Stagenet");
                            return "";
                        }
                        color: item.focus || itemMouseArea.containsMouse ? MoneroComponents.Style.titleBarButtonHoverColor : "transparent"
                        border.width: item.focus ? 3 : 0
                        border.color: MoneroComponents.Style.inputBorderColorActive

                        Accessible.role: Accessible.ListItem
                        Accessible.name: {
                            if (networktype === 0) var networkTypeText = qsTr("Mainnet wallet") + translationManager.emptyString;
                            if (networktype === 1) var networkTypeText = qsTr("Testnet wallet") + translationManager.emptyString;
                            if (networktype === 2) var networkTypeText = qsTr("Stagenet wallet") + translationManager.emptyString;

                            return fileName + ". " + networkTypeText;
                        }
                        Keys.onUpPressed: recentList.moveUp(index);
                        Keys.onBacktabPressed: recentList.moveUp(index);
                        Keys.onDownPressed: recentList.moveDown(index);
                        Keys.onTabPressed: recentList.moveDown(index);
                        Keys.onEnterPressed: recentList.openSelectedWalletFile(networktype, path);
                        Keys.onReturnPressed: recentList.openSelectedWalletFile(networktype, path);

                        Rectangle {
                            height: 1
                            width: parent.width
                            anchors.top: parent.top
                            color: MoneroComponents.Style.appWindowBorderColor
                            visible: index <= 2  // top row

                            MoneroEffects.ColorTransition {
                                targetObj: parent
                                blackColor: MoneroComponents.Style._b_appWindowBorderColor
                                whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                            }
                        }

                        RowLayout {
                            height: flow.itemHeight
                            width: parent.width
                            spacing: 6

                            Rectangle {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: flow.itemHeight
                                color: "transparent"

                                Image {
                                    id: icon
                                    height: 48
                                    width: 48
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    fillMode: Image.PreserveAspectFit
                                    source: {
                                        if (networktype === 0 && fileName.toLowerCase().includes("viewonly")) return "qrc:///images/open-wallet-from-file-view-only.png";
                                        else if (networktype === 0 && fileName.toLowerCase().includes("trezor")) return "qrc:///images/open-wallet-from-file-trezor.png";
                                        else if (networktype === 0 && fileName.toLowerCase().includes("ledger")) return "qrc:///images/restore-wallet-from-hardware.png";
                                        else if (networktype === 0) return "qrc:///images/open-wallet-from-file-mainnet.png";
                                        else if (networktype === 1) return "qrc:///images/open-wallet-from-file-testnet.png";
                                        else if (networktype === 2) return "qrc:///images/open-wallet-from-file-stagenet.png";
                                    }
                                    visible: {
                                        if(!isOpenGL) return true;
                                        if(MoneroComponents.Style.blackTheme) return true;
                                        return false;
                                    }
                                }

                                Colorize {
                                    visible: isOpenGL && !MoneroComponents.Style.blackTheme
                                    anchors.fill: icon
                                    source: icon
                                    lightness: 0.65 // +65%
                                    saturation: 0.0
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: flow.itemHeight
                                spacing: 0

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: {
                                        // truncate on window width
                                        var maxLength = wizardController.layoutScale <= 1 ? 12 : 16
                                        if (fileName.length > maxLength)
                                            return fileName.substring(0, maxLength) + "...";
                                        return fileName;
                                    }

                                    Layout.preferredHeight: 26
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    color: MoneroComponents.Style.defaultFontColor
                                    font.pixelSize: 16

                                    wrapMode: Text.WordWrap
                                    leftPadding: 0
                                    topPadding: networkType !== "" ? 8 : 4
                                    bottomPadding: 0
                                }

                                Text {
                                    visible: networkType !== ""
                                    Layout.preferredHeight: 24
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    text: item.networkType
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    color: MoneroComponents.Style.dimmedFontColor
                                    font.pixelSize: 14

                                    wrapMode: Text.WordWrap
                                    leftPadding: 0
                                    topPadding: 0
                                    bottomPadding: 0
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Rectangle {
                            height: 1
                            width: parent.width
                            color: MoneroComponents.Style.appWindowBorderColor
                            anchors.bottom: parent.bottom

                            MoneroEffects.ColorTransition {
                                targetObj: parent
                                blackColor: MoneroComponents.Style._b_appWindowBorderColor
                                whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                            }
                        }

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: recentList.openSelectedWalletFile(networktype, path);
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            WizardNav {
                id: wizardNav
                Layout.topMargin: 0
                progressEnabled: false
                btnPrev.text: appWindow.width <= 506 ? "<" : qsTr("Back to menu") + translationManager.emptyString
                btnNext.text: appWindow.width <= 506 ? qsTr("Browse") : qsTr("Browse filesystem") + translationManager.emptyString
                btnNext.width: appWindow.width <= 506 ? 80 : appWindow.width <= 660 ? 120 : 180
                btnNext.visible: true
                btnPrevKeyNavigationBackTab: recentList.itemAt(recentList.count - 1)
                btnNextKeyNavigationTab: openWalletFromFileHeader

                onPrevClicked: {
                    wizardStateView.state = "wizardHome";
                }
                onNextClicked: {
                    wizardController.openWallet();
                }
            }
        }
    }

    function onPageCompleted(previousView){
        if(previousView.viewName == "wizardHome"){
            walletKeysFilesModel.refresh(appWindow.accountsDir);
            wizardOpenWallet1.walletCount = walletKeysFilesModel.rowCount();
            flow._height = flow.calcHeight();
        }
    }
}
