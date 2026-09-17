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
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents
import "effects/" as MoneroEffects

Item {
    id: root
    parent: appWindow.contentItem
    anchors.fill: parent
    z: aboveLockScreen ? 11 : passwordDialog.z - 1
    enabled: aboveLockScreen || !passwordDialog.visible
    visible: false

    property bool aboveLockScreen: true
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

    // maximum size of the popup card; it will shrink to fit shorter content
    readonly property int maxCardWidth: 480
    readonly property int maxTextHeight: 260

    // same signals as Dialog has
    signal accepted()
    signal rejected()
    signal closeCallback();

    function open() {
        root.visible = true;
    }

    function close() {
        root.visible = false;
        // reset button text
        okButton.text = qsTr("OK")
        cancelButton.text = qsTr("Cancel")

        closeCallback();
    }

    // dimmed backdrop; blocks interaction with the rest of the app while open
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.5
    }

    MouseArea {
        // absorb clicks and scroll so they don't reach whatever is behind the popup
        anchors.fill: parent
        onWheel: wheel.accepted = true
    }

    // popup card
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(root.maxCardWidth, root.width - 40)
        height: cardLayout.height + cardLayout.anchors.margins * 2
        radius: 10
        color: MoneroComponents.Style.blackTheme ? "black" : "white"
        border.color: MoneroComponents.Style.blackTheme ? Qt.rgba(255, 255, 255, 0.25) : Qt.rgba(0, 0, 0, 0.25)
        border.width: 1

        ColumnLayout {
            id: cardLayout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 14

            RowLayout {
                id: titleRow
                Layout.fillWidth: true
                Layout.rightMargin: closeButton.visible ? 24 : 0

                MoneroComponents.Label {
                    id: dialogTitle
                    Layout.fillWidth: true
                    textWidth: cardLayout.width - titleRow.Layout.rightMargin
                    wrapMode: Text.Wrap
                    fontSize: 18
                    fontFamily: "Arial"
                    fontBold: true
                    color: MoneroComponents.Style.defaultFontColor
                }
            }

            Flickable {
                id: flickable
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(dialogContent.implicitHeight, root.maxTextHeight)
                clip: true
                contentWidth: width
                contentHeight: dialogContent.implicitHeight
                boundsBehavior: isMac ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: dialogContent.implicitHeight > flickable.height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                }

                TextArea {
                    id: dialogContent
                    width: flickable.width
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

            // Ok/Cancel buttons
            RowLayout {
                id: buttons
                spacing: 60
                Layout.alignment: Qt.AlignHCenter

                MoneroComponents.StandardButton {
                    id: cancelButton
                    primary: false
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
            anchors.margins: 10
            width: 24
            height: 24
            radius: 6
            color: "transparent"

            MoneroEffects.ImageMask {
                anchors.centerIn: parent
                width: 12
                height: 12
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
                onEntered: closeButton.color = MoneroComponents.Style.blackTheme ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(0, 0, 0, 0.1);
                onExited: closeButton.color = "transparent";
                hoverEnabled: true
            }
        }
    }
}
