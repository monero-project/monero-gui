import QtQuick 2.0
import "../components"

Rectangle {
    color: "#F0EEEE"

    Text {
        id: filterHeaderText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 17
        anchors.topMargin: 17

        elide: Text.ElideRight
        font.family: "Arial"
        font.pixelSize: 18
        color: "#4A4949"
        text: qsTr("Filter trasactions history")
    }

    Label {
        id: addressLabel
        anchors.left: parent.left
        anchors.top: filterHeaderText.bottom
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

    Label {
        id: dateFromText
        anchors.left: parent.left
        anchors.top: descriptionLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        width: 156
        text: qsTr("Date from")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>")
    }

    DatePicker {
        id: fromDatePicker
        anchors.left: parent.left
        anchors.top: dateFromText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 5
        z: 2
    }

    Label {
        id: dateToText
        anchors.left: dateFromText.right
        anchors.top: descriptionLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("To")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>")
    }

    DatePicker {
        id: toDatePicker
        anchors.left: fromDatePicker.right
        anchors.top: dateToText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 5
        z: 2
    }

    StandardButton {
        id: filterButton
        anchors.bottom: toDatePicker.bottom
        anchors.left: toDatePicker.right
        anchors.leftMargin: 17
        width: 60
        text: qsTr("FILTER")
        shadowReleasedColor: "#4D0051"
        shadowPressedColor: "#2D002F"
        releasedColor: "#6B0072"
        pressedColor: "#4D0051"
    }

    Text {
        anchors.verticalCenter: filterButton.verticalCenter
        anchors.left: filterButton.right
        anchors.leftMargin: 17
        font.family: "Arial"
        font.pixelSize: 12
        color: "#545454"
        textFormat: Text.RichText
        text: qsTr("<style type='text/css'>a {text-decoration: none; color: #6B0072; font-size: 14px;}</style>\
                    looking for <a href='#'>Advance filtering?</a>")
        font.underline: false
        onLinkActivated: tableRect.height = Qt.binding(function(){ return tableRect.collapsedHeight })
    }

    Label {
        id: transactionTypeText
        anchors.left: parent.left
        anchors.top: fromDatePicker.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        width: 156
        text: qsTr("Type of transation")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>")
    }

    ListModel {
        id: transactionsModel
        ListElement { column1: "SENT"; column2: "" }
        ListElement { column1: "RECIVE"; column2: "" }
        ListElement { column1: "ON HOLD"; column2: "" }
    }

    StandardDropdown {
        id: transactionTypeDropdown
        anchors.left: parent.left
        anchors.top: transactionTypeText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 5
        width: 156
        shadowReleasedColor: "#4D0051"
        shadowPressedColor: "#2D002F"
        releasedColor: "#6B0072"
        pressedColor: "#4D0051"
        dataModel: transactionsModel
        z: 1
    }

    Label {
        id: amountFromText
        anchors.left: transactionTypeText.right
        anchors.top: fromDatePicker.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        width: 156
        text: qsTr("Amount from")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>")
    }

    LineEdit {
        id: amountFromLine
        anchors.left: transactionTypeDropdown.right
        anchors.top: amountFromText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 5
        width: 156
    }

    Label {
        id: amountToText
        anchors.left: amountFromText.right
        anchors.top: fromDatePicker.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        width: 156
        text: qsTr("To")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>")
    }

    LineEdit {
        id: amountToLine
        anchors.left: amountFromLine.right
        anchors.top: amountToText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 5
        width: 156
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
            onClicked: {
                parent.expanded = !parent.expanded
                tableRect.height = Qt.binding(function(){ return parent.expanded ? tableRect.expandedHeight : tableRect.middleHeight })
            }
        }
    }

    Rectangle {
        id: tableRect
        property int expandedHeight: parent.height - filterHeaderText.y - filterHeaderText.height - 17
        property int middleHeight: parent.height - fromDatePicker.y - fromDatePicker.height - 17
        property int collapsedHeight: parent.height - transactionTypeDropdown.y - transactionTypeDropdown.height - 17
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#FFFFFF"
        z: 1

        height: middleHeight
        onHeightChanged: {
            if(height === middleHeight) z = 1
            else if(height === collapsedHeight) z = 0
            else z = 3
        }

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
            ListElement { columnName: "Address"; columnWidth: 127 }
            ListElement { columnName: "Date"; columnWidth: 100 }
            ListElement { columnName: "Amount"; columnWidth: 148 }
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
            offset: 20
            onSortRequest: console.log("column: " + column + " desc: " + desc)
        }

        ListModel {
            id: testModel
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: "Client from Australia"; out: false }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: ""; out: true }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: ""; out: true }
            ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: ""; out: false }
            ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: "Client from Australia"; out: false }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: ""; out: false }
            ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: ""; out: false }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: ""; out: false }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: "Client from Australia"; out: false }
            ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "19301.<font size='2'>870709159241</font>"; balance: "0.<font size='2'>000709159241</font>"; description: ""; out: false }
        }

        Scroll {
            id: flickableScroll
            anchors.rightMargin: -14
            flickable: table
            yPos: table.y
        }

        HistoryTable {
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
