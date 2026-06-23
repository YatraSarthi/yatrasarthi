import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var appStack
    property var appState

    ColumnLayout {

        anchors.fill: parent
        spacing: 0

        // Header
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

                    text: "Chat with Sarthi"

                    color: "white"

                    font.pixelSize: 22
                    font.bold: true

                    anchors.verticalCenter:
                        parent.verticalCenter
                }
            }
        }

        // Messages
        ListView {

            id: chatList

            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 8
            clip: true

            model: appState.chatMessages

            delegate: Item {

                width: chatList.width
                height: bubble.height + 12

                Rectangle {

                    id: bubble

                    width: Math.max(
           180,
           Math.min(
               chatText.paintedWidth + 40,
               chatList.width * 0.80
           )
       )

                    height:
                        chatText.paintedHeight + 26

                    radius: 14

                    color:
                        modelData.sender === "You"
                        ? "#DCF8C6"
                        : "#F0F0F0"

                    anchors {

                        right:
                            modelData.sender === "You"
                            ? parent.right
                            : undefined

                        left:
                            modelData.sender === "You"
                            ? undefined
                            : parent.left

                        rightMargin: 12
                        leftMargin: 12
                        top: parent.top
                    }

                    Text {

                        id: chatText

                        anchors.fill: parent
                        anchors.margins: 12

                        wrapMode: Text.WordWrap

                        text:
                            modelData.sender
                            + ": "
                            + modelData.message

                        font.pixelSize: 14

                        color: "black"
                    }
                }
            }
        }

        // Input Area
        Rectangle {

            Layout.fillWidth: true
            height: 60

            color: "#F5F5F5"

            border.color: "#DDDDDD"

            RowLayout {

                anchors.fill: parent
                anchors.margins: 8

                spacing: 8

                TextField {

                    id: msgInput

                    Layout.fillWidth: true

                    placeholderText:
                        "Type message..."
                }

                Button {

                    text: "Send"

                    onClicked: {

                        if (
                            msgInput.text === ""
                        )
                            return

                        // User message
                        appState.chatMessages.push({

                            sender: "You",

                            message:
                                msgInput.text
                        })

                        chatList.model =
                            appState.chatMessages

                        chatList.positionViewAtEnd()

                        var userText =
                            msgInput.text

                        msgInput.text = ""

                        // Fake driver reply
                        replyTimer.replyTo =
                            userText

                        replyTimer.start()
                    }
                }
            }
        }
    }

    Timer {

        id: replyTimer

        interval: 2000

        repeat: false

        property string replyTo: ""

        onTriggered: {

            var reply = ""

            if (
                replyTo.toLowerCase().indexOf("gate") >= 0
            ) {

                reply =
                    "I am on the way. There is a little traffic near REVA University."

            } else if (
                replyTo.toLowerCase().indexOf("where") >= 0
            ) {

                reply =
                    "I am about 2 minutes away."

            } else if (
                replyTo.toLowerCase().indexOf("otp") >= 0
            ) {

                reply =
                    "Please share the OTP once I arrive."

            } else if (
                replyTo.toLowerCase().indexOf("hello") >= 0
            ) {

                reply =
                    "Hello. I am your Sarthi. I am on the way."

            } else {

                reply =
                    "Okay. I have received your message."
            }

            appState.chatMessages.push({

                sender: "Sarthi",

                message: reply
            })

            chatList.model =
                appState.chatMessages

            chatList.positionViewAtEnd()
        }
    }

    Component.onCompleted: {

    if (appState.chatMessages.length === 0) {

        appState.chatMessages.push({

            sender: "Sarthi",

            message:
                "Hello. I am your Sarthi. I am on the way."
        })
    }
}}