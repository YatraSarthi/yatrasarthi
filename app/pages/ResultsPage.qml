import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property var rideData: null

    property string selectedVehicle: ""
    property int selectedFare: 0
    property int selectedEta: 0

    // ── Header ────────────────────────────────────────────────────
    header: Rectangle {

        width: parent.width
        height: 60
        color: "#1976D2"

        Row {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16
            spacing: 8

            // Back button
            ToolButton {
                anchors.verticalCenter: parent.verticalCenter
                width: 44; height: 44

                contentItem: Text {
                    text: "‹"
                    font.pixelSize: 28
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    appStack.pop()
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                width: parent.width - 52

                Label {
                    text: "Choose a Ride"
                    font.pixelSize: 17
                    font.bold: true
                    color: "white"
                }

                Label {
                    text: {
                        var from = appState.pickupLocation
                        var to   = appState.destinationLocation
                        var fp   = from.split(",")[0].trim()
                        var tp   = to.split(",")[0].trim()
                        return fp + "  →  " + tp
                    }
                    font.pixelSize: 11
                    color: "#B3E5FC"
                    width: parent.width
                    elide: Text.ElideRight
                }
            }
        }
    }

    // ── Helper functions ──────────────────────────────────────────
    function getVehicleIcon(vehicle) {
        if (vehicle === "Bike")    return "../../assets/icons/bike.png"
        if (vehicle === "Auto")    return "../../assets/icons/auto.png"
        if (vehicle === "Cab")     return "../../assets/icons/cab.png"
        if (vehicle === "Carpool") return "../../assets/icons/rider.png"
        return "../../assets/icons/rider.png"
    }

    function getVehicleColor(vehicle) {
        if (vehicle === "Bike")    return "#E8F5E9"
        if (vehicle === "Auto")    return "#FFF8E1"
        if (vehicle === "Cab")     return "#E3F2FD"
        if (vehicle === "Carpool") return "#F3E5F5"
        return "#F5F5F5"
    }

    function getVehicleAccent(vehicle) {
        if (vehicle === "Bike")    return "#2E7D32"
        if (vehicle === "Auto")    return "#F57F17"
        if (vehicle === "Cab")     return "#1565C0"
        if (vehicle === "Carpool") return "#6A1B9A"
        return "#1976D2"
    }

    function fetchEstimate() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("Estimate Status:", xhr.status)
                if (xhr.status === 200) {
                    rideData = JSON.parse(xhr.responseText)
                    // Default selection: Bike
                    selectedVehicle = "Bike"
                    selectedFare    = rideData.bike.fare
                    selectedEta     = rideData.bike.eta
                    console.log("rideData loaded")
                }
            }
        }
        var url =
            "http://127.0.0.1:8000/estimate"
            + "?pickup_lat="      + appState.pickupLat
            + "&pickup_lon="      + appState.pickupLon
            + "&destination_lat=" + appState.destinationLat
            + "&destination_lon=" + appState.destinationLon
        xhr.open("GET", url, true)
        xhr.send()
    }

    Component.onCompleted: {
        fetchEstimate()
    }

    // ── Body ──────────────────────────────────────────────────────
    Column {

        anchors.fill: parent
        spacing: 0

        // ── Route Map ─────────────────────────────────────────────
        Rectangle {

            width: parent.width
            height: 200
            color: "#E8EAF6"

            WebEngineView {
                id: routeMap
                anchors.fill: parent
                url: Qt.resolvedUrl("../web/route.html")

                onLoadingChanged: {
                    if (loadRequest.status ===
                            WebEngineLoadRequest.LoadSucceededStatus) {
                        console.log("Route map loaded")
                        runJavaScript(
                            "setRoute("
                            + appState.pickupLat   + ","
                            + appState.pickupLon   + ","
                            + appState.destinationLat + ","
                            + appState.destinationLon
                            + ")"
                        )
                    }
                }
            }

            // Distance badge over the map
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                height: 26
                width: distBadge.width + 20
                radius: 13
                color: "#CC1976D2"

                Label {
                    id: distBadge
                    anchors.centerIn: parent
                    text: rideData
                          ? (rideData.distance >= 1
                             ? rideData.distance.toFixed(1) + " km"
                             : Math.round(rideData.distance * 1000) + " m")
                          : ""
                    font.pixelSize: 12
                    font.bold: true
                    color: "white"
                }
            }
        }

        // ── Vehicle list ──────────────────────────────────────────
        ListView {

            id: vehicleList

            width: parent.width
            // Fill remaining height minus the Choose button bar
            height: parent.height - 200 - 80

            topMargin: 12
            bottomMargin: 8
            spacing: 10
            clip: true

            model: rideData ? [
                {
                    vehicle: "Bike",
                    fare: rideData.bike.fare,
                    eta:  rideData.bike.eta,
                    desc: "Fastest option",
                    availableSeats: 0,
                    routeMatch: 0,
                    co2Saved: 0.0
                },
                {
                    vehicle: "Auto",
                    fare: rideData.auto.fare,
                    eta:  rideData.auto.eta,
                    desc: "Comfortable 3-wheeler",
                    availableSeats: 0,
                    routeMatch: 0,
                    co2Saved: 0.0
                },
                {
                    vehicle: "Cab",
                    fare: rideData.cab.fare,
                    eta:  rideData.cab.eta,
                    desc: "AC sedan",
                    availableSeats: 0,
                    routeMatch: 0,
                    co2Saved: 0.0
                },
                {
                    vehicle: "Carpool",
                    // FIX: use backend carpool fare directly
                    fare: rideData.carpool.fare,
                    eta:  rideData.carpool.eta,
                    desc: "Share & save",
                    availableSeats: rideData.carpool.availableSeats,
                    routeMatch:     rideData.carpool.routeMatch,
                    co2Saved:       rideData.carpool.co2Saved
                }
            ] : []

            delegate: Rectangle {

                width: vehicleList.width - 24
                x: 12
                height: modelData.vehicle === "Carpool" ? 102 : 86
                radius: 14

                // Selected = tinted background in vehicle colour
                color: selectedVehicle === modelData.vehicle
                       ? getVehicleColor(modelData.vehicle)
                       : "white"

                border.color: selectedVehicle === modelData.vehicle
                              ? getVehicleAccent(modelData.vehicle)
                              : "#EEEEEE"
                border.width: selectedVehicle === modelData.vehicle
                              ? 2 : 1

                Behavior on scale {
                    NumberAnimation { duration: 120 }
                }

                // Left accent strip when selected
                Rectangle {
                    visible: selectedVehicle === modelData.vehicle
                    width: 4
                    height: parent.height - 20
                    radius: 2
                    color: getVehicleAccent(modelData.vehicle)
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 0
                    spacing: 14

                    // Vehicle icon in a tinted circle
                    Rectangle {
                        width: 48; height: 48
                        radius: 24
                        color: getVehicleColor(modelData.vehicle)
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            source: getVehicleIcon(modelData.vehicle)
                            width: 28; height: 28
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                        }
                    }

                    // Name + ETA + extras
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        width: parent.width - 48 - 14 - 70 - 14

                        Text {
                            text: modelData.vehicle
                            font.pixelSize: 16
                            font.bold: true
                            color: "#111"
                        }

                        Text {
                            text: modelData.desc
                                  + "  ·  "
                                  + modelData.eta + " min"
                            font.pixelSize: 12
                            color: "#888"
                        }

                        // Carpool extras row
                        Row {
                            visible: modelData.vehicle === "Carpool"
                            spacing: 8

                            Rectangle {
                                height: 20
                                width: seatsLabel.width + 12
                                radius: 10
                                color: "#E8F5E9"

                                Label {
                                    id: seatsLabel
                                    anchors.centerIn: parent
                                    text: modelData.availableSeats
                                          + " seats"
                                    font.pixelSize: 10
                                    color: "#2E7D32"
                                }
                            }

                            Rectangle {
                                height: 20
                                width: matchLabel.width + 12
                                radius: 10
                                color: "#E3F2FD"

                                Label {
                                    id: matchLabel
                                    anchors.centerIn: parent
                                    text: modelData.routeMatch
                                          + "% match"
                                    font.pixelSize: 10
                                    color: "#1565C0"
                                }
                            }

                            Rectangle {
                                height: 20
                                width: co2Label.width + 12
                                radius: 10
                                color: "#F1F8E9"

                                Label {
                                    id: co2Label
                                    anchors.centerIn: parent
                                    text: "🌱 "
                                          + modelData.co2Saved
                                          + " kg"
                                    font.pixelSize: 10
                                    color: "#558B2F"
                                }
                            }
                        }
                    }

                    // Fare — right aligned
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: 70

                        Text {
                            anchors.right: parent.right
                            text: "₹" + modelData.fare
                            font.pixelSize: 20
                            font.bold: true
                            color: getVehicleAccent(modelData.vehicle)
                        }

                        // Carpool shows savings vs Cab
                        Text {
                            anchors.right: parent.right
                            visible: modelData.vehicle === "Carpool"
                                     && rideData !== null
                            text: rideData
                                  ? "save ₹"
                                    + (rideData.cab.fare - modelData.fare)
                                  : ""
                            font.pixelSize: 10
                            color: "#2E7D32"
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: { parent.scale = 1.02 }
                    onExited  : { parent.scale = 1.0  }

                    onClicked: {
                        selectedVehicle = modelData.vehicle
                        selectedFare    = modelData.fare
                        selectedEta     = modelData.eta

                        if (modelData.vehicle === "Carpool") {
                            appState.availableSeats = modelData.availableSeats
                            appState.routeMatch     = modelData.routeMatch
                            appState.co2Saved       = modelData.co2Saved
                        } else {
                            appState.availableSeats = 0
                            appState.routeMatch     = 0
                            appState.co2Saved       = 0
                        }

                        console.log(selectedVehicle + " selected")
                    }
                }
            }
        }

        // ── Choose button bar ─────────────────────────────────────
        Rectangle {
            width: parent.width
            height: 80
            color: "white"

            // Top separator
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: "#EEEEEE"
            }

            Row {
                anchors.centerIn: parent
                spacing: 12

                // Fare summary chip
                Rectangle {
                    height: 48
                    width: fareChip.width + 24
                    radius: 12
                    color: "#F5F5F5"
                    border.color: "#E0E0E0"
                    visible: selectedVehicle !== ""

                    Label {
                        id: fareChip
                        anchors.centerIn: parent
                        text: "₹" + selectedFare
                              + "  ·  " + selectedEta + " min"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                }

                // Choose button
                Button {
                    width: 160
                    height: 48
                    enabled: selectedVehicle !== ""

                    background: Rectangle {
                        color: selectedVehicle !== ""
                               ? "#1976D2"
                               : "#BDBDBD"
                        radius: 12
                    }

                    contentItem: Text {
                        text: selectedVehicle !== ""
                              ? "Book " + selectedVehicle
                              : "Select a ride"
                        font.pixelSize: 15
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        // Save state
                        appState.selectedVehicle = selectedVehicle
                        appState.selectedFare    = selectedFare
                        appState.selectedEta     = selectedEta

                        // ── Save to ride history ──────────────────
                        var xhr = new XMLHttpRequest()
                        xhr.open(
                            "POST",
                            "http://127.0.0.1:8000/ride-history"
                            + "?pickup="
                            + encodeURIComponent(
                                appState.pickupLocation)
                            + "&destination="
                            + encodeURIComponent(
                                appState.destinationLocation)
                            + "&vehicle="
                            + encodeURIComponent(selectedVehicle)
                            + "&fare=" + selectedFare
                            + "&distance="
                            + (rideData ? rideData.distance : 0)
                            + "&co2_saved="
                            + appState.co2Saved,
                            true
                        )
                        xhr.send()

                        // ── Navigate to BookingPage ───────────────
                        appStack.push(
                            Qt.resolvedUrl("BookingPage.qml"),
                            {
                                "appStack": appStack,
                                "appState": appState
                            }
                        )
                    }
                }
            }
        }
    }

    // ── Floating SOS button ───────────────────────────────────────
    Rectangle {
        width: 60; height: 60
        radius: 30
        color: "#E53935"
        z: 100

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 16
        anchors.bottomMargin: 96   // sits above the Choose bar

        // Shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius + 2
            color: "transparent"
            border.color: "#44E53935"
            z: -1
        }

        Column {
            anchors.centerIn: parent
            spacing: 2

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../assets/icons/sos.png"
                width: 22; height: 22
                fillMode: Image.PreserveAspectFit
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "SOS"
                color: "white"
                font.bold: true
                font.pixelSize: 10
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                appStack.push(
                    Qt.resolvedUrl("SOSPage.qml"),
                    { "appStack": appStack }
                )
            }
        }
    }
}