// Copyright (c) 2026, The Monero Project
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

import "." as MoneroComponents

Item {
    id: root

    property int visibleMonth: (new Date()).getMonth()
    property int visibleYear: (new Date()).getFullYear()
    property date selectedDate

    signal dateSelected(date selectedDate)

    function moveMonth(offset) {
        const date = new Date(visibleYear, visibleMonth + offset, 1)
        visibleMonth = date.getMonth()
        visibleYear = date.getFullYear()
    }

    function showPreviousMonth() {
        moveMonth(-1)
    }

    function showNextMonth() {
        moveMonth(1)
    }

    Rectangle {
        anchors.fill: parent
        color: MoneroComponents.Style.middlePanelBackgroundColor

        Column {
            anchors.fill: parent

            Rectangle {
                width: parent.width
                height: 30
                color: MoneroComponents.Style.middlePanelBackgroundColor

                MoneroComponents.TextPlain {
                    anchors.centerIn: parent
                    font.family: MoneroComponents.Style.fontMonoRegular.name
                    font.pixelSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                    themeTransition: false
                    text: Qt.locale().standaloneMonthName(root.visibleMonth, Locale.LongFormat)
                          + " " + root.visibleYear
                }

                MoneroComponents.TextPlain {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\u2039"
                    font.pixelSize: 22
                    color: MoneroComponents.Style.defaultFontColor

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showPreviousMonth()
                    }
                }

                MoneroComponents.TextPlain {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\u203a"
                    font.pixelSize: 22
                    color: MoneroComponents.Style.defaultFontColor

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showNextMonth()
                    }
                }
            }

            DayOfWeekRow {
                width: parent.width
                height: 20
                locale: Qt.locale()

                delegate: MoneroComponents.TextPlain {
                    required property var model
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: MoneroComponents.Style.fontMonoRegular.name
                    font.pixelSize: 12
                    color: MoneroComponents.Style.lightGreyFontColor
                    themeTransition: false
                    text: model.shortName
                }
            }

            MonthGrid {
                id: monthGrid
                width: parent.width
                height: parent.height - 50
                month: root.visibleMonth
                year: root.visibleYear
                locale: Qt.locale()

                delegate: Item {
                    required property var model

                    Rectangle {
                        id: dayBackground
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height)
                        height: width
                        radius: width / 2
                        color: {
                            if (root.selectedDate
                                    && root.selectedDate.toDateString() === model.date.toDateString())
                                return MoneroComponents.Style.buttonBackgroundColor
                            if (dayArea.containsMouse)
                                return MoneroComponents.Style.blackTheme ? "#20FFFFFF" : "#10000000"
                            return "transparent"
                        }
                    }

                    MoneroComponents.TextPlain {
                        anchors.centerIn: parent
                        font.family: MoneroComponents.Style.fontMonoRegular.name
                        font.pixelSize: model.month === root.visibleMonth ? 14 : 12
                        font.bold: model.month === root.visibleMonth
                        color: {
                            if (model.today)
                                return "#FFFF00"
                            if (model.month !== root.visibleMonth)
                                return MoneroComponents.Style.lightGreyFontColor
                            return MoneroComponents.Style.defaultFontColor
                        }
                        text: model.day
                        themeTransition: false
                    }

                    MouseArea {
                        id: dayArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (model.month !== root.visibleMonth) {
                                if (model.date < new Date(root.visibleYear, root.visibleMonth, 1))
                                    root.showPreviousMonth()
                                else
                                    root.showNextMonth()
                                return
                            }
                            root.dateSelected(model.date)
                        }
                    }
                }
            }
        }
    }
}
