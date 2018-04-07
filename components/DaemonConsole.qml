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

Window {
    id: root
    modality: Qt.ApplicationModal
    color: "black"
    flags: persistentSettings.customDecorations ? (Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint) : (Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint | Qt.WindowTitleHint | Qt.WindowMaximizeButtonHint)
    property string title
    property alias text: dialogContent.text
    property alias content: root.text
    property alias textArea: dialogContent
    property alias titleBar: titleBar
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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
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

    TitleBar {
        id: titleBar
        small: true
        anchors.left: parent.left
        anchors.right: parent.right
        x: 0
        y: 0
        showMinimizeButton: false
        showMaximizeButton: false
        showWhatIsButton: false
        onCloseClicked: root.close();
        title: root.title
        visible: persistentSettings.customDecorations ? true : false

        MouseArea {
            enabled: persistentSettings.customDecorations
            property var previousPosition
            anchors.fill: parent
            propagateComposedEvents: true
            onPressed: previousPosition = globalCursor.getPosition()
            onPositionChanged: {
                if (pressedButtons == Qt.LeftButton) {
                    var pos = globalCursor.getPosition()
                    var dx = pos.x - previousPosition.x
                    var dy = pos.y - previousPosition.y

                    root.x += dx
                    root.y += dy
                    previousPosition = pos
                }
            }
        }
    }

    ColumnLayout {
        id: mainLayout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: titleBar.visible ? 80 : 20

        anchors.margins: 35 * scaleRatio
        spacing: 20 * scaleRatio

        RowLayout {
            visible: !persistentSettings.customDecorations
            Layout.fillWidth: true
            anchors.horizontalCenter: parent.horizontalCenter

            MoneroComponents.Label {
                id: titleLabel
                anchors.horizontalCenter: parent.horizontalCenter
                fontSize: 24
                text: title
                z: parent.z + 1
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                id: flickable
                anchors.fill: parent

                TextArea.flickable: TextArea {
                    id : dialogContent
                    selectByMouse: true
                    selectByKeyboard: true
                    anchors.fill: parent
                    font.family: "Ariel"
                    font.pixelSize: 14
                    color: MoneroComponents.Style.defaultFontColor
                    selectionColor: MoneroComponents.Style.dimmedFontColor
                    textFormat: TextEdit.AutoText
                    wrapMode: TextEdit.Wrap
                    background: Rectangle {
                        color: "transparent"
                        anchors.fill: parent
                        border.color: Qt.rgba(255, 255, 255, 0.25);
                        border.width: 1
                        radius: 4
                    }
                    readOnly: true
                }

                ScrollBar.vertical: ScrollBar {
                    // TODO
                    // scrollbar always visible is somewhat buggy
                    // QT 5.7 introduces `policy: ScrollBar.AlwaysOn`
                    // but we can't use it yet.
                    contentItem.opacity: 1
                    anchors.top: flickable.top
                    anchors.left: flickable.right
                    anchors.leftMargin: 10
                    anchors.bottom: flickable.bottom
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            MoneroComponents.LineEdit {
                id: sendCommandText
                Layout.fillWidth: true
                placeholderText: qsTr("command + enter (e.g help)") + translationManager.emptyString
                onAccepted: {
                    if(text.length > 0)
                        daemonManager.sendCommand(text, currentWallet.nettype);
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
