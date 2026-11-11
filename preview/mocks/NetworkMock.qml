import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property bool connected: true
    property string connectionType: "wifi"
    property string ssid: "TAU-CETI-5G"
    property string interfaceName: "wlan0"
    property int signalStrength: 86
    property bool wifiEnabled: true
    property string ipAddress: "10.42.8.19"
    property var networks: [
        { ssid: "TAU-CETI-5G", signalStrength: 86, secured: true, connected: true },
        { ssid: "MARATHON-UPLINK", signalStrength: 68, secured: true, connected: false },
        { ssid: "LAB-OPEN-NET", signalStrength: 41, secured: false, connected: false }
    ]

    function openManager() { errorMessage = "PREVIEW: EXTERNAL SETTINGS MANAGER" }

    function toggleWifi() {
        if (!available) return
        wifiEnabled = !wifiEnabled
        if (!wifiEnabled) {
            connected = false
            connectionType = "offline"
            ssid = ""
            signalStrength = 0
        } else {
            connectNetwork("TAU-CETI-5G")
        }
    }

    function connectNetwork(targetSsid) {
        if (!available || !wifiEnabled) return
        var next = []
        for (var i = 0; i < networks.length; ++i) {
            var n = networks[i]
            var isTarget = (n.ssid === targetSsid)
            if (isTarget) {
                connected = true
                connectionType = "wifi"
                ssid = n.ssid
                signalStrength = n.signalStrength
            }
            next.push({ ssid: n.ssid, signalStrength: n.signalStrength, secured: n.secured, connected: isTarget })
        }
        networks = next
    }

    function disconnect() {
        if (!available) return
        connected = false
        connectionType = "offline"
        ssid = ""
        signalStrength = 0
    }
}

