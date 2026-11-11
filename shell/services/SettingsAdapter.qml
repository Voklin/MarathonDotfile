import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../ui/tokens"

QtObject {
    id: root

    readonly property string _xdgConfigHome: {
        var xdg = Quickshell.env("XDG_CONFIG_HOME")
        if (xdg && String(xdg) !== "") return String(xdg)
        var home = Quickshell.env("HOME")
        return (home && String(home) !== "" ? String(home) : "/tmp") + "/.config"
    }
    readonly property string _marathonRoot: _xdgConfigHome + "/marathon-tactical"

    property bool available: true
    property bool loading: true
    property string errorMessage: ""
    property bool dirty: false
    property string statusNote: "SETTINGS ADAPTER INITIALIZING..."
    property string activeSection: "profile"
    property string searchQuery: ""
    property string settingsFilePath: _marathonRoot + "/settings.json"
    property string hyprOverridePath: _marathonRoot + "/hypr/user-settings.conf"

    property var hostSpecs: ({
        hostname: "cachyos",
        distro: "CachyOS Linux",
        kernel: "linux",
        cpu: "Detecting...",
        gpu: "Detecting...",
        memory: "Detecting...",
        compositor: Hyprland.workspaces !== null ? "Hyprland (Active IPC)" : "Hyprland (Offline)",
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
    property var displayConfigs: []
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

    property var customKeybinds: []

    readonly property var builtinRules: [
        { name: "marathon-float-utilities", matchExpr: "match:class ^(pavucontrol|nm-connection-editor|blueman-manager|polkit...)$", effect: "float = on, center = on" },
        { name: "marathon-float-portals", matchExpr: "match:class ^(xdg-desktop-portal-...)$", effect: "float = on, center = on" },
        { name: "marathon-float-dialogs", matchExpr: "match:title ^(Open File|Save File|Confirm|Preferences|Settings)$", effect: "float = on, center = on" },
        { name: "marathon-pip", matchExpr: "match:title ^(Picture-in-Picture|Picture in picture)$", effect: "float = on, pin = on" },
        { name: "marathon-fullscreen-idleinhibit", matchExpr: "match:fullscreen = true", effect: "idle_inhibit = focus" },
        { name: "marathon-shell-layers", matchExpr: "layerrule match:namespace ^marathon-(hud|launcher|...|settings)$", effect: "no_anim = on, blur = off" }
    ]

    property var customWindowRules: []
    property var autostartItems: []
    property var envVars: [{ id: "env-1", key: "XCURSOR_SIZE", value: "24", enabled: true }]
    property string gpuRenderMode: "auto"
    property var gpuDevices: []
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

    property bool _dirReady: false

    property Connections _tokensConn: Connections {
        target: Tokens
        function onSignalChanged() {
            root._rebuildHyprConf()
            root._rebuildAppThemes()
            root._persistAppThemes()
        }
        function onBackgroundChanged() {
            root._rebuildAppThemes()
            root._persistAppThemes()
        }
    }

    signal settingsApplied(string section, string message)
    signal sectionReset(string section)

    // Ensure isolated target dirs exist (~/.config/marathon-tactical/{hypr,apps/generated})
    property Process ensureDirProc: Process {
        command: ["mkdir", "-p", root._marathonRoot, root._marathonRoot + "/hypr", root._marathonRoot + "/apps/generated"]
        running: true
        onExited: function(code, _status) {
            root._dirReady = (code === 0)
            settingsFileView.reload()
        }
    }

    property FileView settingsFileView: FileView {
        path: root.settingsFilePath
        atomicWrites: true
        onLoaded: {
            root._applyJsonPayload(settingsFileView.text())
            root.loading = false
            root.statusNote = "SETTINGS LOADED FROM ISOLATED CONFIG"
        }
        onLoadFailed: function(_err) {
            root.loading = false
            root._syncVisualTokens()
            root._rebuildHyprConf()
            root.statusNote = "USING DEFAULTS (FIRST LAUNCH)"
        }
    }

    property FileView hyprConfView: FileView {
        path: root.hyprOverridePath
        atomicWrites: true
        onSaveFailed: function(_err) {
            root.errorMessage = "FAILED WRITING " + root.hyprOverridePath
        }
    }

    property FileView ghosttyThemeView: FileView { path: root._marathonRoot + "/apps/generated/ghostty-colors"; atomicWrites: true }
    property FileView kittyThemeView: FileView { path: root._marathonRoot + "/apps/generated/kitty-colors.conf"; atomicWrites: true }
    property FileView alacrittyThemeView: FileView { path: root._marathonRoot + "/apps/generated/alacritty-colors.toml"; atomicWrites: true }
    property FileView footThemeView: FileView { path: root._marathonRoot + "/apps/generated/foot-colors.ini"; atomicWrites: true }
    property FileView btopThemeView: FileView { path: root._marathonRoot + "/apps/generated/btop-marathon.theme"; atomicWrites: true }
    property FileView yaziThemeView: FileView { path: root._marathonRoot + "/apps/generated/yazi-colors.toml"; atomicWrites: true }
    property FileView gtkThemeView: FileView { path: root._marathonRoot + "/apps/generated/gtk-colors.css"; atomicWrites: true }
    property FileView qt6ctThemeView: FileView { path: root._marathonRoot + "/apps/generated/qt6ct-colors.conf"; atomicWrites: true }

    // One-shot Linux hardware & OS specimen probes (zero polling)
    property Process hostNameProc: Process {
        command: ["uname", "-n", "-r"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = (text || "").trim().split(/\s+/)
                if (parts.length >= 2) {
                    var next = Object.assign({}, root.hostSpecs)
                    next.hostname = parts[0]
                    next.kernel = parts[1]
                    root.hostSpecs = next
                }
            }
        }
    }

    property FileView osReleaseView: FileView {
        path: "/etc/os-release"
        onLoaded: {
            var lines = (osReleaseView.text() || "").split("\n")
            for (var i = 0; i < lines.length; ++i) {
                if (lines[i].indexOf("PRETTY_NAME=") === 0) {
                    var val = lines[i].slice(12).replace(/^["']|["']$/g, "")
                    var next = Object.assign({}, root.hostSpecs)
                    next.distro = val
                    root.hostSpecs = next
                    break
                }
            }
        }
    }

    property FileView cpuInfoView: FileView {
        path: "/proc/cpuinfo"
        onLoaded: {
            var lines = (cpuInfoView.text() || "").split("\n")
            for (var i = 0; i < lines.length; ++i) {
                if (lines[i].indexOf("model name") === 0) {
                    var idx = lines[i].indexOf(":")
                    if (idx !== -1) {
                        var next = Object.assign({}, root.hostSpecs)
                        next.cpu = lines[i].slice(idx + 1).trim()
                        root.hostSpecs = next
                        break
                    }
                }
            }
        }
    }

    property FileView memInfoView: FileView {
        path: "/proc/meminfo"
        onLoaded: {
            var m = /MemTotal:\s+(\d+)\s+kB/.exec(memInfoView.text() || "")
            if (m && m[1]) {
                var gib = (parseInt(m[1], 10) / (1024 * 1024)).toFixed(1)
                var next = Object.assign({}, root.hostSpecs)
                next.memory = gib + " GiB RAM"
                root.hostSpecs = next
            }
        }
    }

    property Process monitorsProbeProc: Process {
        command: ["hyprctl", "monitors", "-j"]
        running: Hyprland.workspaces !== null
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var arr = JSON.parse(text || "[]")
                    if (!Array.isArray(arr)) return
                    var out = []
                    for (var i = 0; i < arr.length; ++i) {
                        var m = arr[i]
                        if (!m) continue
                        var modes = ["preferred"]
                        if (Array.isArray(m.availableModes)) {
                            for (var j = 0; j < m.availableModes.length && modes.length < 6; ++j) {
                                var cleaned = String(m.availableModes[j]).replace("Hz", "")
                                if (modes.indexOf(cleaned) === -1) modes.push(cleaned)
                            }
                        }
                        out.push({
                            name: String(m.name || ("OUT-" + i)),
                            description: String(m.description || m.model || "Wayland Output"),
                            mode: (m.width || 1920) + "x" + (m.height || 1080) + "@" + Math.round(m.refreshRate || 60),
                            availableModes: modes,
                            scale: Number(m.scale || 1.0),
                            transform: Number(m.transform || 0),
                            position: (m.x || 0) + "x" + (m.y || 0),
                            enabled: m.disabled !== true,
                            primary: m.focused === true || i === 0
                        })
                    }
                    if (out.length > 0 && root.displayConfigs.length === 0) {
                        root.displayConfigs = out
                        root._rebuildHyprConf()
                    }
                } catch (_err) {
                }
            }
        }
    }

    property Process gpuProbeProc: Process {
        command: ["lspci", "-mm"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = (text || "").split("\n")
                var gpus = []
                for (var i = 0; i < lines.length; ++i) {
                    var ln = lines[i]
                    if (ln.indexOf("VGA compatible controller") !== -1 || ln.indexOf("3D controller") !== -1) {
                        var idx = gpus.length
                        gpus.push({
                            id: "card" + idx,
                            vendor: ln.indexOf("NVIDIA") !== -1 ? "NVIDIA" : (ln.indexOf("AMD") !== -1 ? "AMD" : "INTEL"),
                            name: ln.replace(/"/g, "").slice(0, 56),
                            role: ln.indexOf("3D controller") !== -1 ? "DISCRETE" : "PRIMARY",
                            active: idx === 0
                        })
                    }
                }
                if (gpus.length > 0) {
                    root.gpuDevices = gpus
                    var next = Object.assign({}, root.hostSpecs)
                    next.gpu = gpus[0].name
                    root.hostSpecs = next
                }
            }
        }
    }

    property Process hyprApplyProc: Process {
        running: false
        onExited: function(code, _status) {
            if (code !== 0) {
                root.statusNote = "SAVED CONFIG (HYPRCTL EXIT " + code + ")"
            }
        }
    }

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

    function _buildAppThemeMap() {
        var pal = Tokens.paletteSnapshot()
        var bg = pal.background
        var sf = pal.surface
        var sfe = pal.surfaceElevated
        var sig = pal.signal
        var sigm = pal.signalMuted
        var txt = pal.text
        var tos = pal.textOnSignal
        var mut = pal.muted
        var brd = pal.border
        var alrt = pal.alert
        var wrn = pal.warning

        function rawHex(h) {
            return String(h || "").replace(/^#/, "").toLowerCase()
        }

        var ghostty = [
            "# MARATHON Tactical — Ghostty Dynamic Faction Palette (" + pal.factionId + ")",
            "background = " + bg,
            "foreground = " + txt,
            "cursor-color = " + sig,
            "cursor-text = " + tos,
            "selection-background = " + sig,
            "selection-foreground = " + tos,
            "palette = 0=" + sf,
            "palette = 1=" + alrt,
            "palette = 2=" + sig,
            "palette = 3=" + wrn,
            "palette = 4=" + sigm,
            "palette = 5=" + brd,
            "palette = 6=" + sig,
            "palette = 7=" + mut,
            "palette = 8=" + sfe,
            "palette = 9=" + alrt,
            "palette = 10=" + sig,
            "palette = 11=" + wrn,
            "palette = 12=" + sig,
            "palette = 13=" + sigm,
            "palette = 14=" + txt,
            "palette = 15=" + txt
        ].join("\n")

        var kitty = [
            "# MARATHON Tactical — Kitty Dynamic Faction Palette (" + pal.factionId + ")",
            "background " + bg,
            "foreground " + txt,
            "cursor " + sig,
            "cursor_text_color " + tos,
            "selection_background " + sig,
            "selection_foreground " + tos,
            "active_border_color " + sig,
            "inactive_border_color " + brd,
            "active_tab_background " + sig,
            "active_tab_foreground " + tos,
            "inactive_tab_background " + sf,
            "inactive_tab_foreground " + mut,
            "tab_bar_background " + bg,
            "color0 " + sf,
            "color1 " + alrt,
            "color2 " + sig,
            "color3 " + wrn,
            "color4 " + sigm,
            "color7 " + mut,
            "color8 " + sfe,
            "color10 " + sig,
            "color15 " + txt
        ].join("\n")

        var alacritty = [
            "# MARATHON Tactical — Alacritty Dynamic Faction Palette (" + pal.factionId + ")",
            "[colors.primary]",
            "background = \"" + bg + "\"",
            "foreground = \"" + txt + "\"",
            "[colors.cursor]",
            "text = \"" + tos + "\"",
            "cursor = \"" + sig + "\"",
            "[colors.selection]",
            "text = \"" + tos + "\"",
            "background = \"" + sig + "\"",
            "[colors.normal]",
            "black = \"" + sf + "\"",
            "red = \"" + alrt + "\"",
            "green = \"" + sig + "\"",
            "yellow = \"" + wrn + "\"",
            "blue = \"" + sigm + "\"",
            "magenta = \"" + brd + "\"",
            "cyan = \"" + sig + "\"",
            "white = \"" + txt + "\""
        ].join("\n")

        var foot = [
            "# MARATHON Tactical — Foot Dynamic Faction Palette (" + pal.factionId + ")",
            "[colors]",
            "background=" + rawHex(bg),
            "foreground=" + rawHex(txt),
            "cursor=" + rawHex(tos) + " " + rawHex(sig),
            "selection-foreground=" + rawHex(tos),
            "selection-background=" + rawHex(sig),
            "regular0=" + rawHex(sf),
            "regular1=" + rawHex(alrt),
            "regular2=" + rawHex(sig),
            "regular3=" + rawHex(wrn),
            "regular4=" + rawHex(sigm),
            "regular7=" + rawHex(txt)
        ].join("\n")

        var btop = [
            "# MARATHON Tactical — btop++ Dynamic Faction Theme (" + pal.factionId + ")",
            "theme[main_bg]=\"" + bg + "\"",
            "theme[main_fg]=\"" + txt + "\"",
            "theme[title]=\"" + sig + "\"",
            "theme[hi_fg]=\"" + sig + "\"",
            "theme[selected_bg]=\"" + sig + "\"",
            "theme[selected_fg]=\"" + tos + "\"",
            "theme[inactive_fg]=\"" + mut + "\"",
            "theme[graph_text]=\"" + mut + "\"",
            "theme[meter_bg]=\"" + sf + "\"",
            "theme[proc_misc]=\"" + sigm + "\"",
            "theme[cpu_box]=\"" + brd + "\"",
            "theme[mem_box]=\"" + brd + "\"",
            "theme[net_box]=\"" + brd + "\"",
            "theme[proc_box]=\"" + brd + "\"",
            "theme[div_line]=\"" + brd + "\"",
            "theme[temp_start]=\"" + sig + "\"",
            "theme[temp_mid]=\"" + wrn + "\"",
            "theme[temp_end]=\"" + alrt + "\"",
            "theme[cpu_start]=\"" + sigm + "\"",
            "theme[cpu_mid]=\"" + sig + "\"",
            "theme[cpu_end]=\"" + wrn + "\"",
            "theme[free_start]=\"" + sigm + "\"",
            "theme[free_mid]=\"" + sig + "\"",
            "theme[free_end]=\"" + txt + "\"",
            "theme[cached_start]=\"" + sigm + "\"",
            "theme[cached_mid]=\"" + sig + "\"",
            "theme[cached_end]=\"" + wrn + "\"",
            "theme[available_start]=\"" + sig + "\"",
            "theme[available_mid]=\"" + wrn + "\"",
            "theme[available_end]=\"" + alrt + "\"",
            "theme[used_start]=\"" + sigm + "\"",
            "theme[used_mid]=\"" + sig + "\"",
            "theme[used_end]=\"" + alrt + "\"",
            "theme[download_start]=\"" + sigm + "\"",
            "theme[download_mid]=\"" + sig + "\"",
            "theme[download_end]=\"" + txt + "\"",
            "theme[upload_start]=\"" + wrn + "\"",
            "theme[upload_mid]=\"" + sig + "\"",
            "theme[upload_end]=\"" + alrt + "\"",
            "theme[process_start]=\"" + sigm + "\"",
            "theme[process_mid]=\"" + sig + "\"",
            "theme[process_end]=\"" + alrt + "\""
        ].join("\n")

        var yazi = [
            "# MARATHON Tactical — Yazi Dynamic Faction Theme (" + pal.factionId + ")",
            "[mgr]",
            "cwd = { fg = \"" + sig + "\", bold = true }",
            "hovered = { fg = \"" + tos + "\", bg = \"" + sig + "\", bold = true }",
            "preview_hovered = { underline = true }",
            "find_keyword = { fg = \"" + wrn + "\", bold = true }",
            "find_position = { fg = \"" + sig + "\", bg = \"reset\", italic = true }",
            "marker_copied = { fg = \"" + sig + "\", bg = \"" + sig + "\" }",
            "marker_cut = { fg = \"" + alrt + "\", bg = \"" + alrt + "\" }",
            "marker_marked = { fg = \"" + sigm + "\", bg = \"" + sigm + "\" }",
            "marker_selected = { fg = \"" + wrn + "\", bg = \"" + wrn + "\" }",
            "tab_active = { fg = \"" + tos + "\", bg = \"" + sig + "\", bold = true }",
            "tab_inactive = { fg = \"" + mut + "\", bg = \"" + sf + "\" }",
            "border_symbol = \"│\"",
            "border_style = { fg = \"" + brd + "\" }",
            "[status]",
            "separator_open = \"\"",
            "separator_close = \"\"",
            "mode_normal = { fg = \"" + tos + "\", bg = \"" + sig + "\", bold = true }",
            "mode_select = { fg = \"" + tos + "\", bg = \"" + wrn + "\", bold = true }",
            "mode_unset = { fg = \"" + tos + "\", bg = \"" + alrt + "\", bold = true }",
            "progress_label = { fg = \"" + txt + "\", bold = true }",
            "progress_normal = { fg = \"" + sig + "\", bg = \"" + sf + "\" }",
            "progress_error = { fg = \"" + alrt + "\", bg = \"" + sf + "\" }",
            "[input]",
            "border = { fg = \"" + sig + "\" }",
            "title = { fg = \"" + txt + "\" }",
            "value = { fg = \"" + txt + "\" }",
            "selected = { reversed = true }",
            "[notify]",
            "title_info = { fg = \"" + sig + "\" }",
            "title_warn = { fg = \"" + wrn + "\" }",
            "title_error = { fg = \"" + alrt + "\" }"
        ].join("\n")

        var gtk = [
            "/* MARATHON Tactical — GTK 3.0 / 4.0 Dynamic Faction Palette (" + pal.factionId + ") */",
            "@define-color marathon_bg " + bg + ";",
            "@define-color marathon_surface " + sf + ";",
            "@define-color marathon_elevated " + sfe + ";",
            "@define-color marathon_signal " + sig + ";",
            "@define-color marathon_signal_muted " + sigm + ";",
            "@define-color marathon_text " + txt + ";",
            "@define-color marathon_text_on_signal " + tos + ";",
            "@define-color marathon_muted " + mut + ";",
            "@define-color marathon_border " + brd + ";",
            "@define-color marathon_alert " + alrt + ";",
            "@define-color marathon_warning " + wrn + ";"
        ].join("\n")

        var qt6ct = [
            "[ColorScheme]",
            "active_colors=" + txt + ", " + sf + ", " + sfe + ", " + brd + ", " + bg + ", " + pal.surfaceZebra + ", " + txt + ", " + txt + ", " + txt + ", " + bg + ", " + bg + ", " + bg + ", " + sig + ", " + tos + ", " + sig + ", " + sigm + ", " + sf + ", " + txt + ", " + sf + ", " + txt + ", " + mut,
            "disabled_colors=" + mut + ", " + sf + ", " + sfe + ", " + brd + ", " + bg + ", " + pal.surfaceZebra + ", " + mut + ", " + mut + ", " + mut + ", " + bg + ", " + bg + ", " + bg + ", " + brd + ", " + mut + ", " + sigm + ", " + sigm + ", " + sf + ", " + mut + ", " + sf + ", " + mut + ", " + mut,
            "inactive_colors=" + txt + ", " + sf + ", " + sfe + ", " + brd + ", " + bg + ", " + pal.surfaceZebra + ", " + txt + ", " + txt + ", " + txt + ", " + bg + ", " + bg + ", " + bg + ", " + sigm + ", " + tos + ", " + sig + ", " + sigm + ", " + sf + ", " + txt + ", " + sf + ", " + txt + ", " + mut
        ].join("\n")

        return {
            ghostty: ghostty,
            kitty: kitty,
            alacritty: alacritty,
            foot: foot,
            btop: btop,
            yazi: yazi,
            gtk: gtk,
            qt6ct: qt6ct
        }
    }

    function _rebuildAppThemes() {
        var pal = Tokens.paletteSnapshot()
        var m = _buildAppThemeMap()
        generatedAppThemesPreview = [
            "# MARATHON Tactical — Synced External App Palette Snapshot",
            "# Faction: " + pal.factionId + " // Surface: " + pal.surfaceTheme + " // Sync: " + (appThemeSyncEnabled ? "ENABLED" : "PAUSED"),
            "# Targets: ghostty, kitty, alacritty, foot, btop, yazi, gtk-3.0/4.0, qt6ct",
            "",
            "[ghostty-colors]",
            m.ghostty,
            "",
            "[kitty-colors.conf]",
            m.kitty,
            "",
            "[alacritty-colors.toml]",
            m.alacritty,
            "",
            "[gtk-colors.css]",
            m.gtk
        ].join("\n")
    }

    function _persistAppThemes() {
        if (!_dirReady || !appThemeSyncEnabled) return
        var m = _buildAppThemeMap()
        ghosttyThemeView.setText(m.ghostty)
        kittyThemeView.setText(m.kitty)
        alacrittyThemeView.setText(m.alacritty)
        footThemeView.setText(m.foot)
        btopThemeView.setText(m.btop)
        yaziThemeView.setText(m.yazi)
        gtkThemeView.setText(m.gtk)
        qt6ctThemeView.setText(m.qt6ct)
    }

    function _syncVisualTokens() {
        Tokens.setSurfaceTheme(surfaceTheme)
        Tokens.setCustomAccent(customAccentHex)
        Tokens.setCornerRadius(cornerRadius)
        Tokens.setBorderThickness(borderThickness)
        Tokens.setMotionMultiplier(motionMultiplier)
        Tokens.setHudBarHeight(hudHeight)
    }

    function _applyJsonPayload(rawText) {
        try {
            var data = JSON.parse(rawText || "{}")
            if (typeof data !== "object" || data === null) return
            var keys = Object.keys(data)
            for (var i = 0; i < keys.length; ++i) {
                var k = keys[i]
                if (k === "factionId") Tokens.setFaction(data[k])
                else if (k === "emblemId") Tokens.setEmblem(data[k])
                else if (k === "runnerName") Tokens.setRunnerName(data[k])
                else if (k === "runnerTitle") Tokens.setRunnerTitle(data[k])
                else if (root.hasOwnProperty(k)) root[k] = data[k]
            }
            _syncVisualTokens()
            _rebuildHyprConf()
            _rebuildAppThemes()
        } catch (_e) {
        }
    }

    function _dispatchLiveKeywords() {
        if (Hyprland.workspaces === null || hyprApplyProc.running) return
        var cmds = [
            "keyword general:gaps_in " + hyprGapsIn,
            "keyword general:gaps_out " + hyprGapsOut,
            "keyword general:border_size " + hyprBorderSize,
            "keyword general:col.active_border " + _colorToHyprRgba(Tokens.signal),
            "keyword general:col.inactive_border " + _colorToHyprRgba(Tokens.border),
            "keyword general:layout " + hyprLayout,
            "keyword decoration:rounding " + hyprRounding,
            "keyword decoration:active_opacity " + hyprActiveOpacity.toFixed(2),
            "keyword decoration:inactive_opacity " + hyprInactiveOpacity.toFixed(2),
            "keyword decoration:blur:enabled " + (hyprBlurEnabled ? "true" : "false"),
            "keyword decoration:shadow:enabled " + (hyprShadowEnabled ? "true" : "false"),
            "keyword animations:enabled " + (hyprAnimationsEnabled ? "yes" : "no"),
            "keyword input:kb_layout " + (kbLayout || "us"),
            "keyword input:kb_options " + (kbOptions || ""),
            "keyword input:repeat_rate " + repeatRate,
            "keyword input:repeat_delay " + repeatDelay,
            "keyword input:sensitivity " + pointerSensitivity.toFixed(2),
            "keyword input:accel_profile " + accelProfile
        ]
        hyprApplyProc.command = ["hyprctl", "--batch", cmds.join(" ; ")]
        hyprApplyProc.running = true
    }

    function _persistDisk() {
        if (!_dirReady) return
        settingsFileView.setText(exportSettingsJson())
        hyprConfView.setText(generatedHyprConf)
        _persistAppThemes()
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
            _persistDisk()
            _dispatchLiveKeywords()
            statusNote = "APPLIED " + key.toUpperCase()
            settingsApplied(activeSection, statusNote)
        }
    }

    function updateDisplayConfig(name, patch) {
        if (!available || !patch) return
        var next = []
        for (var i = 0; i < displayConfigs.length; ++i) {
            var cur = displayConfigs[i]
            if (cur.name === name) {
                next.push(Object.assign({}, cur, patch))
            } else {
                next.push(cur)
            }
        }
        displayConfigs = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
        statusNote = "DISPLAY CONFIG UPDATED: " + name
        settingsApplied("displays", statusNote)
    }

    function addCustomKeybind(mods, key, dispatcher, arg) {
        var m = (mods || "").trim().toUpperCase()
        var k = (key || "").trim()
        var d = (dispatcher || "exec").trim()
        var a = (arg || "").trim()
        if (m === "" || k === "" || d === "") return
        var next = customKeybinds.slice()
        next.push({ id: "kb-" + (next.length + 1) + "-" + k, mods: m, key: k, dispatcher: d, arg: a, enabled: true })
        customKeybinds = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
        statusNote = "ADDED KEYBIND: " + m + " + " + k
        settingsApplied("keybinds", statusNote)
    }

    function toggleCustomKeybind(id) {
        var next = []
        for (var i = 0; i < customKeybinds.length; ++i) {
            var item = customKeybinds[i]
            next.push(item.id === id ? Object.assign({}, item, { enabled: !item.enabled }) : item)
        }
        customKeybinds = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
    }

    function removeCustomKeybind(id) {
        var next = []
        for (var i = 0; i < customKeybinds.length; ++i) {
            if (customKeybinds[i].id !== id) next.push(customKeybinds[i])
        }
        customKeybinds = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
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
        _persistDisk()
        statusNote = "ADDED RULE: " + nm
        settingsApplied("rules", statusNote)
    }

    function toggleWindowRule(id) {
        var next = []
        for (var i = 0; i < customWindowRules.length; ++i) {
            var item = customWindowRules[i]
            next.push(item.id === id ? Object.assign({}, item, { enabled: !item.enabled }) : item)
        }
        customWindowRules = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
    }

    function removeWindowRule(id) {
        var next = []
        for (var i = 0; i < customWindowRules.length; ++i) {
            if (customWindowRules[i].id !== id) next.push(customWindowRules[i])
        }
        customWindowRules = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
    }

    function addAutostart(label, command) {
        var lbl = (label || "").trim()
        var cmd = (command || "").trim()
        if (cmd === "") return
        var next = autostartItems.slice()
        next.push({ id: "as-" + (next.length + 1), label: lbl !== "" ? lbl : cmd.split(/\s+/)[0], command: cmd, enabled: true })
        autostartItems = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
    }

    function toggleAutostart(id) {
        var next = []
        for (var i = 0; i < autostartItems.length; ++i) {
            var item = autostartItems[i]
            next.push(item.id === id ? Object.assign({}, item, { enabled: !item.enabled }) : item)
        }
        autostartItems = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
    }

    function removeAutostart(id) {
        var next = []
        for (var i = 0; i < autostartItems.length; ++i) {
            if (autostartItems[i].id !== id) next.push(autostartItems[i])
        }
        autostartItems = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
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
        _persistDisk()
    }

    function toggleEnvVar(id) {
        var next = []
        for (var i = 0; i < envVars.length; ++i) {
            var item = envVars[i]
            next.push(item.id === id ? Object.assign({}, item, { enabled: !item.enabled }) : item)
        }
        envVars = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
    }

    function removeEnvVar(id) {
        var next = []
        for (var i = 0; i < envVars.length; ++i) {
            if (envVars[i].id !== id) next.push(envVars[i])
        }
        envVars = next
        dirty = true
        _rebuildHyprConf()
        _persistDisk()
    }

    function applyAll() {
        _syncVisualTokens()
        _rebuildHyprConf()
        _rebuildAppThemes()
        _persistDisk()
        if (Hyprland.workspaces !== null && !hyprApplyProc.running) {
            hyprApplyProc.command = ["hyprctl", "reload"]
            hyprApplyProc.running = true
        }
        dirty = false
        statusNote = "WRITTEN & RELOADED ISOLATED CONFIG"
        settingsApplied(activeSection, statusNote)
    }

    function reloadConfig() {
        settingsFileView.reload()
        if (Hyprland.workspaces !== null && !monitorsProbeProc.running) {
            monitorsProbeProc.running = true
        }
        dirty = false
        statusNote = "RELOADED FROM " + settingsFilePath
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
            displayConfigs = []
            if (Hyprland.workspaces !== null && !monitorsProbeProc.running) monitorsProbeProc.running = true
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
        _persistDisk()
        _dispatchLiveKeywords()
        dirty = false
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
        applyAll()
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
        return JSON.stringify(payload, null, 2)
    }
}
