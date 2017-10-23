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

Item {
    id: item
    property int fillLevel: 0
    height: 70
    clip: true

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 24
        //radius: 4
        color: "#DBDBDB"
    }

    Rectangle {
        id: bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 1
        height: 24
        //radius: 4
        color: "#FFFFFF"

        Rectangle {
            id: fillRect
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 4
            //radius: 2
            width: row.x

            color: {
                if(item.fillLevel < 3) return "#FF6C3C"
                if(item.fillLevel < 13) return "#AAFFBB"
                return "#36B25C"
            }

            Timer {
                interval: 500
                running: true
                repeat: false
                onTriggered: fillRect.loaded = true
            }

            property bool loaded: false
            Behavior on width {
                enabled: fillRect.loaded
                NumberAnimation { duration: 100; easing.type: Easing.InQuad }
            }
        }

        MouseArea {
            anchors.fill: parent
            function positionBar() {
                var xDiff = 999999
                var index = -1
                for(var i = 0; i < 14; ++i) {
                    var tmp = Math.abs(row.positions[i].currentX + row.x - mouseX)
                    if(tmp < xDiff) {
                        xDiff = tmp
                        index = i
                    }
                }

                if(index !== -1) {
                    fillRect.width = Qt.binding(function(){ return row.positions[index].currentX + row.x })
                    item.fillLevel = index
                }
            }

            onClicked: positionBar()
            onMouseXChanged: positionBar()
        }
    }

    Row {
        id: row
        anchors.right: bar.right
        anchors.rightMargin: 8
        anchors.top: bar.bottom
        anchors.topMargin: -1
        property var positions: new Array()

        Row {
            id: row2
            spacing: bar.width / 14

            Repeater {
                model: 4

                delegate: TickDelegate {
                    id: delegateItem2
                    currentX: x + row2.x
                    currentIndex: index
                    mainTick: currentIndex === 0
                    Component.onCompleted: {
                        row.positions[currentIndex] = delegateItem2
                    }
                }
            }
        }

        Row {
            id: row1
            spacing: bar.width / 14

            Repeater {
                model: 10

                delegate: TickDelegate {
                    id: delegateItem1
                    currentX: x + row1.x
                    currentIndex: index + 4
                    mainTick: currentIndex === 13
                    Component.onCompleted: {
                        row.positions[currentIndex] = delegateItem1
                    }
                }
            }
        }
    }
}
