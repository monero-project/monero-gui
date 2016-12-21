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

Window {
    id: root
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.FramelessWindowHint

    signal rejected()
    signal started();

    function open() {
        show()
    }

    // TODO: implement without hardcoding sizes
    width: 480
    height: 200

    ColumnLayout {
        id: mainLayout
        spacing: 10
        anchors { fill: parent; margins: 35 }

        ColumnLayout {
            id: column
            //anchors {fill: parent; margins: 16 }
            Layout.alignment: Qt.AlignHCenter

            Label {
                text: qsTr("Daemon doesn't appear to be running")
                Layout.alignment: Qt.AlignHCenter
                Layout.columnSpan: 2
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 24
                font.family: "Arial"
                color: "#555555"
            }

        }

        RowLayout {
            id: buttons
            spacing: 60
            Layout.alignment: Qt.AlignHCenter

            MoneroComponents.StandardButton {
                id: okButton
                width: 120
                fontSize: 14
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Start daemon")
                KeyNavigation.tab: cancelButton
                onClicked: {
                    root.close()
                    appWindow.startDaemon(daemonFlags.text);
                    root.started()
                }
            }

            MoneroComponents.StandardButton {
                id: cancelButton
                width: 120
                fontSize: 14
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Cancel")

                onClicked: {
                    root.close()
                    root.rejected()
                }
            }
        }
        RowLayout {
            id: advancedRow
            MoneroComponents.Label {
                id: daemonFlagsLabel
                color: "#4A4949"
                text: qsTr("Daemon startup flags") + translationManager.emptyString
                fontSize: 16
            }

            MoneroComponents.LineEdit {
                id: daemonFlags
                Layout.preferredWidth:  200
                Layout.fillWidth: true
                text: appWindow.persistentSettings.daemonFlags;
                placeholderText: qsTr("(optional)")
            }

        }
    }

}



