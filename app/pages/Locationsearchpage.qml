import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var    appStack
    property var    appState
    property string mode: "pickup"

    header: null
    footer: null

    property var suggestions: []

    function fetchSuggestions(query) {
        if (query.length < 2) { suggestions = []; return }
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200)
                suggestions = JSON.parse(xhr.responseText)
        }
        xhr.open("GET",
            "http://127.0.0.1:8000/search-location?query="
            + encodeURIComponent(query), true)
        xhr.send()
    }

    Timer {
        id:       searchTimer
        interval: 400
        repeat:   false
        onTriggered: fetchSuggestions(searchField.text)
    }

    Rectangle { anchors.fill: parent; color: "#F4F6F9" }

    Column {
        anchors.fill: parent
        spacing:      0

        // ── Top bar ──────────────────────────────────────────────
        Rectangle {
            width:  parent.width
            height: 64
            color:  "#1976D2"

            Row {
                anchors.fill:        parent
                anchors.leftMargin:  8
                anchors.rightMargin: 12
                spacing: 8

                Rectangle {
                    width:  40; height: 40; radius: 20
                    color:  "#33FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        anchors.centerIn: parent
                        text: "←"; color: "white"; font.pixelSize: 20
                    }
                    MouseArea { anchors.fill: parent; onClicked: appStack.pop() }
                }

                Rectangle {
                    width:  parent.width - 40 - 8 - 8
                    height: 42; radius: 10; color: "white"
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.fill:        parent
                        anchors.leftMargin:  10
                        anchors.rightMargin: 8
                        spacing: 8

                        Rectangle {
                            width:  10; height: 10
                            radius: mode === "pickup" ? 5 : 2
                            color:  mode === "pickup" ? "#1976D2" : "#E53935"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextField {
                            id:          searchField
                            width:       parent.width - 10 - 8 - 28 - 16
                            height:      parent.height
                            background:  Item {}
                            font.pixelSize: 15
                            color:       "#1A1A1A"
                            placeholderText: mode === "pickup"
                                ? "Enter pickup location"
                                : "Enter destination"
                            verticalAlignment: Text.AlignVCenter
                            onTextChanged: searchTimer.restart()
                            Component.onCompleted: forceActiveFocus()
                        }

                        Rectangle {
                            width:   28; height: 28; radius: 14
                            color:   searchField.text.length > 0 ? "#E0E0E0" : "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            visible: searchField.text.length > 0
                            Label {
                                anchors.centerIn: parent
                                text: "✕"; font.pixelSize: 13; color: "#555"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { searchField.text = ""; suggestions = [] }
                            }
                        }
                    }
                }
            }
        }

        // ── Select on Map row ─────────────────────────────────────
        Rectangle {
            width:  parent.width
            height: 56
            color:  mapRowMouse.containsMouse ? "#EEF4FF" : "white"
            border.color: "#E8E8E8"

            Row {
                anchors.fill:        parent
                anchors.leftMargin:  16
                anchors.rightMargin: 16
                spacing: 14

                Rectangle {
                    width:  38; height: 38; radius: 19
                    color:  mode === "pickup" ? "#E3F2FD" : "#FFEBEE"
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        anchors.centerIn: parent
                        source:   "../../assets/icons/map.png"
                        width:    20; height: 20
                        fillMode: Image.PreserveAspectFit
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text:           "Select on Map"
                        font.pixelSize: 14; font.bold: true; color: "#1A1A1A"
                    }
                    Text {
                        text:           mode === "pickup"
                                        ? "Pin your pickup location"
                                        : "Pin your destination"
                        font.pixelSize: 12; color: "#888888"
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1; color: "#E0E0E0"
            }

            MouseArea {
                id:           mapRowMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    searchTimer.stop()
                    appState.activeSelection = mode
                    appStack.push(
                        Qt.resolvedUrl("MapPage.qml"),
                        { "appStack": appStack,
                          "appState": appState,
                          "deepPush": true })
                }
            }
        }

        // ── Suggestions list ──────────────────────────────────────
        ListView {
            id:     suggestionList
            width:  parent.width
            height: parent.height - 64 - 56
            clip:   true
            model:  suggestions

            Label {
                anchors.centerIn: parent
                visible:        suggestions.length === 0 && searchField.text.length === 0
                text:           "Start typing to search"
                color:          "#AAAAAA"; font.pixelSize: 15
            }

            Label {
                anchors.centerIn: parent
                visible:        suggestions.length === 0 && searchField.text.length > 1
                text:           "No results found"
                color:          "#AAAAAA"; font.pixelSize: 15
            }

            delegate: Rectangle {
                width:  suggestionList.width
                height: 64
                color:  itemMouse.containsMouse ? "#EEF4FF" : "white"

                Rectangle {
                    width:  4; height: parent.height
                    color:  mode === "pickup" ? "#1976D2" : "#E53935"
                    opacity: itemMouse.containsMouse ? 1 : 0
                }

                Row {
                    anchors.fill:        parent
                    anchors.leftMargin:  16
                    anchors.rightMargin: 16
                    spacing: 14

                    Rectangle {
                        width:  38; height: 38; radius: 19
                        color:  mode === "pickup" ? "#E3F2FD" : "#FFEBEE"
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            anchors.centerIn: parent
                            source:   mode === "pickup"
                                      ? "../../assets/icons/pickup.png"
                                      : "../../assets/icons/destination.png"
                            width: 18; height: 18; fillMode: Image.PreserveAspectFit
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width:   parent.width - 38 - 14 - 32 - 14
                        spacing: 2
                        Text {
                            text:           modelData.name.split(",")[0].trim()
                            font.pixelSize: 14; font.bold: true; color: "#1A1A1A"
                            width:          parent.width; elide: Text.ElideRight
                        }
                        Text {
                            text:           modelData.name.split(",").slice(1, 3).join(",").trim()
                            font.pixelSize: 12; color: "#888888"
                            width:          parent.width; elide: Text.ElideRight
                        }
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "›"; font.pixelSize: 22; color: "#CCCCCC"
                    }
                }

                Rectangle {
                    anchors.bottom:     parent.bottom
                    anchors.left:       parent.left; anchors.right: parent.right
                    anchors.leftMargin: 68
                    height: 1; color: "#F0F0F0"
                }

                MouseArea {
                    id:           itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        searchTimer.stop()
                        if (mode === "pickup") {
                            appState.pickupLocation = modelData.name
                            appState.pickupLat      = modelData.lat
                            appState.pickupLon      = modelData.lon
                        } else {
                            appState.destinationLocation    = modelData.name
                            appState.destinationFullAddress = modelData.name
                            appState.destinationLat         = modelData.lat
                            appState.destinationLon         = modelData.lon
                            var xhr = new XMLHttpRequest()
                            xhr.open("POST",
                                "http://127.0.0.1:8000/recent-places"
                                + "?name=" + encodeURIComponent(modelData.name)
                                + "&lat="  + modelData.lat
                                + "&lon="  + modelData.lon, true)
                            xhr.send()
                        }
                        appStack.pop()
                    }
                }
            }
        }
    }
}