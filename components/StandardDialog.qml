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
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../components" as MoneroComponents

Rectangle {
    id: root
    color: "white"
    visible: false
    property alias title: dialogTitle.text
    property alias text: dialogContent.text
    property alias content: root.text
    property alias cancelVisible: cancelButton.visible
    property alias okVisible: okButton.visible
    property alias textArea: dialogContent
    property alias okText: okButton.text
    property alias cancelText: cancelButton.text

    property var icon

    // same signals as Dialog has
    signal accepted()
    signal rejected()
    signal closeCallback();

    // Make window draggable
    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: root.x += (mouseX - lastMousePos.x)
        onMouseYChanged: root.y += (mouseY - lastMousePos.y)
    }

    function open() {
        // Center
        if(!isMobile) {
            root.x = parent.width/2 - root.width/2
            root.y = screenHeight/2 - root.height/2
        }
        show()
        root.z = 11
        root.visible = true;
    }

    function close() {
        root.visible = false;
        closeCallback();
    }

    // TODO: implement without hardcoding sizes
    width: isMobile ? screenWidth : 480
    height: isMobile ? screenHeight : 280

    ColumnLayout {
        id: mainLayout
        spacing: 10
        anchors { fill: parent; margins: 35 }

        RowLayout {
            id: column
            //anchors {fill: parent; margins: 16 }
            Layout.alignment: Qt.AlignHCenter

            Label {
                id: dialogTitle
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 18 * scaleRatio
                font.family: "Arial"
                color: "#555555"
            }

        }

        RowLayout {
            TextArea {
                id : dialogContent
                Layout.fillWidth: true
                Layout.fillHeight: true
                font.family: "Arial"
                textFormat: TextEdit.AutoText
                readOnly: true
                font.pixelSize: 12 * scaleRatio
                selectByMouse: false
                wrapMode: TextEdit.Wrap

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        appWindow.showStatusMessage(qsTr("Double tap to copy"),3)
                    }
                    onDoubleClicked: {
                        parent.selectAll()
                        parent.copy()
                        parent.deselect()
                        console.log("copied to clipboard");
                        appWindow.showStatusMessage(qsTr("Content copied to clipboard"),3)
                    }
                }
            }
        }

        // Ok/Cancel buttons
        RowLayout {
            id: buttons
            spacing: 60
            Layout.alignment: Qt.AlignHCenter

            MoneroComponents.StandardButton {
                id: cancelButton
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Cancel") + translationManager.emptyString
                onClicked: {
                    root.close()
                    root.rejected()
                }
            }

            MoneroComponents.StandardButton {
                id: okButton
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("OK")
                KeyNavigation.tab: cancelButton
                onClicked: {
                    root.close()
                    root.accepted()

                }
            }
        }
    }

}



