import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var appStack
    property var appState

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 18

        Label {
            text: "YatraSarthi"

            font.pixelSize: 24
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#d0d0d0"
        }

        /*
         * PICKUP
         */

        Label {
            text: "📍 Pickup"
            font.bold: true
        }

        TextField {
            Layout.fillWidth: true

            readOnly: true

            text: appState.pickupLocation

            placeholderText: "Current Location"
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8

            Button {
                text: "📡 My Location"

                onClicked: {
                    // Temporary demo value
                    appState.pickupLocation =
                            "Bengaluru, Karnataka"

                    // Later:
                    // GPS → FastAPI → reverse-geocode
                }
            }

            Button {
                text: "🗺 Map"

                onClicked: {

                    appState.activeSelection = "pickup"

                    appStack.push(
                        Qt.resolvedUrl("MapPage.qml"),
                        {
                            "appStack": appStack,
                            "appState": appState
                        }
                    )
                }
            }
        }

        /*
         * DESTINATION
         */

        Label {
            text: "🏁 Destination"
            font.bold: true
        }

        TextField {
            Layout.fillWidth: true

            readOnly: true

            text: appState.destinationLocation

            placeholderText: "Where to?"
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight

            Button {
                text: "🗺 Map"

                onClicked: {

                    appState.activeSelection = "destination"

                    appStack.push(
                        Qt.resolvedUrl("MapPage.qml"),
                        {
                            "appStack": appStack,
                            "appState": appState
                        }
                    )
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        /*
         * FIND RIDE
         */

        Button {
            text: "🚕 Find Ride"

            Layout.fillWidth: true
            Layout.preferredHeight: 50

            font.pixelSize: 16

            onClicked: {

                if (appState.pickupLocation === ""
                        || appState.destinationLocation === "") {

                    console.log("Select both locations")

                    return
                }

                appStack.push(
                    Qt.resolvedUrl("ResultsPage.qml"),
                    {
                        "appStack": appStack,
                        "appState": appState
                    }
                )
            }
        }
    }
}