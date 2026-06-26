import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property int eta: 0
    property real driverDistance: 0

    property bool driverArrived: false
    property bool rideStartPushed: false
    property bool driverSessionReady: false

    property string rideOtp: ""
    property string sarthiName: ""
    property string vehicleNumber: ""
    property real sarthiRating: 0.0
    property bool dataLoaded: false

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

    // ── Driver photo helper ─────────────────────────────────────────────────
    // Backend now sends the filename WITH extension (e.g. "Johney.jpeg").
    // This helper still tolerates a bare name (no extension) for safety.
    function driverPhotoUrl(photo) {
        if (!photo || photo.length === 0) return ""
        if (/\.(jpe?g|png|webp)$/i.test(photo))
            return "../../assets/image/" + photo
        return "../../assets/image/" + photo + ".jpeg"
    }

    // ── OTP ──────────────────────────────────────────────────────────────
    function generateOtp() {
        var otp = ""
        for (var i = 0; i < 4; i++)
            otp += Math.floor(Math.random() * 10)
        rideOtp = otp
    }

    function otpDigit(index) {
        if (rideOtp.length < 4) return "-"
        return rideOtp.charAt(index)
    }

    // ── START DRIVER ──────────────────────────────────────────────────────
    function startDriver() {
        driverArrived      = false
        driverSessionReady = false

        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status !== 200) {
                    console.warn("startDriver failed:", xhr.status)
                    startDriverErrorLabel.visible = true
                    return
                }
                var data = JSON.parse(xhr.responseText)
                driverDistance = data.distance || 0
                eta            = data.eta      || 0
                sarthiName     = data.driverName    || "Unknown Driver"
vehicleNumber  = data.vehicleNumber || "—"
sarthiRating   = data.driverRating  || 0.0

dataLoaded = true

