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
    signal searchClicked(string text, int option)
    height: 50

    Rectangle {
        anchors.fill: parent
        color: "#DBDBDB"
        //radius: 4
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 1
        color: "#FFFFFF"
        //radius: 4

        Item {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 45

            Image {
                anchors.centerIn: parent
                source: "../images/magnifier.png"
            }
        }

        Input {
            id: input
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: dropdown.left
            anchors.leftMargin: 45
            font.pixelSize: 18
            verticalAlignment: TextInput.AlignVCenter
            placeholderText: qsTr("Search by...") + translationManager.emptyString
        }

        Item {
            id: dropdown
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: button.left
            width: 154

            function hide() { droplist.height = 0 }
            function containsPoint(px, py) {
                if(px < 0)
                    return false
                if(px > width)
                    return false
                if(py < 0)
                    return false
                if(py > height + droplist.height)
                    return false
                return true
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: dropText
                    width: 114 - 12
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: "Arial"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#4A4747"
                    text: "NAME"
                }

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../images/hseparator.png"
                }

                Item {
                    height: dropdown.height
                    width: 38

                    Image {
                        id: dropIndicator
                        anchors.centerIn: parent
                        source: "../images/dropIndicator.png"
                        rotation: droplist.height === 0 ? 0 : 180
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(droplist.height === 0) {
                        appWindow.currentItem = dropdown
                        droplist.height = dropcolumn.height + 2
                    } else {
                        droplist.height = 0
                    }
                }
            }
        }

        Rectangle {
            id: droplist
            property int currentOption: 0

            width: 154
            height: 0
            clip: true
            x: dropdown.x
            y: dropdown.height
            border.width: 1
            border.color: "#DBDBDB"
            color: "#FFFFFF"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                height: 1
                color: "#FFFFFF"
            }

            Behavior on height {
                NumberAnimation { duration: 100; easing.type: Easing.InQuad }
            }

            ListModel {
                id: dropdownModel
                ListElement { name: "NAME" }
                ListElement { name: "DESCRIPTION" }
                ListElement { name: "ADDRESS" }
            }

            Column {
                id: dropcolumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 1

                Repeater {
                    model: dropdownModel
                    delegate: Rectangle {
                        property bool isCurrent: name === dropText.text
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 30
                        color: delegateArea.pressed || isCurrent ? "#4A4646" : "#FFFFFF"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            elide: Text.ElideRight
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            font.family: "Arial"
                            font.bold: true
                            font.pixelSize: 12
                            color: delegateArea.pressed || parent.isCurrent ? "#FFFFFF" : "#4A4646"
                            text: name
                        }

                        MouseArea {
                            id: delegateArea
                            anchors.fill: parent
                            onClicked: {
                                droplist.currentOption = index
                                droplist.height = 0
                                dropText.text = name
                            }
                        }
                    }
                }
            }
        }

        StandardButton {
            id: button
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 6
            width: 80

            shadowReleasedColor: "#C60F00"
            shadowPressedColor: "#8C0B00"
            pressedColor: "#C60F00"
            releasedColor: "#FF4F41"
            text: qsTr("SEARCH")
            onClicked: item.searchClicked(input.text, droplist.currentOption)
        }
    }
}
