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

                var shortAddress =
                        lat.toFixed(5) + ", " + lon.toFixed(5)

                var fullAddress = shortAddress

                console.log("Response:", xhr.responseText)

                if (xhr.status === 200) {

                    try {

                        var data = JSON.parse(xhr.responseText)

                        if (data.address)
                            shortAddress = data.address

                        if (data.full_address)
                            fullAddress = data.full_address

                    } catch(e) {

                        console.log("JSON Error:", e)
                    }
                }

                console.log("Short Address:", shortAddress)
                console.log("Full Address:", fullAddress)

                if (appState.activeSelection === "pickup") {

                    appState.pickupLocation = shortAddress
                    appState.pickupFullAddress = fullAddress

                    appState.pickupLat = lat
                    appState.pickupLon = lon

                } else {

                    appState.destinationLocation = shortAddress
                    appState.destinationFullAddress = fullAddress

                    appState.destinationLat = lat
                    appState.destinationLon = lon
                }

                console.log("Popping back to HomePage")

                if (appStack.depth > 1)
                    appStack.pop()
            }
        }

        xhr.onerror = function() {

            console.log("XHR ERROR")

            var fallback =
                    lat.toFixed(5) + ", " + lon.toFixed(5)

            if (appState.activeSelection === "pickup") {

                appState.pickupLocation = fallback
                appState.pickupFullAddress = fallback

                appState.pickupLat = lat
                appState.pickupLon = lon

            } else {

                appState.destinationLocation = fallback
                appState.destinationFullAddress = fallback

                appState.destinationLat = lat
                appState.destinationLon = lon
            }

            console.log("Popping back using fallback")

            if (appStack.depth > 1)
                appStack.pop()
        }

        xhr.open(
            "GET",
            "http://127.0.0.1:8000/reverse-geocode"
            + "?lat=" + lat
            + "&lon=" + lon,
            true
        )

        console.log("Sending reverse geocode request...")

        xhr.send()
    }

    header: ToolBar {

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Button {
                text: "← Back"

                onClicked: {
                    if (appStack.depth > 1)
                        appStack.pop()
                }
            }

            Label {

                text: appState.activeSelection === "pickup"
                      ? "Select Pickup"
                      : "Select Destination"

                anchors.verticalCenter: parent.verticalCenter

                font.bold: true
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
