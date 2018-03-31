// Copyright (c) 2014-2015, The Monero Project
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
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

ColumnLayout {
    id: lineditmulti
    property alias text: multiLine.text
    property alias placeholderText: placeholderLabel.text
    property alias labelText: inputLabel.text
    property alias error: multiLine.error
    property alias readOnly: multiLine.readOnly
    property alias addressValidation: multiLine.addressValidation
    property alias labelButtonText: labelButton.text
    property bool labelFontBold: false
    property bool labelButtonVisible: false
    property bool copyButton: false
    property bool wrapAnywhere: true
    property bool showingHeader: true
    property bool showBorder: true
    property bool fontBold: false
    property int fontSize: 16 * scaleRatio

    signal labelButtonClicked();
    signal inputLabelLinkActivated();

    spacing: 0
    Rectangle {
        id: inputLabelRect
        color: "transparent"
        Layout.fillWidth: true
        height: (inputLabel.height + 10) * scaleRatio
        visible: showingHeader ? true : false

        Text {
            id: inputLabel
            anchors.top: parent.top
            anchors.left: parent.left
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 16 * scaleRatio
            font.bold: labelFontBold
            textFormat: Text.RichText
            color: MoneroComponents.Style.defaultFontColor
            onLinkActivated: inputLabelLinkActivated()
        }

        MoneroComponents.LabelButton {
            id: labelButton
            onClicked: labelButtonClicked()
            visible: labelButtonVisible
        }

        MoneroComponents.LabelButton {
            id: copyButtonId
            visible: copyButton && multiLine.text !== ""
            text: qsTr("Copy")
            anchors.right: labelButton.visible ? inputLabel.right : parent.right
            anchors.rightMargin: labelButton.visible? 4 : 0
            onClicked: {
                if (multiLine.text.length > 0) {
                    console.log("Copied to clipboard");
                    clipboard.setText(multiLine.text);
                    appWindow.showStatusMessage(qsTr("Copied to clipboard"), 3);
                }
            }
        }
    }

    MoneroComponents.InputMulti {
        id: multiLine
        readOnly: false
        addressValidation: true
        anchors.top: parent.showingHeader ? inputLabelRect.bottom : parent.top
        Layout.fillWidth: true
        topPadding: parent.showingHeader ? 10 * scaleRatio : 0
        bottomPadding: 10 * scaleRatio
        wrapAnywhere: parent.wrapAnywhere
        fontSize: parent.fontSize
        fontBold: parent.fontBold

        Text {
            id: placeholderLabel
            visible: multiLine.text ? false : true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10 * scaleRatio
            opacity: 0.25
            color: MoneroComponents.Style.defaultFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 18 * scaleRatio
            text: ""
            z: 3
        }

        Rectangle {
            color: "transparent"
            border.width: 1
            border.color: {
              if(multiLine.error && multiLine.text !== ""){
                  return Qt.rgba(255, 0, 0, 0.45);
              } else if(multiLine.activeFocus){
                  return Qt.rgba(255, 255, 255, 0.35);
              } else {
                  return Qt.rgba(255, 255, 255, 0.25);
              }
            }
            radius: 4
            anchors.fill: parent
            visible: lineditmulti.showBorder
        }
    }
}
