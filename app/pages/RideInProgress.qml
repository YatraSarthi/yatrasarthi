import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    // ── State ────────────────────────────────────────────────────────────────
    property int  eta:          appState.selectedEta
    property real remainingKm:  0
    property real currentSpeed: 0

    property string driverName:    "Agnik Haldar"
    property string vehicleNumber: "WB03AD7394"
    property real   driverRating:  4.8

    property string destinationName:    appState.destinationLocation
    property string destinationAddress: appState.destinationFullAddress

    property bool rideSessionReady:  false
    property bool completePushed:    false

    // Hide bottom bar
    Component.onCompleted:  { if (appState) appState.showBottomBar = false }
    Component.onDestruction:{ if (appState) appState.showBottomBar = true  }

    // ── Start ride session ────────────────────────────────────────────────────
    function startRide() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status !== 200) {
                    console.warn("startRide failed:", xhr.status)
                    return
                }
                var data = JSON.parse(xhr.responseText)
                remainingKm  = data.distance    || 0
                eta          = data.eta         || appState.selectedEta
                currentSpeed = data.speed       || 30

                // init the map with pickup, destination, vehicle position
                rideMap.runJavaScript(
                    "initializeRide("
                    + appState.pickupLat      + "," + appState.pickupLon      + ","
                    + appState.destinationLat + "," + appState.destinationLon + ","
                    + data.vehicleLat         + "," + data.vehicleLon
                    + ")"
                )
                rideSessionReady = true
            }
        }
        xhr.open("GET",
            "http://127.0.0.1:8000/start-ride"
            + "?pickup_lat="      + appState.pickupLat
            + "&pickup_lon="      + appState.pickupLon
            + "&destination_lat=" + appState.destinationLat
            + "&destination_lon=" + appState.destinationLon,
            true)
        xhr.send()
    }

    // ── Poll ride location ────────────────────────────────────────────────────
    function fetchRideLocation() {
        if (!rideSessionReady) return
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status !== 200) return
                var data = JSON.parse(xhr.responseText)
                remainingKm  = data.distance || remainingKm
                eta          = data.eta      || eta
                currentSpeed = data.speed    || currentSpeed

                rideMap.runJavaScript(
                    "moveVehicle(" + data.vehicleLat + "," + data.vehicleLon + ")"
                )

                if (data.completed && !completePushed) {
                    completePushed = true
                    rideCompleteTimer.start()
                }
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/ride-location", true)
        xhr.send()
    }

    // ── Timers ────────────────────────────────────────────────────────────────
    Timer {
        interval: 5000
        running:  true
        repeat:   true
        onTriggered: fetchRideLocation()
    }

    Timer {
        id:       rideCompleteTimer
        interval: 2000
        repeat:   false
        onTriggered: {
            appStack.push(
                Qt.resolvedUrl("RideCompletedPage.qml"),
                { "appStack": appStack, "appState": appState }
            )
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

            // ── MAP ──────────────────────────────────────────────────────────
            Item {
                width:  parent.width
                height: 280

                WebEngineView {
                    id:           rideMap
                    anchors.fill: parent
                    url:          Qt.resolvedUrl("../web/RideInProgressMap.html")

                    onLoadingChanged: {
                        if (loadRequest.status ===
                                WebEngineLoadRequest.LoadSucceededStatus) {
                            rideMap.runJavaScript(
                                "setVehicleType('" + appState.selectedVehicle + "')"
                            )
                            startRide()
                        }
                    }
                }

                // Floating header overlay on top of map
                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 52
                    color:  "#CC000000"

                    Row {
                        anchors.fill:        parent
                        anchors.leftMargin:  8
                        anchors.rightMargin: 8
                        spacing: 8

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

                        Item { width: parent.width - 200; height: 1 }

                        Rectangle {
                            height: 26
                            width:  vehiclePillLabel.implicitWidth + 16
                            radius: 13
                            color:  "#1976D2"
                            anchors.verticalCenter: parent.verticalCenter
                            Label {
                                id:               vehiclePillLabel
                                anchors.centerIn: parent
                                text:             appState.selectedVehicle
                                color:            "white"
                                font.pixelSize:   12
                                font.bold:        true
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

                    Rectangle {
                        width: 1; height: 50; color: "#4DFFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

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
                            { label: "Pickup",    done: true       },
                            { label: "On Trip",   done: true       },
                            { label: "Arriving",  done: eta <= 3   },
                            { label: "Completed", done: false      }
                        ]

                        Row {
                            spacing: 0
                            Rectangle {
                                visible: index > 0
                                width:   18; height: 2
                                color:   modelData.done ? "#1976D2" : "#D0D0D0"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Column {
                                spacing: 4
                                Rectangle {
                                    width: 20; height: 20; radius: 10
                                    color: modelData.done ? "#1976D2" : "#E0E0E0"
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
                                    text:      modelData.label
                                    font.pixelSize: 10
                                    color:     modelData.done ? "#1976D2" : "#999999"
                                    font.bold: modelData.done
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#EBEBEB" }

            // ── CARDS AREA ───────────────────────────────────────────────────
            Column {
                width:        parent.width
                spacing:      10
                topPadding:   12
                leftPadding:  12
                rightPadding: 12

                // ── Destination card ─────────────────────────────────────────
                Rectangle {
                    width:        parent.width
                    height:       destinationCol.implicitHeight + 24
                    radius:       14
                    color:        "white"
                    border.color: "#E8E8E8"

                    Column {
                        id: destinationCol
                        anchors {
                            top: parent.top; left: parent.left; right: parent.right
                            topMargin: 12; leftMargin: 14; rightMargin: 14
                        }
                        spacing: 4

                        Row {
                            spacing: 6
                            Label { text: "📍"; font.pixelSize: 14 }
                            Label { text: "Destination"; color: "#888888"; font.pixelSize: 12 }
                        }
                        Label {
                            text:           destinationName
                            font.pixelSize: 17; font.bold: true; color: "#1A1A1A"
                            wrapMode:       Text.WordWrap; width: parent.width
                        }
                        Label {
                            text:           destinationAddress
                            font.pixelSize: 13; color: "#666666"
                            wrapMode:       Text.WordWrap; width: parent.width
                        }
                    }
                }

                // ── Fare card ─────────────────────────────────────────────────
                Rectangle {
                    width: parent.width; height: 56
                    radius: 14; color: "white"; border.color: "#E8E8E8"

                    Row {
                        anchors {
                            left: parent.left; right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 16; rightMargin: 16
                        }
                        Label { text: "Fare"; font.pixelSize: 15; color: "#555555" }
                        Item  { width: parent.width - fareLabel.implicitWidth - 60; height: 1 }
                        Label {
                            id:             fareLabel
                            text:           "₹" + appState.selectedFare
                            font.pixelSize: 26; font.bold: true; color: "#1976D2"
                        }
                    }
                }

                // ── Driver card ───────────────────────────────────────────────
                Rectangle {
                    width: parent.width; height: 110
                    radius: 14; color: "white"; border.color: "#E8E8E8"

                    Row {
                        anchors { fill: parent; margins: 14 }
                        spacing: 14

                        // Driver photo
                        Rectangle {
                            width: 72; height: 72; radius: 36
                            clip: true; color: "#E0E0E0"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.fill: parent
                                source:       Qt.resolvedUrl("../../assets/image/agnik.jpeg")
                                fillMode:     Image.PreserveAspectCrop

                                // fallback icon if image missing
                                Rectangle {
                                    anchors.fill: parent
                                    color:        "#1976D2"
                                    visible:      parent.status !== Image.Ready
                                    Label {
                                        anchors.centerIn: parent
                                        text:           "👤"
                                        font.pixelSize: 28
                                    }
                                }
                            }
                        }

                        Column {
                            spacing: 5
                            anchors.verticalCenter: parent.verticalCenter

                            Label {
                                text:           driverName
                                font.pixelSize: 17; font.bold: true; color: "#1A1A1A"
                            }
                            Label {
                                text:           vehicleNumber
                                font.pixelSize: 13; color: "#555555"
                            }
                            Row {
                                spacing: 6
                                Label {
                                    text:           "★ " + driverRating.toFixed(1)
                                    font.pixelSize: 13; color: "#F4A700"; font.bold: true
                                }
                                Rectangle {
                                    width: 1; height: 14; color: "#CCCCCC"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Label {
                                    text:           appState.selectedVehicle
                                    font.pixelSize: 13; color: "#777777"
                                }
                            }
                        }
                    }
                }

                // ── Call / Message ────────────────────────────────────────────
                Row {
                    width: parent.width; spacing: 10

                    Rectangle {
                        width: (parent.width - 10) / 2; height: 46
                        radius: 12; color: "#EEF4FF"; border.color: "#C5D9F8"
                        Label {
                            anchors.centerIn: parent
                            text: "📞  Call"; font.pixelSize: 15
                            color: "#1976D2"; font.bold: true
                        }
                        MouseArea { anchors.fill: parent; onClicked: console.log("Call") }
                    }

                    Rectangle {
                        width: (parent.width - 10) / 2; height: 46
                        radius: 12; color: "#EEF4FF"; border.color: "#C5D9F8"
                        Label {
                            anchors.centerIn: parent
                            text: "💬  Message"; font.pixelSize: 15
                            color: "#1976D2"; font.bold: true
                        }
                        MouseArea { anchors.fill: parent; onClicked: console.log("Message") }
                    }
                }

                // ── SOS ───────────────────────────────────────────────────────
                Rectangle {
                    width: parent.width; height: 52; radius: 14; color: "#E53935"
                    Label {
                        anchors.centerIn: parent
                        text: "🚨  SOS — Emergency"
                        color: "white"; font.pixelSize: 16; font.bold: true
                    }
                    MouseArea { anchors.fill: parent; onClicked: console.log("SOS") }
                }

                Item { height: 8 }
            }
        }
    }
}
