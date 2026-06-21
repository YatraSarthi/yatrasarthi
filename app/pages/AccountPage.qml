import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    footer: null

    // ── Section data defined as properties ────────────────────────
    // QML's inline JS object arrays inside model: [] can choke on
    // nested arrays. Defining them as properties avoids the parser
    // error entirely.

    property var profileItems: [
        { icon: "👤", label: "Edit Profile",
          sub: "Name, photo, email" },
        { icon: "💳", label: "Payment Methods",
          sub: "UPI, cards, wallets" },
        { icon: "🚨", label: "Emergency Contacts",
          sub: "SOS contacts" }
    ]

    property var preferenceItems: [
        { icon: "🔔", label: "Notifications",
          sub: "Ride alerts, offers" },
        { icon: "🌐", label: "Language",
          sub: "English" },
        { icon: "🌙", label: "Dark Mode",
          sub: "Off" }
    ]

    property var supportItems: [
        { icon: "❓", label: "Help & Support",
          sub: "FAQs, chat" },
        { icon: "⭐", label: "Rate the App",
          sub: "Tell us what you think" },
        { icon: "📄", label: "Privacy Policy",
          sub: "" }
    ]

    ScrollView {

        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {

            width: parent.width
            spacing: 0

            // ── Profile Header ────────────────────────────────────
            Rectangle {

                width: parent.width
                height: 150
                color: "#1976D2"

                // Decorative circle
                Rectangle {
                    width: 160
                    height: 160
                    radius: 80
                    color: "#ffffff10"
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: -50
                    anchors.bottomMargin: -50
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        width: 68
                        height: 68
                        radius: 34
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "👤"
                            font.pixelSize: 32
                        }
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Johney"
                        font.pixelSize: 17
                        font.bold: true
                        color: "white"
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "+91 98765 43210"
                        font.pixelSize: 12
                        color: "#B3E5FC"
                    }
                }
            }

            // ── Body ──────────────────────────────────────────────
            Column {

                width: parent.width
                spacing: 14

                Item { width: 1; height: 14 }

                // ── PROFILE section ───────────────────────────────
                Column {
                    x: 16
                    width: parent.width - 32
                    spacing: 6

                    Label {
                        text: "PROFILE"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#AAAAAA"
                        leftPadding: 4
                    }

                    Rectangle {
                        width: parent.width
                        height: profileItems.length * 60
                        radius: 14
                        color: "white"
                        border.color: "#EEEEEE"
                        clip: true

                        Column {
                            width: parent.width
                            spacing: 0

                            Repeater {
                                model: profileItems
                                delegate: accountRowDelegate
                            }
                        }
                    }
                }

                // ── PREFERENCES section ───────────────────────────
                Column {
                    x: 16
                    width: parent.width - 32
                    spacing: 6

                    Label {
                        text: "PREFERENCES"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#AAAAAA"
                        leftPadding: 4
                    }

                    Rectangle {
                        width: parent.width
                        height: preferenceItems.length * 60
                        radius: 14
                        color: "white"
                        border.color: "#EEEEEE"
                        clip: true

                        Column {
                            width: parent.width
                            spacing: 0

                            Repeater {
                                model: preferenceItems
                                delegate: accountRowDelegate
                            }
                        }
                    }
                }

                // ── SUPPORT section ───────────────────────────────
                Column {
                    x: 16
                    width: parent.width - 32
                    spacing: 6

                    Label {
                        text: "SUPPORT"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#AAAAAA"
                        leftPadding: 4
                    }

                    Rectangle {
                        width: parent.width
                        height: supportItems.length * 60
                        radius: 14
                        color: "white"
                        border.color: "#EEEEEE"
                        clip: true

                        Column {
                            width: parent.width
                            spacing: 0

                            Repeater {
                                model: supportItems
                                delegate: accountRowDelegate
                            }
                        }
                    }
                }

                // ── Log Out ───────────────────────────────────────
                Button {
                    x: 16
                    width: parent.width - 32
                    height: 52

                    background: Rectangle {
                        color: "#FFEBEE"
                        radius: 14
                        border.color: "#FFCDD2"
                    }

                    contentItem: Text {
                        text: "🚪   Log Out"
                        font.pixelSize: 15
                        font.bold: true
                        color: "#C62828"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("Logout tapped")
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }

    // ── Row delegate (shared across all three sections) ───────────
    // Defined as a Component so it can be reused by all three
    // Repeaters without duplicating the delegate code.
    Component {

        id: accountRowDelegate

        Rectangle {

            // modelData comes from the Repeater's model array
            width: parent.width
            height: 60
            color: rowMouse.containsMouse ? "#F8F8F8" : "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 14

                // Icon bubble
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: "#F5F5F5"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.pixelSize: 18
                    }
                }

                // Label + subtitle
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    // fill width minus: icon(36) + spacing(14)
                    // + chevron(20) + margins(32)
                    width: parent.width - 36 - 14 - 20 - 32

                    Label {
                        text: modelData.label
                        font.pixelSize: 14
                        color: "#111"
                    }

                    Label {
                        text: modelData.sub
                        font.pixelSize: 11
                        color: "#AAA"
                        visible: modelData.sub !== ""
                    }
                }

                // Chevron
                Text {
                    text: "›"
                    font.pixelSize: 22
                    color: "#CCCCCC"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Row divider — hidden on last item
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 66
                height: 1
                color: "#F0F0F0"
                // index is available inside Repeater delegates
                visible: index < parent.parent.children.length - 1
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    console.log("Tapped:", modelData.label)
                }
            }
        }
    }
}