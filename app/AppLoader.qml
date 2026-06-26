import QtQuick
import QtQuick.Controls

ApplicationWindow {

    id: window

    visible: true
    width: 400
    height: 700
    title: "YatraSarthi"

    StackView {
        id: authStack
        anchors.fill: parent

        initialItem: "auth/Splash.qml"
    }

    Connections {
        target: authStack.currentItem

        function onFinished() {
            authStack.replace(
                Qt.resolvedUrl("auth/Login.qml"),
                {
                    stackView: authStack,
                    appLoader: window
                }
            )
        }
    }

    function openRideApp() {
        authStack.clear()
        authStack.push(Qt.resolvedUrl("Main.qml"))
    }
}