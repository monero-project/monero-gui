import QtQuick 2.2
import QtQuick.XmlListModel 2.0

Item {
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    Column {
        id: headerColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 74
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 24

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 28
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
            wrapMode: Text.Wrap
            text: qsTr("Welcome")
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 18
            //renderType: Text.NativeRendering
            color: "#4A4646"
            wrapMode: Text.Wrap
            text: qsTr("Please choose a language and regional format.")
        }
    }

    XmlListModel {
        id: languagesModel
        source: "file:///" + applicationDirectory + "/lang/languages.xml"
        query: "/languages/language"

        XmlRole { name: "name"; query: "@name/string()" }
        XmlRole { name: "flag"; query: "@flag/string()" }
        XmlRole { name: "isCurrent"; query: "@enabled/string()" }
    }

    ListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: headerColumn.bottom
        anchors.topMargin: 24
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        clip: true

        model: languagesModel
        delegate: Item {
            width: listView.width
            height: 80

            Rectangle {
                id: flagRect
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: 60; height: 60
                radius: 30
                color: listView.currentIndex === index ? "#DBDBDB" : "#FFFFFF"

                Image {
                    anchors.centerIn: parent
                    source: "file:///" + applicationDirectory + flag
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: flagRect.right
                anchors.right: parent.right
                anchors.leftMargin: 16
                font.family: "Arial"
                font.pixelSize: 24
                font.bold: listView.currentIndex === index
                elide: Text.ElideRight
                color: "#3F3F3F"
                text: name
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: "#DBDBDB"
            }

            MouseArea {
                id: delegateArea
                anchors.fill: parent
                onClicked: listView.currentIndex = index
            }
        }
    }
}
