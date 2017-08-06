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

import QtQuick 2.2
import QtQuick.XmlListModel 2.0
import QtQuick.Layouts 1.1
import QtQml 2.2



ColumnLayout {
//    anchors.fill:parent
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    function onPageClosed(settingsObject) {

        // set default language to first item if none selected
        if(gridView.currentIndex === -1) {
            gridView.currentIndex = 0
        }

        var lang = languagesModel.get(gridView.currentIndex);
        settingsObject['language'] = lang.display_name;
        settingsObject['wallet_language'] = lang.wallet_language;
        settingsObject['locale'] = lang.locale;
        console.log("Language chosen: ",lang.display_name)
        return true
    }

    ColumnLayout {
        id: headerColumn
        Layout.leftMargin: wizardLeftMargin
        Layout.rightMargin: wizardRightMargin
        Layout.bottomMargin: 40 * scaleRatio
        spacing: 20 * scaleRatio

        Text {
            Layout.fillWidth: true
            font.family: "Arial"
            font.pixelSize: 28 * scaleRatio
            color: "#3F3F3F"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Welcome to Monero!") + translationManager.emptyString
        }

        Text {
            Layout.fillWidth: true
            font.family: "Arial"
            font.pixelSize: 18 * scaleRatio
            color: "#4A4646"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Please choose a language and regional format.") + translationManager.emptyString
        }
    }


    // Flags model
    XmlListModel {
        id: languagesModel
        source: "/lang/languages.xml"
        query: "/languages/language"

        XmlRole { name: "display_name"; query: "@display_name/string()" }
        XmlRole { name: "locale"; query: "@locale/string()" }
        XmlRole { name: "wallet_language"; query: "@wallet_language/string()" }
        XmlRole { name: "flag"; query: "@flag/string()" }
        // TODO: XmlListModel is read only, we should store current language somewhere else
        // and set current language accordingly
        XmlRole { name: "isCurrent"; query: "@enabled/string()" }

        onStatusChanged: {
            if(status === XmlListModel.Ready){
                console.log("languages availible: ",count);
                if(count === 1){
                    console.log("Skipping language page until more languages are availible")
                    wizard.switchPage(true);
                }
            }
        }
    }

    ColumnLayout{
        // Flags view
        GridView {
            property int margin: (isMobile) ? 0 : Math.floor(appWindow.width/12);

            id: gridView
            cellWidth: 140 * scaleRatio
            cellHeight: 120 * scaleRatio
            model: languagesModel
            // Hack to center the flag grid
            property int columns: Math.floor(appWindow.width/cellWidth)
            Layout.leftMargin: margin + (appWindow.width  - cellWidth*columns) /2
            Layout.rightMargin: margin
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            delegate: ColumnLayout {
                id: flagDelegate
                width: gridView.cellWidth
//                height: gridView.cellHeight
//                Layout.alignment: Qt.AlignHCenter
                Rectangle {
                    id: flagRect
                    width: 60 * scaleRatio; height: 60 * scaleRatio
//                    anchors.centerIn: parent
                    radius: 30 * scaleRatio
                    Layout.alignment: Qt.AlignHCenter
                    color: gridView.currentIndex === index ? "#DBDBDB" : "#FFFFFF"
                    Image {
                        anchors.fill: parent
                        source: flag
                    }
                }

                Text {
                    font.family: "Arial"
                    font.pixelSize: 18 * scaleRatio
//                    anchors.horizontalCenter: parent.horizontalCenter
                    font.bold: gridView.currentIndex === index
//                    elide: Text.ElideRight
                    color: "#3F3F3F"
                    text: display_name
//                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }
                MouseArea {
                    id: delegateArea
                    anchors.fill: parent
                    onClicked:  {
                        gridView.currentIndex = index
                        var data = languagesModel.get(gridView.currentIndex);
                        if (data !== null || data !== undefined) {
                            var locale = data.locale
                            translationManager.setLanguage(locale.split("_")[0]);
                            wizard.switchPage(true)
                        }
                    }
                }
            } // delegate

    }




    }


}
