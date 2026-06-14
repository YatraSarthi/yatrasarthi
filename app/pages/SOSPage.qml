import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack

    property string statusMessage: ""
    property string contactsMessage: ""

    title: "Emergency SOS"

    function sendSOS() {

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {

            if (xhr.readyState === XMLHttpRequest.DONE) {

                console.log("SOS Status:", xhr.status)
                console.log("SOS Response:", xhr.responseText)

                if (xhr.status === 200) {

                    try {

                        var data =
                                JSON.parse(xhr.responseText)

                        statusMessage = data.status

                        contactsMessage =
                                data.contacts.join("\n")

                    } catch(e) {

                        console.log(
                            "SOS JSON Error:",
                            e
                        )

                        statusMessage =
                                "Invalid response"

                    }

                } else {

                    statusMessage =
                            "Failed to send SOS"
                }
            }
        }

        xhr.onerror = function() {

            console.log("SOS Request Failed")

            statusMessage =
                    "Unable to contact server"
        }

        xhr.open(
            "GET",
            "http://192.168.192.1:8000/sos",
            true
        )

        xhr.send()
    }

    Column {

        anchors.centerIn: parent

        spacing: 20

        width: parent.width * 0.8

        Label {

            text: "🚨 Emergency SOS"

            font.pixelSize: 24
            font.bold: true

            anchors.horizontalCenter:
                    parent.horizontalCenter
        }

        Label {

            text:
                "Press the button below to notify emergency contacts."

            wrapMode: Text.WordWrap

            width: parent.width
        }

        Button {

            text: "Send SOS"

            anchors.horizontalCenter:
                    parent.horizontalCenter

            onClicked: {

                sendSOS()
            }
        }

        Label {

            text: statusMessage

            color: "red"

            wrapMode: Text.WordWrap

            width: parent.width
        }

        Label {

            text:
                contactsMessage === ""
                ? ""
                : "Contacts notified:\n"
                  + contactsMessage

            wrapMode: Text.WordWrap

            width: parent.width
        }

        Button {

            text: "Back"

            anchors.horizontalCenter:
                    parent.horizontalCenter

            onClicked: {

                appStack.pop()
            }
        }
    }
}