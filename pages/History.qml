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
        id: paymentIdText
        anchors.left: parent.left
        anchors.top: filterHeaderText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("Payment ID")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>")
    }

    LineEdit {
        id: paymentIdLine
        anchors.left: parent.left
        anchors.top: paymentIdText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 5
        width: 156
    }

    Label {
        id: dateFromText
        anchors.left: parent.left
        anchors.top: paymentIdLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("Date from")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>")
    }

    DatePicker {
        anchors.left: parent.left
        anchors.top: dateFromText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 5
    }
}
