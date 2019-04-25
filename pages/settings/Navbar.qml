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

import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../../js/Windows.js" as Windows
import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents
import "../../pages"
import "."
import moneroComponents.Clipboard 1.0

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 96
    color: "transparent"

    ColumnLayout {
        spacing: 0
        Layout.preferredHeight: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        GridLayout {
            id: grid
            Layout.alignment: Qt.AlignHCenter
            columnSpacing: 0
            property string fontColorActive: MoneroComponents.Style.blackTheme ? "white" : "white"
            property string fontColorInActive: MoneroComponents.Style.blackTheme ? "white" : MoneroComponents.Style.dimmedFontColor
            property int fontSize: 15
            property bool fontBold: true
            property var fontFamily: MoneroComponents.Style.fontRegular.name
            property string borderColor: MoneroComponents.Style.blackTheme ? "#808080" : "#B9B9B9"
            property int textMargin: {
                // left-right margins for a given cell
                if(isMobile){
                    return 10;
                } else if(appWindow.width < 890){
                    return 32;
                } else {
                    return 64;
                }
            }

            Rectangle {
                // navbar left side border
                id: navBarLeft
                property bool isActive: settingsStateView.state === "Wallet"
                Layout.preferredWidth: 2
                Layout.preferredHeight: 32
                color: "transparent"

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: parent.height - 2
                    color: grid.borderColor
                }

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    spacing: 0

                    Rectangle {
                        Layout.preferredHeight: 1
                        Layout.preferredWidth: 1
                        color: grid.borderColor
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        width: 1
                        color: navBarLeft.isActive ? grid.borderColor : "transparent"
                    }

                    Rectangle {
                        color: grid.borderColor
                        Layout.preferredHeight: 1
                        Layout.preferredWidth: 1
                    }
                }
            }

            ColumnLayout {
                // WALLET
                id: navWallet
                property bool isActive: settingsStateView.state === "Wallet"
                Layout.preferredWidth: navWalletText.width + grid.textMargin
                Layout.minimumWidth: 72
                Layout.preferredHeight: 32
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: parent.isActive ? grid.borderColor : "transparent"
                    height: 30
                    Layout.fillWidth: true

                    MoneroComponents.TextPlain {
                        id: navWalletText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Wallet") + translationManager.emptyString
                        color: navWallet.isActive ? grid.fontColorActive : grid.fontColorInActive
                        themeTransition: false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: { settingsStateView.state = "Wallet" }
                    }
                }

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }
            }
            Rectangle{
                Layout.preferredWidth: 1
                Layout.preferredHeight: 32
                color: grid.borderColor
            }
            ColumnLayout {
                // UI
                id: navUI
                property bool isActive: settingsStateView.state === "UI"
                Layout.preferredWidth: navUIText.width + grid.textMargin
                Layout.preferredHeight: 32
                Layout.minimumWidth: 72
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: parent.isActive ? grid.borderColor : "transparent"
                    height: 30
                    Layout.fillWidth: true

                    MoneroComponents.TextPlain {
                        id: navUIText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Interface") + translationManager.emptyString
                        color: navUI.isActive ? grid.fontColorActive : grid.fontColorInActive
                        themeTransition: false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: { settingsStateView.state = "UI" }
                    }
                }

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }
            }
            Rectangle{
                Layout.preferredWidth: 1
                Layout.preferredHeight: 32
                color: grid.borderColor
            }
            ColumnLayout {
                // NODE
                id: navNode
                property bool isActive: settingsStateView.state === "Node"
                visible: appWindow.walletMode >= 2
                Layout.preferredWidth: navNodeText.width + grid.textMargin
                Layout.preferredHeight: 32
                Layout.minimumWidth: 72
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: parent.isActive ? grid.borderColor : "transparent"
                    height: 30
                    Layout.fillWidth: true

                    MoneroComponents.TextPlain {
                        id: navNodeText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Node") + translationManager.emptyString
                        color: navNode.isActive ? grid.fontColorActive : grid.fontColorInActive
                        themeTransition: false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: { settingsStateView.state = "Node" }
                    }
                }

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }
            }
            Rectangle{
                visible: appWindow.walletMode >= 2
                Layout.preferredWidth: 1
                Layout.preferredHeight: 32
                color: grid.borderColor
            }
            ColumnLayout {
                // LOG
                id: navLog
                property bool isActive: settingsStateView.state === "Log"
                visible: appWindow.walletMode >= 2
                Layout.preferredWidth: navLogText.width + grid.textMargin
                Layout.preferredHeight: 32
                Layout.minimumWidth: 72
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: parent.isActive ? grid.borderColor : "transparent"
                    height: 30
                    Layout.fillWidth: true

                    MoneroComponents.TextPlain {
                        id: navLogText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Log") + translationManager.emptyString
                        color: navLog.isActive ? grid.fontColorActive : grid.fontColorInActive
                        themeTransition: false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: { settingsStateView.state = "Log" }
                    }
                }

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }
            }
            Rectangle{
                visible: appWindow.walletMode >= 2
                Layout.preferredWidth: 1
                Layout.preferredHeight: 32
                color: grid.borderColor
            }
            ColumnLayout {
                // INFO
                id: navInfo
                property bool isActive: settingsStateView.state === "Info"
                Layout.preferredWidth: navInfoText.width + grid.textMargin
                Layout.preferredHeight: 32
                Layout.minimumWidth: 72
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: parent.isActive ? grid.borderColor : "transparent"
                    height: 30
                    Layout.fillWidth: true

                    MoneroComponents.TextPlain {
                        id: navInfoText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Info") + translationManager.emptyString
                        color: navInfo.isActive ? grid.fontColorActive : grid.fontColorInActive
                        themeTransition: false
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: { settingsStateView.state = "Info" }
                    }
                }

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                // navbar right side border
                id: navBarRight
                property bool isActive: settingsStateView.state === "Info"
                Layout.preferredWidth: 2
                Layout.preferredHeight: 32
                color: "transparent"
                rotation: 180

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: parent.height - 2
                    color: grid.borderColor
                }

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    spacing: 0

                    Rectangle {
                        Layout.preferredHeight: 1
                        Layout.preferredWidth: 1
                        color: grid.borderColor
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        width: 1
                        color: navBarRight.isActive ? grid.borderColor : "transparent"
                    }

                    Rectangle {
                        color: grid.borderColor
                        Layout.preferredHeight: 1
                        Layout.preferredWidth: 1
                    }
                }
            }

            Rectangle {
                color: "transparent"
                Layout.fillWidth: true
            }
        }
    }
}
