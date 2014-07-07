import QtQuick 2.0

Rectangle {
    id: button
    property alias text: label.text
    property bool checked: false
    property alias dotColor: dot.color
    property alias symbol: symbolText.text
    signal clicked()

    height: 64
    color: checked ? "#FFFFFF" : "#1C1C1C"

    Item {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 50

        Rectangle {
            id: dot
            anchors.centerIn: parent
            width: 16
            height: width
            radius: height / 2

            Rectangle {
                anchors.centerIn: parent
                width: 12
                height: width
                radius: height / 2
                color: "#1C1C1C"
                visible: !button.checked && !buttonArea.containsMouse
            }
        }

        Text {
            id: symbolText
            anchors.centerIn: parent
            font.pixelSize: 11
            font.bold: true
            color: button.checked || buttonArea.containsMouse ? "#FFFFFF" : dot.color
            visible: appWindow.ctrlPressed
        }
    }

    Image {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20
        source: "../images/menuIndicator.png"
    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 50
        font.family: "Arial"
        font.pixelSize: 18
        color: parent.checked ? "#000000" : "#FFFFFF"
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if(parent.checked)
                return
            button.clicked()
            parent.checked = true
        }
    }
}
