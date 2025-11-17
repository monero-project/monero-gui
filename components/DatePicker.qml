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

import QtQuick 6.6
import QtQuick.Controls 6.6
import QtQuick.Controls 6.6 as QtQuickControls2
import QtQuick.Layouts 6.6
import Qt5Compat.GraphicalEffects 6.0
import FontAwesome 1.0

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

    signal dateChanged();

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

    QtQuickControls2.Popup {
        id: popup
        padding: 0
        closePolicy: QtQuickControls2.Popup.CloseOnEscape | QtQuickControls2.Popup.CloseOnPressOutsideParent
        onOpened: {
            // Calendar will sync with currentDate via binding
        }

        Rectangle {
            id: calendarRect
            width: head.width
            x: head.x
            y: head.y + head.height - 2

            color: MoneroComponents.Style.middlePanelBackgroundColor
            border.width: 1
            border.color: MoneroComponents.Style.appWindowBorderColor
            height: datePicker.expanded ? (calendarContainer.height + navigationBar.height + 2) : 0
            clip: true

            Behavior on height {
                NumberAnimation { duration: 150; easing.type: Easing.InQuad }
            }

            MouseArea {
                anchors.fill: parent
                scrollGestureEnabled: false
                onWheel: {
                    if (wheel.angleDelta.y > 0) return calendarNav.showPreviousMonth();
                    if (wheel.angleDelta.y < 0) return calendarNav.showNextMonth();
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

            // Qt6: Custom Calendar component (Calendar removed from QtQuick.Controls)
            // Use inline Calendar component instead of Loader to avoid singleton issues
            Item {
                id: calendarContainer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 1
                anchors.bottomMargin: 10
                height: 220
                
                // Inline Calendar implementation
                property int visibleMonth: currentDate.getMonth()
                property int visibleYear: currentDate.getFullYear()
                property date selectedDate: currentDate
                
                function showNextMonth() {
                    if (visibleMonth === 11) {
                        visibleMonth = 0
                        visibleYear++
                    } else {
                        visibleMonth++
                    }
                }
                
                function showPreviousMonth() {
                    if (visibleMonth === 0) {
                        visibleMonth = 11
                        visibleYear--
                    } else {
                        visibleMonth--
                    }
                }
                
                function getFirstDayOfMonth() {
                    var date = new Date(visibleYear, visibleMonth, 1)
                    return date.getDay()
                }
                
                function getDaysInMonth() {
                    return new Date(visibleYear, visibleMonth + 1, 0).getDate()
                }
                
                function isToday(year, month, day) {
                    var today = new Date()
                    return year === today.getFullYear() && 
                           month === today.getMonth() && 
                           day === today.getDate()
                }
                
                function isSelected(year, month, day) {
                    return year === selectedDate.getFullYear() &&
                           month === selectedDate.getMonth() &&
                           day === selectedDate.getDate()
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: MoneroComponents.Style.middlePanelBackgroundColor
                }
                
                // Day of week headers
                Row {
                    id: dayOfWeekRow
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 20
                    spacing: 0
                    
                    Repeater {
                        model: 7
                        Item {
                            width: calendarContainer.width / 7
                            height: 20
                            
                            Text {
                                anchors.centerIn: parent
                                font.pixelSize: 12
                                color: "#888888"
                                text: {
                                    var dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                                    return dayNames[index]
                                }
                            }
                        }
                    }
                }
                
                // Calendar grid
                Grid {
                    id: calendarGrid
                    anchors.top: dayOfWeekRow.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    columns: 7
                    spacing: 0
                    
                    // Add empty cells for days before the first day of month
                    Repeater {
                        model: getFirstDayOfMonth()
                        Item {
                            width: calendarContainer.width / 7
                            height: (calendarContainer.height - 20) / 6
                        }
                    }
                    
                    // Days of the month
                    Repeater {
                        model: getDaysInMonth()
                        property int day: index + 1
                        
                        Item {
                            width: calendarContainer.width / 7
                            height: (calendarContainer.height - 20) / 6
                            
                            property bool isCurrentDay: isToday(visibleYear, visibleMonth, day)
                            property bool isSelectedDay: isSelected(visibleYear, visibleMonth, day)
                            
                            Rectangle {
                                id: dayRect
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: width / 2
                                color: {
                                    if (dayMouseArea.containsMouse) {
                                        if (isSelectedDay) {
                                            return MoneroComponents.Style.buttonBackgroundColor
                                        } else {
                                            return MoneroComponents.Style.blackTheme ? "#20FFFFFF" : "#10000000"
                                        }
                                    } else if (isSelectedDay) {
                                        return MoneroComponents.Style.buttonBackgroundColor
                                    } else {
                                        return "transparent"
                                    }
                                }
                            }
                            
                            Text {
                                id: dayText
                                anchors.centerIn: parent
                                font.pixelSize: 14
                                font.bold: isSelectedDay || isCurrentDay
                                text: day
                                color: {
                                    if (isCurrentDay && !isSelectedDay) {
                                        return "#FFFF00"
                                    } else if (isSelectedDay) {
                                        return "white"
                                    } else {
                                        return MoneroComponents.Style.defaultFontColor
                                    }
                                }
                            }
                            
                            MouseArea {
                                id: dayMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var date = new Date(visibleYear, visibleMonth, day)
                                    currentDate = date
                                    popup.close()
                                    datePicker.dateChanged()
                                }
                            }
                        }
                    }
                    
                    // Add empty cells for days after the last day of month
                    Repeater {
                        model: {
                            var firstDay = getFirstDayOfMonth()
                            var daysInMonth = getDaysInMonth()
                            var totalCells = Math.ceil((firstDay + daysInMonth) / 7) * 7
                            return Math.max(0, totalCells - firstDay - daysInMonth)
                        }
                        Item {
                            width: calendarContainer.width / 7
                            height: (calendarContainer.height - 20) / 6
                        }
                    }
                }
            }
            
            // Calendar navigation helper
            property var calendar: calendarContainer
            Item {
                id: calendarNav
                function showNextMonth() {
                    calendarContainer.showNextMonth()
                }
                function showPreviousMonth() {
                    calendarContainer.showPreviousMonth()
                }
            }
            
            // Navigation bar (month/year display and navigation buttons)
            Rectangle {
                id: navigationBar
                anchors.top: calendarContainer.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1
                height: 30
                color: MoneroComponents.Style.middlePanelBackgroundColor

                MoneroComponents.TextPlain {
                    anchors.centerIn: parent
                    font.family: MoneroComponents.Style.fontMonoRegular.name
                    font.pixelSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                    themeTransition: false
                    text: {
                        var monthNames = ["January", "February", "March", "April", "May", "June",
                                         "July", "August", "September", "October", "November", "December"]
                        return monthNames[calendarContainer.visibleMonth] + " " + calendarContainer.visibleYear
                    }
                }

                Item {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: height

                    MoneroEffects.ImageMask {
                        id: prevMonthIcon
                        anchors.centerIn: parent
                        image: "qrc:///images/prevMonth.png"
                        height: 8
                        width: 12
                        fontAwesomeFallbackIcon: FontAwesome.arrowLeft
                        fontAwesomeFallbackSize: 14
                        color: MoneroComponents.Style.defaultFontColor
                    }

                    MouseArea {
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: calendarNav.showPreviousMonth()
                    }
                }

                Item {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: height

                    MoneroEffects.ImageMask {
                        id: nextMonthIcon
                        anchors.centerIn: parent
                        image: "qrc:///images/prevMonth.png"
                        height: 8
                        width: 12
                        rotation: 180
                        fontAwesomeFallbackIcon: FontAwesome.arrowLeft
                        fontAwesomeFallbackSize: 14
                        color: MoneroComponents.Style.defaultFontColor
                    }

                    MouseArea {
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: calendarNav.showNextMonth()
                    }
                }
            }
        }
    }
}
