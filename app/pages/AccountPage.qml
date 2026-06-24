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

    // ── EXPANDED PANEL STATE ──────────────────────────────────────────────────
    property string expandedItem: ""   // which item is currently open

    // Emergency contacts state
    property bool   emergencyEditMode:    false
    property string emergencySaveMessage: ""
    property string contact1Name:  ""
    property string contact1Phone: ""
    property string contact2Name:  ""
    property string contact2Phone: ""
    property string bloodGroup:    ""
    property string medicalNotes:  ""
    property int    emergencySyncTick: 0

    // Edit profile state
    property string profileName:   "Johney"
    property string profilePhone:  "+91 98765 43210"
    property string profileEmail:  "johney@email.com"
    property string profileDob:    "01 Jan 1995"
    property string profileGender: "Male"
    property bool   profileEditMode: false
    property string profileSaveMessage: ""

    // Dark mode
    property bool darkModeEnabled: false

    // Rewards points
    property int rewardPoints: 240

    // Wallet
    property real walletBalance: 0.0

    // Language
    property string selectedLanguage: "English"

    Component.onCompleted: { loadEmergencyInfo() }

    onExpandedItemChanged: {
        if (expandedItem !== "Emergency Contacts") {
            emergencyEditMode = false
            emergencySaveMessage = ""
        }
        if (expandedItem !== "Edit Profile") {
            profileEditMode = false
            profileSaveMessage = ""
        }
    }

    function toggleExpand(label) {
        if (expandedItem === label) expandedItem = ""
        else {
            expandedItem = label
            if (label === "Emergency Contacts") {
                emergencySaveMessage = ""
                loadEmergencyInfo()
            }
        }
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
                } catch(e) { console.log("Parse error:", e) }
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/sos/info", true)
        xhr.send()
    }

    function saveEmergencyInfo() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                emergencySaveMessage = xhr.status === 200 ? "Saved successfully ✓" : "Failed to save"
                if (xhr.status === 200) emergencyEditMode = false
            }
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

    // ── SECTION DATA ──────────────────────────────────────────────────────────
    property var profileItems: [
        { icon: Qt.resolvedUrl("../../assets/icons/driver.png"), label: "Edit Profile",       sub: "Name, photo, email",        tag: "",       hasPanel: true  },
        { icon: Qt.resolvedUrl("../../assets/icons/star.png"),   label: "Payment Methods",    sub: "UPI, cards, wallets",       tag: "",       hasPanel: true  },
        { icon: Qt.resolvedUrl("../../assets/icons/sos.png"),    label: "Emergency Contacts", sub: "SOS contacts",              tag: "",       hasPanel: true  },
        { icon: Qt.resolvedUrl("../../assets/icons/rider.png"),  label: "Ride History",       sub: "Past trips & receipts",     tag: "",       hasPanel: true  },
        { icon: Qt.resolvedUrl("../../assets/icons/star.png"),   label: "Rewards & Points",   sub: "Points, offers, coupons",   tag: "240 pts",hasPanel: true  },
        { icon: Qt.resolvedUrl("../../assets/icons/map.png"),    label: "Promo Codes",        sub: "Apply coupons, view deals", tag: "3 Offers",hasPanel: true }
    ]

    property var preferenceItems: [
        { icon: Qt.resolvedUrl("../../assets/icons/destination.png"), label: "Notifications",  sub: "Ride alerts, offers",         tag: "", hasPanel: true,  isToggle: false },
        { icon: Qt.resolvedUrl("../../assets/icons/destination.png"), label: "Saved Places",   sub: "Home, Work & more",           tag: "", hasPanel: true,  isToggle: false },
        { icon: Qt.resolvedUrl("../../assets/icons/map.png"),         label: "Language",       sub: "English",                     tag: "", hasPanel: true,  isToggle: false },
        { icon: Qt.resolvedUrl("../../assets/icons/star.png"),        label: "Dark Mode",      sub: darkModeEnabled ? "On":"Off",  tag: "", hasPanel: false, isToggle: true  },
        { icon: Qt.resolvedUrl("../../assets/icons/sos.png"),         label: "Safety Settings",sub: "Trusted contacts, share ride",tag: "", hasPanel: true,  isToggle: false }
    ]

    property var paymentItems: [
        { icon: Qt.resolvedUrl("../../assets/icons/star.png"), label: "Wallet Balance", sub: "₹" + walletBalance.toFixed(2) + " available", tag: "", hasPanel: true, isToggle: false },
        { icon: Qt.resolvedUrl("../../assets/icons/map.png"),  label: "GST Invoice",    sub: "Download ride invoices",                       tag: "", hasPanel: true, isToggle: false }
    ]

    property var supportItems: [
        { icon: Qt.resolvedUrl("../../assets/icons/rider.png"),       label: "Live Chat Support", sub: "Talk to an agent now",      tag: "Live", hasPanel: true,  isToggle: false },
        { icon: Qt.resolvedUrl("../../assets/icons/rider.png"),       label: "Help & Support",    sub: "FAQs, common issues",       tag: "",     hasPanel: true,  isToggle: false },
        { icon: Qt.resolvedUrl("../../assets/icons/sos.png"),         label: "Safety Features",   sub: "Share trip, SOS button",    tag: "",     hasPanel: true,  isToggle: false },
        { icon: Qt.resolvedUrl("../../assets/icons/star.png"),        label: "Rate the App",      sub: "Tell us what you think",    tag: "",     hasPanel: true,  isToggle: false },
        { icon: Qt.resolvedUrl("../../assets/icons/map.png"),         label: "Privacy Policy",    sub: "Data usage & rights",       tag: "",     hasPanel: true,  isToggle: false },
        { icon: Qt.resolvedUrl("../../assets/icons/destination.png"), label: "About YatraSarthi", sub: "Version 3.2.1",             tag: "",     hasPanel: true,  isToggle: false }
    ]

    property var accountSections: [
        { title: "PROFILE",   items: profileItems   },
        { title: "PREFERENCES", items: preferenceItems },
        { title: "PAYMENTS",  items: paymentItems   },
        { title: "SUPPORT",   items: supportItems   }
    ]

    // ── PANEL BUILDER ─────────────────────────────────────────────────────────
    // Returns a Component for each item's inline panel
    function panelForLabel(label) { return label }  // used as switch key below

    // ── ROOT UI ───────────────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {
            width: parent.width
            spacing: 0

            // ── Top bar ───────────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 56; color: "#1976D2"
                Rectangle {
                    width: 36; height: 36; radius: 18; color: "#33FFFFFF"
                    anchors.left: parent.left; anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: "‹"; font.pixelSize: 28; font.bold: true; color: "white"; anchors.centerIn: parent }
                    MouseArea { anchors.fill: parent; onClicked: switchTab(0) }
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 60
                    text: "Account"; font.pixelSize: 20; font.bold: true; color: "white"
                }
            }

            // ── Profile header ────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 180; color: "#1976D2"; clip: true
                Rectangle {
                    width: 160; height: 160; radius: 80; color: "#ffffff15"
                    anchors.right: parent.right; anchors.bottom: parent.bottom
                    anchors.rightMargin: -50; anchors.bottomMargin: -50
                }
                Column {
                    anchors.centerIn: parent; spacing: 8
                    Rectangle {
                        width: 72; height: 72; radius: 36; color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                        Image {
                            source: Qt.resolvedUrl("../../assets/icons/driver.png")
                            width: 42; height: 42; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent
                        }
                        Rectangle {
                            width: 22; height: 22; radius: 11; color: "#FFD600"
                            anchors.right: parent.right; anchors.bottom: parent.bottom
                            border.color: "white"; border.width: 2
                            Text { text: "✎"; font.pixelSize: 10; color: "#333"; anchors.centerIn: parent }
                            MouseArea { anchors.fill: parent; onClicked: toggleExpand("Edit Profile") }
                        }
                    }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: profileName; font.pixelSize: 18; font.bold: true; color: "white" }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: profilePhone; font.pixelSize: 12; color: "#B3E5FC" }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 8
                        Repeater {
                            model: ["⭐ 4.8", "142 Rides", "Gold"]
                            delegate: Rectangle {
                                height: 20; radius: 10; color: "#ffffff25"; border.color: "#ffffff40"
                                width: btext.implicitWidth + 14
                                Text { id: btext; anchors.centerIn: parent; text: modelData; font.pixelSize: 10; color: "white" }
                            }
                        }
                    }
                }
            }

            // ── Sections ──────────────────────────────────────────────────────
            Column {
                width: parent.width; spacing: 14

                Item { width: 1; height: 14 }

                Repeater {
                    model: accountSections
                    delegate: Column {
                        x: 16; width: parent.width - 32; spacing: 6
                        property var section: modelData

                        Label {
                            text: section ? section.title : ""
                            font.pixelSize: 11; font.bold: true; color: "#AAAAAA"; leftPadding: 4
                        }

                        Rectangle {
                            width: parent.width; radius: 14; color: "white"
                            border.color: "#EEEEEE"; clip: true
                            height: secCol.implicitHeight

                            Column {
                                id: secCol
                                width: parent.width

                                Repeater {
                                    id: innerRep
                                    model: section ? section.items : []

                                    delegate: Column {
                                        width: parent.width
                                        property var item: modelData
                                        property bool isOpen: item ? (expandedItem === item.label) : false

                                        // ── Row ──────────────────────────────
                                        Rectangle {
                                            width: parent.width; height: 60
                                            color: rowMouse.containsMouse ? "#F8F8F8" : "transparent"

                                            Row {
                                                anchors.fill: parent
                                                anchors.leftMargin: 16; anchors.rightMargin: 12
                                                spacing: 14

                                                Rectangle {
                                                    width: 36; height: 36; radius: 18; color: "#F5F5F5"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    Image {
                                                        source: item ? item.icon : ""
                                                        width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent
                                                    }
                                                }

                                                Column {
                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                                    width: parent.width - 36 - 14 - 70
                                                    Label { text: item ? item.label : ""; font.pixelSize: 14; color: "#111" }
                                                    Label {
                                                        text: item ? item.sub : ""; font.pixelSize: 11; color: "#AAA"
                                                        visible: item ? item.sub !== "" : false
                                                    }
                                                }

                                                // Right: tag + chevron or toggle
                                                Row {
                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 6; width: 70

                                                    Rectangle {
                                                        visible: item ? (item.tag !== undefined && item.tag !== "") : false
                                                        height: 18; radius: 9
                                                        color: (item && item.tag === "Live") ? "#E8F5E9" : "#FFF3E0"
                                                        width: tagTxt.implicitWidth + 10
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        Text {
                                                            id: tagTxt; anchors.centerIn: parent
                                                            text: item ? (item.tag || "") : ""
                                                            font.pixelSize: 10; font.bold: true
                                                            color: (item && item.tag === "Live") ? "#388E3C" : "#E65100"
                                                        }
                                                    }

                                                    // Toggle switch
                                                    Rectangle {
                                                        visible: item ? (item.isToggle === true) : false
                                                        width: 38; height: 22; radius: 11
                                                        color: darkModeEnabled ? "#1565C0" : "#CCCCCC"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        Rectangle {
                                                            width: 18; height: 18; radius: 9; color: "white"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            x: darkModeEnabled ? 18 : 2
                                                            Behavior on x { NumberAnimation { duration: 150 } }
                                                        }
                                                    }

                                                    // Chevron
                                                    Text {
                                                        visible: item ? !item.isToggle : true
                                                        text: "›"; font.pixelSize: 22; color: "#CCCCCC"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        rotation: isOpen ? 90 : 0
                                                        Behavior on rotation { NumberAnimation { duration: 150 } }
                                                    }
                                                }
                                            }

                                            // Divider
                                            Rectangle {
                                                visible: index < innerRep.count - 1 && !isOpen
                                                anchors.bottom: parent.bottom
                                                anchors.left: parent.left; anchors.right: parent.right
                                                anchors.leftMargin: 66; height: 1; color: "#F0F0F0"
                                            }

                                            MouseArea {
                                                id: rowMouse; anchors.fill: parent; hoverEnabled: true
                                                onClicked: {
                                                    if (!item) return
                                                    if (item.isToggle) { darkModeEnabled = !darkModeEnabled; return }
                                                    if (item.hasPanel) toggleExpand(item.label)
                                                }
                                            }
                                        }

                                        // ══════════════════════════════════════
                                        // ── INLINE PANELS ─────────────────────
                                        // ══════════════════════════════════════
                                        Rectangle {
                                            width: parent.width
                                            height: isOpen ? panelCol.implicitHeight + 24 : 0
                                            visible: isOpen
                                            color: "#FAFAFA"
                                            clip: true
                                            Behavior on height { NumberAnimation { duration: 180 } }

                                            Column {
                                                id: panelCol
                                                width: parent.width - 32
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                spacing: 12
                                                topPadding: 12

                                                // ── EDIT PROFILE ─────────────
                                                Column {
                                                    width: parent.width; spacing: 10
                                                    visible: item ? item.label === "Edit Profile" : false

                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }

                                                    // Avatar
                                                    Rectangle {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        width: 72; height: 72; radius: 36; color: "white"
                                                        border.color: "#1976D2"; border.width: 2
                                                        Image {
                                                            source: Qt.resolvedUrl("../../assets/icons/driver.png")
                                                            width: 44; height: 44; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent
                                                        }
                                                        Rectangle {
                                                            width: 22; height: 22; radius: 11; color: "#1976D2"
                                                            anchors.right: parent.right; anchors.bottom: parent.bottom
                                                            Text { text: "✎"; font.pixelSize: 11; color: "white"; anchors.centerIn: parent }
                                                        }
                                                    }

                                                    Row {
                                                        width: parent.width
                                                        Label { text: "Profile Details"; font.pixelSize: 12; font.bold: true; color: "#888"; width: parent.width - editProfBtn.width }
                                                        Button {
                                                            id: editProfBtn
                                                            text: profileEditMode ? "Cancel" : "Edit"
                                                            flat: true
                                                            contentItem: Text { text: parent.text; color: "#1976D2"; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                                            background: Item {}
                                                            onClicked: { profileEditMode = !profileEditMode; profileSaveMessage = "" }
                                                        }
                                                    }

                                                    Repeater {
                                                        model: [
                                                            { lbl: "Full Name",     ph: "Your name"       },
                                                            { lbl: "Phone",         ph: "+91 XXXXX XXXXX" },
                                                            { lbl: "Email",         ph: "you@email.com"   },
                                                            { lbl: "Date of Birth", ph: "DD MMM YYYY"     },
                                                            { lbl: "Gender",        ph: "Male / Female"   }
                                                        ]
                                                        delegate: Column {
                                                            width: parent.width; spacing: 4
                                                            Label { text: modelData.lbl; font.pixelSize: 11; color: "#888" }
                                                            Rectangle {
                                                                width: parent.width; height: 44; radius: 10
                                                                color: profileEditMode ? "white" : "#F5F5F5"
                                                                border.color: profileEditMode ? "#1976D2" : "#EEEEEE"
                                                                TextInput {
                                                                    anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                                                                    anchors.verticalCenter: parent.verticalCenter
                                                                    verticalAlignment: TextInput.AlignVCenter
                                                                    text: index === 0 ? profileName : index === 1 ? profilePhone : index === 2 ? profileEmail : index === 3 ? profileDob : profileGender
                                                                    readOnly: !profileEditMode
                                                                    font.pixelSize: 14; color: "#111"
                                                                    onTextChanged: {
                                                                        if (index === 0) profileName = text
                                                                        else if (index === 1) profilePhone = text
                                                                        else if (index === 2) profileEmail = text
                                                                        else if (index === 3) profileDob = text
                                                                        else profileGender = text
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Rectangle {
                                                        width: parent.width; height: 46; radius: 12
                                                        color: profileEditMode ? "#1976D2" : "#EEEEEE"
                                                        visible: true
                                                        Label {
                                                            anchors.centerIn: parent; text: profileEditMode ? "Save Changes" : "Close"
                                                            color: profileEditMode ? "white" : "#888"; font.pixelSize: 14; font.bold: true
                                                        }
                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                if (profileEditMode) {
                                                                    profileSaveMessage = "Profile saved ✓"
                                                                    profileEditMode = false
                                                                } else { toggleExpand("Edit Profile") }
                                                            }
                                                        }
                                                    }

                                                    Label {
                                                        text: profileSaveMessage; color: "#388E3C"
                                                        visible: profileSaveMessage !== ""; font.pixelSize: 12
                                                    }
                                                }

                                                // ── PAYMENT METHODS ───────────
                                                Column {
                                                    width: parent.width; spacing: 10
                                                    visible: item ? item.label === "Payment Methods" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Label { text: "SAVED METHODS"; font.pixelSize: 11; font.bold: true; color: "#AAAAAA" }
                                                    Repeater {
                                                        model: [
                                                            { icon: "💳", title: "UPI — johney@upi",       sub: "Primary",      badge: "UPI"  },
                                                            { icon: "🏦", title: "SBI Savings ••4521",     sub: "Net banking",  badge: "BANK" },
                                                            { icon: "💵", title: "Cash",                   sub: "Pay on ride",  badge: "CASH" }
                                                        ]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 58; radius: 12; color: "white"; border.color: "#EEEEEE"
                                                            Row {
                                                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                                                Label { text: modelData.icon; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                                                                Column {
                                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 100
                                                                    Label { text: modelData.title; font.pixelSize: 13; color: "#111"; font.bold: true }
                                                                    Label { text: modelData.sub;   font.pixelSize: 11; color: "#888" }
                                                                }
                                                                Rectangle {
                                                                    width: 40; height: 20; radius: 6; color: "#E3F2FD"; anchors.verticalCenter: parent.verticalCenter
                                                                    Label { anchors.centerIn: parent; text: modelData.badge; font.pixelSize: 9; color: "#1565C0"; font.bold: true }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    Rectangle {
                                                        width: parent.width; height: 44; radius: 12; color: "#E3F2FD"; border.color: "#90CAF9"
                                                        Row {
                                                            anchors.centerIn: parent; spacing: 8
                                                            Label { text: "+"; font.pixelSize: 18; color: "#1976D2"; font.bold: true }
                                                            Label { text: "Add Payment Method"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                                        }
                                                    }
                                                }

                                                // ── EMERGENCY CONTACTS ────────
                                                Column {
                                                    width: parent.width; spacing: 10
                                                    visible: item ? item.label === "Emergency Contacts" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }

                                                    Row {
                                                        width: parent.width
                                                        Label { text: "Saved Information"; font.pixelSize: 12; font.bold: true; color: "#888"; width: parent.width - ecEditBtn.width; anchors.verticalCenter: parent.verticalCenter }
                                                        Button {
                                                            id: ecEditBtn
                                                            text: emergencyEditMode ? "Cancel" : "Edit"
                                                            flat: true
                                                            contentItem: Text { text: parent.text; color: "#1976D2"; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                                            background: Item {}
                                                            onClicked: {
                                                                if (emergencyEditMode) { loadEmergencyInfo(); emergencySaveMessage = "" }
                                                                emergencyEditMode = !emergencyEditMode
                                                            }
                                                        }
                                                    }

                                                    Label { text: "Contact 1"; font.pixelSize: 11; color: "#888" }
                                                    Rectangle { width: parent.width; height: 42; radius: 10; color: emergencyEditMode ? "white" : "#F5F5F5"; border.color: emergencyEditMode ? "#1976D2" : "#EEEEEE"
                                                        TextInput { anchors { fill: parent; leftMargin: 14; rightMargin: 14 }; verticalAlignment: TextInput.AlignVCenter; text: contact1Name; readOnly: !emergencyEditMode; placeholderText: "Name"; font.pixelSize: 14; color: "#111"; onTextChanged: contact1Name = text }
                                                    }
                                                    Rectangle { width: parent.width; height: 42; radius: 10; color: emergencyEditMode ? "white" : "#F5F5F5"; border.color: emergencyEditMode ? "#1976D2" : "#EEEEEE"
                                                        TextInput { anchors { fill: parent; leftMargin: 14; rightMargin: 14 }; verticalAlignment: TextInput.AlignVCenter; text: contact1Phone; readOnly: !emergencyEditMode; placeholderText: "Phone"; inputMethodHints: Qt.ImhDialableCharactersOnly; font.pixelSize: 14; color: "#111"; onTextChanged: contact1Phone = text }
                                                    }

                                                    Label { text: "Contact 2"; font.pixelSize: 11; color: "#888" }
                                                    Rectangle { width: parent.width; height: 42; radius: 10; color: emergencyEditMode ? "white" : "#F5F5F5"; border.color: emergencyEditMode ? "#1976D2" : "#EEEEEE"
                                                        TextInput { anchors { fill: parent; leftMargin: 14; rightMargin: 14 }; verticalAlignment: TextInput.AlignVCenter; text: contact2Name; readOnly: !emergencyEditMode; placeholderText: "Name"; font.pixelSize: 14; color: "#111"; onTextChanged: contact2Name = text }
                                                    }
                                                    Rectangle { width: parent.width; height: 42; radius: 10; color: emergencyEditMode ? "white" : "#F5F5F5"; border.color: emergencyEditMode ? "#1976D2" : "#EEEEEE"
                                                        TextInput { anchors { fill: parent; leftMargin: 14; rightMargin: 14 }; verticalAlignment: TextInput.AlignVCenter; text: contact2Phone; readOnly: !emergencyEditMode; placeholderText: "Phone"; inputMethodHints: Qt.ImhDialableCharactersOnly; font.pixelSize: 14; color: "#111"; onTextChanged: contact2Phone = text }
                                                    }

                                                    Label { text: "Blood Group"; font.pixelSize: 11; color: "#888" }
                                                    Rectangle { width: parent.width; height: 42; radius: 10; color: emergencyEditMode ? "white" : "#F5F5F5"; border.color: emergencyEditMode ? "#1976D2" : "#EEEEEE"
                                                        TextInput { anchors { fill: parent; leftMargin: 14; rightMargin: 14 }; verticalAlignment: TextInput.AlignVCenter; text: bloodGroup; readOnly: !emergencyEditMode; placeholderText: "e.g. O+"; font.pixelSize: 14; color: "#111"; onTextChanged: bloodGroup = text }
                                                    }

                                                    Label { text: "Medical Notes"; font.pixelSize: 11; color: "#888" }
                                                    Rectangle {
                                                        width: parent.width; height: 70; radius: 10
                                                        color: emergencyEditMode ? "white" : "#F5F5F5"; border.color: emergencyEditMode ? "#1976D2" : "#EEEEEE"
                                                        TextEdit {
                                                            anchors { fill: parent; margins: 12 }
                                                            text: medicalNotes; readOnly: !emergencyEditMode
                                                            wrapMode: TextEdit.Wrap; font.pixelSize: 13; color: "#111"
                                                            onTextChanged: medicalNotes = text
                                                        }
                                                    }

                                                    Rectangle {
                                                        width: parent.width; height: 44; radius: 12; color: "#1976D2"; visible: emergencyEditMode
                                                        Label { anchors.centerIn: parent; text: "Save"; color: "white"; font.pixelSize: 14; font.bold: true }
                                                        MouseArea { anchors.fill: parent; onClicked: saveEmergencyInfo() }
                                                    }
                                                    Label { text: emergencySaveMessage; color: "#388E3C"; visible: emergencySaveMessage !== ""; font.pixelSize: 12 }

                                                    // Sync fields when data loads
                                                    Item {
                                                        property int tick: emergencySyncTick
                                                        onTickChanged: { }  // TextInput binds directly to properties
                                                    }
                                                }

                                                // ── RIDE HISTORY ──────────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "Ride History" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Repeater {
                                                        model: [
                                                            { date: "22 Jun 2026", from: "REVA University",  to: "Malleshwaram",     vehicle: "Auto",    fare: "₹124", km: "4.2 km" },
                                                            { date: "21 Jun 2026", from: "Bharathi Nagar",   to: "Kaverappa Layout", vehicle: "Bike",    fare: "₹35",  km: "1.3 km" },
                                                            { date: "20 Jun 2026", from: "Yeshwanthpur",     to: "MG Road",          vehicle: "Cab",     fare: "₹320", km: "11.0 km"},
                                                            { date: "18 Jun 2026", from: "Hebbal",           to: "Koramangala",      vehicle: "Carpool", fare: "₹68",  km: "9.5 km" }
                                                        ]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 90; radius: 12; color: "white"; border.color: "#EEEEEE"
                                                            Column {
                                                                anchors { fill: parent; margins: 12 }; spacing: 4
                                                                Row {
                                                                    width: parent.width
                                                                    Label { text: modelData.date; font.pixelSize: 11; color: "#888"; width: parent.width - fareL.implicitWidth }
                                                                    Label { id: fareL; text: modelData.fare; font.pixelSize: 14; font.bold: true; color: "#1976D2" }
                                                                }
                                                                Label { text: "📍 " + modelData.from; font.pixelSize: 12; color: "#333" }
                                                                Label { text: "🏁 " + modelData.to;   font.pixelSize: 12; color: "#333" }
                                                                Row {
                                                                    spacing: 8
                                                                    Rectangle { width: 52; height: 18; radius: 6; color: "#E3F2FD"; Label { anchors.centerIn: parent; text: modelData.vehicle; font.pixelSize: 10; color: "#1565C0" } }
                                                                    Label { text: modelData.km; font.pixelSize: 11; color: "#888" }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                // ── REWARDS & POINTS ──────────
                                                Column {
                                                    width: parent.width; spacing: 10
                                                    visible: item ? item.label === "Rewards & Points" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Rectangle {
                                                        width: parent.width; height: 90; radius: 14; color: "#1976D2"
                                                        Column {
                                                            anchors.centerIn: parent; spacing: 4
                                                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "🏆 " + rewardPoints + " YatraPoints"; font.pixelSize: 18; font.bold: true; color: "white" }
                                                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "≈ ₹" + rewardPoints / 10 + " ride credit"; font.pixelSize: 12; color: "#B3E5FC" }
                                                        }
                                                    }
                                                    Label { text: "HOW TO EARN"; font.pixelSize: 11; font.bold: true; color: "#AAAAAA" }
                                                    Repeater {
                                                        model: [
                                                            { icon: "🚗", title: "Complete a ride",      pts: "+10 pts" },
                                                            { icon: "⭐", title: "Rate your Sarthi",     pts: "+5 pts"  },
                                                            { icon: "👥", title: "Refer a friend",       pts: "+50 pts" },
                                                            { icon: "📅", title: "5 rides in a row",     pts: "+25 pts" }
                                                        ]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 48; radius: 10; color: "white"; border.color: "#EEEEEE"
                                                            Row {
                                                                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }; spacing: 12
                                                                Label { text: modelData.icon; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter }
                                                                Label { text: modelData.title; font.pixelSize: 13; color: "#111"; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 90 }
                                                                Label { text: modelData.pts; font.pixelSize: 12; font.bold: true; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter }
                                                            }
                                                        }
                                                    }
                                                }

                                                // ── PROMO CODES ───────────────
                                                Column {
                                                    width: parent.width; spacing: 10
                                                    visible: item ? item.label === "Promo Codes" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Rectangle {
                                                        width: parent.width; height: 48; radius: 12; color: "white"; border.color: "#EEEEEE"
                                                        Row {
                                                            anchors { fill: parent; leftMargin: 12; rightMargin: 8 }; spacing: 8
                                                            Label { text: "🎟️"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                                                            Label { text: "Enter promo code…"; font.pixelSize: 13; color: "#AAAAAA"; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 90 }
                                                            Rectangle {
                                                                width: 60; height: 32; radius: 8; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter
                                                                Label { anchors.centerIn: parent; text: "Apply"; color: "white"; font.pixelSize: 12; font.bold: true }
                                                            }
                                                        }
                                                    }
                                                    Label { text: "ACTIVE OFFERS"; font.pixelSize: 11; font.bold: true; color: "#AAAAAA" }
                                                    Repeater {
                                                        model: [
                                                            { code: "YATRA10", desc: "10% off next ride",     expiry: "Expires 30 Jun 2026", color: "#E8F5E9", border: "#A5D6A7" },
                                                            { code: "FIRST50", desc: "₹50 off for new users", expiry: "Expires 15 Jul 2026", color: "#E3F2FD", border: "#90CAF9" },
                                                            { code: "MONSOON", desc: "Flat ₹30 off",          expiry: "Expires 31 Aug 2026", color: "#FFF8E1", border: "#FFE082" }
                                                        ]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 72; radius: 12; color: modelData.color; border.color: modelData.border
                                                            Row {
                                                                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }; spacing: 10
                                                                Column {
                                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 3; width: parent.width - 76
                                                                    Label { text: modelData.code; font.pixelSize: 14; font.bold: true; color: "#1A1A1A" }
                                                                    Label { text: modelData.desc; font.pixelSize: 12; color: "#444" }
                                                                    Label { text: modelData.expiry; font.pixelSize: 10; color: "#888" }
                                                                }
                                                                Rectangle {
                                                                    width: 58; height: 28; radius: 8; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter
                                                                    Label { anchors.centerIn: parent; text: "Apply"; color: "white"; font.pixelSize: 11; font.bold: true }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                // ── NOTIFICATIONS ─────────────
                                                Column {
                                                    width: parent.width; spacing: 0
                                                    visible: item ? item.label === "Notifications" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Repeater {
                                                        model: [
                                                            { title: "Ride Alerts",       sub: "Start, completion, OTP",    on: true  },
                                                            { title: "Offers & Promos",   sub: "Deals and discount codes",  on: true  },
                                                            { title: "Payment Updates",   sub: "Receipt and fare changes",  on: true  },
                                                            { title: "App Updates",       sub: "New features and patches",  on: false },
                                                            { title: "Driver Nearby",     sub: "Sarthi approaching alerts", on: true  }
                                                        ]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 52; color: "transparent"
                                                            property bool tog: modelData.on
                                                            Row {
                                                                anchors { fill: parent; leftMargin: 4; rightMargin: 4 }; spacing: 10
                                                                Column {
                                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 56
                                                                    Label { text: modelData.title; font.pixelSize: 13; color: "#111" }
                                                                    Label { text: modelData.sub;   font.pixelSize: 11; color: "#888" }
                                                                }
                                                                Rectangle {
                                                                    width: 38; height: 22; radius: 11; anchors.verticalCenter: parent.verticalCenter
                                                                    color: tog ? "#1976D2" : "#CCCCCC"
                                                                    Rectangle {
                                                                        width: 18; height: 18; radius: 9; color: "white"; anchors.verticalCenter: parent.verticalCenter
                                                                        x: tog ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } }
                                                                    }
                                                                    MouseArea { anchors.fill: parent; onClicked: tog = !tog }
                                                                }
                                                            }
                                                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F0F0F0" }
                                                        }
                                                    }
                                                }

                                                // ── SAVED PLACES ──────────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "Saved Places" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Repeater {
                                                        model: [
                                                            { icon: "🏠", label: "Home", addr: "Tap to set home address",          set: false },
                                                            { icon: "💼", label: "Work", addr: "Tap to set work address",          set: false },
                                                            { icon: "⭐", label: "REVA University", addr: "Bellahalli Main Road", set: true  },
                                                            { icon: "⭐", label: "Phoenix Mall",    addr: "Whitefield, Bengaluru", set: true  }
                                                        ]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 58; radius: 12; color: "white"; border.color: "#EEEEEE"
                                                            Row {
                                                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }; spacing: 10
                                                                Label { text: modelData.icon; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                                                                Column {
                                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 70
                                                                    Label { text: modelData.label; font.pixelSize: 13; font.bold: true; color: "#111" }
                                                                    Label { text: modelData.addr; font.pixelSize: 11; color: modelData.set ? "#555" : "#AAAAAA" }
                                                                }
                                                                Label { text: modelData.set ? "✎" : "+"; font.pixelSize: 18; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter }
                                                            }
                                                        }
                                                    }
                                                }

                                                // ── LANGUAGE ──────────────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "Language" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Repeater {
                                                        model: ["English", "ಕನ್ನಡ (Kannada)", "हिन्दी (Hindi)", "తెలుగు (Telugu)", "தமிழ் (Tamil)"]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 48; radius: 10
                                                            color: selectedLanguage === modelData ? "#E3F2FD" : "white"
                                                            border.color: selectedLanguage === modelData ? "#1976D2" : "#EEEEEE"
                                                            Row {
                                                                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                                                                Label { text: modelData; font.pixelSize: 14; color: "#111"; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 24 }
                                                                Label { text: selectedLanguage === modelData ? "✓" : ""; font.pixelSize: 16; color: "#1976D2"; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                                                            }
                                                            MouseArea { anchors.fill: parent; onClicked: selectedLanguage = modelData }
                                                        }
                                                    }
                                                }

                                                // ── SAFETY SETTINGS ───────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "Safety Settings" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Repeater {
                                                        model: [
                                                            { icon: "👥", title: "Trusted Contacts",     sub: "Add emergency contacts",    btn: "Manage" },
                                                            { icon: "📍", title: "Share Ride Location",  sub: "Send live location",         btn: "Enable" },
                                                            { icon: "🚨", title: "SOS Quick Trigger",    sub: "Shake phone to trigger SOS", btn: "On"     },
                                                            { icon: "🛡️", title: "Verified Sarthi Only", sub: "Only matched verified drivers",btn: "On"   }
                                                        ]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 60; radius: 12; color: "white"; border.color: "#EEEEEE"
                                                            Row {
                                                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }; spacing: 10
                                                                Label { text: modelData.icon; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                                                                Column {
                                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 100
                                                                    Label { text: modelData.title; font.pixelSize: 13; font.bold: true; color: "#111" }
                                                                    Label { text: modelData.sub;   font.pixelSize: 11; color: "#888" }
                                                                }
                                                                Rectangle {
                                                                    width: 52; height: 26; radius: 8; anchors.verticalCenter: parent.verticalCenter
                                                                    color: (modelData.btn === "On" || modelData.btn === "Enable") ? "#E8F5E9" : "#F5F5F5"
                                                                    Label {
                                                                        anchors.centerIn: parent; text: modelData.btn; font.pixelSize: 11; font.bold: true
                                                                        color: (modelData.btn === "On" || modelData.btn === "Enable") ? "#2E7D32" : "#888"
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                // ── WALLET BALANCE ────────────
                                                Column {
                                                    width: parent.width; spacing: 10
                                                    visible: item ? item.label === "Wallet Balance" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Rectangle {
                                                        width: parent.width; height: 100; radius: 14; color: "#1976D2"
                                                        Column {
                                                            anchors.centerIn: parent; spacing: 4
                                                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "💳"; font.pixelSize: 28 }
                                                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "₹" + walletBalance.toFixed(2); font.pixelSize: 26; font.bold: true; color: "white" }
                                                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "YatraSarthi Wallet"; font.pixelSize: 11; color: "#B3E5FC" }
                                                        }
                                                    }
                                                    Label { text: "QUICK ADD"; font.pixelSize: 11; font.bold: true; color: "#AAAAAA" }
                                                    Row {
                                                        spacing: 8
                                                        Repeater {
                                                            model: ["₹100", "₹250", "₹500", "₹1000"]
                                                            delegate: Rectangle {
                                                                width: 66; height: 36; radius: 10; color: "white"; border.color: "#1976D2"
                                                                Label { anchors.centerIn: parent; text: modelData; font.pixelSize: 13; font.bold: true; color: "#1976D2" }
                                                                MouseArea { anchors.fill: parent; onClicked: console.log("Add", modelData) }
                                                            }
                                                        }
                                                    }
                                                    Rectangle {
                                                        width: parent.width; height: 44; radius: 12; color: "#1976D2"
                                                        Label { anchors.centerIn: parent; text: "Add Money via UPI / Card"; color: "white"; font.pixelSize: 13; font.bold: true }
                                                    }
                                                    Label { text: "No recent transactions"; font.pixelSize: 12; color: "#AAAAAA"; anchors.horizontalCenter: parent.horizontalCenter }
                                                }

                                                // ── GST INVOICE ───────────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "GST Invoice" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Repeater {
                                                        model: [
                                                            { date: "22 Jun 2026", no: "YS-2026-0042", fare: "₹124", gst: "₹6.20"  },
                                                            { date: "21 Jun 2026", no: "YS-2026-0041", fare: "₹35",  gst: "₹1.75"  },
                                                            { date: "20 Jun 2026", no: "YS-2026-0040", fare: "₹320", gst: "₹16.00" }
                                                        ]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 84; radius: 12; color: "white"; border.color: "#EEEEEE"
                                                            Column {
                                                                anchors { fill: parent; margins: 12 }; spacing: 4
                                                                Row {
                                                                    width: parent.width
                                                                    Label { text: modelData.no; font.pixelSize: 12; font.bold: true; color: "#111"; width: parent.width - gstFare.implicitWidth }
                                                                    Label { id: gstFare; text: modelData.fare; font.pixelSize: 14; font.bold: true; color: "#1976D2" }
                                                                }
                                                                Label { text: modelData.date; font.pixelSize: 11; color: "#888" }
                                                                Label { text: "GST (5%): " + modelData.gst; font.pixelSize: 11; color: "#555" }
                                                                Rectangle {
                                                                    width: 120; height: 24; radius: 6; color: "#E3F2FD"
                                                                    Label { anchors.centerIn: parent; text: "⬇ Download PDF"; font.pixelSize: 10; color: "#1565C0"; font.bold: true }
                                                                    MouseArea { anchors.fill: parent; onClicked: console.log("Download", modelData.no) }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                // ── LIVE CHAT ─────────────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "Live Chat Support" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Row {
                                                        spacing: 8
                                                        Rectangle { width: 10; height: 10; radius: 5; color: "#4CAF50"; anchors.verticalCenter: parent.verticalCenter }
                                                        Label { text: "Support agent online"; font.pixelSize: 12; color: "#388E3C" }
                                                    }
                                                    Repeater {
                                                        model: [
                                                            { from: "agent", text: "👋 Hi Johney! I'm Priya from YatraSarthi Support. How can I help?" },
                                                            { from: "user",  text: "My last ride fare seems incorrect." },
                                                            { from: "agent", text: "I'm sorry! Please share the ride date and I'll look into it right away." }
                                                        ]
                                                        delegate: Item {
                                                            width: parent.width
                                                            height: cBubble.implicitHeight + 8
                                                            Rectangle {
                                                                id: cBubble
                                                                anchors.right: modelData.from === "user" ? parent.right : undefined
                                                                anchors.left:  modelData.from === "agent" ? parent.left : undefined
                                                                width: Math.min(cTxt.implicitWidth + 24, parent.width * 0.8)
                                                                height: cTxt.implicitHeight + 20; radius: 12
                                                                color: modelData.from === "user" ? "#1976D2" : "white"
                                                                border.color: modelData.from === "agent" ? "#EEEEEE" : "transparent"
                                                                Label {
                                                                    id: cTxt; anchors { fill: parent; margins: 10 }
                                                                    text: modelData.text; font.pixelSize: 12
                                                                    color: modelData.from === "user" ? "white" : "#111"
                                                                    wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }
                                                    Rectangle {
                                                        width: parent.width; height: 44; radius: 22; color: "#F5F5F5"; border.color: "#EEEEEE"
                                                        Row {
                                                            anchors { fill: parent; leftMargin: 16; rightMargin: 8 }; spacing: 8
                                                            Label { text: "Type a message…"; font.pixelSize: 13; color: "#AAAAAA"; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 46 }
                                                            Rectangle {
                                                                width: 34; height: 34; radius: 17; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter
                                                                Label { anchors.centerIn: parent; text: "➤"; color: "white"; font.pixelSize: 14 }
                                                            }
                                                        }
                                                    }
                                                }

                                                // ── HELP & SUPPORT ────────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "Help & Support" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Repeater {
                                                        model: [
                                                            { q: "How do I cancel a ride?",         a: "Go to active ride → tap 'Cancel Ride' before driver arrives." },
                                                            { q: "Wrong fare charged?",              a: "Tap 'Help' on the trip receipt and raise a fare dispute." },
                                                            { q: "Driver didn't arrive?",            a: "Use SOS or call driver from the ride screen." },
                                                            { q: "How to update payment method?",   a: "Account → Payment Methods → Add new method." }
                                                        ]
                                                        delegate: Column {
                                                            width: parent.width; spacing: 0
                                                            property bool expanded: false
                                                            Rectangle {
                                                                width: parent.width; height: 48; color: "transparent"
                                                                Row {
                                                                    anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
                                                                    Label { text: modelData.q; font.pixelSize: 13; color: "#111"; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 24; wrapMode: Text.WordWrap }
                                                                    Label { text: parent.parent.parent.expanded ? "▲" : "▼"; font.pixelSize: 12; color: "#AAAAAA"; anchors.verticalCenter: parent.verticalCenter }
                                                                }
                                                                MouseArea { anchors.fill: parent; onClicked: parent.parent.expanded = !parent.parent.expanded }
                                                            }
                                                            Rectangle {
                                                                width: parent.width; visible: parent.expanded; height: visible ? ansLbl.implicitHeight + 16 : 0
                                                                color: "#F5F5F5"; radius: 8
                                                                Label { id: ansLbl; text: modelData.a; anchors { fill: parent; margins: 8 }; font.pixelSize: 12; color: "#555"; wrapMode: Text.WordWrap }
                                                            }
                                                            Rectangle { width: parent.width; height: 1; color: "#F0F0F0" }
                                                        }
                                                    }
                                                }

                                                // ── SAFETY FEATURES ───────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "Safety Features" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Repeater {
                                                        model: [
                                                            { icon: "📍", title: "Share Trip",       sub: "Send live ride link to family" },
                                                            { icon: "🚨", title: "SOS Button",       sub: "Alerts police + emergency contacts" },
                                                            { icon: "🎙️", title: "Audio Safety",     sub: "Record ride audio for safety" },
                                                            { icon: "⭐", title: "Driver Verified",  sub: "All Sarthis are background checked" }
                                                        ]
                                                        delegate: Rectangle {
                                                            width: parent.width; height: 56; radius: 12; color: "white"; border.color: "#EEEEEE"
                                                            Row {
                                                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }; spacing: 10
                                                                Label { text: modelData.icon; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                                                                Column {
                                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 80
                                                                    Label { text: modelData.title; font.pixelSize: 13; font.bold: true; color: "#111" }
                                                                    Label { text: modelData.sub;   font.pixelSize: 11; color: "#888" }
                                                                }
                                                                Label { text: "›"; font.pixelSize: 20; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter }
                                                            }
                                                        }
                                                    }
                                                }

                                                // ── RATE THE APP ──────────────
                                                Column {
                                                    width: parent.width; spacing: 10
                                                    visible: item ? item.label === "Rate the App" : false
                                                    property int appRating: 0
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: "How's your YatraSarthi experience?"; font.pixelSize: 13; color: "#555"; wrapMode: Text.WordWrap; width: parent.width }
                                                    Row {
                                                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 8
                                                        Repeater {
                                                            model: 5
                                                            delegate: Label {
                                                                text: "★"; font.pixelSize: 40
                                                                color: index < parent.parent.parent.appRating ? "#FFC107" : "#D0D0D0"
                                                                MouseArea { anchors.fill: parent; onClicked: parent.parent.parent.parent.appRating = index + 1 }
                                                            }
                                                        }
                                                    }
                                                    Label {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: parent.appRating === 0 ? "Tap to rate" : parent.appRating === 5 ? "Excellent! 🎉" : parent.appRating >= 4 ? "Great!" : parent.appRating >= 3 ? "Good" : "Needs improvement"
                                                        font.pixelSize: 13; color: parent.appRating === 0 ? "#AAAAAA" : "#F57F17"; font.bold: parent.appRating > 0
                                                    }
                                                    Rectangle {
                                                        width: parent.width; height: 44; radius: 12; color: "#1976D2"; visible: parent.appRating > 0
                                                        Label { anchors.centerIn: parent; text: "Submit Rating"; color: "white"; font.pixelSize: 14; font.bold: true }
                                                        MouseArea { anchors.fill: parent; onClicked: console.log("App rated:", parent.parent.appRating) }
                                                    }
                                                }

                                                // ── PRIVACY POLICY ────────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "Privacy Policy" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Label {
                                                        width: parent.width; wrapMode: Text.WordWrap; font.pixelSize: 12; color: "#555"; lineHeight: 1.5
                                                        text: "YatraSarthi collects location, ride, and payment data solely to provide ride-hailing services. Your data is never sold to third parties.\n\n• Location is used only during active rides.\n• Payment info is encrypted and stored securely.\n• You can delete your account and data anytime.\n• We comply with India's DPDP Act 2023."
                                                    }
                                                    Rectangle {
                                                        width: parent.width; height: 40; radius: 10; color: "#E3F2FD"; border.color: "#90CAF9"
                                                        Label { anchors.centerIn: parent; text: "Read Full Policy →"; font.pixelSize: 13; color: "#1565C0"; font.bold: true }
                                                        MouseArea { anchors.fill: parent; onClicked: console.log("Open full policy") }
                                                    }
                                                }

                                                // ── ABOUT ─────────────────────
                                                Column {
                                                    width: parent.width; spacing: 8
                                                    visible: item ? item.label === "About YatraSarthi" : false
                                                    Rectangle { width: parent.width; height: 1; color: "#EEEEEE" }
                                                    Column {
                                                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 6
                                                        Rectangle {
                                                            width: 64; height: 64; radius: 16; color: "#1976D2"; anchors.horizontalCenter: parent.horizontalCenter
                                                            Label { anchors.centerIn: parent; text: "🚗"; font.pixelSize: 30 }
                                                        }
                                                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: "YatraSarthi"; font.pixelSize: 18; font.bold: true; color: "#1976D2" }
                                                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Version 3.2.1 (Build 421)"; font.pixelSize: 12; color: "#888" }
                                                    }
                                                    Repeater {
                                                        model: [
                                                            { label: "Developer",     value: "YatraSarthi Technologies Pvt Ltd" },
                                                            { label: "Headquarters",  value: "Bengaluru, Karnataka, India" },
                                                            { label: "Support Email", value: "help@yatrasarthi.in" },
                                                            { label: "License",       value: "MSME Registered · ISO 9001:2015" }
                                                        ]
                                                        delegate: Row {
                                                            width: parent.width; spacing: 8
                                                            Label { text: modelData.label + ":"; font.pixelSize: 12; color: "#888"; width: 110 }
                                                            Label { text: modelData.value; font.pixelSize: 12; color: "#111"; wrapMode: Text.WordWrap; width: parent.width - 118 }
                                                        }
                                                    }
                                                }

                                            } // panelCol
                                        } // panel Rectangle
                                    } // delegate Column
                                } // Repeater
                            } // secCol
                        } // card Rectangle
                    } // section Column
                } // sections Repeater

                // ── Log Out ───────────────────────────────────────────────────
                Button {
                    x: 16; width: parent.width - 32; height: 52
                    background: Rectangle { color: "#FFEBEE"; radius: 14; border.color: "#FFCDD2" }
                    contentItem: Text {
                        text: "Log Out"; font.pixelSize: 15; font.bold: true; color: "#C62828"
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: console.log("Logout")
                }

                Item { width: 1; height: 20 }
            } // outer Column
        }
    }
}
