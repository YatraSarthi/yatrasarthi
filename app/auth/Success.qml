import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

Page {
    id: page

    property var stackView
    property var appLoader

    background: Rectangle {
        color: "#F5F8FD"
    }

    Column {
        anchors.centerIn: parent
        spacing: 30

        Rectangle {
            width: 130
            height: 130
            radius: 65
            color: "#22C55E"

            Text {
                anchors.centerIn: parent
                text: "✓"
                color: "white"
                font.pixelSize: 72
                font.bold: true
            }
        }

        Text {
            text: "Verification Successful"
            font.pixelSize: 28
            font.bold: true
            color: "#202124"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            width: 300
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "Your mobile number has been verified successfully."
            color: "#6B7280"
            font.pixelSize: 15
        }

        AppButton {
            width: 300
            text: "Continue"

            onClicked: {
                appLoader.openRideApp()
            }
        }
    }
}