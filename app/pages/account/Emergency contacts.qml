import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: emergencyPage
    background: Rectangle { color: "#F5F5F5" }

    header: Rectangle {
        width: parent.width; height: 56; color: "#2196F3"
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 16
            ToolButton {
                contentItem: Text { text: "‹"; color: "white"; font.pixelSize: 28
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: stackView.pop()
            }
            Text { text: "Emergency Contacts"; color: "white"; font.pixelSize: 18; font.bold: true; Layout.fillWidth: true }
        }
    }

    ListModel {
        id: contactsModel
        // Empty by default
    }

    Column {
        width: parent.width
        spacing: 0

        // Info banner
        Rectangle {
            width: parent.width; height: 72; color: "#E3F2FD"
            RowLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 12
                Text { text: "🛡"; font.pixelSize: 28 }
                Text {
                    Layout.fillWidth: true
                    text: "Your emergency contacts will be notified with your live ride location when you trigger SOS."
                    color: "#1565C0"; font.pixelSize: 13; wrapMode: Text.Wrap
                }
            }
        }

        Item { width: 1; height: 16 }

        // Contacts list
        Rectangle {
            width: parent.width - 32; x: 16
            height: contactsModel.count === 0 ? emptyBox.implicitHeight + 32 : contactsModel.count * 72
            radius: 12; color: "white"

            Column {
                id: emptyBox
                visible: contactsModel.count === 0
                anchors.centerIn: parent
                spacing: 8
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "👤"; font.pixelSize: 40 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "No emergency contacts added"; color: "#9E9E9E"; font.pixelSize: 14 }
            }

            Repeater {
                model: contactsModel
                delegate: Rectangle {
                    width: parent.width; height: 72; color: "transparent"
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 16; spacing: 12
                        Rectangle {
                            width: 44; height: 44; radius: 22; color: "#E3F2FD"
                            Text { anchors.centerIn: parent; text: name.charAt(0); font.pixelSize: 18; color: "#2196F3"; font.bold: true }
                        }
                        Column {
                            Layout.fillWidth: true; spacing: 2
                            Text { text: name; font.pixelSize: 15; color: "#212121" }
                            Text { text: phone; font.pixelSize: 13; color: "#757575" }
                        }
                        Text { text: "✕"; font.pixelSize: 18; color: "#BDBDBD"
                            MouseArea { anchors.fill: parent; onClicked: contactsModel.remove(index) }
                        }
                    }
                }
            }
        }

        Item { width: 1; height: 16 }

        // Add contact button
        Rectangle {
            width: parent.width - 32; x: 16; height: 52; radius: 12
            color: contactsModel.count >= 5 ? "#E0E0E0" : "#2196F3"
            Text {
                anchors.centerIn: parent
                text: contactsModel.count >= 5 ? "Maximum 5 contacts added" : "+ Add Emergency Contact"
                color: "white"; font.pixelSize: 15; font.bold: true
            }
            MouseArea {
                anchors.fill: parent
                enabled: contactsModel.count < 5
                onClicked: addDialog.open()
            }
        }

        Item { width: 1; height: 24 }

        // SOS instructions
        Rectangle {
            width: parent.width - 32; x: 16; height: sosCol.implicitHeight + 32; radius: 12; color: "white"
            Column {
                id: sosCol
                width: parent.width - 32; x: 16; y: 16; spacing: 12
                Text { text: "How SOS works"; font.pixelSize: 15; font.bold: true; color: "#212121" }
                Repeater {
                    model: [
                        "Hold the SOS button for 3 seconds during a ride",
                        "Your live location is shared with emergency contacts",
                        "Local emergency services may be alerted",
                        "Your ride details are captured automatically"
                    ]
                    delegate: RowLayout {
                        width: sosCol.width; spacing: 8
                        Text { text: (index + 1) + "."; color: "#F44336"; font.pixelSize: 14; font.bold: true }
                        Text { Layout.fillWidth: true; text: modelData; color: "#616161"; font.pixelSize: 13; wrapMode: Text.Wrap }
                    }
                }
            }
        }
    }

    // Add contact dialog
    Dialog {
        id: addDialog
        title: "Add Emergency Contact"
        anchors.centerIn: parent
        width: parent.width - 48
        modal: true

        Column {
            width: parent.width; spacing: 16
            TextField { id: nameField; width: parent.width; placeholderText: "Contact Name" }
            TextField { id: phoneField; width: parent.width; placeholderText: "+91 Phone Number"; inputMethodHints: Qt.ImhDialableCharactersOnly }
        }

        footer: DialogButtonBox {
            Button {
                text: "Add"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                onClicked: {
                    if (nameField.text !== "" && phoneField.text !== "") {
                        contactsModel.append({ "name": nameField.text, "phone": phoneField.text })
                        nameField.text = ""
                        phoneField.text = ""
                        addDialog.close()
                    }
                }
            }
            Button {
                text: "Cancel"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: addDialog.close()
            }
        }
    }
}
