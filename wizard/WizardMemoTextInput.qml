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
            property alias placeholderText: memoTextPlaceholder.text
            textMargin: 8 * scaleRatio
            text: ""
            font.family: "Arial"
            font.pixelSize: 16 * scaleRatio
            wrapMode: TextInput.Wrap
            width: parent.width
            selectByMouse: true
            property int minimumHeight: 100 * scaleRatio
            height: contentHeight > minimumHeight ? contentHeight : minimumHeight

            Text {
                id: memoTextPlaceholder
                anchors.fill:parent
                font.pixelSize: 16 * scaleRatio
                anchors.margins: 8 * scaleRatio
                font.bold:true
                font.family: "Arial"
                text: qsTr("Enter your 25 (or 24) word mnemonic seed") + translationManager.emptyString
                color: "#BABABA"
                visible: !memoTextInput.text/* && !parent.focus*/
            }
        }
        Image {
            id : clipboardButton
            anchors.right: parent.right
            anchors.rightMargin: 5 * scaleRatio
            anchors.bottom: tipRect.top
            anchors.bottomMargin: 5 * scaleRatio
            source: "qrc:///images/copyToClipboard.png"
            Clipboard { id: clipboard }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    clipboard.setText(memoTextInput.text)
                    appWindow.showStatusMessage(qsTr("Seed copied to clipboard"),3)
                }

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
                anchors.topMargin : 16 * scaleRatio
                anchors.bottomMargin: 16 * scaleRatio
                anchors.leftMargin: 16 * scaleRatio
                anchors.rightMargin: 16 * scaleRatio
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Arial"
                font.pixelSize: 15 * scaleRatio
                color: "#4A4646"
                wrapMode: Text.Wrap
                text: qsTr("This seed is <b>very</b> important to write down and keep secret. It is all you need to backup and restore your wallet.")
                    + translationManager.emptyString
            }
        }
    }
}
