import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: editProfilePage
    title: "Edit Profile"

    background: Rectangle { color: "#F5F5F5" }

    // Header
    header: Rectangle {
        width: parent.width
        height: 56
        color: "#2196F3"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16

            ToolButton {
                contentItem: Text {
                    text: "‹"
                    color: "white"
                    font.pixelSize: 28
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: stackView.pop()
            }

            Text {
                text: "Edit Profile"
                color: "white"
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
            }

            Button {
                text: "Save"
                flat: true
                contentItem: Text {
                    text: "Save"
                    color: "white"
                    font.pixelSize: 15
                    font.bold: true
                }
                onClicked: {
                    // Save logic here
                    stackView.pop()
                }
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width

        Column {
            width: editProfilePage.width
            spacing: 0

            // Avatar section
            Rectangle {
                width: parent.width
                height: 140
                color: "#2196F3"

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        width: 80
                        height: 80
                        radius: 40
                        color: "#1565C0"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "👤"
                            font.pixelSize: 36
                        }

                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: "#FFC107"
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom

                            Text {
                                anchors.centerIn: parent
                                text: "✏"
                                font.pixelSize: 12
                            }
                        }
                    }

                    Text {
                        text: "Tap to change photo"
                        color: "white"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Item { width: 1; height: 16 }

            // Form fields
            Rectangle {
                width: parent.width - 32
                x: 16
                height: formColumn.implicitHeight + 32
                radius: 12
                color: "white"

                Column {
                    id: formColumn
                    width: parent.width - 32
                    x: 16
                    y: 16
                    spacing: 20

                    // Full Name
                    Column {
                        width: parent.width
                        spacing: 6
                        Text { text: "Full Name"; color: "#757575"; font.pixelSize: 12 }
                        TextField {
                            width: parent.width
                            text: "Johney"
                            font.pixelSize: 15
                            placeholderText: "Enter your name"
                            background: Rectangle {
                                radius: 8
                                color: "#F5F5F5"
                                border.color: parent.activeFocus ? "#2196F3" : "transparent"
                                border.width: 1.5
                            }
                        }
                    }

                    // Phone
                    Column {
                        width: parent.width
                        spacing: 6
                        Text { text: "Phone Number"; color: "#757575"; font.pixelSize: 12 }
                        TextField {
                            width: parent.width
                            text: "+91 98765 43210"
                            font.pixelSize: 15
                            readOnly: true
                            placeholderText: "Phone number"
                            background: Rectangle {
                                radius: 8
                                color: "#EEEEEE"
                            }
                            rightPadding: verifiedLabel.width + 12
                            Text {
                                id: verifiedLabel
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: "✓ Verified"
                                color: "#4CAF50"
                                font.pixelSize: 12
                            }
                        }
                    }

                    // Email
                    Column {
                        width: parent.width
                        spacing: 6
                        Text { text: "Email Address"; color: "#757575"; font.pixelSize: 12 }
                        TextField {
                            width: parent.width
                            text: ""
                            font.pixelSize: 15
                            placeholderText: "Add email address"
                            background: Rectangle {
                                radius: 8
                                color: "#F5F5F5"
                                border.color: parent.activeFocus ? "#2196F3" : "transparent"
                                border.width: 1.5
                            }
                        }
                    }

                    // Date of Birth
                    Column {
                        width: parent.width
                        spacing: 6
                        Text { text: "Date of Birth"; color: "#757575"; font.pixelSize: 12 }
                        TextField {
                            width: parent.width
                            placeholderText: "DD / MM / YYYY"
                            font.pixelSize: 15
                            background: Rectangle {
                                radius: 8
                                color: "#F5F5F5"
                                border.color: parent.activeFocus ? "#2196F3" : "transparent"
                                border.width: 1.5
                            }
                        }
                    }

                    // Gender
                    Column {
                        width: parent.width
                        spacing: 6
                        Text { text: "Gender"; color: "#757575"; font.pixelSize: 12 }
                        Row {
                            spacing: 12
                            Repeater {
                                model: ["Male", "Female", "Other"]
                                delegate: Rectangle {
                                    width: (formColumn.width - 24) / 3
                                    height: 40
                                    radius: 20
                                    color: index === 0 ? "#E3F2FD" : "#F5F5F5"
                                    border.color: index === 0 ? "#2196F3" : "transparent"
                                    border.width: 1.5
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 14
                                        color: index === 0 ? "#2196F3" : "#333"
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 24 }

            // Delete account option
            Rectangle {
                width: parent.width - 32
                x: 16
                height: 52
                radius: 12
                color: "white"
                border.color: "#FFCDD2"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Delete Account"
                    color: "#F44336"
                    font.pixelSize: 15
                }

                MouseArea { anchors.fill: parent; onClicked: {} }
            }

            Item { width: 1; height: 32 }
        }
    }
}
