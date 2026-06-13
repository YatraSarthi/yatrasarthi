import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.10

Page {

    header: ToolBar {
        Label {
            anchors.centerIn: parent
            text: "OpenStreetMap"
        }
    }

    WebEngineView {
        anchors.fill: parent

        url: Qt.resolvedUrl("../web/map.html")
    }
}