import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var appStack
    property var appState

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 15
        width: parent.width * 0.85

        Label {
            text: "YatraSarthi"
            font.pixelSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            id: locationLabel

            text: "Current Location: Not fetched"

            wrapMode: Text.WordWrap

            Layout.fillWidth: true
        }

        Button {
            text: "Get My Location"

            onClicked: {
                locationLabel.text =
                        "Current Location:\n" +
                        "Bengaluru, Karnataka\n" +
                        "12.9716, 77.5946"
            }
        }

        /*
         * PICKUP
         */

        RowLayout {
            Layout.fillWidth: true

            TextField {
                Layout.fillWidth: true

                readOnly: true

                text: appState.pickupLocation

                placeholderText: "Pickup Location"
            }

            Button {
                text: "Show Map"

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

        RowLayout {
            Layout.fillWidth: true

            TextField {
                Layout.fillWidth: true

                readOnly: true

                text: appState.destinationLocation

                placeholderText: "Destination"
            }

            Button {
                text: "Show Map"

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

        Button {
            text: "Find Ride"

            Layout.alignment: Qt.AlignHCenter

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