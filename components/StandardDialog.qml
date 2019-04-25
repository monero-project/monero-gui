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
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../components" as MoneroComponents
import "effects/" as MoneroEffects

Rectangle {
    id: root
    color: "transparent"
    visible: false
    property alias title: dialogTitle.text
    property alias text: dialogContent.text
    property alias content: root.text
    property alias cancelVisible: cancelButton.visible
    property alias okVisible: okButton.visible
    property alias textArea: dialogContent
    property alias okText: okButton.text
    property alias cancelText: cancelButton.text
    property alias closeVisible: closeButton.visible

    property var icon

    // same signals as Dialog has
    signal accepted()
    signal rejected()
    signal closeCallback();

    // background
    MoneroEffects.GradientBackground {
        anchors.fill: parent
        fallBackColor: MoneroComponents.Style.middlePanelBackgroundColor
        initialStartColor: MoneroComponents.Style.middlePanelBackgroundGradientStart
        initialStopColor: MoneroComponents.Style.middlePanelBackgroundGradientStop
        blackColorStart: MoneroComponents.Style._b_middlePanelBackgroundGradientStart
        blackColorStop: MoneroComponents.Style._b_middlePanelBackgroundGradientStop
        whiteColorStart: MoneroComponents.Style._w_middlePanelBackgroundGradientStart
        whiteColorStop: MoneroComponents.Style._w_middlePanelBackgroundGradientStop
        start: Qt.point(0, 0)
        end: Qt.point(height, width)
    }

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
            root.y = 100
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
    width: isMobile ? screenWidth : 520
    height: isMobile ? screenHeight : 380

    ColumnLayout {
        id: mainLayout
        spacing: 10
        anchors.fill: parent
        anchors.margins: (isMobile? 17 : 20)

        RowLayout {
            id: column
            Layout.topMargin: 14
            Layout.fillWidth: true

            MoneroComponents.Label {
                id: dialogTitle
                fontSize: 18
                fontFamily: "Arial"
                color: MoneroComponents.Style.defaultFontColor
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 240

            Flickable {
                id: flickable
                anchors.fill: parent
                ScrollBar.vertical: ScrollBar { }

                TextArea.flickable: TextArea {
                    id: dialogContent
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    renderType: Text.QtRendering
                    font.family: MoneroComponents.Style.fontLight.name
                    textFormat: TextEdit.AutoText
                    readOnly: true
                    font.pixelSize: 14
                    selectByMouse: false
                    wrapMode: TextEdit.Wrap
                    color: MoneroComponents.Style.defaultFontColor

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
        }

        // Ok/Cancel buttons
        RowLayout {
            id: buttons
            spacing: 60
            Layout.alignment: Qt.AlignHCenter

            MoneroComponents.StandardButton {
                id: cancelButton
                text: qsTr("Cancel") + translationManager.emptyString
                onClicked: {
                    root.close()
                    root.rejected()
                }
            }

            MoneroComponents.StandardButton {
                id: okButton
                text: qsTr("OK") + translationManager.emptyString
                KeyNavigation.tab: cancelButton
                onClicked: {
                    root.close()
                    root.accepted()
                }
            }
        }
    }

    // close icon
    Rectangle {
        id: closeButton
        anchors.top: parent.top
        anchors.right: parent.right
        width: 48
        height: 48
        color: "transparent"

        MoneroEffects.ImageMask {
            anchors.centerIn: parent
            width: 16
            height: 16
            image: MoneroComponents.Style.titleBarCloseSource
            color: MoneroComponents.Style.defaultFontColor
            opacity: 0.75
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.close()
                root.rejected()
            }
            cursorShape: Qt.PointingHandCursor
            onEntered: closeButton.color = "#262626";
            onExited: closeButton.color = "transparent";
        }
    }

    // window borders
    Rectangle{
        width: 1
        color: MoneroComponents.Style.grey
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    Rectangle{
        width: 1
        color: MoneroComponents.Style.grey
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    Rectangle{
        height: 1
        color: MoneroComponents.Style.grey
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    Rectangle{
        height: 1
        color: MoneroComponents.Style.grey
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }
}
