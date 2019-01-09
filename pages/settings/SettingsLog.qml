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

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents


Rectangle {
    property alias consoleArea: consoleArea
    color: "transparent"
    height: 1400
    Layout.fillWidth: true

    ColumnLayout {
        id: settingsLog
        property int itemHeight: 60 * scaleRatio
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: (isMobile)? 17 * scaleRatio : 20 * scaleRatio
        anchors.topMargin: 0
        spacing: 10

//        Rectangle {
//            // divider
//            Layout.preferredHeight: 1 * scaleRatio
//            Layout.fillWidth: true
//            Layout.bottomMargin: 8 * scaleRatio
//            color: MoneroComponents.Style.dividerColor
//            opacity: MoneroComponents.Style.dividerOpacity
//        }

        Text {
            Layout.bottomMargin: 2 * scaleRatio
            color: MoneroComponents.Style.defaultFontColor
            font.pixelSize: 18 * scaleRatio
            font.family: MoneroComponents.Style.fontRegular.name
            text: qsTr("Log level") + translationManager.emptyString
        }

        ColumnLayout {
            spacing: 10 * scaleRatio
            Layout.fillWidth: true
            id: logColumn
            z: parent.z + 1

            ListModel {
                 id: logLevel
                 ListElement { column1: "0"; name: "none"; }
                 ListElement { column1: "1"; }
                 ListElement { column1: "2"; }
                 ListElement { column1: "3"; }
                 ListElement { column1: "4"; }
                 ListElement { column1: "custom"; }
            }

            MoneroComponents.StandardDropdown {
                id: logLevelDropdown
                dataModel: logLevel
                itemTopMargin: 2 * scaleRatio
                currentIndex: appWindow.persistentSettings.logLevel;
                onChanged: {
                    if (currentIndex == 5) {
                        console.log("log categories changed: ", logCategories.text);
                        walletManager.setLogCategories(logCategories.text);
                    }
                    else {
                        console.log("log level changed: ",currentIndex);
                        walletManager.setLogLevel(currentIndex);
                    }
                    appWindow.persistentSettings.logLevel = currentIndex;
                }
                Layout.fillWidth: true
                Layout.preferredWidth: logColumn.width
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#363636"
                pressedColor: "#202020"
                z: parent.z + 1
            }

            MoneroComponents.LineEdit {
                id: logCategories
                visible: logLevelDropdown.currentIndex === 5
                Layout.fillWidth: true
                Layout.preferredWidth: logColumn.width
                text: appWindow.persistentSettings.logCategories
                placeholderText: "(e.g. *:WARNING,net.p2p:DEBUG)"
                placeholderFontSize: 14 * scaleRatio
                fontSize: 14 * scaleRatio
                enabled: logLevelDropdown.currentIndex === 5
                onEditingFinished: {
                    if(enabled) {
                        console.log("log categories changed: ", text);
                        walletManager.setLogCategories(text);
                        appWindow.persistentSettings.logCategories = text;
                    }
                }
            }
        }

        Text {
            Layout.topMargin: 10 * scaleRatio
            Layout.bottomMargin: 2 * scaleRatio
            color: MoneroComponents.Style.defaultFontColor
            font.pixelSize: 18 * scaleRatio
            font.family: MoneroComponents.Style.fontRegular.name
            text: qsTr("Daemon log") + translationManager.emptyString
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 240 * scaleRatio

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: MoneroComponents.Style.inputBorderColorActive
                border.width: 1
                radius: 4
            }

            Flickable {
                id: flickable
                anchors.fill: parent

                TextArea.flickable: TextArea {
                    id : consoleArea
                    color: MoneroComponents.Style.defaultFontColor
                    selectionColor: MoneroComponents.Style.dimmedFontColor
                    textFormat: TextEdit.RichText
                    selectByMouse: true
                    selectByKeyboard: true
                    font.family: MoneroComponents.Style.defaultFontColor
                    font.pixelSize: 14 * scaleRatio
                    wrapMode: TextEdit.Wrap
                    readOnly: true
                    function logCommand(msg){
                        msg = log_color(msg, "lime");
                        consoleArea.append(msg);
                    }
                    function logMessage(msg){
                        msg = msg.trim();
                        var color = "white";
                        if(msg.toLowerCase().indexOf('error') >= 0){
                            color = "red";
                        } else if (msg.toLowerCase().indexOf('warning') >= 0){
                            color = "yellow";
                        }

                        // format multi-lines
                        if(msg.split("\n").length >= 2){
                            msg = msg.split("\n").join('<br>');
                        }

                        log(msg, color);
                    }
                    function log_color(msg, color){
                        return "<span style='color: " + color +  ";' >" + msg + "</span>";
                    }
                    function log(msg, color){
                        var timestamp = Utils.formatDate(new Date(), {
                            weekday: undefined,
                            month: "numeric",
                            timeZoneName: undefined
                        });

                        var _timestamp = log_color("[" + timestamp + "]", "#FFFFFF");
                        var _msg = log_color(msg, color);
                        consoleArea.append(_timestamp + " " + _msg);

                        // scroll to bottom
                        //if(flickable.contentHeight > content.height){
                        //    flickable.contentY = flickable.contentHeight;
                        //}
                    }
                }

                ScrollBar.vertical: ScrollBar {}
            }
        }

        MoneroComponents.LineEdit {
            id: sendCommandText
            Layout.fillWidth: true
            fontBold: false
            placeholderText: qsTr("command + enter (e.g 'help' or 'status')") + translationManager.emptyString
            placeholderFontSize: 16 * scaleRatio
            onAccepted: {
                if(text.length > 0) {
                    consoleArea.logCommand(">>> " + text)
                    daemonManager.sendCommand(text, currentWallet.nettype);
                }
                text = ""
            }
        }
    }

    Component.onCompleted: {
        logLevelDropdown.currentIndex = appWindow.persistentSettings.logLevel;
        logLevelDropdown.update();

        if(typeof daemonManager != "undefined")
            daemonManager.daemonConsoleUpdated.connect(onDaemonConsoleUpdated)
    }
}
