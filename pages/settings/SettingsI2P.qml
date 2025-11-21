import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import "../../components" as MoneroComponents

Rectangle {
    color: "transparent"
    signal requestNodeCreation(string password)

    ColumnLayout {
        width: parent.width
        spacing: 20

        RowLayout {
            spacing: 15
            Switch {
                id: i2pToggle
                text: "Enable I2P Privacy Routing"
                checked: false
                contentItem: Text {
                    text: i2pToggle.text
                    color: i2pToggle.checked ? "#FF6600" : "#AAAAAA"
                    font.pixelSize: 18
                }
            }
            
            Rectangle {
                visible: i2pToggle.checked
                width: 100
                height: 30
                radius: 15
                color: "#2EB358"
                RowLayout {
                    anchors.centerIn: parent
                    Text { text: "✓ SECURE"; color: "white"; font.bold: true }
                }
            }
        }

        ColumnLayout {
            visible: i2pToggle.checked
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: "Traffic is currently encrypted and proxied via I2P."
                color: "#888888"
                font.italic: true
            }

            RowLayout {
                Text { text: "Connection Method:"; color: "white" }
                ComboBox {
                    model: ["Automatic (Best)", "Local I2P Router", "Remote I2P Node"]
                    currentIndex: 0
                    width: 200
                }
            }

            Text { text: "Verified Trust Nodes"; color: "#FF6600"; font.bold: true }
            
            ListView {
                Layout.preferredHeight: 80
                Layout.fillWidth: true
                model: ListModel {
                    ListElement { name: "i2p-project.main.net"; status: "Online" }
                    ListElement { name: "monero-node-01.i2p"; status: "Online" }
                }
                delegate: Text { text: name + " (" + status + ")"; color: "white" }
            }

            Button {
                // visible: !i2pManager.isMobile // Commented out until C++ wiring is done
                text: "CREATE YOUR OWN NODE (DOCKER)"
                Layout.fillWidth: true
                onClicked: createNodeModal.open()
                background: Rectangle { color: "#FF6600"; radius: 5 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
            }
        }
    }

    I2PNodeModal {
        id: createNodeModal
        anchors.centerIn: parent
        width: 600
        height: 300
        onSubmitPassword: requestNodeCreation(passwordText)
    }
}
