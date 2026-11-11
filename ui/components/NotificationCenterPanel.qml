pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var notifications
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()

    visible: open || drawerReveal.opacity > 0.01

    onOpenChanged: {
        if (open) notifCard.forceActiveFocus()
    }

    Keys.onEscapePressed: function(event) {
        if (root.open) {
            root.closeRequested()
            event.accepted = true
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.closeRequested()
    }

    PanelReveal {
        id: drawerReveal
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Tokens.spaceSm
        width: Math.min(Tokens.notificationCenterWidth, parent.width - Tokens.spaceLg)
        height: Math.min(620, parent.height - Tokens.spaceLg)
        shown: root.open
        reducedMotion: root.reducedMotion
        slideOffsetY: -Tokens.spaceMd

        MouseArea {
            anchors.fill: notifCard
        }

        TacticalPanel {
            id: notifCard
            anchors.fill: parent
            focus: true
            code: "TELEMETRY // NOTIFICATION CENTER"
            title: "EVENT STREAM"
            statusText: root.notifications.dnd ? "DND ON" : (root.notifications.items.length + " LOGGED")
            statusTone: root.notifications.dnd ? "warning" : "signal"

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceSm

                TacticalButton {
                    text: root.notifications.dnd ? "DND: ON" : "DND: OFF"
                    iconName: root.notifications.dnd ? "bell-off" : "bell"
                    active: root.notifications.dnd
                    variant: root.notifications.dnd ? "primary" : "default"
                    implicitHeight: Tokens.controlHeightSm
                    Layout.fillWidth: true
                    reducedMotion: root.reducedMotion
                    onClicked: root.notifications.toggleDnd()
                }

                TacticalButton {
                    text: "CLEAR ALL"
                    iconName: "close"
                    variant: "danger"
                    enabledState: root.notifications.items.length > 0
                    implicitHeight: Tokens.controlHeightSm
                    Layout.fillWidth: true
                    reducedMotion: root.reducedMotion
                    onClicked: root.notifications.clearAll()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                EmptyState {
                    anchors.fill: parent
                    visible: !root.notifications.available || root.notifications.items.length === 0
                    code: !root.notifications.available ? "OFFLINE" : "CLEAR"
                    title: !root.notifications.available ? "NOTIFICATION DAEMON OFFLINE" : "NO NOTIFICATIONS IN QUEUE"
                    detail: !root.notifications.available
                        ? root.notifications.errorMessage
                        : (root.notifications.dnd ? "DO NOT DISTURB IS ACTIVE" : "ALL EVENT PACKETS ACKNOWLEDGED")
                    iconName: root.notifications.dnd ? "bell-off" : "bell"
                    alertTone: !root.notifications.available
                }

                ListView {
                    id: notifList
                    anchors.fill: parent
                    visible: root.notifications.available && root.notifications.items.length > 0
                    model: root.notifications.items
                    clip: true
                    spacing: Tokens.spaceSm

                    delegate: Rectangle {
                        id: nDel
                        required property var modelData
                        readonly property bool isCritical: nDel.modelData.urgency === "critical"

                        width: notifList.width
                        implicitHeight: nCol.implicitHeight + Tokens.spaceMd * 2
                        height: implicitHeight
                        color: nDel.isCritical ? Tokens.alertSurface : Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: nDel.isCritical ? Tokens.alert : Tokens.border

                        // Left urgency accent rail
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 3
                            color: nDel.isCritical ? Tokens.alert : (nDel.modelData.urgency === "low" ? Tokens.borderSubtle : Tokens.signal)
                        }

                        ColumnLayout {
                            id: nCol
                            anchors.fill: parent
                            anchors.margins: Tokens.spaceMd
                            spacing: Tokens.spaceXs

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spaceXs

                                Text {
                                    text: nDel.modelData.appName
                                    color: nDel.isCritical ? Tokens.alert : Tokens.signal
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: true
                                }

                                Text {
                                    text: "// " + nDel.modelData.timestamp
                                    color: Tokens.muted
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    Layout.fillWidth: true
                                }

                                TacticalButton {
                                    text: ""
                                    iconName: "close"
                                    variant: "ghost"
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    reducedMotion: root.reducedMotion
                                    onClicked: root.notifications.dismiss(nDel.modelData.id)
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: nDel.modelData.summary
                                color: Tokens.text
                                font.family: Tokens.fontUi
                                font.pixelSize: Tokens.fontBody
                                font.bold: true
                                wrapMode: Text.Wrap
                            }

                            Text {
                                visible: nDel.modelData.body !== ""
                                Layout.fillWidth: true
                                text: nDel.modelData.body
                                color: Tokens.muted
                                font.family: Tokens.fontUi
                                font.pixelSize: Tokens.fontLabel
                                wrapMode: Text.Wrap
                            }

                            Flow {
                                visible: nDel.modelData.actions && nDel.modelData.actions.length > 0
                                Layout.fillWidth: true
                                spacing: Tokens.spaceXs

                                Repeater {
                                    model: nDel.modelData.actions || []
                                    delegate: TacticalButton {
                                        id: actDel
                                        required property var modelData
                                        text: actDel.modelData.label
                                        variant: nDel.isCritical ? "danger" : "default"
                                        implicitHeight: Tokens.controlHeightSm
                                        reducedMotion: root.reducedMotion
                                        onClicked: root.notifications.invokeAction(nDel.modelData.id, actDel.modelData.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

