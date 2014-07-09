import QtQuick 2.0

Rectangle {
    id: header
    signal sortRequest(bool desc, int column)
    property alias dataModel: columnsRepeater.model
    property int activeSortColumn: -1

    height: 31
    color: "#FFFFFF"

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#DBDBDB"
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            height: 31
            width: 1
            color: "#DBDBDB"
        }

        Repeater {
            id: columnsRepeater
            delegate: Rectangle {
                id: delegate
                property bool desc: false
                height: 31
                width: columnWidth

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 13
                    anchors.rightMargin: 13
                    elide: Text.ElideRight
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: {
                        if(delegateArea.pressed)
                            return "#FF4304"
                        return index === header.activeSortColumn || delegateArea.containsMouse ? "#FF6C3C" : "#4A4949"
                    }
                    text: columnName
                }

                MouseArea {
                    id: delegateArea
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        delegate.desc = !delegate.desc
                        header.activeSortColumn = index
                        header.sortRequest(delegate.desc, index)
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 9

                    Item {
                        width: 14
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        Image {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -2
                            source: {
                                if(descArea.pressed)
                                    return "../images/descSortIndicatorPressed.png"
                                return index === header.activeSortColumn || descArea.containsMouse ? "../images/descSortIndicatorActived.png" :
                                                                                                     "../images/descSortIndicator.png"
                            }
                        }

                        MouseArea {
                            id: descArea
                            hoverEnabled: true
                            anchors.fill: parent
                            onClicked: {
                                delegate.desc = true
                                header.activeSortColumn = index
                                header.sortRequest(delegate.desc, index)
                            }
                        }
                    }

                    Item {
                        width: 14
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        Image {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -3
                            source: {
                                if(ascArea.pressed)
                                    return "../images/ascSortIndicatorPressed.png"
                                return index === header.activeSortColumn || ascArea.containsMouse ? "../images/ascSortIndicatorActived.png" :
                                                                                                    "../images/ascSortIndicator.png"
                            }
                        }

                        MouseArea {
                            id: ascArea
                            hoverEnabled: true
                            anchors.fill: parent
                            onClicked: {
                                delegate.desc = false
                                header.activeSortColumn = index
                                header.sortRequest(delegate.desc, index)
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: index === header.activeSortColumn ? "#FFFFFF" : "#DBDBDB"
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    color: "#DBDBDB"
                }
            }
        }
    }
}
