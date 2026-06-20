import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property int eta: 0
    property int driverStep: 0
    property real driverDistance: 0

    property bool driverArrived: false

    property string rideOtp: ""
    property string sarthiName: "Agnik Haldar"
    property string vehicleNumber: "WB03AD7394"
    property real sarthiRating: 4.8

    property string vehicleIcon:
        appState.selectedVehicle === "Bike"
            ? Qt.resolvedUrl("../../assets/icons/bike.png")
        : appState.selectedVehicle === "Auto"
            ? Qt.resolvedUrl("../../assets/icons/auto.png")
        : Qt.resolvedUrl("../../assets/icons/cab.png")

    title: "Sarthi Arriving"

    // Fix 2: startDriver() added — calls /start-driver, populates
    // Sarthi identity + rating, and initializes the map via
    // setPickupRide() (the function PickupMap.html actually has).
    function startDriver() {
        driverArrived = false
        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {

            if (
                xhr.readyState === XMLHttpRequest.DONE &&
                xhr.status === 200
            ) {

                var data =
                    JSON.parse(xhr.responseText)

                driverDistance = data.distance
                eta = data.eta

                if (data.driverName)
                    sarthiName = data.driverName

                if (data.vehicleNumber)
                    vehicleNumber = data.vehicleNumber

                if (data.driverRating)
                    sarthiRating = data.driverRating

                routeMap.runJavaScript(
                    "setPickupRide("
                    + appState.pickupLat + ","
                    + appState.pickupLon + ","
                    + data.driverLat + ","
                    + data.driverLon
                    + ")"
                )
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

    function generateOtp() {

        rideOtp = ""

        for (var i = 0; i < 4; i++) {

            rideOtp += Math.floor(
                Math.random() * 10
            )
        }

        console.log("Ride OTP:", rideOtp)
    }

    /*
     * Fetch driver updates from FastAPI
     */
    function fetchDriverLocation() {

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {

            if (xhr.readyState === XMLHttpRequest.DONE) {

                console.log(
                    "Driver Status:",
                    xhr.status
                )

                console.log(
                    "Driver Response:",
                    xhr.responseText
                )

                if (xhr.status === 200) {

                    var data =
                            JSON.parse(xhr.responseText)

                    eta = data.eta

                    driverDistance =
                            data.distance

                    if (data.arrived && !driverArrived) {

                        driverArrived = true

                        console.log(
                            "Sarthi arrived"
                        )

                        rideStartTimer.start()
                        }

                    console.log(
                        "ETA:",
                        eta
                    )

                    // Fix 3: PickupMap.html exposes updateDriver(lat, lon),
                    // not moveDriver(step) — driverStep was never part of
                    // the /driver-location payload to begin with.
                    routeMap.runJavaScript(
                        "updateDriver("
                        + data.driverLat + ","
                        + data.driverLon
                        + ")"
                    )
                }
            }
        }

        xhr.open(
            "GET",
            "http://127.0.0.1:8000/driver-location",
            true
        )

        xhr.send()
    }

    /*
     * Poll backend every 5 seconds
     */

    Component.onCompleted: {

    generateOtp()

    console.log(
        "Pickup:",
        appState.pickupLat,
        appState.pickupLon
    )
}

    Timer {

        interval: 5000

        running: true

        repeat: true

        onTriggered: {

            if (!driverArrived) {

                fetchDriverLocation()
            }
        }
    }

    Timer {

        id: rideStartTimer

        interval: 3000

        repeat: false

        onTriggered: {

            console.log(
                "Ride started automatically"
            )

            appStack.push(
                Qt.resolvedUrl(
                    "RideInProgress.qml"
                ),
                {
                    "appStack": appStack,
                    "appState": appState
                }
            )
        }
    }

    Dialog {

        id: cancelDialog

        title: "Cancel Ride"

        modal: true

        // Dialog needs explicit centering — it has no
        // implicit position of its own inside Page.
        anchors.centerIn: parent

        standardButtons:
            Dialog.Ok |
            Dialog.Cancel

        property string reason:
            "Driver taking too long"

        contentItem: Column {

            // 'padding' is not a valid Column property —
            // replaced with anchors.margins, which is.
            anchors.fill: parent
            anchors.margins: 15

            spacing: 10

            Label {

                text:
                    "Why are you cancelling?"
            }

            ComboBox {

                id: cancelReason

                width: 250

                model: [

                    "Driver taking too long",
                    "Changed my mind",
                    "Booked by mistake",
                    "Found another ride",
                    "Emergency",
                    "Other"
                ]

                onCurrentTextChanged: {

                    cancelDialog.reason =
                            currentText
                }
            }
        }

        onAccepted: {

            console.log(
                "Ride Cancelled:",
                reason
            )

            appStack.pop()
        }
    }

    ScrollView {

        anchors.fill: parent

        clip: true

        // Lock content width to the viewport so it never
        // drifts wider/narrower than the actual screen.
        contentWidth: availableWidth

        Column {

            // Bind to the ScrollView's resolved width directly,
            // with a parent.width fallback for the first paint
            // frame before ScrollView.view is attached.
            width: ScrollView.view
                ? ScrollView.view.width
                : parent.width

            spacing: 10

            bottomPadding: 40

            /*
             * HEADER
             */

            Row {

                spacing: 10

                anchors.left: parent.left

                anchors.leftMargin: 10

                Button {

                    text: "← Back"

                    onClicked: {

                        appStack.pop()
                    }
                }

                Label {

                    text:
                        driverArrived
                        ? "Sarthi Arrived"
                        : "Sarthi Arriving"

                    font.pixelSize: 22

                    font.bold: true

                    anchors.verticalCenter:
                            parent.verticalCenter
                }
            }

            /*
             * LIVE MAP
             */

            Rectangle {

                width: parent.width

                height: 260

                border.color: "#D3D3D3"

                WebEngineView {

                    id: routeMap

                    anchors.fill: parent

                    url: Qt.resolvedUrl(
                             "../web/PickupMap.html"
                         )

                    // Fix 1: PickupMap.html has no setRide() function —
                    // it only exposes setPickupRide() (called from inside
                    // startDriver() once the backend responds). On load
                    // we just call startDriver() directly.
                    onLoadingChanged: {

                        if (
                            loadRequest.status ===
                            WebEngineLoadRequest
                            .LoadSucceededStatus
                        ) {

                            console.log(
                                "Sarthi map loaded"
                            )

                            startDriver()
                        }
                    }
                }
            }

            /*
             * STATUS CARD
             */

            Rectangle {

                width: parent.width - 20
                height: 90

                anchors.horizontalCenter: parent.horizontalCenter

                radius: 15

                color: "#1976D2"

                Column {

                    anchors.centerIn: parent

                    spacing: 5

                    Label {

                        text:
                            driverArrived
                            ? "Sarthi Has Arrived"
                            : "Sarthi arriving in " + eta + " min"

                        color: "white"

                        font.pixelSize: 24
                        font.bold: true
                    }

                    Label {

                        text:
                            driverArrived
                            ? "Ready for pickup"
                            : driverDistance.toFixed(1) + " km away"

                        color: "white"

                        font.pixelSize: 16
                    }
                }
            }

            /*
             * OTP CARD — 4-digit grid + Sarthi details + actions
             */

            Rectangle {

                width: parent.width - 20
                height: 320

                anchors.horizontalCenter: parent.horizontalCenter

                radius: 15

                color: "white"

                border.color: "#D3D3D3"

                Column {

                    anchors.fill: parent
                    anchors.margins: 15

                    spacing: 15

                    Label {

                        text: "Share this OTP with Sarthi"

                        font.pixelSize: 18
                        font.bold: true
                    }

                    Row {

                        spacing: 10

                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {

                            model: 4

                            Rectangle {

                                width: 55
                                height: 55

                                radius: 8

                                color: "#F5F5F5"

                                border.color: "#D3D3D3"

                                Label {

                                    anchors.centerIn: parent

                                    text: rideOtp[index]

                                    font.pixelSize: 28
                                    font.bold: true
                                }
                            }
                        }
                    }

                    Rectangle {

                        width: parent.width
                        height: 1

                        color: "#E0E0E0"
                    }

                    Row {

                        spacing: 15

                        Image {

                            source: "../../assets/image/agnik.jpeg"

                            width: 70
                            height: 70

                            fillMode: Image.PreserveAspectCrop

                            clip: true
                        }

                        Column {

                            spacing: 5

                            Label {

                                text: vehicleNumber

                                font.pixelSize: 22
                                font.bold: true
                            }

                            Label {

                                text: sarthiName

                                font.pixelSize: 18
                            }

                            Label {

                                text: "★★★★★ " + sarthiRating

                                font.pixelSize: 16
                            }
                        }
                    }

                    Row {

                        spacing: 10

                        anchors.horizontalCenter: parent.horizontalCenter

                        Button {

                            text: "📞 Call"

                            onClicked: {

                                console.log("Call Sarthi")
                            }
                        }

                        Button {

                            text: "💬 Message"

                            onClicked: {

                                console.log("Message Sarthi")
                            }
                        }
                    }
                }
            }

            /*
             * CANCEL
             */

            Button {

                width: parent.width * 0.7

                height: 50

                anchors.horizontalCenter:
                    parent.horizontalCenter

                text: "Cancel Ride"

                background: Rectangle {

                    radius: 10

                    color: "#E53935"
                }

                contentItem: Text {

                    text: "Cancel Ride"

                    color: "white"

                    horizontalAlignment:
                        Text.AlignHCenter

                    verticalAlignment:
                        Text.AlignVCenter
                }

                onClicked: {

                    cancelDialog.open()
                }
            }

            Item {

                height: 20
            }
        }
    }
}