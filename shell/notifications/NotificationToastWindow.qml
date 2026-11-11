pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../ui/tokens"
import "../../ui/components" as Ui

LazyLoader {
    id: root

    required property var backend
    property bool suppressed: false

    readonly property bool shouldShow: !suppressed
        && backend
        && backend.notifications
        && backend.notifications.available
        && !backend.notifications.dnd
        && backend.notifications.popupItems.length > 0

    active: shouldShow

    PanelWindow {
        readonly property var settingsObj: (root.backend && root.backend.settings) ? root.backend.settings : null
        readonly property string hudPos: settingsObj ? settingsObj.hudPosition : "top"
        readonly property string toastPos: settingsObj ? settingsObj.toastPosition : "top-right"
        anchors {
            top: toastPos !== "bottom-right"
            bottom: toastPos === "bottom-right"
            right: toastPos !== "top-center"
        }
        margins.top: (hudPos === "top" ? (Tokens.hudHeight + Tokens.hudInset * 2) : 0) + Tokens.spaceSm
        margins.bottom: (hudPos === "bottom" ? (Tokens.hudHeight + Tokens.hudInset * 2) : 0) + Tokens.spaceSm
        margins.right: Tokens.spaceSm
        implicitWidth: Tokens.notificationCenterWidth
        implicitHeight: toastStack.implicitHeight
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "marathon-toasts"
        color: "transparent"

        Ui.NotificationToastStack {
            id: toastStack
            notifications: root.backend.notifications
            settings: root.backend.settings
            suppressed: root.suppressed
            reducedMotion: root.backend.appearance.reducedMotion
        }
    }
}

