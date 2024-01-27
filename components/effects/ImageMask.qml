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

import "../" as MoneroComponents
import FontAwesome 1.0

Item {
    // Use this component to color+opacity change images with transparency (svg/png)
    // Does not work in low graphics mode, use fontAwesome fallback option.

    id: root
    property string image: ""
    property string color: ""
    property var fontAwesomeFallbackIcon: ""
    property string fontAwesomeFallbackFont: FontAwesome.fontFamilySolid
    property string fontAwesomeFallbackStyle: "Solid"
    property int fontAwesomeFallbackSize: 16
    property double fontAwesomeFallbackOpacity: 0.8
    property string fontAwesomeFallbackColor: MoneroComponents.Style.defaultFontColor

    property alias fontAwesomeFallback: fontAwesomeFallback
    property alias svgMask: svgMask
    property alias imgMockColor: imgMockColor

    width: 0
    height: 0

    Image {
        id: svgMask
        source: root.image
        sourceSize.width: root.width
        sourceSize.height: root.height
        smooth: true
        mipmap: true
        visible: false
    }

    ColorOverlay {
        id: imgMockColor
        anchors.fill: root
        source: svgMask
        color: root.color
        visible: image && isOpenGL
    }

    Text {
        id: fontAwesomeFallback
        visible: !imgMockColor.visible
        text: root.fontAwesomeFallbackIcon
        font.family: root.fontAwesomeFallbackFont
        font.pixelSize: root.fontAwesomeFallbackSize
        font.styleName: root.fontAwesomeFallbackStyle
        color: root.fontAwesomeFallbackColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: root.fontAwesomeFallbackOpacity
    }
}
