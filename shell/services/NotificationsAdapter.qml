import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "../../ui/logic/DesktopParsing.js" as Parsing

QtObject {
    id: root

    property bool available: false
    property bool loading: true
    property string errorMessage: ""
    property bool dnd: false
    property var popupMap: ({})
    property var readMap: ({})
    property var timestampMap: ({})
    property string _ownerReply: ""
    property bool _ownerTimedOut: false

    // Single notification daemon safety check: verify no competing daemon owns org.freedesktop.Notifications
    property Process ownerCheckProc: Process {
        command: ["busctl", "--user", "--timeout=2", "call", "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "NameHasOwner", "s", "org.freedesktop.Notifications"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root._ownerReply = text || ""
            }
        }
        onExited: function(code, _status) {
            ownerTimeout.stop()
            root.loading = false
            root.available = !root._ownerTimedOut && Parsing.nameAvailable(code, root._ownerReply)
            serverLoader.active = root.available
            root.errorMessage = root.available ? "" : (root._ownerTimedOut ? "D-BUS OWNERSHIP CHECK TIMEOUT" : (code === 0 && root._ownerReply.trim() === "b true" ? "ANOTHER NOTIFICATION SERVER IS ACTIVE" : "D-BUS OWNERSHIP CHECK FAILED"))
        }
    }

    property Timer ownerTimeout: Timer {
        interval: 2000
        running: ownerCheckProc.running
        repeat: false
        onTriggered: {
            if (ownerCheckProc.running) {
                root._ownerTimedOut = true
                ownerCheckProc.running = false
                root.loading = false
                root.available = false
                root.errorMessage = "D-BUS OWNERSHIP CHECK TIMEOUT"
            }
        }
    }

    property LazyLoader serverLoader: LazyLoader {
        id: serverLoader
        active: false
        NotificationServer {
            keepOnReload: true
            bodySupported: true
            actionsSupported: true
            actionIconsSupported: false
            imageSupported: true
            persistenceSupported: true

            onNotification: function(notif) {
                notif.tracked = true
                var nextRead = Object.assign({}, root.readMap)
                var nextPopup = Object.assign({}, root.popupMap)
                var nextTs = Object.assign({}, root.timestampMap)
                nextRead[notif.id] = false
                nextPopup[notif.id] = !root.dnd
                nextTs[notif.id] = Qt.formatDateTime(new Date(), "hh:mm")
                root.readMap = nextRead
                root.popupMap = nextPopup
                root.timestampMap = nextTs
            }
        }
    }

    readonly property var server: serverLoader.item

    readonly property var items: {
        if (!available || !server || !server.trackedNotifications || !server.trackedNotifications.values) {
            return []
        }
        var raw = server.trackedNotifications.values
        var out = []
        for (var i = raw.length - 1; i >= 0; --i) {
            var n = raw[i]
            if (!n) continue
            var urg = "normal"
            if (n.urgency === NotificationUrgency.Critical) urg = "critical"
            else if (n.urgency === NotificationUrgency.Low) urg = "low"

            var mappedActions = []
            if (n.actions) {
                for (var j = 0; j < n.actions.length; ++j) {
                    var act = n.actions[j]
                    if (!act) continue
                    mappedActions.push({
                        id: String(act.identifier || ("act-" + j)),
                        label: String(act.text || "OPEN").toUpperCase(),
                        _raw: act
                    })
                }
            }

            out.push({
                id: n.id,
                appName: String(n.appName || "SYSTEM").toUpperCase(),
                summary: String(n.summary || "Notification"),
                body: String(n.body || ""),
                urgency: urg,
                timestamp: root.timestampMap[n.id] || Qt.formatDateTime(new Date(), "hh:mm"),
                read: root.readMap[n.id] === true,
                popupVisible: !root.dnd && (root.popupMap[n.id] === true),
                actions: mappedActions,
                _raw: n
            })
        }
        return out
    }

    readonly property var popupItems: {
        if (dnd) return []
        var out = []
        for (var i = 0; i < items.length; ++i) {
            if (items[i].popupVisible) out.push(items[i])
        }
        return out
    }

    readonly property int unreadCount: {
        var c = 0
        for (var i = 0; i < items.length; ++i) {
            if (!items[i].read) ++c
        }
        return c
    }

    // Event-gated single popup auto-expiry timer (stops automatically when zero popups remain)
    property Timer popupTimeout: Timer {
        interval: 5500
        repeat: true
        running: root.popupItems.length > 0 && !root.dnd
        onTriggered: {
            var cur = root.popupItems
            if (cur.length > 0) {
                root.dismissPopup(cur[cur.length - 1].id)
            }
        }
    }

    signal actionInvoked(int id, string actionId)

    function toggleDnd() {
        if (!available) return
        dnd = !dnd
        _store.set("dnd", dnd)
    }

    // A11: only the DND flag persists. Notification history is intentionally
    // kept in memory (keepOnReload) to avoid writing message bodies to disk.
    property StateStore _store: StateStore {
        fileName: "notifications.json"
        onLoaded: root.dnd = get("dnd", false) === true
    }

    function findRawNotification(id) {
        for (var i = 0; i < items.length; ++i) {
            if (items[i].id === id) return items[i]
        }
        return null
    }

    function dismiss(id) {
        var entry = findRawNotification(id)
        if (entry && entry._raw) {
            entry._raw.dismiss()
        }
    }

    function dismissPopup(id) {
        var nextPopup = Object.assign({}, popupMap)
        var nextRead = Object.assign({}, readMap)
        nextPopup[id] = false
        nextRead[id] = true
        popupMap = nextPopup
        readMap = nextRead
    }

    function clearAll() {
        if (!server || !server.trackedNotifications || !server.trackedNotifications.values) return
        var copy = server.trackedNotifications.values.slice()
        for (var i = 0; i < copy.length; ++i) {
            if (copy[i]) copy[i].dismiss()
        }
        popupMap = ({})
        readMap = ({})
    }

    function invokeAction(id, actionId) {
        var entry = findRawNotification(id)
        if (entry) {
            for (var i = 0; i < entry.actions.length; ++i) {
                if (entry.actions[i].id === actionId && entry.actions[i]._raw) {
                    entry.actions[i]._raw.invoke()
                    break
                }
            }
        }
        actionInvoked(id, actionId)
        dismissPopup(id)
    }

    function pushNotification(_appName, _summary, _body, _urgency, _actions) {
        // Real D-Bus apps emit notifications directly via org.freedesktop.Notifications.
    }
}
