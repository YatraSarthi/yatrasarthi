import QtQuick 2.12
import QtQuick.Controls 2.12
import "pages"

ApplicationWindow {

    visible: true
    width: 400
    height: 700
    title: "YatraSarthi"

    AppState {
        id: appState
    }

    property int currentTab: 0

    // Expose a function child pages can call to switch tabs
    function switchTab(index) {
        currentTab = index
        bottomNav.currentIndex = index
    }

    footer: TabBar {

        id: bottomNav
        currentIndex: currentTab

        background: Rectangle {
            color: "white"
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: "#E0E0E0"
            }
        }

        onCurrentIndexChanged: {
            currentTab = currentIndex
        }

        TabButton {
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("../assets/icons/pickup.png")
                    width: 22; height: 22
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Home"
                    font.pixelSize: 10
                    color: currentTab === 0 ? "#1976D2" : "#888"
                }
            }
        }

        TabButton {
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("../assets/icons/auto.png")
                    width: 22; height: 22
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Services"
                    font.pixelSize: 10
                    color: currentTab === 1 ? "#1976D2" : "#888"
                }
            }
        }

        TabButton {
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("../assets/icons/rider.png")
                    width: 22; height: 22
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Activity"
                    font.pixelSize: 10
                    color: currentTab === 2 ? "#1976D2" : "#888"
                }
            }
        }

        TabButton {
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("../assets/icons/driver.png")
                    width: 22; height: 22
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Account"
                    font.pixelSize: 10
                    color: currentTab === 3 ? "#1976D2" : "#888"
                }
            }
        }
    }

    StackView {
        id: homeStack
        anchors.fill: parent
        visible: currentTab === 0
        initialItem: HomePage {
            appStack: homeStack
            appState: appState
            // Pass the window's switchTab function down
            onSwitchTab: switchTab(tabIndex)
        }
    }

    StackView {
        id: servicesStack
        anchors.fill: parent
        visible: currentTab === 1
        initialItem: ServicesPage {
            appStack: servicesStack
            appState: appState
        }
    }

    StackView {
        id: activityStack
        anchors.fill: parent
        visible: currentTab === 2
        initialItem: ActivityPage {
            appStack: activityStack
            appState: appState
        }
    }

    StackView {
        id: accountStack
        anchors.fill: parent
        visible: currentTab === 3
        initialItem: AccountPage {
            appStack: accountStack
            appState: appState
        }
    }
}