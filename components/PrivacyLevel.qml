import QtQuick 2.0

Item {
    id: item
    property int fillLevel: 0
    height: 70
    clip: true

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 24
        radius: 4
        color: "#DBDBDB"
    }

    Rectangle {
        id: bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 1
        height: 24
        radius: 4
        color: "#FFFFFF"

        Rectangle {
            id: fillRect
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 4
            radius: 2
            width: row.x

            color: {
                if(item.fillLevel < 3) return "#FF6C3C"
                if(item.fillLevel < 13) return "#FFE00A"
                return "#36B25C"
            }

            Timer {
                interval: 500
                running: true
                repeat: false
                onTriggered: fillRect.loaded = true
            }

            property bool loaded: false
            Behavior on width {
                enabled: fillRect.loaded
                NumberAnimation { duration: 100; easing.type: Easing.InQuad }
            }
        }

        MouseArea {
            anchors.fill: parent
            function positionBar() {
                var xDiff = 999999
                var index = -1
                for(var i = 0; i < 14; ++i) {
                    var tmp = Math.abs(row.positions[i].currentX + row.x - mouseX)
                    if(tmp < xDiff) {
                        xDiff = tmp
                        index = i
                    }
                }

                if(index !== -1) {
                    fillRect.width = Qt.binding(function(){ return row.positions[index].currentX + row.x })
                    item.fillLevel = index
                }
            }

            onClicked: positionBar()
            onMouseXChanged: positionBar()
        }
    }

    Row {
        id: row
        anchors.right: bar.right
        anchors.rightMargin: 8
        anchors.top: bar.bottom
        anchors.topMargin: -1
        property var positions: new Array()

        Row {
            id: row2
            spacing: ((bar.width - 8) / 2) / 4

            Repeater {
                model: 4

                delegate: TickDelegate {
                    id: delegateItem2
                    currentX: x + row2.x
                    currentIndex: index
                    mainTick: currentIndex === 0 || currentIndex === 3 || currentIndex === 13
                    Component.onCompleted: {
                        row.positions[currentIndex] = delegateItem2
                    }
                }
            }
        }

        Row {
            id: row1
            spacing: ((bar.width - 8) / 2) / 10

            Repeater {
                model: 10

                delegate: TickDelegate {
                    id: delegateItem1
                    currentX: x + row1.x
                    currentIndex: index + 4
                    mainTick: currentIndex === 0 || currentIndex === 3 || currentIndex === 13
                    Component.onCompleted: {
                        row.positions[currentIndex] = delegateItem1
                    }
                }
            }
        }
    }
}
