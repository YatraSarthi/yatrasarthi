import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    property bool driverFound: false

    Timer {
        interval: 3000
        running: true
        repeat: false

        onTriggered: {
            driverFound = true
        }
    }

    Column {

        anchors.fill: parent
        spacing: 15

        /*
         * HEADER
         */

        Row {

            spacing: 10

            anchors.left: parent.left
            anchors.leftMargin: 10

            Button {

                text: "← Back"

                onClicked: {
                    appStack.pop()
                }
            }

            Label {

                text: driverFound
                      ? "Driver Found"
                      : "Searching Driver"

                font.pixelSize: 22
                font.bold: true

                anchors.verticalCenter: parent.verticalCenter
            }
        }

        /*
         * ROUTE MAP
         */

        Rectangle {

            width: parent.width
            height: 240

            border.color: "#D3D3D3"

            WebEngineView {

                id: bookingMap

                anchors.fill: parent

                url: Qt.resolvedUrl("../web/route.html")

                onLoadingChanged: {

                    if (loadRequest.status ===
                            WebEngineLoadRequest.LoadSucceededStatus) {

                        runJavaScript(
                            "setRoute("
                            + appState.pickupLat + ","
                            + appState.pickupLon + ","
                            + appState.destinationLat + ","
                            + appState.destinationLon
                            + ")"
                        )
                    }
                }
            }
        }

        /*
         * SEARCHING
         */

        BusyIndicator {

            visible: !driverFound
            running: !driverFound

            width: 60
            height: 60

            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {

            visible: !driverFound

            text: "Looking for nearby drivers..."

            anchors.horizontalCenter: parent.horizontalCenter

            font.pixelSize: 18
        }

        /*
         * DRIVER CARD
         */

        Rectangle {

            visible: driverFound

            width: parent.width - 20
            height: 180

            anchors.horizontalCenter: parent.horizontalCenter

            radius: 15

            color: "white"

            border.color: "#D3D3D3"
            border.width: 1

            Column {

                anchors.fill: parent
                anchors.margins: 15

                spacing: 10

                Label {

                    text: "Driver Found!"

                    font.pixelSize: 22
                    font.bold: true
                }

                Row {
    spacing: 8

    Image {
        source: "../../assets/icons/driver.png"
        width: 20
        height: 20
    }

    Label {
        text: "Agnik Haldar"
        font.pixelSize: 18
    }
}

                Row {
    spacing: 8

    Image {
        source: "../../assets/icons/star.png"
        width: 20
        height: 20
    }

    Label {
        text: "4.8 Rating"
        font.pixelSize: 18
    }
}

                Row {
    spacing: 8

    Image {
        source: "../../assets/icons/car_number.png"
        width: 20
        height: 20
    }

    Label {
        text: "KA 01 AB 1234"
        font.pixelSize: 18
    }
}

                Row {
    spacing: 8

    Image {
        source: "../../assets/icons/clock.png"
        width: 20
        height: 20
    }

    Label {
        text: "ETA: 3 min"
        font.pixelSize: 18
    }
}

                Rectangle {

                    width: parent.width
                    height: 1

                    color: "#E0E0E0"
                }
            }
        }

        Item {
            height: 10
        }

        /*
         * CONFIRM
         */

        /*
 * CONFIRM
 */

Button {

    visible: driverFound

    anchors.horizontalCenter: parent.horizontalCenter

    width: 160
    height: 42

    text: "Confirm Ride"

    onClicked: {

        /*
         * Reset driver simulation
         */

        var xhr = new XMLHttpRequest()

        xhr.open(
            "GET",
            "http://127.0.0.1:8000/reset-driver",
            false
        )

        xhr.send()

        console.log("Driver simulation reset")

        appStack.push(
            Qt.resolvedUrl("PickupPage.qml"),
            {
                "appStack": appStack,
                "appState": appState
            }
        )
    }
}    

        /*
         * CANCEL
         */

        Button {

            anchors.horizontalCenter: parent.horizontalCenter

            width: parent.width * 0.5
            height: 45

            text: "Cancel"

            onClicked: {
                appStack.pop()
            }
        }
    }
}