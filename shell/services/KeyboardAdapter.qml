import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

// Active XKB layout: initial value from `hyprctl devices -j` (main keyboard),
// live updates from Hyprland `activelayout>>KEYBOARD,LAYOUT` events. No polling.
QtObject {
    id: root

    property bool available: false
    property bool loading: true
    property string errorMessage: ""
    property var layouts: []
    property int activeIndex: 0
    property string layoutName: ""
    property string shortCode: _code(layoutName)

    function _code(name) {
        var n = String(name || "")
        if (n === "") return "--"
        if (n.indexOf("Russian") === 0) return "RU"
        if (n.indexOf("English") === 0) return "EN"
        if (n.indexOf("Ukrainian") === 0) return "UA"
        if (n.indexOf("German") === 0) return "DE"
        return n.substring(0, 2).toUpperCase()
    }

    property Process devicesProc: Process {
        command: ["hyprctl", "devices", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text || "{}")
                    var kbs = data.keyboards || []
                    var main = null
                    for (var i = 0; i < kbs.length; ++i) if (kbs[i].main) main = kbs[i]
                    if (!main && kbs.length > 0) main = kbs[0]
                    if (main) {
                        root.layoutName = String(main.active_keymap || "")
                        root.layouts = String(main.layout || "").split(",").filter(function(s) { return s !== "" })
                        root.available = true
                        root.errorMessage = ""
                    }
                } catch (e) {
                    root.errorMessage = "KEYBOARD LAYOUT PARSE FAILED"
                }
            }
        }
        onExited: function(code, _status) {
            root.loading = false
            if (code !== 0) { root.available = false; root.errorMessage = "HYPRCTL DEVICES FAILED" }
        }
    }

    property Connections hyprEvents: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!event || event.name !== "activelayout") return
            var data = String(event.data || "")
            var comma = data.lastIndexOf(",")
            root.layoutName = comma >= 0 ? data.substring(comma + 1) : data
            root.available = true
        }
    }

    property Process switchProc: Process {
        command: ["hyprctl", "switchxkblayout", "all", "next"]
        onExited: function(code, _status) { if (code !== 0) root.errorMessage = "LAYOUT SWITCH FAILED" }
    }
    function nextLayout() {
        if (!available || switchProc.running) return
        switchProc.running = true
    }
}
