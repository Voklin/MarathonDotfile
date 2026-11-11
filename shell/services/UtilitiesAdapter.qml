import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import "../../ui/tokens"

QtObject {
    id: root

    readonly property string _xdgConfigHome: {
        var xdg = Quickshell.env("XDG_CONFIG_HOME")
        if (xdg && String(xdg) !== "") return String(xdg)
        var home = Quickshell.env("HOME")
        return (home && String(home) !== "" ? String(home) : "/tmp") + "/.config"
    }
    readonly property string _homeDir: {
        var home = Quickshell.env("HOME")
        return (home && String(home) !== "") ? String(home) : "/tmp"
    }
    readonly property string _marathonRoot: _xdgConfigHome + "/marathon-tactical"
    readonly property string _screenshotDir: _homeDir + "/Pictures/Screenshots"

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property string statusNote: "UTILITIES ADAPTER READY"

    // Probed Linux utility flags
    property bool clipboardAvailable: false
    property string clipboardError: ""
    property var clipboardItems: []
    property string lastCopiedText: ""
    property var _pinnedIds: []

    property bool captureAvailable: false
    property bool pickerAvailable: false
    property bool _hasSatty: false
    property bool _hasSlurp: false
    property bool _hasWlCopy: false
    property bool captureBusy: false
    property string lastCapturePath: ""
    property string lastPickedColor: ""
    property var recentCaptures: []

    property bool monitorAvailable: true
    property bool monitorActive: false
    property real cpuUsage: 0.0
    property int cpuTempC: 0
    property real ramUsedGib: 0.0
    property real ramTotalGib: 0.0
    property int diskUsedPct: 0
    property string diskSummary: "--"
    property string loadAvg: "--"
    property var processes: []

    property real _prevCpuTotal: 0
    property real _prevCpuIdle: 0

    // Per-app PipeWire playback streams
    readonly property var _streamNodes: {
        var out = []
        if (!Pipewire.nodes || !Pipewire.nodes.values) return out
        var nodes = Pipewire.nodes.values
        for (var i = 0; i < nodes.length; ++i) {
            var n = nodes[i]
            if (!n || !n.isStream || !n.audio) continue
            var cls = ""
            if (n.properties && n.properties["media.class"] !== undefined) {
                cls = String(n.properties["media.class"])
            }
            if (cls !== "" && cls.indexOf("Output/Audio") === -1) continue
            if (cls === "" && n.isSink) continue
            out.push(n)
        }
        return out
    }

    property PwObjectTracker _streamTracker: PwObjectTracker {
        objects: root._streamNodes
    }

    readonly property var audioStreams: {
        var out = []
        for (var i = 0; i < _streamNodes.length; ++i) {
            var n = _streamNodes[i]
            var props = n.properties || ({})
            var app = String(props["application.name"] || n.description || n.nickname || n.name || ("Stream " + n.id))
            var media = String(props["media.name"] || "")
            out.push({
                id: String(n.id),
                appName: app,
                mediaTitle: media !== "" ? media : "Audio Stream",
                volume: Math.max(0.0, Math.min(1.0, Number(n.audio.volume || 0.0))),
                muted: n.audio.muted === true
            })
        }
        return out
    }

    property bool nightLightAvailable: false
    property bool nightLightEnabled: false
    property int nightLightTemp: 4200
    property bool gameModeEnabled: false

    property string scratchpadText: ""
    property int pomodoroRemainingSec: 1500
    property int pomodoroTotalSec: 1500
    property bool pomodoroRunning: false
    property string pomodoroMode: "FOCUS"

    property bool _dirReady: false
    property string _pendingCaptureMode: ""
    property bool _pendingAnnotate: false
    property string _pendingDecodeAction: ""
    property string _pendingDecodeId: ""

    signal clipboardCopied(string label)
    signal captureCompleted(string mode, string path)
    signal colorPicked(string hexColor)

    property Process _mkdirProc: Process {
        command: ["mkdir", "-p", root._marathonRoot, root._screenshotDir]
        running: true
        onExited: function(code, _status) {
            root._dirReady = (code === 0)
            _scratchpadFile.reload()
        }
    }

    // One-shot probe for optional Wayland utilities
    property Process _probeProc: Process {
        command: ["which", "cliphist", "wl-copy", "grim", "slurp", "satty", "hyprpicker", "hyprsunset"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var out = text || ""
                var hasCliphist = out.indexOf("cliphist") !== -1
                root._hasWlCopy = out.indexOf("wl-copy") !== -1
                var hasGrim = out.indexOf("grim") !== -1
                root._hasSlurp = out.indexOf("slurp") !== -1
                root._hasSatty = out.indexOf("satty") !== -1
                root.clipboardAvailable = hasCliphist && root._hasWlCopy
                root.captureAvailable = hasGrim
                root.pickerAvailable = out.indexOf("hyprpicker") !== -1
                root.nightLightAvailable = out.indexOf("hyprsunset") !== -1
                if (!root.clipboardAvailable) {
                    root.clipboardError = "cliphist / wl-clipboard not installed"
                } else {
                    root.refreshClipboard()
                }
            }
        }
        onExited: function(_code, _status) {
            // `which` returns 1 if any binary is absent even while printing found binaries to stdout
        }
    }

    // Scratchpad persistence
    property FileView _scratchpadFile: FileView {
        path: root._marathonRoot + "/scratchpad.txt"
        atomicWrites: true
        onLoaded: {
            root.scratchpadText = _scratchpadFile.text() || ""
        }
    }

    // Clipboard processes
    property Process _clipListProc: Process {
        command: ["cliphist", "list"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (text || "").split("\n")
                var items = []
                for (var i = 0; i < lines.length && items.length < 40; ++i) {
                    var ln = lines[i]
                    if (!ln) continue
                    var tabIdx = ln.indexOf("\t")
                    if (tabIdx === -1) continue
                    var idStr = ln.slice(0, tabIdx).trim()
                    var prev = ln.slice(tabIdx + 1)
                    var kind = "TEXT"
                    if (prev.indexOf("[[ binary data") === 0) kind = "IMAGE"
                    else if (/^#[0-9A-Fa-f]{6,8}/.test(prev.trim())) kind = "COLOR"
                    else if (/^https?:\/\//i.test(prev.trim())) kind = "URI"
                    items.push({
                        id: idStr,
                        preview: prev.slice(0, 96),
                        text: prev,
                        pinned: root._pinnedIds.indexOf(idStr) !== -1,
                        timestamp: "#" + idStr,
                        charCount: prev.length,
                        kind: kind
                    })
                }
                items.sort(function(a, b) {
                    return (a.pinned === b.pinned) ? 0 : (a.pinned ? -1 : 1)
                })
                root.clipboardItems = items
                root.clipboardError = ""
            }
        }
    }

    property Process _clipDecodeProc: Process {
        running: false
        onExited: function(code, _status) {
            if (code !== 0) {
                root._pendingDecodeAction = ""
                root.statusNote = "CLIPHIST DECODE EXIT " + code
            }
        }
        onRunningChanged: root._watch("_clipDecodeProc", _clipDecodeProc, 10000)
        stdout: StdioCollector {
            onStreamFinished: {
                var decoded = text || ""
                if (root._pendingDecodeAction === "copy") {
                    root.copyText(decoded)
                }
                root._pendingDecodeAction = ""
            }
        }
    }

    property Process _wlCopyProc: Process {
        running: false
        onRunningChanged: root._watch("_wlCopyProc", _wlCopyProc, 10000)
        onExited: function(code, _status) {
            if (code !== 0) {
                root.statusNote = "WL-COPY EXIT " + code
            }
        }
    }

    property Process _clipActionProc: Process {
        running: false
        onRunningChanged: root._watch("_clipActionProc", _clipActionProc, 10000)
        onExited: function(code, _status) {
            if (code !== 0) {
                root.statusNote = "CLIPHIST ACTION EXIT " + code
            }
            root.refreshClipboard()
        }
    }

    // Capture & color picker processes
    property Process _slurpProc: Process {
        running: false
        onRunningChanged: root._watch("_slurpProc", _slurpProc, 60000)
        stdout: StdioCollector {
            onStreamFinished: {
                var geom = (text || "").trim()
                if (geom !== "" && root._pendingCaptureMode === "REGION") {
                    root._launchGrim(["-g", geom], "REGION", root._pendingAnnotate)
                } else {
                    root.captureBusy = false
                }
            }
        }
        onExited: function(code, _status) {
            if (code !== 0) {
                root.captureBusy = false
                root.statusNote = "CAPTURE SELECTION CANCELLED"
            }
        }
    }

    property Process _activeWinGeomProc: Process {
        command: ["hyprctl", "activewindow", "-j"]
        running: false
        onRunningChanged: root._watch("_activeWinGeomProc", _activeWinGeomProc, 5000)
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var w = JSON.parse(text || "{}")
                    if (w && w.at && w.size && w.size[0] > 0 && w.size[1] > 0) {
                        var geom = w.at[0] + "," + w.at[1] + " " + w.size[0] + "x" + w.size[1]
                        root._launchGrim(["-g", geom], "WINDOW", root._pendingAnnotate)
                        return
                    }
                } catch (_e) {
                }
                root.captureBusy = false
                root.statusNote = "NO ACTIVE WINDOW GEOMETRY"
            }
        }
    }

    property Process _grimProc: Process {
        running: false
        onRunningChanged: root._watch("_grimProc", _grimProc, 20000)
        onExited: function(code, _status) {
            root.captureBusy = false
            if (code !== 0) {
                root.statusNote = "GRIM CAPTURE FAILED (EXIT " + code + ")"
                return
            }
            var outPath = root.lastCapturePath
            var mode = root._pendingCaptureMode || "CAPTURE"
            var next = [{
                id: "cap-" + Date.now(),
                name: outPath.split("/").pop(),
                path: outPath,
                mode: mode + (root._pendingAnnotate ? "+SATTY" : ""),
                timestamp: "NOW",
                resolution: "WAYLAND"
            }]
            for (var i = 0; i < root.recentCaptures.length && next.length < 12; ++i) {
                next.push(root.recentCaptures[i])
            }
            root.recentCaptures = next
            root.captureCompleted(mode, outPath)
            if (root._pendingAnnotate && root._hasSatty) {
                _sattyProc.command = ["satty", "--filename", outPath, "--output-filename", outPath, "--copy-command", "wl-copy"]
                _sattyProc.running = true
                root.statusNote = "OPENED SATTY ANNOTATION"
            } else {
                _copyImageProc.command = ["bash", root._marathonRoot + "/scripts/copy-image.sh", outPath]
                _copyImageProc.running = true
                root.statusNote = "CAPTURED " + mode + " -> " + outPath
            }
        }
    }

    property Process _sattyProc: Process {
        running: false
    }

    property Process _copyImageProc: Process {
        running: false
        onExited: function(code, _status) {
            if (code !== 0) {
                root.statusNote = "COPY-IMAGE EXIT " + code
            }
        }
        onRunningChanged: root._watch("_copyImageProc", _copyImageProc, 10000)
    }

    property Process _pickerProc: Process {
        running: false
        onExited: function(code, _status) {
            if (code !== 0) {
                root.statusNote = "COLOR PICK CANCELLED/FAILED (EXIT " + code + ")"
            }
        }
        onRunningChanged: root._watch("_pickerProc", _pickerProc, 60000)
        stdout: StdioCollector {
            onStreamFinished: {
                var picked = (text || "").trim()
                if (picked !== "") {
                    root.lastPickedColor = picked
                    root.statusNote = "COLOR PICKED: " + picked
                    root.colorPicked(picked)
                }
            }
        }
    }

    // Night light & Game Mode
    property Process _nightLightProc: Process {
        running: false
        onExited: function(code, _status) {
            if (root.nightLightEnabled && code !== 0 && code !== 15) {
                root.nightLightEnabled = false
                root.statusNote = "HYPRSUNSET EXIT " + code
            }
        }
    }

    property Process _nightLightKillProc: Process {
        command: ["pkill", "-x", "hyprsunset"]
        running: false
        onRunningChanged: root._watch("_nightLightKillProc", _nightLightKillProc, 5000)
        onExited: function(_code, _status) {
            if (root.nightLightEnabled) {
                _nightLightProc.command = ["hyprsunset", "-t", String(root.nightLightTemp)]
                _nightLightProc.running = true
            }
        }
    }

    property Process _gameModeProc: Process {
        running: false
        onExited: function(code, _status) {
            if (code !== 0) {
                root.statusNote = "HYPRCTL EXIT " + code
            }
        }
        onRunningChanged: root._watch("_gameModeProc", _gameModeProc, 10000)
    }

    // System Monitor readers (ONLY run while monitorActive === true -> zero idle polling)
    property FileView _procStatView: FileView {
        path: "/proc/stat"
        onLoaded: {
            var first = ((_procStatView.text() || "").split("\n")[0] || "").trim()
            if (first.indexOf("cpu ") !== 0) return
            var parts = first.split(/\s+/).slice(1)
            var total = 0
            for (var i = 0; i < parts.length; ++i) {
                total += parseInt(parts[i], 10) || 0
            }
            var idle = (parseInt(parts[3], 10) || 0) + (parseInt(parts[4], 10) || 0)
            if (root._prevCpuTotal > 0 && total > root._prevCpuTotal) {
                var dTotal = total - root._prevCpuTotal
                var dIdle = Math.max(0, idle - root._prevCpuIdle)
                root.cpuUsage = Math.max(0.0, Math.min(1.0, (dTotal - dIdle) / dTotal))
            }
            root._prevCpuTotal = total
            root._prevCpuIdle = idle
        }
    }

    property FileView _procMemView: FileView {
        path: "/proc/meminfo"
        onLoaded: {
            var txt = _procMemView.text() || ""
            var totM = /MemTotal:\s+(\d+)\s+kB/.exec(txt)
            var availM = /MemAvailable:\s+(\d+)\s+kB/.exec(txt)
            if (totM && availM) {
                var totGib = parseInt(totM[1], 10) / (1024 * 1024)
                var availGib = parseInt(availM[1], 10) / (1024 * 1024)
                root.ramTotalGib = Math.round(totGib * 10) / 10
                root.ramUsedGib = Math.round(Math.max(0, totGib - availGib) * 10) / 10
            }
        }
    }

    property FileView _loadAvgView: FileView {
        path: "/proc/loadavg"
        onLoaded: {
            var parts = (_loadAvgView.text() || "").trim().split(/\s+/)
            if (parts.length >= 3) {
                root.loadAvg = parts[0] + " " + parts[1] + " " + parts[2]
            }
        }
    }

    property FileView _tempZoneView: FileView {
        path: "/sys/class/thermal/thermal_zone0/temp"
        onLoaded: {
            var raw = parseInt((_tempZoneView.text() || "").trim(), 10)
            if (!isNaN(raw) && raw > 0) {
                root.cpuTempC = raw > 1000 ? Math.round(raw / 1000) : raw
            }
        }
    }

    property Process _dfProc: Process {
        command: ["df", "-kP", "/"]
        running: false
        onRunningChanged: root._watch("_dfProc", _dfProc, 5000)
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (text || "").trim().split("\n")
                if (lines.length < 2) return
                var cols = lines[1].trim().split(/\s+/)
                if (cols.length >= 5) {
                    var totalK = parseInt(cols[1], 10) || 0
                    var usedK = parseInt(cols[2], 10) || 0
                    var pct = parseInt(cols[4].replace("%", ""), 10) || 0
                    root.diskUsedPct = pct
                    root.diskSummary = Math.round(usedK / (1024 * 1024)) + " / " + Math.round(totalK / (1024 * 1024)) + " GiB (/)"
                }
            }
        }
    }

    property Process _psProc: Process {
        command: ["ps", "-eo", "pid=,comm=,%cpu=,%mem=,rss=,user=", "--sort=-%cpu"]
        running: false
        onRunningChanged: root._watch("_psProc", _psProc, 5000)
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (text || "").trim().split("\n")
                var list = []
                for (var i = 0; i < lines.length && list.length < 18; ++i) {
                    var cols = lines[i].trim().split(/\s+/)
                    if (cols.length < 6) continue
                    var pid = parseInt(cols[0], 10)
                    if (isNaN(pid) || pid <= 0) continue
                    list.push({
                        pid: pid,
                        name: cols[1],
                        cpuPct: parseFloat(cols[2]) || 0.0,
                        memPct: parseFloat(cols[3]) || 0.0,
                        memMb: Math.round((parseInt(cols[4], 10) || 0) / 1024),
                        user: cols[5]
                    })
                }
                root.processes = list
            }
        }
    }

    property Process _killProc: Process {
        running: false
        onRunningChanged: root._watch("_killProc", _killProc, 5000)
        onExited: function(code, _status) {
            if (code === 0) {
                root.statusNote = "PROCESS SIGNALLED (SIGTERM)"
                root.refreshSystemMetrics()
            } else {
                root.statusNote = "KILL FAILED (EXIT " + code + ")"
            }
        }
    }

    // Watchdog: external commands cannot hang forever; expired processes are terminated.
    property var _deadlines: ({})

    function _watch(key, proc, timeoutMs) {
        var d = _deadlines
        if (proc.running) {
            d[key] = { proc: proc, at: Date.now() + timeoutMs }
        } else {
            delete d[key]
        }
        _deadlines = d
        _watchdog.running = Object.keys(d).length > 0
    }

    property Timer _watchdog: Timer {
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            var d = root._deadlines
            var now = Date.now()
            for (var k in d) {
                if (d[k].at <= now) {
                    var proc = d[k].proc
                    delete d[k]
                    if (proc.running) {
                        proc.running = false
                        root.statusNote = "TIMEOUT: " + k.replace("_", "").replace("Proc", "").toUpperCase()
                    }
                }
            }
            root._deadlines = d
            running = Object.keys(d).length > 0
        }
    }

    property Timer _monitorTimer: Timer {
        interval: 2000
        repeat: true
        running: root.monitorActive
        onTriggered: root.refreshSystemMetrics()
    }

    property Timer _pomodoroTimer: Timer {
        interval: 1000
        repeat: true
        running: root.pomodoroRunning
        onTriggered: {
            if (root.pomodoroRemainingSec > 1) {
                root.pomodoroRemainingSec -= 1
            } else {
                root.pomodoroRemainingSec = 0
                root.pomodoroRunning = false
                root.statusNote = root.pomodoroMode + " SESSION COMPLETE"
            }
        }
    }

    function _makeCapturePath(modeLabel) {
        var now = new Date()
        function pad(n) { return n < 10 ? ("0" + n) : String(n) }
        var stamp = now.getFullYear() + pad(now.getMonth() + 1) + pad(now.getDate()) + "-" + pad(now.getHours()) + pad(now.getMinutes()) + pad(now.getSeconds())
        return _screenshotDir + "/marathon-" + modeLabel.toLowerCase() + "-" + stamp + ".png"
    }

    function _launchGrim(extraArgs, modeLabel, annotate) {
        var outPath = _makeCapturePath(modeLabel)
        lastCapturePath = outPath
        _pendingCaptureMode = modeLabel
        _pendingAnnotate = !!annotate
        var cmd = ["grim"]
        for (var i = 0; i < extraArgs.length; ++i) cmd.push(extraArgs[i])
        cmd.push(outPath)
        _grimProc.command = cmd
        _grimProc.running = true
    }

    function refreshClipboard() {
        if (!clipboardAvailable || _clipListProc.running) return
        _clipListProc.running = true
    }

    function copyText(text) {
        var clean = String(text || "")
        if (clean === "" || !_hasWlCopy) return
        lastCopiedText = clean
        _wlCopyProc.command = ["wl-copy", "--", clean]
        _wlCopyProc.running = true
        statusNote = "COPIED TO CLIPBOARD"
        clipboardCopied(clean.slice(0, 48))
    }

    function copyClipboardItem(id) {
        if (!clipboardAvailable || _clipDecodeProc.running) return
        _pendingDecodeAction = "copy"
        _pendingDecodeId = String(id)
        _clipDecodeProc.command = ["cliphist", "decode", String(id)]
        _clipDecodeProc.running = true
    }

    function togglePinClipboard(id) {
        var sid = String(id)
        var nextPins = _pinnedIds.slice()
        var idx = nextPins.indexOf(sid)
        if (idx === -1) nextPins.push(sid)
        else nextPins.splice(idx, 1)
        _pinnedIds = nextPins.slice(-50)
        _pinStore.set("pinnedIds", _pinnedIds)
        refreshClipboard()
    }

    // A11: clipboard pin ids (cliphist row ids only, max 50) persist; content never does.
    property StateStore _pinStore: StateStore {
        fileName: "clipboard-pins.json"
        onLoaded: {
            var saved = get("pinnedIds", [])
            if (Array.isArray(saved)) root._pinnedIds = saved.map(String).filter(function(s) { return /^[0-9]{1,12}$/.test(s) }).slice(-50)
        }
    }

    function deleteClipboardItem(id) {
        if (!clipboardAvailable) return
        var sid = String(id)
        var preview = ""
        for (var i = 0; i < clipboardItems.length; ++i) {
            if (clipboardItems[i].id === sid) {
                preview = clipboardItems[i].text
                break
            }
        }
        if (preview !== "" && !_clipActionProc.running) {
            _clipActionProc.command = ["cliphist", "delete-query", preview]
            _clipActionProc.running = true
        }
    }

    function clearClipboard() {
        if (!clipboardAvailable || _clipActionProc.running) return
        _clipActionProc.command = ["cliphist", "wipe"]
        _clipActionProc.running = true
        statusNote = "CLIPBOARD HISTORY WIPED"
    }

    function captureRegion(annotate) {
        if (!captureAvailable || !_hasSlurp || captureBusy) return
        captureBusy = true
        _pendingCaptureMode = "REGION"
        _pendingAnnotate = !!annotate
        var selCol = Tokens.colorHex(Tokens.signal) + "FF"
        var bgCol = Tokens.colorHex(Tokens.background) + "88"
        _slurpProc.command = ["slurp", "-c", selCol, "-b", bgCol]
        _slurpProc.running = true
    }

    function captureWindow(annotate) {
        if (!captureAvailable || captureBusy) return
        captureBusy = true
        _pendingCaptureMode = "WINDOW"
        _pendingAnnotate = !!annotate
        _activeWinGeomProc.running = true
    }

    function captureFullscreen(annotate) {
        if (!captureAvailable || captureBusy) return
        captureBusy = true
        _launchGrim([], "FULLSCREEN", !!annotate)
    }

    function pickColor() {
        if (!pickerAvailable || _pickerProc.running) return
        _pickerProc.command = ["hyprpicker", "-a", "-f", "hex"]
        _pickerProc.running = true
    }

    function setMonitorActive(active) {
        monitorActive = !!active
        if (monitorActive) refreshSystemMetrics()
    }

    function refreshSystemMetrics() {
        _procStatView.reload()
        _procMemView.reload()
        _loadAvgView.reload()
        _tempZoneView.reload()
        if (!_dfProc.running) _dfProc.running = true
        if (!_psProc.running) _psProc.running = true
    }

    function killProcess(pid) {
        var num = Math.floor(Number(pid))
        if (isNaN(num) || num <= 1 || _killProc.running) return
        _killProc.command = ["kill", "-TERM", String(num)]
        _killProc.running = true
    }

    function launchExternalMonitor() {
        launchAppCommand("btop")
    }

    function launchAppCommand(cmdName) {
        var clean = String(cmdName || "").trim().toLowerCase()
        var allow = {
            "terminal": "ghostty",
            "files": "dolphin",
            "browser": "firefox",
            "btop": "ghostty --title marathon-btop -e btop",
            "yazi": "ghostty --title marathon-yazi -e yazi",
            "mixer": "pavucontrol"
        }
        var target = allow[clean]
        if (!target) return
        if (Hyprland.workspaces !== null) {
            Hyprland.dispatch("exec " + target)
            statusNote = "DISPATCHED: " + clean.toUpperCase()
        }
    }

    function setStreamVolume(id, nextVolume) {
        var clamped = Math.max(0.0, Math.min(1.0, Number(nextVolume)))
        for (var i = 0; i < _streamNodes.length; ++i) {
            if (String(_streamNodes[i].id) === String(id) && _streamNodes[i].audio) {
                _streamNodes[i].audio.volume = clamped
                if (clamped > 0 && _streamNodes[i].audio.muted) _streamNodes[i].audio.muted = false
                return
            }
        }
    }

    function toggleStreamMute(id) {
        for (var i = 0; i < _streamNodes.length; ++i) {
            if (String(_streamNodes[i].id) === String(id) && _streamNodes[i].audio) {
                _streamNodes[i].audio.muted = !_streamNodes[i].audio.muted
                return
            }
        }
    }

    function toggleNightLight() {
        if (!nightLightAvailable) return
        nightLightEnabled = !nightLightEnabled
        if (nightLightEnabled) {
            if (_nightLightProc.running) {
                _nightLightKillProc.running = true
            } else {
                _nightLightProc.command = ["hyprsunset", "-t", String(nightLightTemp)]
                _nightLightProc.running = true
            }
            statusNote = "NIGHT LIGHT ON (" + nightLightTemp + "K)"
        } else {
            _nightLightProc.running = false
            _nightLightKillProc.running = true
            statusNote = "NIGHT LIGHT OFF"
        }
    }

    function setNightLightTemp(kelvin) {
        var k = Math.max(2500, Math.min(6500, Math.round(Number(kelvin))))
        nightLightTemp = k
        if (nightLightEnabled && nightLightAvailable) {
            _nightLightProc.running = false
            _nightLightKillProc.running = true
            statusNote = "NIGHT LIGHT TEMP: " + k + "K"
        }
    }

    function toggleGameMode() {
        gameModeEnabled = !gameModeEnabled
        if (Hyprland.workspaces !== null) {
            if (gameModeEnabled) {
                _gameModeProc.command = ["hyprctl", "--batch", "keyword animations:enabled 0 ; keyword decoration:shadow:enabled 0 ; keyword decoration:blur:enabled 0 ; keyword general:gaps_in 0 ; keyword general:gaps_out 0 ; keyword general:border_size 1"]
            } else {
                _gameModeProc.command = ["hyprctl", "reload"]
            }
            _gameModeProc.running = true
        }
        statusNote = gameModeEnabled ? "GAME MODE ARMED" : "GAME MODE DISENGAGED"
    }

    function setScratchpadText(txt) {
        scratchpadText = String(txt || "")
        if (_dirReady) _scratchpadFile.setText(scratchpadText)
    }

    function togglePomodoro() {
        pomodoroRunning = !pomodoroRunning
        statusNote = pomodoroRunning ? (pomodoroMode + " RUNNING") : (pomodoroMode + " PAUSED")
    }

    function resetPomodoro() {
        pomodoroRunning = false
        pomodoroRemainingSec = pomodoroTotalSec
        statusNote = pomodoroMode + " RESET"
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
