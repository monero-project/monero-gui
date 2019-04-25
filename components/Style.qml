pragma Singleton

import QtQuick 2.5

QtObject {
    property bool blackTheme: true
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "qrc:/fonts/Roboto-Medium.ttf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "qrc:/fonts/Roboto-Bold.ttf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "qrc:/fonts/Roboto-Light.ttf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "qrc:/fonts/Roboto-Regular.ttf"; }

    property QtObject fontMonoMedium: FontLoader { id: _fontMonoMedium; source: "qrc:/fonts/RobotoMono-Medium.ttf"; }
    property QtObject fontMonoBold: FontLoader { id: _fontMonoBold; source: "qrc:/fonts/RobotoMono-Bold.ttf"; }
    property QtObject fontMonoLight: FontLoader { id: _fontMonoLight; source: "qrc:/fonts/RobotoMono-Light.ttf"; }
    property QtObject fontMonoRegular: FontLoader { id: _fontMonoRegular; source: "qrc:/fonts/RobotoMono-Regular.ttf"; }

    property string grey: "#404040"
    property string orange: "#FF6C3C"
    property string white: "#FFFFFF"
    property string green: "#2EB358"
    property string moneroGrey: "#4C4C4C"
    property string warningColor: "orange"

    property string defaultFontColor: blackTheme ? _b_defaultFontColor : _w_defaultFontColor
    property string dimmedFontColor: blackTheme ? _b_dimmedFontColor : _w_dimmedFontColor
    property string lightGreyFontColor: blackTheme ? _b_lightGreyFontColor : _w_lightGreyFontColor
    property string errorColor: blackTheme ? _b_errorColor : _w_errorColor
    property string textSelectionColor: blackTheme ? _b_textSelectionColor : _w_textSelectionColor
    property string textSelectedColor: blackTheme ? _b_textSelectedColor : _w_textSelectedColor

    property string inputBoxBackground: blackTheme ? _b_inputBoxBackground : _w_inputBoxBackground
    property string inputBoxBackgroundError: blackTheme ? _b_inputBoxBackgroundError : _w_inputBoxBackgroundError
    property string inputBoxColor: blackTheme ? _b_inputBoxColor : _w_inputBoxColor
    property string legacy_placeholderFontColor: blackTheme ? _b_legacy_placeholderFontColor : _w_legacy_placeholderFontColor
    property string inputBorderColorActive: blackTheme ? _b_inputBorderColorActive : _w_inputBorderColorActive
    property string inputBorderColorInActive: blackTheme ? _b_inputBorderColorInActive : _w_inputBorderColorInActive
    property string inputBorderColorInvalid: blackTheme ? _b_inputBorderColorInvalid : _w_inputBorderColorInvalid

    property string buttonBackgroundColor: blackTheme ? _b_buttonBackgroundColor : _w_buttonBackgroundColor
    property string buttonBackgroundColorHover: blackTheme ? _b_buttonBackgroundColorHover : _w_buttonBackgroundColorHover
    property string buttonBackgroundColorDisabled: blackTheme ? _b_buttonBackgroundColorDisabled : _w_buttonBackgroundColorDisabled
    property string buttonBackgroundColorDisabledHover: blackTheme ? _b_buttonBackgroundColorDisabledHover : _w_buttonBackgroundColorDisabledHover
    property string buttonInlineBackgroundColor: blackTheme ? _b_buttonInlineBackgroundColor : _w_buttonInlineBackgroundColor
    property string buttonTextColor: blackTheme ? _b_buttonTextColor : _w_buttonTextColor
    property string buttonTextColorDisabled: blackTheme ? _b_buttonTextColorDisabled : _w_buttonTextColorDisabled
    property string dividerColor: blackTheme ? _b_dividerColor : _w_dividerColor
    property real dividerOpacity: blackTheme ? _b_dividerOpacity : _w_dividerOpacity

    property string titleBarBackgroundGradientStart: blackTheme ? _b_titleBarBackgroundGradientStart : _w_titleBarBackgroundGradientStart
    property string titleBarBackgroundGradientStop: blackTheme ? _b_titleBarBackgroundGradientStop : _w_titleBarBackgroundGradientStop
    property string titleBarBackgroundBorderColor: blackTheme ? _b_titleBarBackgroundBorderColor : _w_titleBarBackgroundBorderColor
    property string titleBarLogoSource: blackTheme ? _b_titleBarLogoSource : _w_titleBarLogoSource
    property string titleBarMinimizeSource: blackTheme ? _b_titleBarMinimizeSource : _w_titleBarMinimizeSource
    property string titleBarExpandSource: blackTheme ? _b_titleBarExpandSource : _w_titleBarExpandSource
    property string titleBarFullscreenSource: blackTheme ? _b_titleBarFullscreenSource : _w_titleBarFullscreenSource
    property string titleBarCloseSource: blackTheme ? _b_titleBarCloseSource : _w_titleBarCloseSource
    property string titleBarButtonHoverColor: blackTheme ? _b_titleBarButtonHoverColor : _w_titleBarButtonHoverColor

    property string wizardBackgroundGradientStart: blackTheme ? _b_wizardBackgroundGradientStart : _w_wizardBackgroundGradientStart
    property string middlePanelBackgroundGradientStart: blackTheme ? _b_middlePanelBackgroundGradientStart : _w_middlePanelBackgroundGradientStart
    property string middlePanelBackgroundGradientStop: blackTheme ? _b_middlePanelBackgroundGradientStop : _w_middlePanelBackgroundGradientStop
    property string middlePanelBackgroundColor: blackTheme ? _b_middlePanelBackgroundColor : _w_middlePanelBackgroundColor
    property string menuButtonFallbackBackgroundColor: blackTheme ? _b_menuButtonFallbackBackgroundColor : _w_menuButtonFallbackBackgroundColor
    property string menuButtonGradientStart: blackTheme ? _b_menuButtonGradientStart : _w_menuButtonGradientStart
    property string menuButtonGradientStop: blackTheme ? _b_menuButtonGradientStop : _w_menuButtonGradientStop
    property string menuButtonTextColor: blackTheme ? _b_menuButtonTextColor : _w_menuButtonTextColor
    property string menuButtonImageRightColorActive: blackTheme ? _b_menuButtonImageRightColorActive : _w_menuButtonImageRightColorActive
    property string menuButtonImageRightColor: blackTheme ? _b_menuButtonImageRightColor : _w_menuButtonImageRightColor
    property string menuButtonImageRightSource: blackTheme ? _b_menuButtonImageRightSource : _w_menuButtonImageRightSource
    property string menuButtonImageDotArrowSource: blackTheme ? _b_menuButtonImageDotArrowSource : _w_menuButtonImageDotArrowSource
    property string inlineButtonTextColor: blackTheme ? _b_inlineButtonTextColor : _w_inlineButtonTextColor
    property string inlineButtonBorderColor: blackTheme ? _b_inlineButtonBorderColor : _w_inlineButtonBorderColor
    property string appWindowBackgroundColor: blackTheme ? _b_appWindowBackgroundColor : _w_appWindowBackgroundColor
    property string appWindowBorderColor: blackTheme ? _b_appWindowBorderColor : _w_appWindowBorderColor
    property bool progressBarProgressTextBold: blackTheme ? _b_progressBarProgressTextBold : _w_progressBarProgressTextBold
    property string progressBarBackgroundColor: blackTheme ? _b_progressBarBackgroundColor : _w_progressBarBackgroundColor
    property string leftPanelBackgroundGradientStart: blackTheme ? _b_leftPanelBackgroundGradientStart : _w_leftPanelBackgroundGradientStart
    property string leftPanelBackgroundGradientStop: blackTheme ? _b_leftPanelBackgroundGradientStop : _w_leftPanelBackgroundGradientStop
    property string historyHeaderTextColor: blackTheme ? _b_historyHeaderTextColor : _w_historyHeaderTextColor

    property string _b_defaultFontColor: "white"
    property string _b_dimmedFontColor: "#BBBBBB"
    property string _b_lightGreyFontColor: "#DFDFDF"
    property string _b_errorColor: "#FA6800"
    property string _b_textSelectionColor: "#BBBBBB"
    property string _b_textSelectedColor: "white"

    property string _b_inputBoxBackground: "black"
    property string _b_inputBoxBackgroundError: "#FFDDDD"
    property string _b_inputBoxColor: "white"
    property string _b_legacy_placeholderFontColor: "#BABABA"
    property string _b_inputBorderColorActive: Qt.rgba(255, 255, 255, 0.38)
    property string _b_inputBorderColorInActive: Qt.rgba(255, 255, 255, 0.32)
    property string _b_inputBorderColorInvalid: Qt.rgba(255, 0, 0, 0.40)

    property string _b_buttonBackgroundColor: "#FA6800"
    property string _b_buttonBackgroundColorHover: "#E65E00"
    property string _b_buttonBackgroundColorDisabled: "#707070"
    property string _b_buttonBackgroundColorDisabledHover: "#808080"
    property string _b_buttonInlineBackgroundColor: "#707070"
    property string _b_buttonTextColor: "white"
    property string _b_buttonTextColorDisabled: "black"
    property string _b_dividerColor: "white"
    property real _b_dividerOpacity: 0.20

    property string _b_titleBarBackgroundGradientStart: "#262626";
    property string _b_titleBarBackgroundGradientStop: "#191919"
    property string _b_titleBarBackgroundBorderColor: "#2f2f2f"
    property string _b_titleBarLogoSource: "qrc:///images/titlebarLogo.png"
    property string _b_titleBarMinimizeSource: "qrc:///images/minimize.svg"
    property string _b_titleBarExpandSource: "qrc:///images/sidebar.svg"
    property string _b_titleBarFullscreenSource: "qrc:///images/fullscreen.svg"
    property string _b_titleBarCloseSource: "qrc:///images/close.svg"
    property string _b_titleBarButtonHoverColor: "#10FFFFFF"

    property string _b_wizardBackgroundGradientStart: "#1e1e1e"
    property string _b_middlePanelBackgroundGradientStart: "#232323"
    property string _b_middlePanelBackgroundGradientStop: "#101010"
    property string _b_middlePanelBackgroundColor: "#181818"
    property string _b_menuButtonFallbackBackgroundColor: "#09FFFFFF"
    property string _b_menuButtonGradientStart: "#11FFFFFF"
    property string _b_menuButtonGradientStop: "#00000000"
    property string _b_menuButtonTextColor: "white"
    property string _b_menuButtonImageRightColorActive: "white"
    property string _b_menuButtonImageRightColor: "white"
    property string _b_menuButtonImageRightSource: "qrc:///images/right.svg"
    property string _b_menuButtonImageDotArrowSource: "qrc:///images/arrow-right-medium-white.png"
    property string _b_inlineButtonTextColor: "black"
    property string _b_inlineButtonBorderColor: "black"
    property string _b_appWindowBackgroundColor: "white"
    property string _b_appWindowBorderColor: "#313131"
    property bool _b_progressBarProgressTextBold: true
    property string _b_progressBarBackgroundColor: "#24FFFFFF"
    property string _b_leftPanelBackgroundGradientStart: "#222222"
    property string _b_leftPanelBackgroundGradientStop: "#1a1a1a"
    property string _b_historyHeaderTextColor: "#C0C0C0"

    property string _w_defaultFontColor: "black"
    property string _w_dimmedFontColor: "#3f3f3f"
    property string _w_lightGreyFontColor: "#515151"
    property string _w_errorColor: "#FA6800"
    property string _w_textSelectionColor: "#BBBBBB"
    property string _w_textSelectedColor: "black"

    property string _w_inputBoxBackground: "white"
    property string _w_inputBoxBackgroundError: "#FFDDDD"
    property string _w_inputBoxColor: "black"
    property string _w_legacy_placeholderFontColor: "#BABABA"
    property string _w_inputBorderColorActive: Qt.rgba(0, 0, 0, 0.30)
    property string _w_inputBorderColorInActive: Qt.rgba(0, 0, 0, 0.16)
    property string _w_inputBorderColorInvalid: Qt.rgba(255, 0, 0, 0.50)

    property string _w_buttonBackgroundColor: "#FA6800"
    property string _w_buttonBackgroundColorHover: "#E65E00"
    property string _w_buttonBackgroundColorDisabled: "#bbbbbb"
    property string _w_buttonBackgroundColorDisabledHover: "#D1D1D1"
    property string _w_buttonInlineBackgroundColor: "#bbbbbb"
    property string _w_buttonTextColor: "white"
    property string _w_buttonTextColorDisabled: "black"
    property string _w_dividerColor: "black"
    property real _w_dividerOpacity: 0.20

    property string _w_titleBarBackgroundGradientStart: "#fcfcfc"
    property string _w_titleBarBackgroundGradientStop: "#FBFBFB"
    property string _w_titleBarBackgroundBorderColor: "#DEDEDE"
    property string _w_titleBarLogoSource: "qrc:///images/themes/white/titlebarLogo.png"
    property string _w_titleBarMinimizeSource: "qrc:///images/themes/white/minimize.svg"
    property string _w_titleBarExpandSource: "qrc:///images/themes/white/expand.svg"
    property string _w_titleBarFullscreenSource: "qrc:///images/themes/white/fullscreen.svg"
    property string _w_titleBarCloseSource: "qrc:///images/themes/white/close.svg"
    property string _w_titleBarButtonHoverColor: "#11000000"

    property string _w_wizardBackgroundGradientStart: "white"
    property string _w_middlePanelBackgroundGradientStart: "white"
    property string _w_middlePanelBackgroundGradientStop: "#ededed"
    property string _w_middlePanelBackgroundColor: "#f5f5f5"
    property string _w_menuButtonFallbackBackgroundColor: "#09000000"
    property string _w_menuButtonGradientStart: "#08000000"
    property string _w_menuButtonGradientStop: "#10FFFFFF"
    property string _w_menuButtonTextColor: "#787878"
    property string _w_menuButtonImageRightSource: "qrc:///images/right.svg"
    property string _w_menuButtonImageRightColorActive: "#FA6800"
    property string _w_menuButtonImageRightColor: "#808080"
    property string _w_menuButtonImageDotArrowSource: "qrc:///images/arrow-right-medium-white.png"
    property string _w_inlineButtonTextColor: "white"
    property string _w_inlineButtonBorderColor: "transparent"
    property string _w_appWindowBackgroundColor: "black"
    property string _w_appWindowBorderColor: "#dedede"
    property bool _w_progressBarProgressTextBold: false
    property string _w_progressBarBackgroundColor: "#24000000"
    property string _w_leftPanelBackgroundGradientStart: "white"
    property string _w_leftPanelBackgroundGradientStop: "#f5f5f5"
    property string _w_historyHeaderTextColor: "#515151"
}
