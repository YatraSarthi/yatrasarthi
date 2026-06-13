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
}