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

import QtQuick 2.2
import QtQuick.Controls 1.2
import "tweetSearch.js" as Helper
import "../components"

Item {
    id: tab



    ListModel {
        id: testModel
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
        ListElement { head: "Monero || #xmr"; foot: "<b>@btcplanet</b> Duis turpis arcu, varius nec rutrum in, adipiscing at enim. Donec quis consequat ipsum," }
    }

    property int inAnimDur: 250
    property int counter: 0
    property alias isLoading: tweetsModel.isLoading
    property var idx
    property var ids

    function updateTweets() {
        tweetsModel.reload()
    }


    Component.onCompleted: {
        ids = new Array()
    }


    function idInModel(id) {
        for (var j = 0; j < ids.length; j++)
            if (ids[j] === id)
                return 1
        return 0
    }

    TweetsModel {
        id: tweetsModel
        onIsLoaded: {
            console.debug("Reload")
            idx = new Array()
            for (var i = 0; i < tweetsModel.model.count; i++) {
                var id = tweetsModel.model.get(i).id
                if (!idInModel(id))
                    idx.push(i)
            }
            console.debug(idx.length + " new tweets")
            tab.counter = idx.length
        }
    }

    Timer {
        id: timer
        interval: 1; running: tab.counter; repeat: true
        onTriggered: {
            tab.counter--;
            var id = tweetsModel.model.get(idx[tab.counter]).id
            var item = tweetsModel.model.get(tab.counter)
            listView.add({ "statusText": item.text,
                           "twitterName": item.user.screen_name,
                           "name" : item.user.name,
                           "userImage": item.user.profile_image_url,
                           "source": item.source,
                           "id": id,
                           "uri": Helper.insertLinks(item.user.url, item.user.entities),
                           "published": item.created_at });
            ids.push(id)
        }
    }

    Scroll {
        id: flickableScroll
        anchors.right: listView.right
        anchors.rightMargin: -14
        anchors.top: listView.top
        anchors.bottom: listView.bottom
        flickable: listView
    }

    ListView {
        id: listView
        model: ListModel { id: finalModel }
        anchors.fill: parent
        clip: true
        boundsBehavior: ListView.StopAtBounds
        onContentYChanged: flickableScroll.flickableContentYChanged()

        function add(obj) { model.insert(0, obj) }
        delegate: Rectangle {
            height: 88
            width: listView.width

            Text {
                id: headerText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 11
                elide: Text.ElideRight
                font.family: "Arial"
                font.pixelSize: 18
                color: "#000000"
                text: model.name
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: headerText.bottom
                anchors.bottom: parent.bottom
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                font.family: "Arial"
                font.pixelSize: 12
                color: "#535353"
                text: model.statusText
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: "#DBDBDB"
            }
        }
    }
}
