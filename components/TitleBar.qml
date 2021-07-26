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
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.2

import FontAwesome 1.0
import "." as MoneroComponents
import "effects/" as MoneroEffects

Rectangle {
    id: root
    property int mouseX: 0
    property bool customDecorations: persistentSettings.customDecorations
    property bool showMinimizeButton: true
    property bool showMaximizeButton: true
    property bool showCloseButton: true
    property string walletName: ""

    height: {
        if(!persistentSettings.customDecorations) return 0;
        return 50;
    }

    z: 1
    color: "transparent"

    signal closeClicked
    signal maximizeClicked
    signal minimizeClicked
    signal languageClicked
    signal closeWalletClicked

    state: "default"
    states: [
        State {
            name: "default";
            PropertyChanges { target: btnCloseWallet; visible: true}
            PropertyChanges { target: btnLanguageToggle; visible: true}
        }, State {
            // show only theme switcher and window controls
            name: "essentials";
            PropertyChanges { target: btnCloseWallet; visible: false}
            PropertyChanges { target: btnLanguageToggle; visible: false}
        }
    ]

    MoneroEffects.GradientBackground {
        anchors.fill: parent
        duration: 300
        fallBackColor: MoneroComponents.Style.middlePanelBackgroundColor
        initialStartColor: MoneroComponents.Style.titleBarBackgroundGradientStart
        initialStopColor: MoneroComponents.Style.titleBarBackgroundGradientStop
        blackColorStart: MoneroComponents.Style._b_titleBarBackgroundGradientStart
        blackColorStop: MoneroComponents.Style._b_titleBarBackgroundGradientStop
        whiteColorStart: MoneroComponents.Style._w_titleBarBackgroundGradientStart
        whiteColorStop: MoneroComponents.Style._w_titleBarBackgroundGradientStop
        start: Qt.point(width, 0)
        end: Qt.point(0, 0)
    }

    RowLayout {
        z: parent.z + 2
        spacing: 0
        anchors.fill: parent

        // collapse sidebar
        Rectangle {
            id: btnCloseWallet
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height


            Text {
                text: FontAwesome.signOutAlt
                font.family: FontAwesome.fontFamilySolid
                font.pixelSize: 16
                color: MoneroComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            MoneroComponents.Tooltip {
                id: btnCloseWalletTooltip
                anchors.fill: parent
                text: qsTr("Close this wallet and return to main menu") + translationManager.emptyString
            }

            MouseArea {
                anchors.fill: parent
                visible: middlePanel.state !== "Merchant" && !informationPopup.visible && !confirmationDialog.visible
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = MoneroComponents.Style.titleBarButtonHoverColor
                    btnCloseWalletTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnCloseWalletTooltip.tooltipPopup.close()
                }
                onClicked: root.closeWalletClicked(leftPanel.visible)
            }
        }

        // language selection
        Rectangle {
            id: btnLanguageToggle
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: FontAwesome.globe
                font.family: FontAwesome.fontFamilySolid
                font.pixelSize: 16
                color: MoneroComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            MoneroComponents.Tooltip {
                id: btnLanguageToggleTooltip
                anchors.fill: parent
                text: qsTr("Change language") + translationManager.emptyString
            }

            MouseArea {
                anchors.fill: parent
                visible: middlePanel.state !== "Merchant" && !informationPopup.visible && !confirmationDialog.visible
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = MoneroComponents.Style.titleBarButtonHoverColor
                    btnLanguageToggleTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnLanguageToggleTooltip.tooltipPopup.close()
                }
                onClicked: root.languageClicked()
            }
        }

        // switch theme
        Rectangle {
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: FontAwesome.moonO
                font.family: MoneroComponents.Style.blackTheme ? FontAwesome.fontFamilySolid : FontAwesome.fontFamily
                font.styleName: MoneroComponents.Style.blackTheme ? "Solid" : "Regular"
                font.pixelSize: 15
                color: MoneroComponents.Style.defaultFontColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            MoneroComponents.Tooltip {
                id: btnSwitchThemeTooltip
                anchors.fill: parent
                text: MoneroComponents.Style.blackTheme ? qsTr("Switch to light theme") : qsTr("Switch to dark theme") + translationManager.emptyString
            }

            MouseArea {
                anchors.fill: parent
                visible: middlePanel.state !== "Merchant" && !informationPopup.visible && !confirmationDialog.visible
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = MoneroComponents.Style.titleBarButtonHoverColor
                    btnSwitchThemeTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnSwitchThemeTooltip.tooltipPopup.close()
                }
                onClicked: {
                    MoneroComponents.Style.blackTheme = !MoneroComponents.Style.blackTheme;
                }
            }
        }

        Item {
            // make dummy space when hiding buttons when titlebar
            // state is 'essentials' in order for the
            // monero logo to still be centered
            Layout.preferredWidth: parent.height * 2  // amount of buttons we hide
            Layout.preferredHeight: parent.height
            visible: root.state == "essentials"
        }

        // monero logo
        Item {
            visible: walletName.length === 0
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height

            Image {
                id: imgLogo
                width: 125
                height: 28

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                source: MoneroComponents.Style.titleBarLogoSource
                visible: {
                    if(!isOpenGL) return true;
                    if(!MoneroComponents.Style.blackTheme) return true;
                    return false;
                }
            }

            Colorize {
                visible: isOpenGL && MoneroComponents.Style.blackTheme
                anchors.fill: imgLogo
                source: imgLogo
                saturation: 0.0
            }
        }

        Item {
            visible: walletName.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height

            MoneroComponents.TextPlain {
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width
                height: parent.height
                elide: Text.ElideRight
                text: walletName
            }
        }

        // minimize
        Rectangle {
            color: "transparent"
            visible: root.showMinimizeButton
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: FontAwesome.windowMinimize
                font.family:FontAwesome.fontFamilySolid
                font.pixelSize: 16
                color: MoneroComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            MoneroComponents.Tooltip {
                id: btnMinimizeWindowTooltip
                anchors.fill: parent
                text: qsTr("Minimize") + translationManager.emptyString
            }

            MouseArea {
                anchors.fill: parent
                visible: !informationPopup.visible && !confirmationDialog.visible
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = MoneroComponents.Style.titleBarButtonHoverColor
                    btnMinimizeWindowTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnMinimizeWindowTooltip.tooltipPopup.close()
                }
                onClicked: root.minimizeClicked();
            }
        }

        // maximize
        Rectangle {
            id: test
            visible: root.showMaximizeButton
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: appWindow.visibility == Window.Maximized ? FontAwesome.windowRestore : FontAwesome.windowMaximize
                font.family:FontAwesome.fontFamilySolid
                font.pixelSize: 16
                color: MoneroComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            MoneroComponents.Tooltip {
                id: btnMaximizeRestoreTooltip
                anchors.fill: parent
                text: appWindow.visibility == Window.Maximized ? qsTr("Restore") : qsTr("Maximize") + translationManager.emptyString
            }

            MouseArea {
                id: buttonArea
                anchors.fill: parent
                visible: !informationPopup.visible && !confirmationDialog.visible
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = MoneroComponents.Style.titleBarButtonHoverColor
                    btnMaximizeRestoreTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnMaximizeRestoreTooltip.tooltipPopup.close()
                }
                onClicked: root.maximizeClicked();
            }
        }

        // close
        Rectangle {
            visible: root.showCloseButton
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: FontAwesome.times
                font.family:FontAwesome.fontFamilySolid
                font.pixelSize: 19
                color: MoneroComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            MoneroComponents.Tooltip {
                id: btnCloseWindowTooltip
                anchors.fill: parent
                text: qsTr("Close Monero GUI") + translationManager.emptyString
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = MoneroComponents.Style.titleBarButtonHoverColor
                    btnCloseWindowTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnCloseWindowTooltip.tooltipPopup.close()
                }
                onClicked: root.closeClicked();
            }
        }
    }

    Rectangle {
        z: parent.z + 3
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: MoneroComponents.Style.blackTheme ? 1 : 1
        color: MoneroComponents.Style.titleBarBackgroundBorderColor

        MoneroEffects.ColorTransition {
            targetObj: parent
            blackColor: MoneroComponents.Style._b_titleBarBackgroundBorderColor
            whiteColor: MoneroComponents.Style._w_titleBarBackgroundBorderColor
        }
    }

    MouseArea {
        enabled: persistentSettings.customDecorations
        property var previousPosition
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: previousPosition = globalCursor.getPosition()
        onDoubleClicked: root.maximizeClicked()
        onPositionChanged: {
            if (pressedButtons == Qt.LeftButton) {
                var pos = globalCursor.getPosition()
                var dx = pos.x - previousPosition.x
                var dy = pos.y - previousPosition.y

                appWindow.x += dx
                appWindow.y += dy
                previousPosition = pos
            }
        }
    }
}
