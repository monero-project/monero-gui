import QtQuick 2.0
import moneroComponents.Clipboard 1.0

Column {

    property alias memoText : memoTextInput.text
    property alias tipText: wordsTipText.text
    property alias tipTextVisible: tipRect.visible
    property alias memoTextReadOnly : memoTextInput.readOnly
    property alias clipboardButtonVisible: clipboardButton.visible


    Rectangle {
        id: memoTextRect
        width: parent.width
        height:  {
            memoTextInput.height
                    // to have less gap between button and text input we reduce overall height by button height
                    //+ (clipboardButton.visible ? clipboardButton.height : 0)
                    + (tipRect.visible ? tipRect.height : 0)
        }
        border.width: 1
        border.color: "#DBDBDB"

        TextEdit {
            id: memoTextInput
            textMargin: 8
            text: ""
            font.family: "Arial"
            font.pointSize: 16
            wrapMode: TextInput.Wrap
            width: parent.width
            selectByMouse: true
            property int minimumHeight: 100
            height: contentHeight > minimumHeight ? contentHeight : minimumHeight
        }
        Image {
            id : clipboardButton
            anchors.right: parent.right
            anchors.bottom: tipRect.top
            source: "qrc:///images/greyTriangle.png"
            Image {
                anchors.centerIn: parent
                source: "qrc:///images/copyToClipboard.png"
            }
            Clipboard { id: clipboard }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: clipboard.setText(memoTextInput.text)
            }
        }
        Rectangle {
            id: tipRect
            visible: true
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: memoTextRect.bottom
            height: wordsTipText.contentHeight + wordsTipText.anchors.topMargin
            color: "#DBDBDB"
            property alias text: wordsTipText.text

            Text {
                id: wordsTipText
                anchors.fill: parent
                anchors.topMargin : 16
                anchors.bottomMargin: 16
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Arial"
                font.pixelSize: 15
                color: "#4A4646"
                wrapMode: Text.Wrap
                text: qsTr("It is very important to write it down as this is the only backup you will need for your wallet. You will be asked to confirm the seed in the next screen to ensure it has copied down correctly.")
                    + translationManager.emptyString
            }
        }
    }
}
