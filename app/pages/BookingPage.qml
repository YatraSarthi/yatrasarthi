import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property bool driverFound:  false
    property bool cancelled:    false   // guard: don't push if user cancelled

    // ── Auto-navigate to PickupPage when driver is found ──────────
    Timer {
        id:       driverTimer
        interval: 3000
        running:  true
        repeat:   false

        onTriggered: {
            if (cancelled) return   // user already cancelled — do nothing

            driverFound = true

            var xhr = new XMLHttpRequest()
            xhr.open("GET", "http://127.0.0.1:8000/reset-driver", false)
            xhr.send()
            console.log("Driver simulation reset")

            appStack.push(
                Qt.resolvedUrl("PickupPage.qml"),
                { "appStack": appStack, "appState": appState }
            )
        }
    }

    // ── Background ────────────────────────────────────────────────
    Rectangle { anchors.fill: parent; color: "#F4F6F9" }

    Column {
        anchors.fill: parent
        spacing:      0

        // ── Header ────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 58; color: "#1976D2"

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 10

                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: "#33FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        anchors.centerIn: parent
                        text: "←"; color: "white"; font.pixelSize: 18
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            cancelled = true
                            driverTimer.stop()
                            appStack.pop()
                        }
                    }
                }

                Label {
                    text: driverFound ? "Driver Found!" : "Finding Driver…"
                    font.pixelSize: 20; font.bold: true; color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ── Route Map ─────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 260
            border.color: "#D3D3D3"

            WebEngineView {
                id: bookingMap
                anchors.fill: parent
                url: Qt.resolvedUrl("../web/route.html")

                onLoadingChanged: {
                    if (loadRequest.status ===
                            WebEngineLoadRequest.LoadSucceededStatus) {
                        runJavaScript(
                            "setRoute("
                            + appState.pickupLat      + ","
                            + appState.pickupLon      + ","
                            + appState.destinationLat + ","
                            + appState.destinationLon + ")"
                        )
                    }
                }
            }
        }

        // ── Searching animation ───────────────────────────────────
        Item {
            width:   parent.width
            height:  parent.height - 58 - 260
            visible: !driverFound

            Column {
                anchors.centerIn: parent
                spacing: 20

                // Pulsing ring
                Rectangle {
                    width: 120; height: 120; radius: 60
                    color: "transparent"
                    border.color: "#1976D2"; border.width: 3
                    anchors.horizontalCenter: parent.horizontalCenter

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite; running: true
                        NumberAnimation { to: 0.2; duration: 800 }
                        NumberAnimation { to: 1.0; duration: 800 }
                    }

                    Rectangle {
                        width: 90; height: 90; radius: 45
                        color: "#1976D2"; anchors.centerIn: parent
                        Image {
                            source: "../../assets/icons/rider.png"
                            width: 44; height: 44
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                        }
                    }
                }

                Label {
                    text: "Looking for nearby drivers…"
                    font.pixelSize: 16; color: "#444444"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Bouncing dots
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 10; height: 10; radius: 5; color: "#1976D2"
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite; running: true
                                PauseAnimation  { duration: index * 300 }
                                NumberAnimation { to: 1.0; duration: 300 }
                                NumberAnimation { to: 0.2; duration: 300 }
                                PauseAnimation  { duration: (2 - index) * 300 }
                            }
                        }
                    }
                }

                Label {
                    text: "This usually takes a few seconds"
                    font.pixelSize: 13; color: "#AAAAAA"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Cancel button — stops timer and goes back to ResultsPage
                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 200; height: 46

                    background: Rectangle {
                        radius: 12; color: "transparent"
                        border.color: "#E53935"; border.width: 2
                    }
                    contentItem: Text {
                        text: "Cancel Search"; color: "#E53935"
                        font.pixelSize: 15; font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                    }
                    onClicked: {
                        cancelled = true
                        driverTimer.stop()   // prevent auto-push to PickupPage
                        appStack.pop()       // go back to ResultsPage
                    }
                }
            }
        }
    }
}
