pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../ui/tokens"
import "../../ui/components" as Ui

PanelWindow {
    id: root

    required property var backend

    readonly property string hudPos: (root.backend && root.backend.settings) ? root.backend.settings.hudPosition : "top"

    visible: osdView.visible
    anchors {
        bottom: true
    }
    margins.bottom: Tokens.spaceXl + (hudPos === "bottom" ? (Tokens.hudHeight + Tokens.hudInset * 2) : 0)
    implicitWidth: Tokens.osdWidth
    implicitHeight: osdView.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "marathon-osd"
    color: "transparent"

    Ui.OsdOverlay {
        id: osdView
        anchors.fill: parent
        audio: root.backend.audio
        brightness: root.backend.brightness
        settings: root.backend.settings
        reducedMotion: root.backend.appearance.reducedMotion
    }
}

