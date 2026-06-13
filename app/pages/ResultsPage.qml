import QtQuick 2.12
import QtQuick.Controls 2.12

Page {

    header: ToolBar {
        Label {
            anchors.centerIn: parent
            text: "Available Rides"
        }
    }

    ListView {
        anchors.fill: parent

        model: [
            {
                "vehicle": "Auto",
                "fare": "₹120",
                "eta": "4 min"
            },
            {
                "vehicle": "Cab",
                "fare": "₹180",
                "eta": "7 min"
            },
            {
                "vehicle": "Bike",
                "fare": "₹80",
                "eta": "2 min"
            }
        ]

        delegate: ItemDelegate {

            width: parent.width

            text: modelData.vehicle
                  + " • "
                  + modelData.fare
                  + " • ETA "
                  + modelData.eta

            onClicked: {
                console.log(modelData.vehicle + " selected")
            }
        }
    }
}