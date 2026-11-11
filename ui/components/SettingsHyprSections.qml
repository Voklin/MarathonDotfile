pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Item {
    id: root

    required property var backend
    required property string activeSection
    property string searchQuery: ""
    property bool reducedMotion: false

    readonly property var s: backend ? backend.settings : null
    readonly property int contentHeight: {
        if (activeSection === "compositor") return secCompositor.implicitHeight
        if (activeSection === "displays") return secDisplays.implicitHeight
        if (activeSection === "input") return secInput.implicitHeight
        if (activeSection === "keybinds") return secKeybinds.implicitHeight
        if (activeSection === "rules") return secRules.implicitHeight
        if (activeSection === "autostart") return secAutostart.implicitHeight
        return 0
    }
    implicitHeight: contentHeight
    height: contentHeight

    property string newRuleMatchType: "class"
    property bool newRuleFloat: true
    property bool newRuleCenter: true
    property bool newRulePin: false

    function matches(text) {
        var q = (searchQuery || "").trim().toLowerCase()
        if (q === "") return false
        return (text || "").toLowerCase().indexOf(q) !== -1
    }

    // =========================================================================
    // 8. COMPOSITOR // LAYOUT, GAPS, DECORATIONS & ANIMATIONS
    // =========================================================================
    ColumnLayout {
        id: secCompositor
        visible: root.activeSection === "compositor"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Hyprland Tiling Layout"
            sublabel: root.s ? root.s.hyprLayout.toUpperCase() : "DWINDLE"
            highlighted: root.matches("layout dwindle master tiling")
            selectedId: root.s ? root.s.hyprLayout : "dwindle"
            options: [
                { id: "dwindle", label: "DWINDLE (BSP)" },
                { id: "master", label: "MASTER / STACK" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("hyprLayout", id) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Inner Window Gaps (gaps_in)"
            highlighted: root.matches("gaps inner spacing")
            value: root.s ? root.s.hyprGapsIn : 4
            minValue: 0
            maxValue: 24
            stepSize: 2
            unit: "PX"
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("hyprGapsIn", Math.round(v)) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Outer Screen Gaps (gaps_out)"
            highlighted: root.matches("gaps outer margin")
            value: root.s ? root.s.hyprGapsOut : 8
            minValue: 0
            maxValue: 32
            stepSize: 2
            unit: "PX"
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("hyprGapsOut", Math.round(v)) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Window Border Size"
            highlighted: root.matches("border size frame")
            value: root.s ? root.s.hyprBorderSize : 2
            minValue: 0
            maxValue: 5
            stepSize: 1
            unit: "PX"
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("hyprBorderSize", Math.round(v)) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Window Corner Rounding"
            sublabel: "0 px preserves strict MARATHON Tactical geometry"
            highlighted: root.matches("rounding corner radius window")
            value: root.s ? root.s.hyprRounding : 0
            minValue: 0
            maxValue: 16
            stepSize: 2
            unit: "PX"
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("hyprRounding", Math.round(v)) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Active Window Opacity"
            value: root.s ? root.s.hyprActiveOpacity : 1.0
            minValue: 0.70
            maxValue: 1.00
            stepSize: 0.05
            decimals: 2
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("hyprActiveOpacity", v) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Inactive Window Opacity"
            value: root.s ? root.s.hyprInactiveOpacity : 1.0
            minValue: 0.60
            maxValue: 1.00
            stepSize: 0.05
            decimals: 2
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("hyprInactiveOpacity", v) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Compositor Blur (decoration:blur)"
            sublabel: "Keep OFF for razor-sharp tactical typography & low GPU load"
            checked: root.s ? root.s.hyprBlurEnabled : false
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("hyprBlurEnabled", next) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Window Drop Shadows"
            checked: root.s ? root.s.hyprShadowEnabled : false
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("hyprShadowEnabled", next) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Variable Refresh Rate (misc:vfr)"
            sublabel: "Lowers frame rate on static screens to save laptop power"
            checked: root.s ? root.s.hyprVfrEnabled : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("hyprVfrEnabled", next) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Resize Windows on Border Drag"
            checked: root.s ? root.s.hyprResizeOnBorder : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("hyprResizeOnBorder", next) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Allow Screen Tearing (Low-Latency Gaming)"
            checked: root.s ? root.s.hyprAllowTearing : false
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("hyprAllowTearing", next) }
        }

        HudDivider { Layout.fillWidth: true }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Hyprland Window Animations"
            sublabel: (root.s && root.s.hyprAnimationsEnabled) ? "TACTICAL WORKSPACE & WINDOW CURVES" : "INSTANT COMPOSITOR SWITCHING"
            checked: root.s ? root.s.hyprAnimationsEnabled : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("hyprAnimationsEnabled", next) }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Compositor Animation Curve"
            selectedId: root.s ? root.s.hyprAnimStyle : "tactical"
            enabledState: root.s ? root.s.hyprAnimationsEnabled : true
            options: [
                { id: "tactical", label: "TACTICAL SNAP" },
                { id: "snappy", label: "FAST OVERDRIVE" },
                { id: "linear", label: "LINEAR" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("hyprAnimStyle", id) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Hyprland Animation Speed"
            value: root.s ? root.s.hyprAnimationSpeed : 1.0
            minValue: 0.4
            maxValue: 2.0
            stepSize: 0.1
            decimals: 1
            unit: "x"
            enabledState: root.s ? root.s.hyprAnimationsEnabled : true
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("hyprAnimationSpeed", v) }
        }
    }

    // =========================================================================
    // 9. DISPLAYS // MONITORS, MODES, SCALE & ROTATION
    // =========================================================================
    ColumnLayout {
        id: secDisplays
        visible: root.activeSection === "displays"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        TacticalToggle {
            Layout.fillWidth: true
            label: "XWayland Force Zero Scaling"
            sublabel: "Prevents blurry X11/Steam apps on fractional HiDPI setups"
            iconName: "settings"
            checked: root.s ? root.s.xwaylandForceZeroScaling : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("xwaylandForceZeroScaling", next) }
        }

        EmptyState {
            visible: !(root.s && root.s.displayConfigs && root.s.displayConfigs.length > 0)
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            code: "NO OUTPUTS"
            title: "NO WAYLAND MONITORS PROBED"
            detail: "FALLBACK CATCH-ALL RULE ACTIVE (monitor = , preferred, auto, 1)"
            iconName: "grid"
        }

        Repeater {
            model: root.s ? root.s.displayConfigs : []
            delegate: Rectangle {
                id: monCard
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: monCol.implicitHeight + Tokens.spaceMd * 2
                radius: Tokens.cornerRadius
                color: Tokens.surface
                border.width: Tokens.borderWidth
                border.color: monCard.modelData.enabled ? Tokens.borderStrong : Tokens.borderSubtle

                ColumnLayout {
                    id: monCol
                    anchors.fill: parent
                    anchors.margins: Tokens.spaceMd
                    spacing: Tokens.spaceSm

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spaceSm

                        StatusPill {
                            text: monCard.modelData.name
                            tone: monCard.modelData.primary ? "signal" : "neutral"
                            showDot: monCard.modelData.enabled
                        }

                        Text {
                            Layout.fillWidth: true
                            text: monCard.modelData.description || "Monitor Output"
                            color: Tokens.text
                            font.family: Tokens.fontUi
                            font.pixelSize: Tokens.fontBody
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        TacticalButton {
                            text: monCard.modelData.enabled ? "ENABLED" : "DISABLED"
                            active: monCard.modelData.enabled
                            variant: monCard.modelData.enabled ? "primary" : "danger"
                            implicitHeight: Tokens.controlHeightSm
                            reducedMotion: root.reducedMotion
                            onClicked: {
                                if (root.s) root.s.updateDisplayConfig(monCard.modelData.name, { enabled: !monCard.modelData.enabled })
                            }
                        }
                    }

                    SettingsChoiceGroup {
                        Layout.fillWidth: true
                        label: "Resolution & Refresh Mode"
                        selectedId: monCard.modelData.mode
                        enabledState: monCard.modelData.enabled
                        options: {
                            var modes = monCard.modelData.availableModes || ["preferred", "1920x1080@60"]
                            var out = []
                            for (var i = 0; i < modes.length; ++i) {
                                out.push({ id: modes[i], label: modes[i].toUpperCase() })
                            }
                            return out
                        }
                        reducedMotion: root.reducedMotion
                        onOptionSelected: function(id) {
                            if (root.s) root.s.updateDisplayConfig(monCard.modelData.name, { mode: id })
                        }
                    }

                    SettingsChoiceGroup {
                        Layout.fillWidth: true
                        label: "HiDPI Scale Factor"
                        sublabel: Number(monCard.modelData.scale).toFixed(2) + "x"
                        selectedId: Number(monCard.modelData.scale).toFixed(2)
                        enabledState: monCard.modelData.enabled
                        options: [
                            { id: "1.00", label: "1.00x" },
                            { id: "1.25", label: "1.25x" },
                            { id: "1.50", label: "1.50x" },
                            { id: "1.75", label: "1.75x" },
                            { id: "2.00", label: "2.00x" }
                        ]
                        reducedMotion: root.reducedMotion
                        onOptionSelected: function(id) {
                            if (root.s) root.s.updateDisplayConfig(monCard.modelData.name, { scale: parseFloat(id) })
                        }
                    }

                    SettingsChoiceGroup {
                        Layout.fillWidth: true
                        label: "Orientation / Transform"
                        selectedId: String(monCard.modelData.transform)
                        enabledState: monCard.modelData.enabled
                        options: [
                            { id: "0", label: "0 DEG" },
                            { id: "1", label: "90 DEG" },
                            { id: "2", label: "180 DEG" },
                            { id: "3", label: "270 DEG" }
                        ]
                        reducedMotion: root.reducedMotion
                        onOptionSelected: function(id) {
                            if (root.s) root.s.updateDisplayConfig(monCard.modelData.name, { transform: parseInt(id, 10) })
                        }
                    }

                    SettingsChoiceGroup {
                        Layout.fillWidth: true
                        label: "Display Coordinate Position"
                        selectedId: monCard.modelData.position
                        enabledState: monCard.modelData.enabled
                        options: [
                            { id: "auto", label: "AUTO" },
                            { id: "0x0", label: "0x0 (PRIMARY)" },
                            { id: "1920x0", label: "1920x0 (RIGHT)" },
                            { id: "2560x0", label: "2560x0 (RIGHT QHD)" }
                        ]
                        reducedMotion: root.reducedMotion
                        onOptionSelected: function(id) {
                            if (root.s) root.s.updateDisplayConfig(monCard.modelData.name, { position: id })
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // 10. INPUT // KEYBOARD, POINTER & TOUCHPAD
    // =========================================================================
    ColumnLayout {
        id: secInput
        visible: root.activeSection === "input"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Keyboard Layouts (kb_layout)"
            sublabel: root.s ? root.s.kbLayout.toUpperCase() : "US"
            highlighted: root.matches("keyboard layout ru us de")
            selectedId: root.s ? root.s.kbLayout : "us"
            options: [
                { id: "us", label: "US" },
                { id: "us,ru", label: "US + RU" },
                { id: "us,de", label: "US + DE" },
                { id: "us,fr", label: "US + FR" },
                { id: "us,ua", label: "US + UA" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("kbLayout", id) }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Layout Toggle Shortcut (kb_options)"
            selectedId: root.s ? root.s.kbOptions : "grp:alt_shift_toggle"
            options: [
                { id: "", label: "NONE" },
                { id: "grp:alt_shift_toggle", label: "ALT + SHIFT" },
                { id: "grp:win_space_toggle", label: "SUPER + SPACE" },
                { id: "grp:caps_toggle", label: "CAPS LOCK" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("kbOptions", id) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Key Repeat Rate"
            value: root.s ? root.s.repeatRate : 35
            minValue: 15
            maxValue: 60
            stepSize: 5
            unit: "HZ"
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("repeatRate", Math.round(v)) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Key Repeat Delay"
            value: root.s ? root.s.repeatDelay : 250
            minValue: 150
            maxValue: 600
            stepSize: 25
            unit: "MS"
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("repeatDelay", Math.round(v)) }
        }

        HudDivider { Layout.fillWidth: true }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Pointer Sensitivity"
            highlighted: root.matches("mouse pointer sensitivity speed")
            value: root.s ? root.s.pointerSensitivity : 0.0
            minValue: -1.0
            maxValue: 1.0
            stepSize: 0.1
            decimals: 1
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("pointerSensitivity", v) }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Pointer Acceleration Profile"
            selectedId: root.s ? root.s.accelProfile : "flat"
            options: [
                { id: "flat", label: "FLAT (RAW 1:1)" },
                { id: "adaptive", label: "ADAPTIVE" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("accelProfile", id) }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Focus Follows Mouse"
            selectedId: String(root.s ? root.s.followMouse : 1)
            options: [
                { id: "0", label: "0 // CLICK" },
                { id: "1", label: "1 // HOVER" },
                { id: "2", label: "2 // DETACHED" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("followMouse", parseInt(id, 10)) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Touchpad Tap-to-Click"
            checked: root.s ? root.s.touchpadTapToClick : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("touchpadTapToClick", next) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Touchpad Natural Scroll (Reverse)"
            checked: root.s ? root.s.touchpadNaturalScroll : false
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("touchpadNaturalScroll", next) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Touchpad Disable While Typing"
            checked: root.s ? root.s.touchpadDisableWhileTyping : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("touchpadDisableWhileTyping", next) }
        }
    }

    // =========================================================================
    // 11. KEYBINDS & DEFAULT APPS
    // =========================================================================
    ColumnLayout {
        id: secKeybinds
        visible: root.activeSection === "keybinds"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        // Default Apps
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: defAppsCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surface
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            ColumnLayout {
                id: defAppsCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "DEFAULT COMPOSITOR APPLICATIONS"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                SettingsChoiceGroup {
                    Layout.fillWidth: true
                    label: "Terminal ($terminal)"
                    selectedId: root.s ? root.s.defaultTerminal : "ghostty"
                    options: [
                        { id: "ghostty", label: "GHOSTTY" },
                        { id: "alacritty", label: "ALACRITTY" },
                        { id: "kitty", label: "KITTY" },
                        { id: "foot", label: "FOOT" }
                    ]
                    reducedMotion: root.reducedMotion
                    onOptionSelected: function(id) { if (root.s) root.s.setSetting("defaultTerminal", id) }
                }

                SettingsChoiceGroup {
                    Layout.fillWidth: true
                    label: "File Manager ($fileManager)"
                    selectedId: root.s ? root.s.defaultFileManager : "dolphin"
                    options: [
                        { id: "dolphin", label: "DOLPHIN" },
                        { id: "thunar", label: "THUNAR" },
                        { id: "nautilus", label: "NAUTILUS" },
                        { id: "yazi", label: "YAZI" }
                    ]
                    reducedMotion: root.reducedMotion
                    onOptionSelected: function(id) { if (root.s) root.s.setSetting("defaultFileManager", id) }
                }

                SettingsChoiceGroup {
                    Layout.fillWidth: true
                    label: "Web Browser ($browser)"
                    selectedId: root.s ? root.s.defaultBrowser : "firefox"
                    options: [
                        { id: "firefox", label: "FIREFOX" },
                        { id: "chromium", label: "CHROMIUM" },
                        { id: "zen-browser", label: "ZEN" },
                        { id: "brave", label: "BRAVE" }
                    ]
                    reducedMotion: root.reducedMotion
                    onOptionSelected: function(id) { if (root.s) root.s.setSetting("defaultBrowser", id) }
                }

                SettingsChoiceGroup {
                    Layout.fillWidth: true
                    label: "Text Editor ($editor)"
                    selectedId: root.s ? root.s.defaultEditor : "nvim"
                    options: [
                        { id: "nvim", label: "NEOVIM" },
                        { id: "helix", label: "HELIX" },
                        { id: "nano", label: "NANO" },
                        { id: "code", label: "VS CODE" }
                    ]
                    reducedMotion: root.reducedMotion
                    onOptionSelected: function(id) { if (root.s) root.s.setSetting("defaultEditor", id) }
                }

                SettingsChoiceGroup {
                    Layout.fillWidth: true
                    label: "Media Player ($mediaPlayer)"
                    selectedId: root.s ? root.s.defaultMediaPlayer : "mpv"
                    options: [
                        { id: "mpv", label: "MPV" },
                        { id: "vlc", label: "VLC" },
                        { id: "celluloid", label: "CELLULOID" }
                    ]
                    reducedMotion: root.reducedMotion
                    onOptionSelected: function(id) { if (root.s) root.s.setSetting("defaultMediaPlayer", id) }
                }

                SettingsChoiceGroup {
                    Layout.fillWidth: true
                    label: "Image Viewer ($imageViewer)"
                    selectedId: root.s ? root.s.defaultImageViewer : "imv"
                    options: [
                        { id: "imv", label: "IMV" },
                        { id: "loupe", label: "LOUPE" },
                        { id: "gwenview", label: "GWENVIEW" }
                    ]
                    reducedMotion: root.reducedMotion
                    onOptionSelected: function(id) { if (root.s) root.s.setSetting("defaultImageViewer", id) }
                }

                SettingsChoiceGroup {
                    Layout.fillWidth: true
                    label: "PDF / Document Viewer ($pdfViewer)"
                    selectedId: root.s ? root.s.defaultPdfViewer : "zathura"
                    options: [
                        { id: "zathura", label: "ZATHURA" },
                        { id: "okular", label: "OKULAR" },
                        { id: "evince", label: "EVINCE" }
                    ]
                    reducedMotion: root.reducedMotion
                    onOptionSelected: function(id) { if (root.s) root.s.setSetting("defaultPdfViewer", id) }
                }

                SettingsChoiceGroup {
                    Layout.fillWidth: true
                    label: "TUI System Monitor ($systemMonitor)"
                    selectedId: root.s ? root.s.defaultSystemMonitor : "btop"
                    options: [
                        { id: "btop", label: "BTOP++" },
                        { id: "htop", label: "HTOP" },
                        { id: "nvtop", label: "NVTOP" }
                    ]
                    reducedMotion: root.reducedMotion
                    onOptionSelected: function(id) { if (root.s) root.s.setSetting("defaultSystemMonitor", id) }
                }
            }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Opt-In Bare Super Key Launcher (bindr SUPER_L)"
            sublabel: "Disabled by default for safety; test Super+chords on CachyOS before enabling"
            iconName: "warning"
            checked: root.s ? root.s.bareSuperLauncher : false
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("bareSuperLauncher", next) }
        }

        // Custom Keybind Builder
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: kbAddCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.borderStrong

            ColumnLayout {
                id: kbAddCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "CUSTOM USER KEYBINDINGS"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs

                    TacticalTextField {
                        id: kbModsField
                        Layout.preferredWidth: 136
                        text: "SUPER"
                        placeholderText: "MODS..."
                    }
                    TacticalTextField {
                        id: kbKeyField
                        Layout.preferredWidth: 80
                        placeholderText: "KEY..."
                    }
                    TacticalTextField {
                        id: kbArgField
                        Layout.fillWidth: true
                        placeholderText: "EXEC COMMAND (e.g. btop)..."
                    }
                    TacticalButton {
                        text: "+ BIND"
                        variant: "primary"
                        implicitHeight: Tokens.controlHeightLg
                        enabledState: kbModsField.text.trim() !== "" && kbKeyField.text.trim() !== "" && kbArgField.text.trim() !== ""
                        reducedMotion: root.reducedMotion
                        onClicked: {
                            if (root.s) {
                                root.s.addCustomKeybind(kbModsField.text, kbKeyField.text, "exec", kbArgField.text)
                                kbKeyField.text = ""
                                kbArgField.text = ""
                            }
                        }
                    }
                }

                Repeater {
                    model: root.s ? root.s.customKeybinds : []
                    delegate: Rectangle {
                        id: ckbRow
                        required property var modelData
                        Layout.fillWidth: true
                        height: 32
                        color: Tokens.surface
                        border.width: Tokens.borderWidth
                        border.color: ckbRow.modelData.enabled ? Tokens.borderStrong : Tokens.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceXs
                            spacing: Tokens.spaceSm

                            StatusPill {
                                text: ckbRow.modelData.mods + " + " + ckbRow.modelData.key
                                tone: ckbRow.modelData.enabled ? "signal" : "neutral"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: ckbRow.modelData.dispatcher + " " + ckbRow.modelData.arg
                                color: ckbRow.modelData.enabled ? Tokens.text : Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                elide: Text.ElideRight
                            }

                            TacticalButton {
                                text: ckbRow.modelData.enabled ? "ON" : "OFF"
                                variant: ckbRow.modelData.enabled ? "primary" : "default"
                                implicitHeight: 22
                                implicitWidth: 44
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.s) root.s.toggleCustomKeybind(ckbRow.modelData.id)
                            }

                            TacticalButton {
                                text: ""
                                iconName: "close"
                                variant: "danger"
                                implicitHeight: 22
                                implicitWidth: 26
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.s) root.s.removeCustomKeybind(ckbRow.modelData.id)
                            }
                        }
                    }
                }
            }
        }

        // Built-in Keybinds Catalog
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: kbCatCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surface
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            ColumnLayout {
                id: kbCatCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: 2

                Text {
                    text: "BUILTIN MARATHON KEYBINDINGS (READ-ONLY REFERENCE)"
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                Repeater {
                    model: root.s ? root.s.keybindCatalog : []
                    delegate: Rectangle {
                        id: kbItem
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        height: 24
                        color: (kbItem.index % 2 === 0) ? Tokens.surfaceZebra : Tokens.surfacePressed

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceXs
                            anchors.rightMargin: Tokens.spaceXs
                            spacing: Tokens.spaceSm

                            Text {
                                Layout.preferredWidth: 74
                                text: kbItem.modelData.category
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                            }
                            Text {
                                Layout.preferredWidth: 165
                                text: kbItem.modelData.chord
                                color: Tokens.signal
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: kbItem.modelData.action
                                color: Tokens.text
                                font.family: Tokens.fontUi
                                font.pixelSize: Tokens.fontMicro
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // 12. WINDOW & LAYER RULES (HYPRLAND >= 0.53 MATCH: SYNTAX)
    // =========================================================================
    ColumnLayout {
        id: secRules
        visible: root.activeSection === "rules"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: wrAddCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.borderStrong

            ColumnLayout {
                id: wrAddCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "CUSTOM WINDOW RULE BUILDER (HYPRLAND >= 0.53 match:)"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs

                    TacticalTextField {
                        id: wrNameField
                        Layout.preferredWidth: 140
                        placeholderText: "RULE NAME..."
                    }
                    TacticalButton {
                        text: root.newRuleMatchType.toUpperCase()
                        implicitWidth: 68
                        implicitHeight: Tokens.controlHeightLg
                        reducedMotion: root.reducedMotion
                        onClicked: root.newRuleMatchType = (root.newRuleMatchType === "class" ? "title" : "class")
                    }
                    TacticalTextField {
                        id: wrPatternField
                        Layout.fillWidth: true
                        placeholderText: "REGEX PATTERN (e.g. ^(pavucontrol)$)..."
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs

                    TacticalButton {
                        text: "FLOAT"
                        active: root.newRuleFloat
                        variant: root.newRuleFloat ? "primary" : "default"
                        implicitHeight: Tokens.controlHeightSm
                        reducedMotion: root.reducedMotion
                        onClicked: root.newRuleFloat = !root.newRuleFloat
                    }
                    TacticalButton {
                        text: "CENTER"
                        active: root.newRuleCenter
                        variant: root.newRuleCenter ? "primary" : "default"
                        implicitHeight: Tokens.controlHeightSm
                        reducedMotion: root.reducedMotion
                        onClicked: root.newRuleCenter = !root.newRuleCenter
                    }
                    TacticalButton {
                        text: "PIN"
                        active: root.newRulePin
                        variant: root.newRulePin ? "primary" : "default"
                        implicitHeight: Tokens.controlHeightSm
                        reducedMotion: root.reducedMotion
                        onClicked: root.newRulePin = !root.newRulePin
                    }

                    Item { Layout.fillWidth: true }

                    TacticalButton {
                        text: "+ ADD RULE"
                        variant: "primary"
                        implicitHeight: Tokens.controlHeightSm
                        enabledState: wrNameField.text.trim() !== "" && wrPatternField.text.trim() !== ""
                        reducedMotion: root.reducedMotion
                        onClicked: {
                            if (root.s) {
                                root.s.addWindowRule(wrNameField.text, root.newRuleMatchType, wrPatternField.text, root.newRuleFloat, root.newRuleCenter, root.newRulePin)
                                wrNameField.text = ""
                                wrPatternField.text = ""
                            }
                        }
                    }
                }

                Repeater {
                    model: root.s ? root.s.customWindowRules : []
                    delegate: Rectangle {
                        id: wrRow
                        required property var modelData
                        Layout.fillWidth: true
                        height: 34
                        color: Tokens.surface
                        border.width: Tokens.borderWidth
                        border.color: wrRow.modelData.enabled ? Tokens.borderStrong : Tokens.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceXs
                            spacing: Tokens.spaceSm

                            StatusPill {
                                text: wrRow.modelData.matchType.toUpperCase()
                                tone: wrRow.modelData.enabled ? "signal" : "neutral"
                            }
                            Text {
                                Layout.fillWidth: true
                                text: wrRow.modelData.name + " // " + wrRow.modelData.pattern
                                color: Tokens.text
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                elide: Text.ElideRight
                            }
                            TacticalButton {
                                text: wrRow.modelData.enabled ? "ON" : "OFF"
                                variant: wrRow.modelData.enabled ? "primary" : "default"
                                implicitHeight: 22
                                implicitWidth: 44
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.s) root.s.toggleWindowRule(wrRow.modelData.id)
                            }
                            TacticalButton {
                                text: ""
                                iconName: "close"
                                variant: "danger"
                                implicitHeight: 22
                                implicitWidth: 26
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.s) root.s.removeWindowRule(wrRow.modelData.id)
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: brCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surface
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            ColumnLayout {
                id: brCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: 2

                Text {
                    text: "BUILTIN RULES (hypr/modules/rules.lua)"
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                Repeater {
                    model: root.s ? root.s.builtinRules : []
                    delegate: Rectangle {
                        id: brRow
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        height: 26
                        color: (brRow.index % 2 === 0) ? Tokens.surfaceZebra : Tokens.surfacePressed

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceXs
                            anchors.rightMargin: Tokens.spaceXs
                            spacing: Tokens.spaceSm

                            Text {
                                Layout.preferredWidth: 170
                                text: brRow.modelData.name
                                color: Tokens.signal
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: brRow.modelData.effect
                                color: Tokens.text
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // 13. AUTOSTART, ENVIRONMENT & GPU
    // =========================================================================
    ColumnLayout {
        id: secAutostart
        visible: root.activeSection === "autostart"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        // Autostart
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: asCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surface
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            ColumnLayout {
                id: asCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "ISOLATED SESSION AUTOSTART (exec-once)"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: "Do not add competing notification daemons (dunst/mako/swaync) — MARATHON claims org.freedesktop.Notifications safely."
                    color: Tokens.muted
                    font.family: Tokens.fontUi
                    font.pixelSize: Tokens.fontMicro
                    wrapMode: Text.Wrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs

                    TacticalTextField {
                        id: asLabelField
                        Layout.preferredWidth: 140
                        placeholderText: "LABEL..."
                    }
                    TacticalTextField {
                        id: asCmdField
                        Layout.fillWidth: true
                        placeholderText: "COMMAND (e.g. wl-paste --watch cliphist store)..."
                    }
                    TacticalButton {
                        text: "+ ADD"
                        variant: "primary"
                        implicitHeight: Tokens.controlHeightLg
                        enabledState: asCmdField.text.trim() !== ""
                        reducedMotion: root.reducedMotion
                        onClicked: {
                            if (root.s) {
                                root.s.addAutostart(asLabelField.text, asCmdField.text)
                                asLabelField.text = ""
                                asCmdField.text = ""
                            }
                        }
                    }
                }

                Repeater {
                    model: root.s ? root.s.autostartItems : []
                    delegate: Rectangle {
                        id: asRow
                        required property var modelData
                        Layout.fillWidth: true
                        height: 32
                        color: Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: asRow.modelData.enabled ? Tokens.borderStrong : Tokens.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceXs
                            spacing: Tokens.spaceSm

                            Text {
                                Layout.preferredWidth: 140
                                text: asRow.modelData.label
                                color: asRow.modelData.enabled ? Tokens.text : Tokens.muted
                                font.family: Tokens.fontUi
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: asRow.modelData.command
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                elide: Text.ElideRight
                            }
                            TacticalButton {
                                text: asRow.modelData.enabled ? "ON" : "OFF"
                                variant: asRow.modelData.enabled ? "primary" : "default"
                                implicitHeight: 22
                                implicitWidth: 44
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.s) root.s.toggleAutostart(asRow.modelData.id)
                            }
                            TacticalButton {
                                text: ""
                                iconName: "close"
                                variant: "danger"
                                implicitHeight: 22
                                implicitWidth: 26
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.s) root.s.removeAutostart(asRow.modelData.id)
                            }
                        }
                    }
                }
            }
        }

        // Environment Variables
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: evCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surface
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            ColumnLayout {
                id: evCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "ENVIRONMENT VARIABLES (env = KEY,VALUE)"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs

                    TacticalTextField {
                        id: evKeyField
                        Layout.preferredWidth: 160
                        placeholderText: "VAR KEY..."
                    }
                    TacticalTextField {
                        id: evValField
                        Layout.fillWidth: true
                        placeholderText: "VALUE..."
                    }
                    TacticalButton {
                        text: "+ ENV"
                        variant: "primary"
                        implicitHeight: Tokens.controlHeightLg
                        enabledState: evKeyField.text.trim() !== "" && evValField.text.trim() !== ""
                        reducedMotion: root.reducedMotion
                        onClicked: {
                            if (root.s) {
                                root.s.addEnvVar(evKeyField.text, evValField.text)
                                evKeyField.text = ""
                                evValField.text = ""
                            }
                        }
                    }
                }

                Repeater {
                    model: root.s ? root.s.envVars : []
                    delegate: Rectangle {
                        id: evRow
                        required property var modelData
                        Layout.fillWidth: true
                        height: 30
                        color: Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: Tokens.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceXs
                            spacing: Tokens.spaceSm

                            Text {
                                Layout.fillWidth: true
                                text: evRow.modelData.key + " = " + evRow.modelData.value
                                color: evRow.modelData.enabled ? Tokens.text : Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                elide: Text.ElideRight
                            }
                            TacticalButton {
                                text: evRow.modelData.enabled ? "ON" : "OFF"
                                variant: evRow.modelData.enabled ? "primary" : "default"
                                implicitHeight: 22
                                implicitWidth: 44
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.s) root.s.toggleEnvVar(evRow.modelData.id)
                            }
                            TacticalButton {
                                text: ""
                                iconName: "close"
                                variant: "danger"
                                implicitHeight: 22
                                implicitWidth: 26
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.s) root.s.removeEnvVar(evRow.modelData.id)
                            }
                        }
                    }
                }
            }
        }

        // GPU Device Policy
        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Primary GPU Render Policy"
            sublabel: root.s ? root.s.gpuRenderMode.toUpperCase() : "AUTO"
            selectedId: root.s ? root.s.gpuRenderMode : "auto"
            options: [
                { id: "auto", label: "AUTO (COMPOSITOR)" },
                { id: "integrated", label: "PREFER iGPU (POWER)" },
                { id: "discrete", label: "PREFER dGPU (PERF)" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("gpuRenderMode", id) }
        }
    }
}
