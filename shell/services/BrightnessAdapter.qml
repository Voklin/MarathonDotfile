import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool available: false
    property bool loading: true
    property string errorMessage: ""
    property real level: 0.0
    property string deviceName: ""

    signal osdTriggered(string kind, real level, bool muted, string detail)

    property Process probeProc: Process {
        command: ["brightnessctl", "-m", "-c", "backlight", "info"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = (text || "").trim().split("\n")[0] || ""
                var parts = raw.split(",")
                // brightnessctl -m format: device,class,cur,percent%,max
                if (parts.length >= 4 && parts[1] === "backlight") {
                    root.deviceName = parts[0]
                    var pctStr = parts[3].replace("%", "")
                    var pct = parseFloat(pctStr)
                    if (!isNaN(pct)) {
                        root.level = Math.max(0.0, Math.min(1.0, pct / 100.0))
                    }
                    root.available = true
                    root.errorMessage = ""
                } else {
                    root.available = false
                }
            }
        }
        onExited: function(code, _status) {
            probeTimeout.stop()
            root.loading = false
            if (code !== 0) {
                root.available = false
                root.errorMessage = "NO BACKLIGHT CONTROLLER"
            }
        }
    }

    property Timer probeTimeout: Timer {
        interval: 2500
        repeat: false
        onTriggered: {
            if (probeProc.running) {
                probeProc.running = false
                root.loading = false
                root.available = false
            }
        }
    }

    property Process setProc: Process {
        running: false
        onExited: function(code, _status) {
            setTimeout.stop()
            if (code !== 0) {
                root.errorMessage = "BRIGHTNESS WRITE FAILED (EXIT " + code + ")"
            }
        }
    }

    property Timer setTimeout: Timer {
        interval: 2500
        repeat: false
        onTriggered: {
            if (setProc.running) setProc.running = false
        }
    }

    function refresh(showOsd) {
        if (probeProc.running) return
        probeProc.running = true
        probeTimeout.restart()
        if (showOsd && available) {
            osdTriggered("brightness", level, false, deviceName)
        }
    }

    function setLevel(nextLevel) {
        if (!available) return
        var clamped = Math.max(0.05, Math.min(1.0, nextLevel))
        var pct = Math.round(clamped * 100)
        level = clamped
        if (setProc.running) setProc.running = false
        setProc.command = ["brightnessctl", "-c", "backlight", "set", pct + "%"]
        setProc.running = true
        setTimeout.restart()
        osdTriggered("brightness", clamped, false, deviceName)
    }
}

