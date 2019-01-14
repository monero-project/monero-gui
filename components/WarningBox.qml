import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

import "." as MoneroComponents

Rectangle {
    id: root
    property alias text: content.text
    property alias textColor: content.color
    property int fontSize: 15 * scaleRatio

    Layout.fillWidth: true
    Layout.preferredHeight: warningLayout.height

    color: "#09FFFFFF"
    radius: 4
    border.color: MoneroComponents.Style.inputBorderColorInActive
    border.width: 1

    signal linkActivated;

    RowLayout {
        id: warningLayout
        spacing: 0
        anchors.left: parent.left
        anchors.right: parent.right

        Image {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 33 * scaleRatio
            Layout.preferredWidth: 33 * scaleRatio
            Layout.rightMargin: 12 * scaleRatio
            Layout.leftMargin: 18 * scaleRatio
            Layout.topMargin: 12 * scaleRatio
            Layout.bottomMargin: 12 * scaleRatio
            source: "../images/warning.png"
        }

        TextArea {
            id: content
            Layout.fillWidth: true
            color: MoneroComponents.Style.defaultFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: root.fontSize
            horizontalAlignment: TextInput.AlignLeft
            selectByMouse: true
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            textMargin: 0
            leftPadding: 4 * scaleRatio
            rightPadding: 18 * scaleRatio
            topPadding: 10 * scaleRatio
            bottomPadding: 10 * scaleRatio
            readOnly: true
            onLinkActivated: root.linkActivated();

            selectionColor: MoneroComponents.Style.dimmedFontColor
            selectedTextColor: MoneroComponents.Style.defaultFontColor
        }
    }
}
