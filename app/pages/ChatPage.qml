import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var appStack
    property var appState

    ColumnLayout {

        anchors.fill: parent

        Rectangle {

            Layout.fillWidth: true
            height: 60

            color: "#1976D2"

            Row {

                anchors.fill: parent
                anchors.margins: 10

                spacing: 10

                Button {

                    text: "←"

                    onClicked: {
                        appStack.pop()
                    }
                }

                Label {

                    text: "Chat with Driver"

                    color: "white"

                    font.pixelSize: 20
                    font.bold: true

                    anchors.verticalCenter:
                        parent.verticalCenter
                }
            }
        }

        ListView {

            id: chatList

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: appState.chatMessages

            delegate: Rectangle {

                width: chatList.width

                height: 60

                color:
                    modelData.sender === "You"
                    ? "#DCF8C6"
                    : "#F0F0F0"

                radius: 10

                Text {

                    anchors.centerIn: parent

                    text:
                        modelData.sender
                        + ": "
                        + modelData.message
                }
            }
        }

        RowLayout {

            Layout.fillWidth: true

            TextField {

                id: msgInput

                Layout.fillWidth: true

                placeholderText:
                    "Type message..."
            }

            Button {

                text: "Send"

                onClicked: {

                    if (msgInput.text === "")
                        return

                    appState.chatMessages.push({
                        sender: "You",
                        message: msgInput.text
                    })

                    chatList.model =
                        appState.chatMessages

                    msgInput.text = ""
                }
            }
        }
    }
}