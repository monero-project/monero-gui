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
            color: {
                if(item.fillLevel < 3) return "#FF6C3C"
                if(item.fillLevel < repeater.count - 1) return "#FFE00A"
                return "#36B25C"
            }
            width: row.x
        }

        MouseArea {
            anchors.fill: parent
            function positionBar() {
                var xDiff = 999999
                var index = -1
                for(var i = 0; i < repeater.count; ++i) {
                    var tmp = Math.abs(repeater.modelItems[i].x + row.x - mouseX)
                    if(tmp < xDiff) {
                        xDiff = tmp
                        index = i
                    }
                }

                if(index !== -1) {
                    fillRect.width = Qt.binding(function(){ return repeater.modelItems[index].x + row.x; })
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
        spacing: ((bar.width - 8) / 2) / 10

        Repeater {
            id: repeater
            model: 14
            property var modelItems: new Array()

            delegate: Item {
                id: delegate
                width: 1
                height: 48
                property bool mainTick: index === 0 || index === 3 || index === repeater.count - 1

                Component.onCompleted: repeater.modelItems[index] = delegate

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    visible: parent.mainTick
                    source: "../images/privacyTick.png"

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        font.family: "Arial"
                        font.bold: true
                        font.pixelSize: 12
                        color: "#4A4949"
                        text: {
                            if(index === 0) return qsTr("LOW")
                            if(index === 3) return qsTr("MEDIUM")
                            if(index === repeater.count - 1) return qsTr("HIGH")
                            return ""
                        }
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 14
                    width: 1
                    color: "#DBDBDB"
                    height: index === 8 ? 16 : 8
                    visible: !parent.mainTick
                }
            }
        }
    }
}
