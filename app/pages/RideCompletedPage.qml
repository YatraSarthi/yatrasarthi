import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    // Hide bottom bar while on this page
    Component.onCompleted:  { if (appState) appState.showBottomBar = false }
    Component.onDestruction:{ if (appState) appState.showBottomBar = true  }

    // ── Haversine distance calculator ────────────────────────────────────────
    // Returns distance in km between two lat/lng points
    function haversineKm(lat1, lon1, lat2, lon2) {
        var R = 6371
        var dLat = (lat2 - lat1) * Math.PI / 180
        var dLon = (lon2 - lon1) * Math.PI / 180
        var a = Math.sin(dLat/2) * Math.sin(dLat/2)
                + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180)
                * Math.sin(dLon/2) * Math.sin(dLon/2)
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        return (R * c).toFixed(1)
    }

    // ── Computed properties ──────────────────────────────────────────────────
    // Distance: use stored value if valid, else compute from coordinates
    readonly property string computedDistance: {
        var d = parseFloat(appState ? appState.selectedDistance : 0)
        if (!isNaN(d) && d > 0)
            return d.toFixed(1) + " km"
        // Fallback: compute from lat/lng if available on appState
        if (appState && appState.pickupLat && appState.pickupLng
                     && appState.destinationLat && appState.destinationLng)
            return haversineKm(appState.pickupLat, appState.pickupLng,
                               appState.destinationLat, appState.destinationLng) + " km"
        return "N/A"
    }

    // CO₂ saved vs solo car (avg car emits ~0.21 kg CO₂/km; auto/shared ~0.06 kg/km)
    readonly property string computedCO2Saved: {
        var d = parseFloat(appState ? appState.selectedDistance : 0)
        if (isNaN(d) || d <= 0) return "–"
        var saved = (d * (0.21 - 0.06)).toFixed(2)
        return saved + " kg CO₂"
    }

    // Ride completed timestamp
    readonly property string rideDateTime: {
        var now = new Date()
        var days   = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        var hh = now.getHours()
        var mm = now.getMinutes().toString().padStart(2, "0")
        var ampm = hh >= 12 ? "PM" : "AM"
        hh = hh % 12 || 12
        return days[now.getDay()] + ", " + now.getDate() + " " + months[now.getMonth()]
               + " " + now.getFullYear() + "  " + hh + ":" + mm + " " + ampm
    }

    // ── Root background ──────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#F4F6F9"
    }

    // ── Floating header overlay ──────────────────────────────────────────────
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 52
        color:  "#CC000000"
        z:      10

        Row {
            anchors.fill:        parent
            anchors.leftMargin:  8
            anchors.rightMargin: 8
            spacing: 8

            Rectangle {
                width:  36; height: 36; radius: 18
                color:  "#33FFFFFF"
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: "←"; color: "white"; font.pixelSize: 18
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: { while (appStack.depth > 1) appStack.pop() }
                }
            }

            Label {
                text: "Ride Completed"; color: "white"
                font.pixelSize: 18; font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // ── Content ──────────────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        clip:         true
        contentWidth: availableWidth

        Column {
            width:         parent.width
            spacing:       0
            topPadding:    52
            bottomPadding: 24

            Column {
                width:        parent.width
                spacing:      10
                topPadding:   12
                leftPadding:  12
                rightPadding: 12

                // ── Success banner ────────────────────────────────────────────
                Rectangle {
                    width: parent.width; height: 100
                    radius: 14; color: "#4CAF50"

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Destination Reached"
                            color: "white"; font.pixelSize: 22; font.bold: true
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Thank you for riding with YatraSarthi"
                            color: "white"; font.pixelSize: 14
                        }
                    }
                }

                // ── Ride Summary card ─────────────────────────────────────────
                Rectangle {
                    width:        parent.width
                    height:       summaryCol.implicitHeight + 28
                    radius:       14
                    color:        "white"
                    border.color: "#E8E8E8"

                    Column {
                        id: summaryCol
                        anchors {
                            top: parent.top; left: parent.left; right: parent.right
                            topMargin: 14; leftMargin: 14; rightMargin: 14
                        }
                        spacing: 10

                        Label {
                            text: "Ride Summary"
                            font.pixelSize: 17; font.bold: true; color: "#1A1A1A"
                        }

                        // Pickup
                        Row {
                            spacing: 8; width: parent.width
                            Rectangle {
                                width: 8; height: 8; radius: 4; color: "#1976D2"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Label {
                                text: appState ? appState.pickupLocation : ""
                                font.pixelSize: 13; color: "#333"
                                wrapMode: Text.WordWrap
                                width: parent.width - 16; elide: Text.ElideRight
                            }
                        }

                        // Destination
                        Row {
                            spacing: 8; width: parent.width
                            Rectangle {
                                width: 8; height: 8; radius: 2; color: "#E53935"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Label {
                                text: appState ? appState.destinationLocation : ""
                                font.pixelSize: 13; color: "#333"
                                wrapMode: Text.WordWrap
                                width: parent.width - 16; elide: Text.ElideRight
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: "#F0F0F0" }

                        // ── Detail rows helper component ──────────────────────
                        // Vehicle
                        Row {
                            width: parent.width
                            Label { text: "Vehicle";  font.pixelSize: 13; color: "#888"; width: parent.width / 2 }
                            Label { text: appState ? appState.selectedVehicle : "–"; font.pixelSize: 13; color: "#1A1A1A"; font.bold: true }
                        }

                        // Distance  ← restored with computed value
                        Row {
                            width: parent.width
                            Label { text: "Distance"; font.pixelSize: 13; color: "#888"; width: parent.width / 2 }
                            Label { text: computedDistance;               font.pixelSize: 13; color: "#1A1A1A"; font.bold: true }
                        }

                        // Ride Duration
                        Row {
                            width: parent.width
                            Label { text: "Duration";  font.pixelSize: 13; color: "#888"; width: parent.width / 2 }
                            Label {
                                text: appState && appState.rideDurationMins
                                      ? appState.rideDurationMins + " mins"
                                      : "–"
                                font.pixelSize: 13; color: "#1A1A1A"; font.bold: true
                            }
                        }

                        // Date & Time
                        Row {
                            width: parent.width
                            Label { text: "Completed"; font.pixelSize: 13; color: "#888"; width: parent.width / 2 }
                            Label { text: rideDateTime; font.pixelSize: 12; color: "#1A1A1A"; font.bold: true; wrapMode: Text.WordWrap; width: parent.width / 2 }
                        }

                        Rectangle { width: parent.width; height: 1; color: "#F0F0F0" }

                        // Driver Name + Rating
                        Row {
                            width: parent.width
                            spacing: 0

                            Column {
                                width: parent.width / 2
                                spacing: 2
                                Label { text: "Driver";      font.pixelSize: 13; color: "#888" }
                                Label {
                                    text: appState && appState.driverName ? appState.driverName : "Your Sarthi"
                                    font.pixelSize: 13; color: "#1A1A1A"; font.bold: true
                                }
                            }

                            Column {
                                width: parent.width / 2
                                spacing: 2
                                Label { text: "Driver Rating"; font.pixelSize: 13; color: "#888" }
                                Row {
                                    spacing: 2
                                    Label {
                                        text: appState && appState.driverRating
                                              ? appState.driverRating.toFixed(1)
                                              : "4.8"
                                        font.pixelSize: 13; color: "#1A1A1A"; font.bold: true
                                    }
                                    Label { text: "★"; font.pixelSize: 13; color: "#FFC107" }
                                }
                            }
                        }
                    }
                }

                // ── 🌍 Carbon Footprint Saved card (novel idea) ───────────────
                Rectangle {
                    width:        parent.width
                    height:       ecoCol.implicitHeight + 20
                    radius:       14
                    color:        "#E8F5E9"
                    border.color: "#A5D6A7"

                    Column {
                        id: ecoCol
                        anchors {
                            top: parent.top; left: parent.left; right: parent.right
                            topMargin: 10; leftMargin: 14; rightMargin: 14
                        }
                        spacing: 4

                        Row {
                            spacing: 6
                            Label { text: "🌍"; font.pixelSize: 18 }
                            Label {
                                text: "Carbon Footprint Saved"
                                font.pixelSize: 14; font.bold: true; color: "#2E7D32"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Label {
                            text: "By choosing " + (appState ? appState.selectedVehicle : "this ride")
                                  + " over a solo car, you saved approx."
                            font.pixelSize: 12; color: "#388E3C"; wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Label {
                            text: computedCO2Saved
                            font.pixelSize: 22; font.bold: true; color: "#1B5E20"
                        }
                    }
                }

                // ── Fare card ─────────────────────────────────────────────────
                Rectangle {
                    width:        parent.width
                    height:       56
                    radius:       14
                    color:        "white"
                    border.color: "#E8E8E8"

                    Row {
                        anchors {
                            left: parent.left; right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 16; rightMargin: 16
                        }

                        Label { text: "Fare Paid"; font.pixelSize: 15; color: "#555555" }
                        Item  { width: parent.width - farePaidLabel.implicitWidth - 80; height: 1 }
                        Label {
                            id: farePaidLabel
                            text: "₹" + (appState ? appState.selectedFare : "0")
                            font.pixelSize: 26; font.bold: true; color: "#1976D2"
                        }
                    }
                }

                // ── Rate your Sarthi card ─────────────────────────────────────
                Rectangle {
                    id:           rateCard
                    width:        parent.width
                    height:       rateCol.implicitHeight + 24
                    radius:       14
                    color:        "#FFF8E1"
                    border.color: "#FFD54F"

                    property int userRating: 0

                    Column {
                        id: rateCol
                        anchors {
                            top: parent.top; left: parent.left; right: parent.right
                            topMargin: 12; leftMargin: 14; rightMargin: 14
                        }
                        spacing: 8

                        Label {
                            text: "Rate Your Sarthi"
                            font.pixelSize: 16; font.bold: true; color: "#1A1A1A"
                        }

                        // Hint / feedback label
                        Label {
                            text: rateCard.userRating === 0 ? "Tap a star to rate"
                                : rateCard.userRating === 5 ? "Excellent! 🎉"
                                : rateCard.userRating >= 4  ? "Great ride! 👍"
                                : rateCard.userRating >= 3  ? "Good ride"
                                : rateCard.userRating >= 2  ? "Could be better"
                                : "Poor experience"
                            font.pixelSize: 12
                            color: rateCard.userRating === 0 ? "#999" : "#F57F17"
                            font.bold: rateCard.userRating > 0
                        }

                        // Interactive stars — all grey until tapped
                        Row {
                            spacing: 6
                            Repeater {
                                model: 5
                                Label {
                                    text:           "★"
                                    font.pixelSize: 36
                                    color:          index < rateCard.userRating ? "#FFC107" : "#D0D0D0"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked:    rateCard.userRating = index + 1
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Back to Home button ───────────────────────────────────────
                Rectangle {
                    width: parent.width; height: 52
                    radius: 14; color: "#1976D2"

                    Label {
                        anchors.centerIn: parent
                        text: "Back To Home"
                        color: "white"; font.pixelSize: 16; font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { while (appStack.depth > 1) appStack.pop() }
                    }
                }

                Item { height: 8 }
            }
        }
    }
}