import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState
    property var rideHistory: []

    signal switchTab(int tabIndex)

    footer: null
    header: null

    readonly property bool dm: appState ? appState.darkMode : false
    readonly property color thBg:       dm ? "#121212" : "#FFFFFF"
    readonly property color thCard:     dm ? "#1E1E1E" : "#FFFFFF"
    readonly property color thBorder:   dm ? "#2C2C2C" : "#EEEEEE"
    readonly property color thText:     dm ? "#EEEEEE" : "#111111"
    readonly property color thTextSub:  dm ? "#888888" : "#AAAAAA"
    readonly property color thEmptyBg:  dm ? "#1A1A1A" : "#F5F5F5"
    readonly property color thChipBg:   dm ? "#1A2A3A" : "#E3F2FD"
    readonly property color thChipBg2:  dm ? "#2A2A2A" : "#F5F5F5"
    readonly property color thChipText2:dm ? "#AAAAAA" : "#666666"
    readonly property color thBackBtn:  dm ? "#1565C0" : "white"
    readonly property color thBackArrow:dm ? "white"   : "#1565C0"

    Component.onCompleted: { loadHistory() }

    onVisibleChanged: {
        if (visible) {
            if (appState) appState.showBottomBar = true
            loadHistory()
        }
    }

    function loadHistory() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200)
                rideHistory = JSON.parse(xhr.responseText)
        }
        xhr.open("GET", "http://127.0.0.1:8000/ride-history", true)
        xhr.send()
    }

    function totalDistance() { var d = 0; for (var i = 0; i < rideHistory.length; i++) d += rideHistory[i].distance || 0; return Math.round(d) }
    function totalSpent()    { var s = 0; for (var i = 0; i < rideHistory.length; i++) s += rideHistory[i].fare     || 0; return s }
    function totalCo2()      { var c = 0; for (var i = 0; i < rideHistory.length; i++) c += rideHistory[i].co2Saved || 0; return c.toFixed(1) }

    Rectangle { anchors.fill: parent; color: thBg }

    ScrollView {
        anchors.fill: parent; contentWidth: width; clip: true

        Column {
            width: parent.width; spacing: 0

            // ── Header ────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 65; color: "#1976D2"
                Rectangle {
                    id: backBtn; width: 36; height: 36; radius: 18; color: thBackBtn
                    anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { text: "‹"; font.pixelSize: 28; font.bold: true; color: thBackArrow; anchors.centerIn: parent; anchors.horizontalCenterOffset: -1 }
                    MouseArea { id: backBtnMouse; anchors.fill: parent; hoverEnabled: true; onClicked: switchTab(0) }
                }
                Label { anchors.verticalCenter: parent.verticalCenter; anchors.left: backBtn.right; anchors.leftMargin: 10; text: "Activity"; font.pixelSize: 22; font.bold: true; color: "white" }
            }

            Column {
                width: parent.width; spacing: 16

                Item { width: 1; height: 12 }

                // ── Stats card ────────────────────────────────────
                Rectangle {
                    x: 16; width: parent.width - 32; height: 140; radius: 14
                    color: "#1565C0"; clip: true
                    Rectangle { width: 130; height: 130; radius: 65; color: "#ffffff15"; anchors.right: parent.right; anchors.top: parent.top; anchors.rightMargin: -30; anchors.topMargin: -30 }
                    Grid {
                        anchors.fill: parent; anchors.margins: 20; columns: 2; rowSpacing: 16; columnSpacing: 0
                        Repeater {
                            model: [
                                { val: rideHistory.length + "",  lbl: "Total Rides" },
                                { val: totalDistance() + " km", lbl: "Distance" },
                                { val: "₹" + totalSpent(),      lbl: "Money Spent" },
                                { val: totalCo2() + " kg",      lbl: "CO2 Saved" }
                            ]
                            delegate: Column {
                                width: parent.width / 2; spacing: 2
                                Label { text: modelData.val; font.pixelSize: 20; font.bold: true; color: "white" }
                                Label { text: modelData.lbl; font.pixelSize: 10; color: "#B3E5FC" }
                            }
                        }
                    }
                }

                Label { x: 16; text: "Ride History"; font.bold: true; font.pixelSize: 15; color: thText }

                // Empty state
                Rectangle {
                    x: 16; width: parent.width - 32; height: 90
                    visible: rideHistory.length === 0
                    radius: 14; color: thEmptyBg; border.color: thBorder
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "No rides yet"; font.pixelSize: 15; color: thTextSub }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Book your first ride from Home"; font.pixelSize: 12; color: dm ? "#555555" : "#BBBBBB" }
                    }
                }

                // Ride cards
                Column {
                    x: 16; width: parent.width - 32; spacing: 10

                    Repeater {
                        model: rideHistory
                        delegate: Rectangle {
                            width: parent.width; height: 118; radius: 14
                            color: thCard; border.color: thBorder

                            Rectangle { width: 4; height: parent.height - 28; radius: 2; color: "#1976D2"; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter }

                            Column {
                                anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 14; anchors.topMargin: 12; anchors.bottomMargin: 12; spacing: 7

                                Row {
                                    width: parent.width
                                    Label { text: modelData.date || ""; font.pixelSize: 11; color: thTextSub; width: parent.width - fareLabel.width }
                                    Label { id: fareLabel; text: "₹" + (modelData.fare || 0); font.pixelSize: 15; font.bold: true; color: "#1976D2" }
                                }

                                Row {
                                    spacing: 8; width: parent.width
                                    Rectangle { width: 8; height: 8; radius: 4; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter }
                                    Label { text: modelData.pickup || ""; font.pixelSize: 12; color: thText; width: parent.width - 16; elide: Text.ElideRight }
                                }

                                Row {
                                    spacing: 8; width: parent.width
                                    Rectangle { width: 8; height: 8; radius: 2; color: "#E53935"; anchors.verticalCenter: parent.verticalCenter }
                                    Label { text: modelData.destination || ""; font.pixelSize: 12; color: thText; width: parent.width - 16; elide: Text.ElideRight }
                                }

                                Row {
                                    spacing: 8
                                    Rectangle {
                                        height: 22; width: chipTxt.width + 16; radius: 11; color: thChipBg
                                        Label { id: chipTxt; anchors.centerIn: parent; text: modelData.vehicle || "Cab"; font.pixelSize: 11; color: "#1976D2" }
                                    }
                                    Rectangle {
                                        height: 22; width: distTxt.width + 16; radius: 11; color: thChipBg2
                                        Label { id: distTxt; anchors.centerIn: parent; text: (modelData.distance || 0) + " km"; font.pixelSize: 11; color: thChipText2 }
                                    }
                                }
                            }
                        }
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }
}
