import QtQuick 2.0

Item {
    id: item
    signal searchClicked(string text, int option)
    height: 50

    Rectangle {
        anchors.fill: parent
        color: "#DBDBDB"
        radius: 10
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 1
        color: "#FFFFFF"
        radius: 10

        Item {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 45

            Image {
                anchors.centerIn: parent
                source: "../images/magnifier.png"
            }
        }

        Input {
            id: input
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: dropdown.left
            anchors.leftMargin: 45
            verticalAlignment: TextInput.AlignVCenter
            placeholderText: qsTr("Search by...")
        }

        Item {
            id: dropdown
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: button.left
            width: 154

            function hide() { droplist.height = 0 }
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

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: dropText
                    width: 114 - 12
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: "Arial"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: -1
                    color: "#4A4747"
                    text: "NAME"
                }

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../images/hseparator.png"
                }

                Item {
                    height: dropdown.height
                    width: 38

                    Image {
                        id: dropIndicator
                        anchors.centerIn: parent
                        source: "../images/dropIndicator.png"
                        rotation: droplist.height === 0 ? 0 : 180
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(droplist.height === 0) {
                        appWindow.currentItem = dropdown
                        droplist.height = dropcolumn.height
                    } else {
                        droplist.height = 0
                    }
                }
            }
        }

        Rectangle {
            id: droplist
            property int currentOption: 0

            width: 154
            height: 0
            clip: true
            x: dropdown.x
            y: dropdown.height
            color: "#FFFFFF"

            Behavior on height {
                NumberAnimation { duration: 100; easing.type: Easing.InQuad }
            }

            ListModel {
                id: dropdownModel
                ListElement { name: "NAME" }
                ListElement { name: "DESCRIPTION" }
                ListElement { name: "ADDRESS" }
            }

            Column {
                id: dropcolumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                Repeater {
                    model: dropdownModel
                    delegate: Rectangle {
                        property bool isCurrent: name === dropText.text
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 30
                        color: delegateArea.pressed || isCurrent ? "#4A4646" : "#FFFFFF"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            elide: Text.ElideRight
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            font.family: "Arial"
                            font.bold: true
                            font.letterSpacing: -1
                            font.pixelSize: 12
                            color: delegateArea.pressed || parent.isCurrent ? "#FFFFFF" : "#4A4646"
                            text: name
                        }

                        MouseArea {
                            id: delegateArea
                            anchors.fill: parent
                            onClicked: {
                                droplist.currentOption = index
                                droplist.height = 0
                                dropText.text = name
                            }
                        }
                    }
                }
            }
        }

        StandardButton {
            id: button
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 6
            width: 80

            shadowReleasedColor: "#C60F00"
            shadowPressedColor: "#8C0B00"
            pressedColor: "#C60F00"
            releasedColor: "#FF4F41"
            text: qsTr("SEARCH")
            onClicked: item.searchClicked(input.text, droplist.currentOption)
        }
    }
}
