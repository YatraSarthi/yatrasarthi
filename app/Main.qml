import QtQuick 2.12
import QtQuick.Controls 2.12
import "pages"

ApplicationWindow {

    visible: true
    width:   400
    height:  700
    title:   "YatraSarthi"

    AppState { id: appState }

    property int currentTab: 0

    function switchTab(index) {
        currentTab = index
    }

    footer: Rectangle {
        visible: appState.showBottomBar
        height:  visible ? 72 : 0
        color:   "#E3F2FD"

        // Top border line
        Rectangle {
            anchors.top: parent.top
            width: parent.width; height: 1; color: "#90CAF9"
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
                    color:  currentTab === modelData.idx ? "#1976D2" : "white"
                    border.color: currentTab === modelData.idx ? "#1565C0" : "#BBDEFB"
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
                            text:           modelData.label
                            font.pixelSize: 10
                            font.bold:      currentTab === modelData.idx
                            color:          currentTab === modelData.idx
                                            ? "white" : "#555"
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

    // ── Stacks ───────────────────────────────────────────────────────────────

    StackView {
        id:           homeStack
        anchors.fill: parent
        visible:      currentTab === 0

        Component.onCompleted: {
            var page = push(Qt.resolvedUrl("pages/HomePage.qml"))
            page.appStack = homeStack
            page.appState = appState
            page.switchTab.connect(switchTab)
        }
    }

    StackView {
        id:           servicesStack
        anchors.fill: parent
        visible:      currentTab === 1

        Component.onCompleted: {
            var page = push(Qt.resolvedUrl("pages/ServicesPage.qml"))
            page.appStack = servicesStack
            page.appState = appState
            page.switchTab.connect(switchTab)
        }
    }

    StackView {
        id:           activityStack
        anchors.fill: parent
        visible:      currentTab === 2

        Component.onCompleted: {
            var page = push(Qt.resolvedUrl("pages/ActivityPage.qml"))
            page.appStack = activityStack
            page.appState = appState
            page.switchTab.connect(switchTab)
        }
    }

    StackView {
        id:           accountStack
        anchors.fill: parent
        visible:      currentTab === 3

        Component.onCompleted: {
            var page = push(Qt.resolvedUrl("pages/AccountPage.qml"))
            page.appStack = accountStack
            page.appState = appState
            page.switchTab.connect(switchTab)
        }
    }
}
