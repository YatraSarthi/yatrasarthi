import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    property var rideData: null
    property string errorMessage: ""

    function fetchEstimate() {

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {

            if (xhr.readyState === XMLHttpRequest.DONE) {

                if (xhr.status === 200) {

                    rideData = JSON.parse(xhr.responseText)
                    errorMessage = ""

                } else {

                    errorMessage =
                            "Unable to fetch ride estimates"
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

    ScrollView {

        anchors.fill: parent

        Column {

            width: parent.width
            spacing: 20
            padding: 20

            Label {
                text: "Pickup:"
                font.bold: true
            }

            Label {
                text: appState.pickupLocation
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Destination:"
                font.bold: true
            }

            Label {
                text: appState.destinationLocation
                wrapMode: Text.WordWrap
            }

            Label {

                text: rideData
                      ? "Distance: "
                        + rideData.distance
                        + " km"
                      : "Calculating..."
            }

            Label {

                text: errorMessage

                visible: errorMessage !== ""
            }

            Frame {

                width: parent.width

                visible: rideData !== null

                Label {

                    anchors.centerIn: parent

                    text:
                        "🏍 Bike\n"
                        + "Fare: ₹"
                        + rideData.bike.fare
                        + "\nETA: "
                        + rideData.bike.eta
                        + " min"
                }
            }

            Frame {

                width: parent.width

                visible: rideData !== null

                Label {

                    anchors.centerIn: parent

                    text:
                        "🛺 Auto\n"
                        + "Fare: ₹"
                        + rideData.auto.fare
                        + "\nETA: "
                        + rideData.auto.eta
                        + " min"
                }
            }

            Frame {

                width: parent.width

                visible: rideData !== null

                Label {

                    anchors.centerIn: parent

                    text:
                        "🚕 Cab\n"
                        + "Fare: ₹"
                        + rideData.cab.fare
                        + "\nETA: "
                        + rideData.cab.eta
                        + " min"
                }
            }
        }
    }
}