import QtQuick 2.0

Item {
    id: dropdown
    property alias dataModel: repeater.model
    property string shadowPressedColor
    property string shadowReleasedColor
    property string pressedColor
    property string releasedColor
    property string textColor: "#FFFFFF"
    property alias currentIndex: column.currentIndex
    property bool expanded: false
    height: 37

    onExpandedChanged: if(expanded) appWindow.currentItem = dropdown
    function hide() { dropdown.expanded = false }
    function containsPoint(px, py) {
        if(px < 0)
            return false
        if(px > width)
            return false
        if(py < 0)
            return false
        if(py > height + droplist.height)
            return false
        return true
    }

    Item {
        id: head
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 37

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - 1
            y: dropdown.expanded || droplist.height > 0 ? 0 : 1
            color: dropdown.expanded || droplist.height > 0 ? dropdown.shadowPressedColor : dropdown.shadowReleasedColor
            radius: 4
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - 1
            y: dropdown.expanded || droplist.height > 0 ? 1 : 0
            color: dropdown.expanded || droplist.height > 0 ? dropdown.pressedColor : dropdown.releasedColor
            radius: 4
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: 3
            width: 3
            color: dropdown.pressedColor
            visible: dropdown.expanded || droplist.height > 0
        }

        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 3
            width: 3
            color: dropdown.pressedColor
            visible: dropdown.expanded || droplist.height > 0
        }

        Text {
            id: firstColText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            elide: Text.ElideRight
            font.family: "Arial"
            font.bold: true
            font.pixelSize: 12
            color: "#FFFFFF"
            text: repeater.model.get(column.currentIndex).column1
        }

        Text {
            id: secondColText
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: separator.left
            anchors.rightMargin: 12
            width: dropdown.expanded ? w : (separator.x - 12) - (firstColText.x + firstColText.width + 5)
            font.family: "Arial"
            font.pixelSize: 12
            color: "#FFFFFF"
            text: repeater.model.get(column.currentIndex).column2

            property int w: 0
            Component.onCompleted: w = implicitWidth
        }

        Rectangle {
            id: separator
            anchors.right: dropIndicator.left
            anchors.verticalCenter: parent.verticalCenter
            height: 18
            width: 1
            color: "#FFFFFF"
        }

        Item {
            id: dropIndicator
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 32

            Image {
                anchors.centerIn: parent
                source: "../images/whiteDropIndicator.png"
                rotation: dropdown.expanded ? 180 : 0
            }
        }

        MouseArea {
            id: dropArea
            anchors.fill: parent
            onClicked: dropdown.expanded = !dropdown.expanded
        }
    }

    Rectangle {
        id: droplist
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        clip: true
        height: dropdown.expanded ? column.height : 0
        color: dropdown.pressedColor
        radius: 4

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: 3; height: 3
            color: dropdown.pressedColor
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: 3; height: 3
            color: dropdown.pressedColor
        }

        Behavior on height {
            NumberAnimation { duration: 100; easing.type: Easing.InQuad }
        }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            property int currentIndex: 0

            Repeater {
                id: repeater

                delegate: Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 30
                    radius: index === repeater.count - 1 ? 4 : 0
                    color: itemArea.containsMouse || index === column.currentIndex || itemArea.containsMouse ? dropdown.releasedColor : dropdown.pressedColor

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: col2Text.left
                        anchors.leftMargin: 12
                        anchors.rightMargin: column2.length > 0 ? 12 : 0
                        font.family: "Arial"
                        font.bold: true
                        font.pixelSize: 12
                        color: "#FFFFFF"
                        text: column1
                    }

                    Text {
                        id: col2Text
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 45
                        font.family: "Arial"
                        font.pixelSize: 12
                        color: "#FFFFFF"
                        text: column2
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 3; height: 3
                        color: parent.color
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        width: 3; height: 3
                        color: parent.color
                    }

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            dropdown.expanded = false
                            column.currentIndex = index
                        }
                    }
                }
            }
        }
    }
}
