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
    property int countDown: 5;
    signal rejected()
    signal started();

    function open() {
        show()
        countDown = 5;
        timer.start();
    }

    // TODO: implement without hardcoding sizes
    width: 480
    height: 200

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
        spacing: 10
        anchors { fill: parent; margins: 35 }

        ColumnLayout {
            id: column
            //anchors {fill: parent; margins: 16 }
            Layout.alignment: Qt.AlignHCenter

            Timer {
                id: timer
                interval: 1000;
                running: false;
                repeat: true
                onTriggered: {
                    countDown--;
                    if(countDown < 0){
                        running = false;
                        // Start daemon
                        root.close()
                        appWindow.startDaemon(persistentSettings.daemonFlags);
                        root.started();
                    }
                }
            }

            Text {
                text: qsTr("Starting local node in %1 seconds").arg(countDown);
                font.pixelSize: 18
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

        }

        RowLayout {
            id: buttons
            spacing: 60
            Layout.alignment: Qt.AlignHCenter

            MoneroComponents.StandardButton {
                id: okButton
                visible:false
                fontSize: 14
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Start daemon (%1)").arg(countDown)
                KeyNavigation.tab: cancelButton
                onClicked: {
                    timer.stop();
                    root.close()
                    appWindow.startDaemon(persistentSettings.daemonFlags);
                    root.started()
                }
            }

            MoneroComponents.StandardButton {
                id: cancelButton
                fontSize: 14
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
                text: qsTr("Use custom settings")

                onClicked: {
                    timer.stop();
                    root.close()
                    root.rejected()
                }
            }
        }
    }
}



