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
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../components" as MoneroComponents

Item {
    id: root
    visible: false
    Rectangle {
        id: bg
        z: parent.z + 1
        anchors.fill: parent
        color: "white"
        opacity: 0.9
    }

    property alias labelText: label.text
    property alias inputText: input.text

    // same signals as Dialog has
    signal accepted()
    signal rejected()

    function open() {
        leftPanel.enabled = false
        middlePanel.enabled = false
        titleBar.enabled = false
        show()
        root.visible = true;
        input.focus = true;
        input.text = "";
    }

    function close() {
        leftPanel.enabled = true
        middlePanel.enabled = true
        titleBar.enabled = true
        root.visible = false;
    }

    ColumnLayout {
        z: bg.z + 1
        id: mainLayout
        spacing: 10
        anchors { fill: parent; margins: 35 }

        ColumnLayout {
            id: column
            //anchors {fill: parent; margins: 16 }
            Layout.alignment: Qt.AlignHCenter

            Label {
                id: label
                Layout.alignment: Qt.AlignHCenter
                // Layout.columnSpan: 2
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 18 * scaleRatio
                font.family: "Arial"
                color: "#555555"
            }

            TextField {
                id : input
                focus: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.family: "Arial"
                font.pixelSize: 32 * scaleRatio
                // echoMode: TextInput.Password
                KeyNavigation.tab: okButton

                style: TextFieldStyle {
                    renderType: Text.NativeRendering
                    textColor: "#35B05A"
                    // passwordCharacter: "•"
                    // no background
                    background: Rectangle {
                        radius: 0
                        border.width: 0
                    }
                }
                Keys.onReturnPressed: {
                    root.close()
                    root.accepted()
                }
                Keys.onEscapePressed: {
                    root.close()
                    root.rejected()
                }
            }
            // underline
            Rectangle {
                height: 1
                color: "#DBDBDB"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                anchors.bottomMargin: 3
            }
            // padding
            Rectangle {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                height: 10
                opacity: 0
                color: "black"
            }
        }
        // Ok/Cancel buttons
        RowLayout {
            id: buttons
            spacing: 60
            Layout.alignment: Qt.AlignHCenter
            
            MoneroComponents.StandardButton {
                id: cancelButton
                width: 120
                fontSize: 14
                text: qsTr("Cancel") + translationManager.emptyString
                KeyNavigation.tab: input
                onClicked: {
                    root.close()
                    root.rejected()
                }
            }
            MoneroComponents.StandardButton {
                id: okButton
                width: 120
                fontSize: 14
                text: qsTr("Ok")
                KeyNavigation.tab: cancelButton
                onClicked: {
                    root.close()
                    root.accepted()
                }
            }
        }
    }
}
