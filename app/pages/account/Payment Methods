import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: paymentPage
    background: Rectangle { color: "#F5F5F5" }

    header: Rectangle {
        width: parent.width
        height: 56
        color: "#2196F3"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16
            ToolButton {
                contentItem: Text { text: "‹"; color: "white"; font.pixelSize: 28
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: stackView.pop()
            }
            Text { text: "Payment Methods"; color: "white"; font.pixelSize: 18; font.bold: true; Layout.fillWidth: true }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width

        Column {
            width: paymentPage.width
            spacing: 0

            // Wallet balance banner
            Rectangle {
                width: parent.width
                height: 100
                color: "#1565C0"
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "YatraWallet Balance"; color: "#90CAF9"; font.pixelSize: 13; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "₹ 0.00"; color: "white"; font.pixelSize: 30; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 100; height: 28; radius: 14; color: "#2196F3"
                        Text { anchors.centerIn: parent; text: "+ Add Money"; color: "white"; font.pixelSize: 13 }
                        MouseArea { anchors.fill: parent; onClicked: {} }
                    }
                }
            }

            Item { width: 1; height: 16 }

            // UPI Section
            Text { text: "  UPI"; color: "#757575"; font.pixelSize: 12; font.bold: true
                leftPadding: 16; topPadding: 4; bottomPadding: 4 }

            Rectangle {
                width: parent.width - 32; x: 16
                height: upiCol.implicitHeight
                radius: 12; color: "white"
                Column {
                    id: upiCol
                    width: parent.width
                    Repeater {
                        model: [
                            { icon: "🏦", name: "Add UPI ID", sub: "Link your bank UPI ID" },
                            { icon: "🟢", name: "Google Pay", sub: "Tap to link" },
                            { icon: "💙", name: "PhonePe", sub: "Tap to link" },
                            { icon: "🔵", name: "Paytm", sub: "Tap to link" }
                        ]
                        delegate: PaymentRowItem {
                            width: upiCol.width
                            iconStr: modelData.icon
                            nameStr: modelData.name
                            subStr: modelData.sub
                            showDivider: index < 3
                        }
                    }
                }
            }

            Item { width: 1; height: 12 }

            // Cards Section
            Text { text: "  CARDS"; color: "#757575"; font.pixelSize: 12; font.bold: true
                leftPadding: 16; topPadding: 4; bottomPadding: 4 }

            Rectangle {
                width: parent.width - 32; x: 16
                height: cardCol.implicitHeight
                radius: 12; color: "white"
                Column {
                    id: cardCol
                    width: parent.width
                    Repeater {
                        model: [
                            { icon: "💳", name: "Add Credit Card", sub: "Visa, Mastercard, RuPay" },
                            { icon: "💳", name: "Add Debit Card", sub: "All major banks" }
                        ]
                        delegate: PaymentRowItem {
                            width: cardCol.width
                            iconStr: modelData.icon
                            nameStr: modelData.name
                            subStr: modelData.sub
                            showDivider: index < 1
                        }
                    }
                }
            }

            Item { width: 1; height: 12 }

            // Net Banking
            Text { text: "  NET BANKING"; color: "#757575"; font.pixelSize: 12; font.bold: true
                leftPadding: 16; topPadding: 4; bottomPadding: 4 }

            Rectangle {
                width: parent.width - 32; x: 16
                height: nbCol.implicitHeight
                radius: 12; color: "white"
                Column {
                    id: nbCol
                    width: parent.width
                    PaymentRowItem {
                        width: nbCol.width
                        iconStr: "🏧"
                        nameStr: "Add Bank Account"
                        subStr: "All major banks supported"
                        showDivider: false
                    }
                }
            }

            Item { width: 1; height: 32 }
        }
    }

    // Reusable row component
    component PaymentRowItem: Rectangle {
        property string iconStr: ""
        property string nameStr: ""
        property string subStr: ""
        property bool showDivider: true
        height: 60
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Text { text: iconStr; font.pixelSize: 22 }

            Column {
                Layout.fillWidth: true
                spacing: 2
                Text { text: nameStr; font.pixelSize: 15; color: "#212121" }
                Text { text: subStr; font.pixelSize: 12; color: "#9E9E9E" }
            }

            Text { text: "›"; font.pixelSize: 22; color: "#BDBDBD" }
        }

        Rectangle {
            visible: showDivider
            anchors.bottom: parent.bottom
            x: 56; width: parent.width - 56; height: 1
            color: "#F0F0F0"
        }

        MouseArea { anchors.fill: parent; onClicked: {} }
    }
}
