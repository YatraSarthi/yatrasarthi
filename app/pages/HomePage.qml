import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var appStack
    property var appState

    property var pickupModel: []
    property var destinationModel: []

    property bool suppressPickupFetch: false
    property bool suppressDestinationFetch: false

    function fetchPickupSuggestions(query) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                pickupModel = JSON.parse(xhr.responseText)
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/search-location?query=" + encodeURIComponent(query), true)
        xhr.send()
    }

    function fetchDestinationSuggestions(query) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                destinationModel = JSON.parse(xhr.responseText)
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/search-location?query=" + encodeURIComponent(query), true)
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
                    source: "../../assets/icons/home.png"
                    width: 22
                    height: 22
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
                    source: "../../assets/icons/services.png"
                    width: 22
                    height: 22
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
                    source: "../../assets/icons/history.png"
                    width: 22
                    height: 22
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
                    source: "../../assets/icons/account.png"
                    width: 22
                    height: 22
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

    // ── Scrollable Body ───────────────────────────────────────────
    ScrollView {

        anchors.fill: parent
        contentWidth: parent.width
        clip: true

        ColumnLayout {

            width: parent.width
            spacing: 0

            // ── Header ───────────────────────────────────────────
            Rectangle {

                Layout.fillWidth: true
                height: 70

                color: "#1976D2"

                RowLayout {

                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20

                    Label {
                        text: "YatraSarthi"
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                        Layout.fillWidth: true
                    }

                    Image {
                        source: "../../assets/icons/account.png"
                        width: 32
                        height: 32
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }

            // ── Body padding wrapper ──────────────────────────────
            ColumnLayout {

                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 16

                // ── Current Location Card ─────────────────────────
                Rectangle {

                    Layout.fillWidth: true
                    height: 70
                    radius: 12
                    color: "#F5F5F5"
                    border.color: "#E0E0E0"

                    RowLayout {

                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Image {
                            source: "../../assets/icons/my_location.png"
                            width: 26
                            height: 26
                            fillMode: Image.PreserveAspectFit
                        }

                        Column {
                            spacing: 2
                            Label {
                                text: "Current Location"
                                font.pixelSize: 11
                                color: "#888"
                            }
                            Label {
                                text: appState.pickupLocation !== ""
                                      ? appState.pickupLocation
                                      : "Bengaluru, Karnataka"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#222"
                            }
                        }
                    }
                }

                // ── Search Card (Pickup + Destination) ───────────
                // Outer Item: never clips so both dropdowns overlay freely.
                Item {

                    Layout.fillWidth: true

                    // Base card is 130 px; each open dropdown adds
                    // up to 140 px so siblings are never obscured.
                    height: 130
                           + (pickupModel.length      > 0 ? Math.min(pickupModel.length      * 45, 140) : 0)
                           + (destinationModel.length > 0 ? Math.min(destinationModel.length * 45, 140) : 0)

                    // ── White card background ─────────────────────
                    Rectangle {
                        id: searchCard
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: 130
                        radius: 12
                        color: "white"
                        border.color: "#E0E0E0"

                        // drop-shadow
                        layer.enabled: true
                        layer.effect: null
                    }

                    // ── Pickup row ────────────────────────────────
                    RowLayout {

                        id: pickupRow

                        anchors.top: searchCard.top
                        anchors.topMargin: 14
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 14
                        anchors.rightMargin: 8
                        height: 44
                        spacing: 8

                        Rectangle {
                            width: 10; height: 10; radius: 5
                            color: "#1976D2"
                        }

                        TextField {

                            id: pickupSearch

                            Layout.fillWidth: true

                            text: appState.pickupLocation

                            placeholderText: "Pickup location"

                            background: Item {}   // transparent — card is the bg

                            font.pixelSize: 14

                            onTextChanged: {
                                if (suppressPickupFetch) {
                                    suppressPickupFetch = false
                                    return
                                }
                                if (!activeFocus) return
                                if (text.length > 2) pickupTimer.restart()
                            }
                        }

                        // Map button (pickup)
                        ToolButton {
                            implicitWidth: 36
                            implicitHeight: 36
                            onClicked: {
                                appState.activeSelection = "pickup"
                                appStack.push(Qt.resolvedUrl("MapPage.qml"),
                                    { "appStack": appStack, "appState": appState })
                            }
                            contentItem: Image {
                                source: "../../assets/icons/map.png"
                                width: 18; height: 18
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                            }
                        }
                    }

                    // ── Divider ───────────────────────────────────
                    Rectangle {
                        anchors.top: pickupRow.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        height: 1
                        color: "#EEEEEE"
                    }

                    // ── Destination row ───────────────────────────
                    RowLayout {

                        id: destinationRow

                        anchors.top: pickupRow.bottom
                        anchors.topMargin: 1      // sits right on divider
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 14
                        anchors.rightMargin: 8
                        height: 44
                        spacing: 8

                        Rectangle {
                            width: 10; height: 10; radius: 2
                            color: "#E53935"
                        }

                        TextField {

                            id: destinationSearch

                            Layout.fillWidth: true

                            text: appState.destinationLocation

                            placeholderText: "Where to?"

                            background: Item {}

                            font.pixelSize: 14

                            onTextChanged: {
                                if (suppressDestinationFetch) {
                                    suppressDestinationFetch = false
                                    return
                                }
                                if (!activeFocus) return
                                if (text.length > 2) destinationTimer.restart()
                            }
                        }

                        // Map button (destination)
                        ToolButton {
                            implicitWidth: 36
                            implicitHeight: 36
                            onClicked: {
                                appState.activeSelection = "destination"
                                appStack.push(Qt.resolvedUrl("MapPage.qml"),
                                    { "appStack": appStack, "appState": appState })
                            }
                            contentItem: Image {
                                source: "../../assets/icons/map.png"
                                width: 18; height: 18
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                            }
                        }
                    }

                    // ── Pickup dropdown ───────────────────────────
                    Rectangle {

                        anchors.top: searchCard.top
                        anchors.topMargin: 130     // flush below card
                        anchors.left: parent.left
                        anchors.right: parent.right

                        height: pickupModel.length > 0
                                ? Math.min(pickupModel.length * 45, 140)
                                : 0

                        visible: pickupModel.length > 0

                        z: 9999

                        color: "white"
                        border.color: "#D3D3D3"
                        radius: 8

                        ListView {
                            anchors.fill: parent
                            clip: true
                            model: pickupModel
                            delegate: Rectangle {
                                width: parent.width
                                height: 45
                                border.color: "#EEEEEE"
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    width: parent.width - 24
                                    text: modelData.name
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        pickupTimer.stop()
                                        appState.pickupLocation = modelData.name
                                        appState.pickupLat      = modelData.lat
                                        appState.pickupLon      = modelData.lon
                                        pickupModel = []
                                        pickupSearch.focus = false
                                        pickupSearch.text  = modelData.name
                                        pickupSearch.cursorPosition = pickupSearch.text.length
                                    }
                                }
                            }
                        }
                    }

                    // ── Destination dropdown ──────────────────────
                    Rectangle {

                        anchors.top: searchCard.top
                        anchors.topMargin: 130
                                         + (pickupModel.length > 0
                                            ? Math.min(pickupModel.length * 45, 140)
                                            : 0)
                        anchors.left: parent.left
                        anchors.right: parent.right

                        height: destinationModel.length > 0
                                ? Math.min(destinationModel.length * 45, 140)
                                : 0

                        visible: destinationModel.length > 0

                        z: 9999

                        color: "white"
                        border.color: "#D3D3D3"
                        radius: 8

                        ListView {
                            anchors.fill: parent
                            clip: true
                            model: destinationModel
                            delegate: Rectangle {
                                width: parent.width
                                height: 45
                                border.color: "#EEEEEE"
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    width: parent.width - 24
                                    text: modelData.name
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        destinationTimer.stop()
                                        appState.destinationLocation = modelData.name
                                        appState.destinationLat      = modelData.lat
                                        appState.destinationLon      = modelData.lon
                                        destinationModel = []
                                        destinationSearch.focus = false
                                        destinationSearch.text  = modelData.name
                                        destinationSearch.cursorPosition = destinationSearch.text.length
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Get My Location button ────────────────────────
                Button {

                    Layout.fillWidth: true
                    height: 38

                    onClicked: {
                        appState.pickupLocation = "Bengaluru, Karnataka"
                    }

                    background: Rectangle {
                        color: "#E3F2FD"
                        radius: 8
                        border.color: "#90CAF9"
                    }

                    contentItem: Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            source: "../../assets/icons/my_location.png"
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

                // ── Find Ride button ──────────────────────────────
                Button {

                    Layout.fillWidth: true
                    height: 52

                    onClicked: {
                        if (appState.pickupLocation === ""
                                || appState.destinationLocation === "") {
                            console.log("Select both locations")
                            return
                        }
                        appStack.push(Qt.resolvedUrl("ResultsPage.qml"),
                            { "appStack": appStack, "appState": appState })
                    }

                    background: Rectangle {
                        color: "#1976D2"
                        radius: 12
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

                // ── Quick Actions ─────────────────────────────────
                Label {
                    text: "Quick Actions"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#222"
                    Layout.topMargin: 4
                }

                GridLayout {

                    Layout.fillWidth: true
                    columns: 4
                    rowSpacing: 10
                    columnSpacing: 10

                    // SOS
                    Button {
                        Layout.fillWidth: true
                        height: 70
                        onClicked: { /* SOS action */ }
                        background: Rectangle {
                            color: "#FFEBEE"
                            radius: 12
                            border.color: "#FFCDD2"
                        }
                        contentItem: Column {
                            anchors.centerIn: parent
                            spacing: 4
                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: "../../assets/icons/sos.png"
                                width: 26; height: 26
                                fillMode: Image.PreserveAspectFit
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "SOS"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#E53935"
                            }
                        }
                    }

                    // History
                    Button {
                        Layout.fillWidth: true
                        height: 70
                        onClicked: { /* History action */ }
                        background: Rectangle {
                            color: "#E8F5E9"
                            radius: 12
                            border.color: "#C8E6C9"
                        }
                        contentItem: Column {
                            anchors.centerIn: parent
                            spacing: 4
                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: "../../assets/icons/history.png"
                                width: 26; height: 26
                                fillMode: Image.PreserveAspectFit
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "History"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#388E3C"
                            }
                        }
                    }

                    // Queue
                    Button {
                        Layout.fillWidth: true
                        height: 70
                        onClicked: { /* Queue action */ }
                        background: Rectangle {
                            color: "#FFF8E1"
                            radius: 12
                            border.color: "#FFE082"
                        }
                        contentItem: Column {
                            anchors.centerIn: parent
                            spacing: 4
                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: "../../assets/icons/star.png"
                                width: 26; height: 26
                                fillMode: Image.PreserveAspectFit
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Queue"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#F9A825"
                            }
                        }
                    }

                    // Route
                    Button {
                        Layout.fillWidth: true
                        height: 70
                        onClicked: { /* Route action */ }
                        background: Rectangle {
                            color: "#E3F2FD"
                            radius: 12
                            border.color: "#90CAF9"
                        }
                        contentItem: Column {
                            anchors.centerIn: parent
                            spacing: 4
                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: "../../assets/icons/map.png"
                                width: 26; height: 26
                                fillMode: Image.PreserveAspectFit
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Route"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#1976D2"
                            }
                        }
                    }
                }

                // ── Recent Places ─────────────────────────────────
                Label {
                    text: "Recent Places"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#222"
                    Layout.topMargin: 4
                }

                Rectangle {

                    Layout.fillWidth: true
                    height: recentColumn.implicitHeight + 20
                    radius: 12
                    color: "white"
                    border.color: "#E0E0E0"

                    Column {

                        id: recentColumn

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 0

                        Repeater {

                            model: [
                                "REVA University",
                                "Majestic Bus Stand",
                                "Kempegowda Airport"
                            ]

                            delegate: Rectangle {

                                width: parent.width
                                height: 48

                                color: recentMouse.containsMouse
                                       ? "#F5F5F5"
                                       : "transparent"

                                radius: 8

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 4
                                    anchors.rightMargin: 4
                                    spacing: 12

                                    Image {
                                        source: "../../assets/icons/destination.png"
                                        width: 18; height: 18
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    Label {
                                        text: modelData
                                        font.pixelSize: 14
                                        color: "#333"
                                        Layout.fillWidth: true
                                    }

                                    Image {
                                        source: "../../assets/icons/map.png"
                                        width: 14; height: 14
                                        fillMode: Image.PreserveAspectFit
                                        opacity: 0.4
                                    }
                                }

                                // Divider (skip last)
                                Rectangle {
                                    visible: index < 2
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 34
                                    height: 1
                                    color: "#EEEEEE"
                                }

                                MouseArea {
                                    id: recentMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        appState.destinationLocation = modelData
                                        destinationSearch.text = modelData
                                    }
                                }
                            }
                        }
                    }
                }

                // bottom breathing room
                Item { Layout.preferredHeight: 12 }
            }
        }
    }
}