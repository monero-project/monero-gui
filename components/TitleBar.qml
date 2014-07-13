import QtQuick 2.2
import QtQuick.Window 2.0

Row {
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
                    return "../images/whatIsIcon.png"
                return helpArea.containsMouse ? "../images/helpIconHovered.png" :
                                                "../images/helpIcon.png"
            }
        }

        MouseArea {
            id: helpArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: appWindow.whatIsEnable = !appWindow.whatIsEnable
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
            source: minimizeArea.containsMouse ? "../images/minimizeIconHovered.png" :
                                                 "../images/minimizeIcon.png"
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
                    return  maximizeArea.containsMouse ? "../images/backToWindowIconHovered.png" :
                                                         "../images/backToWindowIcon.png"
                return maximizeArea.containsMouse ? "../images/maximizeIconHovered.png" :
                                                    "../images/maximizeIcon.png"
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
            source: "../images/closeIcon.png"
        }

        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Qt.quit()
        }
    }
}
