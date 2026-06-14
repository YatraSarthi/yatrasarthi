import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    function fetchAddress(lat, lon) {

        console.log("fetchAddress:", lat, lon)

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {

            console.log(
                "readyState:",
                xhr.readyState,
                "status:",
                xhr.status
            )

            if (xhr.readyState === XMLHttpRequest.DONE) {

                var address =
                        lat.toFixed(5)
                        + ", "
                        + lon.toFixed(5)

                console.log("Response:", xhr.responseText)

                if (xhr.status === 200) {

                    try {

                        var data = JSON.parse(xhr.responseText)

                        if (data.address)
                            address = data.address

                    } catch(e) {

                        console.log("JSON Error:", e)
                    }
                }

                console.log("Final address:", address)

                if (appState.activeSelection === "pickup") {

                    appState.pickupLocation = address
                    appState.pickupLat = lat
                    appState.pickupLon = lon

                } else {

                    appState.destinationLocation = address
                    appState.destinationLat = lat
                    appState.destinationLon = lon
                }

                console.log("Popping...")

                appStack.pop()
            }
        }

        xhr.onerror = function() {

            console.log("XHR ERROR")

            if (appState.activeSelection === "pickup") {

                appState.pickupLocation =
                        lat.toFixed(5)
                        + ", "
                        + lon.toFixed(5)

                appState.pickupLat = lat
                appState.pickupLon = lon

            } else {

                appState.destinationLocation =
                        lat.toFixed(5)
                        + ", "
                        + lon.toFixed(5)

                appState.destinationLat = lat
                appState.destinationLon = lon
            }

            appStack.pop()
        }

        xhr.open(
            "GET",
            "http://192.168.192.1:8000/reverse-geocode"
            + "?lat=" + lat
            + "&lon=" + lon,
            true
        )

        xhr.send()

        console.log("XHR sent")
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
                text: appState.activeSelection === "pickup"
                      ? "Select Pickup"
                      : "Select Destination"

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    WebEngineView {
        id: mapView

        anchors.fill: parent

        url: Qt.resolvedUrl("../web/map.html")
    }

    Button {
        text: "Use Selected Location"

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20

        onClicked: {

            console.log("Use Selected Location pressed")

            mapView.runJavaScript(
                "[selectedLat, selectedLon]",

                function(result) {

                    console.log("JS returned:", result)

                    if (!result ||
                        result[0] === null ||
                        result[0] === undefined ||
                        result[1] === undefined) {

                        console.log("No location selected")
                        return
                    }

                    var lat = result[0]
                    var lon = result[1]

                    console.log("Selected coordinates:")
                    console.log(lat)
                    console.log(lon)

                    fetchAddress(lat, lon)
                }
            )
        }
    }
}