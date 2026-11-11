pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../ui/tokens"
import "../../ui/components" as Ui

LazyLoader {
    id: root

    required property var backend
    property bool open: false

    signal closeRequested()
    signal openNotificationsRequested()
    signal openSessionRequested()
    signal openSettingsRequested()
    signal openClipboardRequested()
    signal openCaptureRequested()
    signal openSysmonRequested()
    signal openCalendarRequested()
    signal openCheatsheetRequested()

    active: open

    onOpenChanged: {
        if (open && backend && backend.appearance) {
            backend.appearance.refreshUptime()
        }
    }

    PanelWindow {
        readonly property string hudPos: (root.backend && root.backend.settings) ? root.backend.settings.hudPosition : "top"
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        margins.top: hudPos === "top" ? (Tokens.hudHeight + Tokens.hudInset * 2) : 0
        margins.bottom: hudPos === "bottom" ? (Tokens.hudHeight + Tokens.hudInset * 2) : 0
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "marathon-control-center"
        color: "transparent"

        Ui.ControlCenterPanel {
            anchors.fill: parent
            backend: root.backend
            open: root.open
            reducedMotion: root.backend.appearance.reducedMotion
            onCloseRequested: root.closeRequested()
            onOpenNotificationsRequested: root.openNotificationsRequested()
            onOpenSessionRequested: root.openSessionRequested()
            onOpenSettingsRequested: root.openSettingsRequested()
            onOpenClipboardRequested: root.openClipboardRequested()
            onOpenCaptureRequested: root.openCaptureRequested()
            onOpenSysmonRequested: root.openSysmonRequested()
            onOpenCalendarRequested: root.openCalendarRequested()
            onOpenCheatsheetRequested: root.openCheatsheetRequested()
        }
    }
}

