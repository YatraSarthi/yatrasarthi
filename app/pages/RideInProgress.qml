import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10
import QtQuick 2.12

Page {

    property var appStack
    property var appState

    // ── State ────────────────────────────────────────────────────────────────
    property int  eta:           appState.selectedEta
    property real remainingKm:   4.3
    property real currentSpeed:  32

    property string driverName:    "Agnik Haldar"
    property string vehicleNumber: "WB03AD7394"
    property real   driverRating:  4.8

    property string destinationName:    appState.destinationLocation
    property string destinationAddress: appState.destinationFullAddress

    // hide the bottom nav bar while this page is active
    Component.onCompleted:  { if (appState) appState.showBottomBar = false }
    Component.onDestruction:{ if (appState) appState.showBottomBar = true  }

    // ── Auto countdown ───────────────────────────────────────────────────────
    Timer {
        interval: 5000
        running:  true
        repeat:   true
        onTriggered: {
            if (eta > 0)          eta--
            if (remainingKm > 0)  remainingKm  -= 0.5
            if (currentSpeed < 45) currentSpeed += 1
            if (eta <= 0) {
                stop()
                appStack.push(
                    Qt.resolvedUrl("RideCompletedPage.qml"),
                    { "appStack": appStack, "appState": appState }
                )
            }
        }
    }

    // ── Root background ──────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#F4F6F9"
    }

    // ── Content ──────────────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        clip:         true
        contentWidth: availableWidth

        Column {
            width:         parent.width
            spacing:       0
            bottomPadding: 24

            // ── MAP (full-bleed, takes top 42 % of screen) ──────────────────
            Item {
                width:  parent.width
                height: 280

                WebEngineView {
                    anchors.fill: parent
                    url: Qt.resolvedUrl("../web/RideInProgressMap.html")
                }

                // Floating header overlay on top of the map
                Rectangle {
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }
                    height: 52
                    color:  "#CC000000"   // semi-transparent black

                    Row {
                        anchors.fill:   parent
                        anchors.leftMargin:  8
                        anchors.rightMargin: 8
                        spacing: 8

                        // Back button
                        Rectangle {
                            width:  36
                            height: 36
                            radius: 18
                            color:  "#33FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter

                            Label {
                                anchors.centerIn: parent
                                text:  "←"
                                color: "white"
                                font.pixelSize: 18
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked:    appStack.pop()
                            }
                        }

                        Label {
                            text:           "Ride In Progress"
                            color:          "white"
                            font.pixelSize: 18
                            font.bold:      true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item { width: parent.width
                        height: 1
                        }

                        // Vehicle type pill
                        Rectangle {
                            height: 26
                            width:  vehiclePillLabel.implicitWidth + 16
                            radius: 13
                            color:  "#1976D2"
                            anchors.verticalCenter: parent.verticalCenter

                            Label {
                                id:             vehiclePillLabel
                                anchors.centerIn: parent
                                text:           appState.selectedVehicle
                                color:          "white"
                                font.pixelSize: 12
                                font.bold:      true
                            }
                        }
                    }
                }
            }

            // ── STATUS BANNER ────────────────────────────────────────────────
            Rectangle {
                width:  parent.width
                height: 88
                color:  "#1976D2"

                Row {
                    anchors.centerIn: parent
                    spacing:          0

                    // ETA block
                    Column {
                        width:   (parent.parent.width - 1) / 2
                        spacing: 2

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:           "Drop in " + eta + " min"
                            color:          "white"
                            font.pixelSize: 22
                            font.bold:      true
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:           remainingKm.toFixed(1) + " km left"
                            color:          "#B3E5FC"
                            font.pixelSize: 13
                        }
                    }

                    // Divider
                    Rectangle {
                        width:  1
                        height: 50
                        color:  "#4DFFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Speed block
                    Column {
                        width:   (parent.parent.width - 1) / 2
                        spacing: 2

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:           currentSpeed + " km/h"
                            color:          "white"
                            font.pixelSize: 22
                            font.bold:      true
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:           "Current Speed"
                            color:          "#B3E5FC"
                            font.pixelSize: 13
                        }
                    }
                }
            }

            // ── TRIP PROGRESS STEPPER ────────────────────────────────────────
            Rectangle {
                width:  parent.width
                height: 56
                color:  "white"

                Row {
                    anchors.centerIn: parent
                    spacing:          0

                    Repeater {
                        model: [
                            { label: "Pickup",      done: true  },
                            { label: "On Trip",     done: true  },
                            { label: "Arriving",    done: eta <= 3 },
                            { label: "Completed",   done: false }
                        ]

                        Row {
                            spacing: 0

                            // connector line (not before first item)
                            Rectangle {
                                visible: index > 0
                                width:   18
                                height:  2
                                color:   modelData.done ? "#1976D2" : "#D0D0D0"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: 4

                                Rectangle {
                                    width:  20
                                    height: 20
                                    radius: 10
                                    color:  modelData.done ? "#1976D2" : "#E0E0E0"
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Label {
                                        anchors.centerIn: parent
                                        text:           modelData.done ? "✓" : ""
                                        color:          "white"
                                        font.pixelSize: 11
                                        font.bold:      true
                                    }
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:           modelData.label
                                    font.pixelSize: 10
                                    color: modelData.done ? "#1976D2" : "#999999"
                                    font.bold: modelData.done
                                }
                            }
                        }
                    }
                }
            }

            // thin separator
            Rectangle { width: parent.width; height: 1; color: "#EBEBEB" }

            // ── CARDS AREA ───────────────────────────────────────────────────
            Column {
                width:         parent.width
                spacing:       10
                topPadding:    12
                leftPadding:   12
                rightPadding:  12

                // ── Destination card ─────────────────────────────────────────
                Rectangle {
                    width:        parent.width
                    height:       destinationCol.implicitHeight + 24
                    radius:       14
                    color:        "white"
                    border.color: "#E8E8E8"

                    Column {
                        id:              destinationCol
                        anchors {
                            top:   parent.top
                            left:  parent.left
                            right: parent.right
                            topMargin:   12
                            leftMargin:  14
                            rightMargin: 14
                        }
                        spacing: 4

                        Row {
                            spacing: 6
                            Label {
                                text:           "📍"
                                font.pixelSize: 14
                            }
                            Label {
                                text:           "Destination"
                                color:          "#888888"
                                font.pixelSize: 12
                            }
                        }

                        Label {
                            text:           destinationName
                            font.pixelSize: 17
                            font.bold:      true
                            color:          "#1A1A1A"
                            wrapMode:       Text.WordWrap
                            width:          parent.width
                        }

                        Label {
                            text:           destinationAddress
                            font.pixelSize: 13
                            color:          "#666666"
                            wrapMode:       Text.WordWrap
                            width:          parent.width
                        }
                    }
                }

                // ── Fare card ────────────────────────────────────────────────

Rectangle {

    width: parent.width
    height: 56

    radius: 14

    color: "white"

    border.color: "#E8E8E8"

    Row {

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 16
            rightMargin: 16
        }

        Label {
            text: "Fare"
            font.pixelSize: 15
            color: "#555555"
        }

        Item {
            width: 120
            height: 1
        }

        Label {
            text: "₹" + appState.selectedFare
            font.pixelSize: 26
            font.bold: true
            color: "#1976D2"
        }
    }
}
                // ── Driver card ──────────────────────────────────────────────
                Rectangle {
                    width:        parent.width
                    height:       110
                    radius:       14
                    color:        "white"
                    border.color: "#E8E8E8"

                    Row {
                        anchors {
                            fill:    parent
                            margins: 14
                        }
                        spacing: 14

                        // Avatar
                        Rectangle {
                            width:  72
                            height: 72
                            radius: 36
                            clip:   true
                            anchors.verticalCenter: parent.verticalCenter
                            color:  "#E0E0E0"

                            Image {
                                anchors.fill: parent
                                source:       "../../assets/images/agnik.jpeg"
                                fillMode:     Image.PreserveAspectCrop
                            }
                        }

                        Column {
                            spacing:                5
                            anchors.verticalCenter: parent.verticalCenter

                            Label {
                                text:           driverName
                                font.pixelSize: 17
                                font.bold:      true
                                color:          "#1A1A1A"
                            }

                            Label {
                                text:           vehicleNumber
                                font.pixelSize: 13
                                color:          "#555555"
                            }

                            Row {
                                spacing: 6

                                Label {
                                    text:           "★ " + driverRating.toFixed(1)
                                    font.pixelSize: 13
                                    color:          "#F4A700"
                                    font.bold:      true
                                }

                                Rectangle {
                                    width:  1
                                    height: 14
                                    color:  "#CCCCCC"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Label {
                                    text:           appState.selectedVehicle
                                    font.pixelSize: 13
                                    color:          "#777777"
                                }
                            }
                        }

                        // Call + Message pushed to the right
                        Item {
                            width:  parent.width
                                    - 72       // avatar
                                    - 14       // spacing after avatar
                                    - 130      // driver info approx
                            height: 1
                        }
                    }
                }

                // ── Call / Message ───────────────────────────────────────────
                Row {
                    width:   parent.width
                    spacing: 10

                    Rectangle {
                        width:  (parent.width - 10) / 2
                        height: 46
                        radius: 12
                        color:  "#EEF4FF"
                        border.color: "#C5D9F8"

                        Label {
                            anchors.centerIn: parent
                            text:           "📞  Call"
                            font.pixelSize: 15
                            color:          "#1976D2"
                            font.bold:      true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked:    console.log("Call driver")
                        }
                    }

                    Rectangle {
                        width:  (parent.width - 10) / 2
                        height: 46
                        radius: 12
                        color:  "#EEF4FF"
                        border.color: "#C5D9F8"

                        Label {
                            anchors.centerIn: parent
                            text:           "💬  Message"
                            font.pixelSize: 15
                            color:          "#1976D2"
                            font.bold:      true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked:    console.log("Message driver")
                        }
                    }
                }

                // ── SOS ──────────────────────────────────────────────────────
                Rectangle {
                    width:  parent.width
                    height: 52
                    radius: 14
                    color:  "#E53935"

                    Label {
                        anchors.centerIn: parent
                        text:           "🚨  SOS — Emergency"
                        color:          "white"
                        font.pixelSize: 16
                        font.bold:      true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked:    console.log("SOS triggered")
                    }
                }

                Item { height: 8 }
            }
        }
    }
}