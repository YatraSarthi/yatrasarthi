import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    signal switchTab(int tabIndex)
    signal openAbout()          // ← new signal: tells parent to open About

    footer: null
    header: null

    property var favourites: []

    Component.onCompleted: { loadFavourites() }

    onVisibleChanged: {
        if (visible) {
            if (appState) appState.showBottomBar = true
            loadFavourites()
        }
    }

    function loadFavourites() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200)
                favourites = JSON.parse(xhr.responseText)
        }
        xhr.open("GET", "http://127.0.0.1:8000/favourites", true)
        xhr.send()
    }

    Rectangle { anchors.fill: parent; color: "#F4F6F9" }

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
                height: 140
                color: "#1976D2"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    spacing: 16

                    // ── Tappable Logo ──────────────────────────────
                    Item {
                        width: 105
                        height: 105
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            id: logoImg
                            source: "../../assets/icons/logo.png"
                            width: 105
                            height: 105
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            anchors.centerIn: parent

                            // Press scale feedback
                            scale: logoMouse.pressed ? 0.92 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                            }
                        }

                        // Glow ring on hover/press
                        Rectangle {
                            anchors.centerIn: parent
                            width: 108; height: 108
                            radius: 54
                            color: "transparent"
                            border.color: logoMouse.containsMouse
                                          ? "#ffffff55" : "transparent"
                            border.width: 2
                            visible: logoMouse.containsMouse || logoMouse.pressed
                        }

                        MouseArea {
                            id: logoMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                // 1. Switch to Account tab (index 3)
                                switchTab(3)
                                // 2. Tell parent to trigger About section
                                openAbout()
                            }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            text: "YatraSarthi"
                            color: "white"
                            font.pixelSize: 32
                            font.bold: true
                        }

                        Text {
                            text: "The Sarthi for Every Yatra"
                            color: "#E3F2FD"
                            font.pixelSize: 14
                            font.italic: true
                        }
                    }
                }
            }

            Column {
                width: parent.width; spacing: 14

                Item { width: 1; height: 10 }

                // ── Search Card ───────────────────────────────────
                Rectangle {
                    x: 16; width: parent.width - 32
                    height: 112; radius: 14
                    color: "white"; border.color: "#E0E0E0"

                    Column {
                        anchors.fill: parent; spacing: 0

                        // ── Pickup row ────────────────────────────
                        Item {
                            width: parent.width; height: 55

                            Rectangle {
                                anchors.fill: parent
                                color: pickupRowMouse.containsMouse
                                       ? "#F5F9FF" : "transparent"
                                radius: 14
                            }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 8
                                spacing: 10

                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    color: "#1976D2"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Label {
                                    id: pickupLabel
                                    width: parent.width - 10 - 10 - 36 - 8
                                           - parent.anchors.leftMargin
                                           - parent.anchors.rightMargin
                                    height: parent.height
                                    text: appState.pickupLocation !== ""
                                          ? appState.pickupLocation
                                          : "Pickup location"
                                    color: appState.pickupLocation !== ""
                                           ? "#1A1A1A" : "#AAAAAA"
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    id: pickupMapBtn
                                    width: 36; height: 36; radius: 8
                                    color: "#F0F4FF"
                                    anchors.verticalCenter: parent.verticalCenter
                                    z: 10

                                    Image {
                                        source: "../../assets/icons/map.png"
                                        width: 18; height: 18
                                        fillMode: Image.PreserveAspectFit
                                        anchors.centerIn: parent
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        z: 10
                                        onClicked: {
                                            appState.activeSelection = "pickup"
                                            appStack.push(
                                                Qt.resolvedUrl("MapPage.qml"),
                                                { "appStack": appStack,
                                                  "appState": appState })
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: pickupRowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                z: 1
                                onClicked: {
                                    appStack.push(
                                        Qt.resolvedUrl("LocationSearchPage.qml"),
                                        { "appStack": appStack,
                                          "appState": appState,
                                          "mode": "pickup" })
                                }
                            }
                        }

                        // Divider
                        Rectangle {
                            x: 14; width: parent.width - 28
                            height: 1; color: "#F0F0F0"
                        }

                        // ── Destination row ───────────────────────
                        Item {
                            width: parent.width; height: 55

                            Rectangle {
                                anchors.fill: parent
                                color: destRowMouse.containsMouse
                                       ? "#FFF5F5" : "transparent"
                            }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 8
                                spacing: 10

                                Rectangle {
                                    width: 10; height: 10; radius: 2
                                    color: "#E53935"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Label {
                                    id: destLabel
                                    width: parent.width - 10 - 10 - 36 - 8
                                           - parent.anchors.leftMargin
                                           - parent.anchors.rightMargin
                                    height: parent.height
                                    text: appState.destinationLocation !== ""
                                          ? appState.destinationLocation
                                          : "Where to?"
                                    color: appState.destinationLocation !== ""
                                           ? "#1A1A1A" : "#AAAAAA"
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    id: destMapBtn
                                    width: 36; height: 36; radius: 8
                                    color: "#FFF0F0"
                                    anchors.verticalCenter: parent.verticalCenter
                                    z: 10

                                    Image {
                                        source: "../../assets/icons/map.png"
                                        width: 18; height: 18
                                        fillMode: Image.PreserveAspectFit
                                        anchors.centerIn: parent
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        z: 10
                                        onClicked: {
                                            appState.activeSelection = "destination"
                                            appStack.push(
                                                Qt.resolvedUrl("MapPage.qml"),
                                                { "appStack": appStack,
                                                  "appState": appState })
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: destRowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                z: 1
                                onClicked: {
                                    appStack.push(
                                        Qt.resolvedUrl("LocationSearchPage.qml"),
                                        { "appStack": appStack,
                                          "appState": appState,
                                          "mode": "destination" })
                                }
                            }
                        }
                    }
                }

                // ── Use My Location ───────────────────────────────
                Button {
                    x: 16; width: parent.width - 32; height: 40
                    onClicked: { appState.pickupLocation = "Bengaluru, Karnataka" }
                    background: Rectangle { color: "#E3F2FD"; radius: 10; border.color: "#90CAF9" }
                    contentItem: Row {
                        anchors.centerIn: parent; spacing: 8
                        Image {
                            source: "../../assets/icons/my_location.png"
                            width: 16; height: 16
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Use My Current Location"
                            font.pixelSize: 13; color: "#1976D2"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // ── Find Ride ─────────────────────────────────────
                Button {
                    x: 16; width: parent.width - 32; height: 52
                    onClicked: {
                        if (appState.pickupLocation === ""
                                || appState.destinationLocation === "") {
                            console.log("Select both locations")
                            return
                        }
                        appStack.push(
                            Qt.resolvedUrl("ResultsPage.qml"),
                            { "appStack": appStack, "appState": appState })
                    }
                    background: Rectangle { color: "#1976D2"; radius: 12 }
                    contentItem: Row {
                        anchors.centerIn: parent; spacing: 10
                        Image {
                            source: "../../assets/icons/rider.png"
                            width: 24; height: 24
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Find Ride"; font.pixelSize: 16
                            font.bold: true; color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // ── Quick Actions ─────────────────────────────────
                Label {
                    x: 16; text: "Quick Actions"
                    font.bold: true; font.pixelSize: 15; color: "#111"
                }

                Row {
                    x: 16; width: parent.width - 32; spacing: 10

                    Repeater {
                        model: [
                            { label: "SOS",     icon: "sos.png",   color: "#FFEBEE", border: "#FFCDD2", textColor: "#E53935", tab: 1, action: "sos"   },
                            { label: "History", icon: "rider.png",  color: "#E8F5E9", border: "#C8E6C9", textColor: "#388E3C", tab: 2, action: ""      },
                            { label: "Queue",   icon: "star.png",   color: "#FFF8E1", border: "#FFE082", textColor: "#F9A825", tab: 1, action: "queue" }
                        ]
                        delegate: Rectangle {
                            width: (parent.width - 20) / 3
                            height: 72; radius: 12
                            color: modelData.color
                            border.color: modelData.border

                            Column {
                                anchors.centerIn: parent; spacing: 4
                                Image {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    source: "../../assets/icons/" + modelData.icon
                                    width: 26; height: 26
                                    fillMode: Image.PreserveAspectFit
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label; font.pixelSize: 11
                                    font.bold: true; color: modelData.textColor
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (modelData.action === "sos") {
                                        appStack.push(
                                            Qt.resolvedUrl("SosPage.qml"),
                                            { "appStack": appStack,
                                              "appState": appState })
                                    } else {
                                        if (modelData.action !== "")
                                            appState.quickAction = modelData.action
                                        switchTab(modelData.tab)
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Favourite Places ──────────────────────────────
                Label {
                    x: 16; text: "Favourite Places"
                    font.bold: true; font.pixelSize: 15; color: "#111"
                    visible: favourites.length > 0
                }

                Rectangle {
                    x: 16; width: parent.width - 32
                    height: favourites.length > 0
                            ? (favourites.length * 56) + 56 : 56
                    radius: 14; color: "white"
                    border.color: "#E0E0E0"; clip: true

                    Column {
                        width: parent.width; spacing: 0

                        Repeater {
                            model: favourites
                            delegate: Rectangle {
                                width: parent.width; height: 56
                                color: favMouse.containsMouse ? "#F5F5F5" : "transparent"

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14; anchors.rightMargin: 14
                                    spacing: 12

                                    Rectangle {
                                        width: 34; height: 34; radius: 17
                                        color: modelData.color || "#E3F2FD"
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.emoji || "★"
                                            font.pixelSize: 16
                                        }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        width: parent.width - 34 - 12 - 28
                                        Label {
                                            text: modelData.label || ""
                                            font.pixelSize: 14; font.bold: true; color: "#111"
                                        }
                                        Label {
                                            text: modelData.name !== "" ? modelData.name : "Tap to set"
                                            font.pixelSize: 11
                                            color: modelData.name !== "" ? "#888" : "#1976D2"
                                            width: parent.width; elide: Text.ElideRight
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: index < favourites.length - 1
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left; anchors.right: parent.right
                                    anchors.leftMargin: 60
                                    height: 1; color: "#F0F0F0"
                                }

                                MouseArea {
                                    id: favMouse; anchors.fill: parent; hoverEnabled: true
                                    onClicked: {
                                        if (modelData.name !== "" && modelData.lat !== 0) {
                                            appState.destinationLocation    = modelData.name
                                            appState.destinationFullAddress = modelData.name
                                            appState.destinationLat         = modelData.lat
                                            appState.destinationLon         = modelData.lon
                                        }
                                    }
                                }
                            }
                        }

                        // Add New Place
                        Rectangle {
                            width: parent.width; height: 56
                            color: addMouse.containsMouse ? "#F5F5F5" : "transparent"
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14; anchors.rightMargin: 14
                                spacing: 12
                                Rectangle {
                                    width: 34; height: 34; radius: 17; color: "#F0F0F0"
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 22; color: "#888" }
                                }
                                Label {
                                    text: "Add New Place"; font.pixelSize: 14; color: "#1976D2"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            MouseArea {
                                id: addMouse; anchors.fill: parent; hoverEnabled: true
                                onClicked: console.log("Add favourite tapped")
                            }
                        }
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }
}
