import QtQuick

Item {

    anchors.fill: parent

    Rectangle {

        id: blob1

        width: 260
        height: 260

        radius: 130

        color: "#DCEEFF"

        opacity: 0.7

        x: -80
        y: -60

        SequentialAnimation on y {

            loops: Animation.Infinite

            NumberAnimation {

                from: -60
                to: -30

                duration: 3500

                easing.type: Easing.InOutQuad

            }

            NumberAnimation {

                from: -30
                to: -60

                duration: 3500

                easing.type: Easing.InOutQuad

            }

        }

    }

    Rectangle {

        id: blob2

        width: 180
        height: 180

        radius: 90

        color: "#CFE7FF"

        opacity: 0.55

        anchors.right: parent.right

        anchors.top: parent.top

        anchors.rightMargin: -40

        anchors.topMargin: 180

        SequentialAnimation on x {

            loops: Animation.Infinite

            NumberAnimation {

                from: 0
                to: -20

                duration: 3000

                easing.type: Easing.InOutQuad

            }

            NumberAnimation {

                from: -20
                to: 0

                duration: 3000

                easing.type: Easing.InOutQuad

            }

        }

    }

    Rectangle {

        id: blob3

        width: 220
        height: 220

        radius: 110

        color: "#E8F4FF"

        opacity: 0.55

        anchors.bottom: parent.bottom

        anchors.left: parent.left

        anchors.leftMargin: -60

        anchors.bottomMargin: -60

        SequentialAnimation on x {

            loops: Animation.Infinite

            NumberAnimation {

                from: -60
                to: -20

                duration: 4000

                easing.type: Easing.InOutQuad

            }

            NumberAnimation {

                from: -20
                to: -60

                duration: 4000

                easing.type: Easing.InOutQuad

            }

        }

    }

}