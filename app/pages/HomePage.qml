import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    property var stack

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 15

        Label {
            text: "YatraSarthi"
            font.pixelSize: 24
        }

        TextField {
            placeholderText: "Pickup Location"
            Layout.preferredWidth: 250
        }

        TextField {
            placeholderText: "Destination"
            Layout.preferredWidth: 250
        }

       Button {
    text: "Find Ride"

    onClicked: {
        console.log("Button clicked")
        stack.push(Qt.resolvedUrl("ResultsPage.qml"))
    }
}
    }
}