import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    // Hide bottom bar while on this page
    Component.onCompleted:  { if (appState) appState.showBottomBar = false }
    Component.onDestruction:{ if (appState) appState.showBottomBar = true  }

    // ── Root background ──────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#F4F6F9"
    }

    // ── Floating header overlay ──────────────────────────────────────────────
    Rectangle {
        anchors {
            top:   parent.top
            left:  parent.left
            right: parent.right
        }
        height: 52
        color:  "#CC000000"
        z:      10

        Row {
            anchors.fill:        parent
            anchors.leftMargin:  8
            anchors.rightMargin: 8
            spacing: 8

            Rectangle {
                width:  36
                height: 36
                radius: 18
                color:  "#33FFFFFF"
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text:           "←"
                    color:          "white"
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        while (appStack.depth > 1)
                            appStack.pop()
                    }
                }
            }

            Label {
                text:           "Ride Completed"
                color:          "white"
                font.pixelSize: 18
                font.bold:      true
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
            topPadding:    52   // clears the floating header
            bottomPadding: 24

            // ── CARDS AREA ───────────────────────────────────────────────────
            Column {
                width:        parent.width
                spacing:      10
                topPadding:   12
                leftPadding:  12
                rightPadding: 12

                // ── Success card ─────────────────────────────────────────────
                Rectangle {
                    width:  parent.width
                    height: 100
                    radius: 14
                    color:  "#4CAF50"

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:           "Destination Reached"
                            color:          "white"
                            font.pixelSize: 22
                            font.bold:      true
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:           "Thank you for riding with YatraSarthi"
                            color:          "white"
                            font.pixelSize: 14
                        }
                    }
                }

                // ── Ride summary card ─────────────────────────────────────────
                Rectangle {
                    width:        parent.width
                    height:       summaryCol.implicitHeight + 24
                    radius:       14
                    color:        "white"
                    border.color: "#E8E8E8"

                    Column {
                        id: summaryCol
                        anchors {
                            top:         parent.top
                            left:        parent.left
                            right:       parent.right
                            topMargin:   12
                            leftMargin:  14
                            rightMargin: 14
                        }
                        spacing: 10

                        Label {
                            text:           "Ride Summary"
                            font.pixelSize: 17
                            font.bold:      true
                            color:          "#1A1A1A"
                        }

                        // Pickup row
                        Row {
                            spacing: 6
                            width: parent.width

                            Rectangle {
                                width: 8; height: 8; radius: 4
                                color: "#1976D2"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text:      appState.pickupLocation
                                font.pixelSize: 13
                                color:     "#333"
                                wrapMode:  Text.WordWrap
                                width:     parent.width - 14
                                elide:     Text.ElideRight
                            }
                        }

                        // Destination row
                        Row {
                            spacing: 6
                            width: parent.width

                            Rectangle {
                                width: 8; height: 8; radius: 2
                                color: "#E53935"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text:      appState.destinationLocation
                                font.pixelSize: 13
                                color:     "#333"
                                wrapMode:  Text.WordWrap
                                width:     parent.width - 14
                                elide:     Text.ElideRight
                            }
                        }

                        Rectangle {
                            width:  parent.width
                            height: 1
                            color:  "#F0F0F0"
                        }

                        // Vehicle
                        Row {
                            width: parent.width
                            Label {
                                text:           "Vehicle"
                                font.pixelSize: 13
                                color:          "#888"
                                width:          parent.width / 2
                            }
                            Label {
                                text:           appState.selectedVehicle
                                font.pixelSize: 13
                                color:          "#1A1A1A"
                                font.bold:      true
                            }
                        }

                        // Distance
                        Row {
                            width: parent.width
                            Label {
                                text:           "Distance"
                                font.pixelSize: 13
                                color:          "#888"
                                width:          parent.width / 2
                            }
                            Label {
                                text:           appState.selectedDistance + " km"
                                font.pixelSize: 13
                                color:          "#1A1A1A"
                                font.bold:      true
                            }
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
                            left:          parent.left
                            right:         parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin:    16
                            rightMargin:   16
                        }

                        Label {
                            text:           "Fare Paid"
                            font.pixelSize: 15
                            color:          "#555555"
                        }

                        Item { width: parent.width - farePaidLabel.implicitWidth - 80; height: 1 }

                        Label {
                            id:             farePaidLabel
                            text:           "₹" + appState.selectedFare
                            font.pixelSize: 26
                            font.bold:      true
                            color:          "#1976D2"
                        }
                    }
                }

                // ── Rate your Sarthi card ─────────────────────────────────────
                Rectangle {
                    width:        parent.width
                    height:       rateCol.implicitHeight + 24
                    radius:       14
                    color:        "#FFF8E1"
                    border.color: "#FFD54F"

                    Column {
                        id: rateCol
                        anchors {
                            top:         parent.top
                            left:        parent.left
                            right:       parent.right
                            topMargin:   12
                            leftMargin:  14
                            rightMargin: 14
                        }
                        spacing: 10

                        Label {
                            text:           "Rate Your Sarthi"
                            font.pixelSize: 16
                            font.bold:      true
                            color:          "#1A1A1A"
                        }

                        Row {
                            spacing: 8
                            Repeater {
                                model: 5
                                Label {
                                    text:           "★"
                                    font.pixelSize: 32
                                    color:          "#FFC107"
                                }
                            }
                        }
                    }
                }

                // ── Back to Home button ───────────────────────────────────────
                Rectangle {
                    width:  parent.width
                    height: 52
                    radius: 14
                    color:  "#1976D2"

                    Label {
                        anchors.centerIn: parent
                        text:           "Back To Home"
                        color:          "white"
                        font.pixelSize: 16
                        font.bold:      true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            while (appStack.depth > 1)
                                appStack.pop()
                        }
                    }
                }

                Item { height: 8 }
            }
        }
    }
}