// Save current driver in AppState
if (appState) {

    appState.driverName    = sarthiName
    appState.driverVehicle = vehicleNumber
    appState.driverVehicleModel = data.vehicleModel || ""
    appState.driverRating  = sarthiRating
    appState.driverPhoto   = data.driverPhoto || ""

    appState.lastDriverName = sarthiName
}

                routeMap.runJavaScript(
                    "setPickupRide("
                    + appState.pickupLat + ","
                    + appState.pickupLon + ","
                    + data.driverLat    + ","
                    + data.driverLon    + ")"
                )
                fetchPickupRoute(data.driverLat, data.driverLon)
                driverSessionReady = true
            }
        }
        xhr.open(
            "GET",
            "http://127.0.0.1:8000/start-driver"
            + "?pickup_lat=" + appState.pickupLat
            + "&pickup_lon=" + appState.pickupLon
            + "&selected_vehicle=" + appState.selectedVehicle.toLowerCase(),  // ← ADD THIS
            true
        )
        xhr.send()
    }

    // ── POLL DRIVER LOCATION ──────────────────────────────────────────────
    function fetchDriverLocation() {
        if (!driverSessionReady) return

        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status !== 200) return
                var data = JSON.parse(xhr.responseText)
                eta            = data.eta      || eta
                driverDistance = data.distance || driverDistance

                if (data.arrived && !driverArrived && !rideStartPushed) {
                    driverArrived = true
                    rideStartTimer.start()
                }

                routeMap.runJavaScript(
                    "updateDriver(" + data.driverLat + "," + data.driverLon + ")"
                )
                fetchPickupRoute(data.driverLat, data.driverLon)
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/driver-location", true)
        xhr.send()
    }

    // ── ROUTE POLYLINE ────────────────────────────────────────────────────
    function fetchPickupRoute(driverLat, driverLon) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status !== 200) return
                var data = JSON.parse(xhr.responseText)
                if (!data.routes || data.routes.length === 0) return
                var coordinates = data.routes[0].geometry.coordinates
                var routePoints = []
                for (var i = 0; i < coordinates.length; i++)
                    routePoints.push([coordinates[i][1], coordinates[i][0]])
                routeMap.runJavaScript("drawRoute(" + JSON.stringify(routePoints) + ")")
            }
        }
        xhr.open(
            "GET",
            "http://127.0.0.1:8000/pickup-route"
            + "?driver_lat=" + driverLat
            + "&driver_lon=" + driverLon
            + "&pickup_lat=" + appState.pickupLat
            + "&pickup_lon=" + appState.pickupLon,
            true
        )
        xhr.send()
    }

    // ── LIFECYCLE ─────────────────────────────────────────────────────────
    Component.onCompleted: {
        generateOtp()
    }

    // ── TIMERS ────────────────────────────────────────────────────────────
    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: { if (!driverArrived) fetchDriverLocation() }
    }

    Timer {
        id: rideStartTimer
        interval: 3000; repeat: false
        onTriggered: {
            if (rideStartPushed) return
            rideStartPushed = true
            appStack.push(
                Qt.resolvedUrl("RideInProgress.qml"),
                { "appStack": appStack, "appState": appState }
            )
        }
    }

    // ── CANCEL DIALOG ─────────────────────────────────────────────────────
    Dialog {
        id:    cancelDialog
        title: "Cancel Ride"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel

        property string reason: cancelReason.currentText

        contentItem: Item {
            implicitWidth:  300
            implicitHeight: cancelColumn.implicitHeight + 30

            Column {
                id: cancelColumn
                anchors {
                    top: parent.top; left: parent.left; right: parent.right
                    topMargin: 15; leftMargin: 15; rightMargin: 15
                }
                spacing: 12

                Label {
                    text: "Why are you cancelling?"
                    font.pixelSize: 15; font.bold: true; color: "#111"
                }

                Label {
                    text: "Select a reason:"
                    font.pixelSize: 12; color: "#888"
                }

                ComboBox {
                    id: cancelReason
                    width: parent.width
                    font.pixelSize: 13
                    model: [
                        "Driver taking too long",
                        "Changed my mind",
                        "Booked by mistake",
                        "Found another ride",
                        "Emergency",
                        "Other",
                        "Cancel & find another driver"
                    ]

                    // Highlight the special option in amber
                    delegate: ItemDelegate {
                        width: cancelReason.width
                        contentItem: Text {
                            text: modelData
                            font.pixelSize: 13
                            color: modelData === "Cancel & find another driver"
                                   ? "#E65100" : "#111"
                            font.bold: modelData === "Cancel & find another driver"
                        }
                        background: Rectangle {
                            color: hovered
                                   ? (modelData === "Cancel & find another driver"
                                      ? "#FFF8E1" : "#F5F5F5")
                                   : "white"
                        }
                    }
                }

                // Preview of what the special option does
                Rectangle {
                    width: parent.width
                    height: previewCol.height + 20
                    radius: 10
                    color: "#FFF8E1"
                    border.color: "#FFE082"
                    visible: cancelReason.currentText === "Cancel & find another driver"

                    Column {
                        id: previewCol
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                        spacing: 4

                        Text {
                            text: "🔄  Find a different driver"
                            font.pixelSize: 13; font.bold: true; color: "#E65100"
                        }
                        Text {
                            text: "We'll skip " + sarthiName + " and search\nfor the next available driver nearby."
                            font.pixelSize: 11; color: "#F57C00"
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }
            }
        }

        onAccepted: {
            var reason = cancelReason.currentText
            console.log("Cancel reason:", reason)

            if (reason === "Cancel & find another driver") {

                // 1. Increment retry counter in AppState
                if (appState) appState.driverRetryCount++

                // 2. Reset backend driver session
                var xhr = new XMLHttpRequest()
                xhr.open("GET", "http://127.0.0.1:8000/reset-driver", false)
                xhr.send()

                // 3. Replace this page with BookingPage (isRetry = true)
                //    replace() keeps the stack clean — no double PickupPage
                appStack.replace(
                    Qt.resolvedUrl("BookingPage.qml"),
                    {
                        "appStack": appStack,
                        "appState": appState,
                        "isRetry":  true
                    }
                )

            } else if (reason === "Driver taking too long") {
                // Old behaviour: go back to ResultsPage
                appStack.replace(
                    Qt.resolvedUrl("ResultsPage.qml"),
                    { "appStack": appStack, "appState": appState }
                )

            } else {
                // All other reasons: clear stack and go home
                if (appState) {
                    appState.showBottomBar = true
                    appState.resetDriverSearch()
                }
                appStack.clear()
                appStack.push(
                    Qt.resolvedUrl("HomePage.qml"),
                    { "appStack": appStack, "appState": appState }
                )
            }
        }
    }

    // ── UI ────────────────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        Column {
            width: parent.width
            spacing: 10
            bottomPadding: 40

            // ── Header ────────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 58; color: "#1976D2"

                Row {
                    anchors.fill: parent; anchors.leftMargin: 10; spacing: 10

                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: "#33FFFFFF"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "‹"; color: "white"
                            font.pixelSize: 26; font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: appStack.pop()
                        }
                    }

                    Label {
                        text: driverArrived ? "Sarthi Arrived!" : "Sarthi Arriving"
                        font.pixelSize: 20; font.bold: true; color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Retry badge in header
                    Rectangle {
                        visible: appState && appState.driverRetryCount > 0
                        anchors.verticalCenter: parent.verticalCenter
                        height: 22; width: retryCountText.width + 16; radius: 11
                        color: "#FFF3E0"

                        Text {
                            id: retryCountText
                            anchors.centerIn: parent
                            text: "Driver #" + (appState ? appState.driverRetryCount + 1 : 1)
                            font.pixelSize: 11; font.bold: true; color: "#E65100"
                        }
                    }
                }
            }

            // Error banner
            Label {
                id: startDriverErrorLabel
                visible: false
                text: "Could not contact driver service. Please retry or go back."
                color: "#E53935"; wrapMode: Text.WordWrap
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // ── Live Map ─────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 260; border.color: "#D3D3D3"

                WebEngineView {
                    id: routeMap
                    anchors.fill: parent
                    url: Qt.resolvedUrl("../web/PickupMap.html")

                    onLoadingChanged: {
                        if (loadRequest.status ===
                                WebEngineLoadRequest.LoadSucceededStatus) {
                            routeMap.runJavaScript(
                                "setVehicleType('" + appState.selectedVehicle + "')"
                            )
                            startDriver()
                        }
                    }
                }
            }

            // ── Status card ───────────────────────────────────────────────
            Rectangle {
                width: parent.width - 20; height: 90
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 15; color: "#1976D2"

                Column {
                    anchors.centerIn: parent; spacing: 5

                    Label {
                        text: driverArrived
                              ? "Sarthi Has Arrived"
                              : "Sarthi arriving in " + eta + " min"
                        color: "white"; font.pixelSize: 24; font.bold: true
                    }
                    Label {
                        text: driverArrived
                              ? "Ready for pickup"
                              : driverDistance.toFixed(1) + " km away"
                        color: "white"; font.pixelSize: 16
                    }
                }
            }

            // ── OTP + Driver card ─────────────────────────────────────────
            Rectangle {
                width: parent.width - 20; height: 340
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 15; color: "white"; border.color: "#D3D3D3"

                Column {
                    anchors.fill: parent; anchors.margins: 15; spacing: 15

                    Label {
                        text: "Share this OTP with Sarthi"
                        font.pixelSize: 18; font.bold: true
                    }

                    Row {
                        spacing: 10; anchors.horizontalCenter: parent.horizontalCenter
                        Repeater {
                            model: 4
                            Rectangle {
                                width: 55; height: 55; radius: 8
                                color: "#F5F5F5"; border.color: "#D3D3D3"
                                Label {
                                    anchors.centerIn: parent
                                    text: otpDigit(index)
                                    font.pixelSize: 28; font.bold: true
                                }
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: "#E0E0E0" }

                    Row {
                        spacing: 15

                        Image {
                            source: vehicleIcon; width: 50; height: 50
                            fillMode: Image.PreserveAspectFit
                        }

                        Rectangle {
                            width: 70; height: 70; radius: 35
                            clip: true; color: "#E0E0E0"

                            Image {
                                anchors.fill: parent
                                source: driverPhotoUrl(appState.driverPhoto)
                                fillMode: Image.PreserveAspectCrop

                                Rectangle {
                                    anchors.fill: parent
                                    color: "#1976D2"
                                    visible: parent.status !== Image.Ready

                                    Label {
                                        anchors.centerIn: parent
                                        text: "👤"
                                        font.pixelSize: 26
                                    }
                                }
                            }
                        }

                        Column {
    spacing: 4

    Label {
        text: dataLoaded ? sarthiName : ""
        font.pixelSize: 18
        font.bold: true
    }

    Label {
        text: dataLoaded ? vehicleNumber : ""
        font.pixelSize: 15
        color: "#444444"
    }

    Label {
        text: dataLoaded ? appState.driverVehicleModel : ""
        font.pixelSize: 15
        color: "#666666"
    }

    Label {
        text: dataLoaded
              ? "★★★★★ " + sarthiRating.toFixed(1)
              : ""
        font.pixelSize: 16
        color: "#F4A700"
    }
}
                    }

                    Row {
                        spacing: 10; anchors.horizontalCenter: parent.horizontalCenter

                        Button {
                            width: 120; height: 45
                            contentItem: Row {
                                anchors.centerIn: parent; spacing: 8
                                Image { source: "../../assets/icons/phone.png"; width: 20; height: 20 }
                                Text { text: "Call" }
                            }
                        }

                        Button {
                            width: 120; height: 45
                            contentItem: Row {
                                anchors.centerIn: parent; spacing: 8
                                Image { source: "../../assets/icons/message.png"; width: 20; height: 20 }
                                Text { text: "Message" }
                            }
                            onClicked: {
                                appStack.push(
                                    Qt.resolvedUrl("ChatPage.qml"),
                                    { "appStack": appStack, "appState": appState }
                                )
                            }
                        }
                    }
                }
            }

            // ── Cancel Ride button ────────────────────────────────────────
            Button {
                width: parent.width * 0.7; height: 50
                anchors.horizontalCenter: parent.horizontalCenter

                background: Rectangle { radius: 10; color: "#E53935" }
                contentItem: Text {
                    text: "Cancel Ride"
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignVCenter
                }
                onClicked: cancelDialog.open()
            }

            Item { height: 20 }
        }
    }
}
