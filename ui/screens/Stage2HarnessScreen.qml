pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Rectangle {
    id: root

    required property var backend
    property string scenarioCode: "S01"
    property string scenarioLabel: "STANDARD DESKTOP"

    color: Tokens.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Tokens.hudInset
        spacing: Tokens.spaceSm

        PanelReveal {
            id: hudReveal
            Layout.fillWidth: true
            Layout.preferredHeight: hudReveal.shown ? Tokens.hudHeight : 0
            shown: !(root.backend.activeWindow.fullscreen && root.backend.appearance.hudAutoHideOnFullscreen)
            reducedMotion: root.backend.appearance.reducedMotion
            clip: true

            Rectangle {
                anchors.fill: parent
                color: Tokens.surface
                border.width: Tokens.borderWidth
                border.color: Tokens.border

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Tokens.spaceSm
                    anchors.rightMargin: Tokens.spaceSm
                    spacing: Tokens.spaceSm

                    Rectangle {
                        width: Tokens.spaceXs
                        height: Tokens.spaceLg
                        color: Tokens.signal
                    }

                    Text {
                        text: root.backend.appearance.sysLabel
                        color: Tokens.text
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontLabel
                        font.bold: true
                    }

                    Rectangle { width: Tokens.borderWidth; height: Tokens.spaceLg; color: Tokens.border }

                    Row {
                        spacing: Tokens.spaceXs
                        Repeater {
                            model: root.backend.workspaces.items
                            delegate: Rectangle {
                                id: wsDel
                                required property var modelData
                                width: Tokens.controlHeightSm
                                height: Tokens.controlHeightSm
                                color: wsDel.modelData.active ? Tokens.signal : (wsDel.modelData.urgent ? Tokens.alertSurface : Tokens.surfaceElevated)
                                border.width: Tokens.borderWidth
                                border.color: wsDel.modelData.urgent ? Tokens.alert : (wsDel.modelData.active ? Tokens.signal : (wsDel.modelData.occupied ? Tokens.borderStrong : Tokens.borderSubtle))

                                Text {
                                    anchors.centerIn: parent
                                    text: wsDel.modelData.name
                                    color: wsDel.modelData.active ? Tokens.textOnSignal : (wsDel.modelData.urgent ? Tokens.alert : (wsDel.modelData.occupied ? Tokens.text : Tokens.muted))
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontLabel
                                    font.bold: wsDel.modelData.active || wsDel.modelData.urgent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.backend.workspaces.switchWorkspace(wsDel.modelData.id)
                                }
                            }
                        }
                    }

                    Rectangle { width: Tokens.borderWidth; height: Tokens.spaceLg; color: Tokens.border }

                    Text {
                        Layout.fillWidth: true
                        text: root.backend.activeWindow.available
                            ? (root.backend.activeWindow.appId + " // " + root.backend.activeWindow.title)
                            : "NO ACTIVE WINDOW"
                        color: Tokens.text
                        font.family: Tokens.fontUi
                        font.pixelSize: Tokens.fontBody
                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.backend.network.available
                            ? (root.backend.network.connected ? ("NET:" + root.backend.network.ssid) : "NET:OFFLINE")
                            : "NET:N/A"
                        color: !root.backend.network.available || !root.backend.network.connected ? Tokens.alert : Tokens.muted
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontLabel
                    }

                    Text {
                        text: root.backend.audio.available
                            ? ("VOL:" + (root.backend.audio.muted ? "MUTE" : Math.round(root.backend.audio.volume * 100) + "%"))
                            : "VOL:N/A"
                        color: root.backend.audio.muted || !root.backend.audio.available ? Tokens.muted : Tokens.text
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontLabel
                    }

                    Text {
                        text: root.backend.battery.available
                            ? ("BAT:" + root.backend.battery.percentage + "%")
                            : "AC:DIRECT"
                        color: root.backend.battery.available && root.backend.battery.percentage <= 15 && !root.backend.battery.charging
                            ? Tokens.alert
                            : Tokens.text
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontLabel
                    }

                    Rectangle { width: Tokens.borderWidth; height: Tokens.spaceLg; color: Tokens.border }

                    Text {
                        text: root.backend.appearance.clockText + " | " + root.backend.appearance.dateText
                        color: Tokens.signal
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontLabel
                        font.bold: true
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: root.width < Tokens.hudCompactBreakpoint ? 2 : 3
            columnSpacing: Tokens.spaceSm
            rowSpacing: Tokens.spaceSm

            Repeater {
                model: [
                    {
                        code: "01 // WORKSPACES",
                        contract: root.backend.workspaces,
                        summary: "ACTIVE WS " + root.backend.workspaces.activeWorkspaceId + " / MONITORS " + root.backend.workspaces.monitors.length
                    },
                    {
                        code: "02 // ACTIVE WINDOW",
                        contract: root.backend.activeWindow,
                        summary: root.backend.activeWindow.title
                    },
                    {
                        code: "03 // AUDIO",
                        contract: root.backend.audio,
                        summary: root.backend.audio.available ? (root.backend.audio.sinkName + " (" + Math.round(root.backend.audio.volume * 100) + "%)") : "NO AUDIO SINK"
                    },
                    {
                        code: "04 // NETWORK",
                        contract: root.backend.network,
                        summary: root.backend.network.available ? (root.backend.network.connectionType.toUpperCase() + " // " + root.backend.network.ssid) : "SERVICE UNAVAILABLE"
                    },
                    {
                        code: "05 // BLUETOOTH",
                        contract: root.backend.bluetooth,
                        summary: root.backend.bluetooth.available ? (root.backend.bluetooth.powered ? root.backend.bluetooth.connectedDevice : "POWERED OFF") : "ADAPTER ABSENT"
                    },
                    {
                        code: "06 // BATTERY",
                        contract: root.backend.battery,
                        summary: root.backend.battery.available ? (root.backend.battery.percentage + "% // " + root.backend.battery.stateLabel) : "DESKTOP / NO BATTERY"
                    },
                    {
                        code: "07 // BRIGHTNESS",
                        contract: root.backend.brightness,
                        summary: root.backend.brightness.available ? (Math.round(root.backend.brightness.level * 100) + "% // " + root.backend.brightness.deviceName) : "NO BACKLIGHT INTERFACE"
                    },
                    {
                        code: "08 // NOTIFICATIONS",
                        contract: root.backend.notifications,
                        summary: "QUEUE: " + root.backend.notifications.items.length + " | UNREAD: " + root.backend.notifications.unreadCount + (root.backend.notifications.dnd ? " | DND" : "")
                    },
                    {
                        code: "09 // LAUNCHER & SESSION",
                        contract: root.backend.launcher,
                        summary: "APPS: " + root.backend.launcher.entries.length + " | MOTION: " + (root.backend.appearance.reducedMotion ? "REDUCED" : "ACTIVE")
                    }
                ]

                delegate: Rectangle {
                    id: cardDel
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: cardDel.modelData.contract.errorMessage !== "" ? Tokens.alertSurface : Tokens.surface
                    border.width: Tokens.borderWidth
                    border.color: cardDel.modelData.contract.errorMessage !== "" ? Tokens.alert : (cardDel.modelData.contract.available ? Tokens.border : Tokens.borderSubtle)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Tokens.spaceMd
                        spacing: Tokens.spaceXs

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: cardDel.modelData.code
                                color: cardDel.modelData.contract.available ? Tokens.signal : Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontLabel
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Rectangle {
                                width: statusLbl.implicitWidth + Tokens.spaceSm
                                height: Tokens.spaceLg + Tokens.spaceXs
                                color: cardDel.modelData.contract.errorMessage !== ""
                                    ? Tokens.alert
                                    : (cardDel.modelData.contract.loading ? Tokens.warning : (cardDel.modelData.contract.available ? Tokens.signalSubtle : Tokens.surfacePressed))
                                border.width: Tokens.borderWidth
                                border.color: cardDel.modelData.contract.errorMessage !== ""
                                    ? Tokens.alert
                                    : (cardDel.modelData.contract.available ? Tokens.borderStrong : Tokens.borderSubtle)

                                Text {
                                    id: statusLbl
                                    anchors.centerIn: parent
                                    text: cardDel.modelData.contract.errorMessage !== ""
                                        ? "ERROR"
                                        : (cardDel.modelData.contract.loading ? "LOADING" : (cardDel.modelData.contract.available ? "ONLINE" : "UNAVAILABLE"))
                                    color: cardDel.modelData.contract.errorMessage !== ""
                                        ? Tokens.textOnSignal
                                        : (cardDel.modelData.contract.available ? Tokens.signal : Tokens.muted)
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: true
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: cardDel.modelData.contract.errorMessage !== "" ? cardDel.modelData.contract.errorMessage : cardDel.modelData.summary
                            color: cardDel.modelData.contract.errorMessage !== "" ? Tokens.alert : (cardDel.modelData.contract.available ? Tokens.text : Tokens.muted)
                            font.family: Tokens.fontUi
                            font.pixelSize: Tokens.fontBody
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }
}
