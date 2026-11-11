import QtQuick
import Quickshell.Hyprland

QtObject {
    id: root

    readonly property bool available: Hyprland.workspaces !== null
    property bool loading: false
    property string errorMessage: available ? "" : "HYPRLAND IPC UNAVAILABLE"

    readonly property int activeWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property string focusedMonitorName: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""

    readonly property var monitors: {
        var out = []
        if (!Hyprland.monitors || !Hyprland.monitors.values) return out
        var list = Hyprland.monitors.values
        for (var i = 0; i < list.length; ++i) {
            var m = list[i]
            if (!m) continue
            out.push({
                name: m.name || ("OUT-" + i),
                label: (m.name || "MONITOR") + " // " + (m.width || 0) + "x" + (m.height || 0),
                activeWorkspaceId: m.activeWorkspace ? m.activeWorkspace.id : 1,
                primary: m.focused === true || i === 0
            })
        }
        return out
    }

    readonly property var items: {
        var byId = {}
        var maxId = 6
        if (Hyprland.workspaces && Hyprland.workspaces.values) {
            var wsList = Hyprland.workspaces.values
            for (var i = 0; i < wsList.length; ++i) {
                var w = wsList[i]
                if (!w || w.id <= 0) continue
                if (w.id > maxId) maxId = w.id
                var winCount = (w.toplevels && w.toplevels.values) ? w.toplevels.values.length : 0
                byId[w.id] = {
                    id: w.id,
                    name: w.id < 10 ? ("0" + w.id) : String(w.id),
                    monitor: w.monitor ? (w.monitor.name || "") : "",
                    occupied: winCount > 0 || w.active === true,
                    active: w.focused === true || w.id === activeWorkspaceId,
                    urgent: w.urgent === true,
                    windowsCount: winCount
                }
            }
        }
        var out = []
        var defaultMon = monitors.length > 0 ? monitors[0].name : ""
        for (var id = 1; id <= maxId; ++id) {
            if (byId[id]) {
                out.push(byId[id])
            } else {
                out.push({
                    id: id,
                    name: id < 10 ? ("0" + id) : String(id),
                    monitor: defaultMon,
                    occupied: false,
                    active: id === activeWorkspaceId,
                    urgent: false,
                    windowsCount: 0
                })
            }
        }
        return out
    }

    signal workspaceSwitched(int workspaceId)

    property Connections hyprEvents: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!event || !event.name) return
            var n = event.name
            if (n === "workspace" || n === "workspacev2" || n === "focusedmon"
                || n === "createworkspace" || n === "destroyworkspace"
                || n === "urgent" || n === "openwindow" || n === "closewindow"
                || n === "movewindow") {
                Hyprland.refreshWorkspaces()
                Hyprland.refreshMonitors()
            }
        }
    }

    function switchWorkspace(id) {
        if (!available) return
        var num = parseInt(id, 10)
        if (isNaN(num)) return
        Hyprland.dispatch("workspace " + num)
        workspaceSwitched(num)
    }

    function moveFocusedToWorkspace(id) {
        if (!available) return
        var num = parseInt(id, 10)
        if (isNaN(num)) return
        Hyprland.dispatch("movetoworkspace " + num)
    }
}

