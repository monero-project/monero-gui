import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4

// import "../components"

Dialog {
    id: root
    readonly property alias password: passwordInput.text
    standardButtons: StandardButton.Ok + StandardButton.Cancel
    ColumnLayout {
        id: column
        height: 40
        anchors.fill: parent

        Label {
            text: qsTr("Please enter wallet password")
            Layout.columnSpan: 2
            Layout.fillWidth: true
            font.family: "Arial"
            font.pixelSize: 32
        }

        TextField {
            id : passwordInput

            echoMode: TextInput.Password
            focus: true
            Layout.fillWidth: true
            font.family: "Arial"
            font.pixelSize: 24
            style: TextFieldStyle {
                passwordCharacter: "•"
            }
        }
    }
}

