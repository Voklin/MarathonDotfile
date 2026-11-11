import QtQuick
import "../../ui/tokens"

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property bool dirty: false
    property string statusNote: "SETTINGS HUB READY // PREVIEW MOCK"
    property string activeSection: "profile"
    property string searchQuery: ""
    property string settingsFilePath: "~/.config/marathon-tactical/settings.json (preview)"
    property string hyprOverridePath: "~/.config/marathon-tactical/hypr/user-settings.conf (preview)"

    property var hostSpecs: ({
        hostname: "tau-ceti-ws01",
        distro: "CachyOS Linux x86_64 (Simulated)",
        kernel: "6.14.6-cachyos",
        cpu: "AMD Ryzen 9 7950X (32) @ 5.70 GHz",
        gpu: "AMD Radeon RX 7900 XTX [Discrete]",
        memory: "64.0 GiB DDR5-6000",
        compositor: "Hyprland >= 0.53 (Wayland)",
        shellVersion: "MARATHON Tactical v1.1 // Quickshell"
    })

    // Shell & HUD
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

    // Appearance & Wallpaper
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

    // Launcher, Notifications, OSD & Session
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

    // Hyprland Compositor Layout & Animations
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

    // Displays
    property var displayConfigs: [
        {
            name: "eDP-1",
            description: "Built-in Tactical Panel 144Hz",
            mode: "1920x1080@144",
            availableModes: ["preferred", "1920x1080@144", "1920x1080@60", "1366x768@60"],
            scale: 1.0,
            transform: 0,
            position: "0x0",
            enabled: true,
            primary: true
        },
        {
            name: "DP-2",
            description: "External QHD Monitor",
            mode: "2560x1440@144",
            availableModes: ["preferred", "2560x1440@144", "2560x1440@60", "3840x2160@60", "1920x1080@60"],
            scale: 1.0,
            transform: 0,
            position: "1920x0",
            enabled: true,
            primary: false
        }
    ]
    property bool xwaylandForceZeroScaling: true

    // Input & Peripherals
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

    // Keybinds & Default Apps
    property string defaultTerminal: "ghostty"
    property string defaultFileManager: "dolphin"
    property string defaultBrowser: "firefox"
    property string defaultEditor: "nvim"
    property string defaultMediaPlayer: "mpv"
    property string defaultImageViewer: "imv"
    property string defaultPdfViewer: "zathura"
    property string defaultSystemMonitor: "btop"
    property bool bareSuperLauncher: false

    readonly property var keybindCatalog: [
        { category: "SHELL", chord: "SUPER + ,", action: "Toggle Settings Hub", target: "marathon-tactical:settings" },
        { category: "SHELL", chord: "SUPER + SPACE / D", action: "Toggle Application Launcher", target: "marathon-tactical:launcher" },
        { category: "SHELL", chord: "SUPER + C", action: "Toggle Control Center", target: "marathon-tactical:control-center" },
        { category: "SHELL", chord: "SUPER + N", action: "Toggle Notification Center", target: "marathon-tactical:notifications" },
        { category: "SHELL", chord: "SUPER + X", action: "Toggle Session Menu", target: "marathon-tactical:session" },
        { category: "SHELL", chord: "SUPER + SHIFT + V", action: "Toggle Clipboard Vault (cliphist)", target: "marathon-tactical:clipboard" },
        { category: "SHELL", chord: "PRINT / SUPER+SHIFT+S", action: "Capture Suite & Color Picker", target: "marathon-tactical:capture" },
        { category: "SHELL", chord: "SUPER + M", action: "System Monitor & Audio Mixer", target: "marathon-tactical:sysmon" },
        { category: "SHELL", chord: "SUPER + A", action: "Calendar, Pomodoro & Scratchpad", target: "marathon-tactical:calendar" },
        { category: "SHELL", chord: "SUPER + / (or F1)", action: "Keybinds Briefing & Quick-Start", target: "marathon-tactical:cheatsheet" },
        { category: "SHELL", chord: "SUPER + SHIFT + N", action: "Toggle Night Light (hyprsunset)", target: "marathon-tactical:nightlight" },
        { category: "SHELL", chord: "SUPER + L", action: "Lock Workstation (hyprlock)", target: "exec hyprlock" },
        { category: "SHELL", chord: "SUPER + SHIFT + R", action: "Reload Quickshell", target: "pkill -x quickshell; quickshell" },
        { category: "APPS", chord: "SUPER + RETURN", action: "Launch Terminal", target: "$terminal" },
        { category: "APPS", chord: "SUPER + E", action: "Launch File Manager", target: "$fileManager" },
        { category: "APPS", chord: "SUPER + B", action: "Launch Browser", target: "$browser" },
        { category: "APPS", chord: "SUPER + T", action: "Launch TUI File Manager (yazi)", target: "$terminal -e yazi" },
        { category: "TILING", chord: "SUPER + Q", action: "Close Active Window", target: "killactive" },
        { category: "TILING", chord: "SUPER + V", action: "Toggle Floating Mode", target: "togglefloating" },
        { category: "TILING", chord: "SUPER + F", action: "Fullscreen (Auto-Hide HUD)", target: "fullscreen, 0" },
        { category: "TILING", chord: "SUPER + P / S", action: "Pseudo / Toggle Split", target: "pseudo / togglesplit" },
        { category: "WORKSPACES", chord: "SUPER + 1..9", action: "Switch Workspace 1..9", target: "workspace 1..9" },
        { category: "WORKSPACES", chord: "SUPER + SHIFT + 1..9", action: "Move Window to Workspace", target: "movetoworkspace 1..9" },
        { category: "HARDWARE", chord: "XF86AudioRaise/Lower/Mute", action: "PipeWire Volume & OSD", target: "wpctl" },
        { category: "HARDWARE", chord: "XF86MonBrightnessUp/Down", action: "Backlight & OSD", target: "brightnessctl" }
    ]

    property var customKeybinds: [
        { id: "kb-browser", mods: "SUPER", key: "B", dispatcher: "exec", arg: "firefox", enabled: true }
    ]

    // Window & Layer Rules
    readonly property var builtinRules: [
        { name: "marathon-float-utilities", matchExpr: "match:class ^(pavucontrol|nm-connection-editor|blueman-manager|polkit...)$", effect: "float = on, center = on" },
        { name: "marathon-float-portals", matchExpr: "match:class ^(xdg-desktop-portal-...)$", effect: "float = on, center = on" },
        { name: "marathon-float-dialogs", matchExpr: "match:title ^(Open File|Save File|Confirm|Preferences|Settings)$", effect: "float = on, center = on" },
        { name: "marathon-pip", matchExpr: "match:title ^(Picture-in-Picture|Picture in picture)$", effect: "float = on, pin = on" },
        { name: "marathon-fullscreen-idleinhibit", matchExpr: "match:fullscreen = true", effect: "idle_inhibit = focus" },
        { name: "marathon-shell-layers", matchExpr: "layerrule match:namespace ^marathon-(hud|launcher|...|settings)$", effect: "no_anim = on, blur = off" }
    ]

    property var customWindowRules: [
        { id: "wr-1", name: "custom-scratch-term", matchType: "class", pattern: "^(com\\.mitchellh\\.ghostty-float)$", floatWin: true, centerWin: true, pinWin: false, enabled: true }
    ]

    // Autostart, Env & GPU
    property var autostartItems: [
        { id: "as-1", label: "Polkit Authentication Agent", command: "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1", enabled: true },
        { id: "as-2", label: "Clipboard Watcher (wl-paste)", command: "wl-paste --type text --watch cliphist store", enabled: false }
    ]

    property var envVars: [
        { id: "env-1", key: "XCURSOR_SIZE", value: "24", enabled: true },
        { id: "env-2", key: "ELECTRON_OZONE_PLATFORM_HINT", value: "auto", enabled: true }
    ]

    property string gpuRenderMode: "auto"
    property var gpuDevices: [
        { id: "card0", vendor: "AMD", name: "Radeon RX 7900 XTX", role: "DISCRETE", active: true },
        { id: "card1", vendor: "AMD", name: "Raphael iGPU", role: "INTEGRATED", active: false }
    ]

    property string generatedHyprConf: ""
    property string generatedAppThemesPreview: ""
    property var generatedThemeTargets: [
        "apps/generated/ghostty-colors",
        "apps/generated/kitty-colors.conf",
        "apps/generated/alacritty-colors.toml",
        "apps/generated/foot-colors.ini",
        "apps/generated/btop-marathon.theme",
        "apps/generated/yazi-colors.toml",
        "apps/generated/gtk-colors.css",
        "apps/generated/qt6ct-colors.conf"
    ]

    property Connections _tokensConn: Connections {
        target: Tokens
        function onSignalChanged() {
            root._rebuildHyprConf()
            root._rebuildAppThemes()
        }
        function onBackgroundChanged() {
            root._rebuildAppThemes()
        }
    }

    signal settingsApplied(string section, string message)
    signal sectionReset(string section)

    function _colorToHyprRgba(c) {
        function hx(v) {
            var n = Math.max(0, Math.min(255, Math.round(v * 255)))
            var s = n.toString(16)
            return s.length < 2 ? ("0" + s) : s
        }
        return "rgba(" + hx(c.r) + hx(c.g) + hx(c.b) + hx(c.a) + ")"
    }

    function _rebuildHyprConf() {
        var lines = [
            "# ==============================================================================",
            "# MARATHON Tactical — GUI Settings Hub Isolated Overrides",
            "# Auto-generated inside ~/.config/marathon-tactical/hypr/user-settings.conf",
            "# NEVER modifies ~/.config/hypr/",
            "# ==============================================================================",
            "",
            "$terminal = " + (defaultTerminal || "ghostty"),
            "$fileManager = " + (defaultFileManager || "dolphin"),
            "$browser = " + (defaultBrowser || "firefox"),
            "$editor = " + (defaultEditor || "nvim"),
            "$mediaPlayer = " + (defaultMediaPlayer || "mpv"),
            "$imageViewer = " + (defaultImageViewer || "imv"),
            "$pdfViewer = " + (defaultPdfViewer || "zathura"),
            "$systemMonitor = " + (defaultSystemMonitor || "btop"),
            "",
            "general {",
            "    gaps_in = " + hyprGapsIn,
            "    gaps_out = " + hyprGapsOut,
            "    border_size = " + hyprBorderSize,
            "    col.active_border = " + _colorToHyprRgba(Tokens.signal),
            "    col.inactive_border = " + _colorToHyprRgba(Tokens.border),
            "    resize_on_border = " + (hyprResizeOnBorder ? "true" : "false"),
            "    allow_tearing = " + (hyprAllowTearing ? "true" : "false"),
            "    layout = " + hyprLayout,
            "}",
            "",
            "decoration {",
            "    rounding = " + hyprRounding,
            "    active_opacity = " + hyprActiveOpacity.toFixed(2),
            "    inactive_opacity = " + hyprInactiveOpacity.toFixed(2),
            "    shadow {",
            "        enabled = " + (hyprShadowEnabled ? "true" : "false"),
            "    }",
            "    blur {",
            "        enabled = " + (hyprBlurEnabled ? "true" : "false"),
            "    }",
            "}",
            "",
            "misc {",
            "    vfr = " + (hyprVfrEnabled ? "true" : "false"),
            "    background_color = " + _colorToHyprRgba(Tokens.background),
            "}",
            "",
            "animations {",
            "    enabled = " + (hyprAnimationsEnabled ? "yes" : "no"),
            "}",
            "",
            "input {",
            "    kb_layout = " + (kbLayout || "us"),
            "    kb_variant = " + (kbVariant || ""),
            "    kb_options = " + (kbOptions || ""),
            "    repeat_rate = " + repeatRate,
            "    repeat_delay = " + repeatDelay,
            "    follow_mouse = " + followMouse,
            "    sensitivity = " + pointerSensitivity.toFixed(2),
            "    accel_profile = " + accelProfile,
            "    touchpad {",
            "        natural_scroll = " + (touchpadNaturalScroll ? "true" : "false"),
            "        disable_while_typing = " + (touchpadDisableWhileTyping ? "true" : "false"),
            "        tap-to-click = " + (touchpadTapToClick ? "true" : "false"),
            "        middle_button_emulation = " + (touchpadMiddleEmulation ? "true" : "false"),
            "    }",
            "}",
            "",
            "xwayland {",
            "    force_zero_scaling = " + (xwaylandForceZeroScaling ? "true" : "false"),
            "}"
        ]

        if (displayConfigs && displayConfigs.length > 0) {
            lines.push("")
            lines.push("# Displays")
            for (var d = 0; d < displayConfigs.length; ++d) {
                var mon = displayConfigs[d]
                if (!mon.enabled) {
                    lines.push("monitor = " + mon.name + ", disable")
                } else {
                    lines.push("monitor = " + mon.name + ", " + mon.mode + ", " + mon.position + ", " + Number(mon.scale).toFixed(2) + ", transform, " + mon.transform)
                }
            }
        }

        if (bareSuperLauncher) {
            lines.push("")
            lines.push("# Opt-in bare Super release launcher trigger")
            lines.push("bindr = SUPER, SUPER_L, global, marathon-tactical:launcher")
        }

        if (customKeybinds && customKeybinds.length > 0) {
            lines.push("")
            lines.push("# Custom Keybinds")
            for (var k = 0; k < customKeybinds.length; ++k) {
                var kb = customKeybinds[k]
                if (!kb.enabled) continue
                lines.push("bind = " + kb.mods + ", " + kb.key + ", " + kb.dispatcher + (kb.arg !== "" ? (", " + kb.arg) : ""))
            }
        }

        if (customWindowRules && customWindowRules.length > 0) {
            lines.push("")
            lines.push("# Custom Window Rules (Hyprland >= 0.53 match: syntax)")
            for (var r = 0; r < customWindowRules.length; ++r) {
                var wr = customWindowRules[r]
                if (!wr.enabled) continue
                lines.push("windowrule {")
                lines.push("    name = " + wr.name)
                lines.push("    match:" + wr.matchType + " = " + wr.pattern)
                if (wr.floatWin) lines.push("    float = on")
                if (wr.centerWin) lines.push("    center = on")
                if (wr.pinWin) lines.push("    pin = on")
                lines.push("}")
            }
        }

        if (envVars && envVars.length > 0) {
            lines.push("")
            lines.push("# Custom Environment Variables")
            for (var e = 0; e < envVars.length; ++e) {
                var ev = envVars[e]
                if (!ev.enabled) continue
                lines.push("env = " + ev.key + "," + ev.value)
            }
        }

        if (autostartItems && autostartItems.length > 0) {
            lines.push("")
            lines.push("# Custom Autostart")
            for (var a = 0; a < autostartItems.length; ++a) {
                var item = autostartItems[a]
                if (!item.enabled) continue
                lines.push("exec-once = " + item.command)
            }
        }

        generatedHyprConf = lines.join("\n")
    }

    function _rebuildAppThemes() {
        var pal = Tokens.paletteSnapshot()
        var previewLines = [
            "# MARATHON Tactical — Synced External App Palette Snapshot",
            "# Faction: " + pal.factionId + " // Surface: " + pal.surfaceTheme + " // Sync: " + (appThemeSyncEnabled ? "ENABLED" : "PAUSED"),
            "# Targets: ghostty, kitty, alacritty, foot, btop, yazi, gtk-3.0/4.0, qt6ct",
            "",
            "[ghostty-colors]",
            "background = " + pal.background,
            "foreground = " + pal.text,
            "cursor-color = " + pal.signal,
            "selection-background = " + pal.signal,
            "selection-foreground = " + pal.textOnSignal,
            "",
            "[kitty-colors.conf]",
            "background " + pal.background,
            "foreground " + pal.text,
            "cursor " + pal.signal,
            "active_border_color " + pal.signal,
            "inactive_border_color " + pal.border,
            "active_tab_background " + pal.signal,
            "active_tab_foreground " + pal.textOnSignal,
            "",
            "[alacritty-colors.toml]",
            "[colors.primary]",
            "background = \"" + pal.background + "\"",
            "foreground = \"" + pal.text + "\"",
            "[colors.cursor]",
            "cursor = \"" + pal.signal + "\"",
            "",
            "[gtk-colors.css]",
            "@define-color marathon_bg " + pal.background + ";",
            "@define-color marathon_surface " + pal.surface + ";",
            "@define-color marathon_signal " + pal.signal + ";",
            "@define-color marathon_text " + pal.text + ";",
            "@define-color marathon_border " + pal.border + ";"
        ]
        generatedAppThemesPreview = previewLines.join("\n")
    }

    function _syncVisualTokens() {
        Tokens.setSurfaceTheme(surfaceTheme)
        Tokens.setCustomAccent(customAccentHex)
        Tokens.setCornerRadius(cornerRadius)
        Tokens.setBorderThickness(borderThickness)
        Tokens.setMotionMultiplier(motionMultiplier)
        Tokens.setHudBarHeight(hudHeight)
    }

    Component.onCompleted: {
        _syncVisualTokens()
        _rebuildHyprConf()
        _rebuildAppThemes()
    }

    function setSection(sectionId) {
        activeSection = sectionId || "profile"
    }

    function setSearchQuery(q) {
        searchQuery = q || ""
    }

    function setSetting(key, value) {
        if (!available || !key) return
        if (root.hasOwnProperty(key)) {
            root[key] = value
            if (key === "wallpaperId" && wallpaperAccentSync) {
                if (value === "grid-4k") Tokens.setFaction("CYBERACME")
                else if (value === "grid-1080") Tokens.setFaction("SEKIGUCHI")
                else if (value === "lock-4k") Tokens.setFaction("TRAXUS")
                else if (value === "matrix") Tokens.setFaction("RUNNER")
                customAccentHex = ""
            }
            dirty = true
            _syncVisualTokens()
            _rebuildHyprConf()
            _rebuildAppThemes()
            statusNote = "UPDATED " + key.toUpperCase() + " (LIVE PREVIEW)"
            settingsApplied(activeSection, statusNote)
        }
    }

    function updateDisplayConfig(name, patch) {
        if (!available || !patch) return
        var next = []
        for (var i = 0; i < displayConfigs.length; ++i) {
            var cur = displayConfigs[i]
            if (cur.name === name) {
                var copy = Object.assign({}, cur, patch)
                next.push(copy)
            } else {
                next.push(cur)
            }
        }
        displayConfigs = next
        dirty = true
        _rebuildHyprConf()
        statusNote = "DISPLAY TOPOLOGY UPDATED: " + name
        settingsApplied("displays", statusNote)
    }

    function addCustomKeybind(mods, key, dispatcher, arg) {
        var m = (mods || "").trim().toUpperCase()
        var k = (key || "").trim()
        var d = (dispatcher || "exec").trim()
        var a = (arg || "").trim()
        if (m === "" || k === "" || d === "") return
        var next = customKeybinds.slice()
        next.push({
            id: "kb-" + (next.length + 1) + "-" + k,
            mods: m,
            key: k,
            dispatcher: d,
            arg: a,
            enabled: true
        })
        customKeybinds = next
        dirty = true
        _rebuildHyprConf()
        statusNote = "ADDED KEYBIND: " + m + " + " + k
        settingsApplied("keybinds", statusNote)
    }

    function toggleCustomKeybind(id) {
        var next = []
        for (var i = 0; i < customKeybinds.length; ++i) {
            var item = customKeybinds[i]
            if (item.id === id) {
                next.push(Object.assign({}, item, { enabled: !item.enabled }))
            } else {
                next.push(item)
            }
        }
        customKeybinds = next
        dirty = true
        _rebuildHyprConf()
    }

    function removeCustomKeybind(id) {
        var next = []
        for (var i = 0; i < customKeybinds.length; ++i) {
            if (customKeybinds[i].id !== id) next.push(customKeybinds[i])
        }
        customKeybinds = next
        dirty = true
        _rebuildHyprConf()
    }

    function addWindowRule(name, matchType, pattern, floatWin, centerWin, pinWin) {
        var nm = (name || "").trim().replace(/\s+/g, "-")
        var pat = (pattern || "").trim()
        if (nm === "" || pat === "") return
        var next = customWindowRules.slice()
        next.push({
            id: "wr-" + (next.length + 1) + "-" + nm,
            name: nm,
            matchType: (matchType === "title" ? "title" : "class"),
            pattern: pat,
            floatWin: !!floatWin,
            centerWin: !!centerWin,
            pinWin: !!pinWin,
            enabled: true
        })
        customWindowRules = next
        dirty = true
        _rebuildHyprConf()
        statusNote = "ADDED RULE: " + nm
        settingsApplied("rules", statusNote)
    }

    function toggleWindowRule(id) {
        var next = []
        for (var i = 0; i < customWindowRules.length; ++i) {
            var item = customWindowRules[i]
            if (item.id === id) {
                next.push(Object.assign({}, item, { enabled: !item.enabled }))
            } else {
                next.push(item)
            }
        }
        customWindowRules = next
        dirty = true
        _rebuildHyprConf()
    }

    function removeWindowRule(id) {
        var next = []
        for (var i = 0; i < customWindowRules.length; ++i) {
            if (customWindowRules[i].id !== id) next.push(customWindowRules[i])
        }
        customWindowRules = next
        dirty = true
        _rebuildHyprConf()
    }

    function addAutostart(label, command) {
        var lbl = (label || "").trim()
        var cmd = (command || "").trim()
        if (cmd === "") return
        var next = autostartItems.slice()
        next.push({
            id: "as-" + (next.length + 1),
            label: lbl !== "" ? lbl : cmd.split(/\s+/)[0],
            command: cmd,
            enabled: true
        })
        autostartItems = next
        dirty = true
        _rebuildHyprConf()
        statusNote = "ADDED AUTOSTART ENTRY"
        settingsApplied("autostart", statusNote)
    }

    function toggleAutostart(id) {
        var next = []
        for (var i = 0; i < autostartItems.length; ++i) {
            var item = autostartItems[i]
            if (item.id === id) {
                next.push(Object.assign({}, item, { enabled: !item.enabled }))
            } else {
                next.push(item)
            }
        }
        autostartItems = next
        dirty = true
        _rebuildHyprConf()
    }

    function removeAutostart(id) {
        var next = []
        for (var i = 0; i < autostartItems.length; ++i) {
            if (autostartItems[i].id !== id) next.push(autostartItems[i])
        }
        autostartItems = next
        dirty = true
        _rebuildHyprConf()
    }

    function addEnvVar(key, value) {
        var k = (key || "").trim().toUpperCase()
        var v = (value || "").trim()
        if (k === "" || v === "") return
        var next = envVars.slice()
        next.push({ id: "env-" + (next.length + 1) + "-" + k, key: k, value: v, enabled: true })
        envVars = next
        dirty = true
        _rebuildHyprConf()
    }

    function toggleEnvVar(id) {
        var next = []
        for (var i = 0; i < envVars.length; ++i) {
            var item = envVars[i]
            if (item.id === id) {
                next.push(Object.assign({}, item, { enabled: !item.enabled }))
            } else {
                next.push(item)
            }
        }
        envVars = next
        dirty = true
        _rebuildHyprConf()
    }

    function removeEnvVar(id) {
        var next = []
        for (var i = 0; i < envVars.length; ++i) {
            if (envVars[i].id !== id) next.push(envVars[i])
        }
        envVars = next
        dirty = true
        _rebuildHyprConf()
    }

    function applyAll() {
        _syncVisualTokens()
        _rebuildHyprConf()
        _rebuildAppThemes()
        dirty = false
        statusNote = "APPLIED TO MOCK SESSION // 0 ERRORS"
        settingsApplied(activeSection, statusNote)
    }

    function reloadConfig() {
        _syncVisualTokens()
        _rebuildHyprConf()
        _rebuildAppThemes()
        dirty = false
        statusNote = "RELOADED MOCK SETTINGS SNAPSHOT"
        settingsApplied(activeSection, statusNote)
    }

    function resetSection(sectionId) {
        var sec = sectionId || activeSection
        if (sec === "appearance") {
            surfaceTheme = "TACTICAL"
            customAccentHex = ""
            cornerRadius = 0
            borderThickness = 1
            motionMultiplier = 1.0
            appThemeSyncEnabled = true
            Tokens.resetVisualDefaults()
        } else if (sec === "hud") {
            hudPosition = "top"
            hudHeight = 38
            hudMultiMonitorAll = true
            showRunnerBadge = true
            showMonitorTag = true
            showWorkspaces = true
            showActiveWindow = true
            showAudioPill = true
            showNetworkPill = true
            showBatteryPill = true
            showClockSeconds = true
            showDateInClock = true
            use24HourClock = true
        } else if (sec === "wallpaper") {
            wallpaperId = "matrix"
            backdropMatrixEnabled = true
            backdropMatrixOpacity = 0.42
            backdropDim = 0.0
            wallpaperAccentSync = false
        } else if (sec === "launcher") {
            launcherDefaultLayout = "list"
            launcherShowRecents = true
            launcherMaxRecents = 6
            launcherShowCommandsTab = true
            launcherCloseOnLaunch = true
        } else if (sec === "notifications") {
            toastPosition = "top-right"
            toastTimeoutMs = 5000
            toastMaxVisible = 3
            osdEnabled = true
            osdDurationMs = 1600
        } else if (sec === "session") {
            lockShowHostSpecimen = true
            idleLockMinutes = 10
            idleDpmsMinutes = 15
            confirmPowerActions = true
        } else if (sec === "compositor") {
            hyprLayout = "dwindle"
            hyprGapsIn = 4
            hyprGapsOut = 8
            hyprBorderSize = 2
            hyprRounding = 0
            hyprActiveOpacity = 1.0
            hyprInactiveOpacity = 1.0
            hyprBlurEnabled = false
            hyprShadowEnabled = false
            hyprVfrEnabled = true
            hyprAllowTearing = false
            hyprResizeOnBorder = true
            hyprAnimationsEnabled = true
            hyprAnimationSpeed = 1.0
            hyprAnimStyle = "tactical"
        } else if (sec === "displays") {
            xwaylandForceZeroScaling = true
            displayConfigs = [
                {
                    name: "eDP-1",
                    description: "Built-in Tactical Panel 144Hz",
                    mode: "1920x1080@144",
                    availableModes: ["preferred", "1920x1080@144", "1920x1080@60", "1366x768@60"],
                    scale: 1.0,
                    transform: 0,
                    position: "0x0",
                    enabled: true,
                    primary: true
                }
            ]
        } else if (sec === "input") {
            kbLayout = "us"
            kbVariant = ""
            kbOptions = "grp:alt_shift_toggle"
            repeatRate = 35
            repeatDelay = 250
            pointerSensitivity = 0.0
            accelProfile = "flat"
            followMouse = 1
            touchpadNaturalScroll = false
            touchpadDisableWhileTyping = true
            touchpadTapToClick = true
            touchpadMiddleEmulation = false
        } else if (sec === "keybinds") {
            defaultTerminal = "ghostty"
            defaultFileManager = "dolphin"
            defaultBrowser = "firefox"
            defaultEditor = "nvim"
            defaultMediaPlayer = "mpv"
            defaultImageViewer = "imv"
            defaultPdfViewer = "zathura"
            defaultSystemMonitor = "btop"
            bareSuperLauncher = false
            customKeybinds = []
        } else if (sec === "rules") {
            customWindowRules = []
        } else if (sec === "autostart") {
            autostartItems = []
            envVars = [{ id: "env-1", key: "XCURSOR_SIZE", value: "24", enabled: true }]
            gpuRenderMode = "auto"
        }
        _syncVisualTokens()
        _rebuildHyprConf()
        _rebuildAppThemes()
        dirty = true
        statusNote = "RESET SECTION: " + sec.toUpperCase()
        sectionReset(sec)
    }

    function resetAllDefaults() {
        var secs = ["appearance", "hud", "wallpaper", "launcher", "notifications", "session", "compositor", "displays", "input", "keybinds", "rules", "autostart"]
        for (var i = 0; i < secs.length; ++i) {
            resetSection(secs[i])
        }
        Tokens.setEmblem("U73_CRUCIFORM")
        Tokens.setRunnerName("RUNNER")
        Tokens.setRunnerTitle("OPERATOR")
        dirty = false
        statusNote = "ALL SETTINGS RESTORED TO MARATHON DEFAULTS"
        sectionReset("all")
    }

    function exportSettingsJson() {
        var payload = {
            hudPosition: hudPosition,
            hudHeight: hudHeight,
            hudMultiMonitorAll: hudMultiMonitorAll,
            showRunnerBadge: showRunnerBadge,
            showMonitorTag: showMonitorTag,
            showWorkspaces: showWorkspaces,
            showActiveWindow: showActiveWindow,
            showAudioPill: showAudioPill,
            showNetworkPill: showNetworkPill,
            showBatteryPill: showBatteryPill,
            showClockSeconds: showClockSeconds,
            showDateInClock: showDateInClock,
            use24HourClock: use24HourClock,
            surfaceTheme: surfaceTheme,
            customAccentHex: customAccentHex,
            factionId: Tokens.factionId,
            emblemId: Tokens.emblemId,
            runnerName: Tokens.runnerName,
            runnerTitle: Tokens.runnerTitle,
            cornerRadius: cornerRadius,
            borderThickness: borderThickness,
            motionMultiplier: motionMultiplier,
            wallpaperId: wallpaperId,
            backdropMatrixEnabled: backdropMatrixEnabled,
            backdropMatrixOpacity: backdropMatrixOpacity,
            backdropDim: backdropDim,
            wallpaperAccentSync: wallpaperAccentSync,
            appThemeSyncEnabled: appThemeSyncEnabled,
            launcherDefaultLayout: launcherDefaultLayout,
            launcherShowRecents: launcherShowRecents,
            launcherMaxRecents: launcherMaxRecents,
            launcherShowCommandsTab: launcherShowCommandsTab,
            launcherCloseOnLaunch: launcherCloseOnLaunch,
            toastPosition: toastPosition,
            toastTimeoutMs: toastTimeoutMs,
            toastMaxVisible: toastMaxVisible,
            osdEnabled: osdEnabled,
            osdDurationMs: osdDurationMs,
            lockShowHostSpecimen: lockShowHostSpecimen,
            idleLockMinutes: idleLockMinutes,
            idleDpmsMinutes: idleDpmsMinutes,
            confirmPowerActions: confirmPowerActions,
            hyprLayout: hyprLayout,
            hyprGapsIn: hyprGapsIn,
            hyprGapsOut: hyprGapsOut,
            hyprBorderSize: hyprBorderSize,
            hyprRounding: hyprRounding,
            hyprActiveOpacity: hyprActiveOpacity,
            hyprInactiveOpacity: hyprInactiveOpacity,
            hyprBlurEnabled: hyprBlurEnabled,
            hyprShadowEnabled: hyprShadowEnabled,
            hyprVfrEnabled: hyprVfrEnabled,
            hyprAllowTearing: hyprAllowTearing,
            hyprResizeOnBorder: hyprResizeOnBorder,
            hyprAnimationsEnabled: hyprAnimationsEnabled,
            hyprAnimationSpeed: hyprAnimationSpeed,
            hyprAnimStyle: hyprAnimStyle,
            xwaylandForceZeroScaling: xwaylandForceZeroScaling,
            displayConfigs: displayConfigs,
            kbLayout: kbLayout,
            kbVariant: kbVariant,
            kbOptions: kbOptions,
            repeatRate: repeatRate,
            repeatDelay: repeatDelay,
            pointerSensitivity: pointerSensitivity,
            accelProfile: accelProfile,
            followMouse: followMouse,
            touchpadNaturalScroll: touchpadNaturalScroll,
            touchpadDisableWhileTyping: touchpadDisableWhileTyping,
            touchpadTapToClick: touchpadTapToClick,
            touchpadMiddleEmulation: touchpadMiddleEmulation,
            defaultTerminal: defaultTerminal,
            defaultFileManager: defaultFileManager,
            defaultBrowser: defaultBrowser,
            defaultEditor: defaultEditor,
            defaultMediaPlayer: defaultMediaPlayer,
            defaultImageViewer: defaultImageViewer,
            defaultPdfViewer: defaultPdfViewer,
            defaultSystemMonitor: defaultSystemMonitor,
            bareSuperLauncher: bareSuperLauncher,
            customKeybinds: customKeybinds,
            customWindowRules: customWindowRules,
            autostartItems: autostartItems,
            envVars: envVars,
            gpuRenderMode: gpuRenderMode
        }
        statusNote = "JSON SNAPSHOT READY (" + Object.keys(payload).length + " KEYS)"
        return JSON.stringify(payload, null, 2)
    }
}
