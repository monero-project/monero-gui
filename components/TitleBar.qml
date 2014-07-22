import QtQuick 2.2
import QtQuick.Window 2.0

Rectangle {
    id: titleBar
    height: 30
    color: "#000000"
    y: -height
    property int mouseX: 0
    property string walletName: "Donations"
    property bool containsMouse: false
    property alias maximizeButtonVisible: maximizeButton.visible
    signal goToBasicVersion(bool yes)

    Text {
        anchors.centerIn: parent
        font.family: "Arial"
        font.pixelSize: 15
        font.letterSpacing: -1
        color: "#FFFFFF"
        text: qsTr("Monero  -  %1").arg(titleBar.walletName)
    }
    
    Behavior on y {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    Rectangle {
        id: goToBasicVersionButton
        property bool containsMouse: titleBar.mouseX >= x && titleBar.mouseX <= x + width
        property bool checked: false
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: height
        color:  containsMouse || checked ? "#FFE00A" : "#000000"

        Image {
            anchors.centerIn: parent
            rotation: parent.checked ? 180 : 0
            source: parent.containsMouse || parent.checked ? "../images/goToBasicVersionHovered.png" :
                                                             "../images/gotoBasicVersion.png"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                parent.checked = !parent.checked
                titleBar.goToBasicVersion(parent.checked)
            }
        }
    }
    
    Row {
        id: row
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        
        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width && titleBar.containsMouse
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: height
            color: containsMouse ? "#6B0072" : "#000000"
            
            Image {
                anchors.centerIn: parent
                source: "../images/helpIcon.png"
            }
            
            MouseArea {
                id: whatIsArea
                anchors.fill: parent
                onClicked: {

                }
            }
        }
        
        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width && titleBar.containsMouse
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
                onClicked: {
                    appWindow.visibility = Window.Minimized
                }
            }
        }
        
        Rectangle {
            id: maximizeButton
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width && titleBar.containsMouse
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: height
            color: containsMouse ? "#FF6C3C" : "#000000"
            
            Image {
                anchors.centerIn: parent
                source: appWindow.visibility === Window.FullScreen ?  "../images/backToWindowIcon.png" :
                                                                      "../images/maximizeIcon.png"

            }
            
            MouseArea {
                id: maximizeArea
                anchors.fill: parent
                onClicked: {
                    appWindow.visibility = appWindow.visibility !== Window.FullScreen ? Window.FullScreen :
                                                                                        Window.Windowed
                }
            }
        }
        
        Rectangle {
            property bool containsMouse: titleBar.mouseX >= x + row.x && titleBar.mouseX <= x + row.x + width && titleBar.containsMouse
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
