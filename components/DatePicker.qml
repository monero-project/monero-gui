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

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Item {
    id: datePicker
    property bool expanded: false
    property date currentDate
    property bool showCurrentDate: true
    property color backgroundColor : "#FFFFFF"
    property color errorColor : "#FFDDDD"
    property bool error: false

    height: 37
    width: 156

    onExpandedChanged: if(expanded) appWindow.currentItem = datePicker

    function hide() { datePicker.expanded = false }
    function containsPoint(px, py) {
        if(px < 0)
            return false
        if(px > width)
            return false
        if(py < 0)
            return false
        if(py > height + calendarRect.height)
            return false
        return true
    }

    Item {
        id: head
        anchors.fill: parent
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height
            //radius: 4
            y: 0
            color: "#DBDBDB"

        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - 1
            anchors.leftMargin: datePicker.expanded ? 1 : 0
            anchors.rightMargin: datePicker.expanded ? 1 : 0
            //radius: 4
            y: 1
            color: datePicker.error ? datePicker.errorColor : datePicker.backgroundColor
        }

        Item {
            id: buttonItem
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 4
            width: height

            StandardButton {
                id: button
                anchors.fill: parent
                shadowReleasedColor: "#DBDBDB"
                shadowPressedColor: "#888888"
                releasedColor: "#F0EEEE"
                pressedColor: "#DBDBDB"
                icon: "../images/datePicker.png"
                visible: !datePicker.expanded
                onClicked: datePicker.expanded = true
            }

            Image {
                anchors.centerIn: parent
                source: "../images/datePicker.png"
                visible: datePicker.expanded
            }

            MouseArea {
                anchors.fill: parent
                enabled: datePicker.expanded
                onClicked: datePicker.expanded = false
            }
        }

        Rectangle {
            id: separator
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: buttonItem.left
            anchors.rightMargin: 4
            height: 16
            width: 1
            color: "#DBDBDB"
            visible: datePicker.expanded
        }

        Row {
            id: dateInput
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10

            function setDate(date) {
                var day = date.getDate()
                var month = date.getMonth() + 1
                dayInput.text = day < 10 ? "0" + day : day
                monthInput.text = month < 10 ? "0" + month : month
                yearInput.text = date.getFullYear()
            }

            Connections {
                target: datePicker
                onCurrentDateChanged: {
                    dateInput.setDate(datePicker.currentDate)
                }
            }

            TextInput {
                id: dayInput
                readOnly: true
                width: 22
                font.family: "Arial"
                font.pixelSize: 18
                // color: "#525252"
                maximumLength: 2
                horizontalAlignment: TextInput.AlignHCenter
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

            Text {
                font.family: "Arial"
                font.pixelSize: 18
                // color: "#525252"
                text: "."
            }

            TextInput {
                id: monthInput
                readOnly: true
                width: 22
                font.family: "Arial"
                font.pixelSize: 18
                // color: "#525252"
                maximumLength: 2
                horizontalAlignment: TextInput.AlignHCenter
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

            Text {
                font.family: "Arial"
                font.pixelSize: 18
                // color: "#525252"
                text: "."
            }

            TextInput {
                id: yearInput
                width: 44
                font.family: "Arial"
                font.pixelSize: 18
                /// color: "#525252"
                maximumLength: 4
                horizontalAlignment: TextInput.AlignHCenter
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
        }
    }

    Rectangle {
        id: calendarRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        color: "#FFFFFF"
        border.width: 1
        border.color: "#DBDBDB"
        height: datePicker.expanded ? calendar.height + 2 : 0
        clip: true
        //radius: 4

        Behavior on height {
            NumberAnimation { duration: 100; easing.type: Easing.InQuad }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.top: parent.top
            color: "#FFFFFF"
            height: 1
        }

        Calendar {
            id: calendar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 1
            height: 180
            frameVisible: false

            style: CalendarStyle {
                gridVisible: false
                background: Rectangle { color: "transparent" }
                dayDelegate: Item {
                    implicitHeight: implicitWidth
                    implicitWidth: calendar.width / 7

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.implicitHeight / 2
                        color: dayArea.pressed && styleData.visibleMonth ? "#FF6C3B" : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        font.family: "Arial"
                        font.pixelSize: 12
                        font.bold: dayArea.pressed
                        text: styleData.date.getDate()
                        color: {
                            if(!styleData.visibleMonth) return "#DBDBDB"
                            if(dayArea.pressed) return "#FFFFFF"
                            if(styleData.today) return "#FF6C3B"
                            return "#4A4848"
                        }
                    }

                    MouseArea {
                        id: dayArea
                        anchors.fill: parent
                        onClicked: {
                            if(styleData.visibleMonth) {
                                currentDate = styleData.date
                                datePicker.expanded = false
                            } else {
                                var date = styleData.date
                                if(date.getMonth() > calendar.visibleMonth)
                                    calendar.showNextMonth()
                                else calendar.showPreviousMonth()
                            }
                        }
                    }
                }

                dayOfWeekDelegate: Item {
                    implicitHeight: 20
                    implicitWidth: calendar.width / 7

                    Text {
                        anchors.centerIn: parent
                        elide: Text.ElideRight
                        font.family: "Arial"
                        font.pixelSize: 9
                        color: "#535353"
                        text: {
                            var locale = Qt.locale()
                            return locale.dayName(styleData.dayOfWeek, Locale.ShortFormat)
                        }
                    }
                }

                navigationBar: Rectangle {
                    implicitWidth: calendar.width
                    implicitHeight: 30

                    Text {
                        anchors.centerIn: parent
                        font.family: "Arial"
                        font.pixelSize: 12
                        color: "#4A4646"
                        text: styleData.title
                    }

                    Item {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: height

                        Image {
                            anchors.centerIn: parent
                            source: "../images/prevMonth.png"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: calendar.showPreviousMonth()
                        }
                    }

                    Item {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: height

                        Image {
                            anchors.centerIn: parent
                            source: "../images/nextMonth.png"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: calendar.showNextMonth()
                        }
                    }
                }
            }
        }
    }
}
