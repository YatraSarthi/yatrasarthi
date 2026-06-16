import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property int eta: 8
    property int driverStep: 0

    property bool driverArrived: false

    title: "Ride Status"

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
                            + appState.destinationLon + ",'"
                            + appState.selectedVehicle
                            + "')"
                        )

                        /*
                         * Initial fetch
                         */

                        fetchDriverLocation()
                    }
                }
            }
        }
    }
}