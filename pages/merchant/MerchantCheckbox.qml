import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import "../../components" as MoneroComponents

Item {
    id: root
    property bool checked: false;
    property alias text: content.text
    signal changed;

    width: checkBoxLayout.width
    height: 22

    RowLayout {
        id: checkBoxLayout
        spacing: 10

        Item {
            implicitHeight: root.height
            implicitWidth: root.height
            Rectangle {
                id: checkbox
                anchors.fill: parent
                radius: 5

                Image {
                    id: imageChecked
                    visible: root.checked
                    anchors.centerIn: parent
                    source: "qrc:///images/uncheckedIcon.png"
                }
            }
            MultiEffect {
                anchors.fill: source
                shadowHorizontalOffset: 3
                shadowVerticalOffset: 3
                shadowEnabled: true
                shadowBlur: 8
                shadowColor: "#20000000"
                smooth: true
                source: checkbox
            }
        }
        MoneroComponents.TextPlain {
            id: content
            font.pixelSize: 14
            font.bold: false
            color: "white"
            text: ""
            themeTransition: false
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked;
            changed();
        }
    }
}
