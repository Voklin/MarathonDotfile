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
    signal triggerActionRequested(string actionId)

    active: open

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
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "marathon-cheatsheet"
        color: "transparent"

        Ui.CheatsheetPanel {
            anchors.fill: parent
            settings: root.backend.settings
            utilities: root.backend.utilities
            open: root.open
            reducedMotion: root.backend.appearance.reducedMotion
            onCloseRequested: root.closeRequested()
            onTriggerActionRequested: function(actId) { root.triggerActionRequested(actId) }
        }
    }
}
