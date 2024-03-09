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
import QtQuick.Layouts 1.1

import FontAwesome 1.0

import "../components" as MoneroComponents

Item {
    id: button
    property bool fontAwesomeIcon: false
    property bool primary: true
    property string rightIcon: ""
    property string rightIconInactive: ""
    property color textColor: primary ? MoneroComponents.Style.buttonTextColor : MoneroComponents.Style.buttonSecondaryTextColor;
    property bool small: false
    property alias text: label.text
    property alias fontBold: label.font.bold
    property int fontSize: {
        if(small) return 13.5;
        else return 16;
    }
    property alias label: label
    property alias tooltip: tooltip.text
    property alias tooltipLeft: tooltip.tooltipLeft
    property alias tooltipPopup: tooltip.tooltipPopup
    signal clicked()

    height: small ?  30 : 36
    width: buttonLayout.width + 22
    implicitHeight: height
    implicitWidth: width

    function doClick(){
        releaseFocus();
        clicked();
    }

    Rectangle {
        id: buttonRect
        anchors.fill: parent
        radius: 3
        border.width: parent.focus && parent.enabled ? 1 : 0
        opacity: 1

        state: button.enabled ? "active" : "disabled"
        Component.onCompleted: state = state

        states: [
            State {
                name: "hover"
                when: button.enabled && (buttonArea.containsMouse || button.focus)
                PropertyChanges {
                    target: buttonRect
                    color: primary
                        ? MoneroComponents.Style.buttonBackgroundColorHover
                        : MoneroComponents.Style.buttonSecondaryBackgroundColorHover
                }
            },
            State {
                name: "active"
                when: button.enabled
                PropertyChanges {
                    target: buttonRect
                    color: primary
                        ? MoneroComponents.Style.buttonBackgroundColor
                        : MoneroComponents.Style.buttonSecondaryBackgroundColor
                }
            },
            State {
                name: "disabled"
                when: !button.enabled
                PropertyChanges {
                    target: buttonRect
                    opacity: 0.5
                    color: primary
                        ? MoneroComponents.Style.buttonBackgroundColor
                        : MoneroComponents.Style.buttonSecondaryBackgroundColor
                }
                PropertyChanges {
                    target: label
                    opacity: 0.5
                }
            }
        ]

        transitions: Transition {
            enabled: appWindow.themeTransition
            ColorAnimation { duration: 100 }
        }
    }

    RowLayout {
        id: buttonLayout
        height: button.height
        spacing: 11
        anchors.centerIn: parent

        MoneroComponents.TextPlain {
            id: label
            font.family: MoneroComponents.Style.fontBold.name
            font.bold: button.primary ? true : false
            font.pixelSize: button.fontSize
            color: !buttonArea.pressed ? button.textColor : "transparent"
            visible: text !== ""
            themeTransition: false

            MoneroComponents.TextPlain {
                anchors.centerIn: parent
                color: button.textColor
                font.bold: label.font.bold
                font.family: label.font.family
                font.pixelSize: label.font.pixelSize - 1
                text: label.text
                opacity: buttonArea.pressed ? 1 : 0
                themeTransition: false
            }
        }

        Image {
            visible: !fontAwesomeIcon && button.rightIcon !== ""
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            width: button.small ? 16 : 20
            height: button.small ? 16 : 20
            opacity: buttonRect.opacity
            source: {
                if (fontAwesomeIcon) return "";
                if(button.rightIconInactive !== "" && !button.enabled) {
                    return button.rightIconInactive;
                }
                return button.rightIcon;
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            color: MoneroComponents.Style.defaultFontColor
            font.family: FontAwesome.fontFamilySolid
            font.pixelSize: button.small ? 16 : 20
            font.styleName: "Solid"
            text: button.rightIcon
            visible: fontAwesomeIcon && button.rightIcon !== ""
        }
    }

    MoneroComponents.Tooltip {
        id: tooltip
        anchors.fill: parent
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: doClick()
        onEntered: tooltip.text ? tooltip.tooltipPopup.open() : ""
        onExited: tooltip.text ? tooltip.tooltipPopup.close() : ""
        cursorShape: Qt.PointingHandCursor
    }

    Keys.enabled: button.visible
    Keys.onSpacePressed: doClick()
    Keys.onEnterPressed: Keys.onReturnPressed(event)
    Keys.onReturnPressed: doClick()
}
