import QtQuick 2.9

import "." as MoneroComponents
import "effects/" as MoneroEffects

Rectangle {
    color: MoneroComponents.Style.appWindowBorderColor
    height: 1

    MoneroEffects.ColorTransition {
        targetObj: parent
        blackColor: MoneroComponents.Style._b_appWindowBorderColor
        whiteColor: MoneroComponents.Style._w_appWindowBorderColor
    }
}
