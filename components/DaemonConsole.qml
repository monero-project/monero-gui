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
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2

import "../components" as MoneroComponents
import "../js/Windows.js" as Windows
import "../js/Utils.js" as Utils

Window {
    id: root
    modality: Qt.ApplicationModal
    color: "black"
    flags: Windows.flags
    property alias text: dialogContent.text
    property alias content: root.text
    property alias textArea: dialogContent
    property var icon

    // same signals as Dialog has
    signal accepted()
    signal rejected()

    onClosing: {
        inactiveOverlay.visible = false;
    }

    function open() {
        inactiveOverlay.visible = true;
        show();
    }

    // TODO: implement without hardcoding sizes
    width:  480
    height: 280

    // background gradient
    Image {
        anchors.fill: parent
        source: "../images/middlePanelBg.jpg"
    }

    // Make window draggable
    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: root.x += (mouseX - lastMousePos.x)
        onMouseYChanged: root.y += (mouseY - lastMousePos.y)
    }

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.topMargin: 20 * scaleRatio
        anchors.margins: 35 * scaleRatio
        spacing: 20 * scaleRatio

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: MoneroComponents.Style.inputBorderColorActive
                border.width: 1
                radius: 4
            }

            Flickable {
                id: flickable
                anchors.fill: parent

                TextArea.flickable: TextArea {
                    id : dialogContent
                    textFormat: TextEdit.RichText
                    selectByMouse: true
                    selectByKeyboard: true
                    font.family: MoneroComponents.Style.defaultFontColor
                    font.pixelSize: 14 * scaleRatio
                    color: MoneroComponents.Style.defaultFontColor
                    selectionColor: MoneroComponents.Style.dimmedFontColor
                    wrapMode: TextEdit.Wrap
                    readOnly: true
                    function logCommand(msg){
                        msg = log_color(msg, "lime");
                        textArea.append(msg);
                    }
                    function logMessage(msg){
                        msg = msg.trim();
                        var color = "white";
                        if(msg.toLowerCase().indexOf('error') >= 0){
                            color = "red";
                        } else if (msg.toLowerCase().indexOf('warning') >= 0){
                            color = "yellow";
                        }

                        // format multi-lines
                        if(msg.split("\n").length >= 2){
                            msg = msg.split("\n").join('<br>');
                        }

                        log(msg, color);
                    }
                    function log_color(msg, color){
                        return "<span style='color: " + color +  ";' >" + msg + "</span>";
                    }
                    function log(msg, color){
                        var timestamp = Utils.formatDate(new Date(), {
                            weekday: undefined,
                            month: "numeric",
                            timeZoneName: undefined
                        });

                        var _timestamp = log_color("[" + timestamp + "]", "#FFFFFF");
                        var _msg = log_color(msg, color);
                        textArea.append(_timestamp + " " + _msg);

                        // scroll to bottom
                        //if(flickable.contentHeight > content.height){
                        //    flickable.contentY = flickable.contentHeight + 20;
                        //}
                    }
                }

                ScrollBar.vertical: ScrollBar {}
            }
        }

        RowLayout {
            Layout.fillWidth: true

            MoneroComponents.LineEdit {
                id: sendCommandText
                Layout.fillWidth: true
                placeholderText: qsTr("command + enter (e.g help)") + translationManager.emptyString
                onAccepted: {
                    if(text.length > 0) {
                        textArea.logCommand(">>> " + text)
                        daemonManager.sendCommand(text, currentWallet.nettype);
                    }
                    text = ""
                }
            }
        }
    }

    // window borders
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.left: parent.left
        width:1
        color: "#2F2F2F"
        z: 2
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.right: parent.right
        width:1
        color: "#2F2F2F"
        z: 2
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        height:1
        color: "#2F2F2F"
        z: 2
    }
}
