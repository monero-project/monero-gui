import QtQuick 2.0

Item {
    id: item
    property alias text: label.text
    property alias color: label.color
    property string tipText: ""
    property int fontSize: 12
    width: icon.x + icon.width
    height: icon.height

    Text {
        id: label
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.left: parent.left
        font.family: "Arial"
        font.pixelSize: parent.fontSize
        color: "#555555"
    }

    Image {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: label.right
        anchors.leftMargin: 5
        source: "../images/whatIsIcon.png"
        visible: appWindow.whatIsEnable
    }

    MouseArea {
        anchors.fill: icon
        enabled: appWindow.whatIsEnable
        hoverEnabled: true
        onEntered: {
            icon.visible = false
            var pos = rootItem.mapFromItem(icon, 0, -15)
            tipItem.text = item.tipText
            tipItem.x = pos.x
            if(tipItem.height > 30)
                pos.y -= tipItem.height - 28
            tipItem.y = pos.y
            tipItem.visible = true
        }
        onExited: {
            icon.visible = Qt.binding(function(){ return appWindow.whatIsEnable; })
            tipItem.visible = false
        }
    }
}
