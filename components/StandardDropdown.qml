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
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import FontAwesome 1.0
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

ColumnLayout {
    id: dropdown
    Layout.fillWidth: true

    property int itemTopMargin: 0
    property alias dataModel: repeater.model
    property string shadowPressedColor
    property string shadowReleasedColor
    property string pressedColor: MoneroComponents.Style.appWindowBorderColor
    property string releasedColor: MoneroComponents.Style.titleBarButtonHoverColor
    property string textColor: MoneroComponents.Style.defaultFontColor
    property alias currentIndex: columnid.currentIndex
    readonly property alias expanded: popup.visible
    property alias labelText: dropdownLabel.text
    property alias labelColor: dropdownLabel.color
    property alias labelTextFormat: dropdownLabel.textFormat
    property alias labelWrapMode: dropdownLabel.wrapMode
    property alias labelHorizontalAlignment: dropdownLabel.horizontalAlignment
    property bool showingHeader: dropdownLabel.text !== ""
    property int labelFontSize: 14
    property bool labelFontBold: false
    property int dropdownHeight: 39
    property int fontSize: 14
    property int fontItemSize: 14
    property string colorBorder: MoneroComponents.Style.inputBorderColorInActive
    property string colorHeaderBackground: "transparent"
    property bool headerBorder: true
    property bool headerFontBold: false

    signal changed();

    onExpandedChanged: if(expanded) appWindow.currentItem = dropdown

    spacing: 0
    Rectangle {
        id: dropdownLabelRect
        color: "transparent"
        Layout.fillWidth: true
        height: (dropdownLabel.height + 10)
        visible: showingHeader ? true : false

        MoneroComponents.TextPlain {
            id: dropdownLabel
            anchors.top: parent.top
            anchors.left: parent.left
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: labelFontSize
            font.bold: labelFontBold
            textFormat: Text.RichText
            color: MoneroComponents.Style.defaultFontColor
        }
    }

    Rectangle {
        id: head
        color: dropArea.containsMouse ? MoneroComponents.Style.titleBarButtonHoverColor : "transparent"
        border.width: dropdown.headerBorder ? 1 : 0
        border.color: dropdown.colorBorder
        radius: 4
        Layout.fillWidth: true
        Layout.preferredHeight: dropdownHeight

        MoneroComponents.TextPlain {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: dropIndicator.left
            anchors.rightMargin: 12
            width: droplist.width
            elide: Text.ElideRight
            font.family: MoneroComponents.Style.fontRegular.name
            font.bold: dropdown.headerFontBold
            font.pixelSize: dropdown.fontSize
            color: dropdown.textColor
            text: columnid.currentIndex < repeater.model.count ? qsTr(repeater.model.get(columnid.currentIndex).column1) + translationManager.emptyString : ""
        }

        Item {
            id: dropIndicator
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 12
            width: dropdownIcon.width

            MoneroEffects.ImageMask {
                id: dropdownIcon
                anchors.centerIn: parent
                image: "qrc:///images/whiteDropIndicator.png"
                height: 8
                width: 12
                fontAwesomeFallbackIcon: FontAwesome.arrowDown
                fontAwesomeFallbackSize: 14
                color: MoneroComponents.Style.defaultFontColor
            }
        }

        MouseArea {
            id: dropArea
            anchors.fill: parent
            onClicked: dropdown.expanded ? popup.close() : popup.open()
            hoverEnabled: true
            cursorShape: Qt.ArrowCursor
        }
    }

    Popup {
        id: popup
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            id: droplist
            anchors.left: parent.left
            width: dropdown.width
            y: head.y + head.height
            clip: true
            height: dropdown.expanded ? columnid.height : 0
            color: dropdown.pressedColor

            Behavior on height {
                NumberAnimation { duration: 100; easing.type: Easing.InQuad }
            }

            Column {
                id: columnid
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                property int currentIndex: 0

                Repeater {
                    id: repeater

                    // Workaround for translations in listElements. All translated strings needs to be listed in this file.
                    property string stringAutomatic: qsTr("Automatic") + translationManager.emptyString
                    property string stringSlow: qsTr("Slow (x0.2 fee)") + translationManager.emptyString
                    property string stringNormal: qsTr("Normal (x1 fee)")  + translationManager.emptyString
                    property string stringFast: qsTr("Fast (x5 fee)")  + translationManager.emptyString
                    property string stringFastest: qsTr("Fastest (x200 fee)") + translationManager.emptyString

                    delegate: Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: (dropdown.dropdownHeight * 0.75)
                        //radius: index === repeater.count - 1 ? 4 : 0
                        color: itemArea.containsMouse || index === columnid.currentIndex || itemArea.containsMouse ? dropdown.releasedColor : dropdown.pressedColor

                        MoneroComponents.TextPlain {
                            id: col1Text
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: col2Text.left
                            anchors.leftMargin: 12
                            anchors.rightMargin: 0
                            font.family: MoneroComponents.Style.fontRegular.name
                            font.bold: false
                            font.pixelSize: fontItemSize
                            color: itemArea.containsMouse || index === columnid.currentIndex || itemArea.containsMouse ? "#FA6800" : "#FFFFFF"
                            text: qsTr(column1) + translationManager.emptyString
                        }

                        MoneroComponents.TextPlain {
                            id: col2Text
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 45
                            font.family: MoneroComponents.Style.fontRegular.name
                            font.pixelSize: 14
                            color: "#FFFFFF"
                            text: ""
                        }

                        MouseArea {
                            id: itemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.ArrowCursor

                            onClicked: {
                                popup.close()
                                columnid.currentIndex = index
                                changed();
                            }
                        }
                    }
                }
            }
        }
    }
}
