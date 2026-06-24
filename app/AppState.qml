import QtQuick 2.12

QtObject {

    // ── Location ──────────────────────────────────────────────────────────
    property string pickupLocation: ""
    property string pickupFullAddress: ""
    property string destinationLocation: ""
    property string destinationFullAddress: ""
    property real pickupLat: 0
    property real pickupLon: 0
    property real destinationLat: 0
    property real destinationLon: 0
    property string activeSelection: ""

    // ── Selected ride ─────────────────────────────────────────────────────
    property string selectedVehicle: ""
    property int selectedFare: 0
    property int selectedEta: 0
    property real selectedDistance: 0

    // ── Carpool ───────────────────────────────────────────────────────────
    property int availableSeats: 0
    property int routeMatch: 0
    property real co2Saved: 0.0

    // ── Navigation ────────────────────────────────────────────────────────
    property bool showBottomBar: true
    property string preferredVehicle: ""
    property string quickAction: ""

    // ── Chat ──────────────────────────────────────────────────────────────
    property var chatMessages: []

    // ── User profile (set on sign-in / sign-up) ───────────────────────────
    property string userName: ""
    property string userPhone: ""
    property string userEmail: ""
    property bool isLoggedIn: false

    // ── Driver retry state ────────────────────────────────────────────────
    // Track how many times user has asked for a different driver this trip
    property int driverRetryCount: 0
    // Name of the last driver shown — so BookingPage can skip them
    property string lastDriverName: ""

    function resetDriverSearch() {
        driverRetryCount = 0
        lastDriverName   = ""
    }
}
