import QtQuick 2.2

Rectangle {
    id: wizard
    border.color: "#DBDBDB"
    border.width: 1
    color: "#FFFFFF"

    Rectangle {
        id: nextButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 50

        width: 50; height: 50
        radius: 25
        color: nextArea.containsMouse ? "#FF4304" : "#FF6C3C"

        Image {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 3
            source: "qrc:///images/nextPage.png"
        }

        MouseArea {
            id: nextArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: wizard.switchPage(true)
        }
    }

    property int currentPage: 0
    function switchPage(next) {
        var pages = new Array()
        pages[0] = welcomePage
        pages[1] = optionsPage
        pages[2] = createWalletPage

        if(next === false) {
            if(currentPage > 0) {
                pages[currentPage].opacity = 0
                pages[--currentPage].opacity = 1
            }
        } else {
            if(currentPage < pages.length - 1) {
                pages[currentPage].opacity = 0
                pages[++currentPage].opacity = 1
            }
        }
    }

    WizardWelcome {
        id: welcomePage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
    }

    WizardOptions {
        id: optionsPage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
        onCreateWalletClicked: wizard.switchPage(true)
    }

    WizardCreateWallet {
        id: createWalletPage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
    }

    Rectangle {
        id: prevButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 50
        visible: parent.currentPage > 0

        width: 50; height: 50
        radius: 25
        color: prevArea.containsMouse ? "#FF4304" : "#FF6C3C"

        Image {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -3
            source: "qrc:///images/prevPage.png"
        }

        MouseArea {
            id: prevArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: wizard.switchPage(false)
        }
    }
}
