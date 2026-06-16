import QtQuick 2.12

QtObject {

    property string pickupLocation: ""
    property string pickupFullAddress: ""

    property string destinationLocation: ""
    property string destinationFullAddress: ""

    property real pickupLat: 0
    property real pickupLon: 0

    property real destinationLat: 0
    property real destinationLon: 0

    property string activeSelection: ""

    /* Selected Ride */

    property string selectedVehicle: ""
    property int selectedFare: 0
    property int selectedEta: 0
    property real selectedDistance: 0
}