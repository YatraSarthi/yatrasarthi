import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    footer: null

    property var profileItems: [
        { icon: "../../assets/icons/driver.png",
          label: "Edit Profile",    sub: "Name, photo, email" },
        { icon: "../../assets/icons/star.png",
          label: "Payment Methods", sub: "UPI, cards, wallets" },
        { icon: "../../assets/icons/sos.png",
          label: "Emergency Contacts", sub: "SOS contacts" }
    ]

    property var preferenceItems: [
        { icon: "../../assets/icons/destination.png",
          label: "Notifications",   sub: "Ride alerts, offers" },
        { icon: "../../assets/icons/map.png",
          label: "Language",        sub: "English" },
        { icon: "../../assets/icons/star.png",
          label: "Dark Mode",       sub: "Off" }
    ]

    property var supportItems: [
        { icon: "../../assets/icons/rider.png",
          label: "Help & Support",  sub: "FAQs, chat" },
        { icon: "../../assets/icons/star.png",
          label: "Rate the App",    sub: "Tell us what you think" },
        { icon: "../../assets/icons/map.png",
          label: "Privacy Policy",  sub: "" }
    ]

    ScrollView {
        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {
            width: parent.width
            spacing: 0

            // ── Profile header — clip the deco circle ─────────────
            Rectangle {
                width: parent.width
                height: 150
                color: "#1976D2"
                // FIX: clip stops yellow circle going outside header
                clip: true

                Rectangle {
                    width: 160; height: 160; radius: 80
                    color: "#ffffff15"
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: -50
                    anchors.bottomMargin: -50
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        width: 68; height: 68; radius: 34
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Image {
                            source: "../../assets/icons/driver.png"
                            width: 38; height: 38
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                        }
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Johney"
                        font.pixelSize: 17; font.bold: true
                        color: "white"
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "+91 98765 43210"
                        font.pixelSize: 12; color: "#B3E5FC"
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 14

                Item { width: 1; height: 14 }

                // Section builder — 3 explicit sections to avoid
                // nested-array parser errors
                Repeater {
                    model: [
                        { title: "PROFILE",     items: profileItems },
                        { title: "PREFERENCES", items: preferenceItems },
                        { title: "SUPPORT",     items: supportItems }
                    ]

                    delegate: Column {
                        x: 16
                        width: parent.width - 32
                        spacing: 6

                        Label {
                            text: modelData.title
                            font.pixelSize: 11; font.bold: true
                            color: "#AAAAAA"; leftPadding: 4
                        }

                        Rectangle {
                            width: parent.width
                            height: modelData.items.length * 60
                            radius: 14; color: "white"
                            border.color: "#EEEEEE"; clip: true

                            Column {
                                width: parent.width
                                spacing: 0

                                Repeater {
                                    model: modelData.items

                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 60
                                        color: rMouse.containsMouse
                                               ? "#F8F8F8"
                                               : "transparent"

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 16
                                            anchors.rightMargin: 16
                                            spacing: 14

                                            Rectangle {
                                                width: 36; height: 36
                                                radius: 18
                                                color: "#F5F5F5"
                                                anchors.verticalCenter:
                                                    parent.verticalCenter

                                                Image {
                                                    source: modelData.icon
                                                    width: 20; height: 20
                                                    fillMode:
                                                        Image.PreserveAspectFit
                                                    anchors.centerIn:
                                                        parent
                                                }
                                            }

                                            Column {
                                                anchors.verticalCenter:
                                                    parent.verticalCenter
                                                spacing: 2
                                                width: parent.width
                                                       - 36 - 14
                                                       - 20 - 32

                                                Label {
                                                    text: modelData.label
                                                    font.pixelSize: 14
                                                    color: "#111"
                                                }
                                                Label {
                                                    text: modelData.sub
                                                    font.pixelSize: 11
                                                    color: "#AAA"
                                                    visible:
                                                        modelData.sub
                                                        !== ""
                                                }
                                            }

                                            Text {
                                                text: "›"
                                                font.pixelSize: 22
                                                color: "#CCCCCC"
                                                anchors.verticalCenter:
                                                    parent.verticalCenter
                                            }
                                        }

                                        Rectangle {
                                            visible: index 
                                                modelData.items.length
                                                - 1
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.leftMargin: 66
                                            height: 1; color: "#F0F0F0"
                                        }

                                        MouseArea {
                                            id: rMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                console.log("Tapped:",
                                                    modelData.label)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    x: 16
                    width: parent.width - 32
                    height: 52
                    background: Rectangle {
                        color: "#FFEBEE"; radius: 14
                        border.color: "#FFCDD2"
                    }
                    contentItem: Text {
                        text: "Log Out"
                        font.pixelSize: 15; font.bold: true
                        color: "#C62828"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: { console.log("Logout") }
                }

                Item { width: 1; height: 20 }
            }
        }
    }
}