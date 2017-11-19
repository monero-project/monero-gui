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
import "." 1.0

Item {
    id: item
    property alias placeholderText: placeholderLabel.text
    property alias text: input.text
    property alias validator: input.validator
    property alias readOnly : input.readOnly
    property alias cursorPosition: input.cursorPosition
    property alias echoMode: input.echoMode
    property int fontSize: 18 * scaleRatio
    property bool showBorder: true
    property bool error: false
    signal editingFinished()
    signal accepted();
    signal textUpdated();

    height: 48 * scaleRatio

    onTextUpdated: {
        // check to remove placeholder text when there is content
        if(item.isEmpty()){
            placeholderLabel.visible = true
        } else {
            placeholderLabel.visible = false
        }
    }

    function isEmpty(){
        var val = input.text;
        if(val === "") {
            return true;
        }
        else {
            return false;
        }
    }

    function getColor(error) {
        // @TODO: replace/remove this (implement as ternary?)
        if (error)
            return Style.inputBoxBackground
        else
            return Style.inputBoxBackground
    }

    Text {
        id: placeholderLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        opacity: 0.25
        font.family: Style.fontRegular.name
        font.pixelSize: 20 * scaleRatio
        color: "#FFFFFF"
        text: ""
        visible: item.setPlaceholder() ? false : true
        z: 3
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 1 * scaleRatio
        color: getColor(error)
        //radius: 4
    }

    Input {
        id: input
        anchors.fill: parent
        font.pixelSize: parent.fontSize
        onEditingFinished: item.editingFinished()
        onAccepted: item.accepted();
        onTextChanged: item.textUpdated()
    }
}
