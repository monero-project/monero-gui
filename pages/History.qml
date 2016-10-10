// Copyright (c) 2014-2015, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0

import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionInfo 1.0
import moneroComponents.TransactionHistoryModel 1.0

import "../components"

Rectangle {
    id: root
    property var model

    color: "#F0EEEE"
    onModelChanged: {
        if (typeof model !== 'undefined') {
            // setup date filter scope according to real transactions
            fromDatePicker.currentDate = model.transactionHistory.firstDateTime
            toDatePicker.currentDate = model.transactionHistory.lastDateTime
        }
    }


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
        text: qsTr("Filter transactions history") + translationManager.emptyString
    }

    // Filter by Address input (senseless, removing)
    /*
    Label {
        id: addressLabel
        anchors.left: parent.left
        anchors.top: filterHeaderText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("Address")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>") + translationManager.emptyString
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
    */

    // Filter by Payment ID input

    Label {
        id: paymentIdLabel
        anchors.left: parent.left
        anchors.top: filterHeaderText.bottom // addressLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("Payment ID <font size='2'>(Optional)</font>") + translationManager.emptyString
        fontSize: 14
        tipText: qsTr("<b>Payment ID</b><br/><br/>A unique user name used in<br/>the address book. It is not a<br/>transfer of information sent<br/>during thevtransfer")
            + translationManager.emptyString
    }

    LineEdit {
        id: paymentIdLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: paymentIdLabel.bottom // addressLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5


    }

    // Filter by description input (not implemented yet)
    /*
    Label {
        id: descriptionLabel
        anchors.left: parent.left
        anchors.top: paymentIdLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("Description <font size='2'>(Local database)</font>") + translationManager.emptyString
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b><br/><br/>test line 2") + translationManager.emptyString
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
    */


    // DateFrom picker
    Label {
        id: dateFromText
        anchors.left: parent.left
        anchors.top:  paymentIdLine.bottom // descriptionLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        width: 156
        text: qsTr("Date from") + translationManager.emptyString
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>") + translationManager.emptyString
    }

    DatePicker {
        id: fromDatePicker
        anchors.left: parent.left
        anchors.top: dateFromText.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 5
        z: 2
    }

    // DateTo picker
    Label {
        id: dateToText
        anchors.left: dateFromText.right
        anchors.top:  paymentIdLine.bottom //descriptionLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("To")
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>") + translationManager.emptyString
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
        onClicked:  {
            // Apply filter here;
            model.paymentIdFilter = paymentIdLine.text
            model.dateFromFilter  = fromDatePicker.currentDate
            model.dateToFilter    = toDatePicker.currentDate
            if (advancedFilteringCheckBox.checked) {
                if (amountFromLine.text.length) {
                    model.amountFromFilter = parseFloat(amountFromLine.text)
                }
                if (amountToLine.text.length) {
                    model.amountToFilter = parseFloat(amountToLine.text)
                }

                var directionFilter = transactionsModel.get(transactionTypeDropdown.currentIndex).value
                console.log("Direction filter: " + directionFilter)
                model.directionFilter = directionFilter
            }


        }
    }

    CheckBox {
        id: advancedFilteringCheckBox
        text: qsTr("Advance filtering")
        anchors.left: filterButton.right
        anchors.bottom: filterButton.bottom
        anchors.leftMargin: 17
        checkedIcon: "../images/checkedVioletIcon.png"
        uncheckedIcon: "../images/uncheckedIcon.png"
        onClicked: {
            if(checked) tableRect.height = Qt.binding(function(){ return tableRect.collapsedHeight })
            else tableRect.height = Qt.binding(function(){ return tableRect.middleHeight })
        }
    }

    Label {
        id: transactionTypeText
        anchors.left: parent.left
        anchors.top: fromDatePicker.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        width: 156
        text: qsTr("Type of transation") + translationManager.emptyString
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>") + translationManager.emptyString
    }

    ListModel {
        id: transactionsModel
        ListElement { column1: "ALL"; column2: ""; value: TransactionInfo.Direction_Both }
        ListElement { column1: "SENT"; column2: ""; value: TransactionInfo.Direction_Out }
        ListElement { column1: "RECEIVED"; column2: ""; value: TransactionInfo.Direction_In }

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
        text: qsTr("Amount from") + translationManager.emptyString
        fontSize: 14
        tipText: qsTr("<b>Tip tekst test</b>") + translationManager.emptyString
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
        tipText: qsTr("<b>Tip tekst test</b>") + translationManager.emptyString
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
                if (advancedFilteringCheckBox.checked) {
                    tableRect.height = Qt.binding(function() { return parent.expanded ? tableRect.expandedHeight : tableRect.collapsedHeight })
                } else {
                    tableRect.height = Qt.binding(function() { return parent.expanded ? tableRect.expandedHeight : tableRect.middleHeight })
                }
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

            ListElement { columnName: "Payment ID"; columnWidth: 127 }
            ListElement { columnName: "Date"; columnWidth: 100 }
            ListElement { columnName: "Amount"; columnWidth: 148 }
            // ListElement { columnName: "Description"; columnWidth: 148 }
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
            onSortRequest: {
                console.log("column: " + column + " desc: " + desc)
                switch (column) {
                case 0:
                    // Payment ID
                    model.sortRole = TransactionHistoryModel.TransactionPaymentIdRole
                    break;
                case 1:
                    // Date;
                    model.sortRole = TransactionHistoryModel.TransactionDateRole
                    break;
                case 2:
                    // Amount;
                    model.sortRole = TransactionHistoryModel.TransactionAmountRole
                    break;
                }
                model.sort(0, desc ? Qt.DescendingOrder : Qt.AscendingOrder)
            }
        }

        Scroll {
            id: flickableScroll
            anchors.right: table.right
            anchors.rightMargin: -14
            anchors.top: table.top
            anchors.bottom: table.bottom
            flickable: table
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
            model: root.model
        }
    }
}
