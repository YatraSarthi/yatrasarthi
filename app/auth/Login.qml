import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../components"

Page {
    id: page

    property var stackView
    property var appLoader

    background: Item {
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#F9FCFF" }
                GradientStop { position: 1.0; color: "#EAF3FD" }
            }
        }
        FloatingBackground { anchors.fill: parent }
    }

    Column {
        anchors.fill:    parent
        anchors.margins: 28
        spacing:         28
        opacity: 0
        y:       40

        Behavior on opacity { NumberAnimation { duration: 700 } }
        Behavior on y       { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }

        Component.onCompleted: { opacity = 1; y = 0 }

        Item { height: 20 }

        // Logo — falls back to the emoji header if the image file is missing
        Image {
            id:       logoImage
            source:   "../../assets/icons/logo.png"
            width:    90; height: 90
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            visible:  status === Image.Ready

            // Suppress the "Cannot open" warning in the console by handling the
            // error status quietly — QML still tries the path, this just hides
            // the visual gap when the file isn't there yet.
        }

        Text {
            visible: logoImage.status !== Image.Ready
            text:    "🚖"
            font.pixelSize: 60
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "YatraSarthi"
            font.pixelSize: 30; font.bold: true; color: "#1976D2"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Welcome Back"
            font.pixelSize: 24; font.bold: true; color: "#202124"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Sign in using your mobile number"
            color: "#667085"; font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width; height: 300
            radius: 24; color: "white"; border.color: "#E4EAF2"
            layer.enabled: true

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 8; anchors.topMargin: 8
                radius: 24; color: "#D6E7F8"; opacity: 0.35; z: -1
            }

            Column {
                anchors.fill:    parent
                anchors.margins: 24
                spacing:         18

                Text {
                    text: "Mobile Number"
                    color: "#667085"; font.pixelSize: 14
                }

                AppTextField {
                    id:              phoneField
                    width:           parent.width
                    showLeading:     true
                    leadingText:     "+91"
                    placeholderText: "9876543210"
                    inputMethodHints: Qt.ImhDigitsOnly
                }

                Text {
                    id:        errorText
                    width:     parent.width
                    color:     "#E53935"; font.pixelSize: 13
                    wrapMode:  Text.WordWrap
                }

                AppButton {
                    width: parent.width
                    text:  "Send OTP"
                    onClicked: {
                        var phone = phoneField.text.trim()
                        errorText.text = ""

                        if (phone === "") {
                            errorText.text = "Please enter your mobile number."
                            phoneField.forceActiveFocus()
                            return
                        }

                        if (!/^[0-9]{10}$/.test(phone)) {
                            errorText.text = "Please enter a valid 10-digit mobile number."
                            phoneField.forceActiveFocus()
                            return
                        }

                        // Guard: 'backend' is a context property set from Python.
                        // If it isn't registered yet, show a friendly error
                        // instead of crashing with "ReferenceError: backend is not defined".
                        if (typeof backend === "undefined" || backend === null) {
                            errorText.text = "Backend not connected. Please restart the app."
                            return
                        }

                        var response = JSON.parse(backend.sendLoginOTP(phone))

console.log("===================================")
console.log("SUCCESS RECEIVED")
console.log("Response =", JSON.stringify(response))
console.log("stackView =", stackView)
console.log("OTP FILE =", Qt.resolvedUrl("OTP.qml"))

if (!response.success) {
    console.log("OTP FAILED")
    errorText.text = response.message
    return
}

try {

    console.log("Before Push")

    stackView.push(
        Qt.resolvedUrl("OTP.qml"),
        {
            "stackView": stackView,
            "phoneNumber": "+91 " + phone,
            "isLogin": true,
            "appLoader": appLoader
        }
    )

    console.log("After Push")

} catch(err) {

    console.log("PUSH ERROR:", err)

}
                    }
                }
            }
        }

        Item { height: 10 }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            Text { text: "New User?"; color: "#667085"; font.pixelSize: 14 }

            Text {
                text: "Create Account"
                color: "#1976D2"; font.pixelSize: 14; font.bold: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        stackView.push(
                            Qt.resolvedUrl("Register.qml"),
                            { "stackView": stackView, "appLoader": appLoader }
                        )
                    }
                }
            }
        }
    }
}