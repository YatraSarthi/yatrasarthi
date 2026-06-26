import QtQuick 2.12
import QtQuick.Controls 2.12
import "pages"

Item {
    id: rideRoot

    // Passed in from AppLoader
    property var parentWindow

    anchors.fill: parent

    AppState { id: appState }

    readonly property bool   dm:             appState.darkMode
    readonly property color  bgPage:         dm ? "#121212" : "#FFFFFF"
    readonly property color  bgCard:         dm ? "#1E1E1E" : "#FFFFFF"
    readonly property color  bgBar:          dm ? "#1A1A2E" : "#E3F2FD"
    readonly property color  barBorder:      dm ? "#2A2A4A" : "#90CAF9"
    readonly property color  tabSel:         "#1976D2"
    readonly property color  tabUnsel:       dm ? "#2C2C2C" : "#FFFFFF"
    readonly property color  tabBorderSel:   "#1565C0"
    readonly property color  tabBorderUnsel: dm ? "#333355" : "#BBDEFB"
    readonly property color  tabTextSel:     "#FFFFFF"
    readonly property color  tabTextUnsel:   dm ? "#AAAAAA" : "#555555"

    property int currentTab: 0

    function switchTab(index) {
        currentTab = index
    }

    // ── App background ────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: bgPage
        z: -1
    }

    // ── Bottom nav ────────────────────────────────────────────────────────
    Rectangle {
        id:      bottomBar
        visible: appState.showBottomBar
        height:  visible ? 72 : 0
        color:   bgBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right

        Rectangle {
            anchors.top: parent.top
            width: parent.width; height: 1; color: barBorder
        }

        Row {
            anchors.centerIn: parent
            spacing: 10
            padding: 8

            Repeater {
                model: [
                    { label: "Home",     icon: "../assets/icons/pickup.png", idx: 0 },
                    { label: "Services", icon: "../assets/icons/auto.png",   idx: 1 },
                    { label: "Activity", icon: "../assets/icons/rider.png",  idx: 2 },
                    { label: "Account",  icon: "../assets/icons/driver.png", idx: 3 }
                ]

                delegate: Rectangle {
                    width:  78; height: 54; radius: 12
                    color:  currentTab === modelData.idx ? tabSel : tabUnsel
                    border.color: currentTab === modelData.idx
                                  ? tabBorderSel : tabBorderUnsel
                    border.width: 1

                    Column {
                        anchors.centerIn: parent; spacing: 3
                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            source:   Qt.resolvedUrl(modelData.icon)
                            width:    22; height: 22
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:      modelData.label
                            font.pixelSize: 10
                            font.bold: currentTab === modelData.idx
                            color:     currentTab === modelData.idx
                                       ? tabTextSel : tabTextUnsel
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked:    switchTab(modelData.idx)
                    }
                }
            }
        }
    }

    // ── Stacks ────────────────────────────────────────────────────────────
    StackView {
        id:      homeStack
        anchors { top: parent.top; left: parent.left; right: parent.right
                  bottom: bottomBar.top }
        visible: currentTab === 0

        Component.onCompleted: {
            var page = push(Qt.resolvedUrl("pages/HomePage.qml"))
            page.appStack = homeStack
            page.appState = appState
            page.switchTab.connect(switchTab)
        }
    }

    StackView {
        id:      servicesStack
        anchors { top: parent.top; left: parent.left; right: parent.right
                  bottom: bottomBar.top }
        visible: currentTab === 1

        Component.onCompleted: {
            var page = push(Qt.resolvedUrl("pages/ServicesPage.qml"))
            page.appStack = servicesStack
            page.appState = appState
        }
    }

    StackView {
        id:      activityStack
        anchors { top: parent.top; left: parent.left; right: parent.right
                  bottom: bottomBar.top }
        visible: currentTab === 2

        Component.onCompleted: {
            var page = push(Qt.resolvedUrl("pages/ActivityPage.qml"))
            page.appStack = activityStack
            page.appState = appState
        }
    }

    StackView {
        id:      accountStack
        anchors { top: parent.top; left: parent.left; right: parent.right
                  bottom: bottomBar.top }
        visible: currentTab === 3

        Component.onCompleted: {
            var page = push(Qt.resolvedUrl("pages/AccountPage.qml"))
            page.appStack = accountStack
            page.appState = appState
        }
    }
}