import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import "." as MoneroComponents

Dialog {
    id: root
    modal: true
    closePolicy: Popup.NoAutoClose
    dim: true
    title: "Securing Your Freedom"
    
    property alias passwordText: passwordField.text
    signal submitPassword()
    
    property var facts: [
        "Did you know? Monero uses ring signatures to obfuscate the origin of funds.",
        "Running your own node is the highest level of privacy you can achieve.",
        "I2P (Invisible Internet Project) creates a strictly anonymous network layer.",
        "By running this node, you are protecting yourself and the entire network.",
        "Monero is the only major cryptocurrency where every user is anonymous by default."
    ]
    
    property int currentFactIndex: 0

    Timer {
        interval: 5000 
        running: root.visible && !passwordRow.visible
        repeat: true
        onTriggered: {
            currentFactIndex = (currentFactIndex + 1) % facts.length
        }
    }

    background: Rectangle {
        color: "#1D1D1D"
        radius: 10
        border.color: "#FF6600"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Text {
            text: "Constructing Secure Node..."
            color: "white"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.preferredWidth: 400
            Layout.preferredHeight: 100
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                width: parent.width
                text: facts[currentFactIndex]
                color: "#AAAAAA"
                font.pixelSize: 16
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: true
        }
        
        ColumnLayout {
            id: passwordRow
            visible: false 
            Layout.fillWidth: true
            
            Text {
                text: "Admin Access Required for Docker"
                color: "#FF6600"
                font.pixelSize: 14
            }
            
            TextField {
                id: passwordField
                echoMode: TextInput.Password
                placeholderText: "Enter System Password"
                Layout.fillWidth: true
                color: "white"
                background: Rectangle { color: "#333"; radius: 4 }
            }
            
            Button {
                text: "Authorize Securely"
                Layout.alignment: Qt.AlignRight
                onClicked: root.submitPassword()
            }
        }
    }
}
