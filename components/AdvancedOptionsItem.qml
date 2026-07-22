import QtQuick 2.9
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

RowLayout {
    id: advancedOptionsItem

    property alias title: title.text
    property alias tooltip: title.tooltip
    property alias button1: button1
    property alias button2: button2
    property alias button3: button3

    RowLayout {
        id: titlecolumn
        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
        property var language: persistentSettings.language
        Layout.preferredWidth: language == "Deutsch" ? 280 : language == "Español" ? 250 : language == "Français" ? 235 : 220
        Layout.maximumWidth: language == "Deutsch" ? 280 : language == "Español" ? 250 : language == "Français" ? 235 : 220
        Layout.leftMargin: 10

        MoneroComponents.TextPlain {
            id: title
            tooltipIconVisible: true
        }

        Rectangle {
            id: separator
            Layout.fillWidth: true
            height: 10
            color: "transparent"
        }
    }

    ColumnLayout {
        Layout.fillWidth: false
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        spacing: 4

        RowLayout {
            Layout.fillWidth: false
            spacing: 12
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            StandardButton {
                id: button1
                small: true
                primary: false
                visible: button1.text
            }

            StandardButton {
                id: button2
                small: true
                primary: false
                visible: button2.text
            }

            StandardButton {
                id: button3
                small: true
                primary: false
                visible: button3.text
            }
        }
    }
}
