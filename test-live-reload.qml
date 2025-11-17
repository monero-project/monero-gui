// Test file for live reload demonstration
// Run with: qmlscene --live test-live-reload.qml
// Or use the built app with QML_LIVE_RELOAD=1

import QtQuick 6.6
import QtQuick.Window 6.6

Window {
    id: window
    width: 800
    height: 600
    visible: true
    title: "Live Reload Test - Change this text and save!"

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Test 1: Simple label text change
        Text {
            id: testLabel1
            text: "TEST 1: Simple Label - Edit this text in the file!"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Test 2: Color change
        Rectangle {
            id: colorBox
            width: 200
            height: 100
            color: "blue"  // Change this color and save!
            anchors.horizontalCenter: parent.horizontalCenter
            border.width: 2
            border.color: "black"
            
            Text {
                anchors.centerIn: parent
                text: "Change my color!"
                color: "white"
            }
        }

        // Test 3: Nested component
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300
            height: 150
            
            Rectangle {
                id: nestedRect
                anchors.fill: parent
                color: "lightgreen"
                border.width: 2
                border.color: "darkgreen"
                
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Text {
                        text: "Nested Component"
                        font.pixelSize: 18
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Edit nestedRect.color above!"
                        font.pixelSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // Test 4: Property binding
        Text {
            id: testLabel2
            text: "TEST 4: Property - Size: " + window.width + "x" + window.height
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Instructions
        Rectangle {
            width: parent.width - 40
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#f0f0f0"
            border.width: 1
            border.color: "#ccc"
            
            Column {
                anchors.centerIn: parent
                spacing: 5
                
                Text {
                    text: "LIVE RELOAD TEST INSTRUCTIONS:"
                    font.bold: true
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "1. Edit any text/color above and save"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "2. Watch the UI update automatically!"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "3. Changes should appear within 500ms"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}

