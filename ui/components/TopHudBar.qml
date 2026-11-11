pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

PanelReveal {
    id: root

    required property var backend
    property string monitorName: ""
    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool notificationsOpen: false
    property bool sessionOpen: false
    property bool settingsOpen: false
    property bool calendarOpen: false
    property bool forceVisible: false

    readonly property var s: backend && backend.settings ? backend.settings : null

    signal launcherRequested()
    signal controlCenterRequested()
    signal notificationsRequested()
    signal sessionMenuRequested()
    signal settingsRequested()
    signal calendarRequested()
    signal trayMenuRequested(string itemId, real x, real y)

    readonly property bool isCompact: width < Tokens.hudCompactBreakpoint
    readonly property bool fullscreenHidden: !forceVisible && backend && backend.activeWindow && backend.activeWindow.fullscreen && backend.appearance && backend.appearance.hudAutoHideOnFullscreen

    shown: !fullscreenHidden
    reducedMotion: backend && backend.appearance ? backend.appearance.reducedMotion : false
    implicitHeight: shown ? Tokens.hudHeight : 0
    clip: true

    Rectangle {
        anchors.fill: parent
        color: Tokens.surface
        border.width: Tokens.borderWidth
        border.color: Tokens.border

        // Bottom tactical accent hairline
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Tokens.borderWidth
            color: Tokens.borderStrong
        }

        // Left & right top corner registration ticks
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: Tokens.spaceSm
            height: 2
            color: Tokens.signal
        }
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: Tokens.spaceSm
            height: 2
            color: Tokens.signal
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Tokens.spaceSm
            anchors.rightMargin: Tokens.spaceSm
            spacing: Tokens.spaceSm

            // Left launcher + Marathon Runner Emblem & Rank Seal ([● 84] [ ⊕ | III ])
            TacticalButton {
                id: launcherBtn
                text: root.isCompact ? "" : "RUN"
                iconName: "grid"
                active: root.launcherOpen
                variant: root.launcherOpen ? "primary" : "default"
                Layout.preferredWidth: root.isCompact ? 30 : 62
                Layout.minimumWidth: Layout.preferredWidth
                Layout.preferredHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: root.launcherRequested()
            }

            RunnerEmblemCard {
                visible: !root.isCompact && (!root.s || root.s.showRunnerBadge)
                compact: true
                Layout.preferredWidth: visible ? implicitWidth : 0
                Layout.minimumWidth: Layout.preferredWidth
                onEmblemSelected: function(emblemId) {
                    if (root.backend && root.backend.appearance) {
                        root.backend.appearance.setEmblem(emblemId)
                    }
                }
            }

            Row {
                visible: !root.isCompact && root.monitorName !== "" && (!root.s || root.s.showMonitorTag)
                Layout.preferredWidth: visible ? implicitWidth : 0
                Layout.minimumWidth: Layout.preferredWidth
                spacing: Tokens.spaceXs
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "HUD // " + root.monitorName
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }
            }

            HudDivider {
                visible: !root.s || root.s.showWorkspaces
                orientation: Qt.Vertical
                Layout.preferredWidth: visible ? Tokens.borderWidth : 0
                Layout.preferredHeight: 20
            }

            WorkspaceIndicator {
                visible: !root.s || root.s.showWorkspaces
                Layout.preferredWidth: visible ? implicitWidth : 0
                Layout.minimumWidth: Layout.preferredWidth
                workspaces: root.backend.workspaces
                monitorFilter: root.monitorName
                reducedMotion: root.reducedMotion
            }

            HudDivider {
                visible: !root.s || root.s.showActiveWindow
                orientation: Qt.Vertical
                Layout.preferredWidth: visible ? Tokens.borderWidth : 0
                Layout.preferredHeight: 20
            }

            ActiveWindowModule {
                visible: !root.s || root.s.showActiveWindow
                Layout.fillWidth: true
                Layout.minimumWidth: visible ? 80 : 0
                activeWindow: root.backend.activeWindow
                compact: root.isCompact
            }

            Item {
                visible: root.s && !root.s.showActiveWindow
                Layout.fillWidth: true
            }

            HudDivider {
                orientation: Qt.Vertical
                Layout.preferredWidth: Tokens.borderWidth
                Layout.preferredHeight: 20
            }

            TrayStrip {
                Layout.preferredWidth: implicitWidth
                tray: root.backend ? root.backend.tray : null
                keyboard: root.backend ? root.backend.keyboard : null
                compact: root.isCompact
                onMenuRequested: function(itemId, x, y) { root.trayMenuRequested(itemId, x, y) }
            }

            TelemetryCluster {
                Layout.preferredWidth: implicitWidth
                Layout.minimumWidth: implicitWidth
                audio: root.backend.audio
                network: root.backend.network
                bluetooth: root.backend.bluetooth
                battery: root.backend.battery
                notifications: root.backend.notifications
                settings: root.s
                compact: root.isCompact
                controlCenterOpen: root.controlCenterOpen
                notificationsOpen: root.notificationsOpen
                settingsOpen: root.settingsOpen
                reducedMotion: root.reducedMotion
                onControlCenterRequested: root.controlCenterRequested()
                onNotificationsRequested: root.notificationsRequested()
                onSettingsRequested: root.settingsRequested()
            }

            HudDivider {
                orientation: Qt.Vertical
                Layout.preferredWidth: Tokens.borderWidth
                Layout.preferredHeight: 20
            }

            ClockModule {
                Layout.preferredWidth: implicitWidth
                Layout.minimumWidth: implicitWidth
                appearance: root.backend.appearance
                settings: root.s
                utilities: root.backend ? root.backend.utilities : null
                compact: root.isCompact
                calendarOpen: root.calendarOpen
                onClicked: root.calendarRequested()
            }

            TacticalButton {
                id: powerBtn
                text: ""
                iconName: "power"
                active: root.sessionOpen
                variant: root.sessionOpen ? "danger" : "ghost"
                Layout.preferredWidth: 28
                Layout.minimumWidth: 28
                Layout.preferredHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: root.sessionMenuRequested()
            }
        }
    }
}
