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
import QtQuick.Controls as Controls
import QtQuick.Layouts

import FontAwesome

import "." as MoneroComponents
import "effects/" as MoneroEffects

Item {
    id: datePicker
    readonly property alias expanded: popup.visible
    property date currentDate
    property bool showCurrentDate: true
    property color backgroundColor : MoneroComponents.Style.appWindowBorderColor
    property color errorColor : "red"
    property bool error: false
    property alias inputLabel: inputLabel

    signal dateChanged()

    height: 50

    onExpandedChanged: if(expanded) appWindow.currentItem = datePicker

    Rectangle {
        id: inputLabelRect
        color: "transparent"
        height: 22
        width: parent.width

        MoneroComponents.TextPlain {
            id: inputLabel
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: parent.left
            font.family: MoneroComponents.Style.fontLight.name
            font.pixelSize: 14
            font.bold: false
            textFormat: Text.RichText
            color: MoneroComponents.Style.defaultFontColor
            themeTransition: false

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }

    Item {
        id: head
        anchors.top: inputLabelRect.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right
        height: 28

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - 1
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            radius: 4
            y: 1
            color: datePicker.backgroundColor
        }

        RowLayout {
            id: dateInput
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.right: parent.right
            property string headerFontColor: MoneroComponents.Style.blackTheme ? "#e6e6e6" : "#333333"
            spacing: 0

            function setDate(date) {
                var day = date.getDate()
                var month = date.getMonth() + 1
                dayInput.text = day < 10 ? "0" + day : day
                monthInput.text = month < 10 ? "0" + month : month
                yearInput.text = date.getFullYear()
            }

            Connections {
                target: datePicker
                function onCurrentDateChanged() {
                    dateInput.setDate(datePicker.currentDate)
                }
            }

            TextInput {
                id: dayInput
                readOnly: true
                Layout.preferredWidth: childrenRect.width + 40
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : parent.headerFontColor
                selectionColor: MoneroComponents.Style.dimmedFontColor
                selectByMouse: true
                horizontalAlignment: TextInput.AlignHCenter
                maximumLength: 2
                validator: IntValidator{bottom: 01; top: 31;}
                KeyNavigation.tab: monthInput

                text: {
                    if(datePicker.showCurrentDate) {
                        var day = datePicker.currentDate.getDate()
                        return day < 10 ? "0" + day : day
                    }
                }
                onFocusChanged: {
                    if(focus === false) {
                        if(text.length === 0 || text === "0" || text === "00") text = "01"
                        else if(text.length === 1) text = "0" + text
                    }
                }
            }

            MoneroComponents.TextPlain {
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : MoneroComponents.Style.defaultFontColor
                text: "-"
                themeTransition: false
            }

            TextInput {
                id: monthInput
                readOnly: true
                Layout.preferredWidth: childrenRect.width + 40
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : parent.headerFontColor
                selectionColor: MoneroComponents.Style.dimmedFontColor
                selectByMouse: true
                horizontalAlignment: TextInput.AlignHCenter
                maximumLength: 2
                validator: IntValidator{bottom: 01; top: 12;}
                KeyNavigation.tab: yearInput
                text: {
                    if(datePicker.showCurrentDate) {
                        var month = datePicker.currentDate.getMonth() + 1
                        return month < 10 ? "0" + month : month
                    }
                }
                onFocusChanged: {
                    if(focus === false) {
                        if(text.length === 0 || text === "0" || text === "00") text = "01"
                        else if(text.length === 1) text = "0" + text
                    }
                }
            }

            MoneroComponents.TextPlain {
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : MoneroComponents.Style.defaultFontColor
                text: "-"
                themeTransition: false
            }

            TextInput {
                id: yearInput
                Layout.preferredWidth: childrenRect.width + 60
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : parent.headerFontColor
                selectionColor: MoneroComponents.Style.dimmedFontColor
                selectByMouse: true
                horizontalAlignment: TextInput.AlignHCenter
                maximumLength: 4
                validator: IntValidator{bottom: 1000; top: 9999;}
                text: if(datePicker.showCurrentDate) datePicker.currentDate.getFullYear()

                onFocusChanged: {
                    if(focus === false) {
                        var d = new Date()
                        var y = d.getFullYear()
                        if(text.length != 4 || text[0] === "0")
                            text = y
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: parent.height
                Layout.fillWidth: true
                color: "transparent"

                MoneroEffects.ImageMask {
                    id: button
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    image: "qrc:///images/whiteDropIndicator.png"
                    height: 8
                    width: 12
                    fontAwesomeFallbackIcon: FontAwesome.arrowDown
                    fontAwesomeFallbackSize: 14
                    color: MoneroComponents.Style.defaultFontColor
                    rotation: datePicker.expanded ? 180 : 0
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: datePicker.expanded ? popup.close() : popup.open()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    Controls.Popup {
        id: popup
        padding: 0
        closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutsideParent
        onOpened: {
            calendar.visibleMonth = currentDate.getMonth();
            calendar.visibleYear = currentDate.getFullYear();
        }

        Rectangle {
            id: calendarRect
            width: head.width
            x: head.x
            y: head.y + head.height - 2

            color: MoneroComponents.Style.middlePanelBackgroundColor
            border.width: 1
            border.color: MoneroComponents.Style.appWindowBorderColor
            height: datePicker.expanded ? calendar.height + 2 : 0
            clip: true

            Behavior on height {
                NumberAnimation { duration: 150; easing.type: Easing.InQuad }
            }

            MouseArea {
                anchors.fill: parent
                scrollGestureEnabled: false
                onWheel: {
                    if (wheel.angleDelta.y > 0) return calendar.showPreviousMonth();
                    if (wheel.angleDelta.y < 0) return calendar.showNextMonth();
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                anchors.top: parent.top
                color: MoneroComponents.Style.appWindowBorderColor
                height: 1
            }

            MoneroComponents.MoneroCalendar {
                id: calendar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 1
                anchors.bottomMargin: 10
                height: 220
                selectedDate: datePicker.currentDate
                onDateSelected: function(selectedDate) {
                    datePicker.currentDate = selectedDate
                    popup.close()
                    datePicker.dateChanged()
                }
            }
        }
    }
}
