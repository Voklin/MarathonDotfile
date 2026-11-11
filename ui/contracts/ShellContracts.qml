import QtQuick

QtObject {
    id: root

    // Fallback safe contract objects used when no adapter is bound or in isolated unit tests
    property var workspaces: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property var items: []
        property var monitors: []
        property int activeWorkspaceId: 1
        function switchWorkspace(id) {}
        function moveFocusedToWorkspace(id) {}
    }

    property var activeWindow: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property string title: ""
        property string appId: ""
        property bool fullscreen: false
        property bool floating: false
        property string monitor: ""
        function toggleFloating() {}
        function toggleFullscreen() {}
        function closeActive() {}
    }

    property var audio: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property real volume: 0.0
        property bool muted: true
        property string sinkName: ""
        property var sinks: []
        property bool micAvailable: false
        property bool micMuted: true
        property real micVolume: 0.0
        signal osdTriggered(string kind, real level, bool muted, string detail)
        function setVolume(nextVolume) {}
        function toggleMute() {}
        function selectSink(id) {}
        function toggleMicMute() {}
        function setMicVolume(nextVolume) {}
    }

    property var network: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property bool connected: false
        property string connectionType: "offline"
        property string ssid: ""
        property string interfaceName: ""
        property int signalStrength: 0
        property bool wifiEnabled: false
        property string ipAddress: ""
        property var networks: []
        function toggleWifi() {}
        function connectNetwork(ssid) {}
        function disconnect() {}
    }

    property var bluetooth: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property bool powered: false
        property string connectedDevice: ""
        property var devices: []
        function togglePower() {}
        function toggleDevice(address) {}
    }

    property var battery: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property int percentage: 0
        property bool charging: false
        property bool pluggedIn: false
        property string stateLabel: "UNAVAILABLE"
        property string timeRemaining: ""
        property string powerProfile: "balanced"
        function cyclePowerProfile() {}
        function setPowerProfile(profile) {}
    }

    property var brightness: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property real level: 0.0
        property string deviceName: ""
        signal osdTriggered(string kind, real level, bool muted, string detail)
        function setLevel(nextLevel) {}
    }

    property var notifications: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property bool dnd: false
        property var items: []
        property var popupItems: []
        property int unreadCount: 0
        function toggleDnd() {}
        function dismiss(id) {}
        function dismissPopup(id) {}
        function clearAll() {}
        function invokeAction(id, actionId) {}
        function pushNotification(appName, summary, body, urgency, actions) {}
    }

    property var session: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property string userName: ""
        property string hostName: ""
        property bool locked: false
        property bool canSuspend: false
        property string pendingAction: ""
        property string statusMessage: ""
        property string authError: ""
        function requestAction(action) {}
        function confirmAction() {}
        function cancelAction() {}
        function lock() {}
        function unlock(password) {}
    }

    property var launcher: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property string query: ""
        property var entries: []
        property var recentIds: []
        property var safeCommands: []
        property string lastActionNote: ""
        function setQuery(q) {}
        function filteredEntries() { return [] }
        function launchEntry(id) {}
        function runSafeCommand(id) {}
    }

    property var appearance: QtObject {
        property bool available: true
        property bool loading: false
        property string errorMessage: ""
        property bool reducedMotion: false
        property bool hudAutoHideOnFullscreen: true
        property real uiScale: 1.0
        property string clockText: "00:00:00"
        property string dateText: "---"
        property string uptimeText: "00:00"
        property string sysLabel: "SYS // INIT"
        property string faction: "RUNNER"
        property string emblem: "U73_CRUCIFORM"
        property string runnerName: "RUNNER"
        property string runnerTitle: "OPERATOR"
        function setFaction(nextFaction) {}
        function setEmblem(nextEmblem) {}
        function setRunnerName(nextName) {}
        function setRunnerTitle(nextTitle) {}
        function toggleReducedMotion() {}
        function toggleHudAutoHide() {}
    }

    property var settings: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property bool dirty: false
        property string statusNote: ""
        property string activeSection: "profile"
        property string searchQuery: ""
        property string settingsFilePath: ""
        property string hyprOverridePath: ""
        property var hostSpecs: ({})
        property string hudPosition: "top"
        property int hudHeight: 38
        property bool hudMultiMonitorAll: true
        property bool showRunnerBadge: true
        property bool showMonitorTag: true
        property bool showWorkspaces: true
        property bool showActiveWindow: true
        property bool showAudioPill: true
        property bool showNetworkPill: true
        property bool showBatteryPill: true
        property bool showClockSeconds: true
        property bool showDateInClock: true
        property bool use24HourClock: true
        property string surfaceTheme: "TACTICAL"
        property string customAccentHex: ""
        property int cornerRadius: 0
        property int borderThickness: 1
        property real motionMultiplier: 1.0
        property string wallpaperId: "matrix"
        property bool backdropMatrixEnabled: true
        property real backdropMatrixOpacity: 0.42
        property real backdropDim: 0.0
        property bool wallpaperAccentSync: false
        property bool appThemeSyncEnabled: true
        property string launcherDefaultLayout: "list"
        property bool launcherShowRecents: true
        property int launcherMaxRecents: 6
        property bool launcherShowCommandsTab: true
        property bool launcherCloseOnLaunch: true
        property string toastPosition: "top-right"
        property int toastTimeoutMs: 5000
        property int toastMaxVisible: 3
        property bool osdEnabled: true
        property int osdDurationMs: 1600
        property bool lockShowHostSpecimen: true
        property int idleLockMinutes: 10
        property int idleDpmsMinutes: 15
        property bool confirmPowerActions: true
        property string hyprLayout: "dwindle"
        property int hyprGapsIn: 4
        property int hyprGapsOut: 8
        property int hyprBorderSize: 2
        property int hyprRounding: 0
        property real hyprActiveOpacity: 1.0
        property real hyprInactiveOpacity: 1.0
        property bool hyprBlurEnabled: false
        property bool hyprShadowEnabled: false
        property bool hyprVfrEnabled: true
        property bool hyprAllowTearing: false
        property bool hyprResizeOnBorder: true
        property bool hyprAnimationsEnabled: true
        property real hyprAnimationSpeed: 1.0
        property string hyprAnimStyle: "tactical"
        property var displayConfigs: []
        property bool xwaylandForceZeroScaling: true
        property string kbLayout: "us"
        property string kbVariant: ""
        property string kbOptions: "grp:alt_shift_toggle"
        property int repeatRate: 35
        property int repeatDelay: 250
        property real pointerSensitivity: 0.0
        property string accelProfile: "flat"
        property int followMouse: 1
        property bool touchpadNaturalScroll: false
        property bool touchpadDisableWhileTyping: true
        property bool touchpadTapToClick: true
        property bool touchpadMiddleEmulation: false
        property string defaultTerminal: "ghostty"
        property string defaultFileManager: "dolphin"
        property string defaultBrowser: "firefox"
        property string defaultEditor: "nvim"
        property string defaultMediaPlayer: "mpv"
        property string defaultImageViewer: "imv"
        property string defaultPdfViewer: "zathura"
        property string defaultSystemMonitor: "btop"
        property bool bareSuperLauncher: false
        property var keybindCatalog: []
        property var customKeybinds: []
        property var builtinRules: []
        property var customWindowRules: []
        property var autostartItems: []
        property var envVars: []
        property string gpuRenderMode: "auto"
        property var gpuDevices: []
        property string generatedHyprConf: ""
        property string generatedAppThemesPreview: ""
        property var generatedThemeTargets: []
        signal settingsApplied(string section, string message)
        signal sectionReset(string section)
        function setSection(sectionId) {}
        function setSearchQuery(q) {}
        function setSetting(key, value) {}
        function updateDisplayConfig(name, patch) {}
        function addCustomKeybind(mods, key, dispatcher, arg) {}
        function toggleCustomKeybind(id) {}
        function removeCustomKeybind(id) {}
        function addWindowRule(name, matchType, pattern, floatWin, centerWin, pinWin) {}
        function toggleWindowRule(id) {}
        function removeWindowRule(id) {}
        function addAutostart(label, command) {}
        function toggleAutostart(id) {}
        function removeAutostart(id) {}
        function addEnvVar(key, value) {}
        function toggleEnvVar(id) {}
        function removeEnvVar(id) {}
        function applyAll() {}
        function reloadConfig() {}
        function resetSection(sectionId) {}
        function resetAllDefaults() {}
        function exportSettingsJson() { return "{}" }
    }

    property var media: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property string activePlayerId: ""
        property var players: []
        property bool hasPlayer: false
        property string identity: ""
        property string trackTitle: ""
        property string artist: ""
        property string album: ""
        property string artUrl: ""
        property bool playing: false
        property real position: 0
        property real length: 0
        property bool canPlay: false
        property bool canPause: false
        property bool canNext: false
        property bool canPrev: false
        function selectPlayer(id) {}
        function togglePlay() {}
        function next() {}
        function previous() {}
        function seekBy(seconds) {}
    }

    property var utilities: QtObject {
        property bool available: false
        property bool loading: false
        property string errorMessage: ""
        property string statusNote: ""
        property bool clipboardAvailable: false
        property string clipboardError: ""
        property var clipboardItems: []
        property string lastCopiedText: ""
        property bool captureAvailable: false
        property bool pickerAvailable: false
        property bool captureBusy: false
        property string lastCapturePath: ""
        property string lastPickedColor: ""
        property var recentCaptures: []
        property bool monitorAvailable: false
        property bool monitorActive: false
        property real cpuUsage: 0.0
        property int cpuTempC: 0
        property real ramUsedGib: 0.0
        property real ramTotalGib: 0.0
        property int diskUsedPct: 0
        property string diskSummary: ""
        property string loadAvg: ""
        property var processes: []
        property var audioStreams: []
        property bool nightLightAvailable: false
        property bool nightLightEnabled: false
        property int nightLightTemp: 4200
        property bool gameModeEnabled: false
        property string scratchpadText: ""
        property int pomodoroRemainingSec: 1500
        property int pomodoroTotalSec: 1500
        property bool pomodoroRunning: false
        property string pomodoroMode: "FOCUS"
        signal clipboardCopied(string label)
        signal captureCompleted(string mode, string path)
        signal colorPicked(string hexColor)
        function refreshClipboard() {}
        function copyText(text) {}
        function copyClipboardItem(id) {}
        function togglePinClipboard(id) {}
        function deleteClipboardItem(id) {}
        function clearClipboard() {}
        function captureRegion(annotate) {}
        function captureWindow(annotate) {}
        function captureFullscreen(annotate) {}
        function pickColor() {}
        function setMonitorActive(active) {}
        function refreshSystemMetrics() {}
        function killProcess(pid) {}
        function launchExternalMonitor() {}
        function launchAppCommand(cmdName) {}
        function setStreamVolume(id, nextVolume) {}
        function toggleStreamMute(id) {}
        function toggleNightLight() {}
        function setNightLightTemp(kelvin) {}
        function toggleGameMode() {}
        function setScratchpadText(txt) {}
        function togglePomodoro() {}
        function resetPomodoro() {}
        function setPomodoroPreset(minutes, modeLabel) {}
    }
}

