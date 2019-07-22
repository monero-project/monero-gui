// Copyright (c) 2014-2019, The Monero Project
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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../components"
import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects
import "../version.js" as Version

Rectangle {
    Layout.fillWidth: true
    color: "transparent"

    property string viewName: "wizardLanguage"

    ColumnLayout {
        id: root
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 30

        Rectangle {
            // some margins for the titlebar
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.fillWidth: true
            Layout.preferredHeight: 0
            color: "transparent"
        }

        TextArea {
            id: textWelcome
            opacity: 0
            Layout.preferredWidth: parent.width / 1.3
            Layout.alignment: Qt.AlignCenter
            color: MoneroComponents.Style.defaultFontColor
            text: "Welcome - Wilkommen - Bonvenon - Bienvenido - Bienvenue - Välkommen - Selamat datang - Benvenuto - 歡迎 - Welkom - Bem Vindo - добро пожаловать"

            font.family: MoneroComponents.Style.fontRegular.name
            font.bold: true
            font.pixelSize: 18
            horizontalAlignment: TextInput.AlignHCenter
            selectByMouse: false
            wrapMode: Text.WordWrap
            textMargin: 0
            leftPadding: 0
            topPadding: 0
            readOnly: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 350;
                    easing.type: Easing.InCubic;
                }
            }
        }

        Image {
            id: globe
            source: "qrc:///images/world-flags-globe.png"
            opacity: 0
            property bool small: appWindow.width < 700 ? true : false
            property int size: {
                if(small){
                    return 196;
                } else {
                    return 312;
                }
            }
            Layout.preferredWidth: size
            Layout.preferredHeight: size
            Layout.alignment: Qt.AlignCenter
            mipmap: true

            property bool animSlow: false
            property int animSpeedSlow: 4000
            property int animSpeedNormal: 120000
            property real animFrom: 0
            property real animTo: 360

            Rectangle {
                visible: !globe.small
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 117
                anchors.topMargin: 71
                width: 36
                height: 40
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        anim.stop();
                        globe.animFrom = globe.rotation;
                        globe.animTo = globe.animFrom + 360;
                        anim.duration = globe.animSlow ? globe.animSpeedNormal : globe.animSpeedSlow;
                        globe.animSlow = !globe.animSlow;
                        anim.start();
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 450;
                    easing.type: Easing.InCubic;
                }
            }

            RotationAnimation on rotation {
                id: anim
                loops: Animation.Infinite
                from: globe.animFrom
                to: globe.animTo
                duration: globe.animSpeedNormal
            }
        }

        GridLayout {
            id: buttonsGrid
            opacity: 0
            columns: isMobile ? 1 : 2
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: 20
            Layout.fillWidth: true
            columnSpacing: 20

            MoneroComponents.StandardButton {
                id: idChangeLang
                Layout.minimumWidth: 150
                text: "Language"

                onClicked: {
                    appWindow.toggleLanguageView();
                }
            }

            MoneroComponents.StandardButton {
                id: btnContinue
                Layout.minimumWidth: 150
                text: "Continue"

                onClicked: {
                    wizardController.wizardStackView.backTransition = false;
                    if(wizardController.skipModeSelection){
                        wizardStateView.state = "wizardHome"
                    } else {
                        wizardStateView.state = "wizardModeSelection"
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 350;
                    easing.type: Easing.InCubic;
                }
            }
        }

        MoneroComponents.TextPlain {
            id: versionText
            opacity: 0
            Layout.alignment: Qt.AlignCenter
            font.bold: true
            font.pixelSize: 12
            font.family: MoneroComponents.Style.fontRegular.name
            color: MoneroComponents.Style.defaultFontColor
            text: Version.GUI_VERSION + " (Qt " + qtRuntimeVersion + ")"

            Behavior on opacity {
                NumberAnimation {
                    duration: 350;
                    easing.type: Easing.InCubic;
                }
            }
        }
    }

    Component.onCompleted: {
        // opacity effects
        delay(textTimer, 100, function() {
            textWelcome.opacity = 1;
        });

        delay(globeTimer, 150, function() {
            globe.opacity = 1;
        });

        delay(buttonTimer, 250, function() {
            buttonsGrid.opacity = 1;
        });

        delay(versionTimer, 350, function() {
            versionText.opacity = 1;
        });
    }

    function delay(timer, interval, cb) {
        timer.interval = interval;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    Timer {
        id: globeTimer
    }

    Timer {
        id: textTimer
    }

    Timer {
        id: buttonTimer
    }

    Timer {
        id: versionTimer
    }
}
