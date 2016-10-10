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
import moneroComponents.PendingTransaction 1.0
import "../components"


Rectangle {
    id: root
    signal paymentClicked(string address, string paymentId, double amount, int mixinCount,
                          int priority)

    color: "#F0EEEE"

    function scaleValueToMixinCount(scaleValue) {
        var scaleToMixinCount = [2,3,4,5,5,5,6,7,8,9,10,15,20,25];
        if (scaleValue < scaleToMixinCount.length) {
            return scaleToMixinCount[scaleValue];
        } else {
            return 0;
        }
    }


    Label {
        id: amountLabel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 17
        text: qsTr("Amount") + translationManager.emptyString
        fontSize: 14
    }

    Label {
        id: transactionPriority
        anchors.top: parent.top
        anchors.topMargin: 17
        fontSize: 14
        x: (parent.width - 17) / 2 + 17
        text: qsTr("Transaction priority") + translationManager.emptyString
    }

    Row {
        id: amountRow
        anchors.top: amountLabel.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 7
        width: (parent.width - 17) / 2 + 10
        Item {
            width: 37
            height: 37

            Image {
                anchors.centerIn: parent
                source: "../images/moneroIcon.png"
            }
        }
        // Amount input
        LineEdit {
            id: amountLine
            placeholderText: qsTr("Amount...") + translationManager.emptyString
            width: parent.width - 37 - 17
            validator: DoubleValidator {
                bottom: 0.0
                notation: DoubleValidator.StandardNotation
                locale: "C"
            }
        }
    }

    ListModel {
        id: priorityModel
        // ListElement: cannot use script for property value, so
        // code like this wont work:
        // ListElement { column1: qsTr("LOW") + translationManager.emptyString ; column2: ""; priority: PendingTransaction.Priority_Low }

        ListElement { column1: qsTr("LOW") ; column2: ""; priority: PendingTransaction.Priority_Low }
        ListElement { column1: qsTr("MEDIUM") ; column2: ""; priority: PendingTransaction.Priority_Medium }
        ListElement { column1: qsTr("HIGH")  ; column2: "";  priority: PendingTransaction.Priority_High }
    }

    StandardDropdown {
        id: priorityDropdown
        anchors.top: transactionPriority.bottom
        anchors.right: parent.right
        anchors.rightMargin: 17
        anchors.topMargin: 5
        anchors.left: transactionPriority.left
        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        dataModel: priorityModel
        z: 1
    }



    Label {
        id: privacyLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: amountRow.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 30
        fontSize: 14
        text: qsTr("Privacy Level") + translationManager.emptyString
    }

    PrivacyLevel {
        id: privacyLevelItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: privacyLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
        onFillLevelChanged: {
            print ("PrivacyLevel changed:"  + fillLevel)
            print ("mixin count:"  + scaleValueToMixinCount(fillLevel))
        }
    }


    Label {
        id: costLabel
        anchors.right: parent.right
        anchors.top: amountRow.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 30
        fontSize: 14
        text: qsTr("Cost")
    }


    Label {
        id: addressLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: privacyLevelItem.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 30
        fontSize: 14
        textFormat: Text.RichText
        text: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>\
                    Address <font size='2'>  ( Type in  or select from </font> <a href='#'>Address</a><font size='2'> book )</font>")
              + translationManager.emptyString

        onLinkActivated: appWindow.showPageRequest("AddressBook")
    }
    // recipient address input
    LineEdit {
        id: addressLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: addressLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
        // validator: RegExpValidator { regExp: /[0-9A-Fa-f]{95}/g }
    }

    Label {
        id: paymentIdLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: addressLine.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 17
        fontSize: 14
        text: qsTr("Payment ID <font size='2'>( Optional )</font>") + translationManager.emptyString
    }

    // payment id input
    LineEdit {
        id: paymentIdLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: paymentIdLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
        // validator: DoubleValidator { top: 0.0 }
    }

    Label {
        id: descriptionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: paymentIdLine.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 17
        fontSize: 14
        text: qsTr("Description <font size='2'>( An optional description that will be saved to the local address book if entered )</font>")
              + translationManager.emptyString
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
        id: sendButton
        anchors.left: parent.left
        anchors.top: descriptionLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        width: 60
        text: qsTr("SEND") + translationManager.emptyString
        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        enabled : addressLine.text.length > 0 && amountLine.text.length > 0
        onClicked: {
            console.log("Transfer: paymentClicked")
            var priority = priorityModel.get(priorityDropdown.currentIndex).priority
            console.log("priority: " + priority)
            console.log("amount: " + amountLine.text)
            addressLine.text = addressLine.text.trim()
            paymentIdLine.text = paymentIdLine.text.trim()
            root.paymentClicked(addressLine.text, paymentIdLine.text, amountLine.text, scaleValueToMixinCount(privacyLevelItem.fillLevel),
                           priority)

        }
    }
}
