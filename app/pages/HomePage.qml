import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var appStack
    property var appState

    property var pickupModel: []
    property var destinationModel: []

    function fetchPickupSuggestions(query) {

    var xhr = new XMLHttpRequest()

    xhr.onreadystatechange = function() {

        if (
            xhr.readyState === XMLHttpRequest.DONE &&
            xhr.status === 200
        ) {

            pickupModel =
                JSON.parse(
                    xhr.responseText
                )
        }
    }

    xhr.open(
        "GET",
        "http://127.0.0.1:8000/search-location?query="
        + encodeURIComponent(query),
        true
    )

    xhr.send()
}

function fetchDestinationSuggestions(query) {

    var xhr = new XMLHttpRequest()

    xhr.onreadystatechange = function() {

        if (
            xhr.readyState === XMLHttpRequest.DONE &&
            xhr.status === 200
        ) {

            destinationModel =
                JSON.parse(
                    xhr.responseText
                )
        }
    }

    xhr.open(
        "GET",
        "http://127.0.0.1:8000/search-location?query="
        + encodeURIComponent(query),
        true
    )

    xhr.send()
}

Timer {

    id: pickupTimer

    interval: 800

    repeat: false

    onTriggered: {

        fetchPickupSuggestions(
            pickupSearch.text
        )
    }
}

