import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property int eta: appState.selectedEta
    property real remainingKm: 4.3
    property real currentSpeed: 32

    property string driverName: "Agnik Haldar"
    property string vehicleNumber: "WB03AD7394"
    property real driverRating: 4.8

    property string destinationName:
        appState.destinationName

    property string destinationAddress:
        appState.destinationAddress

 /*******************
 Auto Countdown
 *******************/


Timer {

    interval: 5000

    running: true

    repeat: true

    onTriggered: {

        if (eta > 0)
            eta--

        if (remainingKm > 0)
            remainingKm -= 0.5

        if (currentSpeed < 45)
            currentSpeed += 1

        if (eta <= 0) {

            stop()

            appStack.push(
                Qt.resolvedUrl(
                    "RideCompletedPage.qml"
                ),
                {
                    "appStack": appStack,
                    "appState": appState
                }
            )
        }
    }
}
/********************
#Header
*********************/

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

            font.pixelSize: 24
            font.bold: true

            anchors.verticalCenter:
                parent.verticalCenter
        }
    }
}
/*******************
 Map Section
 *******************/
Rectangle {

    width: parent.width
    height: 280

    WebEngineView {

        anchors.fill: parent

        url: Qt.resolvedUrl(
            "../web/RideInProgressMap.html"
        )
    }
}
/*******************
 Drop Banner
 *******************/

Rectangle {

    width: parent.width - 20
    height: 100

    anchors.horizontalCenter:
        parent.horizontalCenter

    radius: 15

    color: "#1976D2"

    Row {

        anchors.centerIn: parent

        spacing: 60

        Column {

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
                    remainingKm.toFixed(1)
                    + " km left"

                color: "white"
            }
        }

        Column {

            Label {

                text:
                    currentSpeed
                    + " km/h"

                color: "white"

                font.pixelSize: 24
                font.bold: true
            }

            Label {

                text: "Current Speed"

                color: "white"
            }
        }
    }
}
/*******************
 Destination Card
 *******************/

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

            color: "#666666"
        }

        Label {

            text: destinationName

            font.pixelSize: 22

            font.bold: true
        }

        Label {

            text: destinationAddress

            wrapMode: Text.WordWrap
        }
    }
}
/*******************
 Fare Card
 *******************/

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
            width: 150
        }

        Label {

            text:
                "₹"
                + appState.selectedFare

            font.pixelSize: 28
            font.bold: true
        }
    }
}
/*******************
 Driver Card
 *******************/

Rectangle {

    width: parent.width - 20
    height: 180

    anchors.horizontalCenter:
        parent.horizontalCenter

    radius: 15

    color: "white"

    border.color: "#D3D3D3"

    Row {

        anchors.fill: parent
        anchors.margins: 15

        spacing: 15

        Image {

            source:
                "../../assets/images/agnik.jpeg"

            width: 90
            height: 90

            fillMode:
                Image.PreserveAspectCrop
        }

        Column {

            spacing: 5

            Label {

                text: driverName

                font.pixelSize: 22
                font.bold: true
            }

            Label {

                text: vehicleNumber
            }

            Label {

                text:
                    "★ "
                    + driverRating
            }

            Label {

                text:
                    appState.selectedVehicle
            }
        }
    }
}
/*******************
 Call + Message Buttons
 *******************/

Row {

    spacing: 15

    anchors.horizontalCenter:
        parent.horizontalCenter

    Button {

        text: "📞 Call"
    }

    Button {

        text: "💬 Message"
    }
}
/*******************
 Trip Progress
 *******************/

Rectangle {

    width: parent.width - 20
    height: 100

    anchors.horizontalCenter:
        parent.horizontalCenter

    radius: 15

    color: "white"

    border.color: "#D3D3D3"

    Row {

        anchors.centerIn: parent

        spacing: 40

        Label {
            text: "✓ Pickup"
        }

        Label {
            text: "✓ On Trip"
        }

        Label {
            text:
                eta <= 3
                ? "✓ Near Destination"
                : "Near Destination"
        }

        Label {
            text: "Completed"
        }
    }
}

/*******************
 sos button
 *******************/
Button {

    width: 200
    height: 50

    anchors.horizontalCenter:
        parent.horizontalCenter

    text: "🚨 SOS"

    background: Rectangle {

        color: "#E53935"

        radius: 10
    }
}
}