import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Rectangle {

    property var appState

    width: parent.width
    height: 220

    radius: 12

    color: "white"

    border.color: "#D3D3D3"
    border.width: 1

    Column {

        anchors.fill: parent
        anchors.margins: 10

        spacing: 8

        Label {
            text: "Route Preview"

            font.bold: true
            font.pixelSize: 16
        }

        WebEngineView {

            id: routeMap

            width: parent.width
            height: 170

            url: Qt.resolvedUrl("../web/route.html")

            onLoadingChanged: {

                if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {

                    runJavaScript(
                        "setRoute("
                        + appState.pickupLat + ","
                        + appState.pickupLon + ","
                        + appState.destinationLat + ","
                        + appState.destinationLon
                        + ");"
                    )
                }
            }
        }
    }
}