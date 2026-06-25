import QtQuick
import QtQuick.Controls

Button {

    id: control

    implicitWidth: 320
    implicitHeight: 58

    font.pixelSize: 16
    font.bold: true

    hoverEnabled: true

    background: Rectangle {

        id: bg

        radius: 18

        gradient: Gradient {

            GradientStop {
                position: 0
                color: control.down ? "#1565C0" : "#1976D2"
            }

            GradientStop {
                position: 1
                color: control.down ? "#1976D2" : "#42A5F5"
            }

        }

        border.width: 1
        border.color: "#5EA8FF"

        scale: control.down ? 0.97 : (control.hovered ? 1.02 : 1)

        Behavior on scale {
            NumberAnimation {
                duration: 120
            }
        }

        Rectangle {

            anchors.fill: parent

            anchors.margins: 1

            radius: parent.radius - 1

            color: "transparent"

            opacity: control.hovered ? 0.08 : 0

            Behavior on opacity {

                NumberAnimation {

                    duration: 150

                }

            }

        }

    }

    contentItem: Text {

        text: control.text

        color: "white"

        font: control.font

        horizontalAlignment: Text.AlignHCenter

        verticalAlignment: Text.AlignVCenter

    }

}