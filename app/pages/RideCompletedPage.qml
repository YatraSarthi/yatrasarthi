import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    // ── Driver photo helper ─────────────────────────────────────────────────
    // Backend now sends the filename WITH extension (e.g. "Johney.jpeg").
    // This helper still tolerates a bare name (no extension) for safety.
    function driverPhotoUrl(photo) {
        if (!photo || photo.length === 0) return ""
        if (/\.(jpe?g|png|webp)$/i.test(photo))
            return "../../assets/image/" + photo
        return "../../assets/image/" + photo + ".jpeg"
    }

    Component.onCompleted: {
        if (appState) appState.showBottomBar = false
        if (appState) {
            var d = parseFloat(appState.selectedDistance)
            if (isNaN(d) || d <= 0) {
                if (appState.pickupLat && appState.pickupLon
                        && appState.destinationLat && appState.destinationLon) {
                    var computed = haversineKm(
                        appState.pickupLat,  appState.pickupLon,
                        appState.destinationLat, appState.destinationLon)
                    appState.selectedDistance = computed
                }
            }
            if (!appState.selectedEta || parseInt(appState.selectedEta) <= 0) {
                var km = parseFloat(appState.selectedDistance)
                if (!isNaN(km) && km > 0)
                    appState.selectedEta = Math.round((km / 25) * 60)
            }
        }
    }
    Component.onDestruction: { if (appState) appState.showBottomBar = true }

    function haversineKm(lat1, lon1, lat2, lon2) {
        var R    = 6371
        var dLat = (lat2 - lat1) * Math.PI / 180
        var dLon = (lon2 - lon1) * Math.PI / 180
        var a    = Math.sin(dLat/2) * Math.sin(dLat/2)
                 + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180)
                 * Math.sin(dLon/2) * Math.sin(dLon/2)
        return parseFloat((R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))).toFixed(1))
    }

    function distanceText() {
        var d = appState ? parseFloat(appState.selectedDistance) : NaN
        return (!isNaN(d) && d > 0) ? d.toFixed(1) + " km" : "N/A"
    }
    function durationText() {
        var mins = appState ? parseInt(appState.selectedEta) : 0
        if (!mins || mins <= 0) return "N/A"
        if (mins < 60) return mins + " min"
        return Math.floor(mins/60) + " hr " + (mins % 60) + " min"
    }
    function co2Text() {
        var d = appState ? parseFloat(appState.selectedDistance) : NaN
        if (isNaN(d) || d <= 0) return "–"
        return (d * 0.15).toFixed(2) + " kg CO₂"
    }
    function dateTimeText() {
        var now    = new Date()
        var days   = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        var months = ["Jan","Feb","Mar","Apr","May","Jun",
                      "Jul","Aug","Sep","Oct","Nov","Dec"]
        var hh = now.getHours(), mm = now.getMinutes()
        var ampm = hh >= 12 ? "PM" : "AM"
        hh = hh % 12 || 12
        return days[now.getDay()] + ", " + now.getDate() + " "
             + months[now.getMonth()] + " " + now.getFullYear()
             + "  " + hh + ":" + (mm < 10 ? "0"+mm : mm) + " " + ampm
    }

    // ── Root background ───────────────────────────────────────────────────────
    Rectangle { anchors.fill: parent; color: "#F4F6F9" }

    // ── Floating header ───────────────────────────────────────────────────────
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 52; color: "#CC000000"; z: 10

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12; anchors.rightMargin: 12
            spacing: 10

            Rectangle {
                width: 36; height: 36; radius: 18; color: "#33FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
                Label { anchors.centerIn: parent; text: "←"; color: "white"; font.pixelSize: 18 }
                MouseArea { anchors.fill: parent; onClicked: { while (appStack.depth > 1) appStack.pop() } }
            }
            Label {
                text: "Ride Completed"; color: "white"
                font.pixelSize: 18; font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // ── Scrollable content ────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        Column {
            width: parent.width
            spacing: 0

            // top spacer clears header
            Item { width: parent.width; height: 64 }

            // Centre-constrained content
            Item {
                width: parent.width
                height: innerCol.implicitHeight

                Column {
                    id: innerCol
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(parent.width - 32, 720)
                    spacing: 12

                    // ── Success banner ────────────────────────────────────────
                    Rectangle {
                        width: parent.width; height: 110
                        radius: 16; color: "#4CAF50"

                        Column {
                            anchors.centerIn: parent; spacing: 6
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Destination Reached"
                                color: "white"; font.pixelSize: 24; font.bold: true
                            }
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Thank you for riding with YatraSarthi"
                                color: "white"; font.pixelSize: 14
                            }
                        }
                    }

                    // ── Ride Summary card ─────────────────────────────────────
                    Rectangle {
                        width: parent.width
                        height: summaryCol.implicitHeight + 28
                        radius: 14; color: "white"; border.color: "#E8E8E8"

                        Column {
                            id: summaryCol
                            anchors {
                                top: parent.top; left: parent.left; right: parent.right
                                topMargin: 16; leftMargin: 18; rightMargin: 18
                            }
                            spacing: 10

                            Label {
                                text: "Ride Summary"
                                font.pixelSize: 17; font.bold: true; color: "#1A1A1A"
                            }

                            // Pickup row
                            Row {
                                spacing: 10; width: parent.width
                                Image {
    source: "../../assets/icons/pickup.png"
    width: 18
    height: 18
    fillMode: Image.PreserveAspectFit
    anchors.verticalCenter: parent.verticalCenter
}
                                Label {
                                    text: appState ? appState.pickupLocation : "–"
                                    font.pixelSize: 13; color: "#333"
                                    wrapMode: Text.WordWrap
                                    width: parent.width - 20
                                }
                            }

                            // Connector line
                            Item {
                                width: parent.width; height: 10
                                Rectangle {
                                    width: 2; height: parent.height
                                    color: "#CCCCCC"
                                    anchors.left: parent.left
                                    anchors.leftMargin: 4
                                }
                            }

                           // Destination row
Row {
    width: parent.width
    spacing: 10

    Image {
        source: "../../assets/icons/destination.png"
        width: 22
        height: 22
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: appState ? appState.destinationLocation : "–"
        width: parent.width - 40
        wrapMode: Text.WordWrap
        font.pixelSize: 13
        font.bold: true
        color: "#333333"
        verticalAlignment: Text.AlignVCenter
    }
}
                                

                            // Divider
                            Rectangle { width: parent.width; height: 1; color: "#F0F0F0" }

                            // Detail grid — 2 columns
                            Grid {
                                width: parent.width
                                columns: 2
                                columnSpacing: 0
                                rowSpacing: 8

                                // Vehicle
                                Column {
                                    width: parent.width / 2
                                    spacing: 3
                                    Label { text: "Vehicle";  font.pixelSize: 12; color: "#888" }
                                    Label { text: appState ? appState.selectedVehicle : "–"; font.pixelSize: 14; color: "#1A1A1A"; font.bold: true }
                                }
                                // Distance
                                Column {
                                    width: parent.width / 2
                                    spacing: 3
                                    Label { text: "Distance"; font.pixelSize: 12; color: "#888" }
                                    Label { text: distanceText(); font.pixelSize: 14; color: "#1A1A1A"; font.bold: true }
                                }
                                // Duration
                                Column {
                                    width: parent.width / 2
                                    spacing: 3
                                    Label { text: "Duration"; font.pixelSize: 12; color: "#888" }
                                    Label { text: durationText(); font.pixelSize: 14; color: "#1A1A1A"; font.bold: true }
                                }
                                // Date & Time
                                Column {
                                    width: parent.width / 2
                                    spacing: 3
                                    Label { text: "Completed"; font.pixelSize: 12; color: "#888" }
                                    Label {
                                        text: dateTimeText()
                                        font.pixelSize: 12; color: "#1A1A1A"; font.bold: true
                                        wrapMode: Text.WordWrap
                                        width: parent.width - 8
                                    }
                                }
                            }

                            // Divider
                            Rectangle { width: parent.width; height: 1; color: "#F0F0F0" }

                            // Driver row
                            Row {
                                width: parent.width
                                spacing: 0

                                Column {
                                    width: parent.width / 2
                                    spacing: 3
                                    Label { text: "Driver"; font.pixelSize: 12; color: "#888" }
                                    Label {
                                        text: appState && appState.driverName ? appState.driverName : "Your Sarthi"
                                        font.pixelSize: 14; color: "#1A1A1A"; font.bold: true
                                    }
                                }
                                Column {
                                    width: parent.width / 2
                                    spacing: 3
                                    Label { text: "Driver Rating"; font.pixelSize: 12; color: "#888" }
                                    Row {
                                        spacing: 4
                                        Label {
                                            text: appState && appState.driverRating ? appState.driverRating.toFixed(1) : "4.8"
                                            font.pixelSize: 14; color: "#1A1A1A"; font.bold: true
                                        }
                                        Label { text: "★"; font.pixelSize: 14; color: "#FFC107" }
                                    }
                                }
                            }
                        }
                    }

                    // ── Carbon + Fare row ─────────────────────────────────────
                    Row {
                        width: parent.width
                        spacing: 12

                        // Carbon card
                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: ecoCol.implicitHeight + 28
                            radius: 14; color: "#E8F5E9"; border.color: "#A5D6A7"

                            Column {
                                id: ecoCol
                                anchors {
                                    top: parent.top; left: parent.left; right: parent.right
                                    topMargin: 14; leftMargin: 14; rightMargin: 14
                                }
                                spacing: 6

                                Row {
                                    spacing: 6
                                    Label { text: "🌍"; font.pixelSize: 20 }
                                    Label {
                                        text: "Carbon Saved"
                                        font.pixelSize: 14; font.bold: true; color: "#2E7D32"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Label {
                                    text: "vs driving solo"
                                    font.pixelSize: 11; color: "#388E3C"
                                }
                                Label {
                                    text: co2Text()
                                    font.pixelSize: 22; font.bold: true; color: "#1B5E20"
                                }
                            }
                        }

                        // Fare card
                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: ecoCol.implicitHeight + 28
                            radius: 14; color: "white"; border.color: "#E8E8E8"

                            Column {
                                anchors.centerIn: parent
                                spacing: 6

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Fare Paid"; font.pixelSize: 13; color: "#888"
                                }
                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "₹" + (appState ? appState.selectedFare : "0")
                                    font.pixelSize: 32; font.bold: true; color: "#1976D2"
                                }
                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: appState && appState.paymentMode ? appState.paymentMode : "Cash"
                                    font.pixelSize: 12; color: "#4CAF50"; font.bold: true
                                }
                            }
                        }
                    }

                    // ── Rate your Sarthi card ─────────────────────────────────
                    Rectangle {
                        id: rateCard
                        width: parent.width
                        height: rateCol.implicitHeight + 28
                        radius: 14; color: "#FFF8E1"; border.color: "#FFD54F"

                        property int userRating: 0

                        // ── Auto-redirect timer after rating ──────────────────
                        Timer {
                            id: redirectTimer
                            interval: 800
                            repeat: false
                            onTriggered: { while (appStack.depth > 1) appStack.pop() }
                        }

                        Column {
                            id: rateCol
                            anchors {
                                top: parent.top; left: parent.left; right: parent.right
                                topMargin: 14; leftMargin: 18; rightMargin: 18
                            }
                            spacing: 10

                            Row {
                                width: parent.width
                                spacing: 0

                                Column {
                                    width: parent.width * 0.55
                                    spacing: 6

                                    Label {
                                        text: "Rate Your Sarthi"
                                        font.pixelSize: 16; font.bold: true; color: "#1A1A1A"
                                    }
                                    Label {
                                        text: rateCard.userRating === 0 ? "Tap a star to rate"
                                            : rateCard.userRating === 5 ? "Excellent! 🎉"
                                            : rateCard.userRating >= 4  ? "Great ride! 👍"
                                            : rateCard.userRating >= 3  ? "Good ride"
                                            : rateCard.userRating >= 2  ? "Could be better"
                                            : "Poor experience"
                                        font.pixelSize: 13
                                        color: rateCard.userRating === 0 ? "#999" : "#F57F17"
                                        font.bold: rateCard.userRating > 0
                                    }

                                    Row {
                                        spacing: 8
                                        Repeater {
                                            model: 5
                                            Label {
                                                text: "★"
                                                font.pixelSize: 38
                                                color: index < rateCard.userRating ? "#FFC107" : "#D0D0D0"
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        rateCard.userRating = index + 1
                                                        redirectTimer.start()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Driver avatar
                                Column {
                                    width: parent.width * 0.45
                                    spacing: 6

                                    Rectangle {
    anchors.horizontalCenter: parent.horizontalCenter
    width: 64
    height: 64
    radius: 32

    color: "#E3F2FD"
    border.color: "#1976D2"
    border.width: 2

    clip: true

    Image {
        anchors.fill: parent
        source: driverPhotoUrl(appState.driverPhoto)
        fillMode: Image.PreserveAspectCrop

        Rectangle {
            anchors.fill: parent
            color: "#1976D2"
            visible: parent.status !== Image.Ready

            Label {
                anchors.centerIn: parent
                text: "👤"
                font.pixelSize: 26
            }
        }
    }
}

Label {
    anchors.horizontalCenter: parent.horizontalCenter
    text: appState.driverName
    font.pixelSize: 13
    font.bold: true
    color: "#1A1A1A"
}

Label {
    anchors.horizontalCenter: parent.horizontalCenter
    text: appState.driverVehicleModel + " • " + appState.driverVehicle
    font.pixelSize: 12
    color: "#666666"
}

Label {
    anchors.horizontalCenter: parent.horizontalCenter
    text: "★ " + appState.driverRating.toFixed(1)
    font.pixelSize: 12
    font.bold: true
    color: "#F4A700"
}
                                }
                            }
                        }
                    }

                    // bottom spacer
                    Item { width: parent.width; height: 32 }
                }
            }
        }
    }
}