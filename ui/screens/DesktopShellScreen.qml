pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../components"

Rectangle {
    id: root

    required property var backend
    property string monitorName: ""
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

    readonly property var settingsObj: backend && backend.settings ? backend.settings : null
    readonly property string hudPos: settingsObj ? settingsObj.hudPosition : "top"
    readonly property bool hudAllMonitors: settingsObj ? settingsObj.hudMultiMonitorAll : true
    readonly property string wallId: settingsObj ? settingsObj.wallpaperId : "matrix"
    readonly property bool matrixEnabled: settingsObj ? settingsObj.backdropMatrixEnabled : true
    readonly property real matrixOpacity: settingsObj ? settingsObj.backdropMatrixOpacity : 0.42
    readonly property real dimOpacity: settingsObj ? settingsObj.backdropDim : 0.0
    readonly property string toastAnchor: settingsObj ? settingsObj.toastPosition : "top-right"

    function openPanel(panelName) {
        if (panelName === "lock") {
            closeAllPanels()
            backend.session.lock()
            return
        }
        if (panelName === "launcher-grid") {
            closeAllPanels()
            launcherOverlay.layoutMode = "grid"
            launcherOpen = true
            return
        }
        if (panelName === "launcher") {
            launcherOverlay.layoutMode = "list"
        }
        launcherOpen = (panelName === "launcher")
        controlCenterOpen = (panelName === "control")
        notificationsOpen = (panelName === "notifications")
        sessionOpen = (panelName === "session")
        settingsOpen = (panelName === "settings")
        clipboardOpen = (panelName === "clipboard")
        captureOpen = (panelName === "capture")
        sysmonOpen = (panelName === "sysmon")
        calendarOpen = (panelName === "calendar")
        cheatsheetOpen = (panelName === "cheatsheet")
    }

    function openSettingsSection(sectionId) {
        if (settingsObj && sectionId) {
            settingsObj.setSection(sectionId)
        }
        openPanel("settings")
    }

    function closeAllPanels() {
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

    function handleSafeCommand(cmdId) {
        if (cmdId === "toggle-dnd") backend.notifications.toggleDnd()
        else if (cmdId === "toggle-motion") backend.appearance.toggleReducedMotion()
        else if (cmdId === "toggle-nightlight" && backend.utilities) backend.utilities.toggleNightLight()
        else if (cmdId === "toggle-gamemode" && backend.utilities) backend.utilities.toggleGameMode()
        else if (cmdId === "open-control") openPanel("control")
        else if (cmdId === "open-settings") openPanel("settings")
        else if (cmdId === "open-clipboard") openPanel("clipboard")
        else if (cmdId === "open-capture") openPanel("capture")
        else if (cmdId === "open-sysmon") openPanel("sysmon")
        else if (cmdId === "open-calendar") openPanel("calendar")
        else if (cmdId === "open-cheatsheet") openPanel("cheatsheet")
        else if (cmdId === "lock-session") {
            closeAllPanels()
            backend.session.lock()
        }
    }

    color: Tokens.background

    Image {
        id: wallpaperImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: {
            if (root.wallId === "grid-4k") return "../../design/wallpapers/marathon-grid-3840x2160.png"
            if (root.wallId === "grid-1080") return "../../design/wallpapers/marathon-grid-1920x1080.png"
            if (root.wallId === "lock-4k") return "../../design/wallpapers/marathon-lock-3840x2160.png"
            return ""
        }
        visible: root.wallId !== "matrix" && root.wallId !== "solid" && source !== ""
    }

    // Marathon Empty-Slot Crosshair Matrix (+) & Bungie Decal Rulers (non-animated, zero CPU idle cost)
    Canvas {
        id: gridBackdrop
        anchors.fill: parent
        visible: root.matrixEnabled && root.wallId !== "solid"
        opacity: root.matrixOpacity
        Connections {
            target: Tokens
            function onFactionIdChanged() { gridBackdrop.requestPaint() }
            function onSurfaceThemeChanged() { gridBackdrop.requestPaint() }
            function onCustomAccentHexChanged() { gridBackdrop.requestPaint() }
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            // Discrete + crosshair matrix (like Marathon BACKPACK empty slot grid)
            var step = 72
            ctx.strokeStyle = Tokens.borderSubtle.toString()
            ctx.lineWidth = 1
            ctx.beginPath()
            for (var cx = step; cx < width - 32; cx += step) {
                for (var cy = step; cy < height - 32; cy += step) {
                    var arm = ((cx / step) % 2 === 0 && (cy / step) % 2 === 0) ? 6 : 3
                    ctx.moveTo(cx - arm, cy + 0.5)
                    ctx.lineTo(cx + arm + 1, cy + 0.5)
                    ctx.moveTo(cx + 0.5, cy - arm)
                    ctx.lineTo(cx + 0.5, cy + arm + 1)
                }
            }
            ctx.stroke()

            // Major sector crosshairs (+) & Grey Decal Sheet cruciform ruler tracks
            ctx.strokeStyle = Tokens.borderStrong.toString()
            ctx.beginPath()
            var major = step * 3
            for (var mx = major; mx < width - 64; mx += major) {
                for (var my = major; my < height - 64; my += major) {
                    ctx.moveTo(mx - 8, my + 0.5)
                    ctx.lineTo(mx + 9, my + 0.5)
                    ctx.moveTo(mx + 0.5, my - 8)
                    ctx.lineTo(mx + 0.5, my + 9)
                }
            }
            ctx.stroke()
        }
    }

    Rectangle {
        id: backdropDimLayer
        anchors.fill: parent
        color: Tokens.voidBg
        opacity: root.dimOpacity
        visible: opacity > 0.001
    }

    Item {
        id: hudFrame
        anchors.fill: parent
        anchors.margins: Tokens.hudInset

        TopHudBar {
            id: primaryHud
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: root.hudPos === "top" ? parent.top : undefined
            anchors.bottom: root.hudPos === "bottom" ? parent.bottom : undefined
            height: primaryHud.shown ? Tokens.hudHeight : 0
            backend: root.backend
            monitorName: root.monitorName !== "" ? root.monitorName : (root.backend.workspaces.monitors.length > 1 ? root.backend.workspaces.monitors[0].name : "")
            launcherOpen: root.launcherOpen
            controlCenterOpen: root.controlCenterOpen
            notificationsOpen: root.notificationsOpen
            sessionOpen: root.sessionOpen
            settingsOpen: root.settingsOpen
            calendarOpen: root.calendarOpen
            onLauncherRequested: {
                var wasOpen = root.launcherOpen
                root.closeAllPanels()
                root.launcherOpen = !wasOpen
            }
            onControlCenterRequested: {
                var wasOpen = root.controlCenterOpen
                root.closeAllPanels()
                root.controlCenterOpen = !wasOpen
            }
            onNotificationsRequested: {
                var wasOpen = root.notificationsOpen
                root.closeAllPanels()
                root.notificationsOpen = !wasOpen
            }
            onSessionMenuRequested: {
                var wasOpen = root.sessionOpen
                root.closeAllPanels()
                root.sessionOpen = !wasOpen
            }
            onSettingsRequested: {
                var wasOpen = root.settingsOpen
                root.closeAllPanels()
                root.settingsOpen = !wasOpen
            }
            onCalendarRequested: {
                var wasOpen = root.calendarOpen
                root.closeAllPanels()
                root.calendarOpen = !wasOpen
            }
        }

        // Secondary monitor HUD bar preview when S10 multi-monitor topology is active
        Column {
            id: secHudCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: root.hudPos === "top" ? primaryHud.bottom : undefined
            anchors.bottom: root.hudPos === "bottom" ? primaryHud.top : undefined
            anchors.topMargin: root.hudPos === "top" && visible ? Tokens.spaceSm : 0
            anchors.bottomMargin: root.hudPos === "bottom" && visible ? Tokens.spaceSm : 0
            spacing: Tokens.spaceSm
            visible: root.monitorName === "" && root.hudAllMonitors && root.backend.workspaces.monitors.length > 1

            Repeater {
                model: (root.monitorName === "" && root.hudAllMonitors && root.backend.workspaces.monitors.length > 1)
                    ? root.backend.workspaces.monitors.slice(1)
                    : []
                delegate: TopHudBar {
                    id: secHud
                    required property var modelData
                    width: secHudCol.width
                    height: Tokens.hudHeight
                    backend: root.backend
                    monitorName: secHud.modelData.name
                    forceVisible: true
                }
            }
        }

        // Simulated active application tile area
        Item {
            id: desktopArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: root.hudPos === "top"
                ? (secHudCol.visible ? secHudCol.bottom : primaryHud.bottom)
                : parent.top
            anchors.bottom: root.hudPos === "bottom"
                ? (secHudCol.visible ? secHudCol.top : primaryHud.top)
                : parent.bottom
            anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? Tokens.spaceSm : 0
            anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? Tokens.spaceSm : 0

            // Top-left & bottom-right Runner visor sector watermarks
            RowLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceSm

                Rectangle {
                    width: 6
                    height: 6
                    color: Tokens.signalMuted
                }

                Text {
                    text: "SECTOR // 04-TAU.IV // RUNNER_DECK.OS"
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    opacity: 0.75
                }
            }

            RowLayout {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceMd

                Text {
                    text: "SYS.ARCH // CACHYOS.HYPRLAND // WAYLAND.COMPOSITOR"
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    opacity: 0.7
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "TELEMETRY // NOMINAL [0.4ms]"
                    color: Tokens.signalMuted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    opacity: 0.85
                }
            }

            TacticalPanel {
                anchors.centerIn: parent
                width: Math.min(740, parent.width - Tokens.spaceXl)
                code: root.backend.activeWindow.fullscreen ? "HYPRLAND // FULLSCREEN CLIENT" : "HYPRLAND // TILED SURFACE"
                title: root.backend.activeWindow.available ? root.backend.activeWindow.title : "EMPTY WORKSPACE"
                statusText: root.backend.activeWindow.fullscreen ? "FULLSCREEN" : (root.backend.activeWindow.floating ? "FLOATING" : "TILED")
                statusTone: root.backend.activeWindow.fullscreen ? "warning" : "signal"

                // Marathon EXFILTRATED-style Alternating Zebra Telemetry Rows
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Repeater {
                        model: [
                            { label: "Active Workspace Sector", value: "WS // 0" + root.backend.workspaces.activeWorkspaceId, highlight: true },
                            { label: "Client App Identifier", value: (root.backend.activeWindow.appId || "NONE").toUpperCase(), highlight: false },
                            { label: "Network Telemetry Uplink", value: root.backend.network.connected ? (root.backend.network.ssid + " (" + root.backend.network.signalStrength + "%)") : "OFFLINE", highlight: root.backend.network.connected }
                        ]
                        delegate: Rectangle {
                            id: zebraRow
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            height: 24
                            color: (zebraRow.index % 2 === 0) ? Tokens.surfaceZebra : Tokens.surfacePressed

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Tokens.spaceSm
                                anchors.rightMargin: Tokens.spaceSm
                                spacing: Tokens.spaceSm

                                Rectangle {
                                    visible: zebraRow.modelData.highlight
                                    width: 5
                                    height: 5
                                    color: Tokens.signal
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: zebraRow.modelData.label
                                    color: zebraRow.modelData.highlight ? Tokens.signal : Tokens.text
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: zebraRow.modelData.highlight
                                }

                                Text {
                                    text: zebraRow.modelData.value
                                    color: zebraRow.modelData.highlight ? Tokens.signal : Tokens.text
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceSm

                    StatusPill {
                        text: "WS " + root.backend.workspaces.activeWorkspaceId
                        tone: "signal"
                        showDot: true
                    }

                    StatusPill {
                        text: "MONITORS: " + root.backend.workspaces.monitors.length
                        tone: "neutral"
                    }

                    StatusPill {
                        text: root.backend.network.connected ? ("NET: " + root.backend.network.ssid) : "NET: OFFLINE"
                        tone: root.backend.network.connected ? "neutral" : "alert"
                    }

                    Item { Layout.fillWidth: true }

                    TacticalButton {
                        text: root.backend.activeWindow.fullscreen ? "EXIT FS" : "FULLSCREEN"
                        variant: root.backend.activeWindow.fullscreen ? "primary" : "default"
                        implicitHeight: Tokens.controlHeightSm
                        reducedMotion: root.backend.appearance.reducedMotion
                        onClicked: root.backend.activeWindow.toggleFullscreen()
                    }
                }
            }
        }
    }

    LauncherPanel {
        id: launcherOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        launcher: root.backend.launcher
        settings: root.settingsObj
        utilities: root.backend ? root.backend.utilities : null
        open: root.launcherOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.launcherOpen = false
        onSafeCommandTriggered: function(cmdId) { root.handleSafeCommand(cmdId) }
    }

    ControlCenterPanel {
        id: controlOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        backend: root.backend
        open: root.controlCenterOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.controlCenterOpen = false
        onOpenNotificationsRequested: root.openPanel("notifications")
        onOpenSessionRequested: root.openPanel("session")
        onOpenSettingsRequested: root.openPanel("settings")
        onOpenClipboardRequested: root.openPanel("clipboard")
        onOpenCaptureRequested: root.openPanel("capture")
        onOpenSysmonRequested: root.openPanel("sysmon")
        onOpenCalendarRequested: root.openPanel("calendar")
        onOpenCheatsheetRequested: root.openPanel("cheatsheet")
    }

    NotificationCenterPanel {
        id: notificationsOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        notifications: root.backend.notifications
        open: root.notificationsOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.notificationsOpen = false
    }

    NotificationToastStack {
        anchors.top: root.toastAnchor !== "bottom-right" ? parent.top : undefined
        anchors.bottom: root.toastAnchor === "bottom-right" ? parent.bottom : undefined
        anchors.right: root.toastAnchor !== "top-center" ? parent.right : undefined
        anchors.horizontalCenter: root.toastAnchor === "top-center" ? parent.horizontalCenter : undefined
        anchors.topMargin: ((root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0) + Tokens.spaceSm
        anchors.bottomMargin: ((root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0) + Tokens.spaceSm
        anchors.rightMargin: Tokens.spaceSm
        notifications: root.backend.notifications
        settings: root.settingsObj
        suppressed: root.notificationsOpen || root.controlCenterOpen || root.settingsOpen || root.backend.session.locked
        reducedMotion: root.backend.appearance.reducedMotion
    }

    SessionMenuPanel {
        id: sessionOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        session: root.backend.session
        settings: root.settingsObj
        open: root.sessionOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.sessionOpen = false
    }

    SettingsHubPanel {
        id: settingsOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        backend: root.backend
        open: root.settingsOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.settingsOpen = false
        onOpenNotificationsRequested: root.openPanel("notifications")
        onOpenSessionRequested: root.openPanel("session")
    }

    ClipboardPanel {
        id: clipboardOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        utilities: root.backend.utilities
        open: root.clipboardOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.clipboardOpen = false
    }

    CapturePanel {
        id: captureOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        utilities: root.backend.utilities
        open: root.captureOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.captureOpen = false
        onOpenClipboardRequested: root.openPanel("clipboard")
    }

    SystemMonitorPanel {
        id: sysmonOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        utilities: root.backend.utilities
        audio: root.backend.audio
        open: root.sysmonOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.sysmonOpen = false
    }

    CalendarNotesPanel {
        id: calendarOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        utilities: root.backend.utilities
        appearance: root.backend.appearance
        open: root.calendarOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.calendarOpen = false
    }

    CheatsheetPanel {
        id: cheatsheetOverlay
        anchors.fill: parent
        anchors.topMargin: (root.hudPos === "top" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        anchors.bottomMargin: (root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0
        settings: root.settingsObj
        utilities: root.backend.utilities
        open: root.cheatsheetOpen
        reducedMotion: root.backend.appearance.reducedMotion
        onCloseRequested: root.cheatsheetOpen = false
        onTriggerActionRequested: function(actId) { root.handleSafeCommand(actId) }
    }

    OsdOverlay {
        id: osdOverlay
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Tokens.spaceXl + ((root.hudPos === "bottom" && primaryHud.shown) ? (Tokens.hudHeight + Tokens.hudInset) : 0)
        audio: root.backend.audio
        brightness: root.backend.brightness
        settings: root.settingsObj
        reducedMotion: root.backend.appearance.reducedMotion
    }

    LockScreenOverlay {
        id: lockOverlay
        anchors.fill: parent
        session: root.backend.session
        appearance: root.backend.appearance
        settings: root.settingsObj
        reducedMotion: root.backend.appearance.reducedMotion
    }
}
