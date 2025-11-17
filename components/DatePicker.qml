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
// Qt6: Calendar moved from QtQuick.Controls to Qt.labs.calendar
import Qt.labs.calendar 1.0
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

            Calendar {
                id: calendar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 1
                anchors.bottomMargin: 10
                height: 220
                frameVisible: false

                // Qt6: CalendarStyle removed, use Calendar properties and delegate directly
                background: Rectangle { color: MoneroComponents.Style.middlePanelBackgroundColor }
                delegate: Item {
                    z: parent.z + 1
                    implicitHeight: implicitWidth
                    implicitWidth: calendar.width / 7

                    // Qt6: Calendar delegate receives model.date, model.today, model.sameMonth, model.selected
                    property date delegateDate: model.date
                    property bool isToday: model.today
                    property bool sameMonth: model.sameMonth
                    property bool isSelected: model.selected

                    Rectangle {
                        id: dayRect
                        anchors.fill: parent
                        radius: parent.implicitHeight / 2
                    }

                    MoneroComponents.TextPlain {
                        id: dayText
                        anchors.centerIn: parent
                        font.family: MoneroComponents.Style.fontMonoRegular.name
                        font.pixelSize: {
                            if(!sameMonth) return 12
                            return 14
                        }
                        font.bold: {
                            if(dayArea.pressed || sameMonth) return true;
                            return false;
                        }
                        text: delegateDate.getDate()
                        themeTransition: false
                        color: {
                            if (currentDate.toDateString() === delegateDate.toDateString()) {
                                if (dayArea.containsMouse) {
                                    dayRect.color = MoneroComponents.Style.buttonBackgroundColorHover;
                                } else {
                                    dayRect.color = MoneroComponents.Style.buttonBackgroundColor;
                                }
                            } else {
                                if (dayArea.containsMouse) {
                                    dayRect.color = MoneroComponents.Style.blackTheme ? "#20FFFFFF" : "#10000000"
                                } else {
                                    dayRect.color = "transparent";
                                }
                            }
                            if(!sameMonth) return MoneroComponents.Style.lightGreyFontColor
                            if(isToday) return "#FFFF00"
                            if(dayArea.pressed) return MoneroComponents.Style.defaultFontColor
                            return MoneroComponents.Style.defaultFontColor
                        }
                    }

                    MouseArea {
                        id: dayArea
                        anchors.fill: parent
                        visible: sameMonth
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(sameMonth) {
                                currentDate = delegateDate
                                popup.close()
                            } else {
                                var date = delegateDate
                                if(date.getMonth() > calendar.visibleMonth)
                                    calendar.showNextMonth()
                                else calendar.showPreviousMonth()
                            }

                            datePicker.dateChanged();
                        }
                    }

                    dayOfWeekDelegate: Item {
                        implicitHeight: 20
                        implicitWidth: calendar.width / 7

                        MoneroComponents.TextPlain {
                            anchors.centerIn: parent
                            elide: Text.ElideRight
                            font.family: MoneroComponents.Style.fontMonoRegular.name
                            font.pixelSize: 12
                            color: MoneroComponents.Style.lightGreyFontColor
                            themeTransition: false
                            text: {
                                var locale = Qt.locale()
                                return locale.dayName(styleData.dayOfWeek, Locale.ShortFormat)
                            }
                        }
                    }

                    navigationBar: Rectangle {
                        color: MoneroComponents.Style.middlePanelBackgroundColor
                        implicitWidth: calendar.width
                        implicitHeight: 30

                        MoneroComponents.TextPlain {
                            anchors.centerIn: parent
                            font.family: MoneroComponents.Style.fontMonoRegular.name
                            font.pixelSize: 14
                            color: MoneroComponents.Style.dimmedFontColor
                            themeTransition: false
                            text: styleData.title
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
                                onClicked: calendar.showPreviousMonth()
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
                                onClicked: calendar.showNextMonth()
                            }
                        }
                    }
                }
            }
        }
    }
}
