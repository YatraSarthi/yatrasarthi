import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    property var appStack
    property var appState

    header: ToolBar {

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Button {
                text: "← Back"

                onClicked: {
                    appStack.pop()
                }
            }

            Label {
                text: appState.activeSelection === "pickup"
                      ? "Select Pickup"
                      : "Select Destination"

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    WebEngineView {
        anchors.fill: parent
        url: Qt.resolvedUrl("../web/map.html")
    }
    Button {
    text: "Use Mock Location"

    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 20

    onClicked: {
        if (appState.activeSelection === "pickup") {
            appState.pickupLocation = "Reva University, Bengaluru"
        } else {
            appState.destinationLocation = "Majestic, Bengaluru"
        }

        appStack.pop()
    }
}
}
