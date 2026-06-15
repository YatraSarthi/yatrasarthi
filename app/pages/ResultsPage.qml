import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    property var rideData: null

    title: "Ride Estimates"

    function getVehicleIcon(vehicle) {

        if (vehicle === "Bike")
            return "../../assets/icons/bike.png"

        else if (vehicle === "Auto")
            return "../../assets/icons/auto.png"

        else if (vehicle === "Cab")
            return "../../assets/icons/cab.png"

        return ""
    }

    function fetchEstimate() {

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {

            if (xhr.readyState === XMLHttpRequest.DONE) {

                console.log("Estimate Status:", xhr.status)

                console.log(
                    "Estimate Response:",
                    xhr.responseText
                )

                if (xhr.status === 200) {

                    rideData =
                            JSON.parse(xhr.responseText)

                    console.log("rideData loaded")
                }
            }
        }

        var url =
                "http://127.0.0.1:8000/estimate"
                + "?pickup_lat=" + appState.pickupLat
                + "&pickup_lon=" + appState.pickupLon
                + "&destination_lat=" + appState.destinationLat
                + "&destination_lon=" + appState.destinationLon

        console.log("Sending estimate request:")
        console.log(url)

        xhr.open(
            "GET",
            url,
            true
        )

        xhr.send()
    }

    Component.onCompleted: {

        console.log("ResultsPage opened")

        console.log(
            "Pickup Lat:",
            appState.pickupLat
        )

        console.log(
            "Pickup Lon:",
            appState.pickupLon
        )

        console.log(
            "Destination Lat:",
            appState.destinationLat
        )

        console.log(
            "Destination Lon:",
            appState.destinationLon
        )

        fetchEstimate()
    }

    ListView {

        anchors.fill: parent
        anchors.margins: 10

        spacing: 10
        clip: true

        model: rideData
               ? [
                    {
                        "vehicle": "Bike",
                        "fare": rideData.bike.fare,
                        "eta": rideData.bike.eta
                    },
                    {
                        "vehicle": "Auto",
                        "fare": rideData.auto.fare,
                        "eta": rideData.auto.eta
                    },
                    {
                        "vehicle": "Cab",
                        "fare": rideData.cab.fare,
                        "eta": rideData.cab.eta
                    }
                 ]
               : []

        delegate: Rectangle {

            width: ListView.view.width
            height: 80

            color: "white"

            radius: 12

            border.color: "#D3D3D3"
            border.width: 1

            Row {

                anchors.fill: parent
                anchors.margins: 12

                spacing: 15

                Image {

                    source: getVehicleIcon(
                                modelData.vehicle
                            )

                    width: 36
                    height: 36

                    anchors.verticalCenter:
                            parent.verticalCenter

                    fillMode:
                            Image.PreserveAspectFit

                    smooth: true
                }

                Column {

                    anchors.verticalCenter:
                            parent.verticalCenter

                    spacing: 4

                    Text {

                        text: modelData.vehicle

                        font.pixelSize: 18
                        font.bold: true
                    }

                    Text {

                        text: "₹"
                              + modelData.fare

                        font.pixelSize: 15

                        color: "#555555"
                    }
                }

                Item {
                    width: 40
                    height: 1
                }

                Text {

                    anchors.verticalCenter:
                            parent.verticalCenter

                    text: "ETA "
                          + modelData.eta
                          + " min"

                    font.pixelSize: 15

                    color: "#333333"
                }
            }

            MouseArea {

                anchors.fill: parent

                onClicked: {

                    console.log(
                        modelData.vehicle
                        + " selected"
                    )

                    appState.selectedVehicle =
                            modelData.vehicle

                    appState.selectedFare =
                            modelData.fare

                    appState.selectedEta =
                            modelData.eta

                    appState.selectedDistance =
                            rideData.distance

                    appStack.push(
                        Qt.resolvedUrl(
                            "../components/RoutePreview.qml"
                        ),
                        {
                            "appStack": appStack,
                            "appState": appState
                        }
                    )
                }
            }
        }
    }

    Button {

        width: 80
        height: 50

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.rightMargin: 20
        anchors.bottomMargin: 20

        z: 100

        background: Rectangle {

            color: "#E53935"

            radius: 25
        }

        onClicked: {

            appStack.push(
                Qt.resolvedUrl("SOSPage.qml"),
                {
                    "appStack": appStack
                }
            )
        }

        contentItem: Row {

            anchors.centerIn: parent

            spacing: 6

            Image {

                source:
                    "../../assets/icons/sos.png"

                width: 22
                height: 22

                fillMode:
                    Image.PreserveAspectFit

                smooth: true
            }

            Text {

                text: "SOS"

                color: "white"

                font.bold: true
                font.pixelSize: 16
            }
        }
    }
}