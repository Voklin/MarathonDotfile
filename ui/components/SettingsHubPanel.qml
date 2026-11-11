pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var backend
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()
    signal openNotificationsRequested()
    signal openSessionRequested()

    readonly property var s: backend ? backend.settings : null
    readonly property string activeSection: s ? s.activeSection : "profile"
    readonly property string searchQuery: s ? s.searchQuery : ""

    readonly property var sections: [
        { id: "profile", group: "PINNED", label: "Profile", code: "PROFILE // SPECIMEN", icon: "grid", resettable: false, keywords: "runner emblem name title host cpu gpu ram kernel uptime specimen" },
        { id: "appearance", group: "SHELL & UI", label: "Appearance", code: "THEME // TOKENS", icon: "settings", resettable: true, keywords: "faction accent hex custom color palette surface void slate corner radius border motion" },
        { id: "hud", group: "SHELL & UI", label: "Top HUD Bar", code: "HUD // BAR", icon: "grid", resettable: true, keywords: "bar top bottom edge height monitors fullscreen workspaces audio network battery clock seconds date" },
        { id: "wallpaper", group: "SHELL & UI", label: "Wallpaper", code: "BACKDROP // MATRIX", icon: "grid", resettable: true, keywords: "wallpaper matrix crosshair opacity dim sync grid 4k" },
        { id: "launcher", group: "SHELL & UI", label: "Launcher", code: "APP LAUNCHER", icon: "search", resettable: true, keywords: "launcher list grid recent mru commands tab close" },
        { id: "notifications", group: "SHELL & UI", label: "Notifications & OSD", code: "ALERTS // OSD", icon: "bell", resettable: true, keywords: "dnd do not disturb toast popup timeout osd volume brightness duration" },
        { id: "session", group: "SHELL & UI", label: "Lock & Session", code: "LOCK // POWER", icon: "lock", resettable: true, keywords: "lock screen specimen confirm power idle timeout dpms sleep" },
        { id: "compositor", group: "HYPRLAND", label: "Layout & Gaps", code: "HYPR // COMPOSITOR", icon: "settings", resettable: true, keywords: "dwindle master gaps inner outer border rounding opacity blur shadow vfr tearing animations speed" },
        { id: "displays", group: "HYPRLAND", label: "Displays", code: "DISPLAYS // MONITORS", icon: "grid", resettable: true, keywords: "monitor display resolution refresh scale hidpi rotation transform position xwayland" },
        { id: "input", group: "HYPRLAND", label: "Input & Mouse", code: "INPUT // PERIPHERALS", icon: "terminal", resettable: true, keywords: "keyboard layout repeat rate delay mouse pointer sensitivity acceleration flat touchpad tap natural scroll" },
        { id: "keybinds", group: "HYPRLAND", label: "Keybinds & Apps", code: "BINDS // SHORTCUTS", icon: "terminal", resettable: true, keywords: "keybinds shortcuts terminal file manager browser super bind custom" },
        { id: "rules", group: "HYPRLAND", label: "Window Rules", code: "RULES // MATCH", icon: "grid", resettable: true, keywords: "windowrule match class title float center pin layerrule" },
        { id: "autostart", group: "HYPRLAND", label: "Autostart & GPU", code: "EXEC // ENV // GPU", icon: "terminal", resettable: true, keywords: "autostart exec-once environment env gpu discrete integrated render" },
        { id: "audio", group: "HARDWARE", label: "Audio & Power", code: "PIPEWIRE // POWER", icon: "audio", resettable: false, keywords: "audio volume mute sink routing microphone backlight brightness battery power profile" },
        { id: "connections", group: "HARDWARE", label: "Connections", code: "WI-FI // BLUETOOTH", icon: "wifi", resettable: false, keywords: "wifi network ssid connect disconnect bluetooth devices battery" },
        { id: "config", group: "MAINTENANCE", label: "Config & Overrides", code: "PERSISTENCE // CONF", icon: "settings", resettable: false, keywords: "config json user-settings.conf export reload reset defaults" },
        { id: "about", group: "MAINTENANCE", label: "Diagnostics & About", code: "HEALTH // INFO", icon: "warning", resettable: false, keywords: "diagnostics health adapters version license credits" }
    ]

    readonly property var settingsIndex: [
        { sectionId: "profile", title: "Runner Emblem & Calling Card", keywords: "runner emblem name title card" },
        { sectionId: "profile", title: "Workstation Hardware Specimen", keywords: "cpu gpu ram kernel hostname distro" },
        { sectionId: "appearance", title: "Corporate Faction Accent Matrix", keywords: "faction runner cyberacme traxus sekiguchi lime cyan orange" },
        { sectionId: "appearance", title: "Custom Accent Hex & Swatches", keywords: "custom hex color swatch accent" },
        { sectionId: "appearance", title: "Surface Contrast Profile", keywords: "surface void slate theme dark" },
        { sectionId: "appearance", title: "Corner Radius & Border Thickness", keywords: "corner radius rounding border thickness" },
        { sectionId: "appearance", title: "Reduced Motion & Speed Multiplier", keywords: "reduced motion speed animation" },
        { sectionId: "hud", title: "HUD Edge Position (Top / Bottom)", keywords: "hud position top bottom edge bar" },
        { sectionId: "hud", title: "HUD Height & Multi-Monitor Policy", keywords: "hud height multi monitor fullscreen autohide" },
        { sectionId: "hud", title: "HUD Telemetry Module Toggles", keywords: "badge workspace window network audio battery clock seconds date" },
        { sectionId: "wallpaper", title: "Wallpaper Preset & Crosshair Matrix", keywords: "wallpaper backdrop matrix opacity dim" },
        { sectionId: "launcher", title: "Launcher Layout (List / Vault Grid)", keywords: "launcher list grid recent mru commands" },
        { sectionId: "notifications", title: "Do Not Disturb & Toast Anchor", keywords: "dnd toast position timeout osd duration" },
        { sectionId: "session", title: "Lock Screen Specimen & Idle Timeouts", keywords: "lock idle dpms confirm power" },
        { sectionId: "compositor", title: "Tiling Layout (Dwindle / Master)", keywords: "dwindle master tiling layout" },
        { sectionId: "compositor", title: "Window Gaps, Border & Rounding", keywords: "gaps_in gaps_out border_size rounding opacity" },
        { sectionId: "compositor", title: "Blur, Shadows, VFR & Tearing", keywords: "blur shadow vfr tearing resize" },
        { sectionId: "compositor", title: "Hyprland Animation Curve & Speed", keywords: "animations speed curve tactical snappy" },
        { sectionId: "displays", title: "Monitor Resolution, Scale & Rotation", keywords: "display monitor resolution refresh scale transform position xwayland" },
        { sectionId: "input", title: "Keyboard Layouts & Repeat Rate", keywords: "keyboard layout ru us de repeat rate delay" },
        { sectionId: "input", title: "Pointer Sensitivity, Accel & Touchpad", keywords: "mouse pointer sensitivity flat adaptive touchpad tap natural scroll" },
        { sectionId: "keybinds", title: "Default Apps ($terminal, $fileManager, $browser)", keywords: "terminal file manager browser ghostty dolphin firefox" },
        { sectionId: "keybinds", title: "Custom Keybind Builder & Super_L Opt-In", keywords: "keybind custom shortcut super bare" },
        { sectionId: "rules", title: "Window Rules Builder (match: syntax)", keywords: "windowrule match class title float center pin" },
        { sectionId: "autostart", title: "Autostart (exec-once), Env & GPU Policy", keywords: "autostart exec-once env gpu render" },
        { sectionId: "audio", title: "PipeWire Volume, Sink Routing & Backlight", keywords: "audio volume mute sink mic brightness backlight power profile" },
        { sectionId: "connections", title: "Wi-Fi Networks & Bluetooth Devices", keywords: "wifi network ssid bluetooth device pair" },
        { sectionId: "config", title: "Live user-settings.conf & JSON Export", keywords: "config export json reload reset" },
        { sectionId: "about", title: "Subsystem Adapter Health Matrix", keywords: "health diagnostics adapters version" }
    ]

    readonly property var activeMeta: {
        for (var i = 0; i < sections.length; ++i) {
            if (sections[i].id === activeSection) return sections[i]
        }
        return sections[0]
    }

    readonly property var searchMatches: {
        var q = (searchQuery || "").trim().toLowerCase()
        if (q === "") return []
        var out = []
        for (var i = 0; i < settingsIndex.length; ++i) {
            var item = settingsIndex[i]
            if (item.title.toLowerCase().indexOf(q) !== -1 || item.keywords.toLowerCase().indexOf(q) !== -1) {
                out.push(item)
            }
        }
        return out
    }

    function matchCountForSection(sec) {
        var q = (searchQuery || "").trim().toLowerCase()
        if (q === "") return 0
        var c = 0
        for (var i = 0; i < settingsIndex.length; ++i) {
            if (settingsIndex[i].sectionId === sec.id) {
                var item = settingsIndex[i]
                if (item.title.toLowerCase().indexOf(q) !== -1 || item.keywords.toLowerCase().indexOf(q) !== -1) {
                    ++c
                }
            }
        }
        if (c === 0 && (sec.label.toLowerCase().indexOf(q) !== -1 || sec.keywords.toLowerCase().indexOf(q) !== -1)) {
            c = 1
        }
        return c
    }

    function sectionVisibleInNav(sec) {
        var q = (searchQuery || "").trim().toLowerCase()
        if (q === "") return true
        return matchCountForSection(sec) > 0
    }

    function selectSection(id) {
        if (s) s.setSection(id)
        rightScroll.contentY = 0
    }

    visible: open || hubReveal.opacity > 0.01

    onOpenChanged: {
        if (open) {
            hubCard.forceActiveFocus()
        }
    }

    Keys.onPressed: function(event) {
        if (!root.open) return
        if (event.key === Qt.Key_Escape) {
            if (root.searchQuery !== "" && root.s) {
                root.s.setSearchQuery("")
                searchInput.text = ""
            } else {
                root.closeRequested()
            }
            event.accepted = true
        } else if ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_F || event.key === Qt.Key_K)) {
            searchInput.focusInput()
            event.accepted = true
        }
    }

    // Scrim backdrop
    Rectangle {
        anchors.fill: parent
        color: Tokens.surfaceOverlay
        opacity: root.open ? 0.72 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Tokens.motionMs(Tokens.durationPanel, root.reducedMotion) }
        }
        MouseArea {
            anchors.fill: parent
            enabled: root.open
            onClicked: root.closeRequested()
        }
    }

    PanelReveal {
        id: hubReveal
        anchors.centerIn: parent
        width: Math.min(Tokens.settingsHubWidth, parent.width - Tokens.spaceLg)
        height: Math.min(Tokens.settingsHubHeight, parent.height - Tokens.spaceLg)
        shown: root.open
        reducedMotion: root.reducedMotion
        slideOffsetY: -Tokens.spaceMd

        MouseArea {
            anchors.fill: hubCard
        }

        TacticalPanel {
            id: hubCard
            anchors.fill: parent
            focus: true
            code: "MARATHON HUB // SETTINGS CONTROL PLANE (SUPER + ,)"
            title: root.activeMeta.label.toUpperCase()
            statusText: (root.s && root.s.dirty) ? "MODIFIED // UNSAVED" : "SYNCHRONIZED"
            statusTone: (root.s && root.s.dirty) ? "warning" : "signal"

            // Main Split Pane (Left Nav Rail + Right Config Canvas)
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Tokens.spaceMd

                // LEFT NAVIGATION RAIL
                ColumnLayout {
                    readonly property int railWidth: hubReveal.width < 820 ? 196 : 224
                    Layout.preferredWidth: railWidth
                    Layout.minimumWidth: railWidth
                    Layout.maximumWidth: railWidth
                    Layout.fillHeight: true
                    spacing: Tokens.spaceXs

                    TacticalTextField {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.preferredWidth: 180
                        promptPrefix: "/"
                        placeholderText: "SEARCH SETTINGS..."
                        text: root.searchQuery
                        onTextChanged: if (root.s) root.s.setSearchQuery(searchInput.text)
                        onEscapePressed: {
                            if (searchInput.text !== "") {
                                searchInput.text = ""
                                if (root.s) root.s.setSearchQuery("")
                            } else {
                                root.closeRequested()
                            }
                        }
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: navCol.implicitHeight
                        clip: true

                        ColumnLayout {
                            id: navCol
                            width: parent.width
                            spacing: 1

                            Repeater {
                                model: root.sections
                                delegate: ColumnLayout {
                                    id: navDel
                                    required property var modelData
                                    required property int index
                                    readonly property bool shownInSearch: root.sectionVisibleInNav(navDel.modelData)
                                    readonly property bool isCurrent: root.activeSection === navDel.modelData.id
                                    readonly property int matchesCount: root.matchCountForSection(navDel.modelData)
                                    readonly property bool showGroupHeader: {
                                        if (!navDel.shownInSearch) return false
                                        if (navDel.index === 0) return true
                                        return root.sections[navDel.index - 1].group !== navDel.modelData.group || root.searchQuery !== ""
                                    }

                                    visible: navDel.shownInSearch
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        visible: navDel.showGroupHeader && (navDel.index === 0 || root.sections[navDel.index - 1].group !== navDel.modelData.group)
                                        Layout.fillWidth: true
                                        Layout.topMargin: navDel.index === 0 ? 0 : Tokens.space2xs
                                        text: navDel.modelData.group
                                        color: Tokens.muted
                                        font.family: Tokens.fontMono
                                        font.pixelSize: Tokens.fontMicro
                                        font.bold: true
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 22
                                        radius: Tokens.cornerRadius
                                        color: navDel.isCurrent ? Tokens.surfaceElevated : (navMouse.containsMouse ? Tokens.surfacePressed : "transparent")
                                        border.width: Tokens.borderWidth
                                        border.color: navDel.isCurrent ? Tokens.signal : "transparent"

                                        Rectangle {
                                            visible: navDel.isCurrent
                                            anchors.left: parent.left
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            width: 3
                                            color: Tokens.signal
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: Tokens.spaceSm
                                            anchors.rightMargin: Tokens.spaceXs
                                            spacing: Tokens.spaceXs

                                            TacticalIcon {
                                                iconName: navDel.modelData.icon
                                                iconSize: 13
                                                color: navDel.isCurrent ? Tokens.signal : Tokens.muted
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: navDel.modelData.label
                                                color: navDel.isCurrent ? Tokens.signal : Tokens.text
                                                font.family: Tokens.fontUi
                                                font.pixelSize: Tokens.fontBody
                                                font.bold: navDel.isCurrent
                                                elide: Text.ElideRight
                                            }

                                            StatusPill {
                                                visible: navDel.matchesCount > 0
                                                text: String(navDel.matchesCount)
                                                tone: "signal"
                                            }
                                        }

                                        MouseArea {
                                            id: navMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.selectSection(navDel.modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                HudDivider {
                    orientation: Qt.Vertical
                    Layout.preferredWidth: Tokens.borderWidth
                    Layout.fillHeight: true
                }

                // RIGHT CONFIGURATION VIEWPORT
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 720
                    Layout.fillHeight: true
                    spacing: Tokens.spaceSm

                    // Active Section Header Strip
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spaceSm

                        StatusPill {
                            text: root.activeMeta.code
                            tone: "signal"
                            showDot: true
                        }

                        Item { Layout.fillWidth: true }

                        TacticalButton {
                            visible: root.activeMeta.resettable
                            text: "RESET SECTION"
                            variant: "ghost"
                            implicitHeight: Tokens.controlHeightSm
                            reducedMotion: root.reducedMotion
                            onClicked: if (root.s) root.s.resetSection(root.activeSection)
                        }
                    }

                    // Cross-Section Search Matches Quick Jump Box
                    Rectangle {
                        visible: root.searchQuery.trim() !== ""
                        Layout.fillWidth: true
                        implicitHeight: searchResCol.implicitHeight + Tokens.spaceSm * 2
                        radius: Tokens.cornerRadius
                        color: Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: root.searchMatches.length > 0 ? Tokens.signal : Tokens.alert

                        ColumnLayout {
                            id: searchResCol
                            anchors.fill: parent
                            anchors.margins: Tokens.spaceSm
                            spacing: Tokens.spaceXs

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: root.searchMatches.length > 0
                                        ? ("CROSS-HUB MATCHES (" + root.searchMatches.length + ")")
                                        : ("NO SETTINGS MATCHED '" + root.searchQuery + "'")
                                    color: root.searchMatches.length > 0 ? Tokens.signal : Tokens.alert
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: true
                                }
                                TacticalButton {
                                    text: "CLEAR"
                                    variant: "ghost"
                                    implicitHeight: 20
                                    reducedMotion: root.reducedMotion
                                    onClicked: {
                                        searchInput.text = ""
                                        if (root.s) root.s.setSearchQuery("")
                                    }
                                }
                            }

                            Flow {
                                visible: root.searchMatches.length > 0
                                Layout.fillWidth: true
                                spacing: Tokens.spaceXs

                                Repeater {
                                    model: root.searchMatches.slice(0, 8)
                                    delegate: TacticalButton {
                                        id: jumpDel
                                        required property var modelData
                                        text: jumpDel.modelData.sectionId.toUpperCase() + ": " + jumpDel.modelData.title
                                        active: root.activeSection === jumpDel.modelData.sectionId
                                        variant: active ? "primary" : "default"
                                        implicitHeight: 22
                                        reducedMotion: root.reducedMotion
                                        onClicked: root.selectSection(jumpDel.modelData.sectionId)
                                    }
                                }
                            }
                        }
                    }

                    // Scrollable Section Body
                    Flickable {
                        id: rightScroll
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: sectionsStack.height + Tokens.spaceSm
                        clip: true

                        Item {
                            id: sectionsStack
                            width: rightScroll.width
                            height: Math.max(shellSecs.contentHeight, Math.max(hyprSecs.contentHeight, sysSecs.contentHeight))

                            SettingsShellSections {
                                id: shellSecs
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                visible: contentHeight > 0
                                backend: root.backend
                                activeSection: root.activeSection
                                searchQuery: root.searchQuery
                                reducedMotion: root.reducedMotion
                                onOpenSessionRequested: root.openSessionRequested()
                                onOpenNotificationsRequested: root.openNotificationsRequested()
                            }

                            SettingsHyprSections {
                                id: hyprSecs
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                visible: contentHeight > 0
                                backend: root.backend
                                activeSection: root.activeSection
                                searchQuery: root.searchQuery
                                reducedMotion: root.reducedMotion
                            }

                            SettingsSystemSections {
                                id: sysSecs
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                visible: contentHeight > 0
                                backend: root.backend
                                activeSection: root.activeSection
                                searchQuery: root.searchQuery
                                reducedMotion: root.reducedMotion
                            }
                        }
                    }
                }
            }

            // Bottom Persistence & Control Bar
            HudDivider { Layout.fillWidth: true; withTicks: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceSm

                Text {
                    Layout.fillWidth: true
                    text: (root.s && root.s.statusNote !== "") ? root.s.statusNote : "ISOLATED CONFIG // ~/.config/marathon-tactical/"
                    color: (root.s && root.s.errorMessage !== "") ? Tokens.alert : Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    elide: Text.ElideRight
                }

                TacticalButton {
                    text: "APPLY & WRITE"
                    iconName: "check"
                    variant: "primary"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: if (root.s) root.s.applyAll()
                }

                TacticalButton {
                    text: "CLOSE [ESC]"
                    iconName: "close"
                    variant: "ghost"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.closeRequested()
                }
            }
        }
    }
}
