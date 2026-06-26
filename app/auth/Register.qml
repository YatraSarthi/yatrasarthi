import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../components"

Page {
    id: page

    property var stackView
    property var appLoader

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0; color: "#F9FCFF" }
            GradientStop { position: 1; color: "#EAF3FD" }
        }
    }

    Column {
        anchors.fill:    parent
        anchors.margins: 28
        spacing:         24

        Item { height: 15 }

        // Logo with emoji fallback (same pattern as Login / OTP)
        Image {
            id:       logoImg
            source:   "../../assets/icons/logo.png"
            width:    90; height: 90
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            visible:  status === Image.Ready
        }
        Text {
            visible:        logoImg.status !== Image.Ready
            text:           "🚖"
            font.pixelSize: 60
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Create Account"
            font.pixelSize: 30; font.bold: true; color: "#1976D2"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Register using your details"
            color: "#667085"; font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width; height: 470
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
                spacing:         16

                Text { text: "Full Name";  color: "#667085" }
                AppTextField {
                    id:              fullName
                    width:           parent.width
                    placeholderText: "John Doe"
                }

                Text { text: "Email Address"; color: "#667085" }
                AppTextField {
                    id:              emailField
                    width:           parent.width
                    placeholderText: "john@example.com"
                }

                Text { text: "Mobile Number"; color: "#667085" }
                AppTextField {
                    id:               phoneField
                    width:            parent.width
                    showLeading:      true
                    leadingText:      "+91"
                    placeholderText:  "9876543210"
                    inputMethodHints: Qt.ImhDigitsOnly
                }

                Text {
                    id:       errorText
                    width:    parent.width
                    color:    "#E53935"; font.pixelSize: 13
                    wrapMode: Text.WordWrap
                }

                AppButton {
                    width: parent.width
                    text:  "Send OTP"
                    onClicked: {
                        var name   = fullName.text.trim()
                        var mail   = emailField.text.trim()
                        var mobile = phoneField.text.trim()
                        errorText.text = ""

                        if (name === "") {
                            errorText.text = "Please enter your full name."
                            fullName.forceActiveFocus(); return
                        }

                        var emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
                        if (mail === "") {
                            errorText.text = "Please enter your email."
                            emailField.forceActiveFocus(); return
                        }
                        if (!emailRegex.test(mail)) {
                            errorText.text = "Please enter a valid email."
                            emailField.forceActiveFocus(); return
                        }

                        if (mobile === "") {
                            errorText.text = "Please enter your mobile number."
                            phoneField.forceActiveFocus(); return
                        }
                        if (!/^[0-9]{10}$/.test(mobile)) {
                            errorText.text = "Please enter a valid 10-digit mobile number."
                            phoneField.forceActiveFocus(); return
                        }

                        // Guard — will never fire once launcher.py injects the bridge
                        if (typeof backend === "undefined" || backend === null) {
                            errorText.text = "Backend not connected. Please restart the app."
                            return
                        }

                        var response = JSON.parse(
                            backend.registerUser(name, mail, mobile)
                        )
                        if (!response.success) {
                            errorText.text = response.message; return
                        }

                        stackView.push(
                            Qt.resolvedUrl("OTP.qml"),
                            {
                                "stackView":   stackView,
                                "appLoader":   appLoader,
                                "phoneNumber": "+91 " + mobile,
                                "fullName":    name,
                                "email":       mail,
                                "isLogin":     false
                            }
                        )
                    }
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            Text { text: "Already have an account?"; color: "#667085" }

            Text {
                text: "Login"; color: "#1976D2"; font.bold: true
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    stackView.pop()
                }
            }
        }
    }
}