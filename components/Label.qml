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
    id: item
    property alias text: label.text
    property alias color: label.color
    property int textFormat: Text.PlainText
    property string tipText: ""
    property int fontSize: 16
    property bool fontBold: false
    property string fontColor: MoneroComponents.Style.defaultFontColor
    property string fontFamily: ""
    property alias wrapMode: label.wrapMode
    property alias horizontalAlignment: label.horizontalAlignment
    property alias elide: label.elide
    property alias textWidth: label.width
    property alias themeTransition: label.themeTransition
    signal linkActivated()
    height: label.height
    width: label.width
    Layout.topMargin: 10

    MoneroComponents.TextPlain {
        id: label
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.left: parent.left
        font.family: {
            if(fontFamily){
                return fontFamily;
            } else {
                return MoneroComponents.Style.fontRegular.name;
            }
        }
        font.pixelSize: fontSize
        font.bold: fontBold
        color: fontColor
        onLinkActivated: item.linkActivated()
        textFormat: parent.textFormat
    }
}
