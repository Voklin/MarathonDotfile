import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property int activeWorkspaceId: 1
    property var monitors: [
        { name: "eDP-1", label: "PRIMARY // 1920x1080", activeWorkspaceId: 1, primary: true }
    ]
    property var items: [
        { id: 1, name: "01", monitor: "eDP-1", occupied: true, active: true, urgent: false, windowsCount: 2 },
        { id: 2, name: "02", monitor: "eDP-1", occupied: true, active: false, urgent: false, windowsCount: 1 },
        { id: 3, name: "03", monitor: "eDP-1", occupied: false, active: false, urgent: false, windowsCount: 0 },
        { id: 4, name: "04", monitor: "eDP-1", occupied: true, active: false, urgent: false, windowsCount: 3 },
        { id: 5, name: "05", monitor: "eDP-1", occupied: false, active: false, urgent: false, windowsCount: 0 },
        { id: 6, name: "06", monitor: "eDP-1", occupied: false, active: false, urgent: false, windowsCount: 0 }
    ]

    signal workspaceSwitched(int workspaceId)

    function switchWorkspace(id) {
        if (!available) return
        var next = []
        var found = false
        for (var i = 0; i < items.length; ++i) {
            var item = items[i]
            var isTarget = (item.id === id)
            if (isTarget) found = true
            next.push({
                id: item.id,
                name: item.name,
                monitor: item.monitor,
                occupied: isTarget ? true : item.occupied,
                active: isTarget,
                urgent: isTarget ? false : item.urgent,
                windowsCount: item.windowsCount
            })
        }
        if (found) {
            activeWorkspaceId = id
            items = next
            workspaceSwitched(id)
        }
    }

    function moveFocusedToWorkspace(id) {
        if (!available) return
        var next = []
        for (var i = 0; i < items.length; ++i) {
            var item = items[i]
            var target = (item.id === id)
            next.push({
                id: item.id,
                name: item.name,
                monitor: item.monitor,
                occupied: target ? true : item.occupied,
                active: item.active,
                urgent: item.urgent,
                windowsCount: target ? item.windowsCount + 1 : item.windowsCount
            })
        }
        items = next
    }
}

