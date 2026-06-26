import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    property var appStack
    property var appState

    signal switchTab(int tabIndex)

    footer: null
    header: null

    // ── Live dark-mode flag ───────────────────────────────────────────────
    readonly property bool dm: appState ? appState.darkMode : false

    // ── Theme palette ─────────────────────────────────────────────────────
    readonly property color thBg:           dm ? "#121212" : "#F5F6FA"
    readonly property color thCard:         dm ? "#1E1E1E" : "#FFFFFF"
    readonly property color thBorder:       dm ? "#2C2C2C" : "#EEEEEE"
    readonly property color thText:         dm ? "#EEEEEE" : "#111111"
    readonly property color thTextSub:      dm ? "#888888" : "#AAAAAA"
    readonly property color thTextLabel:    dm ? "#777777" : "#AAAAAA"
    readonly property color thRowHover:     dm ? "#252525" : "#F8F8F8"
    readonly property color thDivider:      dm ? "#2A2A2A" : "#F0F0F0"
    readonly property color thFieldBg:      dm ? "#2A2A2A" : "#F8F9FA"
    readonly property color thFieldBorder:  dm ? "#444444" : "#EEEEEE"
    readonly property color thIconBg:       dm ? "#2A2A2A" : "#F5F5F5"
    readonly property color thRideCard:     dm ? "#1A1A1A" : "#FAFAFA"
    readonly property color thSectionLabel: dm ? "#666666" : "#AAAAAA"

    onVisibleChanged: {
        if (visible && appState) appState.showBottomBar = true
    }

    // ── EMERGENCY CONTACTS STATE ──────────────────────────────────────────
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

    // ── PROFILE EDIT STATE ────────────────────────────────────────────────
    property bool profileEditExpanded: false
    property bool profileEditMode: false
    property string profileSaveMessage: ""
    property string profileName: "Johney Reji"
    property string profileEmail: "johneyoct@gmail.com"
    property string profilePhone: "+91 8089011097"
    property int profileSyncTick: 0

    // ── PAYMENT STATE ─────────────────────────────────────────────────────
    property bool paymentExpanded: false
    property int selectedPaymentTab: 0

    // ── RIDE HISTORY STATE ────────────────────────────────────────────────
    property bool rideHistoryExpanded: false
    property var rideHistoryData: [
        { date: "22 Jun 2026", from: "Koramangala", to: "Indiranagar", fare: "148", status: "Completed" },
        { date: "20 Jun 2026", from: "MG Road",     to: "Whitefield",  fare: "320", status: "Completed" },
        { date: "18 Jun 2026", from: "HSR Layout",  to: "Jayanagar",   fare: "95",  status: "Cancelled" }
    ]

    // ── REWARDS STATE ─────────────────────────────────────────────────────
    property bool rewardsExpanded: false
    property int rewardPoints: 1240
    property var couponList: [
        { code: "RIDE20",  desc: "20% off next ride",     expiry: "30 Jun 2026" },
        { code: "FLAT50",  desc: "Rs.50 off on Rs.200+",  expiry: "15 Jul 2026" },
        { code: "GOLD10",  desc: "Gold member bonus 10%", expiry: "31 Jul 2026" }
    ]

    // ── NOTIFICATIONS STATE ───────────────────────────────────────────────
    property bool notifExpanded: false
    property bool notifRideAlerts: true
    property bool notifOffers: true
    property bool notifSMS: false
    property bool notifEmail: true

    // ── SAFETY STATE ──────────────────────────────────────────────────────
    property bool safetyExpanded: false
    property bool safetyShareTrip: false
    property bool safetyIncognito: false

    // ── HELP STATE ────────────────────────────────────────────────────────
    property bool helpExpanded: false

    // ── LANGUAGE STATE ────────────────────────────────────────────────────
    property bool langExpanded: false
    property int selectedLang: 0
    property var languages: ["English", "Hindi", "Kannada", "Tamil", "Telugu"]

    // ── GENDER ────────────────────────────────────────────────────────────
    property int selectedGender: 0

    // ── RATE THE APP STATE ────────────────────────────────────────────────
    property bool rateExpanded: false
    property int selectedRating: 0          // 0 = none chosen yet
    property int submittedRating: 0         // locked in after submit
    property string reviewText: ""
    property bool reviewSubmitted: false
    property bool thankYouVisible: false

    // ── ABOUT STATE ───────────────────────────────────────────────────────
    property bool aboutExpanded: false

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
        rateExpanded         = false
        aboutExpanded        = false
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

    // ── Star label helper ─────────────────────────────────────────────────
    function starLabel(n) {
        if (n === 1) return "Poor "
        if (n === 2) return "Fair "
        if (n === 3) return "Good "
        if (n === 4) return "Great "
        if (n === 5) return "Excellent "
        return "Tap a star to rate"
    }

    // ── PAGE BACKGROUND ───────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: thBg
    }

    // ── Thank-you toast overlay ───────────────────────────────────────────
    Rectangle {
        id: thankYouToast
        visible: thankYouVisible
        z: 100
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        width: thankYouRow.implicitWidth + 32
        height: 46
        radius: 23
        color: "#1976D2"

        Row {
            id: thankYouRow
            anchors.centerIn: parent
            spacing: 8
            Text { text: ""; font.pixelSize: 18 }
            Text {
                text: "Thanks for rating us " + submittedRating + " ★!"
                color: "white"; font.pixelSize: 14; font.bold: true
            }
        }

        Timer {
            running: thankYouVisible
            interval: 3000
            repeat: false
            onTriggered: thankYouVisible = false
        }

        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {
            width: parent.width
            spacing: 0

            // ── TOP HEADER BAR ────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 56; color: "#1976D2"
                Rectangle {
                    id: backBtn
                    width: 36; height: 36; radius: 18
                    color: dm ? "#1565C0" : "white"
                    anchors.left: parent.left; anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: "‹"; font.pixelSize: 28; font.bold: true; color: dm ? "white" : "#1565C0"; anchors.centerIn: parent; anchors.horizontalCenterOffset: -1 }
                    MouseArea { anchors.fill: parent; onClicked: switchTab(0) }
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: backBtn.right; anchors.leftMargin: 10
                    text: "Account"; font.pixelSize: 20; font.bold: true; color: "white"
                }
            }

            // ── PROFILE HEADER ────────────────────────────────────────────
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
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: profileName; font.pixelSize: 18; font.bold: true; color: "white" }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: profilePhone; font.pixelSize: 12; color: "#B3E5FC" }
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

            // ── MAIN CONTENT ──────────────────────────────────────────────
            Column {
                width: parent.width; spacing: 14

                Item { width: 1; height: 14 }

                // ── SECTION: PROFILE ──────────────────────────────────────
                Item {
                    x: 16; width: parent.width - 32; height: 24
                    Label { text: "PROFILE"; font.pixelSize: 11; font.bold: true; color: thSectionLabel; leftPadding: 4; anchors.bottom: parent.bottom }
                }

                Rectangle {
                    x: 16; width: parent.width - 32
                    radius: 14; color: thCard; border.color: thBorder; clip: true
                    height: profileSectionCol.implicitHeight

                    Column {
                        id: profileSectionCol; width: parent.width; spacing: 0

                        // Edit Profile row
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60
                                color: editProfMouse.containsMouse ? thRowHover : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/driver.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Edit Profile"; font.pixelSize: 14; color: thText }
                                        Label { text: profileName + " · " + profileEmail; font.pixelSize: 11; color: thTextSub; elide: Text.ElideRight; width: parent.width }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: profileEditExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea {
                                    id: editProfMouse; anchors.fill: parent; hoverEnabled: true
                                    onClicked: { var w = profileEditExpanded; collapseAll(); profileEditExpanded = !w; if (profileEditExpanded) profileSaveMessage = "" }
                                }
                            }
                            Column {
                                width: parent.width; visible: profileEditExpanded
                                spacing: 10; topPadding: 4; bottomPadding: 16; leftPadding: 16; rightPadding: 16
                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }
                                Row {
                                    width: parent.width - 32
                                    Label { text: "Personal Details"; font.pixelSize: 12; font.bold: true; color: thTextLabel; width: parent.width - editProfBtn.width; anchors.verticalCenter: parent.verticalCenter }
                                    Button {
                                        id: editProfBtn; text: profileEditMode ? "Cancel" : "Edit"; flat: true
                                        contentItem: Text { text: editProfBtn.text; color: "#1976D2"; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: { if (profileEditMode) { profileSyncTick++; profileSaveMessage = "" }; profileEditMode = !profileEditMode }
                                    }
                                }
                                Item {
                                    property int tick: profileSyncTick
                                    onTickChanged: { pNameField.text = profileName; pEmailField.text = profileEmail; pPhoneField.text = profilePhone }
                                    Component.onCompleted: { pNameField.text = profileName; pEmailField.text = profileEmail; pPhoneField.text = profilePhone }
                                }
                                Column { width: parent.width - 32; spacing: 4
                                    Label { text: "Full Name"; font.pixelSize: 11; color: thTextLabel }
                                    TextField { id: pNameField; width: parent.width; placeholderText: "Your name"; readOnly: !profileEditMode; leftPadding: 12; font.pixelSize: 13; color: thText
                                        background: Rectangle { color: thFieldBg; radius: 8; border.color: profileEditMode ? "#1976D2" : thFieldBorder; border.width: profileEditMode ? 1.5 : 1 }
                                    }
                                }
                                Column { width: parent.width - 32; spacing: 4
                                    Label { text: "Email"; font.pixelSize: 11; color: thTextLabel }
                                    TextField { id: pEmailField; width: parent.width; placeholderText: "your@email.com"; readOnly: !profileEditMode; leftPadding: 12; font.pixelSize: 13; color: thText
                                        background: Rectangle { color: thFieldBg; radius: 8; border.color: profileEditMode ? "#1976D2" : thFieldBorder; border.width: profileEditMode ? 1.5 : 1 }
                                    }
                                }
                                Column { width: parent.width - 32; spacing: 4
                                    Label { text: "Phone Number"; font.pixelSize: 11; color: thTextLabel }
                                    TextField { id: pPhoneField; width: parent.width; placeholderText: "+91 XXXXX XXXXX"; readOnly: !profileEditMode; inputMethodHints: Qt.ImhDialableCharactersOnly; leftPadding: 12; font.pixelSize: 13; color: thText
                                        background: Rectangle { color: thFieldBg; radius: 8; border.color: profileEditMode ? "#1976D2" : thFieldBorder; border.width: profileEditMode ? 1.5 : 1 }
                                    }
                                }
                                Column { width: parent.width - 32; spacing: 4
                                    Label { text: "Gender"; font.pixelSize: 11; color: thTextLabel }
                                    Row { spacing: 8
                                        Repeater {
                                            model: ["Male", "Female", "Other"]
                                            delegate: Rectangle {
                                                width: gTxt.implicitWidth + 20; height: 30; radius: 15
                                                color: selectedGender === index ? "#1976D2" : (dm ? "#2A2A2A" : "#F0F4FF")
                                                border.color: selectedGender === index ? "#1565C0" : (dm ? "#444444" : "#D0D8FF")
                                                opacity: profileEditMode ? 1.0 : 0.65
                                                Text { id: gTxt; anchors.centerIn: parent; text: modelData; font.pixelSize: 12; color: selectedGender === index ? "white" : thText }
                                                MouseArea { anchors.fill: parent; enabled: profileEditMode; onClicked: selectedGender = index }
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    visible: profileEditMode
                                    width: parent.width - 32; height: 44; radius: 10; color: "#1976D2"
                                    Text { anchors.centerIn: parent; text: "Save Profile"; font.pixelSize: 14; font.bold: true; color: "white" }
                                    MouseArea { anchors.fill: parent; onClicked: { profileName = pNameField.text; profileEmail = pEmailField.text; profilePhone = pPhoneField.text; profileEditMode = false; profileSaveMessage = "Profile updated successfully"; profileSyncTick++ } }
                                }
                                Label { visible: profileSaveMessage !== ""; text: profileSaveMessage; color: profileSaveMessage === "Profile updated successfully" ? "#388E3C" : "#E53935"; font.pixelSize: 12; wrapMode: Text.WordWrap; width: parent.width - 32 }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: thDivider }

                        // Payment Methods row
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: payMouse.containsMouse ? thRowHover : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/star.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Payment Methods"; font.pixelSize: 14; color: thText }
                                        Label { text: "UPI, cards, wallets"; font.pixelSize: 11; color: thTextSub }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: paymentExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: payMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = paymentExpanded; collapseAll(); paymentExpanded = !w } }
                            }
                            Column {
                                visible: paymentExpanded; width: parent.width; topPadding: 4; bottomPadding: 12
                                Rectangle { x: 16; width: parent.width - 32; height: 1; color: thDivider }
                                Item { height: 8 }
                                Row {
                                    x: 16; width: parent.width - 32; height: 36; spacing: 0
                                    Repeater {
                                        model: ["UPI", "Cards", "Wallet"]
                                        delegate: Rectangle {
                                            width: parent.width / 3; height: 36
                                            color: selectedPaymentTab === index ? (dm ? "#1A3A5C" : "#E3F2FD") : "transparent"
                                            radius: 8
                                            Text { anchors.centerIn: parent; text: modelData; font.pixelSize: 13; font.bold: selectedPaymentTab === index; color: selectedPaymentTab === index ? "#1976D2" : thTextSub }
                                            MouseArea { anchors.fill: parent; onClicked: selectedPaymentTab = index }
                                        }
                                    }
                                }
                                Rectangle { x: 16; width: parent.width - 32; height: 1; color: thDivider }
                                Item { height: 8 }
                                Column { visible: selectedPaymentTab === 0; x: 16; width: parent.width - 32; spacing: 8
                                    Repeater {
                                        model: ["johney@upi", "johney@okaxis"]
                                        delegate: Rectangle {
                                            width: parent.width; height: 52; radius: 10; color: thFieldBg; border.color: thBorder
                                            Row { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10
                                                Rectangle { width: 32; height: 32; radius: 8; color: dm ? "#1A3A5C" : "#E3F2FD"; anchors.verticalCenter: parent.verticalCenter
                                                    Text { anchors.centerIn: parent; text: "Rs"; font.pixelSize: 12; font.bold: true; color: "#1976D2" }
                                                }
                                                Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                                    Label { text: modelData; font.pixelSize: 13; color: thText }
                                                    Label { text: index === 0 ? "Default" : "Linked"; font.pixelSize: 11; color: index === 0 ? "#43A047" : thTextSub }
                                                }
                                            }
                                        }
                                    }
                                    Rectangle { width: parent.width; height: 44; radius: 10; color: dm ? "#1A3A5C" : "#EEF4FF"; border.color: dm ? "#2A5A9C" : "#C5D8FF"
                                        Row { anchors.centerIn: parent; spacing: 8
                                            Text { text: "+"; font.pixelSize: 18; color: "#1976D2"; font.bold: true }
                                            Text { text: "Add UPI ID"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: console.log("Add UPI") }
                                    }
                                }
                                Column { visible: selectedPaymentTab === 1; x: 16; width: parent.width - 32; spacing: 8
                                    Rectangle { width: parent.width; height: 80; radius: 12
                                        gradient: Gradient { orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: "#1565C0" }
                                            GradientStop { position: 1.0; color: "#42A5F5" }
                                        }
                                        Column { anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                            Label { text: "**** **** **** 4521"; font.pixelSize: 14; color: "white" }
                                            Label { text: "JOHNEY  Expires 09/28"; font.pixelSize: 11; color: "#B3E5FC" }
                                        }
                                        Rectangle { width: 40; height: 22; radius: 4; color: "#FFD600"; anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                                            Text { anchors.centerIn: parent; text: "VISA"; font.pixelSize: 10; font.bold: true; color: "#333" }
                                        }
                                    }
                                    Rectangle { width: parent.width; height: 44; radius: 10; color: dm ? "#1A3A5C" : "#EEF4FF"; border.color: dm ? "#2A5A9C" : "#C5D8FF"
                                        Row { anchors.centerIn: parent; spacing: 8
                                            Text { text: "+"; font.pixelSize: 18; color: "#1976D2"; font.bold: true }
                                            Text { text: "Add Card"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: console.log("Add Card") }
                                    }
                                }
                                Column { visible: selectedPaymentTab === 2; x: 16; width: parent.width - 32; spacing: 8
                                    Rectangle { width: parent.width; height: 64; radius: 12; color: dm ? "#1A2E1A" : "#F1F8E9"; border.color: dm ? "#2A4A2A" : "#C5E1A5"
                                        Row { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 12
                                            Rectangle { width: 36; height: 36; radius: 18; color: "#43A047"; anchors.verticalCenter: parent.verticalCenter
                                                Text { anchors.centerIn: parent; text: "Rs"; font.pixelSize: 13; font.bold: true; color: "white" }
                                            }
                                            Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                                Label { text: "YatraCash Balance"; font.pixelSize: 13; font.bold: true; color: dm ? "#66BB6A" : "#2E7D32" }
                                                Label { text: "Rs.250 available"; font.pixelSize: 12; color: thText }
                                            }
                                        }
                                    }
                                    Rectangle { width: parent.width; height: 44; radius: 10; color: dm ? "#1A2E1A" : "#E8F5E9"; border.color: dm ? "#2A4A2A" : "#A5D6A7"
                                        Row { anchors.centerIn: parent; spacing: 8
                                            Text { text: "+"; font.pixelSize: 18; color: "#43A047"; font.bold: true }
                                            Text { text: "Add Money"; font.pixelSize: 13; color: "#43A047"; font.bold: true }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: console.log("Add Money") }
                                    }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: thDivider }

                        // Emergency Contacts row
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: emgMouse.containsMouse ? thRowHover : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/sos.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Emergency Contacts"; font.pixelSize: 14; color: thText }
                                        Label { text: "SOS contacts & medical info"; font.pixelSize: 11; color: thTextSub }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: emergencyExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: emgMouse; anchors.fill: parent; hoverEnabled: true
                                    onClicked: { var w = emergencyExpanded; collapseAll(); emergencyExpanded = !w; if (emergencyExpanded) { emergencySaveMessage = ""; loadEmergencyInfo() } }
                                }
                            }
                            Column {
                                visible: emergencyExpanded; width: parent.width
                                spacing: 10; topPadding: 4; bottomPadding: 16; leftPadding: 16; rightPadding: 16
                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }
                                Row { width: parent.width - 32
                                    Label { text: "Saved Information"; font.pixelSize: 12; font.bold: true; color: thTextLabel; anchors.verticalCenter: parent.verticalCenter; width: parent.width - emgEditBtn.width }
                                    Button { id: emgEditBtn; text: emergencyEditMode ? "Cancel" : "Edit"; flat: true
                                        contentItem: Text { text: emgEditBtn.text; color: "#1976D2"; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: { if (emergencyEditMode) { loadEmergencyInfo(); emergencySaveMessage = "" }; emergencyEditMode = !emergencyEditMode }
                                    }
                                }
                                Item { property int tick: emergencySyncTick
                                    onTickChanged: { acc1N.text = contact1Name; acc1P.text = contact1Phone; acc2N.text = contact2Name; acc2P.text = contact2Phone; accBG.text = bloodGroup; accMN.text = medicalNotes }
                                    Component.onCompleted: { acc1N.text = contact1Name; acc1P.text = contact1Phone; acc2N.text = contact2Name; acc2P.text = contact2Phone; accBG.text = bloodGroup; accMN.text = medicalNotes }
                                }
                                Label { text: "Emergency Contact 1"; font.pixelSize: 12; color: thTextLabel }
                                TextField { id: acc1N; width: parent.width - 32; placeholderText: "Name"; readOnly: !emergencyEditMode; color: thText; onTextChanged: contact1Name = text
                                    background: Rectangle { color: thFieldBg; radius: 8; border.color: emergencyEditMode ? "#1976D2" : thFieldBorder; border.width: emergencyEditMode ? 1.5 : 1 }
                                }
                                TextField { id: acc1P; width: parent.width - 32; placeholderText: "Phone number"; readOnly: !emergencyEditMode; inputMethodHints: Qt.ImhDialableCharactersOnly; color: thText; onTextChanged: contact1Phone = text
                                    background: Rectangle { color: thFieldBg; radius: 8; border.color: emergencyEditMode ? "#1976D2" : thFieldBorder; border.width: emergencyEditMode ? 1.5 : 1 }
                                }
                                Label { text: "Emergency Contact 2"; font.pixelSize: 12; color: thTextLabel }
                                TextField { id: acc2N; width: parent.width - 32; placeholderText: "Name"; readOnly: !emergencyEditMode; color: thText; onTextChanged: contact2Name = text
                                    background: Rectangle { color: thFieldBg; radius: 8; border.color: emergencyEditMode ? "#1976D2" : thFieldBorder; border.width: emergencyEditMode ? 1.5 : 1 }
                                }
                                TextField { id: acc2P; width: parent.width - 32; placeholderText: "Phone number"; readOnly: !emergencyEditMode; inputMethodHints: Qt.ImhDialableCharactersOnly; color: thText; onTextChanged: contact2Phone = text
                                    background: Rectangle { color: thFieldBg; radius: 8; border.color: emergencyEditMode ? "#1976D2" : thFieldBorder; border.width: emergencyEditMode ? 1.5 : 1 }
                                }
                                Label { text: "Blood Group"; font.pixelSize: 12; color: thTextLabel }
                                TextField { id: accBG; width: parent.width - 32; placeholderText: "e.g. O+"; readOnly: !emergencyEditMode; color: thText; onTextChanged: bloodGroup = text
                                    background: Rectangle { color: thFieldBg; radius: 8; border.color: emergencyEditMode ? "#1976D2" : thFieldBorder; border.width: emergencyEditMode ? 1.5 : 1 }
                                }
                                Label { text: "Medical Notes"; font.pixelSize: 12; color: thTextLabel }
                                TextArea { id: accMN; width: parent.width - 32; placeholderText: "Allergies, conditions, medications..."; readOnly: !emergencyEditMode; wrapMode: TextArea.Wrap; color: thText; onTextChanged: medicalNotes = text
                                    background: Rectangle { color: thFieldBg; radius: 8; border.color: emergencyEditMode ? "#1976D2" : thFieldBorder; border.width: emergencyEditMode ? 1.5 : 1 }
                                }
                                Rectangle { visible: emergencyEditMode; width: parent.width - 32; height: 44; radius: 10; color: "#1976D2"
                                    Text { anchors.centerIn: parent; text: "Save Emergency Info"; font.pixelSize: 14; font.bold: true; color: "white" }
                                    MouseArea { anchors.fill: parent; onClicked: saveEmergencyInfo() }
                                }
                                Label { visible: emergencySaveMessage !== ""; text: emergencySaveMessage; font.pixelSize: 12; wrapMode: Text.WordWrap; width: parent.width - 32; color: emergencySaveMessage === "Saved successfully" ? "#388E3C" : "#E53935" }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: thDivider }

                        // Ride History row
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: rideMouse.containsMouse ? thRowHover : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/rider.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Ride History"; font.pixelSize: 14; color: thText }
                                        Label { text: "142 past trips & receipts"; font.pixelSize: 11; color: thTextSub }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: rideHistoryExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: rideMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = rideHistoryExpanded; collapseAll(); rideHistoryExpanded = !w } }
                            }
                            Column {
                                visible: rideHistoryExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 12; leftPadding: 16; rightPadding: 16; spacing: 8
                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }
                                Repeater {
                                    model: rideHistoryData
                                    delegate: Rectangle {
                                        width: parent.width - 32; height: 68; radius: 10; color: thRideCard; border.color: thBorder
                                        property var rd: modelData
                                        Row { anchors.fill: parent; anchors.margins: 12; spacing: 10
                                            Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3; width: parent.width - 80
                                                Label { text: (rd ? rd.from : "") + "  →  " + (rd ? rd.to : ""); font.pixelSize: 13; font.bold: true; color: thText; elide: Text.ElideRight; width: parent.width }
                                                Label { text: rd ? rd.date : ""; font.pixelSize: 11; color: thTextSub }
                                            }
                                            Column { anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                                Label { text: rd ? "Rs." + rd.fare : ""; font.pixelSize: 14; font.bold: true; color: thText }
                                                Rectangle { height: 16; radius: 8; width: stLbl.implicitWidth + 10
                                                    color: (rd && rd.status === "Completed") ? (dm ? "#1A2E1A" : "#E8F5E9") : (dm ? "#2E1A1A" : "#FFEBEE")
                                                    Text { id: stLbl; anchors.centerIn: parent; text: rd ? rd.status : ""; font.pixelSize: 10; font.bold: true; color: (rd && rd.status === "Completed") ? "#388E3C" : "#C62828" }
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle { width: parent.width - 32; height: 40; radius: 10; color: thFieldBg; border.color: thBorder
                                    Text { anchors.centerIn: parent; text: "View All Trips"; font.pixelSize: 13; color: "#1976D2"; font.bold: true }
                                    MouseArea { anchors.fill: parent; onClicked: console.log("View all trips") }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: thDivider }

                        // Rewards & Coupons row
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: rwdMouse.containsMouse ? thRowHover : "transparent"
                                Row {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/star.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 80
                                        Label { text: "Rewards & Coupons"; font.pixelSize: 14; color: thText }
                                        Label { text: rewardPoints + " pts · 3 Offers"; font.pixelSize: 11; color: thTextSub }
                                    }
                                    Rectangle { height: 18; radius: 9; color: dm ? "#3A2A0A" : "#FFF3E0"; width: rwdTag.implicitWidth + 12; anchors.verticalCenter: parent.verticalCenter
                                        Text { id: rwdTag; anchors.centerIn: parent; text: "3 Offers"; font.pixelSize: 10; font.bold: true; color: "#E65100" }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: rewardsExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: rwdMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = rewardsExpanded; collapseAll(); rewardsExpanded = !w } }
                            }
                            Column {
                                visible: rewardsExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 12; leftPadding: 16; rightPadding: 16; spacing: 10
                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }
                                Rectangle { width: parent.width - 32; height: 70; radius: 12
                                    gradient: Gradient { orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#FF8F00" }
                                        GradientStop { position: 1.0; color: "#FFD54F" }
                                    }
                                    Column { anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                        Label { text: rewardPoints + " Points"; font.pixelSize: 22; font.bold: true; color: "white" }
                                        Label { text: "Rs." + Math.floor(rewardPoints / 10) + " off on next ride"; font.pixelSize: 11; color: "#FFF8E1" }
                                    }
                                }
                                Label { text: "Available Coupons"; font.pixelSize: 12; font.bold: true; color: thTextLabel }
                                Repeater {
                                    model: couponList
                                    delegate: Rectangle {
                                        width: parent.width - 32; height: 62; radius: 10; color: thCard; border.color: thBorder
                                        property var cpn: modelData
                                        Rectangle { width: 4; height: parent.height - 12; radius: 2; color: "#1976D2"; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter }
                                        Row { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 12; spacing: 8
                                            Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 70
                                                Label { text: cpn ? cpn.code : ""; font.pixelSize: 14; font.bold: true; color: "#1976D2" }
                                                Label { text: cpn ? cpn.desc : ""; font.pixelSize: 12; color: thText }
                                                Label { text: "Expires: " + (cpn ? cpn.expiry : ""); font.pixelSize: 10; color: thTextSub }
                                            }
                                            Rectangle { width: 52; height: 28; radius: 8; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter
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

                // ── SECTION: PREFERENCES ──────────────────────────────────
                Item { x: 16; width: parent.width - 32; height: 24
                    Label { text: "PREFERENCES"; font.pixelSize: 11; font.bold: true; color: thSectionLabel; leftPadding: 4; anchors.bottom: parent.bottom }
                }

                Rectangle {
                    x: 16; width: parent.width - 32
                    radius: 14; color: thCard; border.color: thBorder; clip: true
                    height: prefCol.implicitHeight

                    Column {
                        id: prefCol; width: parent.width; spacing: 0

                        // Notifications
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: notifMouse.containsMouse ? thRowHover : "transparent"
                                Row { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/destination.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Notifications"; font.pixelSize: 14; color: thText }
                                        Label { text: "Ride alerts, offers"; font.pixelSize: 11; color: thTextSub }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: notifExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: notifMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = notifExpanded; collapseAll(); notifExpanded = !w } }
                            }
                            Column {
                                visible: notifExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 8; leftPadding: 16; rightPadding: 16; spacing: 0
                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }
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
                                        Row { anchors.fill: parent; spacing: 0
                                            Column { anchors.verticalCenter: parent.verticalCenter; width: parent.width - 52; spacing: 2
                                                Label { text: ni ? ni.lbl : ""; font.pixelSize: 14; color: thText }
                                                Label { text: ni ? ni.sub : ""; font.pixelSize: 11; color: thTextSub }
                                            }
                                            Rectangle {
                                                width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                                color: togVal ? "#1976D2" : (dm ? "#444444" : "#CCCCCC")
                                                Behavior on color { ColorAnimation { duration: 150 } }
                                                Rectangle { width: 20; height: 20; radius: 10; color: "white"; anchors.verticalCenter: parent.verticalCenter; x: togVal ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } } }
                                                MouseArea { anchors.fill: parent; onClicked: { if (!ni) return; if (ni.tog === 0) notifRideAlerts = !notifRideAlerts; else if (ni.tog === 1) notifOffers = !notifOffers; else if (ni.tog === 2) notifSMS = !notifSMS; else notifEmail = !notifEmail } }
                                            }
                                        }
                                        Rectangle { visible: index < 3; height: 1; color: thDivider; anchors.bottom: parent.bottom; width: parent.width }
                                    }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: thDivider }

                        // Safety Settings
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: safetyMouse.containsMouse ? thRowHover : "transparent"
                                Row { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/sos.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Safety Settings"; font.pixelSize: 14; color: thText }
                                        Label { text: "Trip sharing, incognito mode"; font.pixelSize: 11; color: thTextSub }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: safetyExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: safetyMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = safetyExpanded; collapseAll(); safetyExpanded = !w } }
                            }
                            Column {
                                visible: safetyExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 8; leftPadding: 16; rightPadding: 16; spacing: 0
                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }
                                Rectangle { width: parent.width - 32; height: 52; color: "transparent"
                                    Row { anchors.fill: parent; spacing: 0
                                        Column { anchors.verticalCenter: parent.verticalCenter; width: parent.width - 52; spacing: 2
                                            Label { text: "Share Trip"; font.pixelSize: 14; color: thText }
                                            Label { text: "Auto-share live location with contacts"; font.pixelSize: 11; color: thTextSub }
                                        }
                                        Rectangle { width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter; color: safetyShareTrip ? "#1976D2" : (dm ? "#444444" : "#CCCCCC"); Behavior on color { ColorAnimation { duration: 150 } }
                                            Rectangle { width: 20; height: 20; radius: 10; color: "white"; anchors.verticalCenter: parent.verticalCenter; x: safetyShareTrip ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } } }
                                            MouseArea { anchors.fill: parent; onClicked: safetyShareTrip = !safetyShareTrip }
                                        }
                                    }
                                    Rectangle { height: 1; color: thDivider; anchors.bottom: parent.bottom; width: parent.width }
                                }
                                Rectangle { width: parent.width - 32; height: 52; color: "transparent"
                                    Row { anchors.fill: parent; spacing: 0
                                        Column { anchors.verticalCenter: parent.verticalCenter; width: parent.width - 52; spacing: 2
                                            Label { text: "Incognito Mode"; font.pixelSize: 14; color: thText }
                                            Label { text: "Hide your profile from drivers"; font.pixelSize: 11; color: thTextSub }
                                        }
                                        Rectangle { width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter; color: safetyIncognito ? "#1976D2" : (dm ? "#444444" : "#CCCCCC"); Behavior on color { ColorAnimation { duration: 150 } }
                                            Rectangle { width: 20; height: 20; radius: 10; color: "white"; anchors.verticalCenter: parent.verticalCenter; x: safetyIncognito ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } } }
                                            MouseArea { anchors.fill: parent; onClicked: safetyIncognito = !safetyIncognito }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: thDivider }

                        // Language
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: langMouse.containsMouse ? thRowHover : "transparent"
                                Row { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Image { source: Qt.resolvedUrl("../../assets/icons/map.png"); width: 20; height: 20; fillMode: Image.PreserveAspectFit; anchors.centerIn: parent }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Language"; font.pixelSize: 14; color: thText }
                                        Label { text: languages[selectedLang]; font.pixelSize: 11; color: thTextSub }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: langExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: langMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = langExpanded; collapseAll(); langExpanded = !w } }
                            }
                            Column {
                                visible: langExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 8; leftPadding: 16; rightPadding: 16; spacing: 0
                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }
                                Repeater {
                                    model: languages
                                    delegate: Rectangle {
                                        width: parent.width - 32; height: 46; radius: 8
                                        color: selectedLang === index ? (dm ? "#1A2A4A" : "#EEF4FF") : "transparent"
                                        Row { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                            Label { text: modelData; font.pixelSize: 14; font.bold: selectedLang === index; color: selectedLang === index ? "#1976D2" : thText; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 30 }
                                            Text { visible: selectedLang === index; text: "✓"; font.pixelSize: 16; font.bold: true; color: "#1976D2"; anchors.verticalCenter: parent.verticalCenter }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: { selectedLang = index; langExpanded = false } }
                                    }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: thDivider }

                        // Dark Mode toggle
                        Rectangle {
                            width: parent.width; height: 60; color: "transparent"
                            Row { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                    Text { anchors.centerIn: parent; text: dm ? "🌙" : "☀️"; font.pixelSize: 18 }
                                }
                                Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 50
                                    Label { text: "Dark Mode"; font.pixelSize: 14; color: thText }
                                    Label { text: dm ? "On" : "Off"; font.pixelSize: 11; color: thTextSub }
                                }
                                Rectangle {
                                    width: 40; height: 24; radius: 12; anchors.verticalCenter: parent.verticalCenter
                                    color: dm ? "#1976D2" : "#CCCCCC"
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Rectangle {
                                        width: 20; height: 20; radius: 10; color: "white"; anchors.verticalCenter: parent.verticalCenter
                                        x: dm ? 18 : 2; Behavior on x { NumberAnimation { duration: 150 } }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: { if (appState) appState.darkMode = !appState.darkMode } }
                                }
                            }
                        }
                    }
                }

                // ── SECTION: SUPPORT ──────────────────────────────────────
                Item { x: 16; width: parent.width - 32; height: 24
                    Label { text: "SUPPORT"; font.pixelSize: 11; font.bold: true; color: thSectionLabel; leftPadding: 4; anchors.bottom: parent.bottom }
                }

                Rectangle {
                    x: 16; width: parent.width - 32
                    radius: 14; color: thCard; border.color: thBorder; clip: true
                    height: suppCol.implicitHeight

                    Column {
                        id: suppCol; width: parent.width; spacing: 0

                        // Help & Support
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: helpMouse.containsMouse ? thRowHover : "transparent"
                                Row { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: "?"; font.pixelSize: 18; font.bold: true; color: "#1976D2" }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Help & Support"; font.pixelSize: 14; color: thText }
                                        Label { text: "FAQs, chat with support"; font.pixelSize: 11; color: thTextSub }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: helpExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: helpMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = helpExpanded; collapseAll(); helpExpanded = !w } }
                            }
                            Column {
                                visible: helpExpanded; width: parent.width
                                topPadding: 4; bottomPadding: 12; leftPadding: 16; rightPadding: 16; spacing: 8
                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }
                                Repeater {
                                    model: [
                                        { title: "Report an Issue",    icon: "!" },
                                        { title: "Lost & Found",       icon: "⊕" },
                                        { title: "Billing & Payments", icon: "Rs" },
                                        { title: "Safety Concerns",    icon: "⚑" },
                                        { title: "App Feedback",       icon: "✉" }
                                    ]
                                    delegate: Rectangle {
                                        width: parent.width - 32; height: 48; radius: 10; color: thFieldBg; border.color: thBorder
                                        property var hi: modelData
                                        Row { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                            Rectangle { width: 30; height: 30; radius: 8; color: dm ? "#1A3A5C" : "#E3F2FD"; anchors.verticalCenter: parent.verticalCenter
                                                Text { anchors.centerIn: parent; text: hi ? hi.icon : ""; font.pixelSize: 13; font.bold: true; color: "#1976D2" }
                                            }
                                            Label { text: hi ? hi.title : ""; font.pixelSize: 13; color: thText; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 30 - 10 - 18 }
                                            Text { text: "›"; font.pixelSize: 18; color: thTextSub; anchors.verticalCenter: parent.verticalCenter }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: console.log("Help:", hi ? hi.title : "") }
                                    }
                                }
                                Rectangle { width: parent.width - 32; height: 44; radius: 10
                                    gradient: Gradient { orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#1976D2" }
                                        GradientStop { position: 1.0; color: "#42A5F5" }
                                    }
                                    Row { anchors.centerIn: parent; spacing: 8
                                        Text { text: ""; font.pixelSize: 16 }
                                        Text { text: "Chat with Support"; font.pixelSize: 13; font.bold: true; color: "white" }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: console.log("Open support chat") }
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: thDivider }

                        // ── ABOUT YATRASARTHI — expanded with real content ─
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: aboutMouse.containsMouse ? thRowHover : "transparent"
                                Row { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: thIconBg; anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: "ℹ"; font.pixelSize: 16; color: "#1976D2" }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "About YatraSarthi"; font.pixelSize: 14; color: thText }
                                        Label { text: "Version 1.0.0 · Terms · Privacy"; font.pixelSize: 11; color: thTextSub }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: aboutExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: aboutMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = aboutExpanded; collapseAll(); aboutExpanded = !w } }
                            }

                            // ── About expanded panel ──────────────────────
                            Column {
                                visible: aboutExpanded
                                width: parent.width
                                topPadding: 4; bottomPadding: 20; leftPadding: 16; rightPadding: 16; spacing: 14

                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }

                                // App banner
                                Rectangle {
                                    width: parent.width - 32; height: 90; radius: 16
                                    gradient: Gradient { orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#1565C0" }
                                        GradientStop { position: 1.0; color: "#42A5F5" }
                                    }
                                    Row {
                                        anchors.fill: parent; anchors.margins: 16; spacing: 14
                                        // YatraSarthi logo
                                        Rectangle {
                                            width: 56; height: 56; radius: 28; color: "white"
                                            anchors.verticalCenter: parent.verticalCenter
                                            Image {
                                                anchors.fill: parent
                                                anchors.margins: 2
                                                source: Qt.resolvedUrl("../../assets/icons/logo.png")
                                                fillMode: Image.PreserveAspectFit
                                                // fallback emoji if image not found
                                                visible: status === Image.Ready
                                            }
                                            Text {
                                                anchors.centerIn: parent
                                                text: ""; font.pixelSize: 28
                                                visible: logoImg.status !== Image.Ready
                                                property var logoImg: parent.children[0]
                                            }
                                        }
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                            Label { text: "YatraSarthi"; font.pixelSize: 20; font.bold: true; color: "white" }
                                            Label { text: "Version 1.0.0  ·  Build 2026.06"; font.pixelSize: 11; color: "#B3E5FC" }
                                            Label { text: "The Sarthi for every Yatra"; font.pixelSize: 11; color: "#90CAF9"; font.italic: true }
                                        }
                                    }
                                }

                                // Mission
                                Column { width: parent.width - 32; spacing: 6
                                    Label { text: "Our Mission"; font.pixelSize: 13; font.bold: true; color: "#1976D2" }
                                    Label {
                                        text: "YatraSarthi is a ride-hailing application built for Ubuntu Touch that offers secure authentication, real-time driver tracking, live navigation, in-app communication, and multiple transportation options. Designed with a focus on simplicity, safety, and reliability, it provides users with a seamless and efficient travel experience from booking to ride completion."
                                        font.pixelSize: 13; color: thText; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4
                                    }
                                }

                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }

                                // Built by
                                Column { width: parent.width - 32; spacing: 8
                                    Label { text: "Built by"; font.pixelSize: 13; font.bold: true; color: "#1976D2" }
                                    Repeater {
                                        model: [
                                            { name: "Johney Reji",       role: "Lead Backend Developer" },
                                            { name: "Lokesh Royal",      role: "Lead Frontend Developer" },
                                            { name: "Satyakam Tripathy", role: "Authentication & API Integration" },
                                            { name: "Manaswitha",        role: "UI/UX Designer & Developer" }
                                        ]
                                        delegate: Rectangle {
                                            width: parent.width; height: 44; radius: 10
                                            color: dm ? "#1A1A1A" : "#F8FAFF"; border.color: thBorder
                                            Row {
                                                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                                Rectangle {
                                                    width: 30; height: 30; radius: 15; color: "#1976D2"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    Text { anchors.centerIn: parent; text: modelData.name.charAt(0); font.pixelSize: 13; font.bold: true; color: "white" }
                                                }
                                                Column {
                                                    anchors.verticalCenter: parent.verticalCenter; spacing: 1
                                                    Label { text: modelData.name; font.pixelSize: 13; font.bold: true; color: thText }
                                                    Label { text: modelData.role; font.pixelSize: 11; color: thTextSub }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }

                                // Tech stack
                                Column { width: parent.width - 32; spacing: 8
                                    Label { text: "Technology"; font.pixelSize: 13; font.bold: true; color: "#1976D2" }
                                    Flow { width: parent.width; spacing: 8
                                        Repeater {
                                            model: ["Qt / QML", "Python FastAPI", "OpenStreetMap", "OSRM Routing", "SQLite", "Leaflet.js"]
                                            delegate: Rectangle {
                                                height: 26; radius: 13
                                                color: dm ? "#1A2A3A" : "#E3F2FD"; border.color: dm ? "#2A4A6A" : "#BBDEFB"
                                                width: techLbl.implicitWidth + 16
                                                Label { id: techLbl; anchors.centerIn: parent; text: modelData; font.pixelSize: 11; color: "#1976D2"; font.bold: true }
                                            }
                                        }
                                    }
                                }

                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }

                                // Legal links
                                Column { width: parent.width - 32; spacing: 8
                                    Repeater {
                                        model: [
                                            { label: "Terms of Service",  icon: "" },
                                            { label: "Privacy Policy",    icon: "" },
                                            { label: "Open Source Licences", icon: "" }
                                        ]
                                        delegate: Rectangle {
                                            width: parent.width; height: 44; radius: 10; color: thFieldBg; border.color: thBorder
                                            Row { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                                Text { text: modelData.icon; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                                                Label { text: modelData.label; font.pixelSize: 13; color: thText; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 50 }
                                                Text { text: "›"; font.pixelSize: 18; color: thTextSub; anchors.verticalCenter: parent.verticalCenter }
                                            }
                                            MouseArea { anchors.fill: parent; onClicked: console.log("Open:", modelData.label) }
                                        }
                                    }
                                }

                                // Copyright
                                Label {
                                    width: parent.width - 32
                                    text: "© 2026 YatraSarthi. Made with ❤ in India."
                                    font.pixelSize: 11; color: thTextSub
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        Rectangle { x: 66; width: parent.width - 66; height: 1; color: thDivider }

                        // ── RATE THE APP — fully interactive ──────────────
                        Column {
                            width: parent.width
                            Rectangle {
                                width: parent.width; height: 60; color: rateMouse.containsMouse ? thRowHover : "transparent"
                                Row { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
                                    Rectangle { width: 36; height: 36; radius: 18; color: "#FFF8E1"; anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: "★"; font.pixelSize: 18; color: "#FFB300" }
                                    }
                                    Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2; width: parent.width - 36 - 14 - 30
                                        Label { text: "Rate the App"; font.pixelSize: 14; color: thText }
                                        Label {
                                            text: reviewSubmitted
                                                  ? "You rated us " + submittedRating + " ★ — thank you!"
                                                  : "Enjoying YatraSarthi? Leave a review"
                                            font.pixelSize: 11
                                            color: reviewSubmitted ? "#43A047" : thTextSub
                                        }
                                    }
                                    Text { text: "›"; font.pixelSize: 22; color: thTextSub; anchors.verticalCenter: parent.verticalCenter; rotation: rateExpanded ? 90 : 0; Behavior on rotation { NumberAnimation { duration: 150 } } }
                                }
                                MouseArea { id: rateMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { var w = rateExpanded; collapseAll(); rateExpanded = !w } }
                            }

                            // ── Rate panel ────────────────────────────────
                            Column {
                                visible: rateExpanded
                                width: parent.width
                                topPadding: 8; bottomPadding: 20; leftPadding: 16; rightPadding: 16; spacing: 16

                                Rectangle { width: parent.width - 32; height: 1; color: thDivider }

                                // Already submitted — show thank you state
                                Column {
                                    visible: reviewSubmitted
                                    width: parent.width - 32; spacing: 12
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: ""
                                        font.pixelSize: 48
                                    }
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Thank you for your feedback!"
                                        font.pixelSize: 16; font.bold: true; color: thText
                                    }
                                    // Show submitted stars read-only
                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 8
                                        Repeater {
                                            model: 5
                                            delegate: Text {
                                                text: "★"
                                                font.pixelSize: 32
                                                color: index < submittedRating ? "#FFB300" : (dm ? "#444444" : "#DDDDDD")
                                            }
                                        }
                                    }
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: starLabel(submittedRating)
                                        font.pixelSize: 14; font.bold: true; color: "#FFB300"
                                    }
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Your review helps us improve YatraSarthi for everyone."
                                        font.pixelSize: 12; color: thTextSub; wrapMode: Text.WordWrap
                                        width: parent.width; horizontalAlignment: Text.AlignHCenter
                                    }
                                    // Edit review button
                                    Rectangle {
                                        width: parent.width; height: 44; radius: 10
                                        color: dm ? "#1A2A3A" : "#EEF4FF"; border.color: dm ? "#2A4A6A" : "#C5D8FF"
                                        Text { anchors.centerIn: parent; text: "Edit My Review"; font.pixelSize: 14; font.bold: true; color: "#1976D2" }
                                        MouseArea { anchors.fill: parent; onClicked: { reviewSubmitted = false; selectedRating = submittedRating } }
                                    }
                                }

                                // Not yet submitted — show rating UI
                                Column {
                                    visible: !reviewSubmitted
                                    width: parent.width - 32; spacing: 14
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "How was your experience?"
                                        font.pixelSize: 15; font.bold: true; color: thText
                                    }

                                    // Star row
                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                                        Repeater {
                                            model: 5
                                            delegate: Item {
                                                width: 40; height: 44

                                                Text {
                                                    id: starText
                                                    anchors.centerIn: parent
                                                    text: "★"
                                                    font.pixelSize: 36
                                                    color: index < selectedRating ? "#FFB300" : (dm ? "#444444" : "#DDDDDD")

                                                    Behavior on color { ColorAnimation { duration: 120 } }

                                                    // Scale bounce on select
                                                    property bool bouncing: false
                                                    scale: bouncing ? 1.3 : 1.0
                                                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        selectedRating = index + 1
                                                        starText.bouncing = true
                                                        starBounceReset.restart()
                                                    }
                                                }

                                                Timer {
                                                    id: starBounceReset
                                                    interval: 200; repeat: false
                                                    onTriggered: starText.bouncing = false
                                                }
                                            }
                                        }
                                    }

                                    // Rating label
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: starLabel(selectedRating)
                                        font.pixelSize: 14; font.bold: selectedRating > 0
                                        color: selectedRating > 0 ? "#FFB300" : thTextSub
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }

                                    // Quick-tag chips (show after star chosen)
                                    Column {
                                        visible: selectedRating > 0
                                        width: parent.width; spacing: 6

                                        Label { text: "What stood out?"; font.pixelSize: 12; color: thTextLabel }

                                        property var allTags: selectedRating >= 4
                                            ? ["Easy to use", "Fast pickup", "Great driver", "Safe ride", "Good value", "Clean vehicle"]
                                            : ["App crashed", "Long wait", "Route issue", "Poor support", "Payment issue", "Driver issue"]

                                        property var chosenTags: []

                                        Flow {
                                            width: parent.width; spacing: 8
                                            Repeater {
                                                model: selectedRating >= 4
                                                    ? ["Easy to use", "Fast pickup", "Great driver", "Safe ride", "Good value", "Clean vehicle"]
                                                    : ["App crashed", "Long wait", "Route issue", "Poor support", "Payment issue", "Driver issue"]
                                                delegate: Rectangle {
                                                    id: chipRect
                                                    property bool chosen: false
                                                    height: 30; radius: 15
                                                    width: chipLbl.implicitWidth + 20
                                                    color: chosen ? "#1976D2" : (dm ? "#2A2A2A" : "#F0F4FF")
                                                    border.color: chosen ? "#1565C0" : (dm ? "#444444" : "#C5D0F0")
                                                    Behavior on color { ColorAnimation { duration: 120 } }

                                                    Label {
                                                        id: chipLbl
                                                        anchors.centerIn: parent
                                                        text: modelData
                                                        font.pixelSize: 12
                                                        color: chosen ? "white" : thText
                                                        Behavior on color { ColorAnimation { duration: 120 } }
                                                    }
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        onClicked: chipRect.chosen = !chipRect.chosen
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Written review
                                    Column { width: parent.width; spacing: 4
                                        Label { text: "Write a review (optional)"; font.pixelSize: 12; color: thTextLabel }
                                        Rectangle {
                                            width: parent.width; height: 88; radius: 10
                                            color: thFieldBg; border.color: reviewArea.activeFocus ? "#1976D2" : thFieldBorder
                                            border.width: reviewArea.activeFocus ? 1.5 : 1
                                            TextArea {
                                                id: reviewArea
                                                anchors.fill: parent; anchors.margins: 10
                                                placeholderText: "Tell us what you love or what we can improve..."
                                                wrapMode: TextArea.Wrap; font.pixelSize: 13; color: thText
                                                background: Item {}
                                                onTextChanged: reviewText = text
                                            }
                                        }
                                    }

                                    // Character count
                                    Label {
                                        anchors.right: parent.right
                                        text: reviewText.length + " / 300"
                                        font.pixelSize: 10; color: reviewText.length > 280 ? "#E53935" : thTextSub
                                    }

                                    // Submit button
                                    Rectangle {
                                        width: parent.width; height: 48; radius: 12
                                        opacity: selectedRating > 0 ? 1.0 : 0.4
                                        gradient: Gradient { orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: "#1565C0" }
                                            GradientStop { position: 1.0; color: "#42A5F5" }
                                        }
                                        Behavior on opacity { NumberAnimation { duration: 200 } }

                                        Row { anchors.centerIn: parent; spacing: 8
                                            Text { text: "★"; font.pixelSize: 16; color: "#FFD600" }
                                            Text { text: "Submit Review"; font.pixelSize: 15; font.bold: true; color: "white" }
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            enabled: selectedRating > 0
                                            onClicked: {
                                                submittedRating = selectedRating
                                                reviewSubmitted = true
                                                thankYouVisible = true
                                                console.log("Review submitted — Rating:", submittedRating, "Text:", reviewText)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── LOGOUT ────────────────────────────────────────────────
                Rectangle {
                    x: 16; width: parent.width - 32; height: 50; radius: 14
                    color: dm ? "#2A1A1A" : "#FFF0F0"; border.color: dm ? "#4A2A2A" : "#FFCDD2"
                    Row { anchors.centerIn: parent; spacing: 10
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
