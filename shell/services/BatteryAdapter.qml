import QtQuick
import Quickshell.Services.UPower

QtObject {
    id: root

    readonly property var batteryDevice: {
        if (UPower.devices && UPower.devices.values) {
            var list = UPower.devices.values
            for (var i = 0; i < list.length; ++i) {
                if (list[i] && list[i].isLaptopBattery) return list[i]
            }
        }
        if (UPower.displayDevice && UPower.displayDevice.isLaptopBattery) {
            return UPower.displayDevice
        }
        return null
    }

    readonly property bool available: batteryDevice !== null
    property bool loading: false
    property string errorMessage: ""

    readonly property int percentage: batteryDevice ? Math.max(0, Math.min(100, Math.round(batteryDevice.percentage * 100))) : 0
    readonly property string stateLabel: {
        if (!batteryDevice) return "AC DIRECT"
        var raw = UPowerDeviceState.toString(batteryDevice.state)
        return raw ? raw.toUpperCase() : "UNKNOWN"
    }
    readonly property bool charging: batteryDevice !== null && (
        stateLabel.indexOf("CHARGING") === 0 || stateLabel === "PENDING_CHARGE"
    )
    readonly property bool pluggedIn: batteryDevice === null || charging || stateLabel === "FULLY_CHARGED"

    readonly property string timeRemaining: {
        if (!batteryDevice) return ""
        var secs = charging ? (batteryDevice.timeToFull || 0) : (batteryDevice.timeToEmpty || 0)
        if (!secs || secs <= 0) return ""
        var hrs = Math.floor(secs / 3600)
        var mins = Math.floor((secs % 3600) / 60)
        return (hrs < 10 ? "0" : "") + hrs + "h " + (mins < 10 ? "0" : "") + mins + "m"
    }

    readonly property string powerProfile: {
        if (!PowerProfiles) return "balanced"
        if (PowerProfiles.profile === PowerProfile.PowerSaver) return "power-saver"
        if (PowerProfiles.profile === PowerProfile.Performance) return "performance"
        return "balanced"
    }

    function cyclePowerProfile() {
        if (powerProfile === "balanced") {
            setPowerProfile(PowerProfiles.hasPerformanceProfile ? "performance" : "power-saver")
        } else if (powerProfile === "performance") {
            setPowerProfile("power-saver")
        } else {
            setPowerProfile("balanced")
        }
    }

    function setPowerProfile(profile) {
        if (!PowerProfiles) return
        if (profile === "power-saver") PowerProfiles.profile = PowerProfile.PowerSaver
        else if (profile === "performance" && PowerProfiles.hasPerformanceProfile) PowerProfiles.profile = PowerProfile.Performance
        else if (profile === "balanced") PowerProfiles.profile = PowerProfile.Balanced
    }
}

