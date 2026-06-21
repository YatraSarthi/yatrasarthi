import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var appStack
    property var appState

    property var pickupModel: []
    property var destinationModel: []
    property var recentPlaces: []

    property bool suppressPickupFetch: false
    property bool suppressDestinationFetch: false

    // ── Load recent places on page open ──────────────────────────
    Component.onCompleted: {
        loadRecentPlaces()
    }

    function loadRecentPlaces() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var parsed = JSON.parse(xhr.responseText)
                recentPlaces = parsed
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/recent-places", true)
        xhr.send()
    }

    function saveRecentPlace(name, lat, lon) {
        var xhr = new XMLHttpRequest()
        xhr.open(
            "POST",
            "http://127.0.0.1:8000/recent-places"
            + "?name=" + encodeURIComponent(name)
            + "&lat=" + lat
            + "&lon=" + lon,
            true
        )
        xhr.send()
    }

    function fetchPickupSuggestions(query) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                pickupModel = JSON.parse(xhr.responseText)
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/search-location?query="
            + encodeURIComponent(query), true)
        xhr.send()
    }

    function fetchDestinationSuggestions(query) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                destinationModel = JSON.parse(xhr.responseText)
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/search-location?query="
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
        onTriggered: { fetchDestinationSuggestions(destinationSearch.text) }
    }

    // ── Bottom Navigation Bar ─────────────────────────────────────
    footer: TabBar {

        id: bottomNav

        background: Rectangle {
            color: "white"
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: "#E0E0E0"
            }
        }

        TabButton {
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../assets/icons/pickup.png"
                    width: 22; height: 22
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Home"
                    font.pixelSize: 10
                    color: bottomNav.currentIndex === 0 ? "#1976D2" : "#888"
                }
            }
        }

        TabButton {
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../assets/icons/star.png"
                    width: 22; height: 22
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Services"
                    font.pixelSize: 10
                    color: bottomNav.currentIndex === 1 ? "#1976D2" : "#888"
                }
            }
        }

        TabButton {
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../assets/icons/rider.png"
                    width: 22; height: 22
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Activity"
                    font.pixelSize: 10
                    color: bottomNav.currentIndex === 2 ? "#1976D2" : "#888"
                }
            }
        }

        TabButton {
            contentItem: Column {
                anchors.centerIn: parent
                spacing: 2
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../assets/icons/driver.png"
                    width: 22; height: 22
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Account"
                    font.pixelSize: 10
                    color: bottomNav.currentIndex === 3 ? "#1976D2" : "#888"
                }
            }
        }
    }

    // ── Main content ──────────────────────────────────────────────
    // Outer Item fills the Page so we can use absolute z-layering
    // for the dropdowns — they are children of this Item, not of the
    // ScrollView, so they always float above everything else.
    Item {

        id: pageRoot
        anchors.fill: parent

        // ── Scrollable body (sits below dropdowns in z-order) ─────
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
                    height: 70
                    color: "#1976D2"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        spacing: 8

                        Label {
                            text: "YatraSarthi"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // ── Body padding column ───────────────────────────
                Column {

                    width: parent.width
                    spacing: 14

                    // top gap
                    Item { width: 1; height: 6 }

                    // ── Search Card ───────────────────────────────
                    // This is just the visible white card — fixed
                    // height, no clip. The dropdowns are rendered
                    // in pageRoot above the ScrollView entirely.
                    Rectangle {

                        id: searchCard

                        x: 20
                        width: parent.width - 40
                        height: 110
                        radius: 12
                        color: "white"
                        border.color: "#E0E0E0"

                        // subtle shadow
                        layer.enabled: true

                        Column {

                            anchors.fill: parent
                            spacing: 0

                            // Pickup row
                            Row {
                                id: pickupRowInCard
                                width: parent.width
                                height: 54
                                spacing: 8
                                leftPadding: 14
                                rightPadding: 8

                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    color: "#1976D2"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                TextField {
                                    id: pickupSearch
                                    width: parent.width
                                           - 10 - 8 - 36 - 8
                                           - parent.leftPadding
                                           - parent.rightPadding
                                    height: parent.height
                                    text: appState.pickupLocation
                                    placeholderText: "Pickup location"
                                    background: Item {}
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter

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
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: {
                                        appState.activeSelection = "pickup"
                                        appStack.push(
                                            Qt.resolvedUrl("MapPage.qml"),
                                            { "appStack": appStack,
                                              "appState": appState })
                                    }
                                    contentItem: Image {
                                        source: "../../assets/icons/map.png"
                                        width: 18; height: 18
                                        fillMode: Image.PreserveAspectFit
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            // Divider
                            Rectangle {
                                x: 14
                                width: parent.width - 28
                                height: 1
                                color: "#EEEEEE"
                            }

                            // Destination row
                            Row {
                                id: destinationRowInCard
                                width: parent.width
                                height: 54
                                spacing: 8
                                leftPadding: 14
                                rightPadding: 8

                                Rectangle {
                                    width: 10; height: 10; radius: 2
                                    color: "#E53935"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                TextField {
                                    id: destinationSearch
                                    width: parent.width
                                           - 10 - 8 - 36 - 8
                                           - parent.leftPadding
                                           - parent.rightPadding
                                    height: parent.height
                                    text: appState.destinationLocation
                                    placeholderText: "Where to?"
                                    background: Item {}
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter

                                    onTextChanged: {
                                        if (suppressDestinationFetch) {
                                            suppressDestinationFetch = false
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
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: {
                                        appState.activeSelection = "destination"
                                        appStack.push(
                                            Qt.resolvedUrl("MapPage.qml"),
                                            { "appStack": appStack,
                                              "appState": appState })
                                    }
                                    contentItem: Image {
                                        source: "../../assets/icons/map.png"
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
                        x: 20
                        width: parent.width - 40
                        height: 38
                        onClicked: {
                            appState.pickupLocation = "Bengaluru, Karnataka"
                            pickupSearch.text = "Bengaluru, Karnataka"
                        }
                        background: Rectangle {
                            color: "#E3F2FD"; radius: 8
                            border.color: "#90CAF9"
                        }
                        contentItem: Row {
                            anchors.centerIn: parent
                            spacing: 8
                            Image {
                                source: "../../assets/icons/pickup.png"
                                width: 16; height: 16
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Use My Current Location"
                                font.pixelSize: 13
                                color: "#1976D2"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // ── Find Ride ─────────────────────────────────
                    Button {
                        x: 20
                        width: parent.width - 40
                        height: 52
                        onClicked: {
                            if (appState.pickupLocation === ""
                                    || appState.destinationLocation === "") {
                                console.log("Select both locations")
                                return
                            }
                            console.log("Pickup:",
                                appState.pickupLat, appState.pickupLon)
                            console.log("Destination:",
                                appState.destinationLat, appState.destinationLon)

                            appStack.push(
                                Qt.resolvedUrl("ResultsPage.qml"),
                                { "appStack": appStack, "appState": appState })
                        }
                        background: Rectangle {
                            color: "#1976D2"; radius: 12
                        }
                        contentItem: Row {
                            anchors.centerIn: parent
                            spacing: 10
                            Image {
                                source: "../../assets/icons/rider.png"
                                width: 26; height: 26
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Find Ride"
                                font.pixelSize: 16
                                font.bold: true
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // ── Quick Actions ─────────────────────────────
                    Label {
                        x: 20
                        text: "Quick Actions"
                        font.bold: true
                        font.pixelSize: 16
                        color: "#222"
                    }

                    Row {
                        x: 20
                        width: parent.width - 40
                        spacing: 10

                        Repeater {
                            model: [
                                { label: "SOS",     icon: "sos.png",
                                  bg: "#FFEBEE", border: "#FFCDD2",
                                  fg: "#E53935" },
                                { label: "History", icon: "rider.png",
                                  bg: "#E8F5E9", border: "#C8E6C9",
                                  fg: "#388E3C" },
                                { label: "Queue",   icon: "star.png",
                                  bg: "#FFF8E1", border: "#FFE082",
                                  fg: "#F9A825" },
                                { label: "Route",   icon: "map.png",
                                  bg: "#E3F2FD", border: "#90CAF9",
                                  fg: "#1976D2" }
                            ]

                            delegate: Button {
                                width: (parent.width - 30) / 4
                                height: 72
                                background: Rectangle {
                                    color: modelData.bg
                                    radius: 12
                                    border.color: modelData.border
                                }
                                contentItem: Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Image {
                                        anchors.horizontalCenter:
                                            parent.horizontalCenter
                                        source: "../../assets/icons/"
                                                + modelData.icon
                                        width: 26; height: 26
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    Text {
                                        anchors.horizontalCenter:
                                            parent.horizontalCenter
                                        text: modelData.label
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: modelData.fg
                                    }
                                }
                            }
                        }
                    }

                    // ── Recent Places (dynamic) ───────────────────
                    // Only shown when the backend has returned places
                    Column {
                        x: 20
                        width: parent.width - 40
                        spacing: 8
                        visible: recentPlaces.length > 0

                        Label {
                            text: "Recent Places"
                            font.bold: true
                            font.pixelSize: 16
                            color: "#222"
                        }

                        Rectangle {
                            width: parent.width
                            height: recentPlaces.length * 52
                            radius: 12
                            color: "white"
                            border.color: "#E0E0E0"
                            clip: true

                            Column {
                                anchors.fill: parent
                                spacing: 0

                                Repeater {
                                    model: recentPlaces

                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 52
                                        color: recentMouse.containsMouse
                                               ? "#F5F5F5" : "transparent"

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 14
                                            anchors.rightMargin: 14
                                            spacing: 12

                                            Image {
                                                source: "../../assets/icons/destination.png"
                                                width: 20; height: 20
                                                fillMode: Image.PreserveAspectFit
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2
                                                width: parent.width - 20 - 12 - 28

                                                Label {
                                                    text: modelData.name
                                                    font.pixelSize: 14
                                                    color: "#222"
                                                    width: parent.width
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }

                                        // Row divider
                                        Rectangle {
                                            visible: index < recentPlaces.length - 1
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.leftMargin: 46
                                            height: 1
                                            color: "#EEEEEE"
                                        }

                                        MouseArea {
                                            id: recentMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                // Fill destination directly
                                                // with saved coords — no
                                                // second search needed
                                                appState.destinationLocation =
                                                    modelData.name
                                                appState.destinationLat =
                                                    modelData.lat
                                                appState.destinationLon =
                                                    modelData.lon

                                                suppressDestinationFetch = true
                                                destinationSearch.text =
                                                    modelData.name
                                                destinationSearch.cursorPosition =
                                                    destinationSearch.text.length

                                                console.log(
                                                    "Recent place selected:",
                                                    modelData.name,
                                                    modelData.lat,
                                                    modelData.lon)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // bottom breathing room
                    Item { width: 1; height: 20 }
                }
            }
        }

        // ── PICKUP DROPDOWN ───────────────────────────────────────
        // Child of pageRoot (NOT ScrollView) so it truly floats
        // above every other element with no clipping at all.
        Rectangle {

            id: pickupDropdown

            // Position relative to searchCard, mapped to pageRoot
            x: searchCard.x + pageRoot.x
            // 70 (header) + searchCard.y relative to scroll content
            // We use a helper Item inside the card to get global pos.
            y: pickupAnchor.mapToItem(pageRoot, 0, 0).y
            width: searchCard.width

            height: pickupModel.length > 0
                    ? Math.min(pickupModel.length * 52, 208)
                    : 0

            visible: pickupModel.length > 0
            z: 99999

            color: "white"
            border.color: "#C8C8C8"
            radius: 10

            // Drop shadow
            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                radius: parent.radius + 1
                color: "transparent"
                border.color: "#22000000"
                z: -1
            }

            ListView {
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                model: pickupModel
                spacing: 0

                delegate: Rectangle {
                    width: parent.width
                    height: 52
                    color: pickupItemMouse.containsMouse
                           ? "#F0F4FF" : "transparent"
                    radius: 8

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: "#E3F2FD"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                source: "../../assets/icons/pickup.png"
                                width: 16; height: 16
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 32 - 10 - 12 - 12
                            spacing: 1

                            Text {
                                text: modelData.name
                                font.pixelSize: 13
                                font.bold: true
                                color: "#111"
                                width: parent.width
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.display_name
                                      ? modelData.display_name
                                      : ""
                                font.pixelSize: 11
                                color: "#888"
                                width: parent.width
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }
                    }

                    // thin row separator
                    Rectangle {
                        visible: index < pickupModel.length - 1
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 54
                        height: 1
                        color: "#F0F0F0"
                    }

                    MouseArea {
                        id: pickupItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            pickupTimer.stop()
                            appState.pickupLocation = modelData.name
                            appState.pickupLat      = modelData.lat
                            appState.pickupLon      = modelData.lon
                            pickupModel = []
                            pickupSearch.focus = false
                            pickupSearch.text  = modelData.name
                            pickupSearch.cursorPosition =
                                pickupSearch.text.length
                            console.log("Pickup set:",
                                appState.pickupLat, appState.pickupLon)
                        }
                    }
                }
            }
        }

        // ── DESTINATION DROPDOWN ──────────────────────────────────
        Rectangle {

            id: destinationDropdown

            x: searchCard.x + pageRoot.x
            y: destAnchor.mapToItem(pageRoot, 0, 0).y
            width: searchCard.width

            height: destinationModel.length > 0
                    ? Math.min(destinationModel.length * 52, 208)
                    : 0

            visible: destinationModel.length > 0
            z: 99999

            color: "white"
            border.color: "#C8C8C8"
            radius: 10

            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                radius: parent.radius + 1
                color: "transparent"
                border.color: "#22000000"
                z: -1
            }

            ListView {
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                model: destinationModel
                spacing: 0

                delegate: Rectangle {
                    width: parent.width
                    height: 52
                    color: destItemMouse.containsMouse
                           ? "#F0F4FF" : "transparent"
                    radius: 8

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: "#FFEBEE"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                source: "../../assets/icons/destination.png"
                                width: 16; height: 16
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 32 - 10 - 12 - 12
                            spacing: 1

                            Text {
                                text: modelData.name
                                font.pixelSize: 13
                                font.bold: true
                                color: "#111"
                                width: parent.width
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.display_name
                                      ? modelData.display_name
                                      : ""
                                font.pixelSize: 11
                                color: "#888"
                                width: parent.width
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }
                    }

                    Rectangle {
                        visible: index < destinationModel.length - 1
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 54
                        height: 1
                        color: "#F0F0F0"
                    }

                    MouseArea {
                        id: destItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            destinationTimer.stop()
                            appState.destinationLocation = modelData.name
                            appState.destinationLat      = modelData.lat
                            appState.destinationLon      = modelData.lon
                            destinationModel = []
                            destinationSearch.focus = false
                            destinationSearch.text  = modelData.name
                            destinationSearch.cursorPosition =
                                destinationSearch.text.length

                            // Save to recent places
                            saveRecentPlace(
                                modelData.name,
                                modelData.lat,
                                modelData.lon)

                            // Refresh the list
                            loadRecentPlaces()

                            console.log("Destination set:",
                                appState.destinationLat,
                                appState.destinationLon)
                        }
                    }
                }
            }
        }

        // ── Anchor helpers ────────────────────────────────────────
        // Zero-size Items inside the card give us a stable
        // mapToItem coordinate for the floating dropdowns.
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