import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property bool powered: true
    property string connectedDevice: "MX-TACTICAL MOUSE"
    property var devices: [
        { address: "AA:11:22:33:44:01", name: "MX-TACTICAL MOUSE", connected: true, battery: 74 },
        { address: "AA:11:22:33:44:02", name: "ATH-M50xBT2", connected: false, battery: 90 },
        { address: "AA:11:22:33:44:03", name: "KEYCHRON-K3-PRO", connected: false, battery: 55 }
    ]

    function openManager() { errorMessage = "PREVIEW: EXTERNAL SETTINGS MANAGER" }

    function togglePower() {
        if (!available) return
        powered = !powered
        if (!powered) {
            connectedDevice = ""
            var next = []
            for (var i = 0; i < devices.length; ++i) {
                var d = devices[i]
                next.push({ address: d.address, name: d.name, connected: false, battery: d.battery })
            }
            devices = next
        }
    }

    function toggleDevice(address) {
        if (!available || !powered) return
        var next = []
        var activeName = ""
        for (var i = 0; i < devices.length; ++i) {
            var d = devices[i]
            var conn = (d.address === address) ? !d.connected : d.connected
            if (conn && activeName === "") activeName = d.name
            next.push({ address: d.address, name: d.name, connected: conn, battery: d.battery })
        }
        devices = next
        connectedDevice = activeName
    }
}

