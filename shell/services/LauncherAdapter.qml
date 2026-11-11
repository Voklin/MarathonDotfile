import QtQuick
import Quickshell

QtObject {
    id: root

    readonly property bool available: DesktopEntries.applications !== null
    property bool loading: false
    property string errorMessage: available ? "" : "DESKTOP ENTRIES UNAVAILABLE"
    property string query: ""
    property var recentIds: []
    property string lastActionNote: ""

    readonly property var safeCommands: [
        { id: "open-settings", title: "CMD // SETTINGS HUB", detail: "Open MARATHON Tactical Settings Hub (Super+,)" },
        { id: "open-clipboard", title: "CMD // CLIPBOARD VAULT", detail: "Open cliphist history & pin manager (Super+Shift+V)" },
        { id: "open-capture", title: "CMD // CAPTURE & PICKER", detail: "Region/Window grim capture, Satty & hyprpicker (Print)" },
        { id: "open-sysmon", title: "CMD // SYSTEM MONITOR", detail: "CPU/RAM/Disk telemetry, processes & PipeWire mixer (Super+M)" },
        { id: "open-calendar", title: "CMD // CALENDAR & FOCUS", detail: "Calendar, Pomodoro timer & persistent scratchpad (Super+A)" },
        { id: "open-cheatsheet", title: "CMD // KEYBINDS BRIEFING", detail: "Interactive hotkey cheatsheet & quick actions (Super+/)" },
        { id: "toggle-nightlight", title: "CMD // NIGHT LIGHT", detail: "Toggle hyprsunset blue-light temperature filter (Super+Shift+N)" },
        { id: "toggle-gamemode", title: "CMD // GAME MODE", detail: "Bypass animations, blur, shadow & gaps for zero overhead" },
        { id: "toggle-dnd", title: "CMD // TOGGLE DND", detail: "Silence popup notifications" },
        { id: "toggle-motion", title: "CMD // REDUCED MOTION", detail: "Disable UI animations" },
        { id: "open-control", title: "CMD // CONTROL CENTER", detail: "Open tactical system controls" },
        { id: "lock-session", title: "CMD // LOCK SESSION", detail: "Engage hyprlock PAM screen" }
    ]

    readonly property var entries: {
        var out = []
        if (!DesktopEntries.applications || !DesktopEntries.applications.values) return out
        var apps = DesktopEntries.applications.values
        for (var i = 0; i < apps.length; ++i) {
            var a = apps[i]
            if (!a || a.noDisplay) continue
            var cats = a.categories || []
            var catLabel = (cats.length > 0 && cats[0]) ? String(cats[0]).toUpperCase() : "APP"
            var cmdList = a.command || []
            var tag = String(a.name || "APP").replace(/[^A-Za-z0-9]/g, "").slice(0, 3).toUpperCase()
            if (tag === "") tag = "APP"
            out.push({
                id: String(a.id || a.name),
                name: String(a.name || a.id),
                genericName: String(a.comment || a.genericName || ""),
                execDisplay: Array.isArray(cmdList) ? cmdList.join(" ") : "",
                category: catLabel,
                iconTag: tag,
                _entry: a
            })
        }
        return out
    }

    signal entryLaunched(string id, string name)
    signal safeCommandTriggered(string id)

    function setQuery(q) {
        query = q || ""
    }

    function filteredEntries() {
        if (!available) return []
        var q = (query || "").trim().toLowerCase()
        var list = []
        for (var i = 0; i < entries.length; ++i) {
            var e = entries[i]
            if (q === ""
                || e.name.toLowerCase().indexOf(q) !== -1
                || e.genericName.toLowerCase().indexOf(q) !== -1
                || e.category.toLowerCase().indexOf(q) !== -1
                || e.id.toLowerCase().indexOf(q) !== -1) {
                list.push(e)
            }
        }
        if (q === "") {
            list.sort(function(a, b) {
                var ia = recentIds.indexOf(a.id)
                var ib = recentIds.indexOf(b.id)
                if (ia !== -1 && ib !== -1) return ia - ib
                if (ia !== -1) return -1
                if (ib !== -1) return 1
                return a.name.localeCompare(b.name)
            })
        } else {
            list.sort(function(a, b) { return a.name.localeCompare(b.name) })
        }
        return list
    }

    function launchEntry(id) {
        if (!available) return
        var found = null
        for (var i = 0; i < entries.length; ++i) {
            if (entries[i].id === id) {
                found = entries[i]
                break
            }
        }
        if (!found || !found._entry) return
        // Uses DesktopEntry.execute() which dispatches parsed argv + workingDirectory directly without an intermediate shell
        found._entry.execute()
        var rec = [id]
        for (var j = 0; j < recentIds.length && rec.length < 6; ++j) {
            if (recentIds[j] !== id) rec.push(recentIds[j])
        }
        recentIds = rec
        lastActionNote = "LAUNCHED: " + found.name
        entryLaunched(found.id, found.name)
    }

    function runSafeCommand(id) {
        if (!available) return
        lastActionNote = "SAFE CMD: " + id
        safeCommandTriggered(id)
    }
}
