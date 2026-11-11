import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property string query: ""
    property var recentIds: ["ghostty", "firefox", "nvim"]
    property string lastActionNote: ""
    property var entries: [
        { id: "ghostty", name: "Ghostty Terminal", genericName: "GPU Wayland Terminal", execDisplay: "ghostty", category: "SYSTEM", iconTag: "TRM" },
        { id: "firefox", name: "Firefox Browser", genericName: "Web Browser", execDisplay: "firefox", category: "NETWORK", iconTag: "WEB" },
        { id: "nvim", name: "Neovim Editor", genericName: "Modal Text Editor", execDisplay: "ghostty -e nvim", category: "DEV", iconTag: "EDT" },
        { id: "code", name: "VS Code", genericName: "Code Editor", execDisplay: "code --ozone-platform=wayland", category: "DEV", iconTag: "IDE" },
        { id: "btop", name: "btop++ Telemetry", genericName: "Resource Monitor", execDisplay: "ghostty -e btop", category: "SYSTEM", iconTag: "MON" },
        { id: "dolphin", name: "Dolphin Files", genericName: "File Manager", execDisplay: "dolphin", category: "FILES", iconTag: "DIR" },
        { id: "pavucontrol", name: "PipeWire Mixer", genericName: "Audio Routing", execDisplay: "pavucontrol", category: "AUDIO", iconTag: "AUD" },
        { id: "obsidian", name: "Obsidian Notes", genericName: "Knowledge Base", execDisplay: "obsidian", category: "DOCS", iconTag: "DOC" },
        { id: "yazi", name: "Yazi TUI Files", genericName: "Terminal File Manager", execDisplay: "ghostty -e yazi", category: "FILES", iconTag: "YAZ" },
        { id: "mpv", name: "mpv Media Player", genericName: "Hardware Video & Audio Player", execDisplay: "mpv --player-operation-mode=pseudo-gui", category: "MEDIA", iconTag: "MPV" },
        { id: "imv", name: "imv Image Viewer", genericName: "Minimal Wayland Image Viewer", execDisplay: "imv", category: "MEDIA", iconTag: "IMG" },
        { id: "zathura", name: "Zathura PDF Reader", genericName: "Keyboard Document Viewer", execDisplay: "zathura", category: "DOCS", iconTag: "PDF" },
        { id: "steam", name: "Steam Runtime", genericName: "Game Launcher", execDisplay: "steam", category: "MEDIA", iconTag: "RUN" },
        { id: "wireshark", name: "Wireshark Analyzer", genericName: "Packet Inspector", execDisplay: "wireshark", category: "NETWORK", iconTag: "PKT" }
    ]
    property var safeCommands: [
        { id: "open-settings", title: "CMD // SETTINGS HUB", detail: "Open MARATHON Tactical Settings Hub (Super+,)" },
        { id: "open-clipboard", title: "CMD // CLIPBOARD VAULT", detail: "Open clipboard history & pin manager (Super+Shift+V)" },
        { id: "open-capture", title: "CMD // CAPTURE & PICKER", detail: "Region/Window screenshot, Satty annotate & color picker (Print)" },
        { id: "open-sysmon", title: "CMD // SYSTEM MONITOR", detail: "CPU/RAM/Disk telemetry, processes & PipeWire mixer (Super+M)" },
        { id: "open-calendar", title: "CMD // CALENDAR & FOCUS", detail: "Monthly calendar, Pomodoro timer & persistent notes (Super+A)" },
        { id: "open-cheatsheet", title: "CMD // KEYBINDS BRIEFING", detail: "Interactive hotkey cheatsheet & quick actions (Super+/)" },
        { id: "toggle-nightlight", title: "CMD // NIGHT LIGHT", detail: "Toggle hyprsunset blue-light temperature filter (Super+Shift+N)" },
        { id: "toggle-gamemode", title: "CMD // GAME MODE", detail: "Bypass animations, blur, shadow & gaps for zero overhead" },
        { id: "toggle-dnd", title: "CMD // TOGGLE DND", detail: "Silence popup notifications" },
        { id: "toggle-motion", title: "CMD // REDUCED MOTION", detail: "Disable UI animations" },
        { id: "open-control", title: "CMD // CONTROL CENTER", detail: "Open tactical system controls" },
        { id: "lock-session", title: "CMD // LOCK SESSION", detail: "Engage lock screen" }
    ]

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
            if (q === "" ||
                e.name.toLowerCase().indexOf(q) !== -1 ||
                e.genericName.toLowerCase().indexOf(q) !== -1 ||
                e.category.toLowerCase().indexOf(q) !== -1 ||
                e.id.toLowerCase().indexOf(q) !== -1) {
                list.push(e)
            }
        }
        // Prioritize recent items when query is empty
        if (q === "") {
            list.sort(function(a, b) {
                var ia = recentIds.indexOf(a.id)
                var ib = recentIds.indexOf(b.id)
                if (ia !== -1 && ib !== -1) return ia - ib
                if (ia !== -1) return -1
                if (ib !== -1) return 1
                return a.name.localeCompare(b.name)
            })
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
        if (!found) return
        var rec = [id]
        for (var j = 0; j < recentIds.length && rec.length < 5; ++j) {
            if (recentIds[j] !== id) rec.push(recentIds[j])
        }
        recentIds = rec
        lastActionNote = "SIMULATED LAUNCH: " + found.execDisplay
        entryLaunched(found.id, found.name)
    }

    function runSafeCommand(id) {
        if (!available) return
        lastActionNote = "SAFE CMD: " + id
        safeCommandTriggered(id)
    }
}

