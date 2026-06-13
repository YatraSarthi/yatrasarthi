import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

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

            mapView.runJavaScript(
                "[selectedLat, selectedLon]",
                function(result) {

                    if (!result || result[0] === null) {
                        console.log("No location selected")
                        return
                    }

                    var lat = result[0]
                    var lon = result[1]

                    console.log("Selected:", lat, lon)

                    var coordinateText =
                            lat.toFixed(5)
                            + ", "
                            + lon.toFixed(5)

                    if (appState.activeSelection === "pickup") {

                        appState.pickupLocation =
                                coordinateText

                    } else {

                        appState.destinationLocation =
                                coordinateText
                    }

                    appStack.pop()
                }
            )
        }
    }
}