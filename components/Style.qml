pragma Singleton

import QtQuick 2.5

QtObject {
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "qrc:/fonts/SFUIDisplay-Medium.otf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "qrc:/fonts/SFUIDisplay-Bold.otf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "qrc:/fonts/SFUIDisplay-Light.otf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "qrc:/fonts/SFUIDisplay-Regular.otf"; }

    property string grey: "#404040"

    property string defaultFontColor: "#FF5608"
    property string greyFontColor: "#808080"
    property string dimmedFontColor: "#BBBBBB"
    property string inputBoxBackground: "#DDDDDD"
    property string inputBoxBackgroundError: "#FFDDDD"
    property string inputBoxColor: "white"
    property string legacy_placeholderFontColor: "#BABABA"

    property string buttonBackgroundColor: "#EB12FF"
    property string buttonBackgroundColorHover: "#8D0E9B"
    property string buttonBackgroundColorDisabled: "#430548"
    property string buttonBackgroundColorDisabledHover: "#29032C"
    property string buttonTextColor: "white"
    property string buttonTextColorDisabled: "black"
    property string dividerColor: "white"
    property real dividerOpacity: 0.25
}
