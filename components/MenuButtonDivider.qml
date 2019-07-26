import QtQuick 2.9

import "." as NejCoinComponents
import "effects/" as NejCoinEffects

Rectangle {
    color: NejCoinComponents.Style.appWindowBorderColor
    height: 1

    NejCoinEffects.ColorTransition {
        targetObj: parent
        blackColor: NejCoinComponents.Style._b_appWindowBorderColor
        whiteColor: NejCoinComponents.Style._w_appWindowBorderColor
    }
}
