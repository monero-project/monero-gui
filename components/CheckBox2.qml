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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import "." 1.0

RowLayout {
    id: checkBox
    property alias text: label.text
    property string checkedIcon: "../images/checkedIcon-black.png"
    property string uncheckedIcon
    property bool checked: false
    property string background: "backgroundRect.color"
    property int fontSize: 14 * scaleRatio
    property alias fontColor: label.color
    property int textMargin: 8 * scaleRatio
    property bool darkDropIndicator: false
    signal clicked()
    height: 25 * scaleRatio

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
            anchors.left: parent.left

            Text {
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
                rotation: checkBox.checked ? 180  * scaleRatio : 0

                Image {
                    id: indicatorImage
                    anchors.centerIn: parent
                    source: "../images/whiteDropIndicator.png"
                    visible: !darkDropIndicator
                }
                ColorOverlay {
                    anchors.fill: indicatorImage
                    source: indicatorImage
                    color: "#FF000000"
                    visible: darkDropIndicator
                }
            }

            MouseArea{
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
