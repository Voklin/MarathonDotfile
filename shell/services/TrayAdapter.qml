import QtQuick
import Quickshell.Services.SystemTray

// StatusNotifierItem host (Quickshell.Services.SystemTray, docs v0.2.1).
// Exposes plain JS item records to ui/; native items are resolved by id.
QtObject {
    id: root

    readonly property bool available: SystemTray.items !== null
    property bool loading: false
    property string errorMessage: available ? "" : "SYSTEM TRAY UNAVAILABLE"
    property string lastAction: ""

    readonly property var _native: (SystemTray.items && SystemTray.items.values) ? SystemTray.items.values : []

    readonly property var items: {
        var out = []
        for (var i = 0; i < _native.length; ++i) {
            var it = _native[i]
            if (!it) continue
            var st = it.status === Status.NeedsAttention ? "attention" : (it.status === Status.Passive ? "passive" : "active")
            out.push({
                id: String(it.id || ("item-" + i)),
                title: String(it.title || it.id || ""),
                tooltip: String(it.tooltipTitle || it.title || ""),
                icon: String(it.icon || ""),
                status: st,
                hasMenu: it.hasMenu === true
            })
        }
        return out
    }

    function _find(id) {
        for (var i = 0; i < _native.length; ++i)
            if (_native[i] && String(_native[i].id) === String(id)) return _native[i]
        return null
    }

    function activate(id) {
        var it = _find(id)
        if (!it) return
        lastAction = "activate:" + id
        if (it.onlyMenu && it.hasMenu) return
        it.activate()
    }
    function secondaryActivate(id) {
        var it = _find(id)
        if (!it) return
        lastAction = "secondary:" + id
        it.secondaryActivate()
    }
    function scroll(id, delta) {
        var it = _find(id)
        if (!it) return
        lastAction = "scroll:" + id + ":" + delta
        it.scroll(delta, false)
    }
    // window must be a Quickshell window (provided by shell/panels/TopHudWindow.qml).
    function openMenu(id, window, x, y) {
        var it = _find(id)
        if (!it || !it.hasMenu || !window) return
        lastAction = "menu:" + id
        it.display(window, x, y)
    }
}
