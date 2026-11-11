import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property string statusNote: "UTILITIES READY // PREVIEW MOCK"

    // Clipboard History (cliphist + wl-copy)
    property bool clipboardAvailable: true
    property string clipboardError: ""
    property var clipboardItems: [
        { id: "cb-1", preview: "hyprctl dispatch exec marathon-tactical:capture", text: "hyprctl dispatch exec marathon-tactical:capture", pinned: true, timestamp: "23:41", charCount: 47, kind: "COMMAND" },
        { id: "cb-2", preview: "#C9FF16 // MARATHON RUNNER ACID LIME", text: "#C9FF16", pinned: true, timestamp: "23:39", charCount: 7, kind: "COLOR" },
        { id: "cb-3", preview: "https://wiki.hypr.land/Configuring/Window-Rules/", text: "https://wiki.hypr.land/Configuring/Window-Rules/", pinned: false, timestamp: "23:35", charCount: 48, kind: "URI" },
        { id: "cb-4", preview: "pacman -S --needed ghostty yazi btop grim slurp satty cliphist hyprpicker hyprsunset", text: "pacman -S --needed ghostty yazi btop grim slurp satty cliphist hyprpicker hyprsunset", pinned: false, timestamp: "23:28", charCount: 83, kind: "TEXT" },
        { id: "cb-5", preview: "0x00F0FF // CYBERACME TELEMETRY BUS", text: "0x00F0FF // CYBERACME TELEMETRY BUS", pinned: false, timestamp: "23:14", charCount: 35, kind: "TEXT" },
        { id: "cb-6", preview: "~/.config/marathon-tactical/apps/ghostty/config", text: "~/.config/marathon-tactical/apps/ghostty/config", pinned: false, timestamp: "22:58", charCount: 47, kind: "PATH" }
    ]
    property string lastCopiedText: ""

    // Capture (grim + slurp + satty) & Color Picker (hyprpicker)
    property bool captureAvailable: true
    property bool pickerAvailable: true
    property bool captureBusy: false
    property string lastCapturePath: "~/Pictures/Screenshots/marathon-region-234102.png"
    property string lastPickedColor: "#C9FF16"
    property var recentCaptures: [
        { id: "cap-1", name: "marathon-region-234102.png", path: "~/Pictures/Screenshots/marathon-region-234102.png", mode: "REGION", timestamp: "23:41", resolution: "1280x720" },
        { id: "cap-2", name: "marathon-output-231845.png", path: "~/Pictures/Screenshots/marathon-output-231845.png", mode: "FULLSCREEN", timestamp: "23:18", resolution: "1920x1080" }
    ]

    // System Monitor & Per-App Audio Mixer
    property bool monitorAvailable: true
    property bool monitorActive: false
    property real cpuUsage: 0.28
    property int cpuTempC: 58
    property real ramUsedGib: 18.4
    property real ramTotalGib: 64.0
    property int diskUsedPct: 42
    property string diskSummary: "210 / 500 GiB (/)"
    property string loadAvg: "1.24 1.08 0.96"
    property var processes: [
        { pid: 1420, name: "ghostty", cpuPct: 4.8, memPct: 1.9, memMb: 380, user: "runner" },
        { pid: 1104, name: "Hyprland", cpuPct: 6.2, memPct: 2.4, memMb: 512, user: "runner" },
        { pid: 1192, name: "quickshell", cpuPct: 3.1, memPct: 1.4, memMb: 294, user: "runner" },
        { pid: 2248, name: "firefox", cpuPct: 8.6, memPct: 6.2, memMb: 1290, user: "runner" },
        { pid: 2510, name: "spotify", cpuPct: 1.8, memPct: 2.1, memMb: 440, user: "runner" },
        { pid: 2890, name: "btop", cpuPct: 1.1, memPct: 0.4, memMb: 86, user: "runner" }
    ]
    property var audioStreams: [
        { id: "stream-spotify", appName: "Spotify", mediaTitle: "Sector 04 Extraction", volume: 0.78, muted: false },
        { id: "stream-firefox", appName: "Firefox", mediaTitle: "WebRTC Comms", volume: 0.60, muted: false },
        { id: "stream-mpv", appName: "mpv", mediaTitle: "Latency Capture", volume: 0.45, muted: true }
    ]

    // Night Light (hyprsunset) & Game Mode
    property bool nightLightAvailable: true
    property bool nightLightEnabled: false
    property int nightLightTemp: 4200
    property bool gameModeEnabled: false

    // Focus Pomodoro Timer & Persistent Scratchpad
    property string scratchpadText: "SECTOR 04 LOG // MARATHON TACTICAL\n- Super+/ opens Keybinds Briefing\n- Super+Shift+V opens Clipboard Vault\n- Print / Super+Shift+S opens Capture Suite"
    property int pomodoroRemainingSec: 1500
    property int pomodoroTotalSec: 1500
    property bool pomodoroRunning: false
    property string pomodoroMode: "FOCUS"

    property Timer _pomodoroTimer: Timer {
        interval: 1000
        repeat: true
        running: root.available && root.pomodoroRunning
        onTriggered: {
            if (root.pomodoroRemainingSec > 1) {
                root.pomodoroRemainingSec -= 1
            } else {
                root.pomodoroRemainingSec = 0
                root.pomodoroRunning = false
                root.statusNote = root.pomodoroMode + " TIMER COMPLETE"
            }
        }
    }

    signal clipboardCopied(string label)
    signal captureCompleted(string mode, string path)
    signal colorPicked(string hexColor)

    function _detectKind(txt) {
        if (/^#[0-9A-Fa-f]{6,8}$/.test(txt)) return "COLOR"
        if (/^https?:\/\//i.test(txt)) return "URI"
        if (txt.indexOf("~/") === 0 || txt.indexOf("/") === 0) return "PATH"
        return "TEXT"
    }

    function refreshClipboard() {
        if (!clipboardAvailable) return
        statusNote = "CLIPBOARD SYNCED (" + clipboardItems.length + " ITEMS)"
    }

    function copyText(text) {
        if (!clipboardAvailable) return
        var clean = String(text || "")
        if (clean === "") return
        lastCopiedText = clean
        var next = [{
            id: "cb-" + (clipboardItems.length + 1) + "-" + Date.now(),
            preview: clean.replace(/\s+/g, " ").slice(0, 96),
            text: clean,
            pinned: false,
            timestamp: "NOW",
            charCount: clean.length,
            kind: _detectKind(clean.trim())
        }]
        for (var i = 0; i < clipboardItems.length && next.length < 40; ++i) {
            if (clipboardItems[i].text !== clean) next.push(clipboardItems[i])
        }
        clipboardItems = next
        statusNote = "COPIED TO CLIPBOARD: " + clean.slice(0, 32)
        clipboardCopied(clean.slice(0, 48))
    }

    function copyClipboardItem(id) {
        if (!clipboardAvailable) return
        for (var i = 0; i < clipboardItems.length; ++i) {
            if (clipboardItems[i].id === id) {
                lastCopiedText = clipboardItems[i].text
                statusNote = "COPIED ENTRY: " + clipboardItems[i].preview.slice(0, 32)
                clipboardCopied(clipboardItems[i].preview)
                return
            }
        }
    }

    function togglePinClipboard(id) {
        var next = []
        for (var i = 0; i < clipboardItems.length; ++i) {
            var item = clipboardItems[i]
            next.push(item.id === id ? Object.assign({}, item, { pinned: !item.pinned }) : item)
        }
        next.sort(function(a, b) { return (a.pinned === b.pinned) ? 0 : (a.pinned ? -1 : 1) })
        clipboardItems = next
    }

    function deleteClipboardItem(id) {
        var next = []
        for (var i = 0; i < clipboardItems.length; ++i) {
            if (clipboardItems[i].id !== id) next.push(clipboardItems[i])
        }
        clipboardItems = next
    }

    function clearClipboard() {
        var kept = []
        for (var i = 0; i < clipboardItems.length; ++i) {
            if (clipboardItems[i].pinned) kept.push(clipboardItems[i])
        }
        clipboardItems = kept
        statusNote = "CLEARED UNPINNED CLIPBOARD HISTORY"
    }

    function _recordMockCapture(modeLabel, annotate) {
        var tag = modeLabel.toLowerCase()
        var name = "marathon-" + tag + "-" + (recentCaptures.length + 1) + ".png"
        var path = "~/Pictures/Screenshots/" + name
        var list = [{
            id: "cap-" + (recentCaptures.length + 1),
            name: name,
            path: path,
            mode: modeLabel + (annotate ? "+SATTY" : ""),
            timestamp: "NOW",
            resolution: modeLabel === "FULLSCREEN" ? "1920x1080" : "1280x720"
        }]
        for (var i = 0; i < recentCaptures.length && list.length < 12; ++i) {
            list.push(recentCaptures[i])
        }
        recentCaptures = list
        lastCapturePath = path
        statusNote = "CAPTURED " + modeLabel + (annotate ? " -> SATTY" : " -> CLIPBOARD")
        captureCompleted(modeLabel, path)
    }

    function captureRegion(annotate) {
        if (!captureAvailable) return
        _recordMockCapture("REGION", !!annotate)
    }

    function captureWindow(annotate) {
        if (!captureAvailable) return
        _recordMockCapture("WINDOW", !!annotate)
    }

    function captureFullscreen(annotate) {
        if (!captureAvailable) return
        _recordMockCapture("FULLSCREEN", !!annotate)
    }

    function pickColor() {
        if (!pickerAvailable) return
        var swatches = ["#C9FF16", "#00F0FF", "#FF8800", "#39FF88", "#FF4268"]
        var idx = swatches.indexOf(lastPickedColor)
        var picked = swatches[(idx + 1) % swatches.length]
        lastPickedColor = picked
        copyText(picked)
        statusNote = "COLOR PICKED: " + picked
        colorPicked(picked)
    }

    function setMonitorActive(active) {
        monitorActive = !!active
        if (monitorActive) refreshSystemMetrics()
    }

    function refreshSystemMetrics() {
        if (!monitorAvailable) return
        var bump = ((cpuUsage * 100 + 3) % 45) / 100.0
        cpuUsage = Math.max(0.08, Math.min(0.95, 0.14 + bump))
        cpuTempC = Math.round(48 + cpuUsage * 34)
        statusNote = "SYSTEM TELEMETRY REFRESHED"
    }

    function killProcess(pid) {
        if (!monitorAvailable || pid <= 0) return
        var next = []
        var removed = ""
        for (var i = 0; i < processes.length; ++i) {
            if (processes[i].pid === pid) {
                removed = processes[i].name
            } else {
                next.push(processes[i])
            }
        }
        processes = next
        if (removed !== "") statusNote = "TERMINATED PID " + pid + " (" + removed + ")"
    }

    function launchExternalMonitor() {
        statusNote = "LAUNCHED BTOP TELEMETRY (MOCK)"
    }

    function launchAppCommand(cmdName) {
        var clean = String(cmdName || "").trim()
        if (clean === "") return
        statusNote = "LAUNCHED APP COMMAND: " + clean.toUpperCase()
    }

    function setStreamVolume(id, nextVolume) {
        var clamped = Math.max(0.0, Math.min(1.0, Number(nextVolume)))
        var next = []
        for (var i = 0; i < audioStreams.length; ++i) {
            var s = audioStreams[i]
            if (s.id === id) {
                next.push(Object.assign({}, s, { volume: clamped, muted: clamped > 0 ? false : s.muted }))
            } else {
                next.push(s)
            }
        }
        audioStreams = next
    }

    function toggleStreamMute(id) {
        var next = []
        for (var i = 0; i < audioStreams.length; ++i) {
            var s = audioStreams[i]
            next.push(s.id === id ? Object.assign({}, s, { muted: !s.muted }) : s)
        }
        audioStreams = next
    }

    function toggleNightLight() {
        if (!nightLightAvailable) return
        nightLightEnabled = !nightLightEnabled
        statusNote = nightLightEnabled ? ("NIGHT LIGHT ON (" + nightLightTemp + "K)") : "NIGHT LIGHT OFF"
    }

    function setNightLightTemp(kelvin) {
        var k = Math.max(2500, Math.min(6500, Math.round(Number(kelvin))))
        nightLightTemp = k
        if (nightLightEnabled) statusNote = "NIGHT LIGHT TEMP: " + k + "K"
    }

    function toggleGameMode() {
        gameModeEnabled = !gameModeEnabled
        statusNote = gameModeEnabled ? "GAME MODE ARMED // ANIMATIONS & BLUR BYPASSED" : "GAME MODE DISENGAGED"
    }

    function setScratchpadText(txt) {
        scratchpadText = String(txt || "")
    }

    function togglePomodoro() {
        pomodoroRunning = !pomodoroRunning
        statusNote = pomodoroRunning ? (pomodoroMode + " TIMER RUNNING") : (pomodoroMode + " TIMER PAUSED")
    }

    function resetPomodoro() {
        pomodoroRunning = false
        pomodoroRemainingSec = pomodoroTotalSec
        statusNote = pomodoroMode + " TIMER RESET"
    }

    function setPomodoroPreset(minutes, modeLabel) {
        var mins = Math.max(1, Math.min(120, Math.round(Number(minutes))))
        pomodoroRunning = false
        pomodoroTotalSec = mins * 60
        pomodoroRemainingSec = pomodoroTotalSec
        pomodoroMode = String(modeLabel || "FOCUS").toUpperCase()
        statusNote = "PRESET: " + pomodoroMode + " (" + mins + "M)"
    }
}
