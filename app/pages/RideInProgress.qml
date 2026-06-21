import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property int  eta:          appState.selectedEta
    property real remainingKm:  4.3
    property real currentSpeed: 32

    property string driverName:    "Agnik Haldar"
    property string vehicleNumber: "WB03AD7394"
    property real   driverRating:  4.8

    property string destinationName:    appState.destinationName
    property string destinationAddress: appState.destinationAddress

    // Route state
    property var routePoints: []
    property int routeIndex:  0
    property real currentLat: 0
    property real currentLon: 0

    property bool mapReady:   false   // true once HTML has loaded
    property bool routeReady: false   // true once /route response arrived


    /* ─────────────────────────────────────────────────────────────
       Helper: push markers + route onto the map.
       Safe to call multiple times; guards ensure both sides ready.
    ───────────────────────────────────────────────────────────── */
    function pushToMap() {

        if (!mapReady || !routeReady) return

        // 1. Draw the blue route polyline
        var pts = JSON.stringify(routePoints)
        mapView.runJavaScript("drawRoute(" + pts + ")")

        // 2. Place the three markers on top
        mapView.runJavaScript(
            "initializeRide("
            + appState.pickupLat      + ","
            + appState.pickupLon      + ","
            + appState.destinationLat + ","
            + appState.destinationLon + ","
            + currentLat              + ","
            + currentLon              + ")"
        )
    }


    /* ─────────────────────────────────────────────────────────────
       Load route from FastAPI GET /route
    ───────────────────────────────────────────────────────────── */
    function loadRideRoute() {

        var xhr = new XMLHttpRequest()

        var url =
            "http://localhost:8000/route"
            + "?pickup_lat="      + appState.pickupLat
            + "&pickup_lon="      + appState.pickupLon
            + "&destination_lat=" + appState.destinationLat
            + "&destination_lon=" + appState.destinationLon

        xhr.open("GET", url)

        xhr.onreadystatechange = function() {

            if (xhr.readyState !== XMLHttpRequest.DONE) return

            if (xhr.status === 200) {

                var resp    = JSON.parse(xhr.responseText)
                routePoints = resp.points   // [[lat,lon], ...]
                routeIndex  = 0

                if (routePoints.length > 0) {
                    currentLat = routePoints[0][0]
                    currentLon = routePoints[0][1]
                } else {
                    // Fallback: start at pickup
                    currentLat = appState.pickupLat
                    currentLon = appState.pickupLon
                }

            } else {
                // API unavailable — still show markers at pickup/destination
                console.warn("Route API failed, status:", xhr.status)
                routePoints = [
                    [appState.pickupLat,      appState.pickupLon],
                    [appState.destinationLat, appState.destinationLon]
                ]
                routeIndex = 0
                currentLat = appState.pickupLat
                currentLon = appState.pickupLon
            }

            routeReady = true
            pushToMap()
        }

        xhr.send()
    }


    /* ─────────────────────────────────────────────────────────────
       Auto countdown + vehicle movement every 5 s
    ───────────────────────────────────────────────────────────── */
    Timer {

        interval: 5000
        running:  true
        repeat:   true

        onTriggered: {

            if (eta > 0)           eta--
            if (remainingKm > 0)   remainingKm  -= 0.5
            if (currentSpeed < 45) currentSpeed += 1

            // Advance vehicle along route points
            if (routePoints.length > 0 && routeIndex < routePoints.length) {

                var pt     = routePoints[routeIndex]
                currentLat = pt[0]
                currentLon = pt[1]
                routeIndex++

                mapView.runJavaScript(
                    "moveVehicle(" + currentLat + "," + currentLon + ")"
                )
            }

            if (eta <= 0) {
                stop()
                appStack.push(
                    Qt.resolvedUrl("RideCompletedPage.qml"),
                    { "appStack": appStack, "appState": appState }
                )
            }
        }
    }


    /* ═══════════════════════════════════════════════════════════
       UI
    ═══════════════════════════════════════════════════════════ */

    ScrollView {

        id: rideScroll
        anchors.fill: parent

        Column {

            width:   rideScroll.width
            spacing: 12


            /* ── HEADER ────────────────────────────────────── */

            Rectangle {

                width:  parent.width
                height: 60
                color:  "white"

                Row {

                    anchors.fill:    parent
                    anchors.margins: 10
                    spacing:         10

                    Button {
                        text: "←"
                        onClicked: appStack.pop()
                    }

                    Label {
                        text:              "Ride In Progress"
                        font.pixelSize:    24
                        font.bold:         true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }


            /* ── MAP ───────────────────────────────────────── */

            Rectangle {

                width:  rideScroll.width - 20
                height: 280

                anchors.horizontalCenter: parent.horizontalCenter

                radius:       15
                border.color: "#D3D3D3"
                border.width: 1
                clip:         true

                WebEngineView {

                    id: mapView
                    anchors.fill: parent

                    url: Qt.resolvedUrl("../web/RideInProgressMap.html")

                    onLoadingChanged: {
                        if (loadRequest.status
                                === WebEngineView.LoadSucceededStatus) {
                            mapReady = true
                            loadRideRoute()   // start XHR now map is ready
                        }
                    }
                }
            }


            /* ── ARRIVING CARD ─────────────────────────────── */

            Rectangle {

                width:  rideScroll.width - 20
                height: 100

                anchors.horizontalCenter: parent.horizontalCenter

                radius: 15
                color:  "#1976D2"

                Column {

                    anchors.centerIn: parent
                    spacing:          6

                    Label {
                        text:              "Arriving at Destination"
                        color:             "white"
                        font.pixelSize:    18
                        font.bold:         true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {

                        spacing: 30
                        anchors.horizontalCenter: parent.horizontalCenter

                        Label {
                            text:           "ETA: " + eta + " min"
                            color:          "white"
                            font.pixelSize: 15
                        }

                        Label {
                            text:           "Distance Left: " + remainingKm.toFixed(1) + " km"
                            color:          "white"
                            font.pixelSize: 15
                        }
                    }
                }
            }


            /* ── DESTINATION CARD ──────────────────────────── */

            Rectangle {

                width:  rideScroll.width - 20
                height: 110

                anchors.horizontalCenter: parent.horizontalCenter

                radius:       15
                color:        "white"
                border.color: "#D3D3D3"

                Column {

                    anchors.fill:    parent
                    anchors.margins: 15
                    spacing:         5

                    Label { text: "Destination"; color: "#666666" }

                    Label {
                        text:           destinationName
                        font.pixelSize: 22
                        font.bold:      true
                    }

                    Label {
                        text:     destinationAddress
                        wrapMode: Text.WordWrap
                    }
                }
            }


            /* ── FARE CARD ─────────────────────────────────── */

            Rectangle {

                width:  rideScroll.width - 20
                height: 80

                anchors.horizontalCenter: parent.horizontalCenter

                radius:       15
                color:        "white"
                border.color: "#D3D3D3"

                Row {

                    anchors.fill:    parent
                    anchors.margins: 15

                    Label { text: "Fare"; font.pixelSize: 18 }

                    Item { width: 150 }

                    Label {
                        text:           "₹" + appState.selectedFare
                        font.pixelSize: 28
                        font.bold:      true
                    }
                }
            }


            /* ── DRIVER CARD ───────────────────────────────── */

            Rectangle {

                width:  rideScroll.width - 20
                height: 140

                anchors.horizontalCenter: parent.horizontalCenter

                radius:       15
                color:        "white"
                border.color: "#D3D3D3"

                Row {

                    anchors.fill:    parent
                    anchors.margins: 15
                    spacing:         15

                    Image {
                        source:   "../../assets/image/agnik.jpeg"
                        width:    80
                        height:   80
                        fillMode: Image.PreserveAspectCrop
                    }

                    Column {

                        spacing: 5

                        Label { text: driverName;   font.pixelSize: 22; font.bold: true }
                        Label { text: vehicleNumber }
                        Label { text: "★★★★★ " + driverRating }
                        Label { text: appState.selectedVehicle }
                    }
                }
            }


            /* ── CALL | MESSAGE | SOS ──────────────────────── */

            Row {

                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Button { text: "📞 Call" }

                Button { text: "💬 Message" }

                Button {
                    text: "🚨 SOS"
                    background: Rectangle { color: "#E53935"; radius: 8 }
                }
            }


            Item { height: 20 }

        } // Column
    } // ScrollView
}
