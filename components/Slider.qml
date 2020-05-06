import QtQuick 2.9
import QtQuick.Controls 2.0 as QtQuickControls
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

ColumnLayout {
    property alias from: slider.from
    property alias stepSize: slider.stepSize
    property alias to: slider.to
    property alias value: slider.value

    property alias text: label.text

    signal moved()

    spacing: 0

    Text {
        id: label
        color: MoneroComponents.Style.defaultFontColor
        font.pixelSize: 14
        Layout.fillWidth: true
    }

    QtQuickControls.Slider {
        id: slider
        leftPadding: 0
        snapMode: QtQuickControls.Slider.SnapAlways

        background: Rectangle {
            x: parent.leftPadding
            y: parent.topPadding + parent.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 4
            width: parent.availableWidth
            height: implicitHeight
            radius: 2
            color: MoneroComponents.Style.progressBarBackgroundColor

            Rectangle {
                width: parent.visualPosition * parent.width
                height: parent.height
                color: MoneroComponents.Style.green
                radius: 2
            }
        }

        handle: Rectangle {
            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
            y: parent.topPadding + parent.availableHeight / 2 - height / 2
            implicitWidth: 18
            implicitHeight: 18
            radius: 8
            color: parent.pressed ? "#f0f0f0" : "#f6f6f6"
            border.color: MoneroComponents.Style.grey
        }

        onMoved: parent.moved()

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
