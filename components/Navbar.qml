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
import QtQuick.Layouts 1.1
import "." as MoneroComponents

Rectangle {
    default property list<MoneroComponents.NavbarItem> items
    property alias currentIndex: repeater.currentIndex
    property alias previousIndex: repeater.previousIndex

    color: "transparent"
    height: grid.height
    width: grid.width

    GridLayout {
        id: grid
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        columnSpacing: 0
        property string fontColorActive: MoneroComponents.Style.blackTheme ? "white" : "white"
        property string fontColorInActive: MoneroComponents.Style.blackTheme ? "white" : MoneroComponents.Style.dimmedFontColor
        property int fontSize: 15
        property bool fontBold: true
        property var fontFamily: MoneroComponents.Style.fontRegular.name
        property string borderColor: MoneroComponents.Style.blackTheme ? "#808080" : "#B9B9B9"
        property int textMargin: {
            // left-right margins for a given cell
            if(appWindow.width < 890){
                return 32;
            } else {
                return 64;
            }
        }

        Rectangle {
            // navbar left side border
            id: navBarLeft
            Layout.preferredWidth: 2
            Layout.preferredHeight: 32
            color: "transparent"

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: parent.height - 2
                color: grid.borderColor
            }

            ColumnLayout {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 1
                spacing: 0

                Rectangle {
                    Layout.preferredHeight: 1
                    Layout.preferredWidth: 1
                    color: grid.borderColor
                }

                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: items.length > 0 && items[0].active ? grid.borderColor : "transparent";
                }

                Rectangle {
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.preferredWidth: 1
                }
            }
        }

        Repeater {
            id: repeater
            model: items.length
            property int currentIndex: 0
            property int previousIndex: 0

            RowLayout {
                spacing: 0

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 32
                    color: grid.borderColor
                    visible: index > 0 && items[index - 1].visible
                }

                ColumnLayout {
                    Layout.minimumWidth: 72
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    spacing: 0
                    visible: items[index].visible

                    Rectangle {
                        color: grid.borderColor
                        Layout.preferredHeight: 1
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.minimumHeight: 30
                        Layout.fillWidth: true
                        color: items[index].active ? grid.borderColor : "transparent"
                        implicitHeight: children[0].implicitHeight
                        implicitWidth: children[0].implicitWidth

                        MoneroComponents.TextPlain {
                            anchors.centerIn: parent
                            font.family: grid.fontFamily
                            font.pixelSize: grid.fontSize
                            font.bold: grid.fontBold
                            leftPadding: grid.textMargin / 2
                            rightPadding: grid.textMargin / 2
                            text: items[index].text
                            color: items[index].active ? grid.fontColorActive : grid.fontColorInActive
                            themeTransition: false
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                repeater.previousIndex = repeater.currentIndex;
                                repeater.currentIndex = index;
                                items[index].selected()
                            }
                        }
                    }

                    Rectangle {
                        color: grid.borderColor
                        Layout.preferredHeight: 1
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Rectangle {
            // navbar right side border
            id: navBarRight
            Layout.preferredWidth: 2
            Layout.preferredHeight: 32
            color: "transparent"
            rotation: 180

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: parent.height - 2
                color: grid.borderColor
            }

            ColumnLayout {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 1
                spacing: 0

                Rectangle {
                    Layout.preferredHeight: 1
                    Layout.preferredWidth: 1
                    color: grid.borderColor
                }

                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: items.length > 0 && items[items.length - 1].active ? grid.borderColor : "transparent"
                }

                Rectangle {
                    color: grid.borderColor
                    Layout.preferredHeight: 1
                    Layout.preferredWidth: 1
                }
            }
        }
    }
}
