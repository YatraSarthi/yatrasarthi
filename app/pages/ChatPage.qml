import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var appStack
    property var appState

    property bool isTyping: false

    // ── Hide bottom bar while in chat ─────────────────────────────────────
    Component.onCompleted: {
        if (appState) appState.showBottomBar = false

        // Always clear old messages and start fresh for this ride
        appState.chatMessages = []

        var pickup = pickupShort()
        var msgs = []
        msgs.push({
            sender:  appState.driverName || "Sarthi",
            message: "Hello! I am " + (appState.driverName || "your Sarthi")
                     + ". I am on my way to pick you up from "
                     + pickup + ". I will be there in about "
                     + rideEta() + " minutes.",
            time: timeNow()
        })
        appState.chatMessages = msgs
        chatList.model = appState.chatMessages
    }

    Component.onDestruction: {
        if (appState) appState.showBottomBar = true
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    function timeNow() {
        var now  = new Date()
        var hh   = now.getHours()
        var mm   = now.getMinutes()
        var ampm = hh >= 12 ? "PM" : "AM"
        hh = hh % 12 || 12
        return hh + ":" + (mm < 10 ? "0" + mm : mm) + " " + ampm
    }

    function pickupShort() {
        var p = appState.pickupLocation || ""
        if (p === "") return "your location"
        return p.split(",")[0].trim()
    }

    function destShort() {
        var d = appState.destinationLocation || ""
        if (d === "") return "your destination"
        return d.split(",")[0].trim()
    }

    // ETA in minutes — selectedEta is already in minutes from the backend
    function rideEta() {
        var e = parseInt(appState.selectedEta)
        if (isNaN(e) || e <= 0) return "a few"
        // Guard against absurd values (selectedEta sometimes stores seconds)
        if (e > 300) return Math.round(e / 60)
        return e
    }

    // ── Smart local reply engine ──────────────────────────────────────────
    function smartReply(text) {
        var t       = text.toLowerCase()
        var pickup  = pickupShort()
        var dest    = destShort()
        var vehicle = appState.driverVehicleModel || "my vehicle"
        var name    = appState.driverName         || "Sarthi"
        var eta     = rideEta()

        if (t.indexOf("where") >= 0 || t.indexOf("location") >= 0
                || t.indexOf("reached") >= 0 || t.indexOf("far") >= 0)
            return "I am near " + pickup + " area. Should reach you in about " + eta + " minutes."

        if (t.indexOf("traffic") >= 0 || t.indexOf("jam") >= 0 || t.indexOf("stuck") >= 0)
            return "Yes, there is a bit of traffic near " + pickup + ". I will take a shorter route."

        if (t.indexOf("route") >= 0 || t.indexOf("way") >= 0 || t.indexOf("road") >= 0)
            return "I am taking the fastest route from " + pickup + " to " + dest + "."

        if (t.indexOf("eta") >= 0 || t.indexOf("time") >= 0
                || t.indexOf("long") >= 0 || t.indexOf("minutes") >= 0
                || t.indexOf("mins") >= 0 || t.indexOf("how much") >= 0
                || t.indexOf("howmuch") >= 0 || t.indexOf("how long") >= 0)
            return "I will be at " + pickup + " in approximately " + eta + " minutes."

        if (t.indexOf("otp") >= 0 || t.indexOf("password") >= 0 || t.indexOf("code") >= 0)
            return "Please share the OTP once I arrive at " + pickup + "."

        if (t.indexOf("destination") >= 0 || t.indexOf("drop") >= 0 || t.indexOf("going") >= 0)
            return "Yes, I am taking you to " + dest + ". The route looks clear from here."

        if (t.indexOf("wait") >= 0 || t.indexOf("parking") >= 0 || t.indexOf("stand") >= 0)
            return "I will wait near the main gate at " + pickup + ". Please come when ready."

        if (t.indexOf("cancel") >= 0)
            return "Please do not cancel. I am very close to " + pickup + " now."

        if (t.indexOf("hello") >= 0 || t.indexOf("hi") >= 0 || t.indexOf("hey") >= 0)
            return "Hello! I am " + name + ". I am on my way to " + pickup + "."

        if (t.indexOf("ok") >= 0 || t.indexOf("okay") >= 0
                || t.indexOf("alright") >= 0 || t.indexOf("fine") >= 0)
            return "Great. See you soon at " + pickup + "."

        if (t.indexOf("thank") >= 0)
            return "You are welcome! Happy to help."

        if (t.indexOf("safe") >= 0 || t.indexOf("careful") >= 0)
            return "Do not worry, I drive safely. You will reach " + dest + " comfortably."

        if (t.indexOf("ac") >= 0 || t.indexOf("air") >= 0)
            return "Yes, the AC is on in the " + vehicle + ". You will be comfortable."

        if (t.indexOf("luggage") >= 0 || t.indexOf("bag") >= 0 || t.indexOf("baggage") >= 0)
            return "No problem, there is space in the " + vehicle + " for your luggage."

        if (t.indexOf("gate") >= 0 || t.indexOf("entrance") >= 0 || t.indexOf("entry") >= 0)
            return "Which gate should I come to at " + pickup + "? I will come there."

        if (t.indexOf("number") >= 0 || t.indexOf("plate") >= 0 || t.indexOf("vehicle") >= 0)
            return "My vehicle is a " + vehicle + ". You can see the number on your booking."

        if (t.indexOf("name") >= 0 || t.indexOf("who") >= 0)
            return "I am " + name + ", your Sarthi for this ride."

        return "Okay, noted. I will be at " + pickup + " shortly."
    }

    function sendMessage() {
        var text = msgInput.text.trim()
        if (text === "" || isTyping) return

        var msgs = appState.chatMessages.slice()
        msgs.push({ sender: "You", message: text, time: timeNow() })
        appState.chatMessages = msgs
        chatList.model = appState.chatMessages
        chatList.positionViewAtEnd()
        msgInput.text = ""

        isTyping = true
        replyTimer.pendingReply = smartReply(text)
        replyTimer.start()
    }

    // ── Reply timer ───────────────────────────────────────────────────────
    Timer {
        id: replyTimer
        interval: 1600
        repeat: false
        property string pendingReply: ""
        onTriggered: {
            isTyping = false
            var msgs = appState.chatMessages.slice()
            msgs.push({
                sender:  appState.driverName || "Sarthi",
                message: pendingReply,
                time:    timeNow()
            })
            appState.chatMessages = msgs
            chatList.model = appState.chatMessages
            chatList.positionViewAtEnd()
        }
    }

    // ── Background ────────────────────────────────────────────────────────
    Rectangle { anchors.fill: parent; color: "#EBE5DC" }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header ────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 66
            color: "#1976D2"

            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 2; color: "#00000022"
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 12
                spacing: 10

                // Back button
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: "#33FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: "←"; color: "white"
                        font.pixelSize: 20; font.bold: true
                    }
                    MouseArea { anchors.fill: parent; onClicked: appStack.pop() }
                }

                // Driver avatar
                Rectangle {
                    width: 44; height: 44; radius: 22
                    color: "#1565C0"
                    border.color: "#ffffff44"; border.width: 2
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.fill: parent
                        source: (appState.driverPhoto !== undefined && appState.driverPhoto !== "")
                                ? "../../assets/drivers/" + appState.driverPhoto
                                : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: appState.driverPhoto !== undefined && appState.driverPhoto !== ""
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "👤"; font.pixelSize: 22
                        visible: appState.driverPhoto === undefined || appState.driverPhoto === ""
                    }
                }

                // Name + status
                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        text: (appState.driverName !== undefined && appState.driverName !== "")
                              ? appState.driverName : "Your Sarthi"
                        color: "white"; font.pixelSize: 16; font.bold: true
                    }
                    Label {
                        text: isTyping ? "typing..." : "On the way to you"
                        color: isTyping ? "#A5D6A7" : "#B3E5FC"
                        font.pixelSize: 12
                    }
                }
            }
        }

        // ── Message list ──────────────────────────────────────────────────
        ListView {
            id: chatList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4
            clip: true
            topMargin: 12
            bottomMargin: 8
            model: appState.chatMessages
            onCountChanged: Qt.callLater(positionViewAtEnd)

            delegate: Item {
                width: chatList.width
                height: bubbleCol.implicitHeight + 10

                property bool isMe: modelData.sender === "You"

                Column {
                    id: bubbleCol
                    anchors {
                        right:       isMe ? parent.right : undefined
                        left:        isMe ? undefined    : parent.left
                        rightMargin: 14
                        leftMargin:  14
                    }
                    spacing: 3

                    // Sender name — driver messages only
                    Label {
                        visible: !isMe
                        text: modelData.sender
                        font.pixelSize: 11; font.bold: true
                        color: "#1976D2"
                        leftPadding: 6
                    }

                    // Bubble
                    Rectangle {
                        width: Math.min(
                            msgLabel.implicitWidth + 32,
                            chatList.width * 0.78
                        )
                        height: msgLabel.implicitHeight + timeLabel.implicitHeight + 24
                        radius: 16
                        color: isMe ? "#DCF8C6" : "white"
                        border.color: isMe ? "#b5dfa0" : "#E0E0E0"
                        border.width: 1

                        // Tail
                        Rectangle {
                            width: 12; height: 12
                            color: isMe ? "#DCF8C6" : "white"
                            rotation: 45
                            anchors {
                                right:       isMe ? parent.right : undefined
                                left:        isMe ? undefined    : parent.left
                                rightMargin: isMe ? -5 : 0
                                leftMargin:  isMe ? 0  : -5
                                top: parent.top; topMargin: 12
                            }
                        }

                        // Message text
                        Text {
                            id: msgLabel
                            anchors {
                                left: parent.left; right: parent.right
                                top: parent.top
                                leftMargin: 14; rightMargin: 14; topMargin: 10
                            }
                            text: modelData.message
                            wrapMode: Text.WordWrap
                            font.pixelSize: 14
                            color: "#1A1A1A"
                            lineHeight: 1.35
                        }

                        // Timestamp bottom-right
                        Label {
                            id: timeLabel
                            anchors {
                                right: parent.right; bottom: parent.bottom
                                rightMargin: 10; bottomMargin: 5
                            }
                            text: modelData.time || ""
                            font.pixelSize: 10
                            color: "#999999"
                        }
                    }
                }
            }

            // ── Typing indicator ──────────────────────────────────────────
            footer: Item {
                width: chatList.width
                height: isTyping ? 52 : 0
                visible: isTyping

                Rectangle {
                    anchors {
                        left: parent.left; leftMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    width: 68; height: 36; radius: 18
                    color: "white"; border.color: "#E0E0E0"

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Repeater {
                            model: 3
                            Rectangle {
                                width: 8; height: 8; radius: 4
                                color: "#1976D2"
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    running: isTyping
                                    PauseAnimation  { duration: index * 200 }
                                    NumberAnimation { to: 1.0; duration: 300 }
                                    NumberAnimation { to: 0.3; duration: 300 }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Input bar ─────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: "#F5F5F5"

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1; color: "#D0D0D0"
            }

            Row {
                anchors {
                    fill: parent
                    leftMargin: 10; rightMargin: 10
                    topMargin: 10; bottomMargin: 10
                }
                spacing: 8

                // Input pill
                Rectangle {
                    width: parent.width - sendBtn.width - 8
                    height: 44; radius: 22
                    color: "white"
                    border.color: msgInput.activeFocus ? "#1976D2" : "#D0D0D0"
                    border.width: msgInput.activeFocus ? 2 : 1
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    TextInput {
                        id: msgInput
                        anchors {
                            left: parent.left; right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 16; rightMargin: 16
                        }
                        font.pixelSize: 14
                        color: "#1A1A1A"
                        clip: true
                        enabled: !isTyping

                        Text {
                            anchors.fill: parent
                            text: "Message your Sarthi..."
                            color: "#BBBBBB"; font.pixelSize: 14
                            visible: msgInput.text === ""
                            verticalAlignment: Text.AlignVCenter
                        }

                        Keys.onReturnPressed: sendMessage()
                    }
                }

                // Send button
                Rectangle {
                    id: sendBtn
                    width: 44; height: 44; radius: 22
                    color: (msgInput.text.trim() !== "" && !isTyping) ? "#1976D2" : "#B0BEC5"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "➤"; color: "white"; font.pixelSize: 18
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: sendMessage()
                    }
                }
            }
        }
    }
}