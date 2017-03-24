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

Rectangle {
    id: header
    signal sortRequest(bool desc, int column)
    property alias dataModel: columnsRepeater.model
    property int activeSortColumn: -1
    property int offset: 0

    height: 31
    color: "#FFFFFF"

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#DBDBDB"
    }

    Row {
        id: row
        anchors.horizontalCenter: header.offset !== 0 ? undefined: parent.horizontalCenter
        anchors.left: header.offset !== 0 ? parent.left : undefined
        anchors.leftMargin: header.offset

        Rectangle {
            height: 31
            width: 1
            color: "#DBDBDB"
        }

        Repeater {
            id: columnsRepeater

            // Workaround for translations in listElements. All translated strings needs to be listed in this file.
            property string stringPaymentID: qsTr("Payment ID") + translationManager.emptyString
            property string stringDate: qsTr("Date") + translationManager.emptyString
            property string stringBlockHeight: qsTr("Block height") + translationManager.emptyString
            property string stringAmount: qsTr("Amount") + translationManager.emptyString

            delegate: Rectangle {
                id: delegate
                property bool desc: false
                height: 31
                width: columnWidth

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 13
                    anchors.rightMargin: 13
                    elide: Text.ElideRight
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: {
                        if(delegateArea.pressed)
                            return "#FF4304"
                        return index === header.activeSortColumn || delegateArea.containsMouse ? "#FF6C3C" : "#4A4949"
                    }
                    text: qsTr(columnName) + translationManager.emptyString
                }

                MouseArea {
                    id: delegateArea
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        delegate.desc = !delegate.desc
                        header.activeSortColumn = index
                        header.sortRequest(delegate.desc, index)
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 9

                    Item {
                        width: 14
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        Image {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -2
                            source: {
                                if(descArea.pressed)
                                    return "../images/descSortIndicatorPressed.png"
                                return index === header.activeSortColumn || descArea.containsMouse ? "../images/descSortIndicatorActived.png" :
                                                                                                     "../images/descSortIndicator.png"
                            }
                        }

                        MouseArea {
                            id: descArea
                            hoverEnabled: true
                            anchors.fill: parent
                            onClicked: {
                                delegate.desc = true
                                header.activeSortColumn = index
                                header.sortRequest(delegate.desc, index)
                            }
                        }
                    }

                    Item {
                        width: 14
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        Image {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -3
                            source: {
                                if(ascArea.pressed)
                                    return "../images/ascSortIndicatorPressed.png"
                                return index === header.activeSortColumn || ascArea.containsMouse ? "../images/ascSortIndicatorActived.png" :
                                                                                                    "../images/ascSortIndicator.png"
                            }
                        }

                        MouseArea {
                            id: ascArea
                            hoverEnabled: true
                            anchors.fill: parent
                            onClicked: {
                                delegate.desc = false
                                header.activeSortColumn = index
                                header.sortRequest(delegate.desc, index)
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: index === header.activeSortColumn ? "#FFFFFF" : "#DBDBDB"
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    color: "#DBDBDB"
                }
            }
        }
    }
}
