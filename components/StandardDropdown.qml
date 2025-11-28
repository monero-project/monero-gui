import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import FontAwesome 1.0
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

ColumnLayout {
    id: dropdown
    Layout.fillWidth: true
    z: expanded ? 100 : 1

    property int itemTopMargin: 0
    property alias dataModel: repeater.model

    property string pressedColor: "#DD1D1D1D"
    property string releasedColor: "#FF000000"
    property string textColor: MoneroComponents.Style.orange

    property int currentIndex: 0

    readonly property alias expanded: popup.visible
    property alias labelText: dropdownLabel.text
    property alias labelColor: dropdownLabel.color
    property alias labelTextFormat: dropdownLabel.textFormat
    property alias labelWrapMode: dropdownLabel.wrapMode
    property alias labelHorizontalAlignment: dropdownLabel.horizontalAlignment
    property bool showingHeader: dropdownLabel.text !== ""
    property int labelFontSize: 14
    property bool labelFontBold: false
    property int dropdownHeight: 39
    property int fontSize: 14
    property int fontItemSize: 14

    property string colorBorder: MoneroComponents.Style.orange
    property int borderWidth: 1
    property string colorHeaderBackground: "transparent"
    property bool headerBorder: true
    property bool headerFontBold: true

    property string itemFontFamily: MoneroComponents.Style.fontRegular.name
    property color itemTextColor: "#AAFFFFFF"
    property color selectedItemTextColor: "#FA6800"
    property bool itemTextShadow: true
    property color textShadowColor: "black"

    signal changed();

    onExpandedChanged: if(expanded) appWindow.currentItem = dropdown

    spacing: 0
    Rectangle {
        id: dropdownLabelRect
        color: "transparent"
        Layout.fillWidth: true
        height: (dropdownLabel.height + 10)
        visible: showingHeader ? true : false

        MoneroComponents.TextPlain {
            id: dropdownLabel
            anchors.top: parent.top
            anchors.left: parent.left
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: labelFontSize
            font.bold: labelFontBold
            textFormat: Text.RichText
            color: MoneroComponents.Style.defaultFontColor
        }
    }

    Rectangle {
        id: head
        color: dropArea.containsMouse ? MoneroComponents.Style.titleBarButtonHoverColor : colorHeaderBackground
        border.width: dropdown.headerBorder ? dropdown.borderWidth : 0
        border.color: dropdown.colorBorder
        radius: 4
        Layout.fillWidth: true
        Layout.preferredHeight: dropdownHeight

        MoneroComponents.TextPlain {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: dropIndicator.left
            anchors.rightMargin: 12
            width: droplist.width
            elide: Text.ElideRight
            font.family: dropdown.itemFontFamily
            font.bold: dropdown.headerFontBold
            font.pixelSize: dropdown.fontSize
            color: dropdown.textColor

            text: {
                if (!repeater.model) return "";
                var count = 0;
                if (Array.isArray(repeater.model)) count = repeater.model.length;
                else if (repeater.model.count !== undefined) count = repeater.model.count;

                if (dropdown.currentIndex < 0 || dropdown.currentIndex >= count) return "";

                var item;
                if (typeof repeater.model.get === "function") {
                    item = repeater.model.get(dropdown.currentIndex);
                } else {
                    item = repeater.model[dropdown.currentIndex];
                }

                // CRITICAL FIX: Check if item exists
                if (!item) return "";
                var txt = (item.column1 !== undefined) ? item.column1 : item.text;
                return qsTr(txt ? txt : "") + translationManager.emptyString;
            }
        }

        Item {
            id: dropIndicator
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 12
            width: dropdownIcon.width

            MoneroEffects.ImageMask {
                id: dropdownIcon
                anchors.centerIn: parent
                image: "qrc:///images/whiteDropIndicator.png"
                height: 8
                width: 12
                fontAwesomeFallbackIcon: FontAwesome.arrowDown
                fontAwesomeFallbackSize: 14
                color: dropdown.textColor
            }
        }

        MouseArea {
            id: dropArea
            anchors.fill: parent
            onClicked: dropdown.expanded ? popup.close() : popup.open()
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    Popup {
        id: popup
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        y: head.height + 5
        width: dropdown.width
        z: 100

        background: Rectangle {
            color: "transparent"
        }

        Rectangle {
            id: droplist
            width: dropdown.width
            height: Math.min(columnid.height, 300)
            clip: true

            color: dropdown.pressedColor
            border.width: dropdown.borderWidth
            border.color: dropdown.colorBorder
            radius: 4

            ScrollView {
                anchors.fill: parent
                contentHeight: columnid.height

                Column {
                    id: columnid
                    width: parent.width

                    Repeater {
                        id: repeater
                        model: dropdown.dataModel

                        delegate: Rectangle {
                            width: dropdown.width
                            height: (dropdown.dropdownHeight * 0.85)

                            color: (index === dropdown.currentIndex || itemArea.containsMouse) ? dropdown.releasedColor : "transparent"

                            MoneroComponents.TextPlain {
                                id: col1Text
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                font.family: dropdown.itemFontFamily
                                font.bold: index === dropdown.currentIndex
                                font.pixelSize: fontItemSize

                                color: (index === dropdown.currentIndex || itemArea.containsMouse) ? dropdown.selectedItemTextColor : dropdown.itemTextColor

                                style: dropdown.itemTextShadow ? Text.Raised : Text.Normal
                                styleColor: dropdown.textShadowColor

                                text: {
                                    // CRITICAL FIX: Check if model item exists
                                    if (!model) return "";
                                    var txt = (model.column1 !== undefined) ? model.column1 : model.text;
                                    return qsTr(txt ? txt : "") + translationManager.emptyString;
                                }
                            }

                            MouseArea {
                                id: itemArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    popup.close()
                                    dropdown.currentIndex = index
                                    dropdown.changed()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
