import QtQuick 2.2
import "../components"

Item {
    opacity: 0
    visible: false
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    Row {
        id: dotsRow
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 85
        spacing: 6

        ListModel {
            id: dotsModel
            ListElement { dotColor: "#36B05B" }
            ListElement { dotColor: "#36B05B" }
            ListElement { dotColor: "#36B05B" }
            ListElement { dotColor: "#FFE00A" }
        }

        Repeater {
            model: dotsModel
            delegate: Rectangle {
                width: 12; height: 12
                radius: 6
                color: dotColor
            }
        }
    }

    Text {
        id: headerText
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 74
        anchors.leftMargin: 16
        width: parent.width - dotsRow.width - 16

        font.family: "Arial"
        font.pixelSize: 28
        wrapMode: Text.Wrap
        //renderType: Text.NativeRendering
        color: "#3F3F3F"
        text: qsTr("Monero development is solely supported by donations")
    }

    Column {
        anchors.top: headerText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 34
        spacing: 12

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 2

            CheckBox {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Enable auto-donations of?")
                background: "#F0EEEE"
                fontColor: "#4A4646"
                fontSize: 18
                checkedIcon: "../images/checkedVioletIcon.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
                checked: true
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                height: 30
                width: 41

                TextInput {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Arial"
                    font.pixelSize: 18
                    color: "#6B0072"
                    text: "50"
                    validator: IntValidator { bottom: 0; top: 100 }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: "#DBDBDB"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Arial"
                font.pixelSize: 18
                color: "#4A4646"
                text: qsTr("% of my fee added to each transaction")
            }
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 15
            color: "#4A4646"
            wrapMode: Text.Wrap
            text: qsTr("For every transaction, a small transaction fee is charged. This option lets you add an additional amount, " +
                       "as a percentage of that fee, to your transaction to support Monero development. For instance, a 50% " +
                       "autodonation take a transaction fee of 0.005 XMR and add a 0.0025 XMR to support Monero development.")
        }
    }
}
