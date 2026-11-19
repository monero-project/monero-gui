import QtQuick
import QtQuick.Layouts

import "../components" as MoneroComponents

GridLayout {
    id: advancedOptionsItem

    property alias title: title.text
    property alias tooltip: title.tooltip
    default property alias buttons: buttonFlow.children
    required property real titleColumnWidth
    required property bool stacked
    readonly property alias implicitTitleWidth: title.implicitWidth

    // Keep the two-column size hint stable when the parent stacks the rows.
    Layout.preferredWidth: titleColumnWidth + columnSpacing + buttonFlow.Layout.preferredWidth
    columns: stacked ? 1 : 2

    MoneroComponents.Label {
        id: title
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        Layout.preferredWidth: advancedOptionsItem.stacked ? implicitWidth : advancedOptionsItem.titleColumnWidth
        implicitWidth: textWidth + tooltipIconWidth
        fontSize: 14
        tooltipIconVisible: true
    }

    Flow {
        id: buttonFlow
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        spacing: 12
        Layout.preferredWidth: {
            const actions = Array.from(visibleChildren)
            return actions.reduce((sum, button) => sum + button.implicitWidth, 0)
                    + Math.max(0, actions.length - 1) * spacing
        }
    }
}
