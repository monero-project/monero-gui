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

import FontAwesome 1.0
import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

ColumnLayout {
    id: item
    Layout.fillWidth: true

    default property alias content: inlineButtons.children

    property alias input: input
    property bool inputHasFocus: input.activeFocus
    property bool tabNavigationEnabled: true
    property alias text: input.text

    property int inputPaddingLeft: 10
    property int inputPaddingRight: 10
    property int inputPaddingTop: 10
    property int inputPaddingBottom: 10
    property int inputRadius: 4

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
        } else {
            return inputPaddingLeft;
        }
    }

    property alias acceptableInput: input.acceptableInput
    property alias validator: input.validator
    property alias readOnly : input.readOnly
    property alias cursorPosition: input.cursorPosition
    property bool copyButton: false
    property bool pasteButton: false
    property alias copyButtonText: copyButtonId.text
    property alias copyButtonEnabled: copyButtonId.enabled

    property bool borderDisabled: false
    property string borderColor: {
        if ((error && input.text !== "") || (errorWhenEmpty && input.text == "")) {
            return MoneroComponents.Style.inputBorderColorInvalid;
        } else if (input.activeFocus) {
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
    property bool errorWhenEmpty: false
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
    property int inputHeight: 39

    signal labelLinkActivated(); // input label, rich text <a> signal
    signal editingFinished();
    signal accepted();
    signal textUpdated();
    signal backtabPressed();
    signal tabPressed();

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

    spacing: 0
    Rectangle {
        id: inputLabelRect
        color: "transparent"
        Layout.fillWidth: true
        height: (inputLabel.height + 10)
        visible: showingHeader ? true : false

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

        RowLayout {
            anchors.right: parent.right
            spacing: 16

            MoneroComponents.LabelButton {
                id: copyButtonId
                text: qsTr("Copy") + translationManager.emptyString
                onClicked: {
                    if (input.text.length > 0) {
                        console.log("Copied to clipboard");
                        clipboard.setText(input.text);
                        appWindow.showStatusMessage(qsTr("Copied to clipboard"), 3);
                    }
                }
                visible: copyButton && input.text !== ""
            }

            MoneroComponents.LabelButton {
                id: pasteButtonId
                onClicked: {
                    input.clear();
                    input.paste();
                }
                text: qsTr("Paste") + translationManager.emptyString
                visible: pasteButton
            }
        }
    }

    MoneroComponents.Input {
        id: input
        Keys.onBacktabPressed: {
            item.backtabPressed();
            if (item.KeyNavigation.backtab) {
                item.KeyNavigation.backtab.forceActiveFocus()
            }
        }
        Keys.onTabPressed: {
            item.tabPressed();
            if (item.KeyNavigation.tab) {
                item.KeyNavigation.tab.forceActiveFocus()
            }
        }
        Layout.fillWidth: true
        Layout.preferredHeight: inputHeight

        leftPadding: item.inputPaddingLeft
        rightPadding: (inlineButtons.width > 0 ? inlineButtons.width + inlineButtons.spacing : 0) + inputPaddingRight + (password || passwordLinked ? 45 : 0)
        topPadding: item.inputPaddingTop
        bottomPadding: item.inputPaddingBottom

        font.family: item.fontFamily
        font.pixelSize: item.fontSize
        font.bold: item.fontBold
        onEditingFinished: item.editingFinished()
        onAccepted: item.accepted();
        onTextChanged: item.textUpdated()
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
            radius: item.inputRadius
        }

        RowLayout {
            id: inlineButtons
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: inputPaddingRight
            spacing: 4
        }
    }
}
