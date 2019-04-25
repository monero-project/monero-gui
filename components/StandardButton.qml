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
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

Item {
    id: button
    property string rightIcon: ""
    property string rightIconInactive: ""
    property string textColor: button.enabled? MoneroComponents.Style.buttonTextColor: MoneroComponents.Style.buttonTextColorDisabled
    property bool small: false
    property alias text: label.text
    property int fontSize: {
        if(small) return 14;
        else return 16;
    }
    property alias label: label
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
        border.width: parent.focus ? 1 : 0

        state: button.enabled ? "active" : "disabled"
        Component.onCompleted: state = state

        states: [
            State {
                name: "hover"
                when: buttonArea.containsMouse || button.focus
                PropertyChanges {
                    target: buttonRect
                    color: MoneroComponents.Style.buttonBackgroundColorHover
                }
            },
            State {
                name: "active"
                when: button.enabled
                PropertyChanges {
                    target: buttonRect
                    color: MoneroComponents.Style.buttonBackgroundColor
                }
            },
            State {
                name: "disabled"
                when: !button.enabled
                PropertyChanges {
                    target: buttonRect
                    color: MoneroComponents.Style.buttonBackgroundColorDisabled
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
            font.bold: true
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
            visible: button.rightIcon !== ""
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            width: button.small ? 16 : 20
            height: button.small ? 16 : 20
            source: {
                if(button.rightIconInactive !== "" && !button.enabled) {
                    return button.rightIconInactive;
                }
                return button.rightIcon;
            }
        }
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: doClick()
        cursorShape: Qt.PointingHandCursor
    }

    Keys.onSpacePressed: doClick()
    Keys.onReturnPressed: doClick()
}
