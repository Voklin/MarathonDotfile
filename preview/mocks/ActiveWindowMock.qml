import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property string title: "ghostty — marathon-tactical/ui"
    property string appId: "com.mitchellh.ghostty"
    property bool fullscreen: false
    property bool floating: false
    property string monitor: "eDP-1"

    function toggleFloating() {
        if (!available) return
        floating = !floating
    }

    function toggleFullscreen() {
        if (!available) return
        fullscreen = !fullscreen
    }

    function closeActive() {
        if (!available) return
        title = "IDLE // DESKTOP"
        appId = "hyprland.empty"
        fullscreen = false
        floating = false
    }
}

