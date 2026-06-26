import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    signal switchTab(int tabIndex)

    footer: null
    header: null

    readonly property bool dm: appState ? appState.darkMode : false
    readonly property color thBg:      dm ? "#121212" : "#FFFFFF"
    readonly property color thText:    dm ? "#EEEEEE" : "#111111"
    readonly property color thTextSub: dm ? "#888888" : "#AAAAAA"
    readonly property color thBackBtn: dm ? "#1565C0" : "white"
    readonly property color thBackArrow: dm ? "white" : "#1565C0"

    onVisibleChanged: {
        if (visible) {
            if (appState) appState.showBottomBar = true
            handleQuickAction()
        }
    }

    Component.onCompleted: handleQuickAction()

    function handleQuickAction() {
        if (!appState) return
        if (appState.quickAction === "sos") {
            triggerSos()
            appState.quickAction = ""
        } else if (appState.quickAction === "queue") {
            appState.quickAction = ""
        }
    }

    function triggerSos() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "http://127.0.0.1:8000/sos", true)
        xhr.send()
    }

    Rectangle { anchors.fill: parent; color: thBg }

    ScrollView {
        anchors.fill: parent; contentWidth: width; clip: true

        Column {
            width: parent.width; spacing: 0

            // ── Header ────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 65; color: "#1976D2"
                Rectangle {
                    id: backBtn; width: 36; height: 36; radius: 18
                    color: thBackBtn
                    anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { text: "‹"; font.pixelSize: 28; font.bold: true; color: thBackArrow; anchors.centerIn: parent; anchors.horizontalCenterOffset: -1 }
                    MouseArea { id: backBtnMouse; anchors.fill: parent; hoverEnabled: true; onClicked: switchTab(0) }
                }
                Label { anchors.verticalCenter: parent.verticalCenter; anchors.left: backBtn.right; anchors.leftMargin: 10; text: "Services"; font.pixelSize: 22; font.bold: true; color: "white" }
            }

            Column {
                width: parent.width; spacing: 16

                Item { width: 1; height: 12 }

                Label { x: 16; text: "Book a Ride"; font.bold: true; font.pixelSize: 15; color: thText }

                // ── 2-column service grid ─────────────────────────
                Grid {
                    x: 16; width: parent.width - 32; columns: 2; spacing: 12

                    Repeater {
                        model: [
                            { label: "Bike Taxi", icon: "bike.png",
                              bg:   dm ? "#1A2E1A" : "#E8F5E9", bd: dm ? "#2A4A2A" : "#C8E6C9", fg: "#2E7D32",
                              available: true, desc: "Fast & affordable" },
                            { label: "Auto",      icon: "auto.png",
                              bg:   dm ? "#2E2A1A" : "#FFF8E1", bd: dm ? "#4A4020" : "#FFE082", fg: "#F57F17",
                              available: true, desc: "3-wheeler comfort" },
                            { label: "Cab",       icon: "cab.png",
                              bg:   dm ? "#1A2A3A" : "#E3F2FD", bd: dm ? "#2A4A6A" : "#90CAF9", fg: "#1565C0",
                              available: true, desc: "AC · 4 seats" },
                            { label: "Carpool",   icon: "rider.png",
                              bg:   dm ? "#2A1A2E" : "#F3E5F5", bd: dm ? "#4A2A5A" : "#CE93D8", fg: "#6A1B9A",
                              available: true, desc: "Share & save" },
                            { label: "SOS",       icon: "sos.png",
                              bg:   dm ? "#2E1A1A" : "#FFEBEE", bd: dm ? "#4A2A2A" : "#FFCDD2", fg: "#C62828",
                              available: true, desc: "Emergency alert" }
                        ]

                        delegate: Rectangle {
                            width: (parent.width - 12) / 2; height: 95; radius: 14
                            color: modelData.bg; border.color: modelData.bd; border.width: 1
                            opacity: modelData.available ? 1.0 : 0.55

                            Column {
                                anchors.centerIn: parent; spacing: 6
                                Image { anchors.horizontalCenter: parent.horizontalCenter; source: Qt.resolvedUrl("../../assets/icons/" + modelData.icon); width: 32; height: 32; fillMode: Image.PreserveAspectFit }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; font.pixelSize: 13; font.bold: true; color: modelData.fg }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.desc; font.pixelSize: 10; color: modelData.available ? modelData.fg : (dm ? "#555555" : "#BDBDBD") }
                            }

                            Rectangle { anchors.fill: parent; radius: parent.radius; color: svcMouse.containsMouse ? "#15000000" : "transparent" }

                            MouseArea {
                                id: svcMouse; anchors.fill: parent; hoverEnabled: true; enabled: modelData.available
                                onClicked: {
                                    if (modelData.label === "SOS") { triggerSos() }
                                    else { appState.preferredVehicle = modelData.label }
                                }
                            }
                        }
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }
}
