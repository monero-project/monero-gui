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
    id: dropdown
    property alias dataModel: repeater.model
    property string shadowPressedColor
    property string shadowReleasedColor
    property string pressedColor
    property string releasedColor
    property string textColor: "#FFFFFF"
    property alias currentIndex: column.currentIndex
    property bool expanded: false

    signal changed();

    height: 37 * scaleRatio

    onExpandedChanged: if(expanded) appWindow.currentItem = dropdown
    function hide() { dropdown.expanded = false }
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

    // Workaroud for suspected memory leak in 5.8 causing malloc crash on app exit
    function update() {
        firstColText.text = column.currentIndex < repeater.model.rowCount() ? qsTr(repeater.model.get(column.currentIndex).column1) + translationManager.emptyString : ""
        secondColText.text =  column.currentIndex < repeater.model.rowCount() ? qsTr(repeater.model.get(column.currentIndex).column2) + translationManager.emptyString : ""
    }

    Item {
        id: head
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 37 * scaleRatio

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - 1
            y: dropdown.expanded || droplist.height > 0 ? 0 : 1
            color: dropdown.expanded || droplist.height > 0 ? dropdown.shadowPressedColor : dropdown.shadowReleasedColor
            //radius: 4
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - 1
            y: dropdown.expanded || droplist.height > 0 ? 1 : 0
            color: dropdown.expanded || droplist.height > 0 ? dropdown.pressedColor : dropdown.releasedColor
            //radius: 4
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: 3 * scaleRatio
            width: 3 * scaleRatio
            color: dropdown.pressedColor
            visible: dropdown.expanded || droplist.height > 0
        }

        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 3 * scaleRatio
            width: 3 * scaleRatio
            color: dropdown.pressedColor
            visible: dropdown.expanded || droplist.height > 0
        }

        Text {
            id: firstColText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12 * scaleRatio
            elide: Text.ElideRight
            font.family: "Arial"
            font.bold: true
            font.pixelSize: 12 * scaleRatio
            color: "#FFFFFF"
        }

        Text {
            id: secondColText
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: separator.left
            anchors.rightMargin: 12 * scaleRatio
            width: dropdown.expanded ? w : (separator.x - 12) - (firstColText.x + firstColText.width + 5)
            font.family: "Arial"
            font.pixelSize: 12 * scaleRatio
            color: "#FFFFFF"
            property int w: 0
            Component.onCompleted: w = implicitWidth
        }

        Rectangle {
            id: separator
            anchors.right: dropIndicator.left
            anchors.verticalCenter: parent.verticalCenter
            height: 18 * scaleRatio
            width: 1
            color: "#FFFFFF"
        }

        Item {
            id: dropIndicator
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 32 * scaleRatio

            Image {
                anchors.centerIn: parent
                source: "../images/whiteDropIndicator.png"
                rotation: dropdown.expanded ? 180  * scaleRatio : 0
            }
        }

        MouseArea {
            id: dropArea
            anchors.fill: parent
            onClicked: dropdown.expanded = !dropdown.expanded
        }
    }

    Rectangle {
        id: droplist
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        clip: true
        height: dropdown.expanded ? column.height : 0
        color: dropdown.pressedColor
        //radius: 4

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: 3 * scaleRatio; height: 3 * scaleRatio
            color: dropdown.pressedColor
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: 3 * scaleRatio; height: 3 * scaleRatio
            color: dropdown.pressedColor
        }

        Behavior on height {
            NumberAnimation { duration: 100; easing.type: Easing.InQuad }
        }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            property int currentIndex: 0

            Repeater {
                id: repeater

                // Workaround for translations in listElements. All translated strings needs to be listed in this file.
                property string stringLow: qsTr("Low (x1 fee)") + translationManager.emptyString
                property string stringMedium:  qsTr("Medium (x20 fee)") + translationManager.emptyString
                property string stringHigh:  qsTr("High (x166 fee)") + translationManager.emptyString
                property string stringSlow: qsTr("Slow (x0.25 fee)") + translationManager.emptyString
                property string stringDefault: qsTr("Default (x1 fee)") + translationManager.emptyString
                property string stringFast: qsTr("Fast (x5 fee)") + translationManager.emptyString
                property string stringFastest: qsTr("Fastest (x41.5 fee)") + translationManager.emptyString
                property string stringAll:  qsTr("All") + translationManager.emptyString
                property string stringSent:  qsTr("Sent") + translationManager.emptyString
                property string stringReceived:  qsTr("Received") + translationManager.emptyString


                delegate: Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 30 * scaleRatio
                    //radius: index === repeater.count - 1 ? 4 : 0
                    color: itemArea.containsMouse || index === column.currentIndex || itemArea.containsMouse ? dropdown.releasedColor : dropdown.pressedColor

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: col2Text.left
                        anchors.leftMargin: 12 * scaleRatio
                        anchors.rightMargin: column2.length > 0 ? 12  * scaleRatio: 0
                        font.family: "Arial"
                        font.bold: true
                        font.pixelSize: 12 * scaleRatio
                        color: "#FFFFFF"
                        text: qsTr(column1) + translationManager.emptyString
                    }

                    Text {
                        id: col2Text
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 45 * scaleRatio
                        font.family: "Arial"
                        font.pixelSize: 12 * scaleRatio
                        color: "#FFFFFF"
                        text: column2
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 3 * scaleRatio; height: 3 * scaleRatio
                        color: parent.color
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        width: 3 * scaleRatio; height: 3 * scaleRatio
                        color: parent.color
                    }

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            dropdown.expanded = false
                            column.currentIndex = index
                            changed();
                            dropdown.update()
                        }
                    }
                }
            }
        }
    }
}
