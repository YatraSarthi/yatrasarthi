import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack

    title: "Emergency SOS"

    Column {
        anchors.centerIn: parent
        spacing: 20

        Label {
            text: "🚨 Emergency SOS"
            font.pixelSize: 24
            font.bold: true
        }

        Label {
            text: "Send emergency alert to saved contacts."
            horizontalAlignment: Text.AlignHCenter
        }

        Button {
            text: "Send SOS"

            onClicked: {
                console.log("SOS Triggered")
            }
        }

        Button {
            text: "Back"

            onClicked: {
                appStack.pop()
            }
        }
    }
}