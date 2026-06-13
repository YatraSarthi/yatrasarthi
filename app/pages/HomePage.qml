import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var stack

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 15
        width: parent.width * 0.8

        Label {
            text: "YatraSarthi"
            font.pixelSize: 24
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
            Layout.alignment: Qt.AlignHCenter

            onClicked: {
                // Temporary mock location
                locationLabel.text =
                        "Current Location:\n" +
                        "Bengaluru, Karnataka\n" +
                        "12.9716, 77.5946"
            }
        }

        TextField {
            id: pickupField
            placeholderText: "Pickup Location"
            Layout.fillWidth: true
        }

        TextField {
            id: destinationField
            placeholderText: "Destination"
            Layout.fillWidth: true
        }

        Button {
            text: "Find Ride"
            Layout.alignment: Qt.AlignHCenter

            onClicked: {
                stack.push(Qt.resolvedUrl("ResultsPage.qml"))
            }
        }
    }
}