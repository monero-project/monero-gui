// Copyright (c) 2014-2024, The Monero Project
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
import QtGraphicalEffects 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionInfo 1.0
import moneroComponents.TransactionHistoryModel 1.0
import moneroComponents.Clipboard 1.0
import FontAwesome 1.0

import "../components/effects/" as MoneroEffects
import "../components" as MoneroComponents
import "../js/Utils.js" as Utils
import "../js/TxUtils.js" as TxUtils


Rectangle {
    id: root
    property var model
    property int sideMargin: 50
    property var initialized: false
    property int txMax: Math.max(5, ((appWindow.height - 250) / 60))
    property int txOffset: 0
    property int txPage: (txOffset / txMax) + 1
    property int txCount: 0
    property var sortSearchString: null
    property bool sortDirection: true  // true = desc, false = asc
    property string sortBy: "blockheight"
    property var txModelData: []  // representation of transaction data (appWindow.currentWallet.historyModel)
    property var txData: []  // representation of FILTERED transation data
    property var txDataCollapsed: []  // keep track of which txs are collapsed
    property string historyStatusMessage: ""
    property alias contentHeight: pageRoot.height

    Clipboard { id: clipboard }
    ListModel { id: txListViewModel }

    color: "transparent"

    onTxMaxChanged: root.updateDisplay(root.txOffset, root.txMax);

    ColumnLayout {
        id: pageRoot
        anchors.topMargin: 40

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        RowLayout {
            Layout.preferredHeight: 24
            Layout.preferredWidth: parent.width - root.sideMargin
            Layout.leftMargin: sideMargin
            Layout.rightMargin: sideMargin
            Layout.bottomMargin: 10

            MoneroComponents.Label {
                fontSize: 24
                text: qsTr("Transactions") + translationManager.emptyString
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                id: sortAndFilter
                visible: root.txCount > 0
                property bool collapsed: false
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                Layout.preferredWidth: 100
                Layout.preferredHeight: 15
                spacing: 8

                MoneroComponents.TextPlain {
                    Layout.alignment: Qt.AlignVCenter
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    text: qsTr("Sort & filter") + translationManager.emptyString
                    color: MoneroComponents.Style.defaultFontColor

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            sortAndFilter.collapsed = !sortAndFilter.collapsed
                        }
                    }
                }

                MoneroEffects.ImageMask {
                    id: sortCollapsedIcon
                    Layout.alignment: Qt.AlignVCenter
                    height: 8
                    width: 12
                    image: "qrc:///images/whiteDropIndicator.png"
                    fontAwesomeFallbackIcon: FontAwesome.arrowDown
                    fontAwesomeFallbackSize: 14
                    rotation: sortAndFilter.collapsed ? 180 : 0
                    color: MoneroComponents.Style.defaultFontColor

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            sortAndFilter.collapsed = !sortAndFilter.collapsed
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.leftMargin: sideMargin
            Layout.rightMargin: sideMargin
            visible: sortAndFilter.collapsed

            MoneroComponents.LineEdit {
                id: searchInput
                Layout.fillWidth: true
                input.topPadding: 6
                input.bottomPadding: 6
                fontSize: 15
                labelFontSize: 14
                placeholderText: qsTr("Search by Transaction ID, Address, Description, Amount or Blockheight") + translationManager.emptyString
                placeholderFontSize: 15
                inputHeight: 34
                onTextUpdated: {
                    if (!sortAndFilter.collapsed) {
                        sortAndFilter.collapsed = true;
                    }
                    if(searchInput.text != null && searchInput.text.length >= 3){
                        root.sortSearchString = searchInput.text;
                        root.reset();
                        root.updateFilter();
                    } else {
                        root.sortSearchString = null;
                        root.reset();
                        root.updateFilter();
                    }
                }

                Rectangle {
                    color: "transparent"
                    height: cleanButton.height
                    width: cleanButton.width
                    Layout.rightMargin: -8
                    Layout.leftMargin: -2

                    MoneroComponents.InlineButton {
                        id: cleanButton
                        buttonColor: "transparent"
                        fontFamily: FontAwesome.fontFamilySolid
                        fontStyleName: "Solid"
                        fontPixelSize: 18
                        text: FontAwesome.times
                        tooltip: qsTr("Clean") + translationManager.emptyString
                        tooltipLeft: true
                        visible: searchInput.text != ""
                        onClicked: searchInput.text = ""
                    }
                }
            }
        }

        GridLayout {
            visible: sortAndFilter.collapsed
            Layout.fillWidth: true
            Layout.topMargin: 4
            Layout.leftMargin: sideMargin
            Layout.rightMargin: sideMargin
            columns: 2
            columnSpacing: 20

            MoneroComponents.DatePicker {
                id: fromDatePicker
                Layout.fillWidth: true
                width: 100
                inputLabel.text: qsTr("Date from") + translationManager.emptyString
                inputLabel.font.pixelSize: 14
                onCurrentDateChanged: {
                    if(root.initialized){
                        root.reset();
                        root.updateFilter();
                    }
                }
            }

            MoneroComponents.DatePicker {
                id: toDatePicker
                Layout.fillWidth: true
                width: 100
                inputLabel.text: qsTr("Date to") + translationManager.emptyString

                onCurrentDateChanged: {
                    if(root.initialized){
                        root.reset();
                        root.updateFilter();
                    }
                }
            }
        }

        RowLayout {
            Layout.topMargin: 20
            Layout.bottomMargin: 20
            Layout.fillWidth: true
            Layout.leftMargin: sideMargin
            Layout.rightMargin: sideMargin

            Rectangle {
                visible: sortAndFilter.collapsed
                color: "transparent"
                Layout.preferredWidth: childrenRect.width + 38
                Layout.preferredHeight: 20

                MoneroComponents.TextPlain {
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    text: qsTr("Sort by") + ":" + translationManager.emptyString
                    color: MoneroComponents.Style.defaultFontColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                visible: sortAndFilter.collapsed
                id: sortBlockheight
                color: "transparent"
                Layout.preferredWidth: sortBlockheightText.width + 42
                Layout.preferredHeight: 20

                RowLayout {
                    clip: true
                    anchors.fill: parent

                    MoneroComponents.TextPlain {
                        id: sortBlockheightText
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 15
                        text: qsTr("Blockheight") + translationManager.emptyString
                        color: root.sortBy === "blockheight" ? MoneroComponents.Style.defaultFontColor : MoneroComponents.Style.dimmedFontColor
                        themeTransition: false
                    }

                    MoneroEffects.ImageMask {
                        height: 8
                        width: 12
                        visible: root.sortBy === "blockheight" ? true : false
                        opacity: root.sortBy === "blockheight" ? 1 : 0.2
                        image: "qrc:///images/whiteDropIndicator.png"
                        fontAwesomeFallbackIcon: FontAwesome.arrowDown
                        fontAwesomeFallbackSize: 14
                        color: MoneroComponents.Style.defaultFontColor
                        rotation: {
                            if(root.sortBy === "blockheight"){
                                return root.sortDirection ? 0 : 180
                            } else {
                                return 0;
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if(root.sortBy !== "blockheight") {
                            root.sortDirection = true;
                        } else {
                            root.sortDirection = !root.sortDirection
                        }

                        root.sortBy = "blockheight";
                        root.updateSort();
                    }
                }
            }

            Rectangle {
                visible: sortAndFilter.collapsed
                color: "transparent"
                Layout.preferredWidth: sortDateText.width + 42
                Layout.preferredHeight: 20

                RowLayout {
                    clip: true
                    anchors.fill: parent

                    MoneroComponents.TextPlain {
                        id: sortDateText
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 15
                        text: qsTr("Date") + translationManager.emptyString
                        color: root.sortBy === "timestamp" ? MoneroComponents.Style.defaultFontColor : MoneroComponents.Style.dimmedFontColor
                        themeTransition: false
                    }

                    MoneroEffects.ImageMask {
                        height: 8
                        width: 12
                        visible: root.sortBy === "timestamp" ? true : false
                        opacity: root.sortBy === "timestamp" ? 1 : 0.2
                        image: "qrc:///images/whiteDropIndicator.png"
                        fontAwesomeFallbackIcon: FontAwesome.arrowDown
                        fontAwesomeFallbackSize: 14
                        color: MoneroComponents.Style.defaultFontColor
                        rotation: {
                            if(root.sortBy === "timestamp"){
                                return root.sortDirection ? 0 : 180
                            } else {
                                return 0;
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if(root.sortBy !== "timestamp") {
                            root.sortDirection = true;
                        } else {
                            root.sortDirection = !root.sortDirection
                        }

                        root.sortBy = "timestamp";
                        root.updateSort();
                    }
                }
            }

            Rectangle {
                visible: sortAndFilter.collapsed
                color: "transparent"
                Layout.preferredWidth: sortAmountText.width + 42
                Layout.preferredHeight: 20

                RowLayout {
                    clip: true
                    anchors.fill: parent

                    MoneroComponents.TextPlain {
                        id: sortAmountText
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 15
                        text: qsTr("Amount") + translationManager.emptyString
                        color: root.sortBy === "amount" ? MoneroComponents.Style.defaultFontColor : MoneroComponents.Style.dimmedFontColor
                        themeTransition: false
                    }

                    MoneroEffects.ImageMask {
                        height: 8
                        width: 12
                        visible: root.sortBy === "amount" ? true : false
                        opacity: root.sortBy === "amount" ? 1 : 0.2
                        image: "qrc:///images/whiteDropIndicator.png"
                        fontAwesomeFallbackIcon: FontAwesome.arrowDown
                        fontAwesomeFallbackSize: 14
                        color: MoneroComponents.Style.defaultFontColor
                        rotation: {
                            if(root.sortBy === "amount"){
                                return root.sortDirection ? 0 : 180
                            } else {
                                return 0;
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if(root.sortBy !== "amount") {
                            root.sortDirection = true;
                        } else {
                            root.sortDirection = !root.sortDirection
                        }

                        root.sortBy = "amount";
                        root.updateSort();
                    }
                }
            }

            Rectangle {
                visible: !sortAndFilter.collapsed
                Layout.preferredHeight: 20

                MoneroComponents.TextPlain {
                    // status message
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    text: root.historyStatusMessage

                    color: MoneroComponents.Style.defaultFontColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                id: pagination
                visible: root.txCount > 0
                spacing: 0
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: childrenRect.width
                Layout.preferredHeight: 20

                Rectangle {
                    color: "transparent"
                    Layout.preferredWidth: childrenRect.width + 2
                    Layout.preferredHeight: 20

                    MoneroComponents.TextPlain {
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 15
                        text: qsTr("Page") + ":" + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    color: "transparent"
                    Layout.preferredWidth: childrenRect.width + 10
                    Layout.leftMargin: 4
                    Layout.preferredHeight: 20

                    MoneroComponents.TextPlain {
                        id: paginationText
                        text: root.txPage + "/" + Math.ceil(root.txCount / root.txMax)
                        color: MoneroComponents.Style.defaultFontColor
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            // jump to page functionality
                            property int pages: Math.ceil(root.txCount / root.txMax)
                            anchors.fill: parent
                            hoverEnabled: pages > 1
                            cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onEntered: parent.color = MoneroComponents.Style.orange
                            onExited: parent.color = MoneroComponents.Style.defaultFontColor
                            onClicked: {
                                if(pages === 1)
                                    return;

                                inputDialog.labelText = qsTr("Jump to page (1-%1)").arg(pages) + translationManager.emptyString;
                                inputDialog.onAcceptedCallback = function() {
                                    var pageNumber = parseInt(inputDialog.inputText);
                                    if (!isNaN(pageNumber) && pageNumber >= 1 && pageNumber <= pages) {
                                        root.paginationJump(parseInt(pageNumber));
                                        return;
                                    }

                                    appWindow.showStatusMessage(qsTr("Invalid page. Must be a number within the specified range."), 4);
                                }
                                inputDialog.onRejectedCallback = null;
                                inputDialog.open()
                            }
                        }
                    }
                }

                Rectangle {
                    id: paginationPrev
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 20
                    color: "transparent"
                    opacity: enabled ? 1.0 : 0.2
                    enabled: false

                    MoneroEffects.ImageMask {
                        id: prevIcon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        height: 8
                        width: 12
                        image: "qrc:///images/whiteDropIndicator.png"
                        fontAwesomeFallbackIcon: FontAwesome.arrowDown
                        fontAwesomeFallbackSize: 14
                        color: MoneroComponents.Style.defaultFontColor
                        rotation: 90
                    }

                    MouseArea {
                        enabled: parent.enabled
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.paginationPrevClicked();
                        }
                    }
                }

                Rectangle {
                    id: paginationNext
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 20
                    color: "transparent"
                    opacity: enabled ? 1.0 : 0.2
                    enabled: false

                    MoneroEffects.ImageMask {
                        id: nextIcon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        height: 8
                        width: 12
                        image: "qrc:///images/whiteDropIndicator.png"
                        fontAwesomeFallbackIcon: FontAwesome.arrowDown
                        fontAwesomeFallbackSize: 14
                        rotation: 270
                        color: MoneroComponents.Style.defaultFontColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.paginationNextClicked();
                        }
                    }
                }
            }
        }

        ListView {
            visible: true
            id: txListview
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight;
            model: txListViewModel
            interactive: false

            delegate: Rectangle {
                id: delegate
                property bool collapsed: root.txDataCollapsed.indexOf(hash) >= 0 ? true : false
                anchors.left: parent ? parent.left : undefined
                anchors.right: parent ? parent.right : undefined
                height: {
                    if(!collapsed) return 60;
                    return 320;
                }
                color: {
                    if(!collapsed) return "transparent"
                    return MoneroComponents.Style.blackTheme ? "#06FFFFFF" : "#04000000"
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    width: sideMargin
                    color: "transparent"

                    Rectangle {
                        visible: !isFailed && !isPending
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 10
                        height: 10
                        radius: 8
                        color: isout ? "#d85a00" : "#2eb358"
                    }

                    MoneroComponents.TextPlain {
                        visible: isFailed || isPending
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: FontAwesome.fontFamilySolid
                        font.styleName: isFailed ? "Solid" : ""
                        font.pixelSize: 15
                        text: isFailed ? FontAwesome.times : FontAwesome.clockO
                        color: isFailed ? "#FF0000" : MoneroComponents.Style.defaultFontColor
                        themeTransition: false
                    }
                }

                ColumnLayout {
                    spacing: 0
                    clip: true
                    height: parent.height
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: sideMargin
                    anchors.rightMargin: sideMargin

                    RowLayout {
                        spacing: 0
                        Layout.fillWidth: true
                        height: 60
                        Layout.preferredHeight: 60

                        ColumnLayout {
                            spacing: 0
                            clip: true
                            Layout.preferredHeight: 120
                            Layout.minimumWidth: 180

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: (isout ? qsTr("Sent") : qsTr("Received")) + (isFailed ? " (" + qsTr("Failed") + ")" : (isPending ? " (" + qsTr("Pending") + ")" : "")) + translationManager.emptyString
                                    color: MoneroComponents.Style.historyHeaderTextColor
                                    anchors.verticalCenter: parent.verticalCenter
                                    themeTransitionBlackColor: MoneroComponents.Style._b_historyHeaderTextColor
                                    themeTransitionWhiteColor: MoneroComponents.Style._w_historyHeaderTextColor
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: (amount == 0 ? qsTr("Unknown amount") : displayAmount) + translationManager.emptyString
                                    color: MoneroComponents.Style.defaultFontColor
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        state: "copyable"
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = MoneroComponents.Style.orange
                                        onExited: parent.color = MoneroComponents.Style.defaultFontColor
                                    }
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: isout ? qsTr("Fee") : confirmationsRequired === 60 ? qsTr("Mined") : qsTr("Fee") + translationManager.emptyString
                                    color: MoneroComponents.Style.historyHeaderTextColor
                                    themeTransitionBlackColor: MoneroComponents.Style._b_historyHeaderTextColor
                                    themeTransitionWhiteColor: MoneroComponents.Style._w_historyHeaderTextColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: {
                                        if(!isout && confirmationsRequired === 60) return qsTr("Yes") + translationManager.emptyString;
                                        if(fee !== "") return Utils.removeTrailingZeros(fee) + " XMR";
                                        return "-";
                                    }

                                    color: MoneroComponents.Style.defaultFontColor
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        state: "copyable"
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = MoneroComponents.Style.orange
                                        onExited: parent.color = MoneroComponents.Style.defaultFontColor
                                    }
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }
                        }

                        ColumnLayout {
                            spacing: 0
                            clip: true
                            Layout.preferredHeight: 120
                            Layout.minimumWidth: 230

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: (isout ? qsTr("To") : qsTr("In")) + translationManager.emptyString
                                    color: MoneroComponents.Style.historyHeaderTextColor
                                    themeTransitionBlackColor: MoneroComponents.Style._b_historyHeaderTextColor
                                    themeTransitionWhiteColor: MoneroComponents.Style._w_historyHeaderTextColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    id: addressField
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: {
                                        if (isout) {
                                            if (address) {
                                                return (addressBookName ? FontAwesome.addressBook + " " + addressBookName : TxUtils.addressTruncate(address, 8));
                                            }
                                            if (amount != 0) {
                                                return qsTr("Unknown recipient") + translationManager.emptyString;
                                            } else {
                                                return qsTr("My wallet") + translationManager.emptyString;
                                            }
                                        } else {
                                            if (receivingAddress) {
                                                if (subaddrIndex == 0) {
                                                    return qsTr("Address") + " #0" + " (" + qsTr("Primary address") + ")" + translationManager.emptyString;
                                                } else {
                                                    if (receivingAddressLabel) {
                                                        return qsTr("Address") + " #" + subaddrIndex + " (" + receivingAddressLabel + ")" + translationManager.emptyString;
                                                    } else {
                                                        return qsTr("Address") + " #" + subaddrIndex + " (" + TxUtils.addressTruncate(receivingAddress, 4) + ")" + translationManager.emptyString;
                                                    }
                                                }
                                            } else {
                                                return qsTr("Unknown address") + translationManager.emptyString;
                                            }
                                        }
                                    }

                                    color: MoneroComponents.Style.defaultFontColor
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        state: isout ? "copyable_address" : "copyable_receiving_address"
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = MoneroComponents.Style.orange
                                        onExited: parent.color = MoneroComponents.Style.defaultFontColor
                                    }
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: qsTr("Confirmations") + translationManager.emptyString
                                    color: MoneroComponents.Style.historyHeaderTextColor
                                    themeTransitionBlackColor: MoneroComponents.Style._b_historyHeaderTextColor
                                    themeTransitionWhiteColor: MoneroComponents.Style._w_historyHeaderTextColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    property bool confirmed: confirmations < confirmationsRequired ? false : true
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: confirmed ? confirmations : confirmations + "/" + confirmationsRequired
                                    color: MoneroComponents.Style.defaultFontColor
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        state: "copyable"
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = MoneroComponents.Style.orange
                                        onExited: parent.color = MoneroComponents.Style.defaultFontColor
                                    }
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }
                        }

                        ColumnLayout {
                            spacing: 0
                            clip: true
                            Layout.preferredHeight: 120
                            Layout.minimumWidth: 130

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: qsTr("Date")
                                    color: MoneroComponents.Style.historyHeaderTextColor
                                    themeTransitionBlackColor: MoneroComponents.Style._b_historyHeaderTextColor
                                    themeTransitionWhiteColor: MoneroComponents.Style._w_historyHeaderTextColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20

                                MoneroComponents.TextPlain {
                                    font.family: MoneroComponents.Style.fontRegular.name
                                    font.pixelSize: 15
                                    text: persistentSettings.historyHumanDates ? dateHuman : dateTime

                                    color: MoneroComponents.Style.defaultFontColor
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        state: "copyable"
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: {
                                            parent.color = MoneroComponents.Style.orange
                                            if (persistentSettings.historyHumanDates) {
                                                parent.text = dateTime;
                                            }
                                        }
                                        onExited: {
                                            parent.color = MoneroComponents.Style.defaultFontColor
                                            if (persistentSettings.historyHumanDates) {
                                                parent.text = dateHuman
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50

                                MoneroComponents.StandardButton {
                                    id: btnDetails
                                    text: FontAwesome.info
                                    small: true
                                    label.font.family: FontAwesome.fontFamily
                                    fontSize: 18
                                    width: 34
                                    tooltip: qsTr("Transaction details") + translationManager.emptyString
                                    tooltipLeft: true

                                    MouseArea {
                                        state: "details"
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        z: parent.z + 1

                                        onEntered: {
                                            parent.opacity = 0.8;
                                            parent.tooltipPopup.open()
                                        }
                                        onExited: {
                                            parent.opacity = 1.0;
                                            parent.tooltipPopup.close()
                                        }
                                    }
                                }

                                Image {
                                    visible: !isout && confirmationsRequired === 60
                                    anchors.left: btnDetails.right
                                    anchors.leftMargin: 16
                                    width: 28
                                    height: 28
                                    source: "qrc:///images/miningxmr.png"
                                }

                                MoneroComponents.StandardButton {
                                    visible: isout
                                    enabled: currentWallet ? !currentWallet.isHwBacked() : false
                                    anchors.left: btnDetails.right
                                    anchors.leftMargin: 10
                                    text: FontAwesome.productHunt
                                    small: true
                                    label.font.family: FontAwesome.fontFamilyBrands
                                    fontSize: 18
                                    width: 34
                                    tooltip: qsTr("Generate payment proof") + translationManager.emptyString
                                    tooltipLeft: true

                                    MouseArea {
                                        state: "proof"
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        z: parent.z + 1

                                        onEntered: {
                                            parent.opacity = 0.8;
                                            parent.tooltipPopup.open()
                                        }
                                        onExited: {
                                            parent.opacity = 1.0;
                                            parent.tooltipPopup.close()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 15
                                text: qsTr("Description") + translationManager.emptyString
                                color: MoneroComponents.Style.historyHeaderTextColor
                                themeTransitionBlackColor: MoneroComponents.Style._b_historyHeaderTextColor
                                themeTransitionWhiteColor: MoneroComponents.Style._w_historyHeaderTextColor
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20

                            MoneroComponents.TextPlain {
                                id: txNoteText
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 15
                                text: tx_note !== "" ? tx_note : "-"
                                color: MoneroComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter

                                MouseArea {
                                    state: "copyable"
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = MoneroComponents.Style.orange
                                    onExited: parent.color = MoneroComponents.Style.defaultFontColor
                                }
                            }

                            MoneroEffects.ImageMask {
                                anchors.top: parent.top
                                anchors.left: txNoteText.right
                                anchors.leftMargin: 12
                                image: "qrc:///images/edit.svg"
                                fontAwesomeFallbackIcon: FontAwesome.pencilSquare
                                fontAwesomeFallbackSize: 22
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.75
                                width: 23
                                height: 21

                                MouseArea {
                                    id: txNoteArea
                                    state: "set_tx_note"
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.opacity = 0.4;
                                    onExited: parent.opacity = 0.75;
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 10
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 15
                                text: qsTr("Transaction ID") + translationManager.emptyString
                                color: MoneroComponents.Style.historyHeaderTextColor
                                themeTransitionBlackColor: MoneroComponents.Style._b_historyHeaderTextColor
                                themeTransitionWhiteColor: MoneroComponents.Style._w_historyHeaderTextColor
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 15
                                text: hash
                                color: MoneroComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter

                                MouseArea {
                                    state: "copyable"
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = MoneroComponents.Style.orange
                                    onExited: parent.color = MoneroComponents.Style.defaultFontColor
                                }
                            }
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 10
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 15
                                text: qsTr("Transaction key") + translationManager.emptyString
                                color: MoneroComponents.Style.historyHeaderTextColor
                                themeTransitionBlackColor: MoneroComponents.Style._b_historyHeaderTextColor
                                themeTransitionWhiteColor: MoneroComponents.Style._w_historyHeaderTextColor
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 15
                                text: qsTr("Click to reveal")
                                color: MoneroComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                state: "txkey_hidden"

                                MouseArea {
                                    state: "copyable_txkey"
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = MoneroComponents.Style.orange
                                    onExited: parent.color = MoneroComponents.Style.defaultFontColor
                                }
                            }
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 10
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 15
                                text: qsTr("Blockheight") + translationManager.emptyString
                                color: MoneroComponents.Style.historyHeaderTextColor
                                themeTransitionBlackColor: MoneroComponents.Style._b_historyHeaderTextColor
                                themeTransitionWhiteColor: MoneroComponents.Style._w_historyHeaderTextColor
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20

                            MoneroComponents.TextPlain {
                                font.family: MoneroComponents.Style.fontRegular.name
                                font.pixelSize: 14
                                text: (blockheight > 0 ? blockheight : qsTr('Pending')) + translationManager.emptyString;

                                color: MoneroComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter

                                MouseArea {
                                    state: "copyable"
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = MoneroComponents.Style.orange
                                    onExited: parent.color = MoneroComponents.Style.defaultFontColor
                                }
                            }
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 10
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                MouseArea {
                    id: collapseArea
                    objectName: "collapseArea"
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        // detect clicks on text (for copying), otherwise toggle collapse
                        var doCollapse = true;
                        var res = Utils.qmlEach(delegate, ['containsMouse', 'preventStealing', 'scrollGestureEnabled'], ['collapseArea'], []);
                        for(var i = 0; i < res.length; i+=1){
                            if(res[i].containsMouse === true){
                                if(res[i].state === 'copyable' && res[i].parent.hasOwnProperty('text')) toClipboard(res[i].parent.text);
                                if(res[i].state === 'copyable_address') (address ? root.toClipboard(address) : root.toClipboard(addressField.text));
                                if(res[i].state === 'copyable_receiving_address') root.toClipboard(currentWallet.address(subaddrAccount, subaddrIndex));
                                if(res[i].state === 'copyable_txkey') root.getTxKey(hash, res[i]);
                                if(res[i].state === 'set_tx_note') root.editDescription(hash, tx_note, root.txPage);
                                if(res[i].state === 'details') root.showTxDetails(hash, paymentId, destinations, subaddrAccount, subaddrIndex, dateTime, displayAmount, isout);
                                if(res[i].state === 'proof') root.showTxProof(hash, paymentId, destinations, subaddrAccount, subaddrIndex);
                                doCollapse = false;
                                break;
                            }
                        }

                        if(doCollapse){
                            collapsed = !collapsed;

                            // remember collapsed state
                            if(collapsed){
                                root.txDataCollapsed.push(hash);
                            } else {
                                root.removeFromCollapsedList(hash);
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: sideMargin

                    color: "transparent"

                    MoneroEffects.ImageMask {
                        id: collapsedIcon
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 8
                        width: 12
                        image: "qrc:///images/whiteDropIndicator.png"
                        rotation: delegate.collapsed ? 180 : 0
                        color: MoneroComponents.Style.defaultFontColor
                        fontAwesomeFallbackIcon: FontAwesome.arrowDown
                        fontAwesomeFallbackSize: 14
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 1
                    color: MoneroComponents.Style.appWindowBorderColor

                    MoneroEffects.ColorTransition {
                        targetObj: parent
                        blackColor: MoneroComponents.Style._b_appWindowBorderColor
                        whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.bottom
                    height: 1
                    color: MoneroComponents.Style.appWindowBorderColor

                    MoneroEffects.ColorTransition {
                        targetObj: parent
                        blackColor: MoneroComponents.Style._b_appWindowBorderColor
                        whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                    }
                }
            }
        }

        Item {
            visible: sortAndFilter.collapsed
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.leftMargin: sideMargin
            Layout.rightMargin: sideMargin

            MoneroComponents.TextPlain {
                // status message
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 15
                text: root.historyStatusMessage;
                color: MoneroComponents.Style.dimmedFontColor
                themeTransitionBlackColor: MoneroComponents.Style._b_dimmedFontColor
                themeTransitionWhiteColor: MoneroComponents.Style._w_dimmedFontColor
            }
        }

        MoneroComponents.CheckBox2 {
            id: showAdvancedCheckbox
            Layout.topMargin: 30
            Layout.bottomMargin: 20
            Layout.leftMargin: sideMargin
            Layout.rightMargin: sideMargin
            checked: persistentSettings.historyShowAdvanced
            onClicked: persistentSettings.historyShowAdvanced = !persistentSettings.historyShowAdvanced
            text: qsTr("Advanced options") + translationManager.emptyString
        }

        ColumnLayout {
            visible: persistentSettings.historyShowAdvanced
            Layout.leftMargin: sideMargin
            Layout.rightMargin: sideMargin
            spacing: 20

            MoneroComponents.CheckBox {
                id: humanDatesCheckBox
                checked: persistentSettings.historyHumanDates
                onClicked: {
                    persistentSettings.historyHumanDates = !persistentSettings.historyHumanDates
                    root.updateDisplay(root.txOffset, root.txMax);
                }
                text: qsTr("Human readable date format") + translationManager.emptyString
            }

            MoneroComponents.StandardButton {
                visible: !isIOS
                small: true
                text: qsTr("Export all history") + translationManager.emptyString
                onClicked: {
                    writeCSVFileDialog.open();
                }
            }
        }
    }

    function refresh(){
        if(appWindow.currentWallet != null && typeof appWindow.currentWallet.history !== "undefined" ) {
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount);
        }

        if (typeof root.model !== 'undefined' && root.model != null) {
            toDatePicker.currentDate = root.model.transactionHistory.lastDateTime
        }

        // extract from model, create JS array of txs
        root.updateTransactionsFromModel();

        // fill listview, update UI
        root.updateDisplay(root.txOffset, root.txMax);
    }

    function reset(keepDate) {
        root.txOffset = 0;

        if (typeof root.model !== 'undefined' && root.model != null) {
            if (!keepDate) {
                root.model.dateFromFilter = "2014-04-18" // genesis block
                root.model.dateToFilter = "9999-09-09" // fix before september 9999
            }
            // negative values disable filters here;
            root.model.amountFromFilter = -1;
            root.model.amountToFilter = -1;
            root.model.directionFilter = TransactionInfo.Direction_Both;
        }
    }

    function updateFilter(currentPage){
        // applying filters
        root.txData = JSON.parse(JSON.stringify(root.txModelData)); // deepcopy

        const timezoneOffset = new Date().getTimezoneOffset() * 60;
        var fromDate = Math.floor(fromDatePicker.currentDate.getTime() / 86400000) * 86400 + timezoneOffset;
        var toDate = (Math.floor(toDatePicker.currentDate.getTime() / 86400000) + 1) * 86400 + timezoneOffset;

        var txs = [];
        for (var i = 0; i < root.txData.length; i++){
            var item = root.txData[i];
            var matched = "";

            // daterange filtering
            if(item.timestamp < fromDate || item.timestamp > toDate){
                continue;
            }

            // search string filtering
            if(root.sortSearchString == null || root.sortSearchString === ""){
                txs.push(root.txData[i]);
                continue;
            }

            if(root.sortSearchString.length >= 1){
                if(item.amount && item.amount.toString().startsWith(root.sortSearchString)){
                    txs.push(item);
                } else if(item.address !== "" && item.address.toLowerCase().startsWith(root.sortSearchString.toLowerCase())){
                    txs.push(item);
                } else if(item.receivingAddress !== "" && item.receivingAddress.toLowerCase().startsWith(root.sortSearchString.toLowerCase())){
                    txs.push(item);
                } else if(item.receivingAddressLabel !== "" && item.receivingAddressLabel.toLowerCase().startsWith(root.sortSearchString.toLowerCase())){
                    txs.push(item);
                } else if(item.addressBookName !== "" && item.addressBookName.toLowerCase().startsWith(root.sortSearchString.toLowerCase())){
                    txs.push(item);
                } else if(typeof item.blockheight !== "undefined" && item.blockheight.toString().startsWith(root.sortSearchString)) {
                    txs.push(item);
                } else if(item.tx_note.toLowerCase().indexOf(root.sortSearchString.toLowerCase()) !== -1) {
                    txs.push(item);
                } else if (item.hash.startsWith(root.sortSearchString)){
                    txs.push(item);
                }
            }
        }

        root.txData = txs;
        root.txCount = root.txData.length;

        root.updateSort();
        root.updateDisplay(root.txOffset, root.txMax);
        if (currentPage) {
            root.paginationJump(parseInt(currentPage));
        }
    }

    function updateSort(){
        // applying sorts
        root.txOffset = 0;
        root.txData.sort(function(a, b) {
            return a[root.sortBy] - b[root.sortBy];
        });

        if(root.sortDirection)
            root.txData.reverse();

        root.updateDisplay(root.txOffset, root.txMax);
    }

    function updateDisplay(tx_offset, tx_max) {
        txListViewModel.clear();

        // limit results as per tx_max (root.txMax)
        var txs = root.txData.slice(tx_offset, tx_offset + tx_max);

        // collapse tx if there is a single result
        if(root.txPage === 1 && txs.length === 1)
            root.txDataCollapsed.push(txs[0]['hash']);

        // populate listview
        for (var i = 0; i < txs.length; i++){
            txListViewModel.append(txs[i]);
        }

        root.updateHistoryStatusMessage();

        // determine pagination button states
        var count = txData.length;
        if(count <= root.txMax) {
            paginationPrev.enabled = false;
            paginationNext.enabled = false;
            return;
        }

        if(root.txOffset < root.txMax)
            paginationPrev.enabled = false;
        else
            paginationPrev.enabled = true;

        if((root.txOffset + root.txMax) >= count)
            paginationNext.enabled = false;
        else
            paginationNext.enabled = true;
    }

    function updateTransactionsFromModel() {
        // This function copies the items of `appWindow.currentWallet.historyModel` to `root.txModelData`, as a list of javascript objects
        if(currentWallet == null || typeof currentWallet.history === "undefined" ) return;

        var _model = root.model;
        var total = 0
        var count = _model.rowCount()
        root.txModelData = [];

        for (var i = 0; i < count; ++i) {
            var idx = _model.index(i, 0);
            var isPending = model.data(idx, TransactionHistoryModel.TransactionPendingRole);
            var isFailed = model.data(idx, TransactionHistoryModel.TransactionFailedRole);
            var isout = _model.data(idx, TransactionHistoryModel.TransactionIsOutRole);
            var amount = _model.data(idx, TransactionHistoryModel.TransactionAmountRole);
            var hash = _model.data(idx, TransactionHistoryModel.TransactionHashRole);
            var paymentId = _model.data(idx, TransactionHistoryModel.TransactionPaymentIdRole);
            var destinations = _model.data(idx, TransactionHistoryModel.TransactionDestinationsRole);
            var time = _model.data(idx, TransactionHistoryModel.TransactionTimeRole);
            var date = _model.data(idx, TransactionHistoryModel.TransactionDateRole);
            var blockheight = _model.data(idx, TransactionHistoryModel.TransactionBlockHeightRole);
            var confirmations = _model.data(idx, TransactionHistoryModel.TransactionConfirmationsRole);
            var confirmationsRequired = _model.data(idx, TransactionHistoryModel.TransactionConfirmationsRequiredRole);
            var fee = _model.data(idx, TransactionHistoryModel.TransactionFeeRole);
            var subaddrAccount = model.data(idx, TransactionHistoryModel.TransactionSubaddrAccountRole);
            var subaddrIndex = model.data(idx, TransactionHistoryModel.TransactionSubaddrIndexRole);
            var timestamp = new Date(date + " " + time).getTime() / 1000;
            var dateHuman = Utils.ago(timestamp);

            if (amount === 0) {
                // transactions to the same account have amount === 0, while the 'destinations string'
                // has the correct amount, so we try to fetch it from that instead.
                amount = Number(TxUtils.destinationsToAmount(destinations));
            }
            var displayAmount = Utils.removeTrailingZeros(amount.toFixed(12)) + " XMR";

            var tx_note = currentWallet.getUserNote(hash);
            var address = "";
            var addressBookName = "";
            var receivingAddress = "";
            var receivingAddressLabel = "";

            if (isout) {
                address = TxUtils.destinationsToAddress(destinations);
                addressBookName = currentWallet ? currentWallet.addressBook.getDescription(address) : null;
            } else {
                receivingAddress = currentWallet ? currentWallet.address(subaddrAccount, subaddrIndex) : null;
                receivingAddressLabel = currentWallet ? appWindow.currentWallet.getSubaddressLabel(subaddrAccount, subaddrIndex) : null;
            }

            if (isout)
                total = walletManager.subi(total, amount)
            else
                total = walletManager.addi(total, amount)

            root.txModelData.push({
                "i": i,
                "isPending": isPending,
                "isFailed": isFailed,
                "isout": isout,
                "amount": amount,
                "displayAmount": displayAmount,
                "hash": hash,
                "paymentId": paymentId,
                "address": address,
                "addressBookName": addressBookName,
                "destinations": destinations,
                "tx_note": tx_note,
                "dateHuman": dateHuman,
                "dateTime": date + " " + time,
                "blockheight": blockheight,
                "address": address,
                "timestamp": timestamp,
                "fee": fee,
                "confirmations": confirmations,
                "confirmationsRequired": confirmationsRequired,
                "receivingAddress": receivingAddress,
                "receivingAddressLabel": receivingAddressLabel,
                "subaddrAccount": subaddrAccount,
                "subaddrIndex": subaddrIndex
            });
        }

        root.txData = JSON.parse(JSON.stringify(root.txModelData)); // deepcopy
        root.txCount = root.txData.length;
    }

    function update(currentPage) {
        // handle outside mutation of tx model; incoming/outgoing funds or new blocks. Update table.
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount);

        root.updateTransactionsFromModel();
        root.updateFilter(currentPage);
    }

    function editDescription(_hash, _tx_note, currentPage){
        inputDialog.labelText = qsTr("Set description:") + translationManager.emptyString;
        inputDialog.onAcceptedCallback = function() {
            appWindow.currentWallet.setUserNote(_hash, inputDialog.inputText);
            appWindow.showStatusMessage(qsTr("Updated description."),3);
            root.update(currentPage);
        }
        inputDialog.onRejectedCallback = null;
        inputDialog.open(_tx_note);
    }

    function paginationPrevClicked(){
        root.txOffset -= root.txMax;
        updateDisplay(root.txOffset, root.txMax);
    }

    function paginationNextClicked(){
        root.txOffset += root.txMax;
        updateDisplay(root.txOffset, root.txMax);
    }

    function paginationJump(pageNumber){
        root.txOffset = root.txMax * Math.ceil(pageNumber - 1 || 0);
        updateDisplay(root.txOffset, root.txMax);
    }

    function removeFromCollapsedList(hash){
        root.txDataCollapsed = root.txDataCollapsed.filter(function(item) {
            return item !== hash
        });
    }

    function updateHistoryStatusMessage(){
        if(root.txModelData.length <= 0){
            root.historyStatusMessage = qsTr("No transaction history yet.") + translationManager.emptyString;
        } else if (root.txData.length <= 0){
            root.historyStatusMessage = qsTr("No results.") + translationManager.emptyString;
        } else {
            root.historyStatusMessage = qsTr("%1 transactions total, showing %2.").arg(root.txData.length).arg(txListViewModel.count) + translationManager.emptyString;
        }
    }

    function getTxKey(hash, elem){
        if (elem.parent.state != 'ready'){
            currentWallet.getTxKeyAsync(hash, function(hash, txKey) {
                elem.parent.text = txKey ? txKey : '-';
                elem.parent.state = 'ready';
            });
        } else {
            toClipboard(elem.parent.text);
        }
    }

    function showTxDetails(hash, paymentId, destinations, subaddrAccount, subaddrIndex, dateTime, amount, isout) {
        var tx_note = currentWallet.getUserNote(hash)
        var rings = currentWallet.getRings(hash)
        var address_label = subaddrIndex == 0 ? (qsTr("Primary address") + translationManager.emptyString) : currentWallet.getSubaddressLabel(subaddrAccount, subaddrIndex)
        var address = currentWallet.address(subaddrAccount, subaddrIndex)
        const hasPaymentId = parseInt(paymentId, 16);
        const integratedAddress = !isout && hasPaymentId ? currentWallet.integratedAddress(paymentId) : null;

        if (rings)
            rings = rings.replace(/\|/g, '\n')

        currentWallet.getTxKeyAsync(hash, function(hash, tx_key) {
            informationPopup.title = qsTr("Transaction details") + translationManager.emptyString;
            informationPopup.content = buildTxDetailsString(hash, hasPaymentId ? paymentId : null, tx_key, tx_note, destinations, rings, address, address_label, integratedAddress, dateTime, amount);
            informationPopup.onCloseCallback = null
            informationPopup.open();
        });
    }

    function showTxProof(hash, paymentId, destinations, subaddrAccount, subaddrIndex){
        var address = TxUtils.destinationsToAddress(destinations);
        if(address === undefined){
            console.log('getProof: Error fetching address')
            return;
        }

        var checked = (TxUtils.checkTxID(hash) && TxUtils.checkAddress(address, appWindow.persistentSettings.nettype));
        if(!checked){
            console.log('getProof: Error checking TxId and/or address');
        }

        console.log("getProof: Generate clicked: txid " + hash + ", address " + address);
        middlePanel.getProofClicked(hash, address, '', null);
        informationPopup.title  = qsTr("Payment proof") + translationManager.emptyString;
        informationPopup.text = qsTr("Generating payment proof") + "..." + translationManager.emptyString;
        informationPopup.onCloseCallback = null
        informationPopup.open()
    }

    function toClipboard(text){
        console.log("Copied to clipboard");
        clipboard.setText(text);
        appWindow.showStatusMessage(qsTr("Copied to clipboard"),3);
    }

    function buildTxDetailsString(tx_id, paymentId, tx_key,tx_note, destinations, rings, address, address_label, integratedAddress, dateTime, amount) {
        var trStart = '<tr><td style="white-space: nowrap; padding-top:5px"><b>',
            trMiddle = '</b></td><td style="padding-left:10px;padding-top:5px;">',
            trEnd = "</td></tr>";

        return '<table border="0">'
            + (tx_id ? trStart + qsTr("Tx ID:") + trMiddle + tx_id + trEnd : "")
            + (dateTime ? trStart + qsTr("Date") + ":" + trMiddle + dateTime + trEnd : "")
            + (amount ? trStart + qsTr("Amount") + ":" + trMiddle + amount + trEnd : "")
            + (address ? trStart + qsTr("Address:") + trMiddle + address + trEnd : "")
            + (paymentId ? trStart + qsTr("Payment ID:") + trMiddle + paymentId + trEnd : "")
            + (integratedAddress ? trStart + qsTr("Integrated address") + ":" + trMiddle + integratedAddress + trEnd : "")
            + (tx_key ? trStart + qsTr("Tx key:") + trMiddle + tx_key + trEnd : "")
            + (tx_note ? trStart + qsTr("Tx note:") + trMiddle + tx_note + trEnd : "")
            + (destinations ? trStart + qsTr("Destinations:") + trMiddle + destinations + trEnd : "")
            + (rings ? trStart + qsTr("Rings:") + trMiddle + rings + trEnd : "")
            + "</table>"
            + translationManager.emptyString;
    }

    FileDialog {
        id: writeCSVFileDialog
        title: qsTr("Please choose a folder") + translationManager.emptyString
        selectFolder: true
        onRejected: {
            console.log("csv write canceled")
        }
        onAccepted: {
            var dataDir = walletManager.urlToLocalPath(writeCSVFileDialog.fileUrl);
            var written = currentWallet.history.writeCSV(currentWallet.currentSubaddressAccount, dataDir);

            if(written !== ""){
                confirmationDialog.title = qsTr("Success") + translationManager.emptyString;
                var text = qsTr("CSV file written to: %1").arg(written) + "\n\n"
                text += qsTr("Tip: Use your favorite spreadsheet software to sort on blockheight.") + "\n\n" + translationManager.emptyString;
                confirmationDialog.text = text;
                confirmationDialog.icon = StandardIcon.Information;
                confirmationDialog.cancelText = qsTr("Open folder") + translationManager.emptyString;
                confirmationDialog.onAcceptedCallback = null;
                confirmationDialog.onRejectedCallback = function() {
                    oshelper.openContainingFolder(written);
                }
                confirmationDialog.open();
            } else {
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                informationPopup.text = qsTr("Error exporting transaction data.") + "\n\n" + translationManager.emptyString;
                informationPopup.icon = StandardIcon.Critical;
                informationPopup.onCloseCallback = null;
                informationPopup.open();

            }
        }
        Component.onCompleted: {
            var _folder = 'file://' + appWindow.accountsDir;
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
        // setup date filter scope according to real transactions
        if(appWindow.currentWallet != null){
            root.model = appWindow.currentWallet.historyModel;
            root.model.sortRole = TransactionHistoryModel.TransactionBlockHeightRole
            root.model.sort(0, Qt.DescendingOrder);
            var count = root.model.rowCount()
            if (count > 0) {
                //date of the first transaction
                fromDatePicker.currentDate = root.model.data(root.model.index((count - 1), 0), TransactionHistoryModel.TransactionDateRole);
            } else {
                //date of monero birth (2014-04-18)
                fromDatePicker.currentDate = model.transactionHistory.firstDateTime
            }
        }

        root.reset();
        root.refresh();
        root.initialized = true;
        root.updateFilter();
    }

    function onPageClosed(){
        root.initialized = false;
        root.reset(true);
        root.clearFields();
    }

    function searchInHistory(searchTerm){
        searchInput.text = searchTerm;
        searchInput.forceActiveFocus();
        searchInput.cursorPosition = searchInput.text.length;
        sortAndFilter.collapsed = true;
    }

    function clearFields() {
        sortAndFilter.collapsed = false;
        searchInput.text = "";
        root.txDataCollapsed = [];
    }
}
