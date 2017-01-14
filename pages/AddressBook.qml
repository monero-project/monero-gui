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
import "../components"
import moneroComponents.AddressBook 1.0
import moneroComponents.AddressBookModel 1.0

Rectangle {
    color: "#F0EEEE"
    id: root
    property var model

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
        text: qsTr("Add new entry") + translationManager.emptyString
    }

    Label {
        id: addressLabel
        anchors.left: parent.left
        anchors.top: newEntryText.bottom
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
        error: true;
    }

    Label {
        id: paymentIdLabel
        anchors.left: parent.left
        anchors.top: addressLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        text: qsTr("Payment ID <font size='2'>(Optional)</font>") + translationManager.emptyString
        fontSize: 14
        tipText: qsTr("<b>Payment ID</b><br/><br/>A unique user name used in<br/>the address book. It is not a<br/>transfer of information sent<br/>during the transfer")
                + translationManager.emptyString
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
        text: qsTr("Description <font size='2'>(Local database)</font>") + translationManager.emptyString
        fontSize: 14
        tipText: qsTr("<b>Tip test test</b><br/><br/>test line 2") + translationManager.emptyString
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
        enabled: checkInformation(addressLine.text, paymentIdLine.text, appWindow.persistentSettings.testnet)

        onClicked: {
            if (!currentWallet.addressBook.addRow(addressLine.text.trim(), paymentIdLine.text.trim(), descriptionLine.text)) {
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                // TODO: check currentWallet.addressBook.errorString() instead.
                if(currentWallet.addressBook.errorCode() === AddressBook.Invalid_Address)
                     informationPopup.text  = qsTr("Invalid address")
                else if(currentWallet.addressBook.errorCode() === AddressBook.Invalid_Payment_Id)
                     informationPopup.text  = currentWallet.addressBook.errorString()
                else
                     informationPopup.text  = qsTr("Can't create entry")

                informationPopup.onCloseCallback = null
                informationPopup.open();
            } else {
                addressLine.text = "";
                paymentIdLine.text = "";
                descriptionLine.text = "";
            }
        }
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
//            ListElement { columnName: qsTr("Address") + translationManager.emptyString; columnWidth: 148 }
//            ListElement { columnName: qsTr("Payment ID") + translationManager.emptyString; columnWidth: 148 }
//            ListElement { columnName: qsTr("Description") + translationManager.emptyString; columnWidth: 148 }
//
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
            anchors.right: table.right
            anchors.rightMargin: -14
            anchors.top: table.top
            anchors.bottom: table.bottom
            flickable: table
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
            model: root.model
        }
    }

    function checkInformation(address, payment_id, testnet) {
      address = address.trim()
      payment_id = payment_id.trim()

      var address_ok = walletManager.addressValid(address, testnet)
      var payment_id_ok = payment_id.length == 0 || walletManager.paymentIdValid(payment_id)
      var ipid = walletManager.paymentIdFromAddress(address, testnet)
      if (ipid.length > 0 && payment_id.length > 0)
         payment_id_ok = false

      addressLine.error = !address_ok
      paymentIdLine.error = !payment_id_ok

      return address_ok && payment_id_ok
    }

    function onPageCompleted() {
        console.log("adress book");
        root.model = currentWallet.addressBookModel;
    }


}
