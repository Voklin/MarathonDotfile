import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool available: false
    property bool loading: true
    property string errorMessage: ""
    property bool connected: false
    property string connectionType: "offline"
    property string ssid: ""
    property string interfaceName: ""
    property int signalStrength: 0
    property bool wifiEnabled: false
    property string ipAddress: ""
    property var networks: []

    property Process monitorProc: Process {
        id: nmMonitor
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: function(_line) {
                root.refreshState()
            }
        }
        onExited: function(code, _status) {
            if (code !== 0 && !statusProc.running) {
                root.loading = false
            }
        }
    }

    property Process radioProc: Process {
        id: nmRadio
        command: ["nmcli", "radio", "wifi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var out = (text || "").trim().toLowerCase()
                if (out === "enabled" || out === "disabled") {
                    root.wifiEnabled = (out === "enabled")
                }
            }
        }
        onExited: function(code, _status) {
            if (code !== 0) {
                root.wifiEnabled = false
            }
        }
    }

    property Process statusProc: Process {
        id: nmStatus
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (text || "").trim().split("\n")
                var foundWifi = false
                var foundEth = false
                for (var i = 0; i < lines.length; ++i) {
                    var parts = lines[i].split(":")
                    if (parts.length < 4) continue
                    var dev = parts[0]
                    var dtype = parts[1]
                    var state = parts[2]
                    var conn = parts.slice(3).join(":")
                    if (state === "connected" && dtype === "ethernet") {
                        foundEth = true
                        root.connected = true
                        root.connectionType = "ethernet"
                        root.interfaceName = dev
                        root.ssid = conn || dev
                        root.signalStrength = 100
                        root.errorMessage = ""
                        break
                    }
                    if (state === "connected" && dtype === "wifi") {
                        foundWifi = true
                        root.connected = true
                        root.connectionType = "wifi"
                        root.interfaceName = dev
                        root.ssid = conn
                        root.errorMessage = ""
                    }
                }
                if (!foundEth && !foundWifi) {
                    root.connected = false
                    root.connectionType = "offline"
                    root.ssid = ""
                    root.interfaceName = ""
                    root.signalStrength = 0
                }
            }
        }
        onExited: function(code, _status) {
            root.loading = false
            if (code === 0) {
                root.available = true
                wifiListProc.running = true
            } else {
                root.available = false
                root.errorMessage = "NETWORKMANAGER UNAVAILABLE (EXIT " + code + ")"
            }
        }
    }

    property Process wifiListProc: Process {
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (text || "").trim().split("\n")
                var list = []
                var seen = {}
                for (var i = 0; i < lines.length; ++i) {
                    if (!lines[i]) continue
                    var parts = lines[i].split(":")
                    if (parts.length < 4) continue
                    var inUse = (parts[0] === "*")
                    var sname = parts[1]
                    if (!sname || seen[sname]) continue
                    seen[sname] = true
                    var sig = parseInt(parts[2], 10)
                    if (isNaN(sig)) sig = 0
                    var sec = parts[3] !== "" && parts[3] !== "--"
                    if (inUse) {
                        root.signalStrength = sig
                        root.ssid = sname
                    }
                    list.push({
                        ssid: sname,
                        signalStrength: sig,
                        secured: sec,
                        connected: inUse
                    })
                }
                root.networks = list
            }
        }
    }

    property Process actionProc: Process {
        running: false
        onExited: function(code, _status) {
            actionTimeout.stop()
            if (code !== 0) {
                root.errorMessage = "NETWORK CMD FAILED (EXIT " + code + ")"
            }
            root.refreshState()
        }
    }

    property Timer actionTimeout: Timer {
        interval: 8000
        repeat: false
        onTriggered: {
            if (actionProc.running) {
                actionProc.running = false
                root.errorMessage = "NETWORK CMD TIMEOUT"
            }
        }
    }

    function refreshState() {
        if (!statusProc.running) statusProc.running = true
        if (!radioProc.running) radioProc.running = true
    }

    function runAction(args) {
        if (!available || actionProc.running) return
        root.errorMessage = ""
        actionProc.command = args
        actionProc.running = true
        actionTimeout.restart()
    }

    function toggleWifi() {
        if (!available) return
        runAction(["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"])
    }

    function connectNetwork(targetSsid) {
        if (!available || !wifiEnabled || !targetSsid) return
        runAction(["nmcli", "device", "wifi", "connect", String(targetSsid)])
    }

    function disconnect() {
        if (!available || !interfaceName) return
        runAction(["nmcli", "device", "disconnect", String(interfaceName)])
    }
}

