import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    property var rideHistory: []

    footer: null

    Component.onCompleted: {
        loadHistory()
    }

    // Reload every time this tab becomes visible
    onVisibleChanged: {
        if (visible) loadHistory()
    }

    function loadHistory() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE
                    && xhr.status === 200) {
                rideHistory = JSON.parse(xhr.responseText)
            }
        }
        xhr.open("GET",
            "http://127.0.0.1:8000/ride-history", true)
        xhr.send()
    }

    // Computed helpers
    function totalDistance() {
        var d = 0
        for (var i = 0; i < rideHistory.length; i++)
            d += rideHistory[i].distance || 0
        return Math.round(d)
    }

    function totalSpent() {
        var s = 0
        for (var i = 0; i < rideHistory.length; i++)
            s += rideHistory[i].fare || 0
        return s
    }

    function totalCo2() {
        var c = 0
        for (var i = 0; i < rideHistory.length; i++)
            c += rideHistory[i].co2Saved || 0
        return c.toFixed(1)
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {
            width: parent.width
            spacing: 0

            // ── Header ────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 65
                color: "#1976D2"

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    text: "Activity"
                    font.pixelSize: 22
                    font.bold: true
                    color: "white"
                }
            }

            Column {
                width: parent.width
                spacing: 16

                Item { width: 1; height: 12 }

                // ── Stats Card ────────────────────────────────────
                Rectangle {
                    x: 16
                    width: parent.width - 32
                    height: 140
                    radius: 14
                    color: "#1565C0"

                    // Subtle top-right circle decoration
                    Rectangle {
                        width: 120; height: 120
                        radius: 60
                        color: "#ffffff10"
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: -30
                        anchors.topMargin: -30
                    }

                    Grid {
                        anchors.fill: parent
                        anchors.margins: 20
                        columns: 2
                        rowSpacing: 18
                        columnSpacing: 0

                        Repeater {
                            model: [
                                { val: rideHistory.length + "",
                                  lbl: "Total Rides",
                                  icon: "🚕" },
                                { val: totalDistance() + " km",
                                  lbl: "Distance",
                                  icon: "📍" },
                                { val: "₹" + totalSpent(),
                                  lbl: "Money Spent",
                                  icon: "💳" },
                                { val: totalCo2() + " kg",
                                  lbl: "CO₂ Saved",
                                  icon: "🌱" }
                            ]
                            delegate: Row {
                                width: (parent.width) / 2
                                spacing: 8

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 18
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                }

                                Column {
                                    spacing: 1
                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    Label {
                                        text: modelData.val
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "white"
                                    }
                                    Label {
                                        text: modelData.lbl
                                        font.pixelSize: 10
                                        color: "#B3E5FC"
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Ride History label ────────────────────────────
                Label {
                    x: 16
                    text: "Ride History"
                    font.bold: true
                    font.pixelSize: 15
                    color: "#111"
                }

                // ── Empty state ───────────────────────────────────
                Rectangle {
                    x: 16
                    width: parent.width - 32
                    height: 90
                    visible: rideHistory.length === 0
                    radius: 14
                    color: "#F5F5F5"
                    border.color: "#E0E0E0"

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "🚗"
                            font.pixelSize: 28
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No rides yet"
                            color: "#999"
                            font.pixelSize: 14
                        }
                    }
                }

                // ── Ride cards ────────────────────────────────────
                Column {
                    x: 16
                    width: parent.width - 32
                    spacing: 10

                    Repeater {
                        model: rideHistory

                        delegate: Rectangle {
                            width: parent.width
                            height: 118
                            radius: 14
                            color: "white"
                            border.color: "#EEEEEE"

                            // Left colour accent bar
                            Rectangle {
                                width: 4
                                height: parent.height - 28
                                radius: 2
                                color: "#1976D2"
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                anchors.verticalCenter:
                                    parent.verticalCenter
                            }

                            Column {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 14
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 7

                                // Date + fare
                                Row {
                                    width: parent.width

                                    Label {
                                        text: modelData.date || ""
                                        font.pixelSize: 11
                                        color: "#AAA"
                                        width: parent.width - fareLabel.width
                                    }

                                    Label {
                                        id: fareLabel
                                        text: "₹" + (modelData.fare || 0)
                                        font.pixelSize: 15
                                        font.bold: true
                                        color: "#1976D2"
                                    }
                                }

                                // Pickup
                                Row {
                                    spacing: 8
                                    width: parent.width

                                    Rectangle {
                                        width: 8; height: 8
                                        radius: 4
                                        color: "#1976D2"
                                        anchors.verticalCenter:
                                            parent.verticalCenter
                                    }

                                    Label {
                                        text: modelData.pickup || ""
                                        font.pixelSize: 12
                                        color: "#333"
                                        width: parent.width - 16
                                        elide: Text.ElideRight
                                    }
                                }

                                // Destination
                                Row {
                                    spacing: 8
                                    width: parent.width

                                    Rectangle {
                                        width: 8; height: 8
                                        radius: 2
                                        color: "#E53935"
                                        anchors.verticalCenter:
                                            parent.verticalCenter
                                    }

                                    Label {
                                        text: modelData.destination || ""
                                        font.pixelSize: 12
                                        color: "#333"
                                        width: parent.width - 16
                                        elide: Text.ElideRight
                                    }
                                }

                                // Vehicle chip
                                Row {
                                    spacing: 8

                                    Rectangle {
                                        height: 22
                                        width: chipText.width + 16
                                        radius: 11
                                        color: "#E3F2FD"

                                        Label {
                                            id: chipText
                                            anchors.centerIn: parent
                                            text: modelData.vehicle
                                                  || "Cab"
                                            font.pixelSize: 11
                                            color: "#1976D2"
                                        }
                                    }

                                    Rectangle {
                                        height: 22
                                        width: distText.width + 16
                                        radius: 11
                                        color: "#F5F5F5"

                                        Label {
                                            id: distText
                                            anchors.centerIn: parent
                                            text: (modelData.distance
                                                   || 0) + " km"
                                            font.pixelSize: 11
                                            color: "#666"
                                        }
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