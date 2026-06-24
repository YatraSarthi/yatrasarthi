import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    signal switchTab(int tabIndex)

    footer: null
    header: null

    onVisibleChanged: {
        if (visible && appState) {
            appState.showBottomBar = true
            darkModeEnabled = appState.darkMode
        }
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
    property int selectedPaymentTab: 0

    // ── RIDE HISTORY STATE ───────────────────────────────────────────────
    property bool rideHistoryExpanded: false
    property var rideHistoryData: [
        { date: "22 Jun 2026", from: "Koramangala", to: "Indiranagar", fare: "148", status: "Completed" },
        { date: "20 Jun 2026", from: "MG Road",     to: "Whitefield",  fare: "320", status: "Completed" },
        { date: "18 Jun 2026", from: "HSR Layout",  to: "Jayanagar",   fare: "95",  status: "Cancelled" }
    ]

    // ── REWARDS STATE ────────────────────────────────────────────────────
    property bool rewardsExpanded: false
    property int rewardPoints: 1240
    property var couponList: [
        { code: "RIDE20",  desc: "20% off next ride",     expiry: "30 Jun 2026" },
        { code: "FLAT50",  desc: "Rs.50 off on Rs.200+",  expiry: "15 Jul 2026" },
        { code: "GOLD10",  desc: "Gold member bonus 10%", expiry: "31 Jul 2026" }
    ]

    // ── NOTIFICATIONS STATE ──────────────────────────────────────────────
    property bool notifExpanded: false
    property bool notifRideAlerts: true
    property bool notifOffers: true
    property bool notifSMS: false
    property bool notifEmail: true

    // ── SAFETY STATE ─────────────────────────────────────────────────────
    property bool safetyExpanded: false
    property bool safetyShareTrip: false
    property bool safetyIncognito: false

    // ── HELP STATE ───────────────────────────────────────────────────────
    property bool helpExpanded: false

    // ── LANGUAGE STATE ───────────────────────────────────────────────────
    property bool langExpanded: false
    property int selectedLang: 0
    property var languages: ["English", "Hindi", "Kannada", "Tamil", "Telugu"]

    // ── DARK MODE — mirrors appState.darkMode ────────────────────────────
    property bool darkModeEnabled: appState ? appState.darkMode : false

    // ── GENDER ───────────────────────────────────────────────────────────
    property int selectedGender: 0

    Component.onCompleted: { loadEmergencyInfo() }

    onEmergencyExpandedChanged:   { if (emergencyExpanded)   emergencySyncTick++ }
    onEmergencyEditModeChanged:   { if (!emergencyEditMode)  emergencySyncTick++ }
    onProfileEditExpandedChanged: { if (profileEditExpanded) profileSyncTick++   }

    function collapseAll() {
        profileEditExpanded  = false; profileEditMode   = false
        paymentExpanded      = false
        emergencyExpanded    = false; emergencyEditMode = false
        rideHistoryExpanded  = false
        rewardsExpanded      = false
        notifExpanded        = false
        helpExpanded         = false
        safetyExpanded       = false
        langExpanded         = false
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
                if (xhr.status === 200) {
                    emergencySaveMessage = "Saved successfully"
                    emergencyEditMode = false
                } else {
                    emergencySaveMessage = "Failed to save"
                }
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

    // ── UI ROOT ──────────────────────────────────────────────────────────
    ScrollView {
        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {
            width: parent.width
            spacing: 0

            // ── TOP HEADER BAR ──────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 56; color: "#1976D2"

                Rectangle {
                    id: backBtn
                    width: 36; height: 36; radius: 18; color: "white"
                    anchors.left: parent.left; anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: "‹"; font.pixelSize: 28; font.bold: true; color: "#1565C0"; anchors.centerIn: parent; anchors.horizontalCenterOffset: -1 }
                    MouseArea { anchors.fill: parent; onClicked: switchTab(0) }
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: backBtn.right; anchors.leftMargin: 10
                    text: "Account"; font.pixelSize: 20; font.bold: true; color: "white"
                }
            }

            // ── PROFILE HEADER ──────────────────────────────────────────
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
                                onClicked: { collapseAll(); profileEditExpanded = true; profileEditMode = true; profileSaveMessage = "" }
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
                            model: ["4.8 Rating", "142 Rides", "Gold Member"]
                            delegate: Rectangle {
                                height: 20; radius: 10; color: "#ffffff25"; border.color: "#ffffff40"
                                width: bdgTxt.implicitWidth + 16
                                Text { id: bdgTxt; anchors.centerIn: parent; text: modelData; font.pixelSize: 10; color: "white" }
                            }
                        }
                    }
                }
            }

            // ── MAIN CONTENT COLUMN ─────────────────────────────────────
            Column {
                width: parent.width; spacing: 14

                Item { width: 1; height: 14 }

                // ════════════════════════════════════════════════════════
                // SECTION LABEL: PROFILE
                // ════════════════════════════════════════════════════════
                Item {
                    x: 16; width: parent.width - 32; height: 24
                    Label { text: "PROFILE"; font.pixelSize: 11; font.bold: true; color: "#AAAAAA"; leftPadding: 4; anchors.bottom: parent.bottom }
                }

                // ── PROFILE SECTION CARD ──────────────────────────────
                Rectangle {
                    x: 16; width: parent.width - 32
                    radius: 14; color: "white"; border.color: "#EEEEEE"; clip: true
                    height: profileSectionCol.implicitHeight

                    Column {
                        id: profileSectionCol
                        width: parent.width; spacing: 0

                        // ── Edit Profile row ──────────────────────────
                        Column {
                            width: parent.width

                            Rectangle {
                                width: parent.width; height: 60
                                color: editProfMouse.containsMouse ? "#F8F8F8" : "transparent"

                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/driver.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                        width: parent.width - 36 - 14 - 30
                                        Label { text: "Edit Profile"; font.pixelSize: 14; color: "#111" }
                                        Label { text: profileName + " · " + profileEmail; font.pixelSize: 11; color: "#AAA"; elide: Text.ElideRight; width: parent.width }
                                    }
                                    Text {
                                        text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter
                                        rotation: profileEditExpanded ? 90 : 0
                                        Behavior on rotation { NumberAnimation { duration: 150 } }
                                    }
                                }
                                MouseArea {
                                    id: editProfMouse; anchors.fill: parent; hoverEnabled: true
                                    onClicked: {
                                        var wasOpen = profileEditExpanded
                                        collapseAll()
                                        profileEditExpanded = !wasOpen
                                        if (profileEditExpanded) { profileSaveMessage = "" }
                                    }
                                }
                            }

                            // Edit Profile Expanded Panel
                            Column {
                                width: parent.width; visible: profileEditExpanded
                                spacing: 10; topPadding: 4; bottomPadding: 16; leftPadding: 16; rightPadding: 16

                                Rectangle { width: parent.width - 32; height: 1; color: "#F0F0F0" }

                                Row {
                                    width: parent.width - 32
                                    Label { text: "Personal Details"; font.pixelSize: 12; font.bold: true; color: "#888"; width: parent.width - editProfBtn.width; anchors.verticalCenter: parent.verticalCenter }
                                    Button {
                                        id: editProfBtn
                                        text: profileEditMode ? "Cancel" : "Edit"; flat: true
                                        contentItem: Text { text: editProfBtn.text; color: "#1976D2"; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: {
                                            if (profileEditMode) { profileSyncTick++; profileSaveMessage = "" }
                                            profileEditMode = !profileEditMode
                                        }
                                    }
                                }

                                // Sync helper
                                Item {
                                    property int tick: profileSyncTick
                                    onTickChanged: { pNameField.text = profileName; pEmailField.text = profileEmail; pPhoneField.text = profilePhone }
                                    Component.onCompleted: { pNameField.text = profileName; pEmailField.text = profileEmail; pPhoneField.text = profilePhone }
                                }

                                Column { width: parent.width - 32; spacing: 4
                                    Label { text: "Full Name"; font.pixelSize: 11; color: "#999" }
                                    TextField {
                                        id: pNameField; width: parent.width; placeholderText: "Your name"; readOnly: !profileEditMode
                                        background: Rectangle { color: profileEditMode ? "white" : "#F8F9FA"; radius: 8; border.color: profileEditMode ? "#1976D2" : "#EEEEEE"; border.width: profileEditMode ? 1.5 : 1 }
                                        leftPadding: 12; font.pixelSize: 13
                                    }
                                }
                                Column { width: parent.width - 32; spacing: 4
                                    Label { text: "Email"; font.pixelSize: 11; color: "#999" }
                                    TextField {
                                        id: pEmailField; width: parent.width; placeholderText: "your@email.com"; readOnly: !profileEditMode
                                        background: Rectangle { color: profileEditMode ? "white" : "#F8F9FA"; radius: 8; border.color: profileEditMode ? "#1976D2" : "#EEEEEE"; border.width: profileEditMode ? 1.5 : 1 }
                                        leftPadding: 12; font.pixelSize: 13
                                    }
                                }
                                Column { width: parent.width - 32; spacing: 4
                                    Label { text: "Phone Number"; font.pixelSize: 11; color: "#999" }
                                    TextField {
                                        id: pPhoneField; width: parent.width; placeholderText: "+91 XXXXX XXXXX"; readOnly: !profileEditMode
                                        inputMethodHints: Qt.ImhDialableCharactersOnly
                                        background: Rectangle { color: profileEditMode ? "white" : "#F8F9FA"; radius: 8; border.color: profileEditMode ? "#1976D2" : "#EEEEEE"; border.width: profileEditMode ? 1.5 : 1 }
                                        leftPadding: 12; font.pixelSize: 13
                                    }
                                }

                                Column { width: parent.width - 32; spacing: 4
                                    Label { text: "Gender"; font.pixelSize: 11; color: "#999" }
                                    Row {
                                        spacing: 8
                                        Repeater {
                                            model: ["Male", "Female", "Other"]
                                            delegate: Rectangle {
                                                width: gTxt.implicitWidth + 20; height: 30; radius: 15
                                                color: selectedGender === index ? "#1976D2" : "#F0F4FF"
                                                border.color: selectedGender === index ? "#1565C0" : "#D0D8FF"
                                                opacity: profileEditMode ? 1.0 : 0.65
                                                Text { id: gTxt; anchors.centerIn: parent; text: modelData; font.pixelSize: 12; color: selectedGender === index ? "white" : "#555" }
                                                MouseArea { anchors.fill: parent; enabled: profileEditMode; onClicked: selectedGender = index }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: profileEditMode
                                    width: parent.width - 32; height: 44; radius: 10; color: "#1976D2"
                                    Text { anchors.centerIn: parent; text: "Save Profile"; font.pixelSize: 14; font.bold: true; color: "white" }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            profileName  = pNameField.text
                                            profileEmail = pEmailField.text
                                            profilePhone = pPhoneField.text
                                            profileEditMode = false
                                            profileSaveMessage = "Profile updated successfully"
                                            profileSyncTick++
                                        }
                                    }
                                }

                                Label {
                                    visible: profileSaveMessage !== ""; text: profileSaveMessage
                                    color: profileSaveMessage === "Profile updated successfully" ? "#388E3C" : "#E53935"
                                    font.pixelSize: 12; wrapMode: Text.WordWrap; width: parent.width - 32
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0" }

                        // ── Payment Methods row ───────────────────────
                        Column {
                            width: parent.width

                            Rectangle {
                                width: parent.width; height: 60
                                color: payMouse.containsMouse ? "#F8F8F8" : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/star.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Payment Methods"; font.pixelSize: 14; color: "#111" }
                                        Label { text: "UPI, cards, wallets"; font.pixelSize: 11; color: "#AAA" }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter; rotation: paymentExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea {
                                    id: payMouse; anchors.fill: parent; hoverEnabled: true
                                    onClicked: { var w = paymentExpanded; collapseAll(); paymentExpanded = !w }
                                }
                            }

                            // Payment Expanded
                            Column {
                                visible: paymentExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 12

                                Rectangle { x: 16; width: parent.width - 32; height: 1; color: "#F0F0F0" }
                                Item { height: 8 }

                                // Tabs
                                Row {
                                    x: 16; width: parent.width - 32; height: 36; spacing: 0
                                    Repeater {
                                        model: ["UPI", "Cards", "Wallet"]
                                        delegate: Rectangle {
                                            width: (parent.width) / 3; height: 36
                                            color: selectedPaymentTab === index ? "#E3F2FD" : "transparent"
                                            radius: selectedPaymentTab === index ? 8 : 0
                                            Text {
                                                anchors.centerIn: parent; text: modelData; font.pixelSize: 13
                                                font.bold: selectedPaymentTab === index
                                                color: selectedPaymentTab === index ? "#1976D2" : "#888"
                                            }
                                            MouseArea { anchors.fill: parent; onClicked: selectedPaymentTab = index }
                                        }
                                    }
                                }
                                Rectangle { x: 16; width: parent.width - 32; height: 1; color: "#EEE" }
                                Item { height: 8 }

                                // UPI Panel
                                Column {
                                    visible: selectedPaymentTab === 0
                                    x: 16; width: parent.width - 32; spacing: 8

                                    Repeater {
                                        model: ["johney@upi", "johney@okaxis"]
                                        delegate: Rectangle {
                                            width: parent.width; height: 52; radius: 10; color: "#F8F9FA"; border.color: "#EEEEEE"
                                            Row {
                                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10
                                                Rectangle {
                                                    width: 32; height: 32; radius: 8; color: "#E3F2FD"; anchors.verticalCenter: parent.verticalCenter
                                                    Text { anchors.centerIn: parent; text: "Rs"; font.pixelSize: 12; font.bold: true; color: "#1976D2" }
                                                }
                                                Column {
                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                                    Label { text: modelData; font.pixelSize: 13; color: "#111" }
                                                    Label { text: index === 0 ? "Default" : "Linked"; font.pixelSize: 11; color: index === 0 ? "#43A047" : "#888" }
                                                }
                                            }
                                        }
                                    }
                                    Rectangle {
                                        width: parent.width; height: 44; radius: 10; color: "#EEF4FF"; border.color: "#C5D8FF"
                                        Row { anchors.centerIn: parent; spacing: 8
                                            Text { text: "+"; font.pixelSize: 18; color: "#1976D2"; font.bold: true }
                                            Text { text: "Add UPI ID"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: console.log("Add UPI") }
                                    }
                                }

                                // Cards Panel
                                Column {
                                    visible: selectedPaymentTab === 1
                                    x: 16; width: parent.width - 32; spacing: 8

                                    Rectangle {
                                        width: parent.width; height: 80; radius: 12
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: "#1565C0" }
                                            GradientStop { position: 1.0; color: "#42A5F5" }
                                        }
                                        Column {
                                            anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                            Label { text: "**** **** **** 4521"; font.pixelSize: 14; color: "white" }
                                            Label { text: "JOHNEY  Expires 09/28"; font.pixelSize: 11; color: "#B3E5FC" }
                                        }
                                        Rectangle {
                                            width: 40; height: 22; radius: 4; color: "#FFD600"
                                            anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                                            Text { anchors.centerIn: parent; text: "VISA"; font.pixelSize: 10; font.bold: true; color: "#333" }
                                        }
                                    }
                                    Rectangle {
                                        width: parent.width; height: 44; radius: 10; color: "#EEF4FF"; border.color: "#C5D8FF"
                                        Row { anchors.centerIn: parent; spacing: 8
                                            Text { text: "+"; font.pixelSize: 18; color: "#1976D2"; font.bold: true }
                                            Text { text: "Add Card"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: console.log("Add Card") }
                                    }
                                }

                                // Wallet Panel
                                Column {
                                    visible: selectedPaymentTab === 2
                                    x: 16; width: parent.width - 32; spacing: 8

                                    Rectangle {
                                        width: parent.width; height: 64; radius: 12; color: "#F1F8E9"; border.color: "#C5E1A5"
                                        Row {
                                            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 12
                                            Rectangle {
                                                width: 36; height: 36; radius: 18; color: "#43A047"; anchors.verticalCenter: parent.verticalCenter
                                                Text { anchors.centerIn: parent; text: "Rs"; font.pixelSize: 13; font.bold: true; color: "white" }
                                            }
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                                Label { text: "YatraCash Balance"; font.pixelSize: 13; font.bold: true; color: "#2E7D32" }
                                                Label { text: "Rs.250 available"; font.pixelSize: 12; color: "#555" }
                                            }
                                        }
                                    }
                                    Rectangle {
                                        width: parent.width; height: 44; radius: 10; color: "#E8F5E9"; border.color: "#A5D6A7"
                                        Row { anchors.centerIn: parent; spacing: 8
                                            Text { text: "+"; font.pixelSize: 18; color: "#43A047"; font.bold: true }
                                            Text { text: "Add Money"; font.pixelSize: 13; color: "#43A047"; font.bold: true }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: console.log("Add Money") }
                                    }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0" }

                        // ── Emergency Contacts row ────────────────────
                        Column {
                            width: parent.width

                            Rectangle {
                                width: parent.width; height: 60
                                color: emgMouse.containsMouse ? "#F8F8F8" : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/sos.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Emergency Contacts"; font.pixelSize: 14; color: "#111" }
                                        Label { text: "SOS contacts & medical info"; font.pixelSize: 11; color: "#AAA" }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter; rotation: emergencyExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea {
                                    id: emgMouse; anchors.fill: parent; hoverEnabled: true
                                    onClicked: {
                                        var w = emergencyExpanded; collapseAll(); emergencyExpanded = !w
                                        if (emergencyExpanded) { emergencySaveMessage = ""; loadEmergencyInfo() }
                                    }
                                }
                            }

                            Column {
                                visible: emergencyExpanded; width: parent.width
                                spacing: 10; topPadding: 4; bottomPadding: 16; leftPadding: 16; rightPadding: 16

                                Rectangle { width: parent.width - 32; height: 1; color: "#F0F0F0" }

                                Row {
                                    width: parent.width - 32
                                    Label { text: "Saved Information"; font.pixelSize: 12; font.bold: true; color: "#888"; anchors.verticalCenter: parent.verticalCenter; width: parent.width - emgEditBtn.width }
                                    Button {
                                        id: emgEditBtn; text: emergencyEditMode ? "Cancel" : "Edit"; flat: true
                                        contentItem: Text { text: emgEditBtn.text; color: "#1976D2"; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: { if (emergencyEditMode) { loadEmergencyInfo(); emergencySaveMessage = "" }; emergencyEditMode = !emergencyEditMode }
                                    }
                                }

                                Item {
                                    property int tick: emergencySyncTick
                                    onTickChanged: { acc1N.text = contact1Name; acc1P.text = contact1Phone; acc2N.text = contact2Name; acc2P.text = contact2Phone; accBG.text = bloodGroup; accMN.text = medicalNotes }
                                    Component.onCompleted: { acc1N.text = contact1Name; acc1P.text = contact1Phone; acc2N.text = contact2Name; acc2P.text = contact2Phone; accBG.text = bloodGroup; accMN.text = medicalNotes }
                                }

                                Label { text: "Emergency Contact 1"; font.pixelSize: 12; color: "#888" }
                                TextField { id: acc1N; width: parent.width - 32; placeholderText: "Name"; readOnly: !emergencyEditMode; onTextChanged: contact1Name = text }
                                TextField { id: acc1P; width: parent.width - 32; placeholderText: "Phone number"; readOnly: !emergencyEditMode; inputMethodHints: Qt.ImhDialableCharactersOnly; onTextChanged: contact1Phone = text }

                                Label { text: "Emergency Contact 2"; font.pixelSize: 12; color: "#888" }
                                TextField { id: acc2N; width: parent.width - 32; placeholderText: "Name"; readOnly: !emergencyEditMode; onTextChanged: contact2Name = text }
                                TextField { id: acc2P; width: parent.width - 32; placeholderText: "Phone number"; readOnly: !emergencyEditMode; inputMethodHints: Qt.ImhDialableCharactersOnly; onTextChanged: contact2Phone = text }

                                Label { text: "Blood Group"; font.pixelSize: 12; color: "#888" }
                                TextField { id: accBG; width: parent.width - 32; placeholderText: "e.g. O+"; readOnly: !emergencyEditMode; onTextChanged: bloodGroup = text }

                                Label { text: "Medical Notes"; font.pixelSize: 12; color: "#888" }
                                TextArea {
                                    id: accMN; width: parent.width - 32; placeholderText: "Allergies, conditions, medications..."
                                    readOnly: !emergencyEditMode; wrapMode: TextArea.Wrap; onTextChanged: medicalNotes = text
                                }

                                Rectangle {
                                    visible: emergencyEditMode
                                    width: parent.width - 32; height: 44; radius: 10; color: "#1976D2"
                                    Text { anchors.centerIn: parent; text: "Save Emergency Info"; font.pixelSize: 14; font.bold: true; color: "white" }
                                    MouseArea { anchors.fill: parent; onClicked: saveEmergencyInfo() }
                                }
                                Label {
                                    visible: emergencySaveMessage !== ""; text: emergencySaveMessage
                                    font.pixelSize: 12; wrapMode: Text.WordWrap; width: parent.width - 32
                                    color: emergencySaveMessage === "Saved successfully" ? "#388E3C" : "#E53935"
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0" }

                        // ── Ride History row ──────────────────────────
                        Column {
                            width: parent.width

                            Rectangle {
                                width: parent.width; height: 60
                                color: rideMouse.containsMouse ? "#F8F8F8" : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/rider.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Ride History"; font.pixelSize: 14; color: "#111" }
                                        Label { text: "142 past trips & receipts"; font.pixelSize: 11; color: "#AAA" }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter; rotation: rideHistoryExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea {
                                    id: rideMouse; anchors.fill: parent; hoverEnabled: true
                                    onClicked: { var w = rideHistoryExpanded; collapseAll(); rideHistoryExpanded = !w }
                                }
                            }

                            Column {
                                visible: rideHistoryExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 12; leftPadding: 16; rightPadding: 16; spacing: 8

                                Rectangle { width: parent.width - 32; height: 1; color: "#F0F0F0" }

                                Repeater {
                                    model: rideHistoryData
                                    delegate: Rectangle {
                                        width: parent.width - 32; height: 68; radius: 10; color: "#FAFAFA"; border.color: "#EEEEEE"
                                        property var rd: modelData
                                        Row {
                                            anchors.fill: parent; anchors.margins: 12; spacing: 10
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter; spacing: 3; width: parent.width - 80
                                                Label { text: (rd ? rd.from : "") + "  →  " + (rd ? rd.to : ""); font.pixelSize: 13; font.bold: true; color: "#111"; elide: Text.ElideRight; width: parent.width }
                                                Label { text: rd ? rd.date : ""; font.pixelSize: 11; color: "#999" }
                                            }
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                                Label { text: rd ? "Rs." + rd.fare : ""; font.pixelSize: 14; font.bold: true; color: "#111" }
                                                Rectangle {
                                                    height: 16; radius: 8; width: stLbl.implicitWidth + 10
                                                    color: (rd && rd.status === "Completed") ? "#E8F5E9" : "#FFEBEE"
                                                    Text { id: stLbl; anchors.centerIn: parent; text: rd ? rd.status : ""; font.pixelSize: 10; font.bold: true; color: (rd && rd.status === "Completed") ? "#388E3C" : "#C62828" }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width - 32; height: 40; radius: 10; color: "#F5F5F5"; border.color: "#E0E0E0"
                                    Text { anchors.centerIn: parent; text: "View All Trips"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                    MouseArea { anchors.fill: parent; onClicked: console.log("View all trips") }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0" }

                        // ── Rewards & Coupons row ─────────────────────
                        Column {
                            width: parent.width

                            Rectangle {
                                width: parent.width; height: 60
                                color: rwdMouse.containsMouse ? "#F8F8F8" : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/star.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 80
                                        Label { text: "Rewards & Coupons"; font.pixelSize: 14; color: "#111" }
                                        Label { text: rewardPoints + " pts · 3 Offers"; font.pixelSize: 11; color: "#AAA" }
                                    }
                                    Rectangle {
                                        height: 18; radius: 9; color: "#FFF3E0"; width: rwdTag.implicitWidth + 12; anchors.verticalCenter: parent.verticalCenter
                                        Text { id: rwdTag; anchors.centerIn: parent; text: "3 Offers"; font.pixelSize: 10; font.bold: true; color: "#E65100" }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter; rotation: rewardsExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea {
                                    id: rwdMouse; anchors.fill: parent; hoverEnabled: true
                                    onClicked: { var w = rewardsExpanded; collapseAll(); rewardsExpanded = !w }
                                }
                            }

                            Column {
                                visible: rewardsExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 12; leftPadding: 16; rightPadding: 16; spacing: 10

                                Rectangle { width: parent.width - 32; height: 1; color: "#F0F0F0" }

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
                                            Label { text: "Rs." + Math.floor(rewardPoints / 10) + " off on next ride"; font.pixelSize: 11; color: "#FFF8E1" }
                                        }
                                    }
                                }

                                Label { text: "Available Coupons"; font.pixelSize: 12; font.bold: true; color: "#888" }

                                Repeater {
                                    model: couponList
                                    delegate: Rectangle {
                                        width: parent.width - 32; height: 62; radius: 10; color: "white"; border.color: "#E0E0E0"
                                        property var cpn: modelData
                                        Rectangle { width: 4; height: parent.height - 12; radius: 2; color: "#1976D2"; anchors.left: parent.left; anchors.leftMargin: 0; anchors.verticalCenter: parent.verticalCenter }
                                        Row {
                                            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 12; spacing: 8
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 70
                                                Label { text: cpn ? cpn.code : ""; font.pixelSize: 14; font.bold: true; color: "#1976D2" }
                                                Label { text: cpn ? cpn.desc : ""; font.pixelSize: 12; color: "#444" }
                                                Label { text: "Expires: " + (cpn ? cpn.expiry : ""); font.pixelSize: 10; color: "#AAA" }
                                            }
                                            Rectangle {
                                                width: 52; height: 28; radius: 8; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter
                                                Text { anchors.centerIn: parent; text: "Apply"; font.pixelSize: 12; font.bold: true; color: "white" }
                                                MouseArea { anchors.fill: parent; onClicked: console.log("Apply:", cpn ? cpn.code : "") }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ════════════════════════════════════════════════════════
                // SECTION LABEL: PREFERENCES
                // ════════════════════════════════════════════════════════
                Item {
                    x: 16; width: parent.width - 32; height: 24
                    Label { text: "PREFERENCES"; font.pixelSize: 11; font.bold: true; color: "#AAAAAA"; leftPadding: 4; anchors.bottom: parent.bottom }
                }

                Rectangle {
                    x: 16; width: parent.width - 32
                    radius: 14; color: "white"; border.color: "#EEEEEE"; clip: true
                    height: prefCol.implicitHeight

                    Column {
                        id: prefCol; width: parent.width; spacing: 0

                        // ── Notifications ─────────────────────────────
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: notifMouse.containsMouse ? "#F8F8F8" : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/destination.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Notifications"; font.pixelSize: 14; color: "#111" }
                                        Label { text: "Ride alerts, offers"; font.pixelSize: 11; color: "#AAA" }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter; rotation: notifExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: notifMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = notifExpanded; collapseAll(); notifExpanded = !w } }
                            }

                            Column {
                                visible: notifExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 8; leftPadding: 16; rightPadding: 16; spacing: 0

                                Rectangle { width: parent.width - 32; height: 1; color: "#F0F0F0" }

                                Repeater {
                                    model: [
                                        { lbl: "Ride Alerts",     sub: "Updates on your trips",      tog: 0 },
                                        { lbl: "Offers & Promos", sub: "Deals and discount codes",   tog: 1 },
                                        { lbl: "SMS Alerts",      sub: "Text message notifications", tog: 2 },
                                        { lbl: "Email Updates",   sub: "Weekly digest & receipts",   tog: 3 }
                                    ]
                                    delegate: Rectangle {
                                        width: parent.width - 32; height: 52; color: "transparent"
                                        property var ni: modelData
                                        property bool togVal: ni ? (ni.tog === 0 ? notifRideAlerts : ni.tog === 1 ? notifOffers : ni.tog === 2 ? notifSMS : notifEmail) : false

                                        Row {
                                            anchors.fill: parent; spacing: 0
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter; width: parent.width - 52; spacing: 2
                                                Label { text: ni ? ni.lbl : ""; font.pixelSize: 14; color: "#111" }
                                                Label { text: ni ? ni.sub : ""; font.pixelSize: 11; color: "#AAA" }
                                            }
                                            Rectangle {
                                                width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                                color: togVal ? "#1976D2" : "#CCCCCC"
                                                Behavior on color { ColorAnimation { duration: 150 } }
                                                Rectangle {
                                                    width: 20; height: 20; radius: 10; color: "white"; anchors.verticalCenter: parent.verticalCenter
                                                    x: togVal ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } }
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        if (!ni) return
                                                        if (ni.tog === 0)      notifRideAlerts = !notifRideAlerts
                                                        else if (ni.tog === 1) notifOffers     = !notifOffers
                                                        else if (ni.tog === 2) notifSMS        = !notifSMS
                                                        else                   notifEmail      = !notifEmail
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle { visible: index < 3; height: 1; color: "#F5F5F5"; anchors.bottom: parent.bottom; width: parent.width }
                                    }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0" }

                        // ── Safety ────────────────────────────────────
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: safetyMouse.containsMouse ? "#F8F8F8" : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/sos.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Safety Settings"; font.pixelSize: 14; color: "#111" }
                                        Label { text: "Trip sharing, incognito mode"; font.pixelSize: 11; color: "#AAA" }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter; rotation: safetyExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: safetyMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = safetyExpanded; collapseAll(); safetyExpanded = !w } }
                            }

                            Column {
                                visible: safetyExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 8; leftPadding: 16; rightPadding: 16; spacing: 0

                                Rectangle { width: parent.width - 32; height: 1; color: "#F0F0F0" }

                                // Share Trip toggle
                                Rectangle {
                                    width: parent.width - 32; height: 52; color: "transparent"
                                    Row {
                                        anchors.fill: parent; spacing: 0
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter; width: parent.width - 52; spacing: 2
                                            Label { text: "Share Trip"; font.pixelSize: 14; color: "#111" }
                                            Label { text: "Auto-share live location with contacts"; font.pixelSize: 11; color: "#AAA" }
                                        }
                                        Rectangle {
                                            width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                            color: safetyShareTrip ? "#1976D2" : "#CCCCCC"
                                            Behavior on color { ColorAnimation { duration: 150 } }
                                            Rectangle {
                                                width: 20; height: 20; radius: 10; color: "white"; anchors.verticalCenter: parent.verticalCenter
                                                x: safetyShareTrip ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } }
                                            }
                                            MouseArea { anchors.fill: parent; onClicked: safetyShareTrip = !safetyShareTrip }
                                        }
                                    }
                                    Rectangle { height: 1; color: "#F5F5F5"; anchors.bottom: parent.bottom; width: parent.width }
                                }

                                // Incognito toggle
                                Rectangle {
                                    width: parent.width - 32; height: 52; color: "transparent"
                                    Row {
                                        anchors.fill: parent; spacing: 0
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter; width: parent.width - 52; spacing: 2
                                            Label { text: "Incognito Mode"; font.pixelSize: 14; color: "#111" }
                                            Label { text: "Hide your profile from drivers"; font.pixelSize: 11; color: "#AAA" }
                                        }
                                        Rectangle {
                                            width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                            color: safetyIncognito ? "#1976D2" : "#CCCCCC"
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

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0" }

                        // ── Language ──────────────────────────────────
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: langMouse.containsMouse ? "#F8F8F8" : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/map.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Language"; font.pixelSize: 14; color: "#111" }
                                        Label { text: languages[selectedLang]; font.pixelSize: 11; color: "#AAA" }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter; rotation: langExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: langMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = langExpanded; collapseAll(); langExpanded = !w } }
                            }

                            Column {
                                visible: langExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 8; leftPadding: 16; rightPadding: 16; spacing: 0

                                Rectangle { width: parent.width - 32; height: 1; color: "#F0F0F0" }

                                Repeater {
                                    model: languages
                                    delegate: Rectangle {
                                        width: parent.width - 32; height: 46; radius: 8
                                        color: selectedLang === index ? "#EEF4FF" : "transparent"
                                        Row {
                                            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                            Label {
                                                text: modelData; font.pixelSize: 14; font.bold: selectedLang === index
                                                color: selectedLang === index ? "#1976D2" : "#333"; anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width - 30
                                            }
                                            Text { visible: selectedLang === index; text: "✓"; font.pixelSize: 16; font.bold: true; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: { selectedLang = index; langExpanded = false } }
                                    }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0" }

                        // ── Dark Mode (inline toggle) ──────────────────
                        Rectangle {
                            width: parent.width; height: 60; color: "transparent"
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                Rectangle {
                                    width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                    Image { source: Qt.resolvedUrl("../../assets/icons/star.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 50
                                    Label { text: "Dark Mode"; font.pixelSize: 14; color: "#111" }
                                    Label { text: darkModeEnabled ? "On" : "Off"; font.pixelSize: 11; color: "#AAA" }
                                }
                                Rectangle {
                                    width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                    color: darkModeEnabled ? "#1976D2" : "#CCCCCC"
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Rectangle {
                                        width: 20; height: 20; radius: 10; color: "white"; anchors.verticalCenter: parent.verticalCenter
                                        x: darkModeEnabled ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (appState) appState.darkMode = !appState.darkMode
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ════════════════════════════════════════════════════════
                // SECTION LABEL: SUPPORT
                // ════════════════════════════════════════════════════════
                Item {
                    x: 16; width: parent.width - 32; height: 24
                    Label { text: "SUPPORT"; font.pixelSize: 11; font.bold: true; color: "#AAAAAA"; leftPadding: 4; anchors.bottom: parent.bottom }
                }

                Rectangle {
                    x: 16; width: parent.width - 32
                    radius: 14; color: "white"; border.color: "#EEEEEE"; clip: true
                    height: suppCol.implicitHeight

                    Column {
                        id: suppCol; width: parent.width; spacing: 0

                        // ── Help & Support ────────────────────────────
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: helpMouse.containsMouse ? "#F8F8F8" : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: "?"; font.pixelSize: 18; font.bold: true; color: "#1976D2" }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Help & Support"; font.pixelSize: 14; color: "#111" }
                                        Label { text: "FAQs, chat with support"; font.pixelSize: 11; color: "#AAA" }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter; rotation: helpExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: helpMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = helpExpanded; collapseAll(); helpExpanded = !w } }
                            }

                            Column {
                                visible: helpExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 12; leftPadding: 16; rightPadding: 16; spacing: 8

                                Rectangle { width: parent.width - 32; height: 1; color: "#F0F0F0" }

                                Repeater {
                                    model: [
                                        { title: "Report an Issue",      icon: "!" },
                                        { title: "Lost & Found",         icon: "⊕" },
                                        { title: "Billing & Payments",   icon: "Rs" },
                                        { title: "Safety Concerns",      icon: "⚑" },
                                        { title: "App Feedback",         icon: "✉" }
                                    ]
                                    delegate: Rectangle {
                                        width: parent.width - 32; height: 48; radius: 10; color: "#FAFAFA"; border.color: "#EEEEEE"
                                        property var hi: modelData
                                        Row {
                                            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                            Rectangle {
                                                width: 30; height: 30; radius: 8; color: "#E3F2FD"; anchors.verticalCenter: parent.verticalCenter
                                                Text { anchors.centerIn: parent; text: hi ? hi.icon : ""; font.pixelSize: 13; font.bold: true; color: "#1976D2" }
                                            }
                                            Label { text: hi ? hi.title : ""; font.pixelSize: 13; color: "#111"; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 30 - 10 - 10 - 18 }
                                            Text { text: "›"; font.pixelSize: 18; color: "#CCC"; anchors.verticalCenter: parent.verticalCenter }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: console.log("Help:", hi ? hi.title : "") }
                                    }
                                }

                                Rectangle {
                                    width: parent.width - 32; height: 44; radius: 10
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#1976D2" }
                                        GradientStop { position: 1.0; color: "#42A5F5" }
                                    }
                                    Row { anchors.centerIn: parent; spacing: 8
                                        Text { text: "💬"; font.pixelSize: 16 }
                                        Text { text: "Chat with Support"; font.pixelSize: 13; font.bold: true; color: "white" }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: console.log("Open support chat") }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0" }

                        // ── About ─────────────────────────────────────
                        Rectangle {
                            width: parent.width; height: 60; color: aboutMouse.containsMouse ? "#F8F8F8" : "transparent"
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                Rectangle {
                                    width: 36; height: 36; radius: 18; color: "#F5F5F5"; anchors.verticalCenter: parent.verticalCenter
                                    Text { anchors.centerIn: parent; text: "ℹ"; font.pixelSize: 16; color: "#1976D2" }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                    Label { text: "About YatraSarthi"; font.pixelSize: 14; color: "#111" }
                                    Label { text: "Version 1.0.0 · Terms · Privacy"; font.pixelSize: 11; color: "#AAA" }
                                }
                                Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter }
                            }
                            MouseArea { id: aboutMouse; anchors.fill: parent; hoverEnabled: true; onClicked: console.log("About") }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: "#F0F0F0" }

                        // ── Rate the App ──────────────────────────────
                        Rectangle {
                            width: parent.width; height: 60; color: rateMouse.containsMouse ? "#F8F8F8" : "transparent"
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                Rectangle {
                                    width: 36; height: 36; radius: 18; color: "#FFF8E1"; anchors.verticalCenter: parent.verticalCenter
                                    Text { anchors.centerIn: parent; text: "★"; font.pixelSize: 18; color: "#FFB300" }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                    Label { text: "Rate the App"; font.pixelSize: 14; color: "#111" }
                                    Label { text: "Enjoying YatraSarthi? Leave a review"; font.pixelSize: 11; color: "#AAA" }
                                }
                                Text { text: "›"; font.pixelSize: 22; color: "#CCCCCC"; anchors.verticalCenter: parent.verticalCenter }
                            }
                            MouseArea { id: rateMouse; anchors.fill: parent; hoverEnabled: true; onClicked: console.log("Rate app") }
                        }
                    }
                }

                // ── LOGOUT BUTTON ─────────────────────────────────────
                Rectangle {
                    x: 16; width: parent.width - 32; height: 50; radius: 14
                    color: "#FFF0F0"; border.color: "#FFCDD2"
                    Row {
                        anchors.centerIn: parent; spacing: 10
                        Text { text: "⏻"; font.pixelSize: 18; color: "#E53935" }
                        Text { text: "Log Out"; font.pixelSize: 15; font.bold: true; color: "#E53935" }
                    }
                    MouseArea { anchors.fill: parent; onClicked: console.log("Logout") }
                }

                Item { width: 1; height: 20 }
            }
        }
    }
}
