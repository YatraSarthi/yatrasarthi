import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    title: "Available Rides"

    function getVehicleIcon(vehicle) {
        if (vehicle === "Bike")
            return "../../assets/icons/bike.png"
        else if (vehicle === "Auto")
            return "../../assets/icons/auto.png"
        else if (vehicle === "Cab")
            return "../../assets/icons/cab.png"

        return ""
    }

    ListView {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        model: [
            {
                "vehicle": "Bike",
                "fare": 164,
                "eta": 20
            },
            {
                "vehicle": "Auto",
                "fare": 251,
                "eta": 25
            },
            {
                "vehicle": "Cab",
                "fare": 381,
                "eta": 22
            }
        ]

        delegate: Rectangle {

            width: ListView.view.width
            height: 80

            radius: 12

            color: "#ffffff"

            border.color: "#dcdcdc"
            border.width: 1

            Row {

                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Image {

                    source: getVehicleIcon(modelData.vehicle)

                    width: 36
                    height: 36

                    fillMode: Image.PreserveAspectFit
                    smooth: true

                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {

                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        text: modelData.vehicle
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Text {
                        text: "₹" + modelData.fare
                        font.pixelSize: 15
                        color: "#555555"
                    }
                }

                Item {
                    width: 20
                }

                Text {

                    anchors.verticalCenter: parent.verticalCenter

                    text: "ETA " + modelData.eta + " min"

                    font.pixelSize: 15
                    color: "#333333"
                }
            }

            MouseArea {

                anchors.fill: parent

                onClicked: {
                    console.log(modelData.vehicle + " selected")
                }
            }
        }
    }
}