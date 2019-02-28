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

import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import Qt.labs.folderlistmodel 2.1

import "../js/Wizard.js" as Wizard
import "../components"
import "../components" as MoneroComponents

Rectangle {
    id: wizardOpenWallet1

    color: "transparent"
    property string viewName: "wizardOpenWallet1"

    FolderListModel {
        // @TODO: Current implementation only lists the folders in `/home/foo/Monero/wallets`, better
        // solution is to actually scan for .keys files.
        id: folderModel
        nameFilters: ["*"]
        folder: "file:" + moneroAccountsDir + "/"

        showFiles: false
        showHidden: false
        sortField: FolderListModel.Time
    }

    ColumnLayout {
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
            spacing: 20 * scaleRatio

            WizardHeader {
                title: qsTr("Open a wallet from file") + translationManager.emptyString
                subtitle: qsTr("Import an existing .keys wallet file from your computer.") + translationManager.emptyString
            }

            MoneroComponents.StandardButton {
                Layout.topMargin: 20 * scaleRatio
                id: btnNext
                small: true
                text: qsTr("Browse filesystem")

                onClicked: {
                    wizardController.openWallet();
                }
            }

            GridLayout {
                visible: folderModel.count > 0
                Layout.topMargin: 30 * scaleRatio
                Layout.fillWidth: true
                columnSpacing: 20 * scaleRatio
                columns: 2

                Text {
                    text: qsTr("Most recent wallets") + translationManager.emptyString
                    font.family: MoneroComponents.Style.fontLight.name
                    font.pixelSize: 16 * scaleRatio
                    color: MoneroComponents.Style.defaultFontColor
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            GridLayout {
                visible: folderModel.count > 0
                Layout.topMargin: 10 * scaleRatio
                Layout.fillWidth: true
                columnSpacing: 20 * scaleRatio
                columns: 2

                ListView {
                    id: recentList
                    property int itemHeight: 42 * scaleRatio
                    property int maxItems: 7

                    clip: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: recentList.itemHeight * folderModel.count
                    Layout.maximumHeight: recentList.itemHeight * recentList.maxItems
                    interactive: false  // disable scrolling

                    delegate: Rectangle {
                        height: recentList.itemHeight
                        width: 200 * scaleRatio
                        property string activeColor: "#26FFFFFF"
                        color: "transparent"

                        RowLayout {
                            height: recentList.itemHeight
                            width: parent.width
                            spacing: 10 * scaleRatio

                            Rectangle {
                                Layout.preferredWidth: recentList.itemHeight
                                Layout.preferredHeight: recentList.itemHeight
                                color: "transparent"

                                Image {
                                    height: recentList.itemHeight
                                    width: recentList.itemHeight
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    fillMode: Image.PreserveAspectFit
                                    source: "../images/open-wallet-from-file.png"
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: recentList.itemHeight
                                color: "transparent"

                                TextArea {
                                    text: fileName
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    color: MoneroComponents.Style.defaultFontColor
                                    font.pixelSize: 18 * scaleRatio

                                    selectionColor: MoneroComponents.Style.dimmedFontColor
                                    selectedTextColor: MoneroComponents.Style.defaultFontColor

                                    selectByMouse: false
                                    wrapMode: Text.WordWrap
                                    textMargin: 0
                                    leftPadding: 0
                                    topPadding: 0
                                    bottomPadding: 0
                                    readOnly: true

                                    // @TODO: Legacy. Remove after Qt 5.8.
                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: false
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                parent.color = parent.activeColor;
                            }
                            onExited: {
                                parent.color = "transparent";
                            }
                            onClicked: {
                                // open wallet
                                if(appWindow.walletMode === 0 || appWindow.walletMode === 1){
                                    wizardController.fetchRemoteNodes(function(){
                                        wizardController.openWalletFile(moneroAccountsDir + "/" + fileName + "/" + fileName + ".keys");
                                    }, function(){
                                        appWindow.showStatusMessage(qsTr("Failed to fetch remote nodes from third-party server."), 5);
                                        wizardController.openWalletFile(moneroAccountsDir + "/" + fileName + "/" + fileName + ".keys");
                                    });
                                } else {
                                    wizardController.openWalletFile(moneroAccountsDir + "/" + fileName + "/" + fileName + ".keys");
                                }
                            }
                        }
                    }

                    model: folderModel
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            WizardNav {
                Layout.topMargin: {
                    if(folderModel.count > 0){
                        return 40 * scaleRatio;
                    } else {
                        return 20 * scaleRatio;
                    }
                }
                progressEnabled: false
                btnPrev.text: qsTr("Back to menu") + translationManager.emptyString
                btnNext.visible: false
                onPrevClicked: {
                    wizardStateView.state = "wizardHome";
                }
            }
        }
    }
}
