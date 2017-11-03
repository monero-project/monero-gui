// Copyright (c) 2014-2015, The Monero Project
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

Rectangle {
    id: titleBar
    color: "#000000"
    property int mouseX: 0
    property bool containsMouse: false
    property alias basicButtonVisible: goToBasicVersionButton.visible
    property bool customDecorations: true
    signal goToBasicVersion(bool yes)
    height: customDecorations && !isMobile ? 30 : 0
    y: -height
    property string title
    property alias maximizeButtonVisible: maximizeButton.visible
    z: 1

    Text {
        anchors.centerIn: parent
        font.family: "Arial"
        font.pixelSize: 15
        color: "#FFFFFF"
        text: titleBar.title
        visible: customDecorations
    }

    Rectangle {

        id: goToBasicVersionButton
        property bool containsMouse: titleBar.mouseX >= x && titleBar.mouseX <= x + width
        property bool checked: false
        anchors.top: parent.top
        anchors.left: parent.left
        color:  "#FFE00A"
        height: 30 * scaleRatio
        width: height
        visible: isMobile

        Image {
            width: parent.width * 2/3;
            height: width;
            anchors.centerIn: parent
            source: "../images/menu.png"
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

        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width && titleBar.containsMouse
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: height
            color: containsMouse ? "#6B0072" : "#000000"

            Image {
                anchors.centerIn: parent
                source: "../images/helpIcon.png"
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
            width: height
            color: containsMouse ? "#3665B3" : "#000000"

            Image {
                anchors.centerIn: parent
                source: "../images/minimizeIcon.png"
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
            width: height
            color: containsMouse ? "#FF6C3C" : "#000000"

            Image {
                anchors.centerIn: parent
                source: appWindow.visibility === Window.FullScreen ?  "../images/backToWindowIcon.png" :
                                                                      "../images/maximizeIcon.png"

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
            width: height
            color: containsMouse ? "#E04343" : "#000000"

            Image {
                anchors.centerIn: parent
                source: "../images/closeIcon.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: appWindow.close();
            }
        }
    }

}
