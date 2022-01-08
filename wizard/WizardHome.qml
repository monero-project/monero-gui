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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import FontAwesome 1.0
import QtGraphicalEffects 1.0
import moneroComponents.NetworkType 1.0
import moneroComponents.WalletKeysFilesModel 1.0

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

Rectangle {
    id: wizardHome
    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardHome"
    property int walletCount: walletKeysFilesModel2.rowCount()

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                WizardHeader {
                    Layout.bottomMargin: 7
                    Layout.fillWidth: true
                    title: qsTr("Welcome to Monero") + translationManager.emptyString
                    subtitle: ""
                }

                MoneroComponents.LanguageButton {
                    Layout.bottomMargin: 8
                }
            }

            WalletKeysFilesModel {
                id: walletKeysFilesModel2
            }

            Flow {
                id: flow
                visible: wizardHome.walletCount > 0
                spacing: 0
                clip: true

                property int _height: 0
                property int itemHeight: 140
                property int maxRows: 1
                property bool collapsed: true

                Layout.topMargin: 10
                Layout.fillWidth: true
                Layout.preferredHeight: _height

                function calcHeight(){
                    var itemsHeight = Math.ceil(wizardHome.walletCount / 3) * itemHeight;
                    if(itemsHeight >= (flow.itemHeight * flow.maxRows))
                        return flow.itemHeight * flow.maxRows;
                    else
                        return itemsHeight;
                }

                NumberAnimation on _height {
                    id: flowAnimation
                    duration: 150;
                    running: false
                    easing.type: Easing.InQuad;
                    alwaysRunToEnd: true
                    onStopped: {
                        flow.collapsed = !flow.collapsed
                    }
                }

                Repeater {
                    id: recentList
                    clip: true
                    model: walletKeysFilesModel2.proxyModel
                    Layout.fillWidth: true
                    Layout.minimumWidth: flow.itemHeight
                    Layout.preferredHeight: parent.height

                    function openSelectedWalletFile(networktype, path) {
                        persistentSettings.nettype = parseInt(networktype);
                        wizardController.openWalletFile(path);
                    }

                    delegate: Rectangle {
                        // inherited roles from walletKeysFilesModel:
                        // index, fileName, modified, accessed, path, networktype, address
                        id: item
                        height: flow.itemHeight
                        width: wizardHome.walletCount < 4 ? parent.width / wizardHome.walletCount
                                                                                     : parent.width / 5
                        property string networkType: {
                            if(networktype === 0) return qsTr("Mainnet");
                            else if(networktype === 1) return qsTr("Testnet");
                            else if(networktype === 2) return qsTr("Stagenet");
                            return "";
                        }
                        color: item.focus ? MoneroComponents.Style.titleBarButtonHoverColor : "transparent"
                        border.width: item.focus ? 3 : 0
                        border.color: MoneroComponents.Style.inputBorderColorActive

                        ColumnLayout {
                            height: 90
                            width: parent.width
                            spacing: 0
                            anchors.top: parent.top
                            anchors.topMargin: networkType == "" ? 8 : 2

                            Rectangle {
                                id: walletIcon
                                Layout.preferredWidth: 90
                                Layout.preferredHeight: 90
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                                color: "transparent"

                                Image {
                                    id: icon
                                    height: itemMouseArea.containsMouse ? 95 : 90
                                    width: itemMouseArea.containsMouse ? 95 : 90
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: {
                                        if (networktype === 0 && fileName.toLowerCase().includes("viewonly")) return "qrc:///images/open-wallet-from-file-view-only@2x.png";
                                        else if (networktype === 0 && fileName.toLowerCase().includes("trezor")) return "qrc:///images/open-wallet-from-file-trezor@2x.png";
                                        else if (networktype === 0 && fileName.toLowerCase().includes("ledger")) return "qrc:///images/restore-wallet-from-hardware@2x.png";
                                        else if (networktype === 0) return "qrc:///images/open-wallet-from-file-mainnet@2x.png";
                                        else if (networktype === 1) return "qrc:///images/open-wallet-from-file-testnet@2x.png";
                                        else if (networktype === 2) return "qrc:///images/open-wallet-from-file-stagenet@2x.png";
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
                                    lightness: itemMouseArea.containsMouse ? 0.40 : 0.65 // +65%
                                    saturation: 0.0
                                }
                            }

                            ColumnLayout {
                                id: walletTextRectangle
                                Layout.preferredWidth: 90
                                Layout.preferredHeight: walletTypeText.visible ? 40 : 20
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                                Text {
                                    id: walletNameText
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                                    text: {
                                        // truncate on window width
                                        var maxLength = wizardController.layoutScale <= 1 ? 12 : 20
                                        if (fileName.length > maxLength)
                                            return fileName.substring(0, maxLength) + "...";
                                        return fileName;
                                    }
                                    Layout.fillWidth: true
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    color: MoneroComponents.Style.defaultFontColor
                                    font.pixelSize: 16
                                    font.bold: itemMouseArea.containsMouse ? true : false
                                    horizontalAlignment: Text.AlignHCenter

                                    wrapMode: Text.WordWrap
                                    leftPadding: 0
                                    topPadding: 0
                                    bottomPadding: 0
                                }

                                Text {
                                    id: walletTypeText
                                    opacity: appWindow.walletMode >= 2 ? 1 : 0
                                    Layout.fillWidth: true
                                    text: item.networkType
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    color: MoneroComponents.Style.dimmedFontColor
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter

                                    wrapMode: Text.WordWrap
                                    leftPadding: 0
                                    topPadding: 0
                                    bottomPadding: 0
                                }
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

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: appWindow.walletMode >= 2 ? 5 : 0
                Layout.bottomMargin: flow.collapsed ? 0 : 5
                visible: wizardHome.walletCount > 5

                Rectangle {
                    height: 35
                    width: 240
                    color: "transparent"

                    ColumnLayout {
                        anchors.horizontalCenter: parent.horizontalCenter

                        MoneroEffects.ImageMask {
                            id: arrowUp
                            Layout.alignment: Qt.AlignHCenter
                            visible: !flow.collapsed
                            width: 12
                            height: 8
                            image: "qrc:///images/whiteDropIndicator.png"
                            color: MoneroComponents.Style.defaultFontColor
                            opacity: MoneroComponents.Style.blackTheme ? 1 : 0.75
                            fontAwesomeFallbackIcon: FontAwesome.arrowDown
                            fontAwesomeFallbackSize: 14
                            rotation: 180

                            MoneroEffects.ColorTransition {
                                targetObj: arrowUp
                                blackColor: "white"
                                whiteColor: "black"
                                duration: 500
                            }
                        }

                        MoneroComponents.TextPlain {
                            id: showWalletsLabel
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.family: MoneroComponents.Style.fontRegular.name
                            font.pixelSize: 15
                            font.bold: showWalletsMouseArea.containsMouse ? true : false
                            color: showWalletsMouseArea.containsMouse ? MoneroComponents.Style.dimmedFontColor : MoneroComponents.Style.defaultFontColor
                            text: {
                                if (flow.collapsed) {
                                    qsTr("Show wallets") + " (" + wizardHome.walletCount + ")" + translationManager.emptyString
                                } else {
                                    qsTr("Hide wallets") + translationManager.emptyString
                                }
                            }
                        }

                        MoneroEffects.ImageMask {
                            id: arrowDown
                            Layout.alignment: Qt.AlignHCenter
                            visible: flow.collapsed
                            width: 12
                            height: 8
                            image: "qrc:///images/whiteDropIndicator.png"
                            color: MoneroComponents.Style.defaultFontColor
                            opacity: MoneroComponents.Style.blackTheme ? 1 : 0.75
                            fontAwesomeFallbackIcon: FontAwesome.arrowDown
                            fontAwesomeFallbackSize: 14

                            MoneroEffects.ColorTransition {
                                targetObj: arrowDown
                                blackColor: "white"
                                whiteColor: "black"
                                duration: 500
                            }
                        }
                    }

                    MouseArea {
                        id: showWalletsMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            if (flow.collapsed) {
                                flow.maxRows = Math.ceil(wizardHome.walletCount / 5);
                            } else {
                                flow.maxRows = 1;
                            }
                            flowAnimation.from = flow._height;
                            flowAnimation.to = flow.calcHeight();
                            flowAnimation.start();
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                visible: wizardHome.walletCount > 0
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                headerText: qsTr("Create a new wallet") + translationManager.emptyString
                bodyText: qsTr("Choose this option if this is your first time using Monero.") + translationManager.emptyString
                imageIcon: "qrc:///images/create-wallet.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardController.createWallet();
                    wizardStateView.state = "wizardCreateWallet1"
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                headerText: qsTr("Create a new wallet from hardware") + translationManager.emptyString
                bodyText: qsTr("Connect your hardware wallet to create a new Monero wallet.") + translationManager.emptyString
                imageIcon: "qrc:///images/restore-wallet-from-hardware.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardStateView.state = "wizardCreateDevice1"
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                headerText: qsTr("Open a wallet from file") + translationManager.emptyString
                bodyText: qsTr("Import an existing .keys wallet file from your computer.") + translationManager.emptyString
                imageIcon: "qrc:///images/open-wallet-from-file.png"

                onMenuClicked: {
                    wizardController.openWallet();
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 3
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                headerText: qsTr("Restore wallet from keys or mnemonic seed") + translationManager.emptyString
                bodyText: qsTr("Enter your private keys or 25-word mnemonic seed to restore your wallet.") + translationManager.emptyString
                imageIcon: "qrc:///images/restore-wallet.png"

                onMenuClicked: {
                    wizardController.restart();
                    wizardStateView.state = "wizardRestoreWallet1"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16
                spacing: 20

                MoneroComponents.StandardButton {
                    small: true
                    text: qsTr("Change wallet mode") + translationManager.emptyString

                    onClicked: {
                        wizardController.wizardStackView.backTransition = true;
                        wizardController.wizardState = 'wizardModeSelection';
                    }                    
                }
            }

            MoneroComponents.CheckBox2 {
                id: showAdvancedCheckbox
                Layout.topMargin: 30
                Layout.fillWidth: true
                fontSize: 15
                checked: false
                text: qsTr("Advanced options") + translationManager.emptyString
                visible: appWindow.walletMode >= 2
            }

            ListModel {
                id: networkTypeModel
                ListElement {column1: "Mainnet"; column2: ""; nettype: "mainnet"}
                ListElement {column1: "Testnet"; column2: ""; nettype: "testnet"}
                ListElement {column1: "Stagenet"; column2: ""; nettype: "stagenet"}
            }

            GridLayout {
                visible: showAdvancedCheckbox.checked && appWindow.walletMode >= 2
                columns: 4
                columnSpacing: 20
                Layout.fillWidth: true
                Layout.topMargin: 10

                MoneroComponents.StandardDropdown {
                    id: networkTypeDropdown
                    currentIndex: persistentSettings.nettype
                    dataModel: networkTypeModel
                    Layout.maximumWidth: 180
                    labelText: qsTr("Network") + ":" + translationManager.emptyString
                    labelFontSize: 14

                    onChanged: {
                        var item = dataModel.get(currentIndex).nettype.toLowerCase();
                        if(item === "mainnet") {
                            persistentSettings.nettype = NetworkType.MAINNET
                        } else if(item === "stagenet"){
                            persistentSettings.nettype = NetworkType.STAGENET
                        } else if(item === "testnet"){
                            persistentSettings.nettype = NetworkType.TESTNET
                        }
                        appWindow.disconnectRemoteNode()
                    }
                }

                MoneroComponents.LineEdit {
                    id: kdfRoundsText
                    Layout.maximumWidth: 180

                    labelText: qsTr("Number of KDF rounds:") + translationManager.emptyString
                    labelFontSize: 14
                    fontSize: 16
                    placeholderFontSize: 16
                    placeholderText: "0"
                    validator: IntValidator { bottom: 1 }
                    text: persistentSettings.kdfRounds ? persistentSettings.kdfRounds : "1"
                    onTextChanged: {
                        persistentSettings.kdfRounds = parseInt(kdfRoundsText.text) >= 1 ? parseInt(kdfRoundsText.text) : 1;
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200;
            easing.type: Easing.InCubic;
        }
    }

    function onPageCompleted(){
        wizardController.walletOptionsIsRecoveringFromDevice = false;
        walletKeysFilesModel2.refresh(appWindow.accountsDir);
        wizardHome.walletCount = walletKeysFilesModel2.rowCount();
        flow._height = flow.calcHeight();
    }
}
