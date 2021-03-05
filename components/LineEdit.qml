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

import FontAwesome 1.0
import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

Item {
    id: item

    default property alias content: inlineButtons.children

    property alias input: input
    property alias text: input.text

    property bool password: false
    property bool passwordHidden: true
    property var passwordLinked: null

    property alias placeholderText: placeholderLabel.text
    property bool placeholderCenter: false
    property string placeholderFontFamily: MoneroComponents.Style.fontRegular.name
    property bool placeholderFontBold: false
    property int placeholderFontSize: 18
    property string placeholderColor: MoneroComponents.Style.defaultFontColor
    property real placeholderOpacity: 0.35
    property real placeholderLeftMargin: {
        if (placeholderCenter) {
            return undefined;
        } else if (inlineIcon.visible) {
            return inlineIcon.width + inlineIcon.anchors.leftMargin + inputPadding;
        } else {
            return inputPadding;
        }
    }

    property alias acceptableInput: input.acceptableInput
    property alias validator: input.validator
    property alias readOnly : input.readOnly
    property alias cursorPosition: input.cursorPosition
    property alias inlineIcon: inlineIcon.visible
    property bool copyButton: false
    property alias copyButtonText: copyButtonId.text
    property alias copyButtonEnabled: copyButtonId.enabled

    property bool borderDisabled: false
    property string borderColor: {
        if(error && input.text !== ""){
            return MoneroComponents.Style.inputBorderColorInvalid;
        } else if(input.activeFocus){
            return MoneroComponents.Style.inputBorderColorActive;
        } else {
            return MoneroComponents.Style.inputBorderColorInActive;
        }
    }

    property string fontFamily: MoneroComponents.Style.fontRegular.name
    property int fontSize: 18
    property bool fontBold: false
    property alias fontColor: input.color
    property bool error: false
    property alias labelText: inputLabel.text
    property alias labelColor: inputLabel.color
    property alias labelTextFormat: inputLabel.textFormat
    property string backgroundColor: "transparent"
    property string tipText: ""
    property int labelFontSize: 16
    property bool labelFontBold: false
    property alias labelWrapMode: inputLabel.wrapMode
    property alias labelHorizontalAlignment: inputLabel.horizontalAlignment
    property bool showingHeader: inputLabel.text !== "" || copyButton
    property int inputHeight: 42
    property int inputPadding: 10

    signal labelLinkActivated(); // input label, rich text <a> signal
    signal editingFinished();
    signal accepted();
    signal textUpdated();

    height: showingHeader ? (inputLabel.height + inputItem.height + 2) : inputHeight

    onActiveFocusChanged: activeFocus && input.forceActiveFocus()
    onTextUpdated: {
        // check to remove placeholder text when there is content
        if(item.isEmpty()){
            placeholderLabel.visible = true;
        } else {
            placeholderLabel.visible = false;
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

    function isPasswordHidden() {
        if (password) {
            return passwordHidden;
        }
        if (passwordLinked) {
            return passwordLinked.passwordHidden;
        }
        return false;
    }

    function reset() {
        text = "";
        if (!passwordLinked) {
            passwordHidden = true;
        }
    }

    function passwordToggle() {
        if (passwordLinked) {
            passwordLinked.passwordHidden = !passwordLinked.passwordHidden;
        } else {
            passwordHidden = !passwordHidden;
        }
    }

    MoneroComponents.TextPlain {
        id: inputLabel
        anchors.top: parent.top
        anchors.left: parent.left
        font.family: MoneroComponents.Style.fontRegular.name
        font.pixelSize: labelFontSize
        font.bold: labelFontBold
        textFormat: Text.RichText
        color: MoneroComponents.Style.defaultFontColor
        onLinkActivated: item.labelLinkActivated()

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    MoneroComponents.LabelButton {
        id: copyButtonId
        text: qsTr("Copy") + translationManager.emptyString
        anchors.right: parent.right
        onClicked: {
            if (input.text.length > 0) {
                console.log("Copied to clipboard");
                clipboard.setText(input.text);
                appWindow.showStatusMessage(qsTr("Copied to clipboard"), 3);
            }
        }
        visible: copyButton && input.text !== ""
    }

    Item{
        id: inputItem
        height: inputHeight
        anchors.top: showingHeader ? inputLabel.bottom : parent.top
        anchors.topMargin: showingHeader ? 12 : 0
        width: parent.width
        clip: true

        MoneroComponents.TextPlain {
            id: placeholderLabel
            visible: input.text ? false : true
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: placeholderCenter ? parent.horizontalCenter : undefined
            anchors.left: placeholderCenter ? undefined : parent.left
            anchors.leftMargin: placeholderLeftMargin

            opacity: item.placeholderOpacity
            color: item.placeholderColor
            font.family: item.placeholderFontFamily
            font.pixelSize: placeholderFontSize
            font.bold: item.placeholderFontBold
            text: ""
            z: 3
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1
            color: item.enabled ? "transparent" : MoneroComponents.Style.inputBoxBackgroundDisabled
        }

        Rectangle {
            id: inputFill
            color: backgroundColor
            anchors.fill: parent
            border.width: borderDisabled ? 0 : 1
            border.color: borderColor
            radius: 4
        }

        Image {
            id: inlineIcon
            width: 26
            height: 26
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12
            source: "qrc:///images/moneroIcon-28x28.png"
            visible: false
        }

        MoneroComponents.Input {
            id: input
            anchors.fill: parent
            anchors.leftMargin: inlineIcon.visible ? 44 : 0
            font.family: item.fontFamily
            font.pixelSize: item.fontSize
            font.bold: item.fontBold
            KeyNavigation.backtab: item.KeyNavigation.backtab
            KeyNavigation.tab: item.KeyNavigation.tab
            onEditingFinished: item.editingFinished()
            onAccepted: item.accepted();
            onTextChanged: item.textUpdated()
            leftPadding: inputPadding
            rightPadding: (inlineButtons.width > 0 ? inlineButtons.width + inlineButtons.spacing : 0) + inputPadding
            topPadding: inputPadding
            bottomPadding: inputPadding
            echoMode: isPasswordHidden() ? TextInput.Password : TextInput.Normal

            MoneroComponents.Label {
                visible: password || passwordLinked
                fontSize: 20
                text: isPasswordHidden() ? FontAwesome.eye : FontAwesome.eyeSlash
                opacity: eyeMouseArea.containsMouse ? 0.9 : 0.7
                fontFamily: FontAwesome.fontFamily
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1

                MouseArea {
                    id: eyeMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: passwordToggle()
                }
            }

            RowLayout {
                id: inlineButtons
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: inputPadding
                anchors.bottomMargin: inputPadding
                anchors.rightMargin: inputPadding
                spacing: 4
            }
        }
    }
}
