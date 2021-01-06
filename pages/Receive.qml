// Copyright (c) 2014-2018, The Monero Project
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

import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import FontAwesome 1.0

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

import moneroComponents.Clipboard 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionHistoryModel 1.0
import moneroComponents.Subaddress 1.0
import moneroComponents.SubaddressModel 1.0
import "../js/TxUtils.js" as TxUtils

Rectangle {
    id: pageReceive
    color: "transparent"
    property var model
    property alias receiveHeight: mainLayout.height
    property var freshAddressAccount
    property int freshAddressIndex
    property var freshAddressLabel
    property var freshAddress

    Clipboard { id: clipboard }

    /* main layout */
    RowLayout {
        id: mainLayout
        anchors.margins: 20
        anchors.topMargin: 40

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20

        ColumnLayout {
            id: leftColumn
            spacing: 0
            Layout.alignment: Qt.AlignTop 

            RowLayout {
                MoneroComponents.Label {
                    id: receivePaymentTitleLabel
                    fontSize: 24
                    text: qsTr("Receive payment") + translationManager.emptyString
                }
                
                MoneroComponents.Label {
                    id: iconLabel
                    fontSize: 12
                    text: FontAwesome.questionCircle
                    fontFamily: FontAwesome.fontFamily
                    opacity: 0.3
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: helpText.visible = !helpText.visible
                        onEntered: parent.opacity = 0.4
                        onExited: parent.opacity = 0.3
                    }
                }
            }
            
            MoneroComponents.TextPlain {
                id: helpText
                Layout.leftMargin: 5
                Layout.fillWidth: true
                Layout.maximumWidth: leftColumn.width
                visible: false
                text: {
                    "<style type='text/css'>p{line-height:20px; margin-top:0px; margin-bottom:0px; color:#ffffff;}</style>" +
                    "<p>" + qsTr("- Never give the same address to more than one sender!") + "</p>" +
                    "<p>" + qsTr("- You must use a fresh address for every new sender.") + "</p>" +
                    "<p>" + qsTr("- You don't have to use a fresh address for every new payment/transaction.") + "</p>" +
                    "<p>" + qsTr("- Use the address label to note the sender you gave the address to and/or the payment purpose.") + "</p>" + translationManager.emptyString
                }
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: MoneroComponents.Style.defaultFontColor
            }

            ColumnLayout {
                id: freshAddressColumn
                visible: true
                Layout.topMargin: 10

                MoneroComponents.TextPlain {
                    id: freshAddressLabel
                    text: {
                        if (appWindow.currentWallet) {
                            if (appWindow.currentWallet.currentSubaddressAccount == 0 && pageReceive.freshAddressIndex == 0 && rightColumn.visible == false) {
                                qsTr("Fresh address (click below to see the full address)") + translationManager.emptyString
                            } else {
                                qsTr("Fresh address") + translationManager.emptyString
                            }
                        } else {
                            qsTr("Fresh address") + translationManager.emptyString
                        }
                    }
                    Layout.fillWidth: true
                    color: MoneroComponents.Style.defaultFontColor
                    font.pixelSize: 15
                    font.family: MoneroComponents.Style.fontRegular.name
                    themeTransition: false
                }

                Rectangle {
                    id: freshAddressTableItem2
                    height: subaddressListRow.subaddressListItemHeight
                    width: parent.width
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    color: "transparent"
    
                    Rectangle {
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.top: parent.top
                        height: 1
                        color: MoneroComponents.Style.appWindowBorderColor
  
                        MoneroEffects.ColorTransition {
                            targetObj: parent
                            blackColor: MoneroComponents.Style._b_appWindowBorderColor
                            whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                        }
                    }
  
                    RowLayout {
                        Layout.topMargin: 5
                        Layout.rightMargin: 5
  
                        MoneroComponents.Label {
                            id: idLabelb
                            color: appWindow.current_subaddress_table_index === pageReceive.freshAddressIndex ? MoneroComponents.Style.defaultFontColor : "#757575"
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 6
                            width: 27
                            fontSize: 16
                            text: {
                                var freshAddressIndex = pageReceive.freshAddressIndex;
                                "#" + freshAddressIndex  
                            }
                            themeTransition: false
                        }
                        
                        ColumnLayout {
                            spacing: 0
                            Layout.leftMargin: 11
                            
                            MoneroComponents.Label {
                                Layout.topMargin: 6
                                color: MoneroComponents.Style.dimmedFontColor
                                fontSize: 15
                                text: {
                                    if (pageReceive.freshAddressIndex == 0) {
                                         qsTr("Primary address") + translationManager.emptyString;
                                    } else {
                                         pageReceive.freshAddressLabel == "" ? qsTr("(no label)") : pageReceive.freshAddressLabel + translationManager.emptyString;    
                                    }                                  
                                }
                                elide: Text.ElideRight
                                textWidth: 300
                                themeTransition: false
                            }
      
                            MoneroComponents.Label {
                                Layout.topMargin: 3
                                color: MoneroComponents.Style.defaultFontColor
                                fontSize: 15
                                fontFamily: MoneroComponents.Style.fontMonoRegular.name;
                                text: TxUtils.addressTruncatePretty(pageReceive.freshAddress, 2)
                                themeTransition: false
                            }
                        }
                    }
                    
                    RowLayout {
                        id: freshAddressButtonsRow
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 15
                        height: 21
                        spacing: 10
  
                        MoneroComponents.IconButton {
                            image: "qrc:///images/edit.svg"
                            color: MoneroComponents.Style.defaultFontColor
                            opacity: 0.5
                            Layout.preferredWidth: 23
                            Layout.preferredHeight: 21
                            visible: pageReceive.freshAddressIndex > 0
                            onClicked: {
                                renameSubaddressLabel(pageReceive.freshAddressIndex);
                            }
                        }
  
                        MoneroComponents.IconButton {
                            image: "qrc:///images/copy.svg"
                            color: MoneroComponents.Style.defaultFontColor
                            opacity: 0.5
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 21
                            onClicked: {
                                clipboard.setText(pageReceive.freshAddress);
                                if (pageReceive.freshAddressLabel == "") {
                                    appWindow.showStatusMessage(qsTr("Fresh address copied to clipboard") + translationManager.emptyString, 3);  
                                } else {
                                    appWindow.showStatusMessage(qsTr("Fresh address (%1) copied to clipboard").arg(pageReceive.freshAddressLabel) + translationManager.emptyString, 3);  
                                }
                                createAddressInBackground();
                            }
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        height: 1
                        color: MoneroComponents.Style.appWindowBorderColor
  
                        MoneroEffects.ColorTransition {
                            targetObj: parent
                            blackColor: MoneroComponents.Style._b_appWindowBorderColor
                            whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                        }
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        width: freshAddressTableItem2.width - freshAddressButtonsRow.width - 15 //rightMargin of freshAddressButtonsRow
                        Layout.rightMargin: 15
                        height: freshAddressTableItem2.height
                        hoverEnabled: true
                        onEntered: freshAddressTableItem2.color = MoneroComponents.Style.titleBarButtonHoverColor
                        onExited: freshAddressTableItem2.color = "transparent"
                        onClicked: {
                            if (rightColumn.visible && subaddressListView.currentIndex == pageReceive.freshAddressIndex) {
                                rightColumn.visible = false;                                     
                            } else {
                                if (subaddressListView.visible) {
                                    subaddressListView.currentIndex = pageReceive.freshAddressIndex;  
                                } else {
                                    appWindow.current_subaddress_table_index = pageReceive.freshAddressIndex;
                                    appWindow.current_address = appWindow.currentWallet.address(
                                        appWindow.currentWallet.currentSubaddressAccount,
                                        pageReceive.freshAddressIndex
                                    );
                                }
                                rightColumn.visible = true;
                                createAddressInBackground();
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 7
                Layout.fillWidth: true
                            
                MoneroComponents.CheckBox2 {
                    id: previousAddressesCheckbox
                    text: qsTr("Previous addresses") + translationManager.emptyString
                    checked: false
                    onClicked: {
                        if (!subaddressListView.model) {
                            subaddressListView.model = appWindow.currentWallet.subaddressModel;
                            subaddressListView.currentIndex = pageReceive.freshAddressIndex;
                        }                        
                    } 
                }
                
                Rectangle {
                  id: spacerRetangle
                  Layout.fillWidth:true
                  color: "transparent"
                }
                
                MoneroComponents.StandardButton {
                    id: createAddressButton
                    small: true
                    text: qsTr("+ Create address") + translationManager.emptyString
                    fontSize: 13
                    onClicked: {
                        inputDialog.labelText = qsTr("Please add a label to your new address:") + translationManager.emptyString
                        inputDialog.onAcceptedCallback = function() {
                            //creates new address
                            console.log("Creating address with button");
                            if (pageReceive.freshAddressIndex == (appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1)) {
                                //current fresh address is the last created address. Creating a new address...
                                pageReceive.freshAddressLabel = inputDialog.inputText;
                                appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, pageReceive.freshAddressLabel)
                                pageReceive.freshAddressAccount = appWindow.currentWallet.currentSubaddressAccount;
                                pageReceive.freshAddressIndex = appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1
                            } else if (pageReceive.freshAddressIndex < (appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1)) {
                                //current fresh address is not the last created address. Displaying the last created address...
                                pageReceive.freshAddressAccount = appWindow.currentWallet.currentSubaddressAccount;
                                pageReceive.freshAddressIndex = appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1
                                if (inputDialog.inputText != "") {
                                    pageReceive.freshAddressLabel = inputDialog.inputText;
                                    appWindow.currentWallet.subaddress.setLabel(pageReceive.freshAddressAccount, pageReceive.freshAddressIndex, inputDialog.inputText);
                                } else {
                                    pageReceive.freshAddressLabel = "";
                                }
                            }
                            pageReceive.freshAddress = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, pageReceive.freshAddressIndex);
                            
                            //update the previous addresses list and select the fresh address
                            current_subaddress_table_index = pageReceive.freshAddressIndex
                            subaddressListView.currentIndex = current_subaddress_table_index
                            
                            // if created address button was clicked while rightColumn was visible, the fresh address will be displayed. Create a new address in background...
                            if (subaddressListView.currentIndex == pageReceive.freshAddressIndex && rightColumn.visible) {
                                createAddressInBackground();
                            }
                            
                            if (appWindow.currentWallet) {
                                appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
                            }
                            
                        }
                        inputDialog.onRejectedCallback = null;
                        inputDialog.open()
                    }
                }
            }

            MoneroComponents.TextPlain {
                id: emptySubaddressListMessage
                text: qsTr("You haven't used any address yet") + translationManager.emptyString
                visible: previousAddressesCheckbox.checked && pageReceive.freshAddressIndex == 0
                Layout.fillWidth: true
                color: MoneroComponents.Style.defaultFontColor
                font.pixelSize: 15
                font.family: MoneroComponents.Style.fontRegular.name
                themeTransition: false
            }

            ColumnLayout {
                id: subaddressListRow
                property int subaddressListItemHeight: 50
                visible: previousAddressesCheckbox.checked && pageReceive.freshAddressIndex > 0
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 6
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.maximumHeight: subaddressListRow.Layout.preferredHeight
                ListView {
                    id: subaddressListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: pageReceive.freshAddressIndex
                    clip: true
                    cacheBuffer: 50000
                    boundsBehavior: ListView.StopAtBounds
                    interactive: true
                    verticalLayoutDirection: ListView.BottomToTop
                    highlightMoveDuration: 0
                    ScrollBar.vertical: ScrollBar {
                        id: scrollBarSubaddressListView
                        onActiveChanged: if (!active && !isMac) active = true
                    }

                    delegate: Rectangle {
                        id: tableItem2
                        height: {
                            if (displayOnlyPreviousAddressesWithLabelCheckBox.checked) {
                                if (index < pageReceive.freshAddressIndex && label) {
                                    return subaddressListRow.subaddressListItemHeight;
                                } else {
                                    return 0;
                                }
                            } else {
                                if (index < pageReceive.freshAddressIndex) {
                                    return subaddressListRow.subaddressListItemHeight;
                                } else {
                                    return 0;
                                }
                            }
                        }
                        width: parent ? parent.width : undefined
                        Layout.fillWidth: true
                        color: "transparent"
                        visible: {
                            if (displayOnlyPreviousAddressesWithLabelCheckBox.checked) {
                              if (index < pageReceive.freshAddressIndex && label) {
                                  return true;
                              } else {
                                  return false;
                              }
                            } else {
                              if (index < pageReceive.freshAddressIndex) {
                                  return true;
                              } else {
                                  return false;
                              }
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 1
                            color: MoneroComponents.Style.appWindowBorderColor

                            MoneroEffects.ColorTransition {
                                targetObj: parent
                                blackColor: MoneroComponents.Style._b_appWindowBorderColor
                                whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                            }
                        }

                        RowLayout {
                            id: itemRow
                            Layout.topMargin: 5
                            Layout.rightMargin: 5

                            MoneroComponents.Label {
                                id: idLabel
                                color: index === appWindow.current_subaddress_table_index ? MoneroComponents.Style.defaultFontColor : "#757575"
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 6
                                width: 27
                                fontSize: 16
                                text: "#" + index
                                themeTransition: false
                            }

                            ColumnLayout {
                                spacing: 0
                                Layout.leftMargin: 11

                                MoneroComponents.Label {
                                    id: nameLabel
                                    Layout.topMargin: 6
                                    color: MoneroComponents.Style.dimmedFontColor
                                    fontSize: 15
                                    text: {
                                        if (index == 0) {
                                            qsTr("Primary address")  + translationManager.emptyString
                                        } else {
                                            if (label) {
                                                label
                                            } else {
                                                qsTr("(no label)") + translationManager.emptyString
                                            }
                                        }
                                    }
                                    elide: Text.ElideRight
                                    textWidth: 300
                                    themeTransition: false
                                }

                                MoneroComponents.Label {
                                    id: addressLabel
                                    Layout.topMargin: 3
                                    color: MoneroComponents.Style.defaultFontColor
                                    fontSize: 15
                                    fontFamily: MoneroComponents.Style.fontMonoRegular.name;
                                    text: TxUtils.addressTruncatePretty(address, 2)
                                    themeTransition: false
                                }
                            }
                        }

                        RowLayout {
                            id: buttonsRow
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            height: 21
                            spacing: 10
                            visible: index == pageReceive.freshAddressIndex ? false : true

                            MoneroComponents.IconButton {
                                id: renameButton
                                image: "qrc:///images/edit.svg"
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 23
                                Layout.preferredHeight: 21
                                visible: index !== 0

                                onClicked: {
                                    renameSubaddressLabel(index);
                                }
                            }

                            MoneroComponents.IconButton {
                                id: copyButton
                                image: "qrc:///images/copy.svg"
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 21

                                onClicked: {
                                    console.log("Address copied to clipboard");
                                    clipboard.setText(address);
                                    if (label == "") {
                                        appWindow.showStatusMessage(qsTr("Address copied to clipboard") + translationManager.emptyString, 3);  
                                    } else {
                                        appWindow.showStatusMessage(qsTr("Address (%1) copied to clipboard").arg(label) + translationManager.emptyString, 3);  
                                    }
                                    if (index == pageReceive.freshAddressIndex) {
                                        createAddressInBackground();
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            height: 1
                            color: MoneroComponents.Style.appWindowBorderColor
                            visible: index == 0

                            MoneroEffects.ColorTransition {
                                targetObj: parent
                                blackColor: MoneroComponents.Style._b_appWindowBorderColor
                                whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                            }
                        }
                        
                        MouseArea {
                            cursorShape: Qt.PointingHandCursor
                            width: tableItem2.width - buttonsRow.width - 15 //rightMargin of buttonsRow
                            Layout.rightMargin: 15
                            height: tableItem2.height
                            hoverEnabled: true
                            onEntered: tableItem2.color = MoneroComponents.Style.titleBarButtonHoverColor
                            onExited: tableItem2.color = "transparent"
                            onClicked: {
                                if (rightColumn.visible && subaddressListView.currentIndex == index) {
                                    rightColumn.visible = false;                                     
                                } else {
                                    subaddressListView.currentIndex = index;
                                    if (subaddressListView.currentIndex == pageReceive.freshAddressIndex) {
                                        createAddressInBackground();
                                    }
                                    rightColumn.visible = true;  
                                }
                            }
                        }
                    }
                    onCountChanged: {
                        if (subaddressListView.contentHeight <= 400) {
                            subaddressListRow.Layout.preferredHeight = subaddressListView.contentHeight;
                        } else {
                            subaddressListRow.Layout.preferredHeight = 401;
                        }
                    }       
                    onCurrentItemChanged: {
                        // reset global vars
                        appWindow.current_subaddress_table_index = subaddressListView.currentIndex;
                        appWindow.current_address = appWindow.currentWallet.address(
                            appWindow.currentWallet.currentSubaddressAccount,
                            subaddressListView.currentIndex
                        );
                        if (subaddressListView.currentIndex == 0) {
                            addressLabelRightColumn.text = qsTr("Primary address") + translationManager.emptyString;
                        } else {
                            var selectedAddressLabel = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, appWindow.current_subaddress_table_index);
                            if (selectedAddressLabel == "") {
                                addressLabelRightColumn.text = qsTr("(no label)") + translationManager.emptyString
                            } else {
                                addressLabelRightColumn.text = selectedAddressLabel
                            }
                        }
                    }
                }
            }
            
            MoneroComponents.CheckBox {
                id: displayOnlyPreviousAddressesWithLabelCheckBox
                Layout.topMargin: 10
                visible: subaddressListRow.visible
                checked: false
                text: qsTr("Display only addresses with label") + translationManager.emptyString
                onClicked: {
                    if (appWindow.currentWallet) {
                        appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
                    }
                }
            }
        }

        ColumnLayout {
            id: rightColumn
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: 75
            spacing: 11
            property int qrSize: 220
            visible: false

            Rectangle {
                id: qrContainer
                color: MoneroComponents.Style.blackTheme ? "white" : "transparent"
                Layout.fillWidth: true
                Layout.maximumWidth: parent.qrSize
                Layout.preferredHeight: width
                radius: 4

                Image {
                    id: qrCode
                    anchors.fill: parent
                    anchors.margins: 1

                    smooth: false
                    fillMode: Image.PreserveAspectFit
                    source: "image://qrcode/" + TxUtils.makeQRCodeString(appWindow.current_address)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onPressAndHold: qrFileDialog.open()
                    }
                }
            }

            MoneroComponents.TextPlain {
                id: addressIndexRightColumn
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.qrSize
                text: qsTr("Address #") + subaddressListView.currentIndex + translationManager.emptyString
                wrapMode: Text.WordWrap
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 17
                textFormat: Text.RichText
                color: MoneroComponents.Style.defaultFontColor
                themeTransition: false
            }
            
            MoneroComponents.TextPlain {
                id: addressLabelRightColumn
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.qrSize
                text: "no label"
                wrapMode: Text.WordWrap
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 17
                textFormat: Text.RichText
                color: MoneroComponents.Style.dimmedFontColor
                themeTransition: false
                MouseArea {
                    visible: subaddressListView.currentIndex > 0
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.color = MoneroComponents.Style.orange
                    onExited: parent.color = MoneroComponents.Style.dimmedFontColor
                    onClicked: {
                        renameSubaddressLabel(appWindow.current_subaddress_table_index);
                    }
                }
            }

            MoneroComponents.TextPlain {
                id: addressRightColumn
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.qrSize
                text: appWindow.current_address ? appWindow.current_address : ""
                horizontalAlignment: TextInput.AlignHCenter
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                color: MoneroComponents.Style.defaultFontColor
                font.pixelSize: 15
                font.family: MoneroComponents.Style.fontRegular.name
                themeTransition: false
                MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.color = MoneroComponents.Style.orange
                    onExited: parent.color = MoneroComponents.Style.defaultFontColor
                    onClicked: {
                        clipboard.setText(appWindow.current_address);
                        if (subaddressListView.currentIndex == pageReceive.freshAddressIndex) {
                            if (pageReceive.freshAddressLabel == "") {
                                appWindow.showStatusMessage(qsTr("Fresh address copied to clipboard") + translationManager.emptyString, 3);  
                            } else {
                                appWindow.showStatusMessage(qsTr("Fresh address (%1) copied to clipboard").arg(pageReceive.freshAddressLabel) + translationManager.emptyString, 3);  
                            }
                        } else {
                            var selectedAddressLabel = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, subaddressListView.currentIndex);
                            if (selectedAddressLabel == "") {
                                appWindow.showStatusMessage(qsTr("Address copied to clipboard") + translationManager.emptyString, 3);
                            } else {
                                appWindow.showStatusMessage(qsTr("Address (%1) copied to clipboard").arg(selectedAddressLabel) + translationManager.emptyString, 3);  
                            }
                        }
                    }
                }
            }

            MoneroComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: qsTr("Save as image") + translationManager.emptyString
                fontSize: 14
                onClicked: qrFileDialog.open()
            }

            MoneroComponents.StandardButton {
                Layout.preferredWidth: 220
                enabled: subaddressListView.currentIndex > 0
                small: true
                text: qsTr("Edit label") + translationManager.emptyString
                fontSize: 14
                onClicked: renameSubaddressLabel(appWindow.current_subaddress_table_index);
            }

            MoneroComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: qsTr("Copy to clipboard") + translationManager.emptyString
                fontSize: 14
                onClicked: {
                    clipboard.setText(appWindow.current_address);
                    if (subaddressListView.currentIndex == pageReceive.freshAddressIndex) {
                        if (pageReceive.freshAddressLabel == "") {
                            appWindow.showStatusMessage(qsTr("Fresh address copied to clipboard") + translationManager.emptyString, 3);  
                        } else {
                            appWindow.showStatusMessage(qsTr("Fresh address (%1) copied to clipboard").arg(pageReceive.freshAddressLabel) + translationManager.emptyString, 3);  
                        }
                    } else {
                        var selectedAddressLabel = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, subaddressListView.currentIndex);
                        if (selectedAddressLabel == "") {
                            appWindow.showStatusMessage(qsTr("Address copied to clipboard") + translationManager.emptyString, 3);
                        } else {
                            appWindow.showStatusMessage(qsTr("Address (%1) copied to clipboard").arg(selectedAddressLabel) + translationManager.emptyString, 3);  
                        }
                    }
                }
            }

            MoneroComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: qsTr("Show on device") + translationManager.emptyString
                fontSize: 14
                visible: appWindow.currentWallet ? appWindow.currentWallet.isHwBacked() : false
                onClicked: {
                    appWindow.currentWallet.deviceShowAddressAsync(
                        appWindow.currentWallet.currentSubaddressAccount,
                        appWindow.current_subaddress_table_index,
                        '');
                }
            }
        }

        MessageDialog {
            id: receivePageDialog
            standardButtons: StandardButton.Ok
        }

        FileDialog {
            id: qrFileDialog
            title: qsTr("Please choose a name") + translationManager.emptyString
            folder: shortcuts.pictures
            selectExisting: false
            nameFilters: ["Image (*.png)"]
            onAccepted: {
                if(!walletManager.saveQrCode(TxUtils.makeQRCodeString(appWindow.current_address), walletManager.urlToLocalPath(fileUrl))) {
                    console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                    receivePageDialog.title = qsTr("Save QrCode") + translationManager.emptyString;
                    receivePageDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                    receivePageDialog.icon = StandardIcon.Error
                    receivePageDialog.open()
                }
            }
        }
    }

    function createAddressInBackground() {
        console.log("Entered createAddressInBackground()")
        //if fresh address is the last created address, then create a new address...
        if (pageReceive.freshAddressIndex == (appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1)) {
            appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, "")  
        }
    }

    function renameSubaddressLabel(_index) {
        inputDialog.labelText = qsTr("Set the label of the selected address:") + translationManager.emptyString;
        inputDialog.onAcceptedCallback = function() {
            var ScrollBarPositionBeforeSettingLabel = scrollBarSubaddressListView.position;
            appWindow.currentWallet.subaddress.setLabel(appWindow.currentWallet.currentSubaddressAccount, _index, inputDialog.inputText);
            if (_index == freshAddressIndex) {
                //editing label of fresh address
                pageReceive.freshAddressLabel = inputDialog.inputText;
            } else {
                //editing label of previous address
                scrollBarSubaddressListView.position = ScrollBarPositionBeforeSettingLabel;
            }
        }
        inputDialog.onRejectedCallback = null;
        inputDialog.open(appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, _index))
    }

    function onPageCompleted() {
        console.log("Receive page loaded");

        //set the fresh address (first row)
        pageReceive.freshAddressAccount = appWindow.currentWallet.currentSubaddressAccount;
        pageReceive.freshAddressIndex = appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1
        pageReceive.freshAddressLabel = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, pageReceive.freshAddressIndex);
        pageReceive.freshAddress = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, pageReceive.freshAddressIndex);         

        subaddressListView.currentIndex = pageReceive.freshAddressIndex;
        appWindow.current_subaddress_table_index = pageReceive.freshAddressIndex;

        //set appWindow.current_address, which is used in Merchant page 
        //TODO: remove this after redesigning merchant page to create a new address for every transaction
        if (appWindow.currentWallet) {
            appWindow.current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, 0)
            appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
        }

        //display Receive page instructions for the first 3 generated addresses
        if (appWindow.currentWallet.currentSubaddressAccount == 0 && pageReceive.freshAddressIndex < 4) {
            helpText.visible = true;
        }
    }

    function clearFields() {
        // @TODO: add fields
    }

    function onPageClosed() {
        helpText.visible = false;
        subaddressListView.model = "";
        previousAddressesCheckbox.checked = false;
        rightColumn.visible = false;
        displayOnlyPreviousAddressesWithLabelCheckBox.checked = false;
        console.log("Receive page closed");       
    }
}
