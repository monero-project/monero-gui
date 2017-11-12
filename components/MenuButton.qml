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
import QtGraphicalEffects 1.0

Rectangle {
    id: button
    property alias text: label.text
    property bool checked: false
    property alias dotColor: dot.color
    property alias symbol: symbolText.text
    property int numSelectedChildren: 0
    property var under: null
    signal clicked()

    function doClick() {
        // Android workaround
        releaseFocus();
        clicked();
    }


    function getOffset() {
        var offset = 0
        var item = button
        while (item.under) {
            offset += 20 * scaleRatio
            item = item.under
        }
        return offset
    }

    color: "black"
    property bool present: !under || under.checked || checked || under.numSelectedChildren > 0
    height: present ? ((appWindow.height >= 800) ? 40 * scaleRatio  : 52 * scaleRatio ) : 0

    Item {
        visible: parent.checked ? true : false
        width: 300
        height: 40

        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(300, 0)
            gradient: Gradient {
               GradientStop { position: 1.0; color: "#333333" }
               GradientStop { position: 0.0; color: "black" }
            }
        }
    }

    transform: Scale {
        yScale: button.present ? 1 : 0

        Behavior on yScale {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    Behavior on height {
        SequentialAnimation {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    Behavior on checked {
        // we get the value of checked before the change
        ScriptAction { script: if (under) under.numSelectedChildren += checked > 0 ? -1 : 1 }
    }

    Item {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: parent.getOffset()
        width: 46 * scaleRatio

        Rectangle {
            id: dot
            anchors.centerIn: parent
            width: 8 * scaleRatio
            height: width
            radius: height / 2

            Rectangle {
                anchors.centerIn: parent
                width: 8 * scaleRatio
                height: width
                radius: height / 2
                color: "#1C1C1C"
                visible: !button.checked && !buttonArea.containsMouse
            }
        }

        Text {
            id: symbolText
            anchors.centerIn: parent
            font.pixelSize: 11 * scaleRatio
            font.bold: true
            color: button.checked || buttonArea.containsMouse ? "#FFFFFF" : dot.color
            visible: appWindow.ctrlPressed
        }
    }

//    Rectangle {
//        anchors.left: parent.left
//        anchors.top: parent.top
//        anchors.bottom: parent.bottom
//        width: 1
//        color: "#DBDBDB"
//        visible: parent.checked
//    }

    // menu button arrow
    Image {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20 * scaleRatio
        anchors.leftMargin: parent.getOffset()
        source: "../images/right.png"
    }

    // menu button text
    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: parent.getOffset() + 38 * scaleRatio
        font.family: "Arial"
        font.pixelSize: 16 * scaleRatio
        color: "#FFFFFF"
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if(parent.checked)
                return
            button.doClick()
            parent.checked = true
        }
    }
}
