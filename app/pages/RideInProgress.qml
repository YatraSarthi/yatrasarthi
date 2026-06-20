import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    /*
     * Temporary values
     * Later from FastAPI
     */

    property int eta: 12
    property real remainingKm: 4.3

    property string driverName: "Agnik Haldar"
    property string vehicleNumber: "WB03AD7394"
    property real driverRating: 4.9

    property string destinationName:
        "REVA University"

    property string destinationAddress:
        "Kattigenahalli, Bengaluru"

    ScrollView {

        anchors.fill: parent

        Column {

            width: parent.width

            spacing: 12

            /*
             * HEADER
             */

            Rectangle {

                width: parent.width
                height: 60

                color: "white"

                Row {

                    anchors.fill: parent

                    anchors.margins: 10

                    spacing: 10

                    Button {

                        text: "←"

                        onClicked: {
                            appStack.pop()
                        }
                    }

                    Label {

                        text: "Ride In Progress"

                        font.pixelSize: 22
                        font.bold: true

                        anchors.verticalCenter:
                            parent.verticalCenter
                    }
                }
            }

            /*
             * MAP
             */

            Rectangle {

                width: parent.width - 20
                height: 280

                anchors.horizontalCenter:
                    parent.horizontalCenter

                radius: 15

                border.color: "#D3D3D3"

                WebEngineView {

                    anchors.fill: parent

                    url: Qt.resolvedUrl(
                        "../web/ride_status.html"
                    )
                }
            }

            /*
             * PROGRESS CARD
             */

            Rectangle {

                width: parent.width - 20
                height: 120

                anchors.horizontalCenter:
                    parent.horizontalCenter

                radius: 15

                color: "#1976D2"

                Column {

                    anchors.centerIn: parent

                    spacing: 8

                    Label {

                        text:
                            "Drop in "
                            + eta
                            + " min"

                        color: "white"

                        font.pixelSize: 24
                        font.bold: true
                    }

                    Label {

                        text:
                            remainingKm
                            + " km remaining"

                        color: "white"

                        font.pixelSize: 18
                    }
                }
            }

            /*
             * FARE CARD
             */

            Rectangle {

                width: parent.width - 20
                height: 80

                anchors.horizontalCenter:
                    parent.horizontalCenter

                radius: 15

                color: "white"

                border.color: "#D3D3D3"

                Row {

                    anchors.fill: parent

                    anchors.margins: 15

                    Label {

                        text: "Fare"

                        font.pixelSize: 18
                    }

                    Item {

                        width: 1

                        anchors.horizontalCenter:
                            parent.horizontalCenter
                    }

                    Label {

                        anchors.right:
                            parent.right

                        text:
                            "₹"
                            + appState.selectedFare

                        font.pixelSize: 28
                        font.bold: true
                    }
                }
            }

            /*
             * DRIVER CARD
             */

            Rectangle {

                width: parent.width - 20
                height: 150

                anchors.horizontalCenter:
                    parent.horizontalCenter

                radius: 15

                color: "white"

                border.color: "#D3D3D3"

                Row {

                    anchors.fill: parent

                    anchors.margins: 15

                    spacing: 15

                    Rectangle {

                        width: 80
                        height: 80

                        radius: 40

                        clip: true

                        Image {

                            anchors.fill: parent

                            source:
                                "../../assets/images/agnik.jpeg"

                            fillMode:
                                Image.PreserveAspectCrop
                        }
                    }

                    Column {

                        spacing: 5

                        Label {

                            text: driverName

                            font.pixelSize: 20
                            font.bold: true
                        }

                        Label {

                            text: vehicleNumber

                            font.pixelSize: 18
                        }

                        Label {

                            text:
                                "★★★★★ "
                                + driverRating

                            font.pixelSize: 16
                        }

                        Label {

                            text:
                                appState.selectedVehicle

                            color: "#555555"
                        }
                    }
                }
            }

            /*
             * DESTINATION CARD
             */

            Rectangle {

                width: parent.width - 20
                height: 110

                anchors.horizontalCenter:
                    parent.horizontalCenter

                radius: 15

                color: "white"

                border.color: "#D3D3D3"

                Column {

                    anchors.fill: parent

                    anchors.margins: 15

                    spacing: 5

                    Label {

                        text: "Destination"

                        color: "#555555"
                    }

                    Label {

                        text: destinationName

                        font.pixelSize: 20
                        font.bold: true
                    }

                    Label {

                        text:
                            destinationAddress
                    }
                }
            }

            /*
             * ACTION BUTTONS
             */

            Row {

                spacing: 10

                anchors.horizontalCenter:
                    parent.horizontalCenter

                Button {

                    text: "📞 Call"

                    onClicked: {

                        console.log(
                            "Call Driver"
                        )
                    }
                }

                Button {

                    text: "💬 Message"

                    onClicked: {

                        console.log(
                            "Message Driver"
                        )
                    }
                }

                Button {

                    text: "🚨 SOS"

                    onClicked: {

                        appStack.push(
                            Qt.resolvedUrl(
                                "SOSPage.qml"
                            ),
                            {
                                "appStack":
                                    appStack
                            }
                        )
                    }
                }
            }

            Item {

                height: 30
            }
        }
    }
}