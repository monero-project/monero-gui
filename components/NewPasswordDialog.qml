// Copyright (c) 2017, The Monero Project
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

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../components" as MoneroComponents

Item {
    id: root
    visible: false
    z: parent.z + 2

    property bool isHidden: true
    property alias password: passwordInput1.text

    // same signals as Dialog has
    signal accepted()
    signal rejected()
    signal closeCallback()

    function open() {
        inactiveOverlay.visible = true
        leftPanel.enabled = false
        middlePanel.enabled = false
        titleBar.enabled = false
        show();
        root.visible = true;
        passwordInput1.text = "";
        passwordInput2.text = "";
        passwordInput1.focus = true
    }

    function close() {
        inactiveOverlay.visible = false
        leftPanel.enabled = true
        middlePanel.enabled = true
        titleBar.enabled = true
        root.visible = false;
        closeCallback();
    }
    
    function toggleIsHidden() {
        passwordInput1.echoMode = isHidden ? TextInput.Normal : TextInput.Password;
        passwordInput2.echoMode = isHidden ? TextInput.Normal : TextInput.Password;
        isHidden = !isHidden;
    }

    // TODO: implement without hardcoding sizes
    width: 480
    height: 360

    // Make window draggable
    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: root.x += (mouseX - lastMousePos.x)
        onMouseYChanged: root.y += (mouseY - lastMousePos.y)
    }

    ColumnLayout {
        z: inactiveOverlay.z + 1
        id: mainLayout
        spacing: 10
        anchors { fill: parent; margins: 35 * scaleRatio }

        ColumnLayout {
            id: column

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 400 * scaleRatio

            Label {
                text: qsTr("Please enter new password")
                Layout.fillWidth: true

                font.pixelSize: 16 * scaleRatio
                font.family: MoneroComponents.Style.fontLight.name

                color: MoneroComponents.Style.defaultFontColor
            }

            TextField {
                id : passwordInput1
                Layout.topMargin: 6
                Layout.fillWidth: true
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: TextInput.AlignVCenter
                font.family: MoneroComponents.Style.fontLight.name
                font.pixelSize: 24 * scaleRatio
                echoMode: TextInput.Password
                bottomPadding: 10
                leftPadding: 10
                topPadding: 10
                color: MoneroComponents.Style.defaultFontColor
                selectionColor: MoneroComponents.Style.dimmedFontColor
                selectedTextColor: MoneroComponents.Style.defaultFontColor
                KeyNavigation.tab: passwordInput2

                background: Rectangle {
                    radius: 2
                    border.color: Qt.rgba(255, 255, 255, 0.35)
                    border.width: 1
                    color: "black"

                    Image {
                        width: 26 * scaleRatio
                        height: 26 * scaleRatio
                        opacity: 0.7
                        fillMode: Image.PreserveAspectFit
                        source: isHidden ? "../images/eyeShow.png" : "../images/eyeHide.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                toggleIsHidden()
                            }
                            onEntered: {
                                parent.opacity = 0.9
                                parent.width = 28 * scaleRatio
                                parent.height = 28 * scaleRatio
                            }
                            onExited: {
                                parent.opacity = 0.7
                                parent.width = 26 * scaleRatio
                                parent.height = 26 * scaleRatio
                            }
                        }
                    }
                }

                Keys.onEscapePressed: {
                    root.close()
                    root.rejected()
                }
            }

            // padding
            Rectangle {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                height: 10
                opacity: 0
                color: "black"
            }

            Label {
                text: qsTr("Please confirm new password")
                Layout.fillWidth: true

                font.pixelSize: 16 * scaleRatio
                font.family: MoneroComponents.Style.fontLight.name

                color: MoneroComponents.Style.defaultFontColor
            }

            TextField {
                id : passwordInput2
                Layout.topMargin: 6
                Layout.fillWidth: true
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: TextInput.AlignVCenter
                font.family: MoneroComponents.Style.fontLight.name
                font.pixelSize: 24 * scaleRatio
                echoMode: TextInput.Password
                KeyNavigation.tab: okButton
                bottomPadding: 10
                leftPadding: 10
                topPadding: 10
                color: MoneroComponents.Style.defaultFontColor
                selectionColor: MoneroComponents.Style.dimmedFontColor
                selectedTextColor: MoneroComponents.Style.defaultFontColor

                background: Rectangle {
                    radius: 2
                    border.color: Qt.rgba(255, 255, 255, 0.35)
                    border.width: 1
                    color: "black"

                    Image {
                        width: 26 * scaleRatio
                        height: 26 * scaleRatio
                        opacity: 0.7
                        fillMode: Image.PreserveAspectFit
                        source: isHidden ? "../images/eyeShow.png" : "../images/eyeHide.png"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                toggleIsHidden()
                            }
                            onEntered: {
                                parent.opacity = 0.9
                                parent.width = 28 * scaleRatio
                                parent.height = 28 * scaleRatio
                            }
                            onExited: {
                                parent.opacity = 0.7
                                parent.width = 26 * scaleRatio
                                parent.height = 26 * scaleRatio
                            }
                        }
                    }
                }

                Keys.onReturnPressed: {
                    if (passwordInput1.text === passwordInput2.text) {
                        root.close()
                        root.accepted()
                    }
                }
                Keys.onEscapePressed: {
                    root.close()
                    root.rejected()
                }
            }

            // padding
            Rectangle {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                height: 10
                opacity: 0
                color: "black"
            }

            // Ok/Cancel buttons
            RowLayout {
                id: buttons
                spacing: 16 * scaleRatio
                Layout.topMargin: 16
                Layout.alignment: Qt.AlignRight

                MoneroComponents.StandardButton {
                    id: cancelButton
                    text: qsTr("Cancel") + translationManager.emptyString
                    KeyNavigation.tab: passwordInput1
                    onClicked: {
                        root.close()
                        root.rejected()
                    }
                }
                MoneroComponents.StandardButton {
                    id: okButton
                    text: qsTr("Continue")
                    KeyNavigation.tab: cancelButton
                    enabled: passwordInput1.text === passwordInput2.text
                    onClicked: {
                        root.close()
                        root.accepted()
                    }
                }
            }
        }
    }
}