Timer {

    id: destinationTimer

    interval: 800

    repeat: false

    onTriggered: {

        fetchDestinationSuggestions(
            destinationSearch.text
        )
    }
}
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Label {
            text: "YatraSarthi"

            font.pixelSize: 26
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.preferredHeight: 20
        }

        /*
         * PICKUP
         */

        RowLayout {
            spacing: 8

            Image {
                source: "../../assets/icons/pickup.png"

                width: 22
                height: 22

                fillMode: Image.PreserveAspectFit
            }

            Label {
                text: "Pickup"

                font.bold: true
                font.pixelSize: 15
            }
        }

        // Fix: TextField + dropdown Rectangle merged into a single
        // Item container. Previously these were two separate
        // ColumnLayout children, so the dropdown's height was added
        // to the layout's flow and physically pushed every item below
        // it (including the Buttons row) further down the page.
        // As one Item, the dropdown Rectangle anchors to the
        // TextField's bottom and overlays on top of the layout
        // instead of expanding it.
        Item {

            Layout.fillWidth: true

            height:
                pickupModel.length > 0
                ? 190
                : 50

            TextField {

                id: pickupSearch

                anchors.left: parent.left
                anchors.right: parent.right

                text: appState.pickupLocation

                placeholderText:
                    "Search Pickup Location"

                onTextChanged: {

                    if (!activeFocus)
                        return

                    if (text.length > 2)
                        pickupTimer.restart()
                }
            }

            Rectangle {

                anchors.top:
                    pickupSearch.bottom

                anchors.left:
                    parent.left

                width: parent.width

                height:
                    pickupModel.length > 0
                    ? 140
                    : 0

                visible:
                    pickupModel.length > 0

                z: 9999

                color: "white"

                border.color: "#D3D3D3"

                ListView {

                    anchors.fill: parent

                    clip: true

                    model: pickupModel

                    delegate: Rectangle {

                        width: parent.width
                        height: 45

                        border.color: "#EEEEEE"

                        Text {

                            anchors.verticalCenter:
                                parent.verticalCenter

                            anchors.left:
                                parent.left

                            anchors.leftMargin: 10

                            width:
                                parent.width - 20

                            text:
                                modelData.name

                            elide:
                                Text.ElideRight
                        }

                        MouseArea {

                            anchors.fill: parent

                            onClicked: {

                                pickupSearch.focus = false

                                pickupTimer.stop()

                                appState.pickupLocation =
                                    modelData.name

                                appState.pickupLat =
                                    modelData.lat

                                appState.pickupLon =
                                    modelData.lon

                                pickupModel = []

                                // Prevents Qt from re-focusing the field
                                // and immediately reopening the dropdown
                                // (the double-click-to-select bug).
                                pickupSearch.cursorPosition =
                                    pickupSearch.text.length

                                pickupSearch.text =
                                    modelData.name
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 6

            Button {

                onClicked: {

                    appState.pickupLocation =
                            "Bengaluru, Karnataka"
                }

                contentItem: Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Image {
                        source: "../../assets/icons/my_location.png"

                        width: 16
                        height: 16

                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "Get My Location"

                        font.pixelSize: 13
                    }
                }
            }

            Button {

                onClicked: {

                    appState.activeSelection = "pickup"

                    appStack.push(
                        Qt.resolvedUrl("MapPage.qml"),
                        {
                            "appStack": appStack,
                            "appState": appState
                        }
                    )
                }

                contentItem: Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Image {
                        source: "../../assets/icons/map.png"

                        width: 16
                        height: 16

                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "Show Map"

                        font.pixelSize: 13
                    }
                }
            }
        }

        /*
         * DESTINATION
         */

        Item {
            Layout.preferredHeight: 10
        }

        RowLayout {
            spacing: 8

            Image {
                source: "../../assets/icons/destination.png"

                width: 22
                height: 22

                fillMode: Image.PreserveAspectFit
            }

            Label {
                text: "Destination"

                font.bold: true
                font.pixelSize: 15
            }
        }

        // Same fix as Pickup above: TextField + dropdown Rectangle
        // merged into a single Item so the suggestion list overlays
        // instead of pushing the layout below it.
        Item {

            Layout.fillWidth: true

            height:
                destinationModel.length > 0
                ? 190
                : 50

            TextField {

                id: destinationSearch

                anchors.left: parent.left
                anchors.right: parent.right

                text:
                    appState.destinationLocation

                placeholderText:
                    "Search Destination"

                onTextChanged: {

                    if (!activeFocus)
                        return

                    if (text.length > 2)
                        destinationTimer.restart()
                }
            }

            Rectangle {

                anchors.top:
                    destinationSearch.bottom

                anchors.left:
                    parent.left

                width: parent.width

                height:
                    destinationModel.length > 0
                    ? 140
                    : 0

                visible:
                    destinationModel.length > 0

                z: 9999

                color: "white"

                border.color: "#D3D3D3"

                ListView {

                    anchors.fill: parent

                    clip: true

                    model: destinationModel

                    delegate: Rectangle {

                        width: parent.width
                        height: 45

                        border.color: "#EEEEEE"

                        Text {

                            anchors.verticalCenter:
                                parent.verticalCenter

                            anchors.left:
                                parent.left

                            anchors.leftMargin: 10

                            width:
                                parent.width - 20

                            text:
                                modelData.name

                            elide:
                                Text.ElideRight
                        }

                        MouseArea {

                            anchors.fill: parent

                            onClicked: {

                                destinationSearch.focus = false

                                destinationTimer.stop()

                                appState.destinationLocation =
                                    modelData.name

                                appState.destinationLat =
                                    modelData.lat

                                appState.destinationLon =
                                    modelData.lon

                                destinationModel = []

                                // Prevents Qt from re-focusing the field
                                // and immediately reopening the dropdown
                                // (the double-click-to-select bug).
                                destinationSearch.cursorPosition =
                                    destinationSearch.text.length

                                destinationSearch.text =
                                    modelData.name
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight

            Button {

                onClicked: {

                    appState.activeSelection = "destination"

                    appStack.push(
                        Qt.resolvedUrl("MapPage.qml"),
                        {
                            "appStack": appStack,
                            "appState": appState
                        }
                    )
                }

                contentItem: Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Image {
                        source: "../../assets/icons/map.png"

                        width: 16
                        height: 16

                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "Show Map"

                        font.pixelSize: 13
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        /*
         * FIND RIDE
         */

        Button {

            Layout.alignment: Qt.AlignHCenter

            width: 140
            height: 45

            onClicked: {

                if (appState.pickupLocation === ""
                        || appState.destinationLocation === "") {

                    console.log("Select both locations")
                    return
                }

                appStack.push(
                    Qt.resolvedUrl("ResultsPage.qml"),
                    {
                        "appStack": appStack,
                        "appState": appState
                    }
                )
            }

            contentItem: Row {
                anchors.centerIn: parent
                spacing: 8

                Image {
                    source: "../../assets/icons/rider.png"

                    width: 30
                    height: 30

                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    text: "Find Ride"

                    font.pixelSize: 15
                    font.bold: true
                }
            }
        }

        Item {
            Layout.preferredHeight: 20
        }
    }
}
