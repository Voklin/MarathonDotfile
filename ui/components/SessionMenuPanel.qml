pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var session
    property var settings: null
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()

    function dispatchPowerAction(actionName) {
        if (!root.session) return
        root.session.requestAction(actionName)
        if (root.settings && !root.settings.confirmPowerActions) {
            root.session.confirmAction()
        }
    }

    visible: open || modalReveal.opacity > 0.01

    onOpenChanged: {
        if (open) sessionCard.forceActiveFocus()
        else if (session && session.pendingAction !== "") session.cancelAction()
    }

    Keys.onEscapePressed: function(event) {
        if (root.session && root.session.pendingAction !== "") {
            root.session.cancelAction()
            event.accepted = true
            return
        }
        if (root.open) {
            root.closeRequested()
            event.accepted = true
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Tokens.surfaceOverlay
        opacity: root.open ? 0.80 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Tokens.motionMs(Tokens.durationPanel, root.reducedMotion) }
        }
        MouseArea {
            anchors.fill: parent
            enabled: root.open
            onClicked: root.closeRequested()
        }
    }

    PanelReveal {
        id: modalReveal
        anchors.centerIn: parent
        width: Math.min(Tokens.sessionMenuWidth, parent.width - Tokens.spaceXl)
        height: sessionCard.implicitHeight
        shown: root.open
        reducedMotion: root.reducedMotion

        MouseArea {
            anchors.fill: sessionCard
        }

        TacticalPanel {
            id: sessionCard
            anchors.fill: parent
            focus: true
            code: "SESSION CONTROL // " + (root.session.userName || "RUNNER").toUpperCase() + "@" + (root.session.hostName || "HOST").toUpperCase()
            title: "POWER & SESSION OPERATIONS"
            statusText: "GUARDED"
            statusTone: "warning"

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: Tokens.spaceSm
                rowSpacing: Tokens.spaceSm

                TacticalButton {
                    Layout.fillWidth: true
                    text: "LOCK SCREEN"
                    iconName: "lock"
                    variant: "primary"
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        root.session.lock()
                        root.closeRequested()
                    }
                }

                TacticalButton {
                    Layout.fillWidth: true
                    text: root.session.canSuspend ? "SUSPEND" : "SUSPEND (N/A)"
                    iconName: "sleep"
                    enabledState: root.session.canSuspend
                    reducedMotion: root.reducedMotion
                    onClicked: root.dispatchPowerAction("suspend")
                }

                TacticalButton {
                    Layout.fillWidth: true
                    text: "LOGOUT SESSION"
                    iconName: "logout"
                    variant: "danger"
                    reducedMotion: root.reducedMotion
                    onClicked: root.dispatchPowerAction("logout")
                }

                TacticalButton {
                    Layout.fillWidth: true
                    text: "REBOOT SYSTEM"
                    iconName: "reboot"
                    variant: "danger"
                    reducedMotion: root.reducedMotion
                    onClicked: root.dispatchPowerAction("reboot")
                }

                TacticalButton {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    text: "SHUTDOWN SYSTEM"
                    iconName: "power"
                    variant: "danger"
                    reducedMotion: root.reducedMotion
                    onClicked: root.dispatchPowerAction("shutdown")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceSm

                Text {
                    Layout.fillWidth: true
                    text: root.session.statusMessage
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    elide: Text.ElideRight
                }

                TacticalButton {
                    text: "CLOSE [ESC]"
                    variant: "ghost"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.closeRequested()
                }
            }
        }
    }

    ConfirmDialog {
        anchors.fill: parent
        visible: root.open && root.session && root.session.pendingAction !== ""
        actionName: root.session ? root.session.pendingAction : ""
        message: "Execute " + (root.session ? root.session.pendingAction.toUpperCase() : "") + "? Unsaved work in active windows may be interrupted."
        reducedMotion: root.reducedMotion
        onConfirmed: root.session.confirmAction()
        onCancelled: root.session.cancelAction()
    }
}

