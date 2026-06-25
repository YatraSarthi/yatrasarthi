import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

Page {

    id: page

    property var stackView
    property var appLoader

    background: Item {

        Rectangle {

            anchors.fill: parent

            gradient: Gradient {

                GradientStop {
                    position: 0.0
                    color: "#F9FCFF"
                }

                GradientStop {
                    position: 1.0
                    color: "#EAF3FD"
                }

            }

        }

        FloatingBackground {

            anchors.fill: parent

        }

    }

    Column {

        anchors.fill: parent
        anchors.margins: 28

        spacing: 28

        opacity: 0
        y: 40

        Behavior on opacity {

            NumberAnimation {

                duration: 700

            }

        }

        Behavior on y {

            NumberAnimation {

                duration: 700

                easing.type: Easing.OutCubic

            }

        }

        Component.onCompleted: {

            opacity = 1
            y = 0

        }

        Item {

            height: 20

        }

        Image {

            source: "../assets/icons/logo.jpeg"

            width: 90
            height: 90

            fillMode: Image.PreserveAspectFit

            anchors.horizontalCenter: parent.horizontalCenter

        }

        Text {

            text: "YatraSarthi"

            font.pixelSize: 30

            font.bold: true

            color: "#1976D2"

            anchors.horizontalCenter: parent.horizontalCenter

        }

        Text {

            text: "Welcome Back"

            font.pixelSize: 24

            font.bold: true

            color: "#202124"

            anchors.horizontalCenter: parent.horizontalCenter

        }

        Text {

            text: "Sign in using your mobile number"

            color: "#667085"

            font.pixelSize: 14

            anchors.horizontalCenter: parent.horizontalCenter

        }

        Rectangle {

            width: parent.width

            height: 300

            radius: 24

            color: "white"

            border.color: "#E4EAF2"

            layer.enabled: true

            Rectangle {

                anchors.fill: parent

                anchors.leftMargin: 8
                anchors.topMargin: 8

                radius: 24

                color: "#D6E7F8"

                opacity: 0.35

                z: -1

            }

            Column {

                anchors.fill: parent

                anchors.margins: 24

                spacing: 18

                Text {

                    text: "Mobile Number"

                    color: "#667085"

                    font.pixelSize: 14

                }

                AppTextField {

                    id: phoneField

                    width: parent.width

                    showLeading: true

                    leadingText: "+91"

                    placeholderText: "9876543210"

                }

                Text {

                    id: errorText

                    width: parent.width

                    color: "#E53935"

                    font.pixelSize: 13

                    wrapMode: Text.WordWrap

                }

                AppButton {

                    width: parent.width

                    text: "Send OTP"

                    onClicked: {

                        let phone = phoneField.text.trim()

                        errorText.text = ""

                         if (phone === "") {

                             errorText.text = "Please enter your mobile number."

                             phoneField.forceActiveFocus()

                             return

                        }

                            if (!/^[0-9]{10}$/.test(phone)) {

                                 errorText.text = "Please enter a valid mobile number."

                                phoneField.forceActiveFocus()

                                return

                            }

                             let response = JSON.parse(
                                backend.sendLoginOTP(phone)
                             )

                             if (!response.success) {

                                 errorText.text = response.message

                                return

                             }

                             stackView.push(
                                Qt.resolvedUrl("OTP.qml"),
                                {
                                    stackView: stackView,
                                    phoneNumber: "+91 " + phone,
                                    isLogin: true,
                                    appLoader: appLoader
                                }           
                            )

                        }
                }

            }

        }

        Item {

            height: 10

        }

        Row {

            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 5

            Text {

                text: "New User?"

                color: "#667085"

                font.pixelSize: 14

            }

            Text {

                text: "Create Account"

                color: "#1976D2"

                font.pixelSize: 14

                font.bold: true

                MouseArea {

                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {

                        stackView.push(
                            Qt.resolvedUrl("Register.qml"),
                            {
                                stackView: stackView,
                                appLoader: appLoader
                            }
                        )

                    }

                }

            }

        }

    }

}