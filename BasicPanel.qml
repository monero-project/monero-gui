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
import QtGraphicalEffects 1.0
import "components"
import "pages"

// mbg033 @ 2016-10-08: Not used anymore, to be deleted

Rectangle {
    id: root
    width: 470
    // height: paymentId.y + paymentId.height + 12
    height: header.height + header.anchors.topMargin + transferBasic.height
    color: "#F0EEEE"

    border.width: 1
    border.color: "#DBDBDB"

    property alias balanceText : balanceText.text;
    property alias unlockedBalanceText : availableBalanceText.text;
    // repeating signal to the outside world
    signal paymentClicked(string address, string paymentId, double amount, int mixinCount,
                          int priority)

    Connections {
        target: transferBasic
        onPaymentClicked: {
            console.log("BasicPanel: paymentClicked")
            root.paymentClicked(address, paymentId, amount, mixinCount, priority)
        }
    }


    Rectangle {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.topMargin: 30
        height: 64
        color: "#FFFFFF"

        Image {
            id: logo
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -5
            anchors.left: parent.left
            anchors.leftMargin: 20
            source: "images/moneroLogo2.png"
        }

        Grid {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            width: 256
            columns: 3

            Text {

                width: 116
                height: 20
                font.family: "Arial"
                font.pixelSize: 12
                font.letterSpacing: -1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                color: "#535353"
                text: qsTr("Locked Balance:")
            }

            Text {
                id: balanceText
                width: 110
                height: 20
                font.family: "Arial"
                font.pixelSize: 18
                font.letterSpacing: -1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                color: "#000000"
                text: qsTr("78.9239845")
            }

            Item {
                height: 20
                width: 20

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    source: "images/lockIcon.png"
                }
            }

            Text {
                width: 116
                height: 20
                font.family: "Arial"
                font.pixelSize: 12
                font.letterSpacing: -1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                color: "#535353"
                text: qsTr("Available Balance:")
            }

            Text {
                id: availableBalanceText
                width: 110
                height: 20
                font.family: "Arial"
                font.pixelSize: 14
                font.letterSpacing: -1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                color: "#000000"
                text: qsTr("2324.9239845")
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#DBDBDB"
        }
    }
    Item {
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        Transfer {
            id : transferBasic
            anchors.fill: parent
        }
    }

    // indicate disabled state
    Desaturate {
        anchors.fill: parent
        source: parent
        desaturation: root.enabled ? 0.0 : 1.0
    }


}
