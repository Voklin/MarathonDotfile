import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property int percentage: 82
    property bool charging: false
    property bool pluggedIn: false
    property string stateLabel: "DISCHARGING"
    property string timeRemaining: "04h 18m"
    property string powerProfile: "balanced"

    function cyclePowerProfile() {
        if (!available) return
        if (powerProfile === "balanced") powerProfile = "performance"
        else if (powerProfile === "performance") powerProfile = "power-saver"
        else powerProfile = "balanced"
    }

    function setPowerProfile(profile) {
        if (!available) return
        powerProfile = profile
    }
}

