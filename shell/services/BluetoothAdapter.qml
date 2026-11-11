import QtQuick
import Quickshell.Bluetooth

QtObject {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    property bool loading: false
    property string errorMessage: available ? "" : "BLUETOOTH ADAPTER ABSENT"

    readonly property bool powered: adapter ? (adapter.powered === true) : false

    readonly property var devices: {
        var out = []
        if (!adapter || !adapter.devices || !adapter.devices.values) return out
        var list = adapter.devices.values
        for (var i = 0; i < list.length; ++i) {
            var d = list[i]
            if (!d) continue
            out.push({
                address: String(d.address || ""),
                name: String(d.deviceName || d.name || d.address || "BT Device"),
                connected: d.connected === true,
                battery: d.batteryAvailable ? Math.round(d.battery * 100) : -1
            })
        }
        return out
    }

    readonly property string connectedDevice: {
        for (var i = 0; i < devices.length; ++i) {
            if (devices[i].connected) return devices[i].name
        }
        return ""
    }

    function togglePower() {
        if (!available) return
        adapter.powered = !adapter.powered
    }

    function toggleDevice(address) {
        if (!available || !powered || !adapter.devices || !adapter.devices.values) return
        var list = adapter.devices.values
        for (var i = 0; i < list.length; ++i) {
            var d = list[i]
            if (d && String(d.address) === String(address)) {
                d.connected = !d.connected
                return
            }
        }
    }
}

