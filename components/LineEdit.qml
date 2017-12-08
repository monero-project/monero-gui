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
    property alias text: input.text
    property alias placeholderText: placeholderLabel.text
    property alias validator: input.validator
    property alias readOnly : input.readOnly
    property alias cursorPosition: input.cursorPosition
    property alias echoMode: input.echoMode
    property alias inlineButton: inlineButtonId
    property alias inlineButtonText: inlineButtonId.text
    property alias inlineIcon: inlineIcon.visible
    property bool copyButton: false
    property int fontSize: 18 * scaleRatio
    property bool showBorder: true
    property bool fontBold: true
    property bool error: false
    property alias labelText: inputLabel.text
    property alias labelColor: inputLabel.color
    property alias labelTextFormat: inputLabel.textFormat
    property string tipText: ""
    property int labelFontSize: 16 * scaleRatio
    property bool labelFontBold: false
    property alias labelWrapMode: inputLabel.wrapMode
    property alias labelHorizontalAlignment: inputLabel.horizontalAlignment
    signal labelLinkActivated(); // input label, rich text <a> signal
    signal editingFinished();
    signal accepted();
    signal textUpdated();

    height: (inputLabel.height + inputItem.height + 2) * scaleRatio

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

    Text {
        id: inputLabel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 2 * scaleRatio
        font.family: Style.fontRegular.name
        font.pixelSize: labelFontSize
        font.bold: labelFontBold
        textFormat: Text.RichText
        color: Style.defaultFontColor
        onLinkActivated: item.labelLinkActivated()

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    LabelButton {
        id: copyButtonId
        text: qsTr("Copy")
        anchors.right: parent.right
        onClicked: {
            if (input.text.length > 0) {
                console.log(input.text + " copied to clipboard")
                clipboard.setText(input.text)
                appWindow.showStatusMessage(qsTr("Copied to clipboard"),3)
            }
        }
        visible: input.text && copyButton ? true : false
    }

    Item{
        id: inputItem
        height: 40 * scaleRatio
        anchors.top: inputLabel.bottom
        anchors.topMargin: 6 * scaleRatio
        width: parent.width

        Text {
            id: placeholderLabel
            visible: input.text ? false : true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: inlineIcon.visible ? 50 * scaleRatio : 10 * scaleRatio
            opacity: 0.25
            color: Style.defaultFontColor
            font.family: Style.fontRegular.name
            font.pixelSize: 18 * scaleRatio
            text: ""
            z: 3
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1 * scaleRatio
            color: "transparent"
        }

        Rectangle {
            color: "transparent"
            border.width: 1
            border.color: {
                if(input.activeFocus){
                    return Qt.rgba(255, 255, 255, 0.35);
                } else {
                    return Qt.rgba(255, 255, 255, 0.25);
                }
            }
            radius: 4
            anchors.fill: parent
        }

        Image {
            id: inlineIcon
            width: 26 * scaleRatio
            height: 26 * scaleRatio
            anchors.top: parent.top
            anchors.topMargin: 8 * scaleRatio
            anchors.left: parent.left
            anchors.leftMargin: 12 * scaleRatio
            source: "../images/moneroIcon-28x28.png"
            visible: false
        }

        Input {
            id: input
            anchors.fill: parent
            anchors.leftMargin: inlineIcon.visible ? 38 : 0
            font.pixelSize: item.fontSize
            font.bold: fontBold
            onEditingFinished: item.editingFinished()
            onAccepted: item.accepted();
            onTextChanged: item.textUpdated()
        }

        InlineButton {
            id: inlineButtonId
            visible: item.inlineButtonText ? true : false
            anchors.right: parent.right
            anchors.rightMargin: 8 * scaleRatio
            anchors.top: parent.top
            anchors.topMargin: 6 * scaleRatio
        }
    }
}
