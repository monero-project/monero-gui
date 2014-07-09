import QtQuick 2.0

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds

    delegate: Rectangle {
        id: delegate
        height: 64
        width: listView.width
        color: index % 2 ? "#F8F8F8" : "#FFFFFF"

        StandardButton {
            id: goToTransferButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 37
            anchors.leftMargin: 3
            shadowColor: "#FF4304"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            icon: "../images/goToTransferIcon.png"
        }

        StandardButton {
            id: removeButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 37
            anchors.rightMargin: 3
            shadowColor: "#DBDBDB"
            releasedColor: "#F0EEEE"
            pressedColor: "#DBDBDB"
            icon: "../images/deleteIcon.png"
        }

        Row {
            anchors.left: goToTransferButton.right
            anchors.right: removeButton.left
            anchors.leftMargin: 12
            anchors.top: goToTransferButton.top
            anchors.topMargin: -2

            Text {
                id: paymentIdText
                anchors.top: parent.top
                width: text.length ? 122 : 0
                font.family: "Arial"
                font.bold: true
                font.pixelSize: 19
                color: "#444444"
                elide: Text.ElideRight
                text: paymentId
            }

            Item { //separator
                width: paymentIdText.width ? 12 : 0
                height: 14
            }

            Text {
                anchors.bottom: paymentIdText.bottom
                width: parent.width - x - 12
                elide: Text.ElideRight
                font.family: "Arial"
                font.pixelSize: 14
                color: "#545454"
                text: description
            }
        }

        Text {
            anchors.top: description.length === 0 && paymentId.length === 0 ? goToTransferButton.top : undefined
            anchors.bottom: description.length === 0 && paymentId.length === 0 ? undefined : goToTransferButton.bottom
            anchors.topMargin: -2
            anchors.bottomMargin: -2

            anchors.left: goToTransferButton.right
            anchors.right: removeButton.left
            anchors.rightMargin: 12
            anchors.leftMargin: 12
            elide: Text.ElideRight
            font.family: "Arial"
            font.pixelSize: 14
            color: "#545454"
            text: address
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#DBDBDB"
        }
    }
}
