import QtQuick
import QtQuick.Controls

TextField {

    id: control

    property string leadingText: ""
    property bool showLeading: false

    implicitWidth: 320
    implicitHeight: 58

    font.pixelSize: 16

    color: "#202124"

    leftPadding: showLeading ? 65 : 18
    rightPadding: 18
    topPadding: 18
    bottomPadding: 18

    placeholderTextColor: "#98A2B3"

    background: Rectangle {

        radius: 18

        color: "white"

        border.width: control.activeFocus ? 2 : 1

        border.color: control.activeFocus
                      ? "#1976D2"
                      : "#D9E2EC"

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

        Rectangle {

            visible: control.showLeading

            width: 52

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            radius: 18

            color: "#EEF5FF"

            Text {

                anchors.centerIn: parent

                text: control.leadingText

                font.bold: true

                color: "#1976D2"

            }

        }

    }

    scale: activeFocus ? 1.01 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 120
        }
    }

}