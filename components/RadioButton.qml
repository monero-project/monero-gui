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
import QtQuick.Controls 2.15

import "../components" as MoneroComponents

RadioButton {
    id: control
    checked: false
    property var tooltip: ""
    property bool tooltipIconVisible: true
    property alias fontSize: control.font.pixelSize

    font.pixelSize: 16
    font.family: MoneroComponents.Style.fontRegular.name

    indicator: Rectangle {
        color: "transparent"
        border.color: checked ? (MoneroComponents.Style.blackTheme ? "white" : "#666666") : MoneroComponents.Style.inputBorderColorInActive
        height: 22
        width: 22
        radius: 22

        Rectangle {
            visible: control.checked
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: MoneroComponents.Style.blackTheme ? "white" : "#666666"
            width: 10
            height: 10
            radius: 10
        }
    }

    contentItem: Text {
        id: textContent
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: MoneroComponents.Style.defaultFontColor
        anchors.bottom: indicator.bottom
        anchors.bottomMargin: 1
        leftPadding: control.indicator.width + (control.spacing / 2)

        MoneroComponents.Tooltip {
            id: tooltip
            anchors.top: parent.top
            anchors.left: parent.right
            tooltipIconVisible: true
            text: control.tooltip
        }
    }
}
