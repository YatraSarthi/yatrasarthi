import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Page {

    property var appStack
    property var appState

    signal switchTab(int tabIndex)

    footer: null
    header: null

    onVisibleChanged: {
        if (visible && appState) appState.showBottomBar = true
    }

    // ── EMERGENCY CONTACTS STATE ─────────────────────────────────────────
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

    // ── PROFILE EDIT STATE ───────────────────────────────────────────────
    property bool profileEditExpanded: false
    property bool profileEditMode: false
    property string profileSaveMessage: ""
    property string profileName: "Johney"
    property string profileEmail: "johney@example.com"
    property string profilePhone: "+91 98765 43210"
    property int profileSyncTick: 0

    // ── PAYMENT STATE ────────────────────────────────────────────────────
    property bool paymentExpanded: false
    property int selectedPaymentIndex: 0   // 0=UPI, 1=Card, 2=Wallet

    // ── RIDE HISTORY STATE ───────────────────────────────────────────────
    property bool rideHistoryExpanded: false
    property var rideHistoryData: [
        { date: "22 Jun 2026", from: "Koramangala", to: "Indiranagar", fare: "₹148", status: "Completed" },
        { date: "20 Jun 2026", from: "MG Road",     to: "Whitefield",  fare: "₹320", status: "Completed" },
        { date: "18 Jun 2026", from: "HSR Layout",  to: "Jayanagar",   fare: "₹95",  status: "Cancelled" }
    ]

    // ── REWARDS STATE ────────────────────────────────────────────────────
    property bool rewardsExpanded: false
    property int rewardPoints: 1240
    property var couponList: [
        { code: "RIDE20",  desc: "20% off next ride",    expiry: "30 Jun 2026" },
        { code: "FLAT50",  desc: "₹50 off on ₹200+",    expiry: "15 Jul 2026" },
        { code: "GOLD10",  desc: "Gold member bonus 10%", expiry: "31 Jul 2026" }
    ]

    // ── NOTIFICATIONS STATE ──────────────────────────────────────────────
    property bool notifExpanded: false
    property bool notifRideAlerts: true
    property bool notifOffers: true
    property bool notifSMS: false
    property bool notifEmail: true

    // ── HELP STATE ───────────────────────────────────────────────────────
    property bool helpExpanded: false

    // ── SAFETY STATE ─────────────────────────────────────────────────────
    property bool safetyExpanded: false
    property bool safetyShareTrip: false
    property bool safetyIncognito: false

    // ── DARK MODE ────────────────────────────────────────────────────────
    property bool darkModeEnabled: false

    // ── LANGUAGE ─────────────────────────────────────────────────────────
    property bool langExpanded: false
    property int selectedLang: 0  // 0=English
    property var languages: ["English", "हिन्दी", "ಕನ್ನಡ", "தமிழ்", "తెలుగు"]

    Component.onCompleted: { loadEmergencyInfo() }

    onEmergencyExpandedChanged: { if (emergencyExpanded) emergencySyncTick++ }
    onEmergencyEditModeChanged: { if (!emergencyEditMode) emergencySyncTick++ }
    onProfileEditExpandedChanged: { if (profileEditExpanded) profileSyncTick++ }

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
                } catch (e) { console.log("Emergency Info Parse Error:", e) }
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/sos/info", true)
        xhr.send()
    }

    function saveEmergencyInfo() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                emergencySaveMessage = (xhr.status === 200) ? "Saved successfully" : "Failed to save"
                if (xhr.status === 200) emergencyEditMode = false
            }
        }
        xhr.onerror = function() { emergencySaveMessage = "Unable to contact server" }
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

    function saveProfile() {
        profileName = pNameField.text
        profileEmail = pEmailField.text
        profilePhone = pPhoneField.text
        profileEditMode = false
        profileSaveMessage = "Profile updated successfully"
        profileSyncTick++
    }

    function collapseAll() {
        profileEditExpanded = false
        profileEditMode = false
        paymentExpanded = false
        emergencyExpanded = false
        emergencyEditMode = false
        rideHistoryExpanded = false
        rewardsExpanded = false
        notifExpanded = false
        helpExpanded = false
        safetyExpanded = false
        langExpanded = false
    }

    // ── REUSABLE COMPONENTS ──────────────────────────────────────────────

    // Section header label component (used inline below)
    // Inline field row: label + read/edit TextField
    component FieldRow: Column {
        property string fieldLabel: ""
        property string fieldPlaceholder: ""
        property bool editMode: false
        property alias fieldText: tf.text
        property alias tf: tf
        spacing: 4
        width: parent.width

        Label {
            text: fieldLabel
            font.pixelSize: 11; color: "#999"
        }
        TextField {
            id: tf
            width: parent.width
            placeholderText: fieldPlaceholder
            readOnly: !editMode
            background: Rectangle {
                color: editMode ? "white" : "#F8F9FA"
                radius: 8
                border.color: editMode ? "#1976D2" : "#EEEEEE"
                border.width: editMode ? 1.5 : 1
            }
            leftPadding: 12; rightPadding: 12
            font.pixelSize: 13
        }
    }

    // ── UI ───────────────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {
            width: parent.width
            spacing: 0

            // ── Top header bar ─────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 56
                color: "#1976D2"

                Rectangle {
                    id: backBtn
                    width: 36; height: 36; radius: 18
                    color: backBtnMouse.containsMouse ? "#E3F2FD" : "white"
                    anchors.left: parent.left; anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { text: "‹"; font.pixelSize: 28; font.bold: true; color: "#1565C0"; anchors.centerIn: parent; anchors.horizontalCenterOffset: -1 }
                    MouseArea { id: backBtnMouse; anchors.fill: parent; hoverEnabled: true; onClicked: switchTab(0) }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: backBtn.right; anchors.leftMargin: 10
                    text: "Account"; font.pixelSize: 20; font.bold: true; color: "white"
                }
            }

            // ── Profile header card ────────────────────────────────────
            Rectangle {
                width: parent.width; height: 170; color: "#1976D2"; clip: true

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
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    collapseAll()
                                    profileEditExpanded = true
                                    profileEditMode = true
                                }
                            }
                        }
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: profileName; font.pixelSize: 18; font.bold: true; color: "white"
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: profilePhone; font.pixelSize: 12; color: "#B3E5FC"
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 8
                        Repeater {
                            model: ["⭐ 4.8 Rating", "142 Rides", "Gold Member"]
                            delegate: Rectangle {
                                height: 20; radius: 10; color: "#ffffff25"; border.color: "#ffffff40"
                                width: badgeText.implicitWidth + 16
                                Text { id: badgeText; anchors.centerIn: parent; text: modelData; font.pixelSize: 10; color: "white" }
                            }
                        }
                    }
                }
            }

            Column {
                width: parent.width; spacing: 14

                Item { width: 1; height: 14 }

                // ════════════════════════════════════════════════════════
                // PROFILE SECTION
                // ════════════════════════════════════════════════════════
                SectionLabel { sectionTitle: "PROFILE" }

                SectionCard {
                    // ── Edit Profile ──────────────────────────────────
                    ExpandableRow {
                        rowIcon: Qt.resolvedUrl("../../assets/icons/driver.png")
                        rowLabel: "Edit Profile"
                        rowSub: profileName + " · " + profileEmail
                        expanded: profileEditExpanded
                        onRowClicked: {
                            var wasOpen = profileEditExpanded
                            collapseAll()
                            profileEditExpanded = !wasOpen
                            if (profileEditExpanded) { profileSaveMessage = "" }
                            else { profileEditMode = false }
                        }

                        expandedContent: Column {
                            width: parent.width; spacing: 12
                            topPadding: 4; bottomPadding: 16
                            leftPadding: 16; rightPadding: 16

                            ExpandDivider {}

                            Row {
                                width: parent.width - 32
                                Label {
                                    text: "Personal Details"
                                    font.pixelSize: 12; font.bold: true; color: "#888"
                                    width: parent.width - editProfileBtn.width
                                }
                                Button {
                                    id: editProfileBtn
                                    text: profileEditMode ? "Cancel" : "Edit"
                                    flat: true; font.pixelSize: 13; font.bold: true
                                    palette.buttonText: "#1976D2"
                                    onClicked: {
                                        if (profileEditMode) {
                                            // restore
                                            profileSyncTick++
                                            profileSaveMessage = ""
                                        }
                                        profileEditMode = !profileEditMode
                                    }
                                }
                            }

                            Item {
                                property int tick: profileSyncTick
                                onTickChanged: {
                                    pNameField.text  = profileName
                                    pEmailField.text = profileEmail
                                    pPhoneField.text = profilePhone
                                }
                                Component.onCompleted: {
                                    pNameField.text  = profileName
                                    pEmailField.text = profileEmail
                                    pPhoneField.text = profilePhone
                                }
                            }

                            Column {
                                width: parent.width - 32; spacing: 10

                                FieldRow {
                                    id: pNameRow
                                    fieldLabel: "Full Name"
                                    fieldPlaceholder: "Your name"
                                    editMode: profileEditMode
                                    tf.id: pNameField
                                    width: parent.width
                                }
                                FieldRow {
                                    id: pEmailRow
                                    fieldLabel: "Email"
                                    fieldPlaceholder: "your@email.com"
                                    editMode: profileEditMode
                                    tf.id: pEmailField
                                    width: parent.width
                                }
                                FieldRow {
                                    id: pPhoneRow
                                    fieldLabel: "Phone Number"
                                    fieldPlaceholder: "+91 XXXXX XXXXX"
                                    editMode: profileEditMode
                                    tf.inputMethodHints: Qt.ImhDialableCharactersOnly
                                    tf.id: pPhoneField
                                    width: parent.width
                                }
                            }

                            // Gender selector (read-only in view, editable in edit)
                            Column {
                                width: parent.width - 32; spacing: 4
                                Label { text: "Gender"; font.pixelSize: 11; color: "#999" }
                                Row {
                                    spacing: 8
                                    property int selGender: 0
                                    Repeater {
                                        model: ["Male", "Female", "Other"]
                                        delegate: Rectangle {
                                            width: genderText.implicitWidth + 20; height: 30; radius: 15
                                            color: (parent.selGender === index) ? "#1976D2" : "#F0F4FF"
                                            border.color: (parent.selGender === index) ? "#1565C0" : "#D0D8FF"
                                            opacity: profileEditMode ? 1.0 : 0.6
                                            Text {
                                                id: genderText; anchors.centerIn: parent
                                                text: modelData; font.pixelSize: 12
                                                color: (parent.parent.selGender === index) ? "white" : "#555"
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                enabled: profileEditMode
                                                onClicked: parent.parent.selGender = index
                                            }
                                        }
                                    }
                                }
                            }

                            ActionButton {
                                visible: profileEditMode
                                btnText: "Save Profile"
                                onBtnClicked: saveProfile()
                            }

                            SaveMessage { msg: profileSaveMessage }
                        }
                    }

                    RowDivider {}

                    // ── Payment Methods ───────────────────────────────
                    ExpandableRow {
                        rowIcon: Qt.resolvedUrl("../../assets/icons/star.png")
                        rowLabel: "Payment Methods"
                        rowSub: "UPI, cards, wallets"
                        expanded: paymentExpanded
                        onRowClicked: {
                            var wasOpen = paymentExpanded
                            collapseAll()
                            paymentExpanded = !wasOpen
                        }

                        expandedContent: Column {
                            width: parent.width; spacing: 0
                            topPadding: 4; bottomPadding: 8

                            ExpandDivider {}

                            // Payment method tabs
                            Row {
                                x: 16; spacing: 0
                                width: parent.width - 32

                                Repeater {
                                    model: ["UPI", "Cards", "Wallet"]
                                    delegate: Rectangle {
                                        width: (parent.width) / 3; height: 36
                                        color: selectedPaymentIndex === index ? "#E3F2FD" : "transparent"
                                        border.color: selectedPaymentIndex === index ? "#1976D2" : "transparent"
                                        radius: selectedPaymentIndex === index ? 8 : 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData; font.pixelSize: 13
                                            font.bold: selectedPaymentIndex === index
                                            color: selectedPaymentIndex === index ? "#1976D2" : "#888"
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: selectedPaymentIndex = index }
                                    }
                                }
                            }

                            Rectangle { width: parent.width - 32; height: 1; color: "#EEE"; x: 16 }

                            // UPI Panel
                            Column {
                                visible: selectedPaymentIndex === 0
                                width: parent.width - 32; x: 16
                                spacing: 8; topPadding: 12; bottomPadding: 8

                                // Saved UPI IDs
                                Repeater {
                                    model: ["johney@upi", "johney@okaxis"]
                                    delegate: Rectangle {
                                        width: parent.width; height: 52; radius: 10
                                        color: "#F8F9FA"; border.color: "#EEEEEE"
                                        Row {
                                            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                                            spacing: 10
                                            Rectangle { width: 32; height: 32; radius: 8; color: "#E3F2FD"; anchors.verticalCenter: parent.verticalCenter
                                                Text { anchors.centerIn: parent; text: "₹"; font.pixelSize: 16; font.bold: true; color: "#1976D2" }
                                            }
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                                Label { text: modelData; font.pixelSize: 13; color: "#111" }
                                                Label { text: index === 0 ? "Default" : "Linked"; font.pixelSize: 11; color: index === 0 ? "#43A047" : "#888" }
                                            }
                                            Item { width: 1; Layout.fillWidth: true }
                                        }
                                    }
                                }

                                // Add UPI
                                Rectangle {
                                    width: parent.width; height: 44; radius: 10
                                    color: "#EEF4FF"; border.color: "#C5D8FF"
                                    Row {
                                        anchors.centerIn: parent; spacing: 8
                                        Text { text: "+"; font.pixelSize: 18; color: "#1976D2"; font.bold: true }
                                        Text { text: "Add UPI ID"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: console.log("Add UPI") }
                                }
                            }

                            // Card Panel
                            Column {
                                visible: selectedPaymentIndex === 1
                                width: parent.width - 32; x: 16
                                spacing: 8; topPadding: 12; bottomPadding: 8

                                Rectangle {
                                    width: parent.width; height: 80; radius: 12
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#1565C0" }
                                        GradientStop { position: 1.0; color: "#42A5F5" }
                                    }
                                    Column {
                                        anchors.left: parent.left; anchors.leftMargin: 16
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                        Label { text: "**** **** **** 4521"; font.pixelSize: 14; color: "white"; font.letterSpacing: 1 }
                                        Label { text: "JOHNEY  ·  Expires 09/28"; font.pixelSize: 11; color: "#B3E5FC" }
                                    }
                                    Rectangle {
                                        width: 40; height: 24; radius: 4; color: "#FFD600"
                                        anchors.right: parent.right; anchors.rightMargin: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: "VISA"; font.pixelSize: 10; font.bold: true; color: "#333" }
                                    }
                                }

                                Rectangle {
                                    width: parent.width; height: 44; radius: 10
                                    color: "#EEF4FF"; border.color: "#C5D8FF"
                                    Row { anchors.centerIn: parent; spacing: 8
                                        Text { text: "+"; font.pixelSize: 18; color: "#1976D2"; font.bold: true }
                                        Text { text: "Add Card"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: console.log("Add Card") }
                                }
                            }

                            // Wallet Panel
                            Column {
                                visible: selectedPaymentIndex === 2
                                width: parent.width - 32; x: 16
                                spacing: 8; topPadding: 12; bottomPadding: 8

                                Rectangle {
                                    width: parent.width; height: 64; radius: 12
                                    color: "#F1F8E9"; border.color: "#C5E1A5"
                                    Row {
                                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 12
                                        Rectangle { width: 36; height: 36; radius: 18; color: "#43A047"; anchors.verticalCenter: parent.verticalCenter
                                            Text { anchors.centerIn: parent; text: "₹"; font.pixelSize: 18; font.bold: true; color: "white" }
                                        }
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                            Label { text: "YatraCash Balance"; font.pixelSize: 13; font.bold: true; color: "#2E7D32" }
                                            Label { text: "₹250.00 available"; font.pixelSize: 12; color: "#555" }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width; height: 44; radius: 10
                                    color: "#E8F5E9"; border.color: "#A5D6A7"
                                    Row { anchors.centerIn: parent; spacing: 8
                                        Text { text: "+"; font.pixelSize: 18; color: "#43A047"; font.bold: true }
                                        Text { text: "Add Money"; font.pixelSize: 13; color: "#43A047"; font.bold: true }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: console.log("Add Money") }
                                }
                            }
                        }
                    }

                    RowDivider {}

                    // ── Emergency Contacts ────────────────────────────
                    ExpandableRow {
                        rowIcon: Qt.resolvedUrl("../../assets/icons/sos.png")
                        rowLabel: "Emergency Contacts"
                        rowSub: "SOS contacts & medical info"
                        expanded: emergencyExpanded
                        onRowClicked: {
                            var wasOpen = emergencyExpanded
                            collapseAll()
                            emergencyExpanded = !wasOpen
                            if (emergencyExpanded) { emergencySaveMessage = ""; loadEmergencyInfo() }
                        }

                        expandedContent: Column {
                            width: parent.width; spacing: 14
                            topPadding: 4; bottomPadding: 16; leftPadding: 16; rightPadding: 16

                            ExpandDivider {}

                            Row {
                                width: parent.width - 32
                                Label { text: "Saved Information"; font.pixelSize: 12; font.bold: true; color: "#888"; width: parent.width - editToggleBtn.width }
                                Button {
                                    id: editToggleBtn
                                    text: emergencyEditMode ? "Cancel" : "Edit"; flat: true
                                    palette.buttonText: "#1976D2"
                                    onClicked: {
                                        if (emergencyEditMode) { loadEmergencyInfo(); emergencySaveMessage = "" }
                                        emergencyEditMode = !emergencyEditMode
                                    }
                                }
                            }

                            Label { text: "Emergency Contact 1"; font.pixelSize: 12; color: "#888" }
                            TextField { id: acc1NameField; width: parent.width - 32; placeholderText: "Name"; readOnly: !emergencyEditMode; onTextChanged: contact1Name = text }
                            TextField { id: acc1PhoneField; width: parent.width - 32; placeholderText: "Phone number"; readOnly: !emergencyEditMode; inputMethodHints: Qt.ImhDialableCharactersOnly; onTextChanged: contact1Phone = text }

                            Label { text: "Emergency Contact 2"; font.pixelSize: 12; color: "#888" }
                            TextField { id: acc2NameField; width: parent.width - 32; placeholderText: "Name"; readOnly: !emergencyEditMode; onTextChanged: contact2Name = text }
                            TextField { id: acc2PhoneField; width: parent.width - 32; placeholderText: "Phone number"; readOnly: !emergencyEditMode; inputMethodHints: Qt.ImhDialableCharactersOnly; onTextChanged: contact2Phone = text }

                            Label { text: "Blood Group"; font.pixelSize: 12; color: "#888" }
                            TextField { id: accBloodField; width: parent.width - 32; placeholderText: "e.g. O+"; readOnly: !emergencyEditMode; onTextChanged: bloodGroup = text }

                            Label { text: "Medical Notes"; font.pixelSize: 12; color: "#888" }
                            TextArea { id: accNotesField; width: parent.width - 32; placeholderText: "Allergies, conditions, medications..."; readOnly: !emergencyEditMode; wrapMode: TextArea.Wrap; onTextChanged: medicalNotes = text }

                            Item {
                                property int tick: emergencySyncTick
                                onTickChanged: { acc1NameField.text = contact1Name; acc1PhoneField.text = contact1Phone; acc2NameField.text = contact2Name; acc2PhoneField.text = contact2Phone; accBloodField.text = bloodGroup; accNotesField.text = medicalNotes }
                                Component.onCompleted: { acc1NameField.text = contact1Name; acc1PhoneField.text = contact1Phone; acc2NameField.text = contact2Name; acc2PhoneField.text = contact2Phone; accBloodField.text = bloodGroup; accNotesField.text = medicalNotes }
                            }

                            ActionButton { visible: emergencyEditMode; btnText: "Save Emergency Info"; onBtnClicked: saveEmergencyInfo() }
                            SaveMessage { msg: emergencySaveMessage }
                        }
                    }

                    RowDivider {}

                    // ── Ride History ──────────────────────────────────
                    ExpandableRow {
                        rowIcon: Qt.resolvedUrl("../../assets/icons/rider.png")
                        rowLabel: "Ride History"
                        rowSub: "142 past trips"
                        expanded: rideHistoryExpanded
                        onRowClicked: {
                            var wasOpen = rideHistoryExpanded
                            collapseAll()
                            rideHistoryExpanded = !wasOpen
                        }

                        expandedContent: Column {
                            width: parent.width; spacing: 0
                            topPadding: 4; bottomPadding: 8; leftPadding: 16; rightPadding: 16

                            ExpandDivider {}

                            Repeater {
                                model: rideHistoryData
                                delegate: Rectangle {
                                    width: parent.width - 32; height: 72; radius: 10
                                    color: "#FAFAFA"; border.color: "#EEEEEE"
                                    property var ride: modelData

                                    Row {
                                        anchors.fill: parent; anchors.margins: 12; spacing: 12

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 80

                                            Label {
                                                text: (ride ? ride.from : "") + "  →  " + (ride ? ride.to : "")
                                                font.pixelSize: 13; font.bold: true; color: "#111"
                                                elide: Text.ElideRight; width: parent.width
                                            }
                                            Label { text: ride ? ride.date : ""; font.pixelSize: 11; color: "#999" }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                            Label {
                                                text: ride ? ride.fare : ""
                                                font.pixelSize: 14; font.bold: true; color: "#111"
                                                anchors.right: parent.right
                                            }
                                            Rectangle {
                                                height: 16; radius: 8; width: statusLbl.implicitWidth + 10
                                                color: (ride && ride.status === "Completed") ? "#E8F5E9" : "#FFEBEE"
                                                Text {
                                                    id: statusLbl; anchors.centerIn: parent
                                                    text: ride ? ride.status : ""
                                                    font.pixelSize: 10; font.bold: true
                                                    color: (ride && ride.status === "Completed") ? "#388E3C" : "#C62828"
                                                }
                                            }
                                        }
                                    }

                                    // Spacer between cards
                                    Rectangle { visible: index < rideHistoryData.length - 1; height: 8; color: "transparent"; anchors.bottom: parent.bottom }
                                }
                            }

                            Item { height: 8 }

                            Rectangle {
                                width: parent.width - 32; height: 40; radius: 10
                                color: "#F5F5F5"; border.color: "#E0E0E0"
                                Text { anchors.centerIn: parent; text: "View All Trips"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                MouseArea { anchors.fill: parent; onClicked: console.log("View all trips") }
                            }
                        }
                    }

                    RowDivider {}

                    // ── Rewards & Coupons ─────────────────────────────
                    ExpandableRow {
                        rowIcon: Qt.resolvedUrl("../../assets/icons/star.png")
                        rowLabel: "Rewards & Coupons"
                        rowSub: rewardPoints + " pts · 3 Offers"
                        rowTag: "3 Offers"
                        expanded: rewardsExpanded
                        onRowClicked: {
                            var wasOpen = rewardsExpanded
                            collapseAll()
                            rewardsExpanded = !wasOpen
                        }

                        expandedContent: Column {
                            width: parent.width; spacing: 0
                            topPadding: 4; bottomPadding: 12; leftPadding: 16; rightPadding: 16

                            ExpandDivider {}

                            // Points card
                            Rectangle {
                                width: parent.width - 32; height: 70; radius: 12
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "#FF8F00" }
                                    GradientStop { position: 1.0; color: "#FFD54F" }
                                }
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 12
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                        Label { text: rewardPoints + " Points"; font.pixelSize: 22; font.bold: true; color: "white" }
                                        Label { text: "≈ ₹" + Math.floor(rewardPoints / 10) + " off on next ride"; font.pixelSize: 11; color: "#FFF8E1" }
                                    }
                                    Item { width: 1; Layout.fillWidth: true }
                                    Text { anchors.verticalCenter: parent.verticalCenter; text: "🏆"; font.pixelSize: 32 }
                                }
                            }

                            Item { height: 12 }
                            Label { text: "Available Coupons"; font.pixelSize: 12; font.bold: true; color: "#888"; x: 0 }
                            Item { height: 8 }

                            Repeater {
                                model: couponList
                                delegate: Rectangle {
                                    width: parent.width - 32; height: 62; radius: 10
                                    color: "white"; border.color: "#E0E0E0"
                                    property var cpn: modelData

                                    // Left dash border accent
                                    Rectangle { width: 4; height: parent.height; radius: 2; color: "#1976D2"; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter }

                                    Row {
                                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 12; spacing: 10
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter; spacing: 3; width: parent.width - 60
                                            Label { text: cpn ? cpn.code : ""; font.pixelSize: 14; font.bold: true; color: "#1976D2"; font.letterSpacing: 1 }
                                            Label { text: cpn ? cpn.desc : ""; font.pixelSize: 12; color: "#444" }
                                            Label { text: "Expires: " + (cpn ? cpn.expiry : ""); font.pixelSize: 10; color: "#AAA" }
                                        }
                                        Rectangle {
                                            width: 52; height: 28; radius: 8; color: "#1976D2"
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text { anchors.centerIn: parent; text: "Apply"; font.pixelSize: 12; font.bold: true; color: "white" }
                                            MouseArea { anchors.fill: parent; onClicked: console.log("Apply coupon:", cpn ? cpn.code : "") }
                                        }
                                    }
                                    Rectangle { height: 8; color: "transparent"; anchors.bottom: parent.bottom; width: parent.width }
                                }
                            }
                        }
                    }
                }

                // ════════════════════════════════════════════════════════
                // PREFERENCES SECTION
                // ════════════════════════════════════════════════════════
                SectionLabel { sectionTitle: "PREFERENCES" }

                SectionCard {
                    // ── Notifications ──────────────────────────────────
                    ExpandableRow {
                        rowIcon: Qt.resolvedUrl("../../assets/icons/destination.png")
                        rowLabel: "Notifications"
                        rowSub: "Ride alerts, offers"
                        expanded: notifExpanded
                        onRowClicked: {
                            var wasOpen = notifExpanded
                            collapseAll()
                            notifExpanded = !wasOpen
                        }

                        expandedContent: Column {
                            width: parent.width; spacing: 0
                            topPadding: 4; bottomPadding: 8; leftPadding: 16; rightPadding: 16

                            ExpandDivider {}

                            Repeater {
                                model: [
                                    { label: "Ride Alerts",     sub: "Updates on your trips",        ref: "ride" },
                                    { label: "Offers & Promos", sub: "Deals and discount codes",     ref: "offers" },
                                    { label: "SMS Alerts",      sub: "Text message notifications",   ref: "sms" },
                                    { label: "Email Updates",   sub: "Weekly digest & receipts",     ref: "email" }
                                ]
                                delegate: Rectangle {
                                    width: parent.width - 32; height: 54
                                    color: "transparent"
                                    property var ni: modelData

                                    Row {
                                        anchors.fill: parent; spacing: 0
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - 52; spacing: 2
                                            Label { text: ni ? ni.label : ""; font.pixelSize: 14; color: "#111" }
                                            Label { text: ni ? ni.sub : ""; font.pixelSize: 11; color: "#AAA" }
                                        }
                                        // Toggle
                                        Rectangle {
                                            width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                            color: {
                                                if (!ni) return "#CCC"
                                                if (ni.ref === "ride")   return notifRideAlerts ? "#1976D2" : "#CCC"
                                                if (ni.ref === "offers") return notifOffers ? "#1976D2" : "#CCC"
                                                if (ni.ref === "sms")    return notifSMS ? "#1976D2" : "#CCC"
                                                if (ni.ref === "email")  return notifEmail ? "#1976D2" : "#CCC"
                                                return "#CCC"
                                            }
                                            Behavior on color { ColorAnimation { duration: 150 } }
                                            Rectangle {
                                                width: 20; height: 20; radius: 10; color: "white"
                                                anchors.verticalCenter: parent.verticalCenter
                                                x: {
                                                    if (!ni) return 2
                                                    if (ni.ref === "ride")   return notifRideAlerts ? 18 : 2
                                                    if (ni.ref === "offers") return notifOffers ? 18 : 2
                                                    if (ni.ref === "sms")    return notifSMS ? 18 : 2
                                                    if (ni.ref === "email")  return notifEmail ? 18 : 2
                                                    return 2
                                                }
                                                Behavior on x { NumberAnimation { duration: 150 } }
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (!ni) return
                                                    if (ni.ref === "ride")   notifRideAlerts = !notifRideAlerts
                                                    if (ni.ref === "offers") notifOffers = !notifOffers
                                                    if (ni.ref === "sms")    notifSMS = !notifSMS
                                                    if (ni.ref === "email")  notifEmail = !notifEmail
                                                }
                                            }
                                        }
                                    }

                                    Rectangle { visible: index < 3; height: 1; color: "#F5F5F5"; anchors.bottom: parent.bottom; width: parent.width }
                                }
                            }
                        }
                    }

                    RowDivider {}

                    // ── Language ──────────────────────────────────────
                    ExpandableRow {
                        rowIcon: Qt.resolvedUrl("../../assets/icons/map.png")
                        rowLabel: "Language"
                        rowSub: languages[selectedLang]
                        expanded: langExpanded
                        onRowClicked: {
                            var wasOpen = langExpanded
                            collapseAll()
                            langExpanded = !wasOpen
                        }

                        expandedContent: Column {
                            width: parent.width; spacing: 0
                            topPadding: 4; bottomPadding: 8; leftPadding: 16; rightPadding: 16

                            ExpandDivider {}

                            Repeater {
                                model: languages
                                delegate: Rectangle {
                                    width: parent.width - 32; height: 48
                                    color: selectedLang === index ? "#EEF4FF" : "transparent"
                                    radius: 8

                                    Row {
                                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                        Label {
                                            text: modelData; font.pixelSize: 14
                                            font.bold: selectedLang === index
                                            color: selectedLang === index ? "#1976D2" : "#333"
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - 32
                                        }
                                        Text {
                                            visible: selectedLang === index
                                            text: "✓"; font.pixelSize: 16; font.bold: true; color: "#1976D2"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: { selectedLang = index; langExpanded = false } }
                                }
                            }
                        }
                    }

                    RowDivider {}

                    // ── Dark Mode (toggle inline) ──────────────────────
                    Rectangle {
                        width: parent.width; height: 60; color: "transparent"
                        Row {
                            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                            Rectangle {
                                width: 36; height: 36; radius: 18; color: "#F5F5F5"
                                anchors.verticalCenter: parent.verticalCenter
                                Image { source: Qt.resolvedUrl("../../assets/icons/star.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                width: parent.width - 36 - 14 - 50
                                Label { text: "Dark Mode"; font.pixelSize: 14; color: "#111" }
                                Label { text: darkModeEnabled ? "On" : "Off"; font.pixelSize: 11; color: "#AAA" }
                            }
                            Rectangle {
                                width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                color: darkModeEnabled ? "#1976D2" : "#CCCCCC"
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Rectangle {
                                    width: 20; height: 20; radius: 10; color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: darkModeEnabled ? 18 : 2
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                                MouseArea { anchors.fill: parent; onClicked: darkModeEnabled = !darkModeEnabled }
                            }
                        }
                    }
                }

                // ════════════════════════════════════════════════════════
                // SUPPORT SECTION
                // ════════════════════════════════════════════════════════
                SectionLabel { sectionTitle: "SUPPORT" }

                SectionCard {
                    // ── Help & Support ────────────────────────────────
                    ExpandableRow {
                        rowIcon: Qt.resolvedUrl("../../assets/icons/rider.png")
                        rowLabel: "Help & Support"
                        rowSub: "FAQs, report issue, live chat"
                        rowTag: "Live"
                        expanded: helpExpanded
                        onRowClicked: {
                            var wasOpen = helpExpanded
                            collapseAll()
                            helpExpanded = !wasOpen
                        }

                        expandedContent: Column {
                            width: parent.width; spacing: 8
                            topPadding: 4; bottomPadding: 12; leftPadding: 16; rightPadding: 16

                            ExpandDivider {}

                            Repeater {
                                model: [
                                    { icon: "❓", label: "FAQs",                sub: "Common questions answered" },
                                    { icon: "🚗", label: "Issue with a Ride",    sub: "Report problems with trips" },
                                    { icon: "💬", label: "Live Chat",            sub: "Chat with support now" },
                                    { icon: "📞", label: "Call Support",         sub: "1800-XXX-XXXX (toll free)" },
                                    { icon: "📝", label: "Give Feedback",        sub: "Help us improve" }
                                ]
                                delegate: Rectangle {
                                    width: parent.width - 32; height: 52; radius: 10
                                    color: helpItemMouse.containsMouse ? "#F5F5F5" : "#FAFAFA"
                                    border.color: "#EEEEEE"
                                    property var hi: modelData

                                    Row {
                                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                        Text { text: hi ? hi.icon : ""; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter }
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 60
                                            Label { text: hi ? hi.label : ""; font.pixelSize: 13; font.bold: true; color: "#111" }
                                            Label { text: hi ? hi.sub : "";   font.pixelSize: 11; color: "#888" }
                                        }
                                        Text { text: "›"; font.pixelSize: 20; color: "#CCC"; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                    MouseArea { id: helpItemMouse; anchors.fill: parent; hoverEnabled: true; onClicked: console.log("Help:", hi ? hi.label : "") }
                                }
                            }
                        }
                    }

                    RowDivider {}

                    // ── Safety Features ───────────────────────────────
                    ExpandableRow {
                        rowIcon: Qt.resolvedUrl("../../assets/icons/sos.png")
                        rowLabel: "Safety Features"
                        rowSub: "Share trip, SOS, panic button"
                        expanded: safetyExpanded
                        onRowClicked: {
                            var wasOpen = safetyExpanded
                            collapseAll()
                            safetyExpanded = !wasOpen
                        }

                        expandedContent: Column {
                            width: parent.width; spacing: 8
                            topPadding: 4; bottomPadding: 16; leftPadding: 16; rightPadding: 16

                            ExpandDivider {}

                            // Share trip live
                            Rectangle {
                                width: parent.width - 32; height: 56; radius: 12; color: "#F3E5F5"; border.color: "#CE93D8"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                    Text { text: "📍"; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 70
                                        Label { text: "Share Live Trip"; font.pixelSize: 13; font.bold: true; color: "#6A1B9A" }
                                        Label { text: "Let trusted contacts track your ride"; font.pixelSize: 11; color: "#9C27B0" }
                                    }
                                    Rectangle {
                                        width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                        color: safetyShareTrip ? "#7B1FA2" : "#CCCCCC"
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Rectangle {
                                            width: 20; height: 20; radius: 10; color: "white"; anchors.verticalCenter: parent.verticalCenter
                                            x: safetyShareTrip ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: safetyShareTrip = !safetyShareTrip }
                                    }
                                }
                            }

                            // SOS Button
                            Rectangle {
                                width: parent.width - 32; height: 56; radius: 12; color: "#FFEBEE"; border.color: "#EF9A9A"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                    Text { text: "🆘"; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 70
                                        Label { text: "SOS Emergency Button"; font.pixelSize: 13; font.bold: true; color: "#C62828" }
                                        Label { text: "Instantly alert emergency contacts"; font.pixelSize: 11; color: "#E53935" }
                                    }
                                    Rectangle {
                                        width: 50; height: 30; radius: 15; anchors.verticalCenter: parent.verticalCenter; color: "#C62828"
                                        Text { anchors.centerIn: parent; text: "Test"; font.pixelSize: 11; font.bold: true; color: "white" }
                                        MouseArea { anchors.fill: parent; onClicked: console.log("SOS Test triggered") }
                                    }
                                }
                            }

                            // Incognito mode
                            Rectangle {
                                width: parent.width - 32; height: 56; radius: 12; color: "#E8EAF6"; border.color: "#9FA8DA"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                                    Text { text: "🕶️"; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 70
                                        Label { text: "Incognito Mode"; font.pixelSize: 13; font.bold: true; color: "#283593" }
                                        Label { text: "Hide your ride from history"; font.pixelSize: 11; color: "#3949AB" }
                                    }
                                    Rectangle {
                                        width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                        color: safetyIncognito ? "#283593" : "#CCCCCC"
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Rectangle {
                                            width: 20; height: 20; radius: 10; color: "white"; anchors.verticalCenter: parent.verticalCenter
                                            x: safetyIncognito ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: safetyIncognito = !safetyIncognito }
                                    }
                                }
                            }
                        }
                    }

                    RowDivider {}

                    // ── Rate the App ──────────────────────────────────
                    Rectangle {
                        width: parent.width; height: 60; color: "transparent"
                        property bool hovered: rateAppMouse.containsMouse
                        color: hovered ? "#F8F8F8" : "transparent"
                        Row {
                            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                            Rectangle { width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                Image { source: Qt.resolvedUrl("../../assets/icons/star.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                Label { text: "Rate the App"; font.pixelSize: 14; color: "#111" }
                                Label { text: "Tell us what you think"; font.pixelSize: 11; color: "#AAA" }
                            }
                            Text { text: "›"; font.pixelSize: 22; color: "#CCC"; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { id: rateAppMouse; anchors.fill: parent; hoverEnabled: true; onClicked: console.log("Rate app") }

                        // Stars row pops up inline
                    }

                    RowDivider {}

                    // ── Privacy Policy ────────────────────────────────
                    Rectangle {
                        width: parent.width; height: 60; color: "transparent"
                        Row {
                            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                            Rectangle { width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                Image { source: Qt.resolvedUrl("../../assets/icons/map.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                Label { text: "Privacy Policy"; font.pixelSize: 14; color: "#111" }
                                Label { text: "Data usage & your rights"; font.pixelSize: 11; color: "#AAA" }
                            }
                            Text { text: "›"; font.pixelSize: 22; color: "#CCC"; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { anchors.fill: parent; onClicked: console.log("Privacy policy") }
                    }

                    RowDivider {}

                    // ── About ─────────────────────────────────────────
                    Rectangle {
                        width: parent.width; height: 60; color: "transparent"
                        Row {
                            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                            Rectangle { width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                Image { source: Qt.resolvedUrl("../../assets/icons/destination.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                Label { text: "About YatraSarthi"; font.pixelSize: 14; color: "#111" }
                                Label { text: "Version 3.2.1"; font.pixelSize: 11; color: "#AAA" }
                            }
                            Text { text: "›"; font.pixelSize: 22; color: "#CCC"; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { anchors.fill: parent; onClicked: console.log("About") }
                    }
                }

                // ── Log Out button ──────────────────────────────────
                Button {
                    x: 16; width: parent.width - 32; height: 52
                    background: Rectangle { color: "#FFEBEE"; radius: 14; border.color: "#FFCDD2" }
                    contentItem: Text {
                        text: "Log Out"; font.pixelSize: 15; font.bold: true; color: "#C62828"
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: console.log("Logout tapped")
                }

                Item { width: 1; height: 24 }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // INLINE COMPONENT DEFINITIONS
    // ══════════════════════════════════════════════════════════════════════

    component SectionLabel: Item {
        property string sectionTitle: ""
        x: 16; width: parent.width - 32; height: 28
        Label {
            text: sectionTitle; font.pixelSize: 11; font.bold: true
            color: "#AAAAAA"; leftPadding: 4; anchors.bottom: parent.bottom; anchors.bottomMargin: 4
        }
    }

    component SectionCard: Rectangle {
        default property alias content: innerCol.children
        x: 16; width: parent.width - 32
        radius: 14; color: "white"; border.color: "#EEEEEE"; clip: true
        height: innerCol.height
        Column { id: innerCol; width: parent.width; spacing: 0 }
    }

    component RowDivider: Rectangle {
        x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0"
    }

    component ExpandDivider: Rectangle {
        width: parent.width - 32; height: 1; color: "#F0F0F0"; x: 0
    }

    component ActionButton: Rectangle {
        property string btnText: "Save"
        signal btnClicked()
        width: parent.width - 32; height: 44; radius: 10
        color: "#1976D2"
        Text { anchors.centerIn: parent; text: btnText; font.pixelSize: 14; font.bold: true; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        MouseArea { anchors.fill: parent; onClicked: parent.btnClicked() }
    }

    component SaveMessage: Label {
        property string msg: ""
        visible: msg !== ""; text: msg; wrapMode: Text.WordWrap
        color: msg === "Saved successfully" || msg === "Profile updated successfully" ? "#388E3C" : "#E53935"
        font.pixelSize: 12; width: parent.width - 32
    }

    component ExpandableRow: Column {
        property string rowIcon: ""
        property string rowLabel: ""
        property string rowSub: ""
        property string rowTag: ""
        property bool expanded: false
        property alias expandedContent: expandPanel.children
        signal rowClicked()

        width: parent.width

        // ── Main clickable row ──────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 60; color: eRowMouse.containsMouse ? "#F8F8F8" : "transparent"

            Row {
                anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14

                Rectangle {
                    width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                    Image { source: rowIcon; width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 2
                    width: parent.width - 36 - 14 - 60 - 32
                    Label { text: rowLabel; font.pixelSize: 14; color: "#111" }
                    Label { text: rowSub; font.pixelSize: 11; color: "#AAA"; visible: rowSub !== ""; elide: Text.ElideRight; width: parent.width }
                }

                Item {
                    width: 60; height: parent.height; anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        visible: rowTag !== ""
                        height: 18; radius: 9; color: rowTag === "Live" ? "#E8F5E9" : "#FFF3E0"
                        width: tagLbl.implicitWidth + 12
                        anchors.right: chevron.left; anchors.rightMargin: 4; anchors.verticalCenter: parent.verticalCenter
                        Text { id: tagLbl; anchors.centerIn: parent; text: rowTag; font.pixelSize: 10; font.bold: true; color: rowTag === "Live" ? "#388E3C" : "#E65100" }
                    }
                    Text {
                        id: chevron; text: "›"; font.pixelSize: 22; color: "#CCCCCC"
                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        rotation: expanded ? 90 : 0
                        Behavior on rotation { NumberAnimation { duration: 150 } }
                    }
                }
            }
            MouseArea { id: eRowMouse; anchors.fill: parent; hoverEnabled: true; onClicked: parent.parent.rowClicked() }
        }

        // ── Expanded panel ──────────────────────────────────────────────
        Column {
            id: expandPanel
            width: parent.width; visible: expanded; spacing: 8
        }
    }
}
