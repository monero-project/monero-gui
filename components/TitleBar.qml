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

import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

Rectangle {
    id: titleBar

    property int mouseX: 0
    property bool containsMouse: false
    property alias basicButtonVisible: goToBasicVersionButton.visible
    property bool customDecorations: true
    signal goToBasicVersion(bool yes)
    height: customDecorations && !isMobile ? 50 : 0
    y: -height
    property string title
    property alias maximizeButtonVisible: maximizeButton.visible
    z: 1

    Item {
        id: test
        width: parent.width
        height: 50
        z: 1

        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, 0)
            gradient: Gradient {
               GradientStop { position: 1.0; color: "#1a1a1a" }
               GradientStop { position: 0.0; color: "black" }
            }
        }
    }

    Item{
        id: titlebarlogo
        width: 128
        height: 50
        anchors.centerIn: parent
        visible: customDecorations
        z: 1

        Image {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 11
            width: 86
            height: 26
            fillMode: Image.PreserveAspectFit
            source: "../images/moneroLogo_white.png"
        }

        Image {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 11
            width: 28
            height: 28
            source: "../images/moneroIcon-trans28x28.png"
        }
    }

    // collapse left panel
    Rectangle {
        id: goToBasicVersionButton
        property bool containsMouse: titleBar.mouseX >= x && titleBar.mouseX <= x + width
        property bool checked: false
        anchors.top: parent.top
        anchors.left: parent.left
        color:  "black"
        height: 50 * scaleRatio
        width: height
        visible: isMobile
        z: 2

        Image {
            width: 14
            height: 14
            anchors.centerIn: parent
            source: "../images/expand.png"
        }

        MouseArea {
            id: basicMouseArea
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                releaseFocus()
                parent.checked = !parent.checked
                titleBar.goToBasicVersion(leftPanel.visible)
            }
        }
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: parent.customDecorations
        z: 2

        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width && titleBar.containsMouse
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 42
            color: containsMouse ? "#6B0072" : "#00000000"

            Image {
                anchors.centerIn: parent
                width: 9
                height: 16
                source: "../images/question.png"
            }

            MouseArea {
                id: whatIsArea
                anchors.fill: parent
                onClicked: {

                }
            }
        }

        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width && titleBar.containsMouse
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 42
            color: containsMouse ? "#3665B3" : "#00000000"

            Image {
                anchors.centerIn: parent
                source: "../images/minimize.png"
            }

            MouseArea {
                id: minimizeArea
                anchors.fill: parent
                onClicked: {
                    appWindow.visibility = Window.Minimized
                }
            }
        }

        Rectangle {
            id: maximizeButton
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width && titleBar.containsMouse
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 42
            color: containsMouse ? "#FF6C3C" : "#00000000"

            Image {
                anchors.centerIn: parent
                height: 16
                width: 16
                source: appWindow.visibility === Window.FullScreen ?  "../images/backToWindowIcon.png" :
                                                                      "../images/fullscreen.png"

            }

            MouseArea {
                id: maximizeArea
                anchors.fill: parent
                onClicked: {
                    appWindow.visibility = appWindow.visibility !== Window.FullScreen ? Window.FullScreen :
                                                                                        Window.Windowed
                }
            }
        }

        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width && titleBar.containsMouse
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 42
            color: containsMouse ? "#E04343" : "#00000000"

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: "../images/close.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: appWindow.close();
            }
        }
    }

}
