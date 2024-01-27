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
import QtGraphicalEffects 1.0
import FontAwesome 1.0

import "." 1.0
import "." as MoneroComponents
import "effects/" as MoneroEffects

RowLayout {
    id: checkBox
    property alias text: label.text
    property bool checked: false
    property int fontSize: 14
    property alias fontColor: label.color
    property int textMargin: 8
    signal clicked()
    height: 25

    function toggle(){
        checkBox.checked = !checkBox.checked
        checkBox.clicked()
    }

    RowLayout {
        Layout.fillWidth: true

        Rectangle{
            height: label.height
            width: (label.width + indicatorRect.width + checkBox.textMargin)
            color: "transparent"

            MoneroComponents.TextPlain {
                id: label
                font.family: Style.fontLight.name
                font.pixelSize: checkBox.fontSize
                color: Style.defaultFontColor
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                anchors.left: parent.left
            }

            Rectangle {
                id: indicatorRect
                width: indicatorImage.width
                height: label.height
                anchors.left: label.right
                anchors.leftMargin: textMargin
                color: "transparent"
                rotation: checkBox.checked ? 180  : 0

                MoneroEffects.ImageMask {
                    id: indicatorImage
                    anchors.centerIn: parent
                    width: 12
                    height: 8
                    image: "qrc:///images/whiteDropIndicator.png"
                    color: MoneroComponents.Style.defaultFontColor
                    opacity: MoneroComponents.Style.blackTheme ? 1 : 0.75
                    fontAwesomeFallbackIcon: FontAwesome.arrowDown
                    fontAwesomeFallbackSize: 14

                    MoneroEffects.ColorTransition {
                        targetObj: indicatorImage
                        blackColor: "white"
                        whiteColor: "black"
                        duration: 500
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    toggle();
                }
            }
        }
    }
}
