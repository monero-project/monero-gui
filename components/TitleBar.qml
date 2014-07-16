import QtQuick 2.2
import QtQuick.Window 2.0

Rectangle {
    id: titleBar
    height: 30
    color: "#000000"
    y: -height
    property int mouseX: 0
    property int mouseY: 0

    Text {
        anchors.centerIn: parent
        font.family: "Arial"
        font.pixelSize: 15
        font.letterSpacing: -1
        color: "#FFFFFF"
        text: qsTr("Monero")
    }
    
    Behavior on y {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }
    
    Row {
        id: row
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        
        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: height
            color: appWindow.whatIsEnable || containsMouse ? "#6B0072" : "#000000"
            
            Image {
                anchors.centerIn: parent
                source: "../images/helpIcon.png"
            }
            
            MouseArea {
                id: whatIsArea
                anchors.fill: parent
                onClicked: appWindow.whatIsEnable = !appWindow.whatIsEnable
            }
        }
        
        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: height
            color: containsMouse ? "#3665B3" : "#000000"
            
            Image {
                anchors.centerIn: parent
                source: "../images/minimizeIcon.png"
            }
            
            MouseArea {
                id: minimizeArea
                anchors.fill: parent
                onClicked: appWindow.visibility = Window.Minimized
            }
        }
        
        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: height
            color: containsMouse ? "#FF6C3C" : "#000000"
            property bool checked: false
            
            Image {
                anchors.centerIn: parent
                source: parent.checked ?  "../images/backToWindowIcon.png" :
                                          "../images/maximizeIcon.png"

            }
            
            MouseArea {
                id: maximizeArea
                anchors.fill: parent
                onClicked: {
                    parent.checked = !parent.checked
                    appWindow.visibility = parent.checked ? Window.FullScreen :
                                                            Window.Windowed
                }
            }
        }
        
        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: height
            color: containsMouse ? "#E04343" : "#000000"
            
            Image {
                anchors.centerIn: parent
                source: "../images/closeIcon.png"
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }
        }
    }
}
