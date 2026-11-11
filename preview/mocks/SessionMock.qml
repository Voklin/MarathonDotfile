import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property string userName: "runner"
    property string hostName: "cachyos-tactical"
    property bool locked: false
    property bool canSuspend: true
    property string pendingAction: ""
    property string statusMessage: "SESSION ACTIVE // MOCK GUARD ENABLED"
    property string authError: ""

    signal simulatedActionExecuted(string action)

    function requestAction(action) {
        if (!available) return
        authError = ""
        if (action === "lock") {
            lock()
            return
        }
        pendingAction = action
        statusMessage = "AWAITING CONFIRMATION: " + action.toUpperCase()
    }

    function confirmAction() {
        if (!available || pendingAction === "") return
        var action = pendingAction
        pendingAction = ""
        statusMessage = "SIMULATED (" + action.toUpperCase() + ") — OS POWER SAFE"
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
        locked = true
        statusMessage = "LOCKED (MOCK)"
        simulatedActionExecuted("lock")
    }

    function unlock(password) {
        if (!password || password.trim() === "") {
            authError = "PASSPHRASE REQUIRED (TRY: marathon)"
            return false
        }
        if (password !== "marathon" && password !== "1234") {
            authError = "AUTH REJECTED // INVALID KEY"
            return false
        }
        locked = false
        authError = ""
        statusMessage = "UNLOCKED // RUNNER AUTHENTICATED"
        return true
    }
}

