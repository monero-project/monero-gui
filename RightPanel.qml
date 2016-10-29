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
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0

import "tabs"
import "components"

Rectangle {
    id: root
    width: 330
    color: "#FFFFFF"

    function updateTweets() {
        tabView.twitter.item.updateTweets()
    }


    TabView {
        id: tabView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: styledRow.top
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 40
        property alias twitter: twitter




        Tab { id: twitter; title: qsTr("Twitter"); source: "tabs/Twitter.qml" }
        Tab { title: qsTr("News") + translationManager.emptyString }
        Tab { title: qsTr("Help") + translationManager.emptyString }
        Tab { title: qsTr("About") + translationManager.emptyString }



        style: TabViewStyle {
            frameOverlap: 0
            tabOverlap: 0

            tab: Rectangle {
                implicitHeight: 31
                implicitWidth: styleData.index === tabView.count - 1 ? tabView.width - (tabView.count - 1) * 68 : 68

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    elide: Text.ElideRight
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: styleData.selected ? "#FF4E40" : "#4A4646"
                    text: styleData.title
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    color: "#DBDBDB"
                    visible: styleData.index !== tabView.count - 1
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -1
                    height: 1
                    color: styleData.selected ? "#FFFFFF" : "#DBDBDB"
                }
            }

            frame: Rectangle {
                color: "#FFFFFF"
                anchors.fill: parent
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    //anchors.topMargin: 1
                    height: 1
                    color: "#DBDBDB"
                }
            }
        }
    }

    Row {
        id: styledRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Rectangle { height: 8; width: parent.width / 5; color: "#FFE00A" }
        Rectangle { height: 8; width: parent.width / 5; color: "#6B0072" }
        Rectangle { height: 8; width: parent.width / 5; color: "#FF6C3C" }
        Rectangle { height: 8; width: parent.width / 5; color: "#FFD781" }
        Rectangle { height: 8; width: parent.width / 5 - 30; color: "#FF4F41" }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: "#DBDBDB"
    }

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 1
        color: "#DBDBDB"
    }

    // indicate disabled state
//    Desaturate {
//        anchors.fill: parent
//        source: parent
//        desaturation: root.enabled ? 0.0 : 1.0
//    }
}
