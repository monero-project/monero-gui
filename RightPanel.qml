import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "tabs"

Rectangle {
    width: 330

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 5
        anchors.rightMargin: 5

        Rectangle {
            width: 25
            height: 25
            radius: 5
            clip: true
            color: helpArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

            Rectangle {
                width: 25
                height: 25
                radius: 5
                color: "#FFFFFF"
                visible: helpArea.containsMouse
                x: 1; y: 2
            }

            Image {
                anchors.centerIn: parent
                source: {
                    if(appWindow.whatIsEnable)
                        return "images/whatIsIcon.png"
                    return helpArea.containsMouse ? "images/helpIconHovered.png" :
                                                    "images/helpIcon.png"
                }
            }

            MouseArea {
                id: helpArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    appWindow.whatIsEnable = !appWindow.whatIsEnable
                }
            }
        }

        Rectangle {
            width: 25
            height: 25
            radius: 5
            clip: true
            color: minimizeArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

            Rectangle {
                width: 25
                height: 25
                radius: 5
                color: "#FFFFFF"
                visible: minimizeArea.containsMouse
                x: 1; y: 2
            }

            Image {
                anchors.centerIn: parent
                source: minimizeArea.containsMouse ? "images/minimizeIconHovered.png" :
                                                     "images/minimizeIcon.png"
            }

            MouseArea {
                id: minimizeArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: appWindow.visibility = Window.Minimized
            }
        }

        Rectangle {
            property bool checked: false
            width: 25
            height: 25
            radius: 5
            clip: true
            color: maximizeArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

            Rectangle {
                width: 25
                height: 25
                radius: 5
                color: "#FFFFFF"
                visible: maximizeArea.containsMouse
                x: 1; y: 2
            }

            Image {
                anchors.centerIn: parent
                source: {
                    if(parent.checked)
                        return  maximizeArea.containsMouse ? "images/backToWindowIconHovered.png" :
                                                             "images/backToWindowIcon.png"
                    return maximizeArea.containsMouse ? "images/maximizeIconHovered.png" :
                                                        "images/maximizeIcon.png"
                }
            }

            MouseArea {
                id: maximizeArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    parent.checked = !parent.checked
                    appWindow.visibility = parent.checked ? Window.FullScreen :
                                                            Window.Windowed
                }
            }
        }

        Rectangle {
            width: 25
            height: 25
            radius: 5
            clip: true
            color: closeArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

            Rectangle {
                width: 25
                height: 25
                radius: 5
                color: "#FFFFFF"
                visible: closeArea.containsMouse
                x: 1; y: 2
            }

            Image {
                anchors.centerIn: parent
                source: "images/closeIcon.png"
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Qt.quit()
            }
        }
    }

    TabView {
        id: tabView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: styledRow.top
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 40

        Tab { title: qsTr("Twitter"); source: "tabs/Twitter.qml" }
        Tab { title: "News" }
        Tab { title: "Help" }
        Tab { title: "About" }

        style: TabViewStyle {
            frameOverlap: 0
            tabOverlap: 0

            tab: Rectangle {
                implicitHeight: 31
                implicitWidth: styleData.index === tabView.count - 1 ? tabView.width - (tabView.count - 1) * 68 : 68

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    elide: Text.ElideRight
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: styleData.selected ? "#FF4E40" : "#4A4646"
                    text: styleData.title
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    color: "#DBDBDB"
                    visible: styleData.index !== tabView.count - 1
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -1
                    height: 1
                    color: styleData.selected ? "#FFFFFF" : "#DBDBDB"
                }
            }

            frame: Rectangle {
                color: "#FFFFFF"
                anchors.fill: parent
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    //anchors.topMargin: 1
                    height: 1
                    color: "#DBDBDB"
                }
            }
        }
    }

    Row {
        id: styledRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Rectangle { height: 8; width: parent.width / 5; color: "#FFE00A" }
        Rectangle { height: 8; width: parent.width / 5; color: "#6B0072" }
        Rectangle { height: 8; width: parent.width / 5; color: "#FF6C3C" }
        Rectangle { height: 8; width: parent.width / 5; color: "#FFD781" }
        Rectangle { height: 8; width: parent.width / 5; color: "#FF4F41" }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: "#DBDBDB"
    }

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 1
        color: "#DBDBDB"
    }
}
