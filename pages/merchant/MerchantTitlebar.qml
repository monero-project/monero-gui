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
import "../../components/" as MoneroComponents
import "../../components/effects/" as MoneroEffects

Rectangle {
    id: root
    property int mouseX: 0
    property bool customDecorations: persistentSettings.customDecorations
    property bool showMinimizeButton: true
    property bool showMaximizeButton: true
    property bool showCloseButton: true

    height: {
        if(!persistentSettings.customDecorations) return 0;
        return 50;
    }

    z: 1
    color: "transparent"

    signal closeClicked
    signal maximizeClicked
    signal minimizeClicked

    Rectangle {
        width: parent.width
        height: parent.height
        z: parent.z + 1
        color: "#ff6600"
    }

    RowLayout {
        z: parent.z + 2
        spacing: 0
        anchors.fill: parent

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.height * 3
        }

        // monero logo
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height

            Image {
                id: imgLogo
                width: 132
                height: 22

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:///images/moneroLogo_white.png"
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
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = "#44FFFFFF"
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
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = "#44FFFFFF"
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
                    parent.color = "#44FFFFFF"
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

    MouseArea {
        enabled: persistentSettings.customDecorations
        property var previousPosition
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: previousPosition = globalCursor.getPosition()
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
