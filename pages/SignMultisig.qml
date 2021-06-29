// Copyright (c) 2021, The Monero Project
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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import moneroComponents.Clipboard 1.0
import moneroComponents.PendingTransaction 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.NetworkType 1.0
import FontAwesome 1.0
import "../components"
import "../components" as MoneroComponents
import "." 1.0
import "../js/TxUtils.js" as TxUtils
import "../js/Utils.js" as Utils

Rectangle {
    id: pageRoot
    color: "transparent"
    property string txFilename: ""

    ColumnLayout {
        id: advancedLayout
        anchors.top: root.bottom
        anchors.left: parent.left
        anchors.margins: 20
        anchors.topMargin: 32
        spacing: 10

        RowLayout {
            Layout.topMargin: 60
            StandardButton {
                id: exportMultisigImages
                text: "Export Key Images"
                onClicked: {
                    exportMultisigKeyImagesDialog.open();
                }
            }
            StandardButton {
                id: importMultisigImages
                text: "Import Key Images"
                onClicked: {
                    importMultisigKeyImagesDialog.open();
                }
            }
            StandardButton {
                id: loadMultisigTxButton
                text: "Load Transaction"
                onClicked: {
                    loadMultisigTxDialog.open();
                }
            }
        }

        RowLayout {
            id: addressLineRow
            Layout.fillWidth: true

            LineEditMulti {
                id: addressLine
                KeyNavigation.tab: addressLine
                spacing: 0
                fontBold: true
                readOnly: true
                wrapMode: Text.WrapAnywhere
                labelText: qsTr("Address") + translationManager.emptyString
                placeholderText: qsTr("Load Tx to view") + translationManager.emptyString
            }
        }

        RowLayout {
            id: feeLineRow
            Layout.fillWidth: true

            LineEditMulti {
                id: amountLine
                KeyNavigation.tab: amountLine
                spacing: 0
                fontBold: true
                readOnly: true
                width: 100
                labelText: qsTr("Amount") + translationManager.emptyString
                placeholderText: "----"
            }

            LineEditMulti {
                id: feeLine
                KeyNavigation.tab: feeLine
                spacing: 0
                fontBold: true
                readOnly: true
                width: 100
                labelText: qsTr("Fee") + translationManager.emptyString
                placeholderText: "----"
            }
        }

        RowLayout {
            Layout.topMargin: 20
            StandardButton {
                id: signTransaction
                text: "Sign Transaction"
                enabled: txFilename != ""
                onClicked: {
                    console.log("Trying to sign tx");
                    if (!currentWallet.signMultisigTxFromFile(txFilename)) {
                        console.log("Failed to sign tx");
                        signTxErrorDialog.open()
                        return;
                    }
                    successfulSigningDialog.open();
                }
            }
            StandardButton {
                id: broadcastTransaction
                text: "Broadcast Transaction"
                enabled: txFilename != ""
                onClicked: {
                    console.log("Trying to submit multisig tx");
                    currentWallet.commitTransactionAsync(currentWallet.loadMultisigTxFromFile(txFilename));
                }
            }
        }
    }

    //Same as Transfer page
    FileDialog {
        id: exportMultisigKeyImagesDialog
        selectMultiple: false
        selectExisting: false
        onAccepted: {
            console.log(walletManager.urlToLocalPath(exportMultisigKeyImagesDialog.fileUrl));
            currentWallet.exportMultisigImages(walletManager.urlToLocalPath(exportMultisigKeyImagesDialog.fileUrl));
        }
        onRejected: {
            console.log("Canceled");
        }
    }

    FileDialog {
        id: importMultisigKeyImagesDialog
        selectMultiple: false
        selectExisting: true
        title: qsTr("Please choose a file") + translationManager.emptyString
        onAccepted: {
            console.log(walletManager.urlToLocalPath(importMultisigKeyImagesDialog.fileUrl));
            currentWallet.importMultisigImages(walletManager.urlToLocalPath(importMultisigKeyImagesDialog.fileUrl));
        }
        onRejected: {
            console.log("Canceled");
        }
    }

    // Ask user to choose partially signed transaction file
    FileDialog {
        id: loadMultisigTxDialog
        selectMultiple: false
        selectExisting: true
        title: qsTr("Please choose a file") + translationManager.emptyString
        onAccepted: {
            txFilename = walletManager.urlToLocalPath(loadMultisigTxDialog.fileUrl);
            console.log(txFilename);
            var transaction = currentWallet.loadMultisigTxFromFile(txFilename);
            if (transaction === null) {
              console.log("transaction null");
              txFilename = "";
              errorDialog.open()
              return;
            }
            addressLine.text = transaction.address;
            amountLine.text = Utils.printMoney(transaction.amount);
            feeLine.text = Utils.printMoney(transaction.fee);
        }
        onRejected: {
            console.log("Canceled");
        }
    }

    SuccessfulTxDialog {
        id: successfulSigningDialog
        z: parent.z + 1
    }

    StandardDialog {
        id: loadTxErrorDialog
        title: qsTr("Error Loading Transaction from File") + translationManager.emptyString
        cancelVisible: false
    }

    StandardDialog {
        id: signTxErrorDialog
        title: qsTr("Error Signing Transaction") + translationManager.emptyString
        cancelVisible: false
    }
}