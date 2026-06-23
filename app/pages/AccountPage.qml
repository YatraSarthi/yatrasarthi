import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    footer: null
    onVisibleChanged: {
        if (visible && appState) appState.showBottomBar = true
    }

    // ── PROFILE ────────────────────────────────────────────────────────────
    property var profileItems: [
        {
            icon: Qt.resolvedUrl("../../assets/icons/driver.png"),
            label: "Edit Profile",
            sub: "Name, photo, email",
            page: "EditProfilePage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/star.png"),
            label: "Payment Methods",
            sub: "UPI, cards, wallets",
            page: "PaymentMethodsPage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/sos.png"),
            label: "Emergency Contacts",
            sub: "SOS contacts",
            page: "EmergencyContactsPage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/rider.png"),
            label: "Ride History",
            sub: "Past trips & receipts",
            page: "RideHistoryPage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/star.png"),
            label: "Rewards & Coupons",
            sub: "Points, offers, promo codes",
            tag: "3 Offers",
            page: "RewardsPage"
        }
    ]

    // ── PREFERENCES ────────────────────────────────────────────────────────
    property var preferenceItems: [
        {
            icon: Qt.resolvedUrl("../../assets/icons/destination.png"),
            label: "Notifications",
            sub: "Ride alerts, offers",
            page: "NotificationsPage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/map.png"),
            label: "Language",
            sub: "English",
            page: "LanguagePage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/star.png"),
            label: "Dark Mode",
            sub: darkModeEnabled ? "On" : "Off",
            isToggle: true,
            page: ""
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/map.png"),
            label: "Accessibility",
            sub: "Font size, contrast",
            page: "AccessibilityPage"
        }
    ]

    // ── SUPPORT ────────────────────────────────────────────────────────────
    property var supportItems: [
        {
            icon: Qt.resolvedUrl("../../assets/icons/rider.png"),
            label: "Help & Support",
            sub: "FAQs, live chat",
            tag: "Live",
            page: "HelpSupportPage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/sos.png"),
            label: "Safety Features",
            sub: "Share trip, SOS button",
            page: "SafetyPage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/star.png"),
            label: "Rate the App",
            sub: "Tell us what you think",
            page: "RateAppPage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/map.png"),
            label: "Privacy Policy",
            sub: "Data usage & rights",
            page: "PrivacyPolicyPage"
        },
        {
            icon: Qt.resolvedUrl("../../assets/icons/destination.png"),
            label: "About YatraSarthi",
            sub: "Version 3.2.1",
            page: "AboutPage"
        }
    ]

    property var accountSections: [
        { title: "PROFILE",     items: profileItems    },
        { title: "PREFERENCES", items: preferenceItems },
        { title: "SUPPORT",     items: supportItems    }
    ]

    // ── STATE ──────────────────────────────────────────────────────────────
    property bool darkModeEnabled: false

    // ── NAVIGATION HELPER ──────────────────────────────────────────────────
    function navigateTo(pageName) {
        if (pageName === "" || !appStack) return
        switch (pageName) {
            case "EditProfilePage":      appStack.push("qrc:/pages/account/EditProfilePage.qml");      break
            case "PaymentMethodsPage":   appStack.push("qrc:/pages/account/PaymentMethodsPage.qml");   break
            case "EmergencyContactsPage":appStack.push("qrc:/pages/account/EmergencyContactsPage.qml");break
            case "RideHistoryPage":      appStack.push("qrc:/pages/account/RideHistoryPage.qml");      break
            case "RewardsPage":          appStack.push("qrc:/pages/account/RewardsPage.qml");          break
            case "NotificationsPage":    appStack.push("qrc:/pages/account/NotificationsPage.qml");    break
            case "LanguagePage":         appStack.push("qrc:/pages/account/LanguagePage.qml");         break
            case "AccessibilityPage":    appStack.push("qrc:/pages/account/AccessibilityPage.qml");    break
            case "HelpSupportPage":      appStack.push("qrc:/pages/account/HelpSupportPage.qml");      break
            case "SafetyPage":           appStack.push("qrc:/pages/account/SafetyPage.qml");           break
            case "RateAppPage":          appStack.push("qrc:/pages/account/RateAppPage.qml");          break
            case "PrivacyPolicyPage":    appStack.push("qrc:/pages/account/PrivacyPolicyPage.qml");    break
            case "AboutPage":            appStack.push("qrc:/pages/account/AboutPage.qml");            break
            default: console.log("No route for:", pageName)
        }
    }

    // ── UI ─────────────────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {
            width: parent.width
            spacing: 0

            // ── Profile header ──────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 170
                color: "#1976D2"
                clip: true

                // Decorative circle
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

                    // Avatar
                    Rectangle {
                        width: 72; height: 72; radius: 36
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Image {
                            source: Qt.resolvedUrl("../../assets/icons/driver.png")
                            width: 42; height: 42
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                        }

                        // Camera badge — tapping opens Edit Profile
                        Rectangle {
                            width: 22; height: 22; radius: 11
                            color: "#FFD600"
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            border.color: "white"; border.width: 2

                            Text {
                                text: "✎"
                                font.pixelSize: 10
                                color: "#333"
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: navigateTo("EditProfilePage")
                            }
                        }
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Johney"
                        font.pixelSize: 18; font.bold: true
                        color: "white"
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "+91 98765 43210"
                        font.pixelSize: 12; color: "#B3E5FC"
                    }

                    // Badges row
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        Repeater {
                            model: ["⭐ 4.8 Rating", "142 Rides", "Gold Member"]
                            delegate: Rectangle {
                                height: 20; radius: 10
                                color: "#ffffff25"
                                border.color: "#ffffff40"
                                width: badgeText.implicitWidth + 16

                                Text {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 10
                                    color: "white"
                                }
                            }
                        }
                    }
                }
            }

            // ── Sections ────────────────────────────────────────────────────
            Column {
                width: parent.width
                spacing: 14

                Item { width: 1; height: 14 }

                Repeater {
                    model: accountSections

                    delegate: Column {
                        x: 16
                        width: parent.width - 32
                        spacing: 6

                        property var section: modelData

                        Label {
                            text: section ? section.title : ""
                            font.pixelSize: 11; font.bold: true
                            color: "#AAAAAA"; leftPadding: 4
                        }

                        Rectangle {
                            width: parent.width
                            height: section ? (section.items.length * 60) : 0
                            radius: 14; color: "white"
                            border.color: "#EEEEEE"; clip: true

                            Column {
                                width: parent.width
                                spacing: 0

                                Repeater {
                                    id: innerRepeater
                                    model: section ? section.items : []

                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 60
                                        property var item: modelData
                                        color: rMouse.containsMouse ? "#F8F8F8" : "transparent"

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 16
                                            anchors.rightMargin: 16
                                            spacing: 14

                                            // Icon circle
                                            Rectangle {
                                                width: 36; height: 36; radius: 18
                                                color: "#F5F5F5"
                                                anchors.verticalCenter: parent.verticalCenter

                                                Image {
                                                    source: item ? item.icon : ""
                                                    width: 20; height: 20
                                                    fillMode: Image.PreserveAspectFit
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            // Labels
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2
                                                width: parent.width - 36 - 14 - 60 - 32

                                                Label {
                                                    text: item ? item.label : ""
                                                    font.pixelSize: 14; color: "#111"
                                                }
                                                Label {
                                                    text: item ? item.sub : ""
                                                    font.pixelSize: 11; color: "#AAA"
                                                    visible: item ? (item.sub !== "") : false
                                                }
                                            }

                                            // Right side: tag OR toggle OR chevron
                                            Item {
                                                width: 60
                                                height: parent.height
                                                anchors.verticalCenter: parent.verticalCenter

                                                // Optional tag badge (e.g. "3 Offers", "Live")
                                                Rectangle {
                                                    id: tagBadge
                                                    visible: item ? (item.tag !== undefined && item.tag !== "") : false
                                                    height: 18; radius: 9
                                                    color: (item && item.tag === "Live") ? "#E8F5E9" : "#FFF3E0"
                                                    width: tagLabel.implicitWidth + 12
                                                    anchors.right: chevronText.left
                                                    anchors.rightMargin: 6
                                                    anchors.verticalCenter: parent.verticalCenter

                                                    Text {
                                                        id: tagLabel
                                                        anchors.centerIn: parent
                                                        text: item ? (item.tag || "") : ""
                                                        font.pixelSize: 10; font.bold: true
                                                        color: (item && item.tag === "Live") ? "#388E3C" : "#E65100"
                                                    }
                                                }

                                                // Dark mode toggle
                                                Rectangle {
                                                    id: toggleTrack
                                                    visible: item ? (item.isToggle === true) : false
                                                    width: 38; height: 22; radius: 11
                                                    color: darkModeEnabled ? "#1565C0" : "#CCCCCC"
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter

                                                    Rectangle {
                                                        width: 18; height: 18; radius: 9
                                                        color: "white"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        x: darkModeEnabled ? 18 : 2
                                                        Behavior on x { NumberAnimation { duration: 150 } }
                                                    }
                                                }

                                                // Chevron (shown when not a toggle)
                                                Text {
                                                    id: chevronText
                                                    visible: item ? (item.isToggle !== true) : true
                                                    text: "›"
                                                    font.pixelSize: 22; color: "#CCCCCC"
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                        }

                                        // Divider
                                        Rectangle {
                                            visible: item ? (index < innerRepeater.count - 1) : false
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left; anchors.right: parent.right
                                            anchors.leftMargin: 66
                                            height: 1; color: "#F0F0F0"
                                        }

                                        MouseArea {
                                            id: rMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                if (!item) return
                                                if (item.isToggle === true) {
                                                    darkModeEnabled = !darkModeEnabled
                                                } else {
                                                    navigateTo(item.page)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Log Out button ──────────────────────────────────────────
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
                    onClicked: {
                        // TODO: clear session tokens, then:
                        // appStack.replace("qrc:/pages/auth/LoginPage.qml")
                        console.log("Logout tapped")
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }
}
