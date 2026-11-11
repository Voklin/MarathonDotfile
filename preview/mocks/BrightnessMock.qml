import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property real level: 0.72
    property string deviceName: "intel_backlight"

    signal osdTriggered(string kind, real level, bool muted, string detail)

    function setLevel(nextLevel) {
        if (!available) return
        level = Math.max(0.05, Math.min(1.0, nextLevel))
        osdTriggered("brightness", level, false, deviceName)
    }
}

