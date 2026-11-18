import QtQuick
import QtQuick.Layouts

import "../components" as MoneroComponents

GridLayout {
    id: advancedOptionsItem

    property alias title: title.text
    property alias tooltip: title.tooltip
    property alias button1: button1
    property alias button2: button2
    property alias button3: button3
    // Measure the inner text: the outer Label's width is overwritten by the layout
    readonly property int titleImplicitWidth: title.textWidth + title.tooltipWidth + titlecolumn.spacing
    readonly property int buttonsImplicitWidth: buttonsRow.implicitWidth
    property int titleWidth: {
        var width = 195;
        var siblings = parent ? parent.children : [];
        for (var i = 0; i < siblings.length; ++i) {
            if (siblings[i].titleImplicitWidth !== undefined) {
                width = Math.max(width, siblings[i].titleImplicitWidth);
            }
        }
        return width;
    }
    // Move the buttons below the titles when any row doesn't fit next to the shared title column
    readonly property bool stacked: {
        var buttonsWidth = 0;
        var siblings = parent ? parent.children : [];
        for (var i = 0; i < siblings.length; ++i) {
            if (siblings[i].buttonsImplicitWidth !== undefined) {
                buttonsWidth = Math.max(buttonsWidth, siblings[i].buttonsImplicitWidth);
            }
        }
        return parent && parent.width > 0 &&
               titlecolumn.Layout.leftMargin + titleWidth + columnSpacing + buttonsWidth > parent.width;
    }
    columns: stacked ? 1 : 2

    RowLayout {
        id: titlecolumn
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        Layout.preferredWidth: advancedOptionsItem.stacked ? advancedOptionsItem.titleImplicitWidth : advancedOptionsItem.titleWidth
        Layout.maximumWidth: Layout.preferredWidth
        Layout.leftMargin: 10

        MoneroComponents.Label {
            id: title
            Layout.preferredWidth: title.textWidth
            fontSize: 14
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
        Layout.leftMargin: advancedOptionsItem.stacked ? 10 : 0
        spacing: 4

        RowLayout {
            id: buttonsRow
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
