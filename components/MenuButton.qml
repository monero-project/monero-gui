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
import QtGraphicalEffects 1.0

import "../components" as MoneroComponents
import "effects/" as MoneroEffects

Rectangle {
    id: button
    property alias text: label.text
    property bool checked: false
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
            offset += 20
            item = item.under
        }
        return offset
    }

    color: "transparent"
    property bool present: !under || under.checked || checked || under.numSelectedChildren > 0
    height: present ? ((appWindow.height >= 800) ? 44  : 38 ) : 0

    LinearGradient {
        visible: isOpenGL && (button.checked || buttonArea.containsMouse)
        height: parent.height
        width: 260
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: -20
        anchors.leftMargin: parent.getOffset()
        start: Qt.point(width, 0)
        end: Qt.point(0, 0)
        gradient: Gradient {
            GradientStop { position: 0.0; color: MoneroComponents.Style.menuButtonGradientStart }
            GradientStop { position: 1.0; color: MoneroComponents.Style.menuButtonGradientStop }
        }
        opacity: button.checked ? 1 : 0.3
    }

    // fallback hover effect when opengl is not available
    Rectangle {
        visible: !isOpenGL && (button.checked || buttonArea.containsMouse)
        anchors.fill: parent
        color: MoneroComponents.Style.menuButtonFallbackBackgroundColor
        opacity: button.checked ? 1 : 0.3
    }

    // button decorations that are subject to leftMargin offsets
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 20
        height: parent.height
        width: 2
        color: button.checked ? MoneroComponents.Style.accountColors[currentAccountIndex % MoneroComponents.Style.accountColors.length] : "transparent"

        // button text
        MoneroComponents.TextPlain {
            id: label
            color: MoneroComponents.Style.menuButtonTextColor
            themeTransitionBlackColor: MoneroComponents.Style._b_menuButtonTextColor
            themeTransitionWhiteColor: MoneroComponents.Style._w_menuButtonTextColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.right
            anchors.leftMargin: button.getOffset() + 8
            font.bold: true
            font.pixelSize: 14
        }
    }

    // menu button right arrow
    MoneroEffects.ImageMask {
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: parent.getOffset()
        anchors.right: parent.right
        anchors.rightMargin: 20
        height: 14
        width: 8
        image: MoneroComponents.Style.menuButtonImageRightSource
        color: button.checked ? MoneroComponents.Style.menuButtonImageRightColorActive : MoneroComponents.Style.menuButtonImageRightColor
        opacity: button.checked ? 0.8 : 0.25
    }

    MoneroComponents.TextPlain {
        id: symbolText
        anchors.right: parent.right
        anchors.rightMargin: 44
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 12
        font.bold: true
        color: MoneroComponents.Style.menuButtonTextColor
        visible: appWindow.ctrlPressed
        themeTransition: false
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if(parent.checked)
                return
            button.doClick()
            parent.checked = true
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
}
