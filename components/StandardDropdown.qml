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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import FontAwesome

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
    property int maxDropdownItems: 0
    property int fontSize: 14
    property int fontItemSize: 14
    property string colorBorder: MoneroComponents.Style.inputBorderColorInActive
    property string colorHeaderBackground: "transparent"
    property bool headerBorder: true
    property bool headerFontBold: false

    property real maxAvailableDropdownHeight: Number.POSITIVE_INFINITY

    function updateMaxAvailableDropdownHeight() {
        var itemCap = dropdown.maxDropdownItems > 0 ? dropdown.maxDropdownItems * dropdown.dropdownHeight * 0.75 : Number.POSITIVE_INFINITY
        var win = dropdown.Window.window
        if (!win) {
            maxAvailableDropdownHeight = itemCap
            return
        }
        var headBottom = head.mapToItem(null, 0, head.height).y
        var spaceCap = Math.max(dropdown.dropdownHeight * 0.75, win.height - headBottom - 8)
        maxAvailableDropdownHeight = Math.min(itemCap, spaceCap)
    }

    signal changed();

    property int highlightIndex: 0

    function openPopup() {
        dropdown.highlightIndex = columnid.currentIndex
        dropdown.updateMaxAvailableDropdownHeight()
        popup.open()
        dropdown.ensureHighlightVisible()
    }

    function ensureHighlightVisible() {
        var row = repeater.itemAt(dropdown.highlightIndex)
        if (!row) {
            return
        }
        // droplist's height animates on open, so use the height it is animating to
        var viewHeight = Math.min(columnid.height, dropdown.maxAvailableDropdownHeight)
        if (row.y < dropFlickable.contentY) {
            dropFlickable.contentY = row.y
        } else if (row.y + row.height > dropFlickable.contentY + viewHeight) {
            dropFlickable.contentY = row.y + row.height - viewHeight
        }
    }

    onHighlightIndexChanged: if (expanded) ensureHighlightVisible()

    // Close when keyboard focus moves away (e.g. Tab), otherwise the popup stays
    // open with nothing left to receive Escape
    onActiveFocusChanged: if (!activeFocus) popup.close()

    function selectItem(index) {
        popup.close()
        columnid.currentIndex = index
        changed();
    }

    Accessible.onPressAction: {
        if (dropdown.expanded) {
            popup.close()
        } else {
            dropdown.forceActiveFocus()
            dropdown.openPopup()
        }
    }

    Keys.onPressed: (event) => {
        var isActivationKey = event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space
        // A held key would otherwise open the popup and then immediately commit the highlighted row
        if (isActivationKey && event.isAutoRepeat) {
            event.accepted = true
            return
        }
        if (!dropdown.expanded) {
            if (isActivationKey) {
                dropdown.openPopup()
                event.accepted = true
            }
            return
        }
        if (event.key === Qt.Key_Up) {
            dropdown.highlightIndex = Math.max(0, dropdown.highlightIndex - 1)
        } else if (event.key === Qt.Key_Down) {
            dropdown.highlightIndex = Math.min(repeater.count - 1, dropdown.highlightIndex + 1)
        } else if (isActivationKey) {
            dropdown.selectItem(dropdown.highlightIndex)
        } else if (event.key === Qt.Key_Escape) {
            popup.close()
        } else {
            return
        }
        event.accepted = true
    }

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
        color: dropArea.containsMouse || dropdown.activeFocus ? MoneroComponents.Style.titleBarButtonHoverColor : "transparent"
        border.width: dropdown.headerBorder ? 1 : 0
        border.color: dropdown.activeFocus ? MoneroComponents.Style.inputBorderColorActive : dropdown.colorBorder
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
            onClicked: {
                if (dropdown.expanded) {
                    popup.close()
                } else {
                    dropdown.forceActiveFocus()
                    dropdown.openPopup()
                }
            }
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
            height: dropdown.expanded ? Math.min(columnid.height, dropdown.maxAvailableDropdownHeight) : 0
            color: dropdown.pressedColor

            Behavior on height {
                NumberAnimation { duration: 100; easing.type: Easing.InQuad }
            }

            Flickable {
                id: dropFlickable
                anchors.fill: parent
                contentHeight: columnid.height
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                ScrollBar.vertical: ScrollBar { }

                Column {
                    id: columnid
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    property int currentIndex: 0

                    Repeater {
                        id: repeater

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
                            color: itemArea.containsMouse || index === dropdown.highlightIndex ? dropdown.releasedColor : dropdown.pressedColor

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
                                color: itemArea.containsMouse || index === dropdown.highlightIndex ? "#FA6800" : "#FFFFFF"
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

                                onClicked: dropdown.selectItem(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
