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

Item {
    id: button
    height: 37 * scaleRatio
    property string shadowPressedColor: "#B32D00"
    property string shadowReleasedColor: "#FF4304"
    property string pressedColor: "#FF4304"
    property string releasedColor: "#FF6C3C"
    property string icon: ""
    property string textColor: "#FFFFFF"
    property int fontSize: 12 * scaleRatio
    property alias text: label.text
    signal clicked()

    // Dynamic label width
    Layout.minimumWidth: (label.contentWidth > 50)? label.contentWidth + 10 : 60

    function doClick() {
        // Android workaround
        releaseFocus();
        clicked();
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height - 1
        y: buttonArea.pressed ? 0 : 1
        //radius: 4
        color: {
            parent.enabled ? (buttonArea.pressed ? parent.shadowPressedColor : parent.shadowReleasedColor)
                           : Qt.lighter(parent.shadowReleasedColor)
        }
        border.color: Qt.darker(parent.releasedColor)
        border.width: parent.focus ? 1 : 0

    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height - 1
        y: buttonArea.pressed ? 1 : 0
        color: {
            parent.enabled ? (buttonArea.pressed ? parent.pressedColor : parent.releasedColor)
                           : Qt.lighter(parent.releasedColor)

        }
        //radius: 4


    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        font.family: "Arial"
        font.bold: true
        font.pixelSize: button.fontSize
        color: parent.textColor
        visible: parent.icon === ""
//        font.capitalization : Font.Capitalize
    }

    Image {
        anchors.centerIn: parent
        visible: parent.icon !== ""
        source: parent.icon
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        onClicked: doClick()
    }

    Keys.onSpacePressed: doClick()
    Keys.onReturnPressed: doClick()
}
