import QtQuick

// Preview-only StatusNotifier tray. Mirrors shell/services/TrayAdapter.qml 1:1.
QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property string lastAction: ""
    property var items: [
        { id: "nm-applet", title: "Network", tooltip: "Wi-Fi: MARATHON-NET", icon: "", status: "active", hasMenu: true },
        { id: "telegram", title: "Telegram", tooltip: "3 unread", icon: "", status: "attention", hasMenu: true },
        { id: "wireguard", title: "VPN", tooltip: "WireGuard: connected", icon: "", status: "active", hasMenu: false }
    ]

    function activate(id) { lastAction = "activate:" + id }
    function secondaryActivate(id) { lastAction = "secondary:" + id }
    function scroll(id, delta) { lastAction = "scroll:" + id + ":" + delta }
    function openMenu(id, window, x, y) { lastAction = "menu:" + id }
}
