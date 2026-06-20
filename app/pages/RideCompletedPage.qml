import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    title: "Ride Completed"

    ScrollView {

        anchors.fill: parent

        clip: true

        Column {

            width: parent.width

            spacing: 10

            /*
             * HEADER
             */

            Row {

                spacing: 10

                anchors.left: parent.left

                anchors.leftMargin: 10

                Label {

                    text: "Ride Completed"

                    font.pixelSize: 22

                    font.bold: true
                }
            }

            /*
             * SUCCESS CARD
             */

            Rectangle {

                width: parent.width - 20
                height: 100

                anchors.horizontalCenter:
                    parent.horizontalCenter

                radius: 15

                color: "#4CAF50"

                Column {

                    anchors.centerIn: parent

                    spacing: 5

                    Label {

                        text: "Destination Reached"

                        color: "white"

                        font.pixelSize: 24

                        font.bold: true
                    }

                    Label {

                        text:
                            "Thank you for riding with YatraSarthi"

                        color: "white"

                        font.pixelSize: 16
                    }
                }
            }

            /*
             * RIDE DETAILS
             */

            Rectangle {

                width: parent.width - 20
                height: 240

                anchors.horizontalCenter:
                    parent.horizontalCenter

                radius: 15

                color: "white"

                border.color: "#D3D3D3"

                Column {

                    anchors.fill: parent

                    anchors.margins: 15

                    spacing: 12

                    Label {

                        text: "Ride Summary"

                        font.pixelSize: 20

                        font.bold: true
                    }

                    Label {

                        text:
                            "Pickup: "
                            + appState.pickupLocation

                        wrapMode: Text.WordWrap
                    }

                    Label {

                        text:
                            "Destination: "
                            + appState.destinationLocation

                        wrapMode: Text.WordWrap
                    }

                    Label {

                        text:
                            "Vehicle: "
                            + appState.selectedVehicle
                    }

                    Label {

                        text:
                            "Distance: "
                            + appState.selectedDistance
                            + " km"
                    }

                    Label {

                        text:
                            "Fare Paid: ₹"
                            + appState.selectedFare

                        font.bold: true
                    }
                }
            }

            /*
             * RATE SARTHI
             */

            Rectangle {

                width: parent.width - 20
                height: 140

                anchors.horizontalCenter:
                    parent.horizontalCenter

                radius: 15

                color: "#FFF8E1"

                border.color: "#FFD54F"

                Column {

                    anchors.centerIn: parent

                    spacing: 10

                    Label {

                        text: "Rate Your Sarthi"

                        font.pixelSize: 18

                        font.bold: true
                    }

                    Row {

                        spacing: 10

                        Repeater {

                            model: 5

                            Label {

                                text: "★"

                                font.pixelSize: 30

                                color: "#FFC107"
                            }
                        }
                    }
                }
            }

            /*
             * HOME BUTTON
             */

            Button {

                width: parent.width * 0.7

                height: 50

                anchors.horizontalCenter:
                    parent.horizontalCenter

                text: "Back To Home"

                onClicked: {

                    while(appStack.depth > 1)
                        appStack.pop()
                }
            }

            Item {

                height: 20
            }
        }
    }
}