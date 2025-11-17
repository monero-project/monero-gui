// Minimal test file for live reload - no imports needed
// Works with any QML runtime

import QtQuick 2.0

Rectangle {
    id: root
    width: 600
    height: 400
    color: "lightgray"
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            id: testText
            text: "HOT RELOAD TEST"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            color: "black"
        }
        
        Rectangle {
            id: colorBox
            width: 200
            height: 100
            color: "blue"  // CHANGE THIS TO "red" AND SAVE!
            anchors.horizontalCenter: parent.horizontalCenter
            border.width: 2
            border.color: "black"
            
            Text {
                anchors.centerIn: parent
                text: "Change my color!"
                color: "white"
            }
        }
        
        Text {
            text: "Edit this file and save to see live reload!"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
            color: "darkblue"
        }
        
        Text {
            text: "Try changing colorBox.color above to 'red'"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: "darkgreen"
        }
    }
}

