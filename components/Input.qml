import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick 2.2

TextField {
    font.family: "Arial"

    style: TextFieldStyle {
        textColor: "#3F3F3F"
        placeholderTextColor: "#BABABA"

        background: Rectangle {
            border.width: 0
            color: "transparent"
        }
    }
}
