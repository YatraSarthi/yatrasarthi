import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: snackbar

    property string message: ""
    property bool   isError: false

    function show(msg, error) {
        message  = msg || ""
        isError  = error || false
        visible  = true
        hideTimer.restart()
    }

    visible:       false
    width:         Math.min(parent.width - 32, 340)
    height:        48
    radius:        12
    color:         isError ? "#E53935" : "#323232"
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 24
    z: 9999

    Text {
        anchors.centerIn: parent
        text:           snackbar.message
        color:          "white"
        font.pixelSize: 14
        width:          parent.width - 24
        horizontalAlignment: Text.AlignHCenter
        wrapMode:       Text.WordWrap
    }

    Timer {
        id:       hideTimer
        interval: 3000
        repeat:   false
        onTriggered: snackbar.visible = false
    }

    Behavior on visible {
        NumberAnimation { duration: 200 }
    }
}