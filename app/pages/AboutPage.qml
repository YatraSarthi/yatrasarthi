import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack

    Rectangle {
        anchors.fill: parent
        color: "#F5F7FA"

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Row {
                spacing: 12

                Button {
                    text: "←"

                    onClicked: {
                        appStack.pop()
                    }
                }

                Text {
                    text: "About YatraSarthi"
                    font.pixelSize: 24
                    font.bold: true
                }
            }

            Image {
                source: "../../assets/icons/yatrasarthi_logo.png"
                width: 120
                height: 120
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "YatraSarthi"
                font.pixelSize: 28
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "The Sarthi for Every Yatra"
                font.pixelSize: 14
                color: "#666666"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#DDDDDD"
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap

                text:
                    "YatraSarthi is a smart mobility platform designed to make everyday travel safer, simpler, and more reliable. Users can book rides, manage favourite destinations, access SOS emergency services, view ride history, and navigate efficiently through an intuitive interface."
            }

            Text {
                text: "Version 1.0.0"
                color: "#888888"
            }

            Text {
                text: "Developed by Team YatraSarthi"
                color: "#888888"
            }
        }
    }
}