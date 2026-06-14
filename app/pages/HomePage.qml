import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var appStack
    property var appState

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Label {
            text: "YatraSarthi"

            font.pixelSize: 26
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.preferredHeight: 20
        }

        /*
         * PICKUP
         */

        RowLayout {
            spacing: 8

            Image {
                source: "../../assets/icons/pickup.png"

                width: 22
                height: 22

                fillMode: Image.PreserveAspectFit
            }

            Label {
                text: "Pickup"

                font.bold: true
                font.pixelSize: 15
            }
        }

        TextField {
            Layout.fillWidth: true

            readOnly: true

            text: appState.pickupLocation

            placeholderText: "Select Pickup Location"
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 6

            Button {

                onClicked: {

                    appState.pickupLocation =
                            "Bengaluru, Karnataka"
                }

                contentItem: Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Image {
                        source: "../../assets/icons/my_location.png"

                        width: 16
                        height: 16

                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "Get My Location"

                        font.pixelSize: 13
                    }
                }
            }

            Button {

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

                contentItem: Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Image {
                        source: "../../assets/icons/map.png"

                        width: 16
                        height: 16

                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "Show Map"

                        font.pixelSize: 13
                    }
                }
            }
        }

        /*
         * DESTINATION
         */

        Item {
            Layout.preferredHeight: 10
        }

        RowLayout {
            spacing: 8

            Image {
                source: "../../assets/icons/destination.png"

                width: 22
                height: 22

                fillMode: Image.PreserveAspectFit
            }

            Label {
                text: "Destination"

                font.bold: true
                font.pixelSize: 15
            }
        }

        TextField {
            Layout.fillWidth: true

            readOnly: true

            text: appState.destinationLocation

            placeholderText: "Select Destination"
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight

            Button {

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

                contentItem: Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Image {
                        source: "../../assets/icons/map.png"

                        width: 16
                        height: 16

                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "Show Map"

                        font.pixelSize: 13
                    }
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

            Layout.alignment: Qt.AlignHCenter

            width: 140
            height: 45

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

            contentItem: Row {
                anchors.centerIn: parent
                spacing: 8

                Image {
                    source: "../../assets/icons/rider.png"

                    width: 30
                    height: 30

                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    text: "Find Ride"

                    font.pixelSize: 15
                    font.bold: true
                }
            }
        }

        Item {
            Layout.preferredHeight: 20
        }
    }
}
