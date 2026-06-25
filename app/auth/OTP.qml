import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

Page {

    id: page

    property var stackView
    property var appLoader

    property string phoneNumber: ""
    property bool isLogin: true

    property string fullName: ""
    property string email: ""

    background: Rectangle {

        gradient: Gradient {

            GradientStop {
                position: 0
                color: "#F9FCFF"
            }

            GradientStop {
                position: 1
                color: "#EAF3FD"
            }

        }

    }

    Timer {

        id: timer

        interval: 1000

        repeat: true

        running: true

        property int seconds: 30

        onTriggered: {

            if (seconds > 0)
                seconds--
            else
                stop()

        }

    }

    Column {

        anchors.centerIn: parent

        width: 340

        spacing: 24

        Image {

            source: "../assets/icons/logo.jpeg"

            width: 90
            height: 90

            fillMode: Image.PreserveAspectFit

            anchors.horizontalCenter: parent.horizontalCenter

        }

        Text {

            text: "Verify OTP"

            font.pixelSize: 28

            font.bold: true

            color: "#1976D2"

            anchors.horizontalCenter: parent.horizontalCenter

        }

        Text {

            text: "OTP sent to"

            color: "#667085"

            anchors.horizontalCenter: parent.horizontalCenter

        }

        Text {

            text: phoneNumber

            font.bold: true

            anchors.horizontalCenter: parent.horizontalCenter

        }

        Row {

            spacing: 10

            anchors.horizontalCenter: parent.horizontalCenter

            OTPDigit {

                id: d1

                onMoveNext: d2.forceActiveFocus()

            }

            OTPDigit {

                id: d2

                onMoveNext: d3.forceActiveFocus()

                onMovePrevious: d1.forceActiveFocus()

            }

            OTPDigit {

                id: d3

                onMoveNext: d4.forceActiveFocus()

                onMovePrevious: d2.forceActiveFocus()

            }

            OTPDigit {

                id: d4

                onMoveNext: d5.forceActiveFocus()

                onMovePrevious: d3.forceActiveFocus()

            }

            OTPDigit {

                id: d5

                onMoveNext: d6.forceActiveFocus()

                onMovePrevious: d4.forceActiveFocus()

            }

            OTPDigit {

                id: d6

                onMovePrevious: d5.forceActiveFocus()

            }

        }

        Text {

            id: errorText

            width: parent.width

            horizontalAlignment: Text.AlignHCenter

            color: "#E53935"

            font.pixelSize: 13

            wrapMode: Text.WordWrap

        }

        Text {

            anchors.horizontalCenter: parent.horizontalCenter

            text: "00:" + (timer.seconds < 10 ? "0" : "") + timer.seconds

            font.pixelSize: 18

            font.bold: true

            color: "#1976D2"

        }

        Text {

            anchors.horizontalCenter: parent.horizontalCenter

            text: timer.seconds === 0 ? "Resend OTP" : "Didn't receive OTP?"

            color: timer.seconds === 0 ? "#1976D2" : "#667085"

            font.bold: timer.seconds === 0

            MouseArea {

                anchors.fill: parent

                enabled: timer.seconds === 0

                cursorShape: Qt.PointingHandCursor

                onClicked: {

                    let phone = phoneNumber.replace("+91 ", "").trim()

                    let response = JSON.parse(
                       backend.resendOTP(phone)
                    )

                    if (!response.success) {

                       errorText.text = response.message
                        return

                    }   

                    timer.seconds = 30
                    timer.start()

                    errorText.text = ""

                    d1.text = ""
                    d2.text = ""
                    d3.text = ""
                    d4.text = ""
                    d5.text = ""
                    d6.text = ""

                    d1.forceActiveFocus()

                }

            }

        }

        AppButton {

            width: parent.width

            text: "Verify OTP"

            onClicked: {

                errorText.text = ""

                let otp =
                        d1.text +
                        d2.text +
                        d3.text +
                        d4.text +
                        d5.text +
                        d6.text

                if (otp.length !== 6) {

                    errorText.text = "Please enter the complete 6-digit OTP."

                    d1.forceActiveFocus()

                    return

                }

                let phone = phoneNumber.replace("+91 ", "").trim()

                let response = JSON.parse(
                    backend.verifyOTP(
                        phone,
                        otp
                    )
                )

                if (!response.success) {

                    errorText.text = response.message

                    return

                }

                stackView.push(
                    Qt.resolvedUrl("Success.qml"),
                    {
                        stackView: stackView,
                        appLoader: appLoader
                    }
                )

            }

        }

    }

    Component.onCompleted: {

        d1.forceActiveFocus()

    }

}