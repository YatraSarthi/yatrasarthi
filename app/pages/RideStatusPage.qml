import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property int eta: 8
    property int driverStep: 0

    property bool driverArrived: false

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
    }
}