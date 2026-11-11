import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property string userName: "runner"
    property string hostName: "cachyos"
    property bool locked: false
    property bool canSuspend: false
    property string pendingAction: ""
    property string statusMessage: "SESSION ACTIVE // HYPRLOCK PAM READY"
    property string authError: ""
    property string hyprlockConfigPath: ""
    property bool _hyprlockConfigValid: false

    signal simulatedActionExecuted(string action)

    onHyprlockConfigPathChanged: {
        _hyprlockConfigValid = false
        if (hyprlockConfigPath !== "") {
            lockConfigProbe.command = ["test", "-f", hyprlockConfigPath]
            lockConfigProbe.running = true
        }
    }

    property Process lockConfigProbe: Process {
        running: false
        onExited: function(code, _status) {
            root._hyprlockConfigValid = (code === 0)
        }
    }

    // Separate explicit array-arg commands without shell interpolation
    property Process userProc: Process {
        command: ["id", "-un"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var u = (text || "").trim()
                if (u !== "") root.userName = u
            }
        }
    }

    property Process hostProc: Process {
        command: ["uname", "-n"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var h = (text || "").trim()
                if (h !== "") root.hostName = h
            }
        }
    }

    property Process suspendProbe: Process {
        command: ["systemctl", "can-suspend"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.canSuspend = ((text || "").trim().toLowerCase() === "yes")
            }
        }
        onExited: function(code, _status) {
            if (code !== 0) root.canSuspend = false
        }
    }

    property Process execProc: Process {
        running: false
        onExited: function(code, _status) {
            if (code !== 0) {
                root.errorMessage = "SESSION ACTION EXIT " + code
                root.statusMessage = root.errorMessage
            }
            root.locked = false
        }
    }

    function requestAction(action) {
        if (!available) return
        authError = ""
        if (action === "lock") {
            lock()
            return
        }
        pendingAction = action
        statusMessage = "CONFIRMATION REQUIRED: " + action.toUpperCase()
    }

    function confirmAction() {
        if (!available || pendingAction === "") return
        var action = pendingAction
        pendingAction = ""
        statusMessage = "EXECUTING " + action.toUpperCase() + "..."

        if (action === "suspend" && canSuspend) {
            execProc.command = ["systemctl", "suspend"]
            execProc.running = true
        } else if (action === "reboot") {
            execProc.command = ["systemctl", "reboot"]
            execProc.running = true
        } else if (action === "shutdown") {
            execProc.command = ["systemctl", "poweroff"]
            execProc.running = true
        } else if (action === "logout") {
            Hyprland.dispatch("exit")
        }
        simulatedActionExecuted(action)
    }

    function cancelAction() {
        pendingAction = ""
        statusMessage = "ACTION ABORTED"
    }

    function lock() {
        if (!available) return
        pendingAction = ""
        authError = ""
        if (execProc.running) return
        if (_hyprlockConfigValid && hyprlockConfigPath !== "") {
            execProc.command = ["hyprlock", "--config", hyprlockConfigPath]
        } else {
            execProc.command = ["hyprlock"]
        }
        statusMessage = "LOCKING SESSION VIA HYPRLOCK..."
        execProc.running = true
        simulatedActionExecuted("lock")
    }

    function unlock(_password) {
        // Real Linux authentication is delegated strictly to PAM / hyprlock, never QML string check
        return false
    }
}
