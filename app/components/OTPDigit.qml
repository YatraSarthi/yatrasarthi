import QtQuick
import QtQuick.Controls

TextField {

    id: otpField

    signal moveNext()
    signal movePrevious()

    width: 48
    height: 58

    maximumLength: 1

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    font.pixelSize: 24
    font.bold: true

    color: "#202124"

    inputMethodHints: Qt.ImhDigitsOnly

    selectByMouse: true

    background: Rectangle {

        radius: 14

        color: "white"

        border.width: otpField.activeFocus ? 2 : 1

        border.color: otpField.activeFocus
                      ? "#1976D2"
                      : "#D8E2EC"

        Behavior on border.color {

            ColorAnimation {

                duration: 180

            }

        }

        Behavior on border.width {

            NumberAnimation {

                duration: 180

            }

        }

    }

    onTextChanged: {

        if (text.length === 1)
            moveNext()

    }

    Keys.onPressed: function(event) {

        if (event.key === Qt.Key_Backspace && text === "") {

            movePrevious()

            event.accepted = true

        }

    }

    MouseArea {

        anchors.fill: parent

        acceptedButtons: Qt.LeftButton

        onClicked: {

            otpField.forceActiveFocus()

        }

    }

}