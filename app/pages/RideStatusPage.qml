import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property int eta: 8
property int driverStep: 0

property bool driverArrived: false

property string rideOtp: ""
property string driverName: "Agnik Haldar"
property string vehicleNumber: "WB03AD7394"
property real driverRating: 5.5

    property string vehicleIcon:
        appState.selectedVehicle === "Bike"
            ? Qt.resolvedUrl("../../assets/icons/bike.png")
        : appState.selectedVehicle === "Auto"
            ? Qt.resolvedUrl("../../assets/icons/auto.png")
        : Qt.resolvedUrl("../../assets/icons/cab.png")

    title: "Ride Status"

    
function fetchRoute() {

    var xhr = new XMLHttpRequest()

    xhr.onreadystatechange = function() {

        if (xhr.readyState === XMLHttpRequest.DONE &&
            xhr.status === 200) {

            var data = JSON.parse(xhr.responseText)

            if (!data.routes ||
                data.routes.length === 0) {

                console.log("No route found")
                return
            }

            var coordinates =
                    data.routes[0]
                        .geometry
                        .coordinates

            var routeLatLngs = []

            for (var i = 0;
                 i < coordinates.length;
                 i++) {

                routeLatLngs.push([
                    coordinates[i][1],
                    coordinates[i][0]
                ])
            }

            console.log(
                "Route points:",
                routeLatLngs.length
            )

          routeMap.runJavaScript(

    "drawRoute("
    + JSON.stringify(routeLatLngs)
    + ", '"
    + vehicleIcon
    + "')",

    function() {

        fetchDriverLocation()
    }
)
        }
    }

    xhr.open(
        "GET",
        "http://127.0.0.1:8000/route"
        + "?pickup_lat=" + appState.pickupLat
        + "&pickup_lon=" + appState.pickupLon
        + "&destination_lat=" + appState.destinationLat
        + "&destination_lon=" + appState.destinationLon,
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

                    driverStep = data.step

                    driverArrived =
                            data.arrived

                    console.log(
                        "ETA:",
                        eta
                    )

                    console.log(
                        "STEP:",
                        driverStep
                    )

                    routeMap.runJavaScript(
                        "moveDriver("
                        + driverStep
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

    Column {

        anchors.fill: parent

        spacing: 10

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
                    ? "Driver Arrived"
                    : "Ride Status"

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
                         "../web/ride_status.html"
                     )

                onLoadingChanged: {

                    if (
                        loadRequest.status ===
                        WebEngineLoadRequest
                        .LoadSucceededStatus
                    ) {

                        console.log(
                            "Ride map loaded"
                        )
runJavaScript(
    "setRide("
    + appState.pickupLat + ","
    + appState.pickupLon + ","
    + appState.destinationLat + ","
    + appState.destinationLon
    + ")"
)

fetchRoute()
                    }
                }
            }
        }
        /*
 * OTP CARD
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
                ? "Drop in " + eta + " min"
                : " driver arriving in " + eta + " min"

            color: "white"

            font.pixelSize: 24
            font.bold: true
        }

        Label {

            text:
                driverArrived
                ? "Heading to destination"
                : "212 m away"

            color: "white"

            font.pixelSize: 16
        }
    }
}
Rectangle {

    visible: driverArrived

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

            text: "Share this OTP with Captain"

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

                    text: driverName

                    font.pixelSize: 18
                }

                Label {

                    text: "★★★★★ " + driverRating

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

                    console.log("Call Driver")
                }
            }

            Button {

                text: "💬 Message"

                onClicked: {

                    console.log("Message Driver")
                }
            }
        }
    }
}

    }
}