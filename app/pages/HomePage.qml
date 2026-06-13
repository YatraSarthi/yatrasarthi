import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var navigationStack

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

        Button {
            text: "Show Map"

            onClicked: {
                navigationStack.push(
                    Qt.resolvedUrl("MapPage.qml")
                )
            }
        }

        TextField {
            placeholderText: "Pickup Location"
            Layout.fillWidth: true
        }

        TextField {
            placeholderText: "Destination"
            Layout.fillWidth: true
        }

        Button {
            text: "Find Ride"

            onClicked: {
                navigationStack.push(
                    Qt.resolvedUrl("ResultsPage.qml")
                )
            }
        }
    }
}