import QtQuick 2.0

Item {
    id: dropdown
    property bool expanded: false
    property alias dataModel: repeater.model
    signal collapsed()
    signal optionClicked(int option)
    width: 72
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
        if(py > height + dropArea.height)
            return false
        return true
    }

    Item {
        id: head
        anchors.fill: parent

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - 1
            y: dropdown.expanded || dropArea.height > 0 ? 0 : 1
            radius: 3
            color: dropdown.expanded || dropArea.height > 0 ? "#888888" : "#DBDBDB"
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - 1
            y: dropdown.expanded || dropArea.height > 0 ? 1 : 0
            radius: 3
            color: dropdown.expanded || dropArea.height > 0 ? "#DBDBDB" : "#F0EEEE"
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: 3
            width: 3
            color: "#DBDBDB"
            visible: dropdown.expanded || dropArea.height > 0
        }

        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 3
            width: 3
            color: "#DBDBDB"
            visible: dropdown.expanded || dropArea.height > 0
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            source: "../images/tableOptions.png"
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 1
            height: 23
            width: 1
            color: dropdown.expanded || dropArea.height > 0 ? "#FFFFFF" : "#DBDBDB"
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            source: "../images/dropIndicator.png"
        }
    }

    MouseArea {
        anchors.left: head.left
        anchors.right: head.right
        anchors.top: head.top
        height: head.height + dropArea.height
        hoverEnabled: true
        onEntered: dropdown.expanded = true
        onExited: dropdown.expanded = false
        preventStealing: true
        z: 1

        Item {
            id: dropArea
            anchors.left: parent.left
            anchors.right: parent.right
            y: head.height
            height: dropdown.expanded ? column.height : 0
            onHeightChanged: if(height === 0) dropdown.collapsed()
            clip: true

            Behavior on height {
                NumberAnimation { duration: 100; easing.type: Easing.InQuad }
            }

            Column {
                id: column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                Repeater {
                    id: repeater
                    delegate: Rectangle {
                        id: delegate
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 30
                        color: delegateArea.containsMouse ? "#F0EEEE" : "#DBDBDB"
                        radius: index === repeater.count - 1 ? 5 : 0

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            width: 5
                            height: 5
                            color: delegate.color
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            width: 5
                            height: 5
                            color: delegate.color
                        }

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            source: icon
                        }

                        MouseArea {
                            id: delegateArea
                            hoverEnabled: true
                            anchors.fill: parent
                            propagateComposedEvents: true
                            onEntered: {
                                var pos = rootItem.mapFromItem(delegate, 30, -20)
                                tipItem.text = name
                                tipItem.x = pos.x
                                if(tipItem.height > 30)
                                    pos.y -= tipItem.height - 30
                                tipItem.y = pos.y
                                tipItem.visible = true
                            }
                            onExited: tipItem.visible = false
                            onClicked: {
                                dropdown.optionClicked(index)
                                tipItem.visible = false
                                dropdown.expanded = false
                            }
                        }
                    }
                }
            }
        }
    }
}
