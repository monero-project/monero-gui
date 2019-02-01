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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionInfo 1.0
import moneroComponents.TransactionHistoryModel 1.0

import "../components"

Rectangle {
    id: mainLayout
    property var model
    property int tableHeight: !isMobile ? table.contentHeight : tableMobile.contentHeight

    QtObject {
        id: d
        property bool initialized: false
    }

    color: "transparent"

    function getSelectedAmount() {
      if (typeof model === 'undefined' || model == null)
        return ""
      var total = 0
      var count = model.rowCount()
      for (var i = 0; i < count; ++i) {
          var idx = model.index(i, 0)
          var isout = model.data(idx, TransactionHistoryModel.TransactionIsOutRole);
          var amount = model.data(idx, TransactionHistoryModel.TransactionAtomicAmountRole);
          if (isout)
              total = walletManager.subi(total, amount)
          else
              total = walletManager.addi(total, amount)
      }

      var sign = ""
      if (total < 0) {
        total = -total
        sign = "-"
      }
      return count + qsTr(" selected: ") + sign + walletManager.displayAmount(total);
    }

    function resetFilter(model) {
        model.dateFromFilter = "2014-04-18" // genesis block
        model.dateToFilter = "9999-09-09" // fix before september 9999
        // negative values disable filters here;
        model.amountFromFilter = -1;
        model.amountToFilter = -1;
        model.directionFilter = TransactionInfo.Direction_Both;
    }

    onModelChanged: {
        if (typeof model !== 'undefined' && model != null) {
            if (!d.initialized) {
                // setup date filter scope according to real transactions
                fromDatePicker.currentDate = model.transactionHistory.firstDateTime
                toDatePicker.currentDate = model.transactionHistory.lastDateTime

                model.sortRole = TransactionHistoryModel.TransactionBlockHeightRole
                model.sort(0, Qt.DescendingOrder);
                d.initialized = true
            }
        }
    }

    function onFilterChanged() {
        // set datepicker error states
        var datesValid = fromDatePicker.currentDate <= toDatePicker.currentDate
        fromDatePicker.error = !datesValid;
        toDatePicker.error = !datesValid;

        if(datesValid){
            resetFilter(model)

            if (fromDatePicker.currentDate > toDatePicker.currentDate) {
                console.error("Invalid date filter set: ", fromDatePicker.currentDate, toDatePicker.currentDate)
            } else {
                model.dateFromFilter  = fromDatePicker.currentDate
                model.dateToFilter    = toDatePicker.currentDate
            }

            model.searchFilter = searchLine.text;
            tableHeader.visible = model.rowCount() > 0;
        }
    }

    Rectangle{
        id: rootLayout
        visible: false
    }

    ColumnLayout {
        id: pageRoot
        anchors.margins: isMobile ? 17 : 20 * scaleRatio
        anchors.topMargin: isMobile ? 0 : 40 * scaleRatio

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 10 * scaleRatio

        GridLayout {
            property int column_width: {
                if(!isMobile){
                    return (parent.width / 2) - 20;
                } else {
                    return parent.width - 20;
                }
            }

            columns: 2
            Layout.fillWidth: true

            RowLayout {
                visible: !isMobile
                Layout.preferredWidth: parent.column_width

                StandardButton {
                    visible: !isIOS
                    small: true
                    text: qsTr("Export") + translationManager.emptyString
                    onClicked: {
                        writeCSVFileDialog.open();
                    }
                }
            }

            RowLayout {
                Layout.preferredWidth: parent.column_width
                LineEdit {
                    id: searchLine
                    fontSize: 14 * scaleRatio
                    inputHeight: 36 * scaleRatio
                    borderDisabled: true
                    Layout.fillWidth: true
                    backgroundColor: "#404040"
                    placeholderText: qsTr("Search") + translationManager.emptyString
                    placeholderCenter: true
                    onTextChanged:  {
                        onFilterChanged();
                    }
                }
            }
        }

        GridLayout {
            z: 6
            columns: (isMobile)? 1 : 3
            Layout.fillWidth: true
            columnSpacing: 22 * scaleRatio
            visible: !isMobile

            ColumnLayout {
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    id: fromDateRow
                    Layout.minimumWidth: 150 * scaleRatio

                    DatePicker {
                        visible: !isMobile

                        id: fromDatePicker
                        Layout.fillWidth: true
                        width: 100 * scaleRatio
                        inputLabel.text: qsTr("Date from") + translationManager.emptyString

                        onCurrentDateChanged: {
                            onFilterChanged()
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    id: toDateRow
                    Layout.minimumWidth: 150 * scaleRatio

                    DatePicker {
                        visible: !isMobile

                        id: toDatePicker
                        Layout.fillWidth: true
                        width: 100 * scaleRatio
                        inputLabel.text: qsTr("Date to") + translationManager.emptyString

                        onCurrentDateChanged: {
                            onFilterChanged()
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                Label {
                    id: transactionPriority
                    Layout.minimumWidth: 120 * scaleRatio
                    text: qsTr("Sort") + translationManager.emptyString
                    fontSize: 14
                }

                ListModel {
                     id: priorityModelV5

                     ListElement { column1: qsTr("Block height") ; column2: "";}
                     ListElement { column1: qsTr("Date") ; column2: ""; }
                 }

                StandardDropdown {
                    id: priorityDropdown
                    anchors.topMargin: 2 * scaleRatio
                    fontHeaderSize: 14 * scaleRatio
                    dropdownHeight: 28 * scaleRatio

                    Layout.fillWidth: true
                    shadowReleasedColor: "#FF4304"
                    shadowPressedColor: "#B32D00"
                    releasedColor: "#404040"
                    pressedColor: "#202020"
                    colorBorder: "#404040"
                    colorHeaderBackground: "#404040"

                    onChanged: {
                        switch(priorityDropdown.currentIndex){
                            case 0:
                                // block sort
                                model.sortRole = TransactionHistoryModel.TransactionBlockHeightRole;
                                break;
                            case 1:
                                // amount sort
                                model.sortRole = TransactionHistoryModel.TransactionDateRole;
                                break;
                        }
                        model.sort(0, Qt.DescendingOrder);
                    }

                }
            }
        }

        GridLayout {
            Layout.topMargin: 20
            visible: table.count === 0

            Label {
                fontSize: 16 * scaleRatio
                text: qsTr("No history...") + translationManager.emptyString
            }
        }

        GridLayout {
            id: tableHeader
            columns: 1
            columnSpacing: 0
            rowSpacing: 0
            Layout.topMargin: 20
            Layout.fillWidth: true

            RowLayout{
                Layout.preferredHeight: 10
                Layout.fillWidth: true

                Rectangle {
                    id: header
                    Layout.fillWidth: true
                    visible: table.count > 0

                    height: 10
                    color: "transparent"

                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.leftMargin: 10

                        height: 1
                        color: "#404040"
                    }

                    Image {
                        anchors.top: parent.top
                        anchors.left: parent.left

                        width: 10
                        height: 10

                        source: "../images/historyBorderRadius.png"
                    }

                    Image {
                        anchors.top: parent.top
                        anchors.right: parent.right

                        width: 10
                        height: 10

                        source: "../images/historyBorderRadius.png"
                        rotation: 90
                    }
                }
            }

            RowLayout {
                Layout.preferredHeight: isMobile ? tableMobile.contentHeight : table.contentHeight
                Layout.fillWidth: true
                Layout.fillHeight: true

                HistoryTable {
                    id: table
                    visible: !isMobile
                    onContentYChanged: flickableScroll.flickableContentYChanged()
                    model: !isMobile ? mainLayout.model : null
                    addressBookModel: null

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                HistoryTableMobile {
                    id: tableMobile
                    visible: isMobile
                    onContentYChanged: flickableScroll.flickableContentYChanged()
                    model: isMobile ? mainLayout.model : null
                    addressBookModel: null

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    FileDialog {
        id: writeCSVFileDialog
        title: "Please choose a folder"
        selectFolder: true
        onRejected: {
            console.log("csv write canceled")
        }
        onAccepted: {
            var dataDir = walletManager.urlToLocalPath(writeCSVFileDialog.fileUrl);
            var written = currentWallet.history.writeCSV(currentWallet.currentSubaddressAccount, dataDir);

            if(written !== ""){
                informationPopup.title = qsTr("Success") + translationManager.emptyString;
                var text = qsTr("CSV file written to: %1").arg(written) + "\n\n"
                text += qsTr("Tip: Use your favorite spreadsheet software to sort on blockheight.") + "\n\n" + translationManager.emptyString;
                informationPopup.text = text;
                informationPopup.icon = StandardIcon.Information;
            } else {
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                informationPopup.text = qsTr("Error exporting transaction data.") + "\n\n" + translationManager.emptyString;
                informationPopup.icon = StandardIcon.Critical;
            }
            informationPopup.onCloseCallback = null;
            informationPopup.open();
        }
        Component.onCompleted: {
            var _folder = 'file://' + moneroAccountsDir;
            try {
                _folder = 'file://' + desktopFolder;
            }
            catch(err) {}
            finally {
                writeCSVFileDialog.folder = _folder;
            }
        }
    }

    function onPageCompleted() {
        if(currentWallet != null && typeof currentWallet.history !== "undefined" ) {
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
            table.addressBookModel = currentWallet ? currentWallet.addressBookModel : null
            //transactionTypeDropdown.update()
        }

        priorityDropdown.dataModel = priorityModelV5;
        priorityDropdown.currentIndex = 0;
        priorityDropdown.update();
    }

    function update() {
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
    }
}
