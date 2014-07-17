import QtQuick 2.0

Item {
    id: checkBox
    property alias text: label.text
    property bool checked: false
    signal clicked()
    height: 25
    width: label.x + label.width
    clip: true

    Rectangle {
        anchors.left: parent.left
        height: parent.height - 1
        width: 25
        //radius: 4
        y: 0
        color: "#DBDBDB"
    }

    Rectangle {
        anchors.left: parent.left
        height: parent.height - 1
        width: 25
        //radius: 4
        y: 1
        color: "#FFFFFF"

        Image {
            anchors.centerIn: parent
            source: checkBox.checked ? "../images/checkedIcon.png" :
                                       "../images/uncheckedIcon.png"
        }
    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 25 + 12
        font.family: "Arial"
        font.pixelSize: 14
        font.letterSpacing: -1
        color: "#525252"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            checkBox.checked = !checkBox.checked
            checkBox.clicked()
        }
    }
}
