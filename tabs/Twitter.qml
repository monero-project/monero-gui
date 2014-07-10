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
        anchors.rightMargin: -14
        flickable: listView
        yPos: listView.y
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
