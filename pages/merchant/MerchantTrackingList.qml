import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents

ListView {
    id: trackingListView

    // items will not be drawn when a message is set
    property string message: ""

    boundsBehavior: ListView.StopAtBounds
    Layout.fillWidth: true
    clip: true

    signal hideAmountToggled(string txid)

    function viewTx(txid){
        // @TODO: implement blockexplorer-like page. Redirect to history for now
        appWindow.showPageRequest("History");
    }

    TextEdit {
        // message box
        visible: parent.message !== ""
        anchors.fill: parent
        anchors.margins: 20 * scaleRatio
        anchors.topMargin: 10 * scaleRatio
        wrapMode: Text.Wrap

        font.pixelSize: 14 * scaleRatio
        font.bold: false
        color: "#767676"
        textFormat: Text.RichText
        text: parent.message
        selectionColor: MoneroComponents.Style.dimmedFontColor
        selectByMouse: true
        readOnly: true
        onFocusChanged: {if(focus === false) deselect() }
    }

    delegate: Item {
        id: trackingTableItem
        visible: trackingListView.message === ""
        height: 53 * scaleRatio
        width: parent.width
        Layout.fillWidth: true

        RowLayout {
            id: container
            height: parent.height
            width: parent.width
            spacing: 0

            Item {
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: 20 * scaleRatio
            }

            ColumnLayout {
                spacing: 0
                Layout.preferredHeight: 40 * scaleRatio
                Layout.preferredWidth: 240 * scaleRatio

                Item {
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 18 * scaleRatio

                    TextEdit {
                        id: dateString
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 12 * scaleRatio
                        font.bold: false
                        color: "#707070"
                        text: time_date + " (" + Utils.ago(time_epoch) + ") "
                        selectionColor: MoneroComponents.Style.dimmedFontColor
                        selectByMouse: true
                        readOnly: true
                        onFocusChanged: {if(focus === false) deselect() }
                    }

                    Rectangle {
                        anchors.left: dateString.right
                        anchors.leftMargin: 2
                        width: hideAmount.width + 2
                        height: 20
                        color: 'transparent'

                        TextEdit {
                            id: hideAmount
                            anchors.top: parent.top
                            anchors.topMargin: 1 * scaleRatio
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            readOnly: true
                            font.pixelSize: 12 * scaleRatio
                            font.bold: false
                            color: "#707070"
                            text: hide_amount ? "(" + qsTr("show") + ")" : "(" + qsTr("hide") + ")"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                trackingListView.hideAmountToggled(txid);
                                hide_amount = !hide_amount;
                            }
                        }
                    }
                }

                Item {
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 18 * scaleRatio

                    TextEdit {
                        id: amountText
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 14 * scaleRatio
                        font.bold: true
                        color: hide_amount ? "#707070" : "#009F1E"
                        text: hide_amount ? '-' : '+' + amount
                        selectionColor: MoneroComponents.Style.dimmedFontColor
                        selectByMouse: true
                        readOnly: true
                        onFocusChanged: {if(focus === false) deselect() }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 0
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: 240 * scaleRatio

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                }

                Item {
                    Layout.preferredWidth: 150 * scaleRatio
                    Layout.preferredHeight: parent.height

                    TextEdit {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 12 * scaleRatio
                        font.bold: false
                        color: "#a8a8a8"
                        text: {
                            if(in_txpool){
                                return qsTr("Awaiting in txpool") + translationManager.emptyString;
                            } else {
                                if(confirmations > 1){
                                    if(confirmations > 100){
                                        return "100+ " + qsTr("confirmations") + translationManager.emptyString;
                                    } else {
                                        return confirmations + " " + qsTr("confirmations") + translationManager.emptyString;
                                    }
                                } else {
                                    return "1 " + qsTr("confirmation") + translationManager.emptyString;
                                }
                            }
                        }
                        selectionColor: MoneroComponents.Style.dimmedFontColor
                        selectByMouse: true
                        readOnly: true
                        onFocusChanged: {if(focus === false) deselect() }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            viewTx(txid);
                        }
                    }
                }

                Item {
                    Layout.preferredWidth: 30 * scaleRatio
                    Layout.preferredHeight: parent.height

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        Layout.preferredWidth: 12 * scaleRatio
                        Layout.preferredHeight: 21 * scaleRatio
                        source: "../../images/merchant/arrow_right.png"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            viewTx(txid);
                        }
                    }
                }

                Item {
                    Layout.preferredWidth: 10 * scaleRatio
                    Layout.preferredHeight: parent.height
                }
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: container.bottom
            height: 1
            color: "#F0F0F0"
        }
    }
}
