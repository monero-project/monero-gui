pragma Singleton

import QtQuick 2.5

QtObject {
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "qrc:/fonts/Roboto-Medium.ttf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "qrc:/fonts/Roboto-Bold.ttf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "qrc:/fonts/Roboto-Light.ttf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "qrc:/fonts/Roboto-Regular.ttf"; }

    property string grey: "#404040"
    property string orange: "#FF6C3C"
    property string white: "#FFFFFF"
    property string green: "#2EB358"
    property string moneroGrey: "#4C4C4C"

    property string defaultFontColor: "white"
    property string dimmedFontColor: "#BBBBBB"
    property string errorColor: "#FA6800"
    property string inputBoxBackground: "black"
    property string inputBoxBackgroundError: "#FFDDDD"
    property string inputBoxColor: "white"
    property string legacy_placeholderFontColor: "#BABABA"
    property string inputBorderColorActive: Qt.rgba(255, 255, 255, 0.38)
    property string inputBorderColorInActive: Qt.rgba(255, 255, 255, 0.32)
    property string inputBorderColorInvalid: Qt.rgba(255, 0, 0, 0.40)

    property string buttonBackgroundColor: "#FA6800"
    property string buttonBackgroundColorHover: "#E65E00"
    property string buttonBackgroundColorDisabled: "#707070"
    property string buttonBackgroundColorDisabledHover: "#808080"
    property string buttonTextColor: "white"
    property string buttonTextColorDisabled: "black"
    property string dividerColor: "white"
    property real dividerOpacity: 0.20
}
