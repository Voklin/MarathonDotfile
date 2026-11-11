import QtQuick

QtObject {
    id: root

    property string activeScenarioId: "S01"

    property WorkspacesMock workspaces: WorkspacesMock {}
    property ActiveWindowMock activeWindow: ActiveWindowMock {}
    property AudioMock audio: AudioMock {}
    property NetworkMock network: NetworkMock {}
    property BluetoothMock bluetooth: BluetoothMock {}
    property BatteryMock battery: BatteryMock {}
    property BrightnessMock brightness: BrightnessMock {}
    property NotificationsMock notifications: NotificationsMock {}
    property SessionMock session: SessionMock {}
    property LauncherMock launcher: LauncherMock {}
    property AppearanceMock appearance: AppearanceMock {}
    property SettingsMock settings: SettingsMock {}
    property MediaMock media: MediaMock {}
    property UtilitiesMock utilities: UtilitiesMock {}
    property TrayMock tray: TrayMock {}
    property KeyboardMock keyboard: KeyboardMock {}

    function resetDefaults() {
        workspaces.available = true
        workspaces.loading = false
        workspaces.errorMessage = ""
        workspaces.activeWorkspaceId = 1
        workspaces.monitors = [
            { name: "eDP-1", label: "PRIMARY // 1920x1080", activeWorkspaceId: 1, primary: true }
        ]
        workspaces.items = [
            { id: 1, name: "01", monitor: "eDP-1", occupied: true, active: true, urgent: false, windowsCount: 2 },
            { id: 2, name: "02", monitor: "eDP-1", occupied: true, active: false, urgent: false, windowsCount: 1 },
            { id: 3, name: "03", monitor: "eDP-1", occupied: false, active: false, urgent: false, windowsCount: 0 },
            { id: 4, name: "04", monitor: "eDP-1", occupied: true, active: false, urgent: false, windowsCount: 3 },
            { id: 5, name: "05", monitor: "eDP-1", occupied: false, active: false, urgent: false, windowsCount: 0 },
            { id: 6, name: "06", monitor: "eDP-1", occupied: false, active: false, urgent: false, windowsCount: 0 }
        ]

        activeWindow.available = true
        activeWindow.loading = false
        activeWindow.errorMessage = ""
        activeWindow.title = "ghostty — marathon-tactical/ui"
        activeWindow.appId = "com.mitchellh.ghostty"
        activeWindow.fullscreen = false
        activeWindow.floating = false
        activeWindow.monitor = "eDP-1"

        audio.available = true
        audio.loading = false
        audio.errorMessage = ""
        audio.volume = 0.65
        audio.muted = false
        audio.sinkName = "UESC Tactical Headset (Analog)"
        audio.micAvailable = true
        audio.micMuted = false
        audio.micVolume = 0.80

        network.available = true
        network.loading = false
        network.errorMessage = ""
        network.connected = true
        network.connectionType = "wifi"
        network.ssid = "TAU-CETI-5G"
        network.interfaceName = "wlan0"
        network.signalStrength = 86
        network.wifiEnabled = true
        network.ipAddress = "10.42.8.19"

        bluetooth.available = true
        bluetooth.loading = false
        bluetooth.errorMessage = ""
        bluetooth.powered = true
        bluetooth.connectedDevice = "MX-TACTICAL MOUSE"

        battery.available = true
        battery.loading = false
        battery.errorMessage = ""
        battery.percentage = 82
        battery.charging = false
        battery.pluggedIn = false
        battery.stateLabel = "DISCHARGING"
        battery.timeRemaining = "04h 18m"
        battery.powerProfile = "balanced"

        brightness.available = true
        brightness.loading = false
        brightness.errorMessage = ""
        brightness.level = 0.72
        brightness.deviceName = "intel_backlight"

        notifications.available = true
        notifications.loading = false
        notifications.errorMessage = ""
        notifications.dnd = false
        notifications.items = [
            {
                id: 1,
                appName: "HYPRLAND",
                summary: "Display topology synchronized",
                body: "eDP-1 active at 1920x1080@144Hz. Profile MARATHON_TACTICAL ready.",
                urgency: "normal",
                timestamp: "23:40",
                read: false,
                popupVisible: false,
                actions: [{ id: "inspect", label: "INSPECT" }]
            },
            {
                id: 2,
                appName: "NETWORK",
                summary: "Uplink secured: TAU-CETI-5G",
                body: "WPA3 handshake verified on interface wlan0 (10.42.8.19).",
                urgency: "low",
                timestamp: "23:36",
                read: true,
                popupVisible: false,
                actions: []
            },
            {
                id: 3,
                appName: "POWER",
                summary: "Thermal profile balanced",
                body: "Acoustic envelope nominal; battery telemetry streaming via UPower.",
                urgency: "normal",
                timestamp: "23:28",
                read: true,
                popupVisible: false,
                actions: []
            }
        ]

        session.available = true
        session.loading = false
        session.errorMessage = ""
        session.locked = false
        session.pendingAction = ""
        session.authError = ""
        session.statusMessage = "SESSION ACTIVE // MOCK GUARD ENABLED"

        launcher.available = true
        launcher.loading = false
        launcher.errorMessage = ""
        launcher.query = ""
        launcher.lastActionNote = ""

        appearance.available = true
        appearance.reducedMotion = false
        appearance.hudAutoHideOnFullscreen = true
        appearance.uiScale = 1.0
        appearance.clockText = "23:42:08"
        appearance.dateText = "TUE 10 NOV"
        appearance.sysLabel = "SYS // ONLINE"

        media.available = true
        media.activePlayerId = "spotify"

        utilities.available = true
        utilities.clipboardAvailable = true
        utilities.captureAvailable = true
        utilities.pickerAvailable = true
        utilities.monitorAvailable = true
        utilities.nightLightAvailable = true
        utilities.nightLightEnabled = false
        utilities.nightLightTemp = 4200
        utilities.gameModeEnabled = false
        utilities.pomodoroRunning = false
        utilities.pomodoroRemainingSec = 1500
        utilities.pomodoroTotalSec = 1500
        utilities.pomodoroMode = "FOCUS"
    }

    function applyScenario(scenarioId) {
        resetDefaults()
        activeScenarioId = scenarioId

        if (scenarioId === "S01") {
            return
        }
        if (scenarioId === "S02") {
            workspaces.monitors = [
                { name: "DP-1", label: "QHD // 2560x1440", activeWorkspaceId: 2, primary: true }
            ]
            workspaces.switchWorkspace(2)
            activeWindow.title = "nvim — ui/tokens/Tokens.qml [MARATHON_TACTICAL]"
            activeWindow.appId = "neovim"
            battery.charging = true
            battery.pluggedIn = true
            battery.percentage = 96
            battery.stateLabel = "CHARGING"
            return
        }
        if (scenarioId === "S03") {
            activeWindow.title = "alacritty — cachyos-laptop"
            activeWindow.appId = "Alacritty"
            battery.percentage = 14
            battery.charging = false
            battery.stateLabel = "LOW BATTERY"
            battery.timeRemaining = "00h 24m"
            return
        }
        if (scenarioId === "S04") {
            appearance.uiScale = 1.5
            appearance.sysLabel = "SYS // HIDPI 1.5X"
            activeWindow.title = "firefox — Wayland Fractional Scale Check"
            activeWindow.appId = "org.mozilla.firefox"
            return
        }
        if (scenarioId === "S05") {
            activeWindow.appId = "org.kde.dolphin.long.subsystem.identifier"
            activeWindow.title = "MARATHON Tactical — Очень длинный заголовок окна с кириллицей, 日本語テスト, Unicode ⚡ и техническими параметрами [2560x1440 / Wayland / Hyprland IPC]"
            return
        }
        if (scenarioId === "S06") {
            network.available = true
            network.connected = false
            network.connectionType = "offline"
            network.ssid = ""
            network.signalStrength = 0
            network.wifiEnabled = false
            network.errorMessage = "NETWORKMANAGER OFFLINE // NO CARRIER"
            appearance.sysLabel = "SYS // OFFLINE"
            return
        }
        if (scenarioId === "S07") {
            audio.volume = 0.0
            audio.muted = true
            audio.micMuted = true
            audio.osdTriggered("audio", 0.0, true, audio.sinkName)
            return
        }
        if (scenarioId === "S08") {
            battery.available = false
            battery.stateLabel = "AC DIRECT"
            brightness.available = false
            brightness.deviceName = ""
            bluetooth.available = false
            bluetooth.powered = false
            bluetooth.connectedDevice = ""
            appearance.sysLabel = "SYS // DESKTOP RIG"
            return
        }
        if (scenarioId === "S09") {
            var flood = []
            var apps = ["SYSTEM", "PIPEWIRE", "HYPRLAND", "NETWORK", "SECURITY", "COMPILER"]
            for (var i = 1; i <= 16; ++i) {
                var crit = (i === 1 || i === 5)
                flood.push({
                    id: 200 + i,
                    appName: apps[i % apps.length],
                    summary: crit ? ("CRITICAL ALERT #" + i + ": Telemetry buffer threshold exceeded") : ("Event packet #" + i + " processed cleanly"),
                    body: "Diagnostic stream payload " + i + " for scrollable Notification Center density and overflow check.",
                    urgency: crit ? "critical" : (i % 3 === 0 ? "low" : "normal"),
                    timestamp: "23:" + (25 + i),
                    read: i > 6,
                    popupVisible: i <= 2,
                    actions: crit ? [{ id: "ack", label: "ACK" }, { id: "mute", label: "MUTE" }] : []
                })
            }
            notifications.items = flood
            return
        }
        if (scenarioId === "S10") {
            workspaces.monitors = [
                { name: "eDP-1", label: "LAPTOP // 1920x1080", activeWorkspaceId: 2, primary: true },
                { name: "DP-2", label: "EXT // 2560x1440", activeWorkspaceId: 7, primary: false }
            ]
            workspaces.activeWorkspaceId = 2
            workspaces.items = [
                { id: 1, name: "01", monitor: "eDP-1", occupied: true, active: false, urgent: false, windowsCount: 1 },
                { id: 2, name: "02", monitor: "eDP-1", occupied: true, active: true, urgent: false, windowsCount: 3 },
                { id: 3, name: "03", monitor: "eDP-1", occupied: false, active: false, urgent: false, windowsCount: 0 },
                { id: 4, name: "04", monitor: "eDP-1", occupied: true, active: false, urgent: true, windowsCount: 2 },
                { id: 5, name: "05", monitor: "eDP-1", occupied: false, active: false, urgent: false, windowsCount: 0 },
                { id: 6, name: "06", monitor: "DP-2", occupied: true, active: false, urgent: false, windowsCount: 1 },
                { id: 7, name: "07", monitor: "DP-2", occupied: true, active: true, urgent: false, windowsCount: 2 },
                { id: 8, name: "08", monitor: "DP-2", occupied: false, active: false, urgent: false, windowsCount: 0 }
            ]
            activeWindow.title = "mpv — Fullscreen Telemetry Check"
            activeWindow.fullscreen = true
            return
        }
    }
}

