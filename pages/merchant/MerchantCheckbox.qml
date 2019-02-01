import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0


RowLayout {
    id: root
    spacing: 10 * scaleRatio
    property bool checked: false;
    property alias text: content.text
    signal changed;

    Rectangle {
        id: checkbox
        anchors.left: parent.left
        anchors.top: parent.top
        implicitHeight: 22 * scaleRatio
        width: 22 * scaleRatio
        radius: 5

        Image {
            id: imageChecked
            visible: root.checked
            anchors.centerIn: parent
            source: "../../images/uncheckedIcon.png"
        }
    }

    Text {
        id: content
        font.pixelSize: 14 * scaleRatio
        font.bold: false
        color: "white"
        text: ""
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

    DropShadow {
        anchors.fill: source
        cached: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 16
        color: "#20000000"
        smooth: true
        source: checkbox
    }
}
