import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property var rideData: null

    property string selectedVehicle: ""
    property int selectedFare: 0
    property int selectedEta: 0

    title: "Ride Preview"

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
                console.log("Estimate Response:", xhr.responseText)

                if (xhr.status === 200) {

                    rideData = JSON.parse(xhr.responseText)

                    selectedVehicle = "Bike"
                    selectedFare = rideData.bike.fare
                    selectedEta = rideData.bike.eta

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

        xhr.open("GET", url, true)
        xhr.send()
    }

    Component.onCompleted: {
        fetchEstimate()
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
            anchors.topMargin: 10

            Button {

                text: "← Back"

                onClicked: {
                    appStack.pop()
                }
            }

            Label {

                text: "Ride Preview"

                font.pixelSize: 20
                font.bold: true

                anchors.verticalCenter: parent.verticalCenter
            }
        }

        /*
         * ROUTE MAP
         */

        Rectangle {

            width: parent.width
            height: 220

            border.color: "#D3D3D3"

            WebEngineView {

                anchors.fill: parent

                url: Qt.resolvedUrl("../web/route.html")
            }
        }

        /*
         * VEHICLES
         */

        ListView {

            width: parent.width
            height: 280

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

                width: ListView.view.width - 20
                height: 90

                x: 10

                radius: 12

                color: selectedVehicle === modelData.vehicle
                       ? "#E8F5E9"
                       : "white"

                border.color: selectedVehicle === modelData.vehicle
                               ? "#4CAF50"
                               : "#D3D3D3"

                border.width: 2

                scale: 1.0

                Behavior on scale {

                    NumberAnimation {
                        duration: 150
                    }
                }

                Row {

                    anchors.fill: parent
                    anchors.margins: 15

                    spacing: 20

                    Image {

                        source: getVehicleIcon(modelData.vehicle)

                        width: 48
                        height: 48

                        fillMode: Image.PreserveAspectFit
                    }

                    Column {

                        spacing: 5

                        anchors.verticalCenter: parent.verticalCenter

                        Text {

                            text: modelData.vehicle

                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {

                            text: "ETA " + modelData.eta + " min"

                            color: "#555555"
                        }
                    }

                    Item {
                        width: 80
                    }

                    Text {

                        anchors.verticalCenter: parent.verticalCenter

                        text: "₹" + modelData.fare

                        font.pixelSize: 22
                        font.bold: true
                    }
                }

                MouseArea {

                    anchors.fill: parent

                    hoverEnabled: true

                    onEntered: {
                        parent.scale = 1.03
                    }

                    onExited: {

                        if (selectedVehicle !== modelData.vehicle)
                            parent.scale = 1.0
                    }

                    onClicked: {

                        selectedVehicle = modelData.vehicle
                        selectedFare = modelData.fare
                        selectedEta = modelData.eta

                        console.log(selectedVehicle + " selected")
                    }
                }
            }
        }

        /*
         * CHOOSE BUTTON
         */

        Button {

            anchors.horizontalCenter: parent.horizontalCenter

            width: parent.width * 0.7
            height: 50

            text: "Choose " + selectedVehicle

            enabled: selectedVehicle !== ""

            onClicked: {

                console.log("Vehicle chosen:")
                console.log(selectedVehicle)
                console.log(selectedFare)
                console.log(selectedEta)

                /*
                 * BookingPage comes next
                 */
            }
        }
    }

    /*
     * SOS
     */

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

                source: "../../assets/icons/sos.png"

                width: 22
                height: 22

                fillMode: Image.PreserveAspectFit
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