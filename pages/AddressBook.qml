import QtQuick 2.0
import "../components"

Rectangle {
    color: "#F0EEEE"

//    Text {
//        id: newEntryText
//        anchors.left: parent.left
//        anchors.right: parent.right
//        anchors.top: parent.top
//        anchors.leftMargin: 17
//        anchors.topMargin: 17

//        elide: Text.ElideRight
//        font.family: "Arial"
//        font.pixelSize: 18
//        color: "#4A4949"
//        text: qsTr("Add new entry")
//    }

//    Label {
//        id: addressLabel
//        anchors.left: parent.left
//        anchors.top: newEntryText.bottom
//        anchors.leftMargin: 17
//        anchors.topMargin: 17
//        text: qsTr("Address")
//        fontSize: 14
//        tipText: qsTr("<b>Tip tekst test</b>")
//    }

//    LineEdit {
//        id: addressLine
//        anchors.left: parent.left
//        anchors.right: parent.right
//        anchors.top: addressLabel.bottom
//        anchors.leftMargin: 17
//        anchors.rightMargin: 17
//        anchors.topMargin: 5
//    }

//    Label {
//        id: paymentIdLabel
//        anchors.left: parent.left
//        anchors.top: addressLine.bottom
//        anchors.leftMargin: 17
//        anchors.topMargin: 17
//        text: qsTr("Payment ID <font size='2'>(Optional)</font>")
//        fontSize: 14
//        tipText: qsTr("<b>Payment ID</b><br/><br/>A unique user name used in<br/>the address book. It is not a<br/>transfer of information sent<br/>during thevtransfer")
//        width: 156
//    }

//    Label {
//        id: descriptionLabel
//        anchors.left: paymentIdLabel.right
//        anchors.top: addressLine.bottom
//        anchors.leftMargin: 17
//        anchors.topMargin: 17
//        text: qsTr("Description <font size='2'>(Local database)</font>")
//        fontSize: 14
//        tipText: qsTr("<b>Tip tekst test</b><br/><br/>test line 2")
//        width: 156
//    }

//    LineEdit {
//        id: paymentIdLine
//        anchors.left: parent.left
//        anchors.top: paymentIdLabel.bottom
//        anchors.leftMargin: 17
//        anchors.topMargin: 5
//        width: 156
//    }

//    LineEdit {
//        id: descriptionLine
//        anchors.left: paymentIdLine.right
//        anchors.right: addButton.left
//        anchors.top: paymentIdLabel.bottom
//        anchors.leftMargin: 17
//        anchors.rightMargin: 17
//        anchors.topMargin: 5
//    }

//    StandardButton {
//        id: addButton
//        anchors.right: parent.right
//        anchors.top: paymentIdLabel.bottom
//        anchors.rightMargin: 17
//        anchors.topMargin: 5
//        width: 60

//        shadowColor: "#8C0B00"
//        pressedColor: "#C60F00"
//        releasedColor: "#FF4F41"
//        text: qsTr("ADD")
//    }

//    Rectangle {
//        anchors.left: parent.left
//        anchors.right: parent.right
//        anchors.bottom: parent.bottom
//        anchors.top: paymentIdLine.bottom
//        anchors.topMargin: 17
//        color: "#FFFFFF"

//        Rectangle {
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: parent.top
//            height: 1
//            color: "#DBDBDB"
//        }

//        ListModel {
//            id: columnsModel
//            ListElement { columnName: "Payment ID"; columnWidth: 148 }
//            ListElement { columnName: "Description"; columnWidth: 420 }
//        }

//        TableHeader {
//            id: header
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: parent.top
//            anchors.topMargin: 17
//            anchors.leftMargin: 14
//            anchors.rightMargin: 14
//            dataModel: columnsModel
//            onSortRequest: console.log("column: " + column + " desc: " + desc)
//        }

//        ListModel {
//            id: testModel
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: "Malkolm T."; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "Client from Australia" }
//            ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; description: "" }
//        }

//        Scroll {
//            id: flickableScroll
//            anchors.rightMargin: -14
//            flickable: table
//            yPos: table.y
//        }

//        AddressBookTable {
//            id: table
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: header.bottom
//            anchors.bottom: parent.bottom
//            anchors.leftMargin: 14
//            anchors.rightMargin: 14
//            onContentYChanged: flickableScroll.flickableContentYChanged()
//            model: testModel
//        }
//    }
}
