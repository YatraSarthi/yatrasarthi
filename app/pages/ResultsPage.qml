import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    // Signal to tell Main.qml to switch tab
    // (renamed from switchTab to avoid shadowing Main.qml's switchTab() function)
    signal requestTabChange(int tabIndex)

    // No local footer — Main.qml owns the TabBar
    footer: null
    header: null

    property var pickupModel: []
    property var destinationModel: []
    property var favourites: []

    property bool suppressPickupFetch: false
    property bool suppressDestinationFetch: false

    Component.onCompleted: {
        loadFavourites()
    }

    // Reload favourites every time Home tab becomes visible
    // Also restore the bottom bar (safety net in case booking flow left it hidden)
    onVisibleChanged: {
        if (visible) {
            if (appState) appState.showBottomBar = true
            loadFavourites()
        }
    }

    function loadFavourites() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE
                    && xhr.status === 200) {
                favourites = JSON.parse(xhr.responseText)
            }
        }
        xhr.open("GET",
            "http://127.0.0.1:8000/favourites", true)
        xhr.send()
    }

    function fetchPickupSuggestions(query) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE
                    && xhr.status === 200) {
                pickupModel = JSON.parse(xhr.responseText)
            }
        }
        xhr.open("GET",
            "http://127.0.0.1:8000/search-location?query="
            + encodeURIComponent(query), true)
        xhr.send()
    }

    function fetchDestinationSuggestions(query) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE
                    && xhr.status === 200) {
                destinationModel = JSON.parse(xhr.responseText)
            }
        }
        xhr.open("GET",
            "http://127.0.0.1:8000/search-location?query="
            + encodeURIComponent(query), true)
        xhr.send()
    }

    Timer {
        id: pickupTimer
        interval: 800
        repeat: false
        onTriggered: { fetchPickupSuggestions(pickupSearch.text) }
    }

    Timer {
        id: destinationTimer
        interval: 800
        repeat: false
        onTriggered: {
            fetchDestinationSuggestions(destinationSearch.text)
        }
    }

    // ── Root item — dropdowns float above ScrollView ──────────────
    Item {

        id: pageRoot
        anchors.fill: parent

        ScrollView {
            anchors.fill: parent
            contentWidth: width
            clip: true

            Column {
                width: parent.width
                spacing: 0

                // ── Header ────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 65
                    color: "#1976D2"
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        text: "YatraSarthi"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                    }
                }

                Column {
                    width: parent.width
                    spacing: 14

                    Item { width: 1; height: 10 }

                    // ── Search Card ───────────────────────────────
                    Rectangle {
                        id: searchCard
                        x: 16
                        width: parent.width - 32
                        height: 112
                        radius: 14
                        color: "white"
                        border.color: "#E0E0E0"

                        Column {
                            anchors.fill: parent
                            spacing: 0

                            Row {
                                id: pickupRowInCard
                                width: parent.width
                                height: 55
                                leftPadding: 14
                                rightPadding: 8
                                spacing: 10

                                Rectangle {
                                    width: 10; height: 10
                                    radius: 5; color: "#1976D2"
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                }

                                TextField {
                                    id: pickupSearch
                                    width: parent.width - 10 - 10
                                           - 36 - 8
                                           - parent.leftPadding
                                           - parent.rightPadding
                                    height: parent.height
                                    text: appState.pickupLocation
                                    placeholderText: "Pickup location"
                                    background: Item {}
                                    font.pixelSize: 14
                                    verticalAlignment:
                                        Text.AlignVCenter
                                    onTextChanged: {
                                        if (suppressPickupFetch) {
                                            suppressPickupFetch = false
                                            return
                                        }
                                        if (!activeFocus) return
                                        if (text.length > 2)
                                            pickupTimer.restart()
                                        else
                                            pickupModel = []
                                    }
                                }

                                ToolButton {
                                    width: 36; height: 36
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                    onClicked: {
                                        appState.activeSelection =
                                            "pickup"
                                        appStack.push(
                                            Qt.resolvedUrl(
                                                "MapPage.qml"),
                                            { "appStack": appStack,
                                              "appState": appState })
                                    }
                                    contentItem: Image {
                                        source: Qt.resolvedUrl("../../assets/icons/map.png")
                                        width: 18; height: 18
                                        fillMode: Image.PreserveAspectFit
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Rectangle {
                                x: 14; width: parent.width - 28
                                height: 1; color: "#F0F0F0"
                            }

                            Row {
                                id: destinationRowInCard
                                width: parent.width
                                height: 55
                                leftPadding: 14
                                rightPadding: 8
                                spacing: 10

                                Rectangle {
                                    width: 10; height: 10
                                    radius: 2; color: "#E53935"
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                }

                                TextField {
                                    id: destinationSearch
                                    width: parent.width - 10 - 10
                                           - 36 - 8
                                           - parent.leftPadding
                                           - parent.rightPadding
                                    height: parent.height
                                    text: appState.destinationLocation
                                    placeholderText: "Where to?"
                                    background: Item {}
                                    font.pixelSize: 14
                                    verticalAlignment:
                                        Text.AlignVCenter
                                    onTextChanged: {
                                        if (suppressDestinationFetch) {
                                            suppressDestinationFetch =
                                                false
                                            return
                                        }
                                        if (!activeFocus) return
                                        if (text.length > 2)
                                            destinationTimer.restart()
                                        else
                                            destinationModel = []
                                    }
                                }

                                ToolButton {
                                    width: 36; height: 36
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                    onClicked: {
                                        appState.activeSelection =
                                            "destination"
                                        appStack.push(
                                            Qt.resolvedUrl(
                                                "MapPage.qml"),
                                            { "appStack": appStack,
                                              "appState": appState })
                                    }
                                    contentItem: Image {
                                        source: Qt.resolvedUrl("../../assets/icons/map.png")
                                        width: 18; height: 18
                                        fillMode: Image.PreserveAspectFit
                                        anchors.centerIn: parent
                                    }
                                }
                            }
                        }
                    }

                    // ── Use My Location ───────────────────────────
                    Button {
                        x: 16
                        width: parent.width - 32
                        height: 40
                        onClicked: {
                            appState.pickupLocation =
                                "Bengaluru, Karnataka"
                            pickupSearch.text =
                                "Bengaluru, Karnataka"
                        }
                        background: Rectangle {
                            color: "#E3F2FD"; radius: 10
                            border.color: "#90CAF9"
                        }
                        contentItem: Row {
                            anchors.centerIn: parent
                            spacing: 8
                            Image {
                                source: Qt.resolvedUrl("../../assets/icons/pickup.png")
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

                    // ── Find Ride ─────────────────────────────────
                    Button {
                        x: 16
                        width: parent.width - 32
                        height: 52
                        onClicked: {
                            if (appState.pickupLocation === ""
                                    || appState.destinationLocation
                                    === "") {
                                console.log("Select both locations")
                                return
                            }
                            appStack.push(
                                Qt.resolvedUrl("ResultsPage.qml"),
                                { "appStack": appStack,
                                  "appState": appState })
                        }
                        background: Rectangle {
                            color: "#1976D2"; radius: 12
                        }
                        contentItem: Row {
                            anchors.centerIn: parent
                            spacing: 10
                            Image {
                                source: Qt.resolvedUrl("../../assets/icons/rider.png")
                                width: 24; height: 24
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Find Ride"
                                font.pixelSize: 16; font.bold: true
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // ── Quick Actions ─────────────────────────────
                    Label {
                        x: 16
                        text: "Quick Actions"
                        font.bold: true; font.pixelSize: 15
                        color: "#111"
                    }

                    Row {
                        x: 16
                        width: parent.width - 32
                        spacing: 10

                        // SOS — goes to Services tab, SOS card
                        Rectangle {
                            width: (parent.width - 20) / 3
                            height: 72
                            radius: 12
                            color: "#FFEBEE"
                            border.color: "#FFCDD2"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Image {
                                    anchors.horizontalCenter:
                                        parent.horizontalCenter
                                    source: Qt.resolvedUrl("../../assets/icons/sos.png")
                                    width: 26; height: 26
                                    fillMode: Image.PreserveAspectFit
                                }
                                Text {
                                    anchors.horizontalCenter:
                                        parent.horizontalCenter
                                    text: "SOS"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#E53935"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("SOS clicked")
                                    appState.quickAction = "sos"
                                    requestTabChange(1)
                                }
                            }
                        }

                        // History — goes to Activity tab
                        Rectangle {
                            width: (parent.width - 20) / 3
                            height: 72
                            radius: 12
                            color: "#E8F5E9"
                            border.color: "#C8E6C9"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Image {
                                    anchors.horizontalCenter:
                                        parent.horizontalCenter
                                    source: Qt.resolvedUrl("../../assets/icons/rider.png")
                                    width: 26; height: 26
                                    fillMode: Image.PreserveAspectFit
                                }
                                Text {
                                    anchors.horizontalCenter:
                                        parent.horizontalCenter
                                    text: "History"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#388E3C"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("History clicked")
                                    appState.quickAction = ""
                                    requestTabChange(2)
                                }
                            }
                        }

                        // Queue — goes to Services tab
                        Rectangle {
                            width: (parent.width - 20) / 3
                            height: 72
                            radius: 12
                            color: "#FFF8E1"
                            border.color: "#FFE082"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Image {
                                    anchors.horizontalCenter:
                                        parent.horizontalCenter
                                    source: Qt.resolvedUrl("../../assets/icons/star.png")
                                    width: 26; height: 26
                                    fillMode: Image.PreserveAspectFit
                                }
                                Text {
                                    anchors.horizontalCenter:
                                        parent.horizontalCenter
                                    text: "Queue"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#F9A825"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Queue clicked")
                                    appState.quickAction = "queue"
                                    requestTabChange(1)
                                }
                            }
                        }
                    }

                    // ── Favourite Places (dynamic) ─────────────────
                    Label {
                        x: 16
                        text: "Favourite Places"
                        font.bold: true; font.pixelSize: 15
                        color: "#111"
                        visible: favourites.length > 0
                    }

                    Rectangle {
                        x: 16
                        width: parent.width - 32
                        height: favourites.length > 0
                                ? (favourites.length * 56) + 56
                                : 56
                        radius: 14
                        color: "white"
                        border.color: "#E0E0E0"
                        clip: true

                        Column {
                            width: parent.width
                            spacing: 0

                            Repeater {
                                model: favourites

                                delegate: Rectangle {
                                    width: parent.width
                                    height: 56
                                    color: favMouse.containsMouse
                                           ? "#F5F5F5"
                                           : "transparent"

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 14
                                        anchors.rightMargin: 14
                                        spacing: 12

                                        Rectangle {
                                            width: 34; height: 34
                                            radius: 17
                                            color: modelData.color
                                                   || "#E3F2FD"
                                            anchors.verticalCenter:
                                                parent.verticalCenter

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.emoji
                                                      || "★"
                                                font.pixelSize: 16
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter:
                                                parent.verticalCenter
                                            spacing: 2
                                            width: parent.width
                                                   - 34 - 12
                                                   - 14 - 14

                                            Label {
                                                text: modelData.label
                                                      || ""
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "#111"
                                            }

                                            Label {
                                                text: modelData.name
                                                      !== ""
                                                      ? modelData.name
                                                      : "Tap to set"
                                                font.pixelSize: 11
                                                color: modelData.name
                                                       !== ""
                                                       ? "#888"
                                                       : "#1976D2"
                                                width: parent.width
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }

                                    Rectangle {
                                        visible: index < favourites.length - 1
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.leftMargin: 60
                                        height: 1; color: "#F0F0F0"
                                    }

                                    MouseArea {
                                        id: favMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (modelData.name !== ""
                                                    && modelData.lat
                                                    !== 0) {
                                                appState.destinationLocation
                                                    = modelData.name
                                                appState.destinationLat
                                                    = modelData.lat
                                                appState.destinationLon
                                                    = modelData.lon
                                                suppressDestinationFetch
                                                    = true
                                                destinationSearch.text
                                                    = modelData.name
                                            }
                                        }
                                    }
                                }
                            }

                            // Add New Place row
                            Rectangle {
                                width: parent.width
                                height: 56
                                color: addMouse.containsMouse
                                       ? "#F5F5F5" : "transparent"

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Rectangle {
                                        width: 34; height: 34
                                        radius: 17; color: "#F0F0F0"
                                        anchors.verticalCenter:
                                            parent.verticalCenter
                                        Text {
                                            anchors.centerIn: parent
                                            text: "+"
                                            font.pixelSize: 22
                                            color: "#888"
                                        }
                                    }

                                    Label {
                                        text: "Add New Place"
                                        font.pixelSize: 14
                                        color: "#1976D2"
                                        anchors.verticalCenter:
                                            parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    id: addMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        console.log(
                                            "Add favourite tapped")
                                    }
                                }
                            }
                        }
                    }

                    Item { width: 1; height: 20 }
                }
            }
        }

        // ── PICKUP DROPDOWN (floats above everything) ─────────────
        Rectangle {
            x: searchCard.x
            y: pickupAnchor.mapToItem(pageRoot, 0, 0).y
            width: searchCard.width
            height: pickupModel.length > 0
                    ? Math.min(pickupModel.length * 52, 210) : 0
            visible: pickupModel.length > 0
            z: 99999
            color: "white"
            border.color: "#DDDDDD"
            radius: 10

            ListView {
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                model: pickupModel

                delegate: Rectangle {
                    width: parent.width
                    height: 52
                    color: pMouse.containsMouse
                           ? "#F0F4FF" : "transparent"
                    radius: 8

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Rectangle {
                            width: 30; height: 30; radius: 15
                            color: "#E3F2FD"
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                source: Qt.resolvedUrl("../../assets/icons/pickup.png")
                                width: 14; height: 14
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 30 - 10 - 24
                            spacing: 1
                            Text {
                                text: modelData.name.split(",")[0].trim()
                                font.pixelSize: 13; font.bold: true
                                color: "#111"; width: parent.width
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.name.split(",")
                                      .slice(1, 3).join(",").trim()
                                font.pixelSize: 11; color: "#888"
                                width: parent.width
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Rectangle {
                        visible: index < pickupModel.length - 1
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 52
                        height: 1; color: "#F0F0F0"
                    }

                    MouseArea {
                        id: pMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            pickupTimer.stop()
                            appState.pickupLocation = modelData.name
                            appState.pickupLat = modelData.lat
                            appState.pickupLon = modelData.lon
                            pickupModel = []
                            pickupSearch.focus = false
                            pickupSearch.text = modelData.name
                            console.log("Pickup:",
                                appState.pickupLat,
                                appState.pickupLon)
                        }
                    }
                }
            }
        }

        // ── DESTINATION DROPDOWN ──────────────────────────────────
        Rectangle {
            x: searchCard.x
            y: destAnchor.mapToItem(pageRoot, 0, 0).y
            width: searchCard.width
            height: destinationModel.length > 0
                    ? Math.min(destinationModel.length * 52, 210) : 0
            visible: destinationModel.length > 0
            z: 99999
            color: "white"
            border.color: "#DDDDDD"
            radius: 10

            ListView {
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                model: destinationModel

                delegate: Rectangle {
                    width: parent.width
                    height: 52
                    color: dMouse.containsMouse
                           ? "#F0F4FF" : "transparent"
                    radius: 8

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Rectangle {
                            width: 30; height: 30; radius: 15
                            color: "#FFEBEE"
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                source: Qt.resolvedUrl("../../assets/icons/destination.png")
                                width: 14; height: 14
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 30 - 10 - 24
                            spacing: 1
                            Text {
                                text: modelData.name.split(",")[0].trim()
                                font.pixelSize: 13; font.bold: true
                                color: "#111"; width: parent.width
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.name.split(",")
                                      .slice(1, 3).join(",").trim()
                                font.pixelSize: 11; color: "#888"
                                width: parent.width
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Rectangle {
                        visible: index < destinationModel.length - 1
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 52
                        height: 1; color: "#F0F0F0"
                    }

                    MouseArea {
                        id: dMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            destinationTimer.stop()
                            appState.destinationLocation = modelData.name
                            appState.destinationLat = modelData.lat
                            appState.destinationLon = modelData.lon
                            destinationModel = []
                            destinationSearch.focus = false
                            destinationSearch.text = modelData.name
                            var xhr = new XMLHttpRequest()
                            xhr.open("POST",
                                "http://127.0.0.1:8000/recent-places"
                                + "?name="
                                + encodeURIComponent(modelData.name)
                                + "&lat=" + modelData.lat
                                + "&lon=" + modelData.lon, true)
                            xhr.send()
                            console.log("Destination:",
                                appState.destinationLat,
                                appState.destinationLon)
                        }
                    }
                }
            }
        }

        // Anchor helpers for dropdown positioning
        Item {
            id: pickupAnchor
            parent: pickupRowInCard
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: 0; height: 0
        }

        Item {
            id: destAnchor
            parent: destinationRowInCard
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: 0; height: 0
        }
    }
}
