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

    signal openSessionRequested()
    signal openNotificationsRequested()

    readonly property var s: backend ? backend.settings : null
    readonly property int contentHeight: {
        if (activeSection === "profile") return secProfile.implicitHeight
        if (activeSection === "appearance") return secAppearance.implicitHeight
        if (activeSection === "hud") return secHud.implicitHeight
        if (activeSection === "wallpaper") return secWallpaper.implicitHeight
        if (activeSection === "launcher") return secLauncher.implicitHeight
        if (activeSection === "notifications") return secNotifications.implicitHeight
        if (activeSection === "session") return secSession.implicitHeight
        return 0
    }
    implicitHeight: contentHeight
    height: contentHeight

    function matches(text) {
        var q = (searchQuery || "").trim().toLowerCase()
        if (q === "") return false
        return (text || "").toLowerCase().indexOf(q) !== -1
    }

    // =========================================================================
    // 1. PROFILE // RUNNER IDENTITY & WORKSTATION SPECIMEN
    // =========================================================================
    ColumnLayout {
        id: secProfile
        visible: root.activeSection === "profile"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        RunnerEmblemCard {
            Layout.fillWidth: true
            compact: false
            showSelector: true
            reducedMotion: root.reducedMotion
            onEmblemSelected: function(emblemId) {
                if (root.backend && root.backend.appearance) root.backend.appearance.setEmblem(emblemId)
                if (root.s) root.s.setSetting("statusNote", "EMBLEM UPDATED: " + emblemId)
            }
            onNameEdited: function(nextName) {
                if (root.backend && root.backend.appearance) root.backend.appearance.setRunnerName(nextName)
            }
            onTitleEdited: function(nextTitle) {
                if (root.backend && root.backend.appearance) root.backend.appearance.setRunnerTitle(nextTitle)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: specCol.implicitHeight + Tokens.spaceMd * 2
            radius: Tokens.cornerRadius
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.borderStrong

            ColumnLayout {
                id: specCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceMd
                spacing: Tokens.spaceXs

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "COLLECTOR SPECIMEN // WORKSTATION HARDWARE"
                        color: Tokens.signal
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontMicro
                        font.bold: true
                    }
                    StatusPill {
                        text: root.backend && root.backend.appearance ? root.backend.appearance.sysLabel : "ONLINE"
                        tone: "signal"
                        showDot: true
                    }
                }

                Repeater {
                    model: root.s && root.s.hostSpecs ? [
                        { k: "HOST", v: root.s.hostSpecs.hostname || "-" },
                        { k: "OS / DISTRO", v: root.s.hostSpecs.distro || "-" },
                        { k: "KERNEL", v: root.s.hostSpecs.kernel || "-" },
                        { k: "PROCESSOR", v: root.s.hostSpecs.cpu || "-" },
                        { k: "GRAPHICS", v: root.s.hostSpecs.gpu || "-" },
                        { k: "MEMORY", v: root.s.hostSpecs.memory || "-" },
                        { k: "UPTIME", v: root.backend && root.backend.appearance ? root.backend.appearance.uptimeText : "-" },
                        { k: "COMPOSITOR", v: root.s.hostSpecs.compositor || "-" },
                        { k: "SHELL", v: root.s.hostSpecs.shellVersion || "-" }
                    ] : []
                    delegate: Rectangle {
                        id: specRow
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        height: 24
                        color: (specRow.index % 2 === 0) ? Tokens.surfaceZebra : Tokens.surface

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceSm
                            spacing: Tokens.spaceSm

                            Text {
                                Layout.preferredWidth: 112
                                text: specRow.modelData.k
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                            }

                            Text {
                                Layout.fillWidth: true
                                text: specRow.modelData.v
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
    // 2. APPEARANCE // FACTION PALETTE, CUSTOM ACCENT, SCALE & GEOMETRY
    // =========================================================================
    ColumnLayout {
        id: secAppearance
        visible: root.activeSection === "appearance"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        // Faction Matrix
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: facCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: root.matches("faction accent theme palette") ? Tokens.surfaceElevated : Tokens.surface
            border.width: Tokens.borderWidth
            border.color: root.matches("faction accent theme palette") ? Tokens.signal : Tokens.border

            ColumnLayout {
                id: facCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "CORPORATE FACTION ACCENT // " + Tokens.factionId
                        color: Tokens.signal
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontMicro
                        font.bold: true
                    }
                    Text {
                        text: Tokens.customAccentHex !== "" ? ("OVERRIDE: " + Tokens.customAccentHex) : "FACTION DEFAULT"
                        color: Tokens.muted
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontMicro
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: Tokens.spaceXs
                    rowSpacing: Tokens.spaceXs

                    Repeater {
                        model: Tokens.factions
                        delegate: TacticalButton {
                            id: facDel
                            required property var modelData
                            Layout.fillWidth: true
                            text: facDel.modelData.id
                            active: Tokens.factionId === facDel.modelData.id && Tokens.customAccentHex === ""
                            variant: active ? "primary" : "default"
                            implicitHeight: Tokens.controlHeightSm
                            reducedMotion: root.reducedMotion
                            onClicked: {
                                Tokens.setFaction(facDel.modelData.id)
                                if (root.backend && root.backend.appearance) root.backend.appearance.setFaction(facDel.modelData.id)
                                if (root.s) root.s.setSetting("customAccentHex", "")
                            }
                        }
                    }
                }
            }
        }

        // Accent Swatches + Custom Hex Input
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: swCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: root.matches("custom color accent hex swatch") ? Tokens.surfaceElevated : Tokens.surface
            border.width: Tokens.borderWidth
            border.color: root.matches("custom color accent hex swatch") ? Tokens.signal : Tokens.border

            ColumnLayout {
                id: swCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "CUSTOM ACCENT OVERRIDE // SWATCHES & HEX"
                    color: Tokens.text
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs

                    Repeater {
                        model: Tokens.accentSwatches
                        delegate: TacticalButton {
                            id: swBtn
                            required property var modelData
                            readonly property bool isActive: Tokens.customAccentHex === swBtn.modelData.hex
                            text: swBtn.modelData.label
                            active: swBtn.isActive
                            variant: swBtn.isActive ? "primary" : "default"
                            implicitHeight: Tokens.controlHeightSm
                            reducedMotion: root.reducedMotion
                            onClicked: {
                                if (root.s) root.s.setSetting("customAccentHex", swBtn.modelData.hex)
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs

                    TacticalTextField {
                        id: hexField
                        Layout.fillWidth: true
                        placeholderText: "CUSTOM HEX (#RRGGBB, e.g. #00FFAA)..."
                        text: Tokens.customAccentHex
                        errorText: (hexField.text.trim() !== "" && !Tokens.isValidHexColor(hexField.text)) ? "EXPECT #RRGGBB" : ""
                        onTextSubmitted: {
                            if (Tokens.isValidHexColor(hexField.text) && root.s) {
                                root.s.setSetting("customAccentHex", hexField.text.trim().toUpperCase())
                            }
                        }
                    }

                    TacticalButton {
                        text: "APPLY HEX"
                        variant: "primary"
                        enabledState: hexField.text.trim() === "" || Tokens.isValidHexColor(hexField.text)
                        implicitHeight: Tokens.controlHeightLg
                        reducedMotion: root.reducedMotion
                        onClicked: {
                            if (root.s) root.s.setSetting("customAccentHex", hexField.text.trim().toUpperCase())
                        }
                    }
                }
            }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Surface Contrast Profile"
            sublabel: root.s ? root.s.surfaceTheme : "TACTICAL"
            highlighted: root.matches("surface theme void slate contrast dark")
            selectedId: root.s ? root.s.surfaceTheme : "TACTICAL"
            options: Tokens.surfaceThemes
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) {
                if (root.s) root.s.setSetting("surfaceTheme", id)
            }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Panel & Control Corner Radius"
            sublabel: (root.s ? root.s.cornerRadius : 0) + " PX"
            highlighted: root.matches("corner radius rounding sharp chamfer")
            selectedId: String(root.s ? root.s.cornerRadius : 0)
            options: [
                { id: "0", label: "0 PX // SHARP" },
                { id: "2", label: "2 PX // CHAMFER" },
                { id: "4", label: "4 PX // TACTICAL" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) {
                if (root.s) root.s.setSetting("cornerRadius", parseInt(id, 10))
            }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Structural Border Thickness"
            sublabel: (root.s ? root.s.borderThickness : 1) + " PX"
            highlighted: root.matches("border width thickness outline")
            selectedId: String(root.s ? root.s.borderThickness : 1)
            options: [
                { id: "1", label: "1 PX // HAIRLINE" },
                { id: "2", label: "2 PX // HEAVY" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) {
                if (root.s) root.s.setSetting("borderThickness", parseInt(id, 10))
            }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Reduced Motion (Static Transitions)"
            sublabel: root.backend && root.backend.appearance && root.backend.appearance.reducedMotion
                ? "ACTIVE // 0 MS INSTANT TRANSITIONS"
                : "SMOOTH TACTICAL MOTION"
            iconName: "settings"
            checked: root.backend && root.backend.appearance ? root.backend.appearance.reducedMotion : false
            reducedMotion: root.reducedMotion
            onToggled: if (root.backend && root.backend.appearance) root.backend.appearance.toggleReducedMotion()
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Motion Duration Multiplier"
            sublabel: "Scales UI reveal & color transition timing"
            highlighted: root.matches("motion animation speed duration")
            value: root.s ? root.s.motionMultiplier : 1.0
            minValue: 0.5
            maxValue: 1.5
            stepSize: 0.1
            decimals: 1
            unit: "x"
            enabledState: !(root.backend && root.backend.appearance && root.backend.appearance.reducedMotion)
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("motionMultiplier", v) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Sync External App Themes (Ghostty, Kitty, Alacritty, Foot, btop, Yazi, GTK, Qt6)"
            sublabel: (root.s && root.s.appThemeSyncEnabled)
                ? "DYNAMICALLY WRITES FACTION PALETTE TO apps/generated/"
                : "MANUAL PALETTE MODE"
            iconName: "palette"
            checked: root.s ? root.s.appThemeSyncEnabled : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("appThemeSyncEnabled", next) }
        }
    }

    // =========================================================================
    // 3. TOP HUD // BAR POSITION, HEIGHT, MULTI-MONITOR & WIDGET MODULES
    // =========================================================================
    ColumnLayout {
        id: secHud
        visible: root.activeSection === "hud"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "HUD Bar Screen Edge"
            sublabel: root.s ? root.s.hudPosition.toUpperCase() : "TOP"
            highlighted: root.matches("hud bar position top bottom edge")
            selectedId: root.s ? root.s.hudPosition : "top"
            options: [
                { id: "top", label: "TOP EDGE" },
                { id: "bottom", label: "BOTTOM EDGE" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("hudPosition", id) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "HUD Bar Height"
            sublabel: "Adjust vertical density of Top/Bottom HUD"
            highlighted: root.matches("hud height bar size")
            value: root.s ? root.s.hudHeight : 38
            minValue: 32
            maxValue: 48
            stepSize: 2
            unit: "PX"
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("hudHeight", Math.round(v)) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Auto-Hide HUD in Fullscreen"
            sublabel: "Slides HUD away when active window enters fullscreen"
            iconName: "grid"
            checked: root.backend && root.backend.appearance ? root.backend.appearance.hudAutoHideOnFullscreen : true
            reducedMotion: root.reducedMotion
            onToggled: if (root.backend && root.backend.appearance) root.backend.appearance.toggleHudAutoHide()
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Multi-Monitor HUD Policy (All Displays)"
            sublabel: (root.s && root.s.hudMultiMonitorAll) ? "RENDER ON ALL MONITORS" : "PRIMARY MONITOR ONLY"
            iconName: "grid"
            checked: root.s ? root.s.hudMultiMonitorAll : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("hudMultiMonitorAll", next) }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: modCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.borderSubtle

            ColumnLayout {
                id: modCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "HUD TELEMETRY MODULE VISIBILITY"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                Repeater {
                    model: [
                        { key: "showRunnerBadge", label: "Runner Emblem Badge", sub: "Calling card emblem & operator callsign" },
                        { key: "showMonitorTag", label: "Monitor Connector Tag", sub: "Shows HUD // eDP-1 identifier" },
                        { key: "showWorkspaces", label: "Workspace Indicator Strip", sub: "Tactical workspace switcher blocks" },
                        { key: "showActiveWindow", label: "Active Window Module", sub: "Focused client title & floating/FS badge" },
                        { key: "showNetworkPill", label: "Network Telemetry Pill", sub: "SSID / Ethernet / Offline indicator" },
                        { key: "showAudioPill", label: "Audio Volume Pill", sub: "Scrollable volume & quick mute pill" },
                        { key: "showBatteryPill", label: "Power / Battery Pill", sub: "Charge percentage or AC status" },
                        { key: "showClockSeconds", label: "Clock Seconds Readout", sub: "HH:MM:SS vs HH:MM compact clock" },
                        { key: "showDateInClock", label: "Date in HUD Clock", sub: "Displays day and month beside time" }
                    ]
                    delegate: TacticalToggle {
                        id: hudModToggle
                        required property var modelData
                        Layout.fillWidth: true
                        label: hudModToggle.modelData.label
                        sublabel: hudModToggle.modelData.sub
                        checked: root.s ? !!root.s[hudModToggle.modelData.key] : true
                        reducedMotion: root.reducedMotion
                        onToggled: function(next) { if (root.s) root.s.setSetting(hudModToggle.modelData.key, next) }
                    }
                }
            }
        }
    }

    // =========================================================================
    // 4. WALLPAPER & TACTICAL BACKDROP
    // =========================================================================
    ColumnLayout {
        id: secWallpaper
        visible: root.activeSection === "wallpaper"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Desktop Backdrop Source"
            sublabel: root.s ? root.s.wallpaperId.toUpperCase() : "MATRIX"
            highlighted: root.matches("wallpaper background grid matrix")
            selectedId: root.s ? root.s.wallpaperId : "matrix"
            options: [
                { id: "matrix", label: "TACTICAL MATRIX" },
                { id: "grid-4k", label: "MARATHON GRID 4K" },
                { id: "grid-1080", label: "MARATHON GRID 1080P" },
                { id: "lock-4k", label: "LOCK VECTOR 4K" },
                { id: "solid", label: "SOLID VOID" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("wallpaperId", id) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Procedural Crosshair Matrix Overlay"
            sublabel: "Zero-idle-CPU Marathon tactical registration grid"
            iconName: "grid"
            checked: root.s ? root.s.backdropMatrixEnabled : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("backdropMatrixEnabled", next) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Crosshair Matrix Opacity"
            value: root.s ? Math.round(root.s.backdropMatrixOpacity * 100) : 42
            minValue: 0
            maxValue: 80
            stepSize: 5
            unit: "%"
            enabledState: root.s ? root.s.backdropMatrixEnabled : true
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("backdropMatrixOpacity", v / 100.0) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Backdrop Dimming Layer"
            sublabel: "Darkens wallpaper behind floating overlays"
            value: root.s ? Math.round(root.s.backdropDim * 100) : 0
            minValue: 0
            maxValue: 60
            stepSize: 5
            unit: "%"
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("backdropDim", v / 100.0) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Auto-Sync Faction Preset on Wallpaper Change"
            sublabel: "Maps selected Marathon wallpaper style to corporate palette"
            iconName: "settings"
            checked: root.s ? root.s.wallpaperAccentSync : false
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("wallpaperAccentSync", next) }
        }
    }

    // =========================================================================
    // 5. LAUNCHER
    // =========================================================================
    ColumnLayout {
        id: secLauncher
        visible: root.activeSection === "launcher"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Default Launcher Presentation"
            sublabel: root.s ? root.s.launcherDefaultLayout.toUpperCase() : "LIST"
            highlighted: root.matches("launcher list grid layout")
            selectedId: root.s ? root.s.launcherDefaultLayout : "list"
            options: [
                { id: "list", label: "COMPACT LIST" },
                { id: "grid", label: "VAULT MATRIX GRID" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("launcherDefaultLayout", id) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Show Recent Apps (MRU Priority)"
            sublabel: "Pins recently deployed applications at top when query is empty"
            iconName: "search"
            checked: root.s ? root.s.launcherShowRecents : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("launcherShowRecents", next) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Max Recent Entries"
            value: root.s ? root.s.launcherMaxRecents : 6
            minValue: 2
            maxValue: 10
            stepSize: 1
            enabledState: root.s ? root.s.launcherShowRecents : true
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("launcherMaxRecents", Math.round(v)) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Enable Safe Command Whitelist Tab [CMDS]"
            sublabel: "Allows toggling DND, Motion, Control Center, Settings, Lock via Tab"
            iconName: "terminal"
            checked: root.s ? root.s.launcherShowCommandsTab : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("launcherShowCommandsTab", next) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Close Launcher Immediately on Deploy"
            sublabel: "Automatically dismisses overlay after launching an app"
            iconName: "close"
            checked: root.s ? root.s.launcherCloseOnLaunch : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("launcherCloseOnLaunch", next) }
        }
    }

    // =========================================================================
    // 6. NOTIFICATIONS & OSD
    // =========================================================================
    ColumnLayout {
        id: secNotifications
        visible: root.activeSection === "notifications"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        TacticalToggle {
            Layout.fillWidth: true
            label: "Do Not Disturb (DND)"
            sublabel: root.backend && root.backend.notifications && root.backend.notifications.dnd ? "SUPPRESS POPUP TOASTS" : "LIVE POPUPS ENABLED"
            iconName: (root.backend && root.backend.notifications && root.backend.notifications.dnd) ? "bell-off" : "bell"
            checked: root.backend && root.backend.notifications ? root.backend.notifications.dnd : false
            enabledState: root.backend && root.backend.notifications ? root.backend.notifications.available : false
            reducedMotion: root.reducedMotion
            onToggled: if (root.backend && root.backend.notifications) root.backend.notifications.toggleDnd()
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Toast Popup Screen Anchor"
            sublabel: root.s ? root.s.toastPosition.toUpperCase() : "TOP-RIGHT"
            highlighted: root.matches("toast notification position corner")
            selectedId: root.s ? root.s.toastPosition : "top-right"
            options: [
                { id: "top-right", label: "TOP-RIGHT" },
                { id: "top-center", label: "TOP-CENTER" },
                { id: "bottom-right", label: "BOTTOM-RIGHT" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("toastPosition", id) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Max Simultaneous Toasts"
            value: root.s ? root.s.toastMaxVisible : 3
            minValue: 1
            maxValue: 5
            stepSize: 1
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("toastMaxVisible", Math.round(v)) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "Toast Auto-Dismiss Timeout"
            value: root.s ? root.s.toastTimeoutMs : 5000
            minValue: 2000
            maxValue: 10000
            stepSize: 500
            unit: "MS"
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("toastTimeoutMs", Math.round(v)) }
        }

        HudDivider { Layout.fillWidth: true }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Enable Volume & Brightness OSD"
            sublabel: "Non-blocking telemetry bar on audio/backlight changes"
            iconName: "audio"
            checked: root.s ? root.s.osdEnabled : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("osdEnabled", next) }
        }

        SettingsStepper {
            Layout.fillWidth: true
            label: "OSD Visibility Duration"
            value: root.s ? root.s.osdDurationMs : 1600
            minValue: 800
            maxValue: 4000
            stepSize: 200
            unit: "MS"
            enabledState: root.s ? root.s.osdEnabled : true
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.s) root.s.setSetting("osdDurationMs", Math.round(v)) }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spaceXs

            TacticalButton {
                Layout.fillWidth: true
                text: "TEST NOTIFICATION"
                iconName: "bell"
                implicitHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: {
                    if (root.backend && root.backend.notifications) {
                        root.backend.notifications.pushNotification("SETTINGS HUB", "Telemetry Diagnostic", "Notification stack test event triggered.", "normal", [])
                    }
                }
            }

            TacticalButton {
                Layout.fillWidth: true
                text: "OPEN HISTORY"
                iconName: "chevron-right"
                implicitHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: root.openNotificationsRequested()
            }
        }
    }

    // =========================================================================
    // 7. LOCK SCREEN & SESSION POWER
    // =========================================================================
    ColumnLayout {
        id: secSession
        visible: root.activeSection === "session"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        TacticalToggle {
            Layout.fillWidth: true
            label: "Show Host & Runner Specimen on Lock Screen"
            sublabel: "Displays user@host and Runner Calling Card while locked"
            iconName: "lock"
            checked: root.s ? root.s.lockShowHostSpecimen : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("lockShowHostSpecimen", next) }
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Require Confirmation for Power Actions"
            sublabel: "Guards Logout, Reboot, and Shutdown behind ConfirmDialog"
            iconName: "warning"
            checked: root.s ? root.s.confirmPowerActions : true
            reducedMotion: root.reducedMotion
            onToggled: function(next) { if (root.s) root.s.setSetting("confirmPowerActions", next) }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Auto-Lock Idle Timeout"
            sublabel: (root.s && root.s.idleLockMinutes > 0) ? (root.s.idleLockMinutes + " MIN") : "DISABLED"
            selectedId: String(root.s ? root.s.idleLockMinutes : 10)
            options: [
                { id: "0", label: "NEVER" },
                { id: "5", label: "5 MIN" },
                { id: "10", label: "10 MIN" },
                { id: "15", label: "15 MIN" },
                { id: "30", label: "30 MIN" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("idleLockMinutes", parseInt(id, 10)) }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Display DPMS Sleep Timeout"
            sublabel: (root.s && root.s.idleDpmsMinutes > 0) ? (root.s.idleDpmsMinutes + " MIN") : "DISABLED"
            selectedId: String(root.s ? root.s.idleDpmsMinutes : 15)
            options: [
                { id: "0", label: "NEVER" },
                { id: "5", label: "5 MIN" },
                { id: "10", label: "10 MIN" },
                { id: "15", label: "15 MIN" },
                { id: "30", label: "30 MIN" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.s) root.s.setSetting("idleDpmsMinutes", parseInt(id, 10)) }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spaceXs

            TacticalButton {
                Layout.fillWidth: true
                text: "LOCK NOW"
                iconName: "lock"
                variant: "primary"
                implicitHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: {
                    if (root.backend && root.backend.session) root.backend.session.lock()
                }
            }

            TacticalButton {
                Layout.fillWidth: true
                text: "SESSION MENU"
                iconName: "power"
                variant: "danger"
                implicitHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: root.openSessionRequested()
            }
        }
    }
}
