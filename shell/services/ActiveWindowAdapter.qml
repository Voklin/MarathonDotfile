import QtQuick
import Quickshell.Hyprland

QtObject {
    id: root

    readonly property var toplevel: Hyprland.activeToplevel
    readonly property bool available: Hyprland.workspaces !== null
    property bool loading: false
    property string errorMessage: available ? "" : "HYPRLAND TOPLEVEL UNAVAILABLE"

    readonly property string title: (toplevel && toplevel.title && toplevel.title !== "")
        ? toplevel.title
        : "IDLE // EMPTY WORKSPACE"
    readonly property string appId: {
        if (!toplevel) return "hyprland.empty"
        var ipc = toplevel.lastIpcObject
        if (ipc && (ipc["class"] || ipc.initialClass)) {
            return String(ipc["class"] || ipc.initialClass)
        }
        if (toplevel.wayland && toplevel.wayland.appId) {
            return String(toplevel.wayland.appId)
        }
        return "client"
    }
    readonly property bool fullscreen: {
        if (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.hasFullscreen) return true
        if (!toplevel || !toplevel.lastIpcObject) return false
        var fs = toplevel.lastIpcObject.fullscreen
        return fs === true || (typeof fs === "number" && fs > 0)
    }
    readonly property bool floating: {
        if (!toplevel || !toplevel.lastIpcObject) return false
        return toplevel.lastIpcObject.floating === true
    }
    readonly property string monitor: (toplevel && toplevel.monitor && toplevel.monitor.name)
        ? toplevel.monitor.name
        : (Hyprland.focusedMonitor ? (Hyprland.focusedMonitor.name || "") : "")

    property Connections hyprEvents: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!event || !event.name) return
            var n = event.name
            if (n === "activewindow" || n === "windowtitle" || n === "fullscreen"
                || n === "changefloatingmode" || n === "openwindow"
                || n === "closewindow" || n === "movewindow") {
                Hyprland.refreshToplevels()
                Hyprland.refreshWorkspaces()
            }
        }
    }

    function toggleFloating() {
        if (!available) return
        Hyprland.dispatch("togglefloating")
    }

    function toggleFullscreen() {
        if (!available) return
        Hyprland.dispatch("fullscreen 0")
    }

    function closeActive() {
        if (!available) return
        Hyprland.dispatch("killactive")
    }
}

