import QtQuick 2.0

Rectangle {
    property var flickable
    property int yPos: 0

    function flickableContentYChanged() {
        if(flickable === undefined)
            return

        var t = flickable.height - height
        y = (flickable.contentY / (flickable.contentHeight - flickable.height)) * t + yPos
    }

    width: 12
    height: {
        var t = (flickable.height * flickable.height) / flickable.contentHeight
        return t < 20 ? 20 : t
    }
    z: 1; y: yPos
    color: "#DBDBDB"
    anchors.right: flickable.right
    opacity: flickable.moving ? 0.5 : 0
    visible: flickable.contentHeight > flickable.height

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }
}
