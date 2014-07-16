import QtQuick 2.0
import "../components"

Rectangle {
    color: "#F0EEEE"

    Text {
        id: newEntryText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 17
        anchors.topMargin: 17

        elide: Text.ElideRight
        font.family: "Arial"
        font.pixelSize: 18
        color: "#4A4949"
        text: qsTr("Add new entry")
    }

    Label {
        id: addressLabel
        anchors.left: parent.left
        anchors.top: newEntryText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("Address")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>")
    }

    LineEdit {
        id: addressLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: addressLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
    }

    Label {
        id: paymentIdLabel
        anchors.left: parent.left
        anchors.top: addressLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("Payment ID <font size='2'>(Optional)</font>")
        fontSize: 14
        tipText: qsTr("<b>Payment ID</b><br/><br/>A unique user name used in<br/>the address book. It is not a<br/>transfer of information sent<br/>during thevtransfer")
    }

    LineEdit {
        id: paymentIdLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: paymentIdLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
    }

    Label {
        id: descriptionLabel
        anchors.left: parent.left
        anchors.top: paymentIdLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("Description <font size='2'>(Local database)</font>")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b><br/><br/>test line 2")
    }

    LineEdit {
        id: descriptionLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: descriptionLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
    }

    StandardButton {
        id: addButton
        anchors.left: parent.left
        anchors.top: descriptionLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        width: 60

        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        text: qsTr("ADD")
    }

    Item {
        id: expandItem
        property bool expanded: false

        anchors.right: parent.right
        anchors.bottom: tableRect.top
        width: 34
        height: 34

        Image {
            anchors.centerIn: parent
            source: "../images/expandTable.png"
            rotation: parent.expanded ? 180 : 0
        }

        MouseArea {
            anchors.fill: parent
            onClicked: parent.expanded = !parent.expanded
        }
    }

    Rectangle {
        id: tableRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: expandItem.expanded ? parent.height - newEntryText.y - newEntryText.height - 17 :
                                      parent.height - addButton.y - addButton.height - 17
        color: "#FFFFFF"

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.InQuad }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: "#DBDBDB"
        }

        ListModel {
            id: columnsModel
            ListElement { columnName: "Address"; columnWidth: 148 }
            ListElement { columnName: "Payment ID"; columnWidth: 148 }
            ListElement { columnName: "Description"; columnWidth: 148 }
        }

        TableHeader {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 17
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            dataModel: columnsModel
            onSortRequest: console.log("column: " + column + " desc: " + desc)
        }

        ListModel {
            id: testModel
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
            ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "" }
        }

        Scroll {
            id: flickableScroll
            anchors.rightMargin: -14
            flickable: table
            yPos: table.y
        }

        AddressBookTable {
            id: table
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            onContentYChanged: flickableScroll.flickableContentYChanged()
            model: testModel
        }
    }
}
