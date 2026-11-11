import QtQuick
import Quickshell
import Quickshell.Io

// Small bounded JSON state file under $XDG_STATE_HOME/marathon-tactical/.
// Policy (docs/DECISIONS.md, A11): only non-secret UI state (launcher MRU ids,
// DND flag, clipboard pin ids). No notification bodies, no clipboard content.
// Writes are atomic (FileView.atomicWrites) and debounced; file > 64 KiB is ignored.
QtObject {
    id: root

    required property string fileName
    readonly property string _stateHome: {
        var s = Quickshell.env("XDG_STATE_HOME")
        if (s && String(s).length > 0) return String(s)
        return String(Quickshell.env("HOME") || "") + "/.local/state"
    }
    readonly property string dir: _stateHome + "/marathon-tactical"
    readonly property string path: dir + "/" + fileName
    property var data: ({})
    property bool ready: false
    signal loaded()

    property Process _mkdir: Process {
        command: ["mkdir", "-p", "-m", "700", root.dir]
        running: true
        onExited: function(_code, _status) { root._view.reload() }
    }

    property FileView _view: FileView {
        path: root.path
        atomicWrites: true
        blockLoading: false
        printErrors: false
        onLoaded: {
            var raw = root._view.text() || ""
            var parsed = {}
            if (raw.length <= 65536) {
                try { parsed = JSON.parse(raw) } catch (e) { parsed = {} }
            }
            root.data = (parsed && typeof parsed === "object") ? parsed : {}
            root.ready = true
            root.loaded()
        }
        onLoadFailed: function(_err) {
            root.data = {}
            root.ready = true
            root.loaded()
        }
    }

    property Timer _debounce: Timer {
        interval: 500
        repeat: false
        onTriggered: root._view.setText(JSON.stringify(root.data))
    }

    function get(key, fallback) {
        return (data && data[key] !== undefined) ? data[key] : fallback
    }
    function set(key, value) {
        if (!ready) return
        var next = Object.assign({}, data)
        next[key] = value
        data = next
        _debounce.restart()
    }
}
