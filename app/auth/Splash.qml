import QtQuick
import QtQuick.Controls

Item {

    id: splash

    signal finished()

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {

            GradientStop {
                position: 0
                color: "#1976D2"
            }

            GradientStop {
                position: 1
                color: "#42A5F5"
            }
        }
    }

    Text {

        id: logo

        anchors.centerIn: parent

        text: "YatraSarthi"

        color: "white"

        font.pixelSize: 40

        font.bold: true

        opacity: 0

        scale: 0.5
    }

    NumberAnimation {

        target: logo

        property: "opacity"

        from: 0

        to: 1

        duration: 800

        running: true
    }

    NumberAnimation {

        target: logo

        property: "scale"

        from: 0.5

        to: 1

        duration: 800

        running: true
    }

    BusyIndicator {

        anchors.horizontalCenter: parent.horizontalCenter

        anchors.bottom: parent.bottom

        anchors.bottomMargin: 80

        running: true

        width: 50

        height: 50
    }

    Timer {

        interval: 2500

        running: true

        repeat: false

        onTriggered: splash.finished()
    }

}
