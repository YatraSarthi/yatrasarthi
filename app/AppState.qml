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

    property string selectedVehicle: ""
    property int selectedFare: 0
    property int selectedEta: 0
    property real selectedDistance: 0

    property int availableSeats: 0
    property int routeMatch: 0
    property real co2Saved: 0.0

    property bool showBottomBar: true
    property string preferredVehicle: ""
    property string quickAction: ""

    property var chatMessages: []

    property string userName: ""
    property string userPhone: ""
    property string userEmail: ""
    property bool isLoggedIn: false

    property string driverName: ""
    property string driverVehicle: ""
    property real driverRating: 0.0
    property string driverPhoto: ""

    property int driverRetryCount: 0
    property string lastDriverName: ""

    property bool darkMode: false

    function resetDriverSearch() {
        driverRetryCount = 0
        lastDriverName = ""
    }
}