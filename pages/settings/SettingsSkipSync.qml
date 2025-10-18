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

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias skipSyncHeight: skipSyncContainer.height
    
    // Add null-safe property references
    property var currentWallet: null
    property var persistentSettings: null
    property var informationPopup: null

    ColumnLayout {
        id: skipSyncContainer
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 24

        // Data Saving Mode Toggle
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MoneroComponents.Label {
                Layout.fillWidth: true
                fontSize: 16
                text: "Data Saving Mode"
            }

            MoneroComponents.CheckBox {
                id: dataSavingCheckbox
                checked: persistentSettings ? persistentSettings.skipSyncEnabled : false
                onCheckedChanged: {
                    if (persistentSettings) {
                        persistentSettings.skipSyncEnabled = checked
                    }
                }
            }
        }

        MoneroComponents.Label {
            Layout.fillWidth: true
            fontSize: 13
            text: "Enable data-saving sync options. This allows you to sync only specific date ranges, saving mobile data and time."
            color: MoneroComponents.Style.defaultFontColor
            wrapMode: Text.WordWrap
        }

        // Skip Sync Controls (visible when enabled)
        Rectangle {
            Layout.fillWidth: true
            color: "transparent"
            visible: dataSavingCheckbox.checked
            height: skipSyncContent.height + 20

            ColumnLayout {
                id: skipSyncContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 16

                MoneroComponents.Label {
                    Layout.fillWidth: true
                    fontSize: 14
                    fontBold: true
                    text: "Synchronization Options"
                }

                // Transaction import checkbox (define early for binding)
                MoneroComponents.CheckBox {
                    id: txImportCheckbox
                    checked: false
                    text: "Show transaction import"
                }

                // Skip Sync Button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MoneroComponents.StandardButton {
                        text: "Skip Sync (Current Height)"
                        onClicked: {
                            console.log("Skipping sync - using current daemon block height")
                            if (currentWallet) {
                                currentWallet.skipSync()
                            }
                        }
                    }

                    MoneroComponents.Label {
                        Layout.fillWidth: true
                        fontSize: 12
                        text: "Sync from current block height (fastest, no missed transactions)"
                        wrapMode: Text.WordWrap
                    }
                }

                // Full Sync Button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MoneroComponents.StandardButton {
                        text: "Full Sync (~500 MB)"
                        onClicked: {
                            console.log("Starting full sync")
                            if (currentWallet) {
                                currentWallet.startRefresh()
                            }
                        }
                    }

                    MoneroComponents.Label {
                        Layout.fillWidth: true
                        fontSize: 12
                        text: "Complete sync from last sync date to present"
                        wrapMode: Text.WordWrap
                    }
                }

                // Date Range Sync Section
                MoneroComponents.Label {
                    Layout.fillWidth: true
                    fontSize: 14
                    fontBold: true
                    text: "Sync Date Range"
                    topMargin: 12
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        spacing: 6

                        MoneroComponents.Label {
                            fontSize: 12
                            text: "Start Date"
                        }

                        MoneroComponents.LineEdit {
                            id: startDateInput
                            placeholderText: "YYYY-MM-DD"
                            Layout.minimumWidth: 150
                            text: persistentSettings ? (persistentSettings.skipSyncStartDate || "") : ""
                            onTextChanged: {
                                if (persistentSettings) {
                                    persistentSettings.skipSyncStartDate = text
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 6

                        MoneroComponents.Label {
                            fontSize: 12
                            text: "End Date"
                        }

                        MoneroComponents.LineEdit {
                            id: endDateInput
                            placeholderText: "YYYY-MM-DD"
                            Layout.minimumWidth: 150
                            text: persistentSettings ? (persistentSettings.skipSyncEndDate || "") : ""
                            onTextChanged: {
                                if (persistentSettings) {
                                    persistentSettings.skipSyncEndDate = text
                                }
                            }
                        }
                    }

                    MoneroComponents.StandardButton {
                        text: "Sync Range"
                        onClicked: {
                            if (startDateInput.text && endDateInput.text) {
                                console.log("Syncing date range: " + startDateInput.text + " to " + endDateInput.text)
                                if (currentWallet) {
                                    currentWallet.syncFromDateRange(startDateInput.text, endDateInput.text)
                                }
                            } else {
                                if (informationPopup) {
                                    informationPopup.title = "Invalid Date Range"
                                    informationPopup.text = "Please enter both start and end dates in YYYY-MM-DD format"
                                    informationPopup.open()
                                } else {
                                    console.warn("Cannot show popup: informationPopup is not defined")
                                }
                            }
                        }
                    }
                }

                // Import TX
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    MoneroComponents.StandardButton {
                        text: "Import Transaction"
                        onClicked: {
                            txImportDialog.open()
                        }
                    }

                    MoneroComponents.Label {
                        Layout.fillWidth: true
                        fontSize: 12
                        text: "Scan a specific transaction by hash"
                        wrapMode: Text.WordWrap
                    }
                }

                // Transaction Import Input
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    visible: txImportCheckbox.checked

                    MoneroComponents.Label {
                        fontSize: 12
                        text: "TX Hash:"
                    }

                    MoneroComponents.LineEdit {
                        id: txHashInput
                        Layout.fillWidth: true
                        placeholderText: "Enter transaction hash (64 hex characters)"
                    }

                    MoneroComponents.StandardButton {
                        text: "Import"
                        onClicked: {
                            if (txHashInput.text.length === 64) {
                                console.log("Importing transaction: " + txHashInput.text)
                                if (currentWallet) {
                                    currentWallet.scanTransaction(txHashInput.text)
                                    txHashInput.text = ""
                                }
                            } else {
                                if (informationPopup) {
                                    informationPopup.title = "Invalid Hash"
                                    informationPopup.text = "Transaction hash must be 64 hexadecimal characters"
                                    informationPopup.open()
                                } else {
                                    console.warn("Cannot show popup: informationPopup is not defined")
                                }
                            }
                        }
                    }
                }
            }
        }

        // Information section
        Rectangle {
            Layout.fillWidth: true
            color: "#f5f5f5"
            height: infoText.height + 20
            radius: 4

            MoneroComponents.Label {
                id: infoText
                anchors.fill: parent
                anchors.margins: 10
                fontSize: 12
                text: "Data Saving Mode helps you conserve mobile data by allowing selective syncing. Skip sync uses the current network height (fastest), while date-range sync lets you sync specific periods. A full sync downloads approximately 500 MB of blockchain data."
                wrapMode: Text.WordWrap
                color: "#333333"
            }
        }
    }
}
