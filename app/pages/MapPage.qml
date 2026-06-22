import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    // Poll until geocoding finishes, then commit and pop
    function commitSelection() {
        mapView.runJavaScript("JSON.stringify(getSelection())", function(raw) {
            if (!raw) { console.log("getSelection() returned nothing"); return }

            var sel
            try { sel = JSON.parse(raw) } catch(e) { console.log("Parse error:", e); return }

            if (sel.lat === null || sel.lat === undefined) {
                console.log("No pin placed yet"); return
            }

            if (sel.pending) {
                // Geocode still in flight — retry in 400 ms
                retryTimer.start()
                return
            }

            var shortAddr = sel.short || (sel.lat.toFixed(5) + ", " + sel.lon.toFixed(5))
            var fullAddr  = sel.full  || shortAddr

            if (appState.activeSelection === "pickup") {
                appState.pickupLocation    = shortAddr
                appState.pickupFullAddress = fullAddr
                appState.pickupLat         = sel.lat
                appState.pickupLon         = sel.lon
            } else {
                appState.destinationLocation    = shortAddr
                appState.destinationFullAddress = fullAddr
                appState.destinationLat         = sel.lat
                appState.destinationLon         = sel.lon
            }

            if (appStack.depth > 1) appStack.pop()
        })
    }

    Timer {
        id: retryTimer
        interval: 400
        repeat: false
        onTriggered: commitSelection()
    }

    header: ToolBar {
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            Button {
                text: "← Back"
                onClicked: { if (appStack.depth > 1) appStack.pop() }
            }
            Label {
                text: appState.activeSelection === "pickup"
                      ? "Select Pickup" : "Select Destination"
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
        onClicked: commitSelection()
    }
}