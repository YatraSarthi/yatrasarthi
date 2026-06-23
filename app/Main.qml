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
        bottomNav.currentIndex = index
    }

    footer: TabBar {
        id:      bottomNav
        visible: appState.showBottomBar
        height:  visible ? implicitHeight : 0
        currentIndex: currentTab

        background: Rectangle {
            color: "#E3F2FD"
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: "#90CAF9"
            }
        }

        onCurrentIndexChanged: currentTab = currentIndex

        TabButton {
            background: Rectangle { color: "transparent" }
            contentItem: Column {
                anchors.centerIn: parent; spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("../assets/icons/pickup.png")
                    width: 22; height: 22; fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Home"; font.pixelSize: 10
                    color: currentTab === 0 ? "#1976D2" : "#888"
                }
            }
        }

        TabButton {
            background: Rectangle { color: "transparent" }
            contentItem: Column {
                anchors.centerIn: parent; spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("../assets/icons/auto.png")
                    width: 22; height: 22; fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Services"; font.pixelSize: 10
                    color: currentTab === 1 ? "#1976D2" : "#888"
                }
            }
        }

        TabButton {
            background: Rectangle { color: "transparent" }
            contentItem: Column {
                anchors.centerIn: parent; spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("../assets/icons/rider.png")
                    width: 22; height: 22; fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Activity"; font.pixelSize: 10
                    color: currentTab === 2 ? "#1976D2" : "#888"
                }
            }
        }

        TabButton {
            background: Rectangle { color: "transparent" }
            contentItem: Column {
                anchors.centerIn: parent; spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("../assets/icons/driver.png")
                    width: 22; height: 22; fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Account"; font.pixelSize: 10
                    color: currentTab === 3 ? "#1976D2" : "#888"
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
        initialItem:  ServicesPage {
            appStack: servicesStack
            appState: appState
        }
    }

    StackView {
        id:           activityStack
        anchors.fill: parent
        visible:      currentTab === 2
        initialItem:  ActivityPage {
            appStack: activityStack
            appState: appState
        }
    }

    StackView {
        id:           accountStack
        anchors.fill: parent
        visible:      currentTab === 3
        initialItem:  AccountPage {
            appStack: accountStack
            appState: appState
        }
    }
}