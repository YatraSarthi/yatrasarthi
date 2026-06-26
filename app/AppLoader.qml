import QtQuick 2.12
import QtQuick.Controls 2.12

ApplicationWindow {
    id: window
    visible: true
    width:   400
    height:  700
    title:   "YatraSarthi"

    StackView {
        id:           authStack
        anchors.fill: parent

        // Pass stackView + appLoader into Splash so it can navigate itself.
        // No Connections element needed — Splash drives the transition directly.
        Component.onCompleted: {
            authStack.push(
                Qt.resolvedUrl("auth/Splash.qml"),
                { "stackView": authStack, "appLoader": window }
            )
        }
    }

    // Called by Success.qml → launches the main ride app
    function openRideApp() {
        authStack.clear()
        authStack.push(
            Qt.resolvedUrl("RideApp.qml"),
            { "parentWindow": window }
        )
    }
}