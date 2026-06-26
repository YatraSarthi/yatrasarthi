import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    property string title:    "YatraSarthi"
    property string subtitle: ""

    width:  parent ? parent.width : 360
    height: 120

    Column {
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: "🚖"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 50
        }
        Text {
            text:           title
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 32; font.bold: true; color: "#1976D2"
        }
        Text {
            visible:        subtitle !== ""
            text:           subtitle
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15; color: "#6B7280"
        }
    }
}