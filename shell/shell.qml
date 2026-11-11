pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "services" as Services
import "panels" as Panels
import "launcher" as LauncherMod
import "control-center" as ControlMod
import "notifications" as NotifMod
import "osd" as OsdMod
import "settings" as SettingsMod
import "utilities" as UtilitiesMod

ShellRoot {
    id: shellRoot

    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool notificationsOpen: false
    property bool sessionOpen: false
    property bool settingsOpen: false
    property bool clipboardOpen: false
    property bool captureOpen: false
    property bool sysmonOpen: false
    property bool calendarOpen: false
    property bool cheatsheetOpen: false

    function closeAllOverlays() {
        launcherOpen = false
        controlCenterOpen = false
        notificationsOpen = false
        sessionOpen = false
        settingsOpen = false
        clipboardOpen = false
        captureOpen = false
        sysmonOpen = false
        calendarOpen = false
        cheatsheetOpen = false
    }

    function toggleOverlay(name) {
        var nextLauncher = (name === "launcher") ? !launcherOpen : false
        var nextControl = (name === "control") ? !controlCenterOpen : false
        var nextNotif = (name === "notifications") ? !notificationsOpen : false
        var nextSession = (name === "session") ? !sessionOpen : false
        var nextSettings = (name === "settings") ? !settingsOpen : false
        var nextClipboard = (name === "clipboard") ? !clipboardOpen : false
        var nextCapture = (name === "capture") ? !captureOpen : false
        var nextSysmon = (name === "sysmon") ? !sysmonOpen : false
        var nextCalendar = (name === "calendar") ? !calendarOpen : false
        var nextCheatsheet = (name === "cheatsheet") ? !cheatsheetOpen : false

        launcherOpen = nextLauncher
        controlCenterOpen = nextControl
        notificationsOpen = nextNotif
        sessionOpen = nextSession
        settingsOpen = nextSettings
        clipboardOpen = nextClipboard
        captureOpen = nextCapture
        sysmonOpen = nextSysmon
        calendarOpen = nextCalendar
        cheatsheetOpen = nextCheatsheet
    }

    function handleSafeCommand(cmdId) {
        if (cmdId === "toggle-dnd") liveBackend.notifications.toggleDnd()
        else if (cmdId === "toggle-motion") liveBackend.appearance.toggleReducedMotion()
        else if (cmdId === "toggle-nightlight") liveBackend.utilities.toggleNightLight()
        else if (cmdId === "toggle-gamemode") liveBackend.utilities.toggleGameMode()
        else if (cmdId === "open-control") toggleOverlay("control")
        else if (cmdId === "open-settings") toggleOverlay("settings")
        else if (cmdId === "open-clipboard") toggleOverlay("clipboard")
        else if (cmdId === "open-capture") toggleOverlay("capture")
        else if (cmdId === "open-sysmon") toggleOverlay("sysmon")
        else if (cmdId === "open-calendar") toggleOverlay("calendar")
        else if (cmdId === "open-cheatsheet") toggleOverlay("cheatsheet")
        else if (cmdId === "lock-session") {
            closeAllOverlays()
            liveBackend.session.lock()
        }
    }

    Services.LiveBackend {
        id: liveBackend
    }

    Component.onCompleted: {
        // Resolve repository/installed hyprlock config adjacent to shell/ if present
        var rootPath = Qt.resolvedUrl("../hypr/hyprlock.conf").toString()
        if (rootPath.indexOf("file://") === 0) {
            liveBackend.session.hyprlockConfigPath = rootPath.slice(7)
        }
    }

    // Native Hyprland GlobalShortcuts (active without spawning CLI processes)
    GlobalShortcut {
        appid: "marathon-tactical"
        name: "launcher"
        description: "Toggle MARATHON Tactical Launcher"
        onPressed: shellRoot.toggleOverlay("launcher")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "control-center"
        description: "Toggle MARATHON Tactical Control Center"
        onPressed: shellRoot.toggleOverlay("control")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "notifications"
        description: "Toggle MARATHON Tactical Notification Center"
        onPressed: shellRoot.toggleOverlay("notifications")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "session"
        description: "Toggle MARATHON Tactical Session Menu"
        onPressed: shellRoot.toggleOverlay("session")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "settings"
        description: "Toggle MARATHON Tactical Settings Hub"
        onPressed: shellRoot.toggleOverlay("settings")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "clipboard"
        description: "Toggle MARATHON Tactical Clipboard Vault"
        onPressed: shellRoot.toggleOverlay("clipboard")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "capture"
        description: "Toggle MARATHON Tactical Capture Suite"
        onPressed: shellRoot.toggleOverlay("capture")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "sysmon"
        description: "Toggle MARATHON Tactical System Monitor"
        onPressed: shellRoot.toggleOverlay("sysmon")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "calendar"
        description: "Toggle MARATHON Tactical Calendar & Pomodoro"
        onPressed: shellRoot.toggleOverlay("calendar")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "cheatsheet"
        description: "Toggle MARATHON Tactical Keybinds Briefing"
        onPressed: shellRoot.toggleOverlay("cheatsheet")
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "nightlight"
        description: "Toggle MARATHON Night Light (hyprsunset)"
        onPressed: liveBackend.utilities.toggleNightLight()
    }

    GlobalShortcut {
        appid: "marathon-tactical"
        name: "gamemode"
        description: "Toggle MARATHON Tactical Game Mode"
        onPressed: liveBackend.utilities.toggleGameMode()
    }

    // External IPC channel (`qs ipc call marathon <method>`)
    IpcHandler {
        target: "marathon"

        function toggleLauncher(): void {
            shellRoot.toggleOverlay("launcher")
        }

        function toggleControlCenter(): void {
            shellRoot.toggleOverlay("control")
        }

        function toggleNotifications(): void {
            shellRoot.toggleOverlay("notifications")
        }

        function toggleSession(): void {
            shellRoot.toggleOverlay("session")
        }

        function toggleSettings(): void {
            shellRoot.toggleOverlay("settings")
        }

        function toggleClipboard(): void {
            shellRoot.toggleOverlay("clipboard")
        }

        function toggleCapture(): void {
            shellRoot.toggleOverlay("capture")
        }

        function toggleSystemMonitor(): void {
            shellRoot.toggleOverlay("sysmon")
        }

        function toggleCalendar(): void {
            shellRoot.toggleOverlay("calendar")
        }

        function toggleCheatsheet(): void {
            shellRoot.toggleOverlay("cheatsheet")
        }

        function toggleNightLight(): void {
            liveBackend.utilities.toggleNightLight()
        }

        function toggleGameMode(): void {
            liveBackend.utilities.toggleGameMode()
        }

        function openSettingsSection(sectionId: string): void {
            if (liveBackend.settings && sectionId !== "") {
                liveBackend.settings.setSection(sectionId)
            }
            shellRoot.closeAllOverlays()
            shellRoot.settingsOpen = true
        }

        function closeAll(): void {
            shellRoot.closeAllOverlays()
        }

        function lock(): void {
            shellRoot.closeAllOverlays()
            liveBackend.session.lock()
        }

        function refreshBrightnessOsd(): void {
            liveBackend.brightness.refresh(true)
        }

        function toggleReducedMotion(): void {
            liveBackend.appearance.toggleReducedMotion()
        }
    }

    Panels.BackdropWindow {
        backend: liveBackend
    }

    Panels.TopHudWindow {
        backend: liveBackend
        launcherOpen: shellRoot.launcherOpen
        controlCenterOpen: shellRoot.controlCenterOpen
        notificationsOpen: shellRoot.notificationsOpen
        sessionOpen: shellRoot.sessionOpen
        settingsOpen: shellRoot.settingsOpen
        calendarOpen: shellRoot.calendarOpen

        onLauncherRequested: shellRoot.toggleOverlay("launcher")
        onControlCenterRequested: shellRoot.toggleOverlay("control")
        onNotificationsRequested: shellRoot.toggleOverlay("notifications")
        onSessionMenuRequested: shellRoot.toggleOverlay("session")
        onSettingsRequested: shellRoot.toggleOverlay("settings")
        onCalendarRequested: shellRoot.toggleOverlay("calendar")
    }

    LauncherMod.LauncherWindow {
        backend: liveBackend
        open: shellRoot.launcherOpen
        onCloseRequested: shellRoot.launcherOpen = false
        onSafeCommandTriggered: function(cmdId) { shellRoot.handleSafeCommand(cmdId) }
    }

    ControlMod.ControlCenterWindow {
        backend: liveBackend
        open: shellRoot.controlCenterOpen
        onCloseRequested: shellRoot.controlCenterOpen = false
        onOpenNotificationsRequested: shellRoot.toggleOverlay("notifications")
        onOpenSessionRequested: shellRoot.toggleOverlay("session")
        onOpenSettingsRequested: shellRoot.toggleOverlay("settings")
        onOpenClipboardRequested: shellRoot.toggleOverlay("clipboard")
        onOpenCaptureRequested: shellRoot.toggleOverlay("capture")
        onOpenSysmonRequested: shellRoot.toggleOverlay("sysmon")
        onOpenCalendarRequested: shellRoot.toggleOverlay("calendar")
        onOpenCheatsheetRequested: shellRoot.toggleOverlay("cheatsheet")
    }

    NotifMod.NotificationCenterWindow {
        backend: liveBackend
        open: shellRoot.notificationsOpen
        onCloseRequested: shellRoot.notificationsOpen = false
    }

    NotifMod.NotificationToastWindow {
        backend: liveBackend
        suppressed: shellRoot.notificationsOpen || shellRoot.controlCenterOpen || shellRoot.settingsOpen || liveBackend.session.locked
    }

    Panels.SessionMenuWindow {
        backend: liveBackend
        open: shellRoot.sessionOpen
        onCloseRequested: shellRoot.sessionOpen = false
    }

    SettingsMod.SettingsWindow {
        backend: liveBackend
        open: shellRoot.settingsOpen
        onCloseRequested: shellRoot.settingsOpen = false
        onOpenNotificationsRequested: shellRoot.toggleOverlay("notifications")
        onOpenSessionRequested: shellRoot.toggleOverlay("session")
    }

    UtilitiesMod.ClipboardWindow {
        backend: liveBackend
        open: shellRoot.clipboardOpen
        onCloseRequested: shellRoot.clipboardOpen = false
    }

    UtilitiesMod.CaptureWindow {
        backend: liveBackend
        open: shellRoot.captureOpen
        onCloseRequested: shellRoot.captureOpen = false
        onOpenClipboardRequested: shellRoot.toggleOverlay("clipboard")
    }

    UtilitiesMod.SystemMonitorWindow {
        backend: liveBackend
        open: shellRoot.sysmonOpen
        onCloseRequested: shellRoot.sysmonOpen = false
    }

    UtilitiesMod.CalendarWindow {
        backend: liveBackend
        open: shellRoot.calendarOpen
        onCloseRequested: shellRoot.calendarOpen = false
    }

    UtilitiesMod.CheatsheetWindow {
        backend: liveBackend
        open: shellRoot.cheatsheetOpen
        onCloseRequested: shellRoot.cheatsheetOpen = false
        onTriggerActionRequested: function(actId) { shellRoot.handleSafeCommand(actId) }
    }

    OsdMod.OsdWindow {
        backend: liveBackend
    }
}

