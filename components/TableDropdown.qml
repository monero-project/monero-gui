import QtQuick 2.0

Item {
    id: dropdown
    property bool expanded: false
    signal collapsed()
    width: 72
    height: 37

    Item {
        id: head
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: dropdown.expanded ? 0 : 1
            radius: 3
            color: dropdown.expanded ? "#888888" : "#DBDBDB"
        }

        Rectangle {
            anchors.fill: parent
            anchors.bottomMargin: dropdown.expanded ? 0 : 1
            radius: 3
            color: dropdown.expanded ? "#DBDBDB" : "#F0EEEE"
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
            color: dropdown.expanded ? "#FFFFFF" : "#DBDBDB"
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            source: "../images/dropIndicator.png"
        }

        MouseArea {
            anchors.fill: parent
            onPressed: dropdown.expanded = !dropdown.expanded
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
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

            ListModel {
                id: dataModel
                ListElement { name: "<b>text 1</b>"; icon: "../images/dropdownOption1.png" }
                ListElement { name: "<b>longer text 2</b>"; icon: "../images/dropdownSend.png" }
                ListElement { name: "<b>text3</b><br/><br/>lorem ipsum asdasd asdasd"; icon: "../images/dropdownSearch.png" }
            }

            Repeater {
                id: repeater
                model: dataModel

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
                    }
                }
            }
        }
    }
}
