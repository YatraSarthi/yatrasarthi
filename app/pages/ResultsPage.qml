import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    property var rideData: null

    function fetchEstimate() {

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {

            if (xhr.readyState === XMLHttpRequest.DONE) {

                console.log("Estimate Status:", xhr.status)
                console.log("Estimate Response:", xhr.responseText)

                if (xhr.status === 200) {

                    rideData = JSON.parse(xhr.responseText)

                } else {

                    console.log("Estimate request failed")
                }
            }
        }

        xhr.open(
            "GET",
            "http://192.168.192.1:8000/estimate"
            + "?pickup_lat=" + appState.pickupLat
            + "&pickup_lon=" + appState.pickupLon
            + "&destination_lat=" + appState.destinationLat
            + "&destination_lon=" + appState.destinationLon,
            true
        )

        xhr.send()
    }

    Component.onCompleted: {
        fetchEstimate()
    }

    header: ToolBar {

        Row {

            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Button {
                text: "← Back"

                onClicked: {
                    appStack.pop()
                }
            }

            Label {
                text: "Ride Estimates"
            }
        }
    }

    Column {

        anchors.centerIn: parent
        spacing: 15

        Label {
            text: "Pickup:"
            font.bold: true
        }

        Label {
            text: appState.pickupLocation
        }

        Label {
            text: "Destination:"
            font.bold: true
        }

        Label {
            text: appState.destinationLocation
        }

        Label {

            text: rideData
                  ? "Distance: " + rideData.distance + " km"
                  : "Calculating..."
        }

        Label {

            visible: rideData !== null

            text:
                "🏍 Bike: ₹"
                + rideData.bike.fare
                + " • ETA "
                + rideData.bike.eta
                + " min"
        }

        Label {

            visible: rideData !== null

            text:
                "🛺 Auto: ₹"
                + rideData.auto.fare
                + " • ETA "
                + rideData.auto.eta
                + " min"
        }

        Label {

            visible: rideData !== null

            text:
                "🚕 Cab: ₹"
                + rideData.cab.fare
                + " • ETA "
                + rideData.cab.eta
                + " min"
        }
    }
}