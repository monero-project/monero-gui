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

import "../components" as MoneroComponents

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
    property int dropdownHeight: 42
    property int fontHeaderSize: 16 * scaleRatio
    property int fontItemSize: 14 * scaleRatio
    property string colorBorder: MoneroComponents.Style.inputBorderColorInActive
    property string colorHeaderBackground: "transparent"
    property bool headerBorder: true
    property bool headerFontBold: false

    height: dropdownHeight

    signal changed();

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
    }

    Item {
        id: head
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: dropdown.dropdownHeight

        Rectangle {
            color: dropdown.colorHeaderBackground
            border.width: dropdown.headerBorder ? 1 : 0
            border.color: dropdown.colorBorder
            radius: 4
            anchors.fill: parent
        }

        Text {
            id: firstColText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12 * scaleRatio
            elide: Text.ElideRight
            font.family: MoneroComponents.Style.fontRegular.name
            font.bold: dropdown.headerFontBold
            font.pixelSize: dropdown.fontHeaderSize
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
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
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
                    height: (dropdown.dropdownHeight * 0.75) * scaleRatio
                    //radius: index === repeater.count - 1 ? 4 : 0
                    color: itemArea.containsMouse || index === column.currentIndex || itemArea.containsMouse ? dropdown.releasedColor : dropdown.pressedColor

                    Text {
                        id: col1Text
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: col2Text.left
                        anchors.leftMargin: 12 * scaleRatio
                        anchors.rightMargin: 0
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.bold: true
                        font.pixelSize: fontItemSize
                        color: itemArea.containsMouse || index === column.currentIndex || itemArea.containsMouse ? "#FA6800" : "#FFFFFF"
                        text: qsTr(column1) + translationManager.emptyString
                    }

                    Text {
                        id: col2Text
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 45 * scaleRatio
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 14 * scaleRatio
                        color: "#FFFFFF"
                        text: ""
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
                        cursorShape: Qt.PointingHandCursor

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
