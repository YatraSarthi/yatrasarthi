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

    /* Carpool */
    property int availableSeats: 0
    property int routeMatch: 0
    property real co2Saved: 0.0

    /* Navigation */
    property bool showBottomBar: true

    /* Services page preferred vehicle (set from ServicesPage grid) */
    property string preferredVehicle: ""

    /* Pending quick-action from HomePage Quick Actions
       ("sos", "queue", or "" for none) — consumed by ServicesPage
       once it has acted on it */
    property string quickAction: ""
}