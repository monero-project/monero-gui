// Copyright (c) 2019-2019, Nejcraft
// Copyright (c) 2014-2018, The NejCoin Project
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
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.2

import "." as NejCoinComponents
import "effects/" as NejCoinEffects

Item {
    id: datePicker
    z: parent.z + 1
    property bool expanded: false
    property date currentDate
    property bool showCurrentDate: true
    property color backgroundColor : NejCoinComponents.Style.appWindowBorderColor
    property color errorColor : "red"
    property bool error: false
    property alias inputLabel: inputLabel

    signal dateChanged();

    height: 50

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

    Rectangle {
        id: inputLabelRect
        color: "transparent"
        height: 22
        width: parent.width

        NejCoinComponents.TextPlain {
            id: inputLabel
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: parent.left
            font.family: NejCoinComponents.Style.fontLight.name
            font.pixelSize: 14
            font.bold: false
            textFormat: Text.RichText
            color: NejCoinComponents.Style.defaultFontColor
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
            anchors.leftMargin: datePicker.expanded ? 1 : 0
            anchors.rightMargin: datePicker.expanded ? 1 : 0
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
            property string headerFontColor: NejCoinComponents.Style.blackTheme ? "#e6e6e6" : "#333333"
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
                onCurrentDateChanged: {
                    dateInput.setDate(datePicker.currentDate)
                }
            }

            TextInput {
                id: dayInput
                readOnly: true
                Layout.preferredWidth: childrenRect.width + 40
                font.family: NejCoinComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : parent.headerFontColor
                selectionColor: NejCoinComponents.Style.dimmedFontColor
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

            NejCoinComponents.TextPlain {
                font.family: NejCoinComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : NejCoinComponents.Style.defaultFontColor
                text: "-"
                themeTransition: false
            }

            TextInput {
                id: monthInput
                readOnly: true
                Layout.preferredWidth: childrenRect.width + 40
                font.family: NejCoinComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : parent.headerFontColor
                selectionColor: NejCoinComponents.Style.dimmedFontColor
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

            NejCoinComponents.TextPlain {
                font.family: NejCoinComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : NejCoinComponents.Style.defaultFontColor
                text: "-"
                themeTransition: false
            }

            TextInput {
                id: yearInput
                Layout.preferredWidth: childrenRect.width + 60
                font.family: NejCoinComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: datePicker.error ? errorColor : parent.headerFontColor
                selectionColor: NejCoinComponents.Style.dimmedFontColor
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

                Image {
                    id: button
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:///images/whiteDropIndicator.png"
                    visible: false
                }

                ColorOverlay {
                    source: button
                    anchors.fill: button
                    color: NejCoinComponents.Style.defaultFontColor
                    rotation: datePicker.expanded ? 180 : 0
                    opacity: 1
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: datePicker.expanded = !datePicker.expanded
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    Rectangle {
        id: calendarRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        anchors.topMargin: 10
        color: NejCoinComponents.Style.middlePanelBackgroundColor
        border.width: 1
        border.color: NejCoinComponents.Style.appWindowBorderColor
        height: datePicker.expanded ? calendar.height + 2 : 0
        clip: true

        Behavior on height {
            NumberAnimation { duration: 100; easing.type: Easing.InQuad }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.top: parent.top
            color: NejCoinComponents.Style.appWindowBorderColor
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

            style: CalendarStyle {
                gridVisible: false
                background: Rectangle { color: NejCoinComponents.Style.middlePanelBackgroundColor }
                dayDelegate: Item {
                    z: parent.z + 1
                    implicitHeight: implicitWidth
                    implicitWidth: calendar.width / 7

                    Rectangle {
                        id: dayRect
                        anchors.fill: parent
                        radius: parent.implicitHeight / 2
                        color: {
                            if(dayArea.pressed && styleData.visibleMonth)
                                return NejCoinComponents.Style.blackTheme ? "#20FFFFFF" : "#10000000"
                            return "transparent";
                        }
                    }

                    NejCoinComponents.TextPlain {
                        id: dayText
                        anchors.centerIn: parent
                        font.family: NejCoinComponents.Style.fontMonoRegular.name
                        font.pixelSize: {
                            if(!styleData.visibleMonth) return 12
                            return 14
                        }
                        font.bold: {
                            if(dayArea.pressed || styleData.visibleMonth) return true;
                            return false;
                        }
                        text: styleData.date.getDate()
                        themeTransition: false
                        color: {
                            if(!styleData.visibleMonth) return NejCoinComponents.Style.lightGreyFontColor
                            if(dayArea.pressed) return NejCoinComponents.Style.defaultFontColor
                            if(styleData.today) return NejCoinComponents.Style.orange
                            return NejCoinComponents.Style.defaultFontColor
                        }
                    }

                    MouseArea {
                        id: dayArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: dayRect.color = NejCoinComponents.Style.blackTheme ? "#20FFFFFF" : "#10000000"
                        onExited: dayRect.color = "transparent"
                        cursorShape: Qt.PointingHandCursor
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

                            datePicker.dateChanged();
                        }
                    }
                }

                dayOfWeekDelegate: Item {
                    implicitHeight: 20
                    implicitWidth: calendar.width / 7

                    NejCoinComponents.TextPlain {
                        anchors.centerIn: parent
                        elide: Text.ElideRight
                        font.family: NejCoinComponents.Style.fontMonoRegular.name
                        font.pixelSize: 12
                        color: NejCoinComponents.Style.lightGreyFontColor
                        themeTransition: false
                        text: {
                            var locale = Qt.locale()
                            return locale.dayName(styleData.dayOfWeek, Locale.ShortFormat)
                        }
                    }
                }

                navigationBar: Rectangle {
                    color: NejCoinComponents.Style.middlePanelBackgroundColor
                    implicitWidth: calendar.width
                    implicitHeight: 30

                    NejCoinComponents.TextPlain {
                        anchors.centerIn: parent
                        font.family: NejCoinComponents.Style.fontMonoRegular.name
                        font.pixelSize: 14
                        color: NejCoinComponents.Style.dimmedFontColor
                        themeTransition: false
                        text: styleData.title
                    }


                    Item {
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: height

                        Image {
                            id: prevMonthIcon
                            anchors.centerIn: parent
                            source: "qrc:///images/prevMonth.png"
                            visible: false
                        }

                        ColorOverlay {
                            source: prevMonthIcon
                            anchors.fill: prevMonthIcon
                            color: NejCoinComponents.Style.defaultFontColor
                            opacity: 0.5
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

                        Image {
                            id: nextMonthIcon
                            anchors.centerIn: parent
                            source: "qrc:///images/prevMonth.png"
                            visible: false
                        }

                        ColorOverlay {
                            source: nextMonthIcon
                            anchors.fill: nextMonthIcon
                            color: NejCoinComponents.Style.defaultFontColor
                            opacity: 0.5
                            rotation: 180
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
