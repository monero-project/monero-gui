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
            property string fontColor: "white"
            property int fontSize: 13 * scaleRatio
            property bool fontBold: true
            property var fontFamily: MoneroComponents.Style.fontRegular.name
            property string borderColor: "#808080"
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
            Image {
                Layout.preferredWidth: 2
                Layout.preferredHeight: 32
                source: {
                    if(settingsStateView.state === "Wallet"){
                        return "../../images/settings_navbar_side_active.png"
                    } else {
                        return "../../images/settings_navbar_side.png"
                    }
                }
            }
            ColumnLayout {
                // WALLET
                id: navWallet
                Layout.preferredWidth: navWalletText.width + grid.textMargin
                Layout.minimumWidth: 72 * scaleRatio
                Layout.preferredHeight: 32
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: settingsStateView.state === "Wallet" ? grid.borderColor : "transparent"
                    height: 30 * scaleRatio
                    Layout.fillWidth: true

                    Text {
                        id: navWalletText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Wallet") + translationManager.emptyString
                        color: grid.fontColor
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
                Layout.preferredWidth: navUIText.width + grid.textMargin
                Layout.preferredHeight: 32
                Layout.minimumWidth: 72 * scaleRatio
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: settingsStateView.state === "UI" ? grid.borderColor : "transparent"
                    height: 30 * scaleRatio
                    Layout.fillWidth: true

                    Text {
                        id: navUIText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Layout") + translationManager.emptyString
                        color: grid.fontColor
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
                visible: appWindow.walletMode >= 2
                Layout.preferredWidth: navNodeText.width + grid.textMargin
                Layout.preferredHeight: 32
                Layout.minimumWidth: 72 * scaleRatio
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: settingsStateView.state === "Node" ? grid.borderColor : "transparent"
                    height: 30 * scaleRatio
                    Layout.fillWidth: true

                    Text {
                        id: navNodeText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Node") + translationManager.emptyString
                        color: grid.fontColor
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
                visible: appWindow.walletMode >= 2
                Layout.preferredWidth: navLogText.width + grid.textMargin
                Layout.preferredHeight: 32
                Layout.minimumWidth: 72 * scaleRatio
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: settingsStateView.state === "Log" ? grid.borderColor : "transparent"
                    height: 30 * scaleRatio
                    Layout.fillWidth: true

                    Text {
                        id: navLogText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Log") + translationManager.emptyString
                        color: grid.fontColor
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
                Layout.preferredWidth: navInfoText.width + grid.textMargin
                Layout.preferredHeight: 32
                Layout.minimumWidth: 72 * scaleRatio
                spacing: 0

                Rectangle { 
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: settingsStateView.state === "Info" ? grid.borderColor : "transparent"
                    height: 30 * scaleRatio
                    Layout.fillWidth: true

                    Text {
                        id: navInfoText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: grid.fontFamily
                        font.pixelSize: grid.fontSize
                        font.bold: grid.fontBold
                        text: qsTr("Info") + translationManager.emptyString
                        color: grid.fontColor
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
            Image {
                Layout.preferredWidth: 2
                Layout.preferredHeight: 32
                source: {
                    if(settingsStateView.state === "Info"){
                        return "../../images/settings_navbar_side_active.png"
                    } else {
                        return "../../images/settings_navbar_side.png"
                    }    
                    
                }
                rotation: 180
            }
            Rectangle {
                color: "transparent"
                Layout.fillWidth: true
            }
        }
    }
}
