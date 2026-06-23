import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    signal switchTab(int tabIndex)

    footer: null
    header: null

    onVisibleChanged: {
        if (visible && appState) appState.showBottomBar = true
    }

    // ── EMERGENCY CONTACTS STATE ────────────────────────────────────────────
    property bool emergencyExpanded: false
    property bool emergencyEditMode: false
    property string emergencySaveMessage: ""

    property string contact1Name: ""
    property string contact1Phone: ""
    property string contact2Name: ""
    property string contact2Phone: ""
    property string bloodGroup: ""
    property string medicalNotes: ""

    property int emergencySyncTick: 0

    Component.onCompleted: { loadEmergencyInfo() }

    onEmergencyExpandedChanged: {
        if (emergencyExpanded) emergencySyncTick++
    }
    onEmergencyEditModeChanged: {
        if (!emergencyEditMode) emergencySyncTick++
    }

    function loadEmergencyInfo() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    contact1Name  = data.contact1Name  || ""
                    contact1Phone = data.contact1Phone || ""
                    contact2Name  = data.contact2Name  || ""
                    contact2Phone = data.contact2Phone || ""
                    bloodGroup    = data.bloodGroup    || ""
                    medicalNotes  = data.medicalNotes  || ""
                    emergencySyncTick++
                } catch (e) {
                    console.log("Emergency Info Parse Error:", e)
                }
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/sos/info", true)
        xhr.send()
    }

    function saveEmergencyInfo() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    emergencySaveMessage = "Saved successfully"
                    emergencyEditMode = false
                } else {
                    emergencySaveMessage = "Failed to save"
                }
            }
        }
        xhr.onerror = function() {
            emergencySaveMessage = "Unable to contact server"
        }

        var url = "http://127.0.0.1:8000/sos/info"
                  + "?contact1Name="  + encodeURIComponent(contact1Name)
                  + "&contact1Phone=" + encodeURIComponent(contact1Phone)
                  + "&contact2Name="  + encodeURIComponent(contact2Name)
                  + "&contact2Phone=" + encodeURIComponent(contact2Phone)
                  + "&bloodGroup="    + encodeURIComponent(bloodGroup)
                  + "&medicalNotes="  + encodeURIComponent(medicalNotes)

        xhr.open("POST", url, true)
        xhr.send()
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
            page: "",
            isEmergencyContacts: true
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
            case "EditProfilePage":      appStack.push(Qt.resolvedUrl("EditProfilePage.qml"));      break
            case "PaymentMethodsPage":   appStack.push(Qt.resolvedUrl("PaymentMethodsPage.qml"));   break
            case "RideHistoryPage":      appStack.push(Qt.resolvedUrl("RideHistoryPage.qml"));      break
            case "RewardsPage":          appStack.push(Qt.resolvedUrl("RewardsPage.qml"));          break
            case "NotificationsPage":    appStack.push(Qt.resolvedUrl("NotificationsPage.qml"));    break
            case "LanguagePage":         appStack.push(Qt.resolvedUrl("LanguagePage.qml"));         break
            case "AccessibilityPage":    appStack.push(Qt.resolvedUrl("AccessibilityPage.qml"));    break
            case "HelpSupportPage":      appStack.push(Qt.resolvedUrl("HelpSupportPage.qml"));      break
            case "SafetyPage":           appStack.push(Qt.resolvedUrl("SafetyPage.qml"));           break
            case "RateAppPage":          appStack.push(Qt.resolvedUrl("RateAppPage.qml"));          break
            case "PrivacyPolicyPage":    appStack.push(Qt.resolvedUrl("PrivacyPolicyPage.qml"));    break
            case "AboutPage":            appStack.push(Qt.resolvedUrl("AboutPage.qml"));            break
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

            // ── Back-arrow header bar ───────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 56
                color: "#1976D2"

                // Back arrow
                Rectangle {
                    id: backBtn
                    width: 36; height: 36; radius: 18
                    color: "#ffffff20"
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "‹"
                        font.pixelSize: 26
                        color: "white"
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -1
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: switchTab(0)
                    }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: backBtn.right
                    anchors.leftMargin: 10
                    text: "Account"
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                }
            }

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

                        // Camera badge
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
                            radius: 14; color: "white"
                            border.color: "#EEEEEE"; clip: true
                            height: sectionColumn.height

                            Column {
                                id: sectionColumn
                                width: parent.width
                                spacing: 0

                                Repeater {
                                    id: innerRepeater
                                    model: section ? section.items : []

                                    delegate: Column {
                                        width: parent.width
                                        property var item: modelData
                                        property bool isEmergencyRow: item ? (item.isEmergencyContacts === true) : false

                                        // ── Row itself ───────────────────────────
                                        Rectangle {
                                            width: parent.width
                                            height: 60
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

                                                    // Optional tag badge
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

                                                    // Chevron / expand arrow
                                                    Text {
                                                        id: chevronText
                                                        visible: item ? (item.isToggle !== true) : true
                                                        text: "›"
                                                        font.pixelSize: 22
                                                        color: "#CCCCCC"
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        rotation: (isEmergencyRow && emergencyExpanded) ? 90 : 0
                                                        Behavior on rotation { NumberAnimation { duration: 150 } }
                                                    }
                                                }
                                            }

                                            // Divider
                                            Rectangle {
                                                visible: item
                                                         ? (index < innerRepeater.count - 1 && !(isEmergencyRow && emergencyExpanded))
                                                         : false
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
                                                    } else if (isEmergencyRow) {
                                                        emergencyExpanded = !emergencyExpanded
                                                        if (emergencyExpanded) {
                                                            emergencySaveMessage = ""
                                                            loadEmergencyInfo()
                                                        } else {
                                                            emergencyEditMode = false
                                                        }
                                                    } else {
                                                        navigateTo(item.page)
                                                    }
                                                }
                                            }
                                        }

                                        // ── Expanded Emergency Contacts panel ──────
                                        Column {
                                            width: parent.width
                                            visible: isEmergencyRow && emergencyExpanded
                                            spacing: 14
                                            topPadding: 4
                                            bottomPadding: 16
                                            leftPadding: 16
                                            rightPadding: 16

                                            Rectangle {
                                                width: parent.width - 32
                                                height: 1
                                                color: "#F0F0F0"
                                            }

                                            Row {
                                                width: parent.width - 32
                                                Label {
                                                    text: "Saved Information"
                                                    font.pixelSize: 12; font.bold: true; color: "#888"
                                                    width: parent.width - editToggleBtn.width
                                                }
                                                Button {
                                                    id: editToggleBtn
                                                    text: emergencyEditMode ? "Cancel" : "Edit"
                                                    flat: true
                                                    onClicked: {
                                                        if (emergencyEditMode) {
                                                            loadEmergencyInfo()
                                                            emergencySaveMessage = ""
                                                        }
                                                        emergencyEditMode = !emergencyEditMode
                                                    }
                                                }
                                            }

                                            Label { text: "Emergency Contact 1"; font.pixelSize: 12; color: "#888"; leftPadding: 0 }
                                            TextField {
                                                id: acc1NameField
                                                width: parent.width - 32
                                                placeholderText: "Name"
                                                readOnly: !emergencyEditMode
                                                onTextChanged: contact1Name = text
                                            }
                                            TextField {
                                                id: acc1PhoneField
                                                width: parent.width - 32
                                                placeholderText: "Phone number"
                                                readOnly: !emergencyEditMode
                                                inputMethodHints: Qt.ImhDialableCharactersOnly
                                                onTextChanged: contact1Phone = text
                                            }

                                            Label { text: "Emergency Contact 2"; font.pixelSize: 12; color: "#888" }
                                            TextField {
                                                id: acc2NameField
                                                width: parent.width - 32
                                                placeholderText: "Name"
                                                readOnly: !emergencyEditMode
                                                onTextChanged: contact2Name = text
                                            }
                                            TextField {
                                                id: acc2PhoneField
                                                width: parent.width - 32
                                                placeholderText: "Phone number"
                                                readOnly: !emergencyEditMode
                                                inputMethodHints: Qt.ImhDialableCharactersOnly
                                                onTextChanged: contact2Phone = text
                                            }

                                            Label { text: "Blood Group"; font.pixelSize: 12; color: "#888" }
                                            TextField {
                                                id: accBloodField
                                                width: parent.width - 32
                                                placeholderText: "e.g. O+"
                                                readOnly: !emergencyEditMode
                                                onTextChanged: bloodGroup = text
                                            }

                                            Label { text: "Medical Notes"; font.pixelSize: 12; color: "#888" }
                                            TextArea {
                                                id: accNotesField
                                                width: parent.width - 32
                                                placeholderText: "Allergies, conditions, medications..."
                                                readOnly: !emergencyEditMode
                                                wrapMode: TextArea.Wrap
                                                onTextChanged: medicalNotes = text
                                            }

                                            Item {
                                                property int tick: emergencySyncTick
                                                onTickChanged: {
                                                    acc1NameField.text  = contact1Name
                                                    acc1PhoneField.text = contact1Phone
                                                    acc2NameField.text  = contact2Name
                                                    acc2PhoneField.text = contact2Phone
                                                    accBloodField.text  = bloodGroup
                                                    accNotesField.text  = medicalNotes
                                                }
                                                Component.onCompleted: {
                                                    acc1NameField.text  = contact1Name
                                                    acc1PhoneField.text = contact1Phone
                                                    acc2NameField.text  = contact2Name
                                                    acc2PhoneField.text = contact2Phone
                                                    accBloodField.text  = bloodGroup
                                                    accNotesField.text  = medicalNotes
                                                }
                                            }

                                            Button {
                                                width: parent.width - 32; height: 44
                                                visible: emergencyEditMode
                                                onClicked: saveEmergencyInfo()
                                                background: Rectangle { color: "#1976D2"; radius: 10 }
                                                contentItem: Text {
                                                    text: "Save"; font.pixelSize: 14
                                                    font.bold: true; color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }

                                            Label {
                                                width: parent.width - 32
                                                text: emergencySaveMessage
                                                color: emergencySaveMessage === "Saved successfully" ? "#388E3C" : "#E53935"
                                                visible: emergencySaveMessage !== ""
                                                wrapMode: Text.WordWrap
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
                        console.log("Logout tapped")
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }
}
