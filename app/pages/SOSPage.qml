import QtQuick 2.12
import QtQuick.Controls 2.12

Page {
    id: sosPage

    property var appStack
    property var appState

    property string statusMessage: ""
    property string contactsMessage: ""
    property string saveMessage: ""

    property bool editMode: false

    // ── Editable fields ────────────────────────────────────────
    property string contact1Name: ""
    property string contact1Phone: ""
    property string contact2Name: ""
    property string contact2Phone: ""
    property string bloodGroup: ""
    property string medicalNotes: ""

    title: "Emergency SOS"

    Component.onCompleted: { loadSosInfo() }

    // ── Load saved info ───────────────────────────────────────
    function loadSosInfo() {
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
                } catch (e) {
                    console.log("SOS Info Parse Error:", e)
                }
            }
        }
        xhr.open("GET", "http://127.0.0.1:8000/sos/info", true)
        xhr.send()
    }

    // ── Save edited info ───────────────────────────────────────
    function saveSosInfo() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    saveMessage = "Saved successfully"
                    editMode = false
                } else {
                    saveMessage = "Failed to save"
                }
            }
        }
        xhr.onerror = function() {
            saveMessage = "Unable to contact server"
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

    // ── Trigger SOS alert ──────────────────────────────────────
    function sendSOS() {
        console.log("sendSOS() called")
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            console.log("SOS readyState:", xhr.readyState, "status:", xhr.status)
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText)
                        statusMessage = data.status
                        contactsMessage = data.contacts ? data.contacts.join("\n") : ""
                    } catch (e) {
                        console.log("SOS JSON Error:", e)
                        statusMessage = "Invalid server response"
                        contactsMessage = ""
                    }
                } else {
                    statusMessage = "Failed to send SOS"
                    contactsMessage = ""
                }
            }
        }
        xhr.onerror = function() {
            console.log("SOS Request Failed")
            statusMessage = "Unable to contact server"
            contactsMessage = ""
        }
        xhr.open("GET", "http://127.0.0.1:8000/sos", true)
        xhr.send()
    }

    Rectangle { anchors.fill: parent; color: "#F4F6F9" }

    ScrollView {
        anchors.fill: parent
        contentWidth: width
        clip: true

        Column {
            width: parent.width
            spacing: 0

            // ── Header ────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 65; color: "#E53935"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    spacing: 4

                    Button {
                        width: 44; height: 44
                        anchors.verticalCenter: parent.verticalCenter
                        flat: true
                        contentItem: Text {
                            text: "←"; font.pixelSize: 22; color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle { color: "transparent" }
                        onClicked: appStack.pop()
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Emergency SOS"; font.pixelSize: 20
                        font.bold: true; color: "white"
                    }
                }
            }

            Column {
                width: parent.width; spacing: 16
                Item { width: 1; height: 6 }

                // ── Panic button card ──────────────────────────
                Column {
                    x: 16; width: parent.width - 32
                    spacing: 14

                    Column {
                        width: parent.width
                        spacing: 14

                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: "../../assets/icons/sos.png"
                            width: 64; height: 64
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                        Label {
                            width: parent.width
                            text: "Press the button below to notify your emergency contacts"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            font.pixelSize: 14
                            lineHeight: 1.3
                            color: "#5A5A5A"
                        }
                    }

                    Button {
                        width: parent.width; height: 52
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: sendSOS()
                        background: Rectangle { color: "#E53935"; radius: 12 }
                        contentItem: Text {
                            text: "Send SOS"; font.pixelSize: 16
                            font.bold: true; color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Label {
                        text: statusMessage; color: "#E53935"
                        wrapMode: Text.WordWrap; width: parent.width
                        visible: statusMessage !== ""
                    }
                    Label {
                        text: contactsMessage === "" ? "" : "Contacts notified:\n" + contactsMessage
                        wrapMode: Text.WordWrap; width: parent.width
                        visible: contactsMessage !== ""
                    }
                }

                // Divider
                Rectangle {
                    x: 16; width: parent.width - 32
                    height: 1; color: "#E0E0E0"
                }

                // ── Emergency info card ─────────────────────────
                Rectangle {
                    x: 16; width: parent.width - 32
                    radius: 14; color: "white"
                    border.color: "#E0E0E0"
                    height: infoColumn.height + 28

                    Column {
                        id: infoColumn
                        x: 14; y: 14
                        width: parent.width - 28
                        spacing: 14

                        Row {
                            width: parent.width
                            Label {
                                text: "Emergency Info"
                                font.bold: true; font.pixelSize: 15; color: "#111"
                                width: parent.width - editBtn.width
                            }
                            Button {
                                id: editBtn
                                text: editMode ? "Cancel" : "Edit"
                                flat: true
                                onClicked: {
                                    if (editMode) {
                                        loadSosInfo()
                                        saveMessage = ""
                                    }
                                    editMode = !editMode
                                }
                            }
                        }

                        // Contact 1
                        Label { text: "Emergency Contact 1"; font.pixelSize: 12; color: "#888" }
                        TextField {
                            id: contact1NameField
                            width: parent.width
                            placeholderText: "Name"
                            readOnly: !editMode
                            Component.onCompleted: text = contact1Name
                            onTextChanged: contact1Name = text
                            Connections {
                                target: sosPage
                                function onEditModeChanged() {
                                    contact1NameField.text = contact1Name
                                }
                            }
                        }
                        TextField {
                            id: contact1PhoneField
                            width: parent.width
                            placeholderText: "Phone number"
                            readOnly: !editMode
                            inputMethodHints: Qt.ImhDialableCharactersOnly
                            Component.onCompleted: text = contact1Phone
                            onTextChanged: contact1Phone = text
                            Connections {
                                target: sosPage
                                function onEditModeChanged() {
                                    contact1PhoneField.text = contact1Phone
                                }
                            }
                        }

                        // Contact 2
                        Label { text: "Emergency Contact 2"; font.pixelSize: 12; color: "#888" }
                        TextField {
                            id: contact2NameField
                            width: parent.width
                            placeholderText: "Name"
                            readOnly: !editMode
                            Component.onCompleted: text = contact2Name
                            onTextChanged: contact2Name = text
                            Connections {
                                target: sosPage
                                function onEditModeChanged() {
                                    contact2NameField.text = contact2Name
                                }
                            }
                        }
                        TextField {
                            id: contact2PhoneField
                            width: parent.width
                            placeholderText: "Phone number"
                            readOnly: !editMode
                            inputMethodHints: Qt.ImhDialableCharactersOnly
                            Component.onCompleted: text = contact2Phone
                            onTextChanged: contact2Phone = text
                            Connections {
                                target: sosPage
                                function onEditModeChanged() {
                                    contact2PhoneField.text = contact2Phone
                                }
                            }
                        }

                        // Blood group
                        Label { text: "Blood Group"; font.pixelSize: 12; color: "#888" }
                        TextField {
                            id: bloodGroupField
                            width: parent.width
                            placeholderText: "e.g. O+"
                            readOnly: !editMode
                            Component.onCompleted: text = bloodGroup
                            onTextChanged: bloodGroup = text
                            Connections {
                                target: sosPage
                                function onEditModeChanged() {
                                    bloodGroupField.text = bloodGroup
                                }
                            }
                        }

                        // Medical notes
                        Label { text: "Medical Notes"; font.pixelSize: 12; color: "#888" }
                        TextArea {
                            id: medicalNotesField
                            width: parent.width
                            placeholderText: "Allergies, conditions, medications..."
                            readOnly: !editMode
                            wrapMode: TextArea.Wrap
                            Component.onCompleted: text = medicalNotes
                            onTextChanged: medicalNotes = text
                            Connections {
                                target: sosPage
                                function onEditModeChanged() {
                                    medicalNotesField.text = medicalNotes
                                }
                            }
                        }

                        Button {
                            width: parent.width; height: 44
                            visible: editMode
                            onClicked: saveSosInfo()
                            background: Rectangle { color: "#1976D2"; radius: 10 }
                            contentItem: Text {
                                text: "Save"; font.pixelSize: 14
                                font.bold: true; color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Label {
                            text: saveMessage
                            color: saveMessage === "Saved successfully" ? "#388E3C" : "#E53935"
                            visible: saveMessage !== ""
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }
}
