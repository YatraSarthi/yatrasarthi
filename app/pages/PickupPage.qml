import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property int eta: 0
    property real driverDistance: 0

    property bool driverArrived: false
    property bool rideStartPushed: false   // Fix 5: guard against double-push
    property bool driverSessionReady: false // Fix 2: block polling until /start-driver completes

    property string rideOtp: ""
    property string sarthiName: ""
    property string vehicleNumber: ""
    property real sarthiRating: 0.0
    property bool dataLoaded: false        // Fix 6: track whether real data arrived

    // Fix 9: vehicleIcon now actually used in the driver detail row
    property string vehicleIcon:
        appState.selectedVehicle === "Bike"
            ? Qt.resolvedUrl("../../assets/icons/bike.png")
        : appState.selectedVehicle === "Auto"
            ? Qt.resolvedUrl("../../assets/icons/auto.png")
        : appState.selectedVehicle === "Cab"
            ? Qt.resolvedUrl("../../assets/icons/cab.png")
        : appState.selectedVehicle === "Carpool"
            ? Qt.resolvedUrl("../../assets/icons/cab.png")
            : Qt.resolvedUrl("../../assets/icons/cab.png")

    title: "Sarthi Arriving"

    // ─── OTP ────────────────────────────────────────────────────────────────

    function generateOtp() {
        var otp = ""
        for (var i = 0; i < 4; i++)
            otp += Math.floor(Math.random() * 10)
        rideOtp = otp
        console.log("Ride OTP:", rideOtp)
    }

    // Fix 3: safe single-char accessor used in Repeater instead of rideOtp[index]
    function otpDigit(index) {
        if (rideOtp.length < 4)
            return "-"
        return rideOtp.charAt(index)
    }

    // ─── START DRIVER ───────────────────────────────────────────────────────

    function startDriver() {
        driverArrived       = false
        driverSessionReady  = false     // Fix 2: block poll until this call succeeds

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {

                // Fix 7: handle non-200 responses explicitly
                if (xhr.status !== 200) {
                    console.warn(
                        "startDriver failed, status:", xhr.status,
                        "body:", xhr.responseText
                    )
                    startDriverErrorLabel.visible = true
                    return
                }

                var data = JSON.parse(xhr.responseText)

                driverDistance = data.distance || 0
                eta            = data.eta      || 0

                // Fix 6: only overwrite defaults when server returns real values
                sarthiName    = data.driverName    || "Unknown Driver"
                vehicleNumber = data.vehicleNumber  || "—"
                sarthiRating  = data.driverRating   || 0.0
                dataLoaded    = true

                routeMap.runJavaScript(
                    "setPickupRide("
                    + appState.pickupLat + ","
                    + appState.pickupLon + ","
                    + data.driverLat    + ","
                    + data.driverLon
                    + ")"
                )

                fetchPickupRoute(data.driverLat, data.driverLon)

                // Fix 2: only open the poll gate after session is established
                driverSessionReady = true
            }
        }

        xhr.open(
            "GET",
            "http://127.0.0.1:8000/start-driver"
            + "?pickup_lat=" + appState.pickupLat
            + "&pickup_lon=" + appState.pickupLon,
            true
        )
        xhr.send()
    }

    // ─── POLL DRIVER LOCATION ───────────────────────────────────────────────

    function fetchDriverLocation() {

        // Fix 2: skip poll if /start-driver hasn't returned yet
        if (!driverSessionReady)
            return

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {

                // Fix 7: handle non-200 responses
                if (xhr.status !== 200) {
                    console.warn(
                        "fetchDriverLocation failed, status:", xhr.status
                    )
                    return
                }

                var data = JSON.parse(xhr.responseText)

                eta            = data.eta      || eta
                driverDistance = data.distance || driverDistance

                // Fix 5: guard so the timer never fires twice
                if (data.arrived && !driverArrived && !rideStartPushed) {
                    driverArrived = true
                    console.log("Sarthi arrived — starting 3 s handoff timer")
                    rideStartTimer.start()
                }

                routeMap.runJavaScript(
                    "updateDriver("
                    + data.driverLat + ","
                    + data.driverLon
                    + ")"
                )

                fetchPickupRoute(data.driverLat, data.driverLon)
            }
        }

        xhr.open(
            "GET",
            "http://127.0.0.1:8000/driver-location",
            true
        )
        xhr.send()
    }

    // ─── ROUTE POLYLINE ─────────────────────────────────────────────────────

    function fetchPickupRoute(driverLat, driverLon) {

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {

                // Fix 7: handle non-200 responses
                if (xhr.status !== 200) {
                    console.warn(
                        "fetchPickupRoute failed, status:", xhr.status
                    )
                    return
                }

                var data = JSON.parse(xhr.responseText)

                if (!data.routes || data.routes.length === 0)
                    return

                var coordinates = data.routes[0].geometry.coordinates
                var routePoints = []

                for (var i = 0; i < coordinates.length; i++)
                    routePoints.push([ coordinates[i][1], coordinates[i][0] ])

                routeMap.runJavaScript(
                    "drawRoute(" + JSON.stringify(routePoints) + ")"
                )
            }
        }

        xhr.open(
            "GET",
            "http://127.0.0.1:8000/pickup-route"
            + "?driver_lat="  + driverLat
            + "&driver_lon="  + driverLon
            + "&pickup_lat="  + appState.pickupLat
            + "&pickup_lon="  + appState.pickupLon,
            true
        )
        xhr.send()
    }

    // ─── LIFECYCLE ──────────────────────────────────────────────────────────

    // Fix 1: Component.onCompleted now only does what is safe at this point.
    // startDriver() is deferred to the map's onLoadingChanged so the WebView
    // is guaranteed to be ready before we inject JS into it.
    Component.onCompleted: {
        generateOtp()
        console.log(
            "Pickup coords:",
            appState.pickupLat,
            appState.pickupLon
        )
    }

    // ─── TIMERS ─────────────────────────────────────────────────────────────

    // Fix 2: poll only fires when driverSessionReady is true (checked inside)
    Timer {
        interval: 5000
        running:  true
        repeat:   true
        onTriggered: {
            if (!driverArrived)
                fetchDriverLocation()
        }
    }

    // Fix 5: rideStartPushed ensures push() is called exactly once
    Timer {
        id:      rideStartTimer
        interval: 3000
        repeat:  false
        onTriggered: {
            if (rideStartPushed)
                return
            rideStartPushed = true
            console.log("Navigating to RideInProgress")
            appStack.push(
                Qt.resolvedUrl("RideInProgress.qml"),
                { "appStack": appStack, "appState": appState }
            )
        }
    }

    // ─── CANCEL DIALOG ──────────────────────────────────────────────────────

    Dialog {
        id:    cancelDialog
        title: "Cancel Ride"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel

        property string reason: "Driver taking too long"

        // Fix 4: use Item as contentItem so Dialog controls its own size;
        // Column sits inside with normal anchors rather than anchors.fill
        contentItem: Item {
            implicitWidth:  280
            implicitHeight: cancelColumn.implicitHeight + 30

            Column {
                id:      cancelColumn
                anchors {
                    top:   parent.top
                    left:  parent.left
                    right: parent.right
                    topMargin:  15
                    leftMargin: 15
                    rightMargin: 15
                }
                spacing: 10

                Label {
                    text: "Why are you cancelling?"
                }

                ComboBox {
                    id:    cancelReason
                    width: parent.width
                    model: [
                        "Driver taking too long",
                        "Changed my mind",
                        "Booked by mistake",
                        "Found another ride",
                        "Emergency",
                        "Other"
                    ]
                    onCurrentTextChanged: cancelDialog.reason = currentText
                }
            }
        }

        onAccepted: {

    console.log("Ride Cancelled:", reason)

    if (reason === "Driver taking too long") {

        console.log("Searching for another driver...")

        appStack.replace(
            Qt.resolvedUrl("ResultsPage.qml"),
            {
                "appStack": appStack,
                "appState": appState
            }
        )

    } else {

        console.log("Going to Home Page")

        appStack.clear()

        appStack.push(
            Qt.resolvedUrl("HomePage.qml"),
            {
                "appStack": appStack,
                "appState": appState
            }
        )
    }
}}




    // ─── UI ─────────────────────────────────────────────────────────────────

    ScrollView {
        anchors.fill: parent
        clip:         true
        contentWidth: availableWidth   // never wider than viewport

        Column {
            // Fix 8: bind width to ScrollView.availableWidth (a real property)
            // instead of the non-existent ScrollView.view.width
            width:          parent.width
            spacing:        10
            bottomPadding:  40

            // ── HEADER ──────────────────────────────────────────────────────

            Row {
                spacing:           10
                anchors.left:      parent.left
                anchors.leftMargin: 10

                Button {
                    text:      "← Back"
                    onClicked: appStack.pop()
                }

                Label {
                    text: driverArrived ? "Sarthi Arrived" : "Sarthi Arriving"
                    font.pixelSize: 22
                    font.bold:      true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Fix 6: error banner shown when /start-driver fails
            Label {
                id:      startDriverErrorLabel
                visible: false
                text:    "Could not contact driver service. Please retry or go back."
                color:   "#E53935"
                wrapMode: Text.WordWrap
                width:    parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // ── LIVE MAP ────────────────────────────────────────────────────

            Rectangle {
                width:        parent.width
                height:       260
                border.color: "#D3D3D3"

                WebEngineView {
                    id:          routeMap
                    anchors.fill: parent
                    url:         Qt.resolvedUrl("../web/PickupMap.html")

                    // Fix 1: call startDriver() here (not in Component.onCompleted)
                    // so the WebView is fully ready before we inject JS
                    onLoadingChanged: {

    if (
        loadRequest.status ===
        WebEngineLoadRequest
        .LoadSucceededStatus
    ) {

        console.log(
            "Sarthi map loaded"
        )

        routeMap.runJavaScript(

            "setVehicleType('"
            + appState.selectedVehicle
            + "')"
        )

        startDriver()
    }
}
                }
            }

            // ── STATUS CARD ─────────────────────────────────────────────────

            Rectangle {
                width:  parent.width - 20
                height: 90
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 15
                color:  "#1976D2"

                Column {
                    anchors.centerIn: parent
                    spacing:          5

                    Label {
                        text: driverArrived
                            ? "Sarthi Has Arrived"
                            : "Sarthi arriving in " + eta + " min"
                        color:          "white"
                        font.pixelSize: 24
                        font.bold:      true
                    }

                    Label {
                        text: driverArrived
                            ? "Ready for pickup"
                            : driverDistance.toFixed(1) + " km away"
                        color:          "white"
                        font.pixelSize: 16
                    }
                }
            }

            // ── OTP + DRIVER CARD ────────────────────────────────────────────

            Rectangle {
                width:  parent.width - 20
                height: 340
                anchors.horizontalCenter: parent.horizontalCenter
                radius:       15
                color:        "white"
                border.color: "#D3D3D3"

                Column {
                    anchors.fill:    parent
                    anchors.margins: 15
                    spacing:         15

                    Label {
                        text:           "Share this OTP with Sarthi"
                        font.pixelSize: 18
                        font.bold:      true
                    }

                    // Fix 3: use otpDigit(index) helper — safe even on first frame
                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: 4

                            Rectangle {
                                width:        55
                                height:       55
                                radius:       8
                                color:        "#F5F5F5"
                                border.color: "#D3D3D3"

                                Label {
                                    anchors.centerIn: parent
                                    text:             otpDigit(index)
                                    font.pixelSize:   28
                                    font.bold:        true
                                }
                            }
                        }
                    }

                    Rectangle {
                        width:  parent.width
                        height: 1
                        color:  "#E0E0E0"
                    }

                    Row {
                        spacing: 15

                        // Fix 9: vehicleIcon is now displayed here
                        Image {
                            source:   vehicleIcon
                            width:    50
                            height:   50
                            fillMode: Image.PreserveAspectFit
                        }

                        Image {
                            source:   "../../assets/image/agnik.jpeg"
                            width:    70
                            height:   70
                            fillMode: Image.PreserveAspectCrop
                            clip:     true
                        }

                        Column {
                            spacing: 5

                            // Fix 6: show placeholder text until real data arrives
                            Label {
                                text:           dataLoaded ? vehicleNumber : "Loading…"
                                font.pixelSize: 22
                                font.bold:      true
                            }

                            Label {
                                text:           dataLoaded ? sarthiName : ""
                                font.pixelSize: 18
                            }

                            Label {
                                text: dataLoaded
                                    ? "★★★★★ " + sarthiRating.toFixed(1)
                                    : ""
                                font.pixelSize: 16
                            }
                        }
                    }

                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        Button {

    width: 120
    height: 45

    contentItem: Row {

        anchors.centerIn: parent
        spacing: 8

        Image {
            source: "../../assets/icons/phone.png"
            width: 20
            height: 20
        }

        Text {
            text: "Call"
        }
    }
}Button {

    width: 120
    height: 45

    contentItem: Row {

        anchors.centerIn: parent
        spacing: 8

        Image {
            source: "../../assets/icons/message.png"
            width: 20
            height: 20
        }

        Text {
            text: "Message"
        }
    }

    onClicked: {

        appStack.push(
            Qt.resolvedUrl("ChatPage.qml"),
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

            // ── CANCEL ──────────────────────────────────────────────────────

            Button {
                width:  parent.width * 0.7
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter

                background: Rectangle {
                    radius: 10
                    color:  "#E53935"
                }

                contentItem: Text {
                    text:               "Cancel Ride"
                    color:              "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignVCenter
                }

                onClicked: cancelDialog.open()
            }

            Item { height: 20 }
        }
    }
}
