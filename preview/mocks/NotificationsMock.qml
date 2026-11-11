import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property bool dnd: false
    property int _nextId: 100
    property var items: [
        {
            id: 1,
            appName: "HYPRLAND",
            summary: "Display topology synchronized",
            body: "eDP-1 active at 1920x1080@144Hz. Profile MARATHON_TACTICAL ready.",
            urgency: "normal",
            timestamp: "23:40",
            read: false,
            popupVisible: false,
            actions: [{ id: "inspect", label: "INSPECT" }]
        },
        {
            id: 2,
            appName: "NETWORK",
            summary: "Uplink secured: TAU-CETI-5G",
            body: "WPA3 handshake verified on interface wlan0 (10.42.8.19).",
            urgency: "low",
            timestamp: "23:36",
            read: true,
            popupVisible: false,
            actions: []
        },
        {
            id: 3,
            appName: "POWER",
            summary: "Thermal profile balanced",
            body: "Acoustic envelope nominal; battery telemetry streaming via UPower.",
            urgency: "normal",
            timestamp: "23:28",
            read: true,
            popupVisible: false,
            actions: []
        }
    ]

    readonly property var popupItems: {
        if (dnd) return []
        var out = []
        for (var i = 0; i < items.length; ++i) {
            if (items[i].popupVisible) out.push(items[i])
        }
        return out
    }

    readonly property int unreadCount: {
        var count = 0
        for (var i = 0; i < items.length; ++i) {
            if (!items[i].read) ++count
        }
        return count
    }

    signal actionInvoked(int id, string actionId)

    function toggleDnd() {
        if (!available) return
        dnd = !dnd
    }

    function dismiss(id) {
        var next = []
        for (var i = 0; i < items.length; ++i) {
            if (items[i].id !== id) next.push(items[i])
        }
        items = next
    }

    function dismissPopup(id) {
        var next = []
        for (var i = 0; i < items.length; ++i) {
            var it = items[i]
            next.push({
                id: it.id,
                appName: it.appName,
                summary: it.summary,
                body: it.body,
                urgency: it.urgency,
                timestamp: it.timestamp,
                read: it.id === id ? true : it.read,
                popupVisible: it.id === id ? false : it.popupVisible,
                actions: it.actions
            })
        }
        items = next
    }

    function clearAll() {
        items = []
    }

    function invokeAction(id, actionId) {
        actionInvoked(id, actionId)
        dismissPopup(id)
    }

    function pushNotification(appName, summary, body, urgency, actions) {
        if (!available) return
        _nextId += 1
        var entry = {
            id: _nextId,
            appName: appName || "SYSTEM",
            summary: summary || "Telemetry notice",
            body: body || "",
            urgency: urgency || "normal",
            timestamp: "23:42",
            read: false,
            popupVisible: !dnd,
            actions: actions || []
        }
        var next = [entry]
        for (var i = 0; i < items.length; ++i) {
            next.push(items[i])
        }
        items = next
    }
}
