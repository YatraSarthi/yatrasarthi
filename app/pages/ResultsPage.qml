import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack

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

    ListView {

        anchors.fill: parent
        anchors.margins: 10

        spacing: 10
        clip: true

        model: [
            {
                "vehicle": "Bike",
                "fare": 75,
                "eta": 7
            },
            {
                "vehicle": "Auto",
                "fare": 117,
                "eta": 8
            },
            {
                "vehicle": "Cab",
                "fare": 160,
                "eta": 6
            }
        ]

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

                    source: getVehicleIcon(modelData.vehicle)

                    width: 36
                    height: 36

                    anchors.verticalCenter: parent.verticalCenter

                    fillMode: Image.PreserveAspectFit
                    smooth: true
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
                    width: 40
                    height: 1
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

                    console.log(
                        modelData.vehicle + " selected"
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

                source: "../../assets/icons/sos.png"

                width: 22
                height: 22

                fillMode: Image.PreserveAspectFit

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