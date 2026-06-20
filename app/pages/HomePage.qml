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

        TTextField {

    id: pickupSearch

    Layout.fillWidth: true

    text: appState.pickupLocation

    placeholderText:
        "Search Pickup Location"

    onTextChanged: {

        if (text.length > 2)
            pickupTimer.restart()
    }
}

ListView {

    Layout.fillWidth: true

    height: pickupModel.length > 0
            ? 120
            : 0

    model: pickupModel

    delegate: Rectangle {

        width: parent.width

        height: 40

        border.color: "#E0E0E0"

        Text {

            anchors.centerIn: parent

            text: modelData.name

            width: parent.width - 20

            elide: Text.ElideRight
        }

        MouseArea {

            anchors.fill: parent

            onClicked: {

                pickupSearch.text =
                    modelData.name

                appState.pickupLocation =
                    modelData.name

                appState.pickupLat =
                    modelData.lat

                appState.pickupLon =
                    modelData.lon

                pickupModel = []
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

        TextField {

    id: destinationSearch

    Layout.fillWidth: true

    text:
        appState.destinationLocation

    placeholderText:
        "Search Destination"

    onTextChanged: {

        if (text.length > 2)
            destinationTimer.restart()
    }
}

ListView {

    Layout.fillWidth: true

    height: destinationModel.length > 0
            ? 120
            : 0

    model: destinationModel

    delegate: Rectangle {

        width: parent.width

        height: 40

        border.color: "#E0E0E0"

        Text {

            anchors.centerIn: parent

            text: modelData.name

            width: parent.width - 20

            elide: Text.ElideRight
        }

        MouseArea {

            anchors.fill: parent

            onClicked: {

                destinationSearch.text =
                    modelData.name

                appState.destinationLocation =
                    modelData.name

                appState.destinationLat =
                    modelData.lat

                appState.destinationLon =
                    modelData.lon

                destinationModel = []
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
