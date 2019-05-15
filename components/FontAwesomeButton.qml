// Copyright (c) 2014-2019, The Monero Project
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
import FontAwesome 1.0

import "../components" as MoneroComponents

Item {
    id: item
    property alias text: label.text
    property alias color: label.color
    property int textFormat: Text.PlainText
    property int fontSize: 20
    property bool fontBold: false
    property string fontColor: MoneroComponents.Style.defaultFontColor
    property string fontFamily: FontAwesome.fontFamily
    property alias wrapMode: label.wrapMode
    property alias horizontalAlignment: label.horizontalAlignment
    property alias elide: label.elide
    property alias textWidth: label.width
    property alias themeTransition: label.themeTransition
    height: label.height
    width: label.width
    opacity: 0.7

    signal clicked()

    MoneroComponents.TextPlain {
        id: label
        font.family: fontFamily
        font.pixelSize: fontSize
        font.bold: fontBold
        color: fontColor
        textFormat: parent.textFormat
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {
            parent.opacity = 0.9
            parent.fontSize = 22
        }
        onExited: {
            parent.opacity = 0.7
            parent.fontSize = 20
        }
        onClicked: item.clicked()
    }
}
