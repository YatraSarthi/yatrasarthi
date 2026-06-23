import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    footer: null

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
            console.log("Auto-triggering SOS from Quick Actions")
            triggerSos()
            appState.quickAction = ""
        } else if (appState.quickAction === "queue") {
            console.log("Landed on Services via Queue quick action")
            appState.quickAction = ""
        }
    }

    function triggerSos() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "http://127.0.0.1:8000/sos", true)
        xhr.send()
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {
            width: parent.width
            spacing: 0

            // ── Header ────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 65
                color: "#1976D2"

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    text: "Services"
                    font.pixelSize: 22
                    font.bold: true
                    color: "white"
                }
            }

            Column {
                width: parent.width
                spacing: 16

                Item { width: 1; height: 12 }

                Label {
                    x: 16
                    text: "Book a Ride"
                    font.bold: true
                    font.pixelSize: 15
                    color: "#111"
                }

                // ── 2-column service grid ─────────────────────────
                Grid {
                    x: 16
                    width: parent.width - 32
                    columns: 2
                    spacing: 12

                    Repeater {
                        model: [
                            { label: "Bike Taxi",
                              icon: "bike.png",
                              bg: "#E8F5E9",
                              bd: "#C8E6C9",
                              fg: "#2E7D32",
                              available: true,
                              desc: "Fast & affordable" },
                            { label: "Auto",
                              icon: "auto.png",
                              bg: "#FFF8E1",
                              bd: "#FFE082",
                              fg: "#F57F17",
                              available: true,
                              desc: "3-wheeler comfort" },
                            { label: "Cab",
                              icon: "cab.png",
                              bg: "#E3F2FD",
                              bd: "#90CAF9",
                              fg: "#1565C0",
                              available: true,
                              desc: "AC · 4 seats" },
                            { label: "Carpool",
                              icon: "rider.png",
                              bg: "#F3E5F5",
                              bd: "#CE93D8",
                              fg: "#6A1B9A",
                              available: true,
                              desc: "Share & save" },
                            { label: "SOS",
                              icon: "sos.png",
                              bg: "#FFEBEE",
                              bd: "#FFCDD2",
                              fg: "#C62828",
                              available: true,
                              desc: "Emergency alert" }
                        ]

                        delegate: Rectangle {
                            id: serviceCard
                            width: (parent.width - 12) / 2
                            height: 95
                            radius: 14
                            color: modelData.bg
                            border.color: modelData.bd
                            border.width: (modelData.label === "SOS"
                                           && appState
                                           && appState.quickAction === "sos")
                                          ? 2 : 1
                            opacity: modelData.available ? 1.0 : 0.55

                            Column {
                                anchors.centerIn: parent
                                spacing: 6

                                Image {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    source: Qt.resolvedUrl(
                                            "../../assets/icons/"
                                            + modelData.icon)
                                    width: 32; height: 32
                                    fillMode: Image.PreserveAspectFit
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: modelData.fg
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.desc
                                    font.pixelSize: 10
                                    color: modelData.available
                                           ? modelData.fg
                                           : "#BDBDBD"
                                }
                            }

                            // Ripple overlay on hover
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: svcMouse.containsMouse
                                       ? "#15000000"
                                       : "transparent"
                            }

                            MouseArea {
                                id: svcMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: modelData.available

                                onClicked: {
                                    if (modelData.label === "SOS") {
                                        console.log("SOS card tapped directly")
                                        triggerSos()
                                    } else {
                                        appState.preferredVehicle = modelData.label
                                    }
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