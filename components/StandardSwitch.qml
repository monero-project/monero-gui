import QtQuick 2.9
import QtQuick.Layouts 1.1
import "." as MoneroComponents

Item {
    id: toggleSwitch
    property alias text: label.text
    property bool checked: false
    property bool enabled: true
    signal clicked()

    height: 24
    width: layout.width

    RowLayout {
        id: layout
        spacing: 10

        // The Switch Track
        Rectangle {
            id: indicator
            width: 36
            height: 14
            radius: 7
            color: toggleSwitch.checked ? MoneroComponents.Style.orange : MoneroComponents.Style.progressBarBackgroundColor
            opacity: toggleSwitch.enabled ? 1.0 : 0.5

            // The Thumb (Circle)
            Rectangle {
                id: knob
                width: 20
                height: 20
                radius: 10
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
                // Animate position
                x: toggleSwitch.checked ? parent.width - width : 0
                Behavior on x { NumberAnimation { duration: 150 } }

                // Shadow
                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "black"
                    opacity: 0.2
                    z: -1
                    anchors.topMargin: 1
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: toggleSwitch.enabled
                onClicked: {
                    toggleSwitch.checked = !toggleSwitch.checked;
                    toggleSwitch.clicked();
                }
            }
        }

        // Label
        MoneroComponents.TextPlain {
            id: label
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
            visible: text !== ""
        }
    }
}
