pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../ui/tokens"
import "../../ui/components" as Ui

Variants {
    id: root

    required property var backend
    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool notificationsOpen: false
    property bool sessionOpen: false
    property bool settingsOpen: false
    property bool calendarOpen: false

    readonly property var settingsObj: (root.backend && root.backend.settings) ? root.backend.settings : null
    readonly property string hudPos: settingsObj ? settingsObj.hudPosition : "top"
    readonly property bool allMonitors: settingsObj ? settingsObj.hudMultiMonitorAll : true

    signal launcherRequested()
    signal controlCenterRequested()
    signal notificationsRequested()
    signal sessionMenuRequested()
    signal settingsRequested()
    signal calendarRequested()

    model: Quickshell.screens

    PanelWindow {
        id: hudWin
        required property var modelData
        readonly property bool showOnScreen: root.allMonitors || (Quickshell.screens.length === 0) || (modelData === Quickshell.screens[0])

        screen: modelData
        visible: showOnScreen && hudBar.shown
        anchors {
            top: root.hudPos === "top"
            bottom: root.hudPos === "bottom"
            left: true
            right: true
        }
        implicitHeight: (showOnScreen && hudBar.shown) ? (Tokens.hudHeight + Tokens.hudInset * 2) : 0
        exclusionMode: (showOnScreen && hudBar.shown) ? ExclusionMode.Auto : ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "marathon-hud"
        color: "transparent"

        Ui.TopHudBar {
            id: hudBar
            anchors.fill: parent
            anchors.margins: Tokens.hudInset
            backend: root.backend
            monitorName: hudWin.modelData ? (hudWin.modelData.name || "") : ""
            launcherOpen: root.launcherOpen
            controlCenterOpen: root.controlCenterOpen
            notificationsOpen: root.notificationsOpen
            sessionOpen: root.sessionOpen
            settingsOpen: root.settingsOpen
            calendarOpen: root.calendarOpen

            onLauncherRequested: root.launcherRequested()
            onControlCenterRequested: root.controlCenterRequested()
            onNotificationsRequested: root.notificationsRequested()
            onSessionMenuRequested: root.sessionMenuRequested()
            onSettingsRequested: root.settingsRequested()
            onCalendarRequested: root.calendarRequested()
        }
    }
}
