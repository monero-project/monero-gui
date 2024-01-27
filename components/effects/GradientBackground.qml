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
import QtGraphicalEffects 1.0

import "../" as MoneroComponents

Item {
    id: root
    property string fallBackColor: ""
    property string blackColorStart: ""
    property string blackColorStop: ""
    property string whiteColorStart: ""
    property string whiteColorStop: ""
    property string initialStartColor: ""
    property string initialStopColor: ""
    property double posStart: 0.1
    property double posStop: 1.0
    property int duration: 300
    property variant start
    property variant end
    anchors.fill: parent

    // background software renderer
    Rectangle {
        visible: !isOpenGL
        anchors.fill: parent
        color: root.fallBackColor
    }

    // background opengl
    LinearGradient {
        visible: isOpenGL
        anchors.fill: parent
        start: root.start
        end: root.end
        gradient: Gradient {
            GradientStop {
                id: gradientStart
                position: root.posStart
                color: root.initialStartColor
            }
            GradientStop {
                id: gradientStop
                position: root.posStop
                color: root.initialStopColor
            }
        }

        states: [
            State {
                name: "black";
                when: isOpenGL && MoneroComponents.Style.blackTheme
                PropertyChanges {
                    target: gradientStart
                    color: root.blackColorStart
                }
                PropertyChanges {
                    target: gradientStop
                    color: root.blackColorStop
                }
            }, State {
                name: "white";
                when: isOpenGL && !MoneroComponents.Style.blackTheme
                PropertyChanges {
                    target: gradientStart
                    color: root.whiteColorStart
                }
                PropertyChanges {
                    target: gradientStop
                    color: root.whiteColorStop
                }
            }
        ]

        transitions: Transition {
            enabled: appWindow.themeTransition
            ColorAnimation { properties: "color"; easing.type: Easing.InOutQuad; duration: root.duration }
        }
    }
}
