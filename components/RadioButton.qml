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
    id: radioButton
    property alias text: label.text
    property bool checked: false
    property int fontSize: 14
    property alias fontColor: label.color
    signal clicked()
    height: 26
    width: layout.width
    // legacy properties
    property var checkedColor: MoneroComponents.Style.blackTheme ? "white" : "#666666"
    property var borderColor: checked ? MoneroComponents.Style.inputBorderColorActive : MoneroComponents.Style.inputBorderColorInActive

    function toggle(){
        radioButton.checked = !radioButton.checked
        radioButton.clicked()
    }

    RowLayout {
        id: layout

        Rectangle {
            id: button
            color: "transparent"
            border.color: borderColor
            height: radioButton.height
            width: radioButton.height
            radius: radioButton.height

            Rectangle {
                visible: radioButton.checked
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: checkedColor
                width: 10
                height: 10
                radius: 10
                opacity: 0.8
            }
        }

        MoneroComponents.TextPlain {
            id: label
            Layout.leftMargin: 10
            color: MoneroComponents.Style.defaultFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: radioButton.fontSize
            wrapMode: Text.Wrap
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggle()
        }
    }
}
