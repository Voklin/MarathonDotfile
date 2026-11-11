pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../components"

Rectangle {
    id: root

    required property var backend
    property bool showConfirmDemo: false

    color: Tokens.background

    Flickable {
        anchors.fill: parent
        anchors.margins: Tokens.spaceMd
        contentWidth: width
        contentHeight: mainCol.implicitHeight
        clip: true

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: Tokens.spaceMd

            TacticalPanel {
                Layout.fillWidth: true
                code: "STAGE 03 // COMPONENT LIBRARY"
                title: "MARATHON TACTICAL PRIMITIVES"
                statusText: root.backend.appearance.reducedMotion ? "REDUCED MOTION" : "MOTION ACTIVE"
                statusTone: root.backend.appearance.reducedMotion ? "warning" : "signal"

                Flow {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceSm

                    TacticalButton { text: "DEFAULT"; iconName: "terminal"; reducedMotion: root.backend.appearance.reducedMotion }
                    TacticalButton { text: "PRIMARY"; iconName: "check"; variant: "primary"; reducedMotion: root.backend.appearance.reducedMotion }
                    TacticalButton { text: "ACTIVE"; active: true; reducedMotion: root.backend.appearance.reducedMotion }
                    TacticalButton {
                        text: "DANGER MODAL"
                        iconName: "warning"
                        variant: "danger"
                        reducedMotion: root.backend.appearance.reducedMotion
                        onClicked: root.showConfirmDemo = true
                    }
                    TacticalButton { text: "GHOST"; variant: "ghost"; reducedMotion: root.backend.appearance.reducedMotion }
                    TacticalButton { text: "DISABLED"; enabledState: false; reducedMotion: root.backend.appearance.reducedMotion }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.width < 1100 ? 1 : 2
                columnSpacing: Tokens.spaceMd
                rowSpacing: Tokens.spaceMd

                TacticalPanel {
                    Layout.fillWidth: true
                    code: "CONTROLS // SLIDERS & TOGGLES"
                    title: "INPUTS & TELEMETRY"
                    statusText: "INTERACTIVE"

                    TacticalSlider {
                        Layout.fillWidth: true
                        label: "MASTER AUDIO OUTPUT"
                        iconName: root.backend.audio.muted ? "audio-muted" : "audio"
                        value: root.backend.audio.volume
                        mutedState: root.backend.audio.muted
                        enabledState: root.backend.audio.available
                        reducedMotion: root.backend.appearance.reducedMotion
                        onValueEdited: function(v) { root.backend.audio.setVolume(v) }
                        onIconClicked: root.backend.audio.toggleMute()
                    }

                    TacticalSlider {
                        Layout.fillWidth: true
                        label: "DISPLAY BACKLIGHT"
                        iconName: "brightness"
                        value: root.backend.brightness.level
                        minValue: 0.05
                        enabledState: root.backend.brightness.available
                        reducedMotion: root.backend.appearance.reducedMotion
                        onValueEdited: function(v) { root.backend.brightness.setLevel(v) }
                    }

                    TacticalToggle {
                        Layout.fillWidth: true
                        label: "DO NOT DISTURB"
                        sublabel: root.backend.notifications.dnd ? "POPUPS SUPPRESSED" : "STREAMING ACTIVE"
                        iconName: root.backend.notifications.dnd ? "bell-off" : "bell"
                        checked: root.backend.notifications.dnd
                        reducedMotion: root.backend.appearance.reducedMotion
                        onToggled: root.backend.notifications.toggleDnd()
                    }

                    TacticalToggle {
                        Layout.fillWidth: true
                        label: "BLUETOOTH SUBSYSTEM"
                        sublabel: root.backend.bluetooth.available ? root.backend.bluetooth.connectedDevice : "NO HARDWARE ADAPTER"
                        iconName: root.backend.bluetooth.powered ? "bluetooth" : "bluetooth-off"
                        checked: root.backend.bluetooth.powered
                        enabledState: root.backend.bluetooth.available
                        reducedMotion: root.backend.appearance.reducedMotion
                        onToggled: root.backend.bluetooth.togglePower()
                    }
                }

                TacticalPanel {
                    Layout.fillWidth: true
                    code: "TEXT INPUT // STATUS & EMPTY"
                    title: "FIELDS, PILLS & GEOMETRY"
                    statusText: "TOKENS ONLY"

                    TacticalTextField {
                        Layout.fillWidth: true
                        placeholderText: "FILTER APPLICATIONS OR SAFE COMMANDS..."
                    }

                    TacticalTextField {
                        Layout.fillWidth: true
                        passwordMode: true
                        text: "bad-pass"
                        errorText: "AUTH REJECTED // INVALID PASSPHRASE"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spaceXs
                        StatusPill { text: "ONLINE"; tone: "signal"; showDot: true }
                        StatusPill { text: "STANDBY"; tone: "neutral" }
                        StatusPill { text: "THROTTLED"; tone: "warning" }
                        StatusPill { text: "FAULT"; tone: "alert"; showDot: true }
                        StatusPill { text: "UNAVAILABLE"; tone: "muted" }
                    }

                    HudDivider { Layout.fillWidth: true; withTicks: true }

                    EmptyState {
                        Layout.fillWidth: true
                        code: "EMPTY"
                        title: "NO TELEMETRY EVENTS MATCHED"
                        detail: "ADJUST FILTER OR RESET WORKSPACE QUERY"
                        iconName: "search"
                    }
                }
            }

            TacticalPanel {
                Layout.fillWidth: true
                code: "VECTOR // GEOMETRIC ICONOGRAPHY"
                title: "CANVAS GRID ICONS (ORIGINAL)"
                statusText: "28 GLYPHS"

                Flow {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceSm

                    Repeater {
                        model: [
                            "audio", "audio-muted", "mic", "mic-muted", "wifi", "wifi-off",
                            "ethernet", "bluetooth", "bluetooth-off", "battery", "battery-charging",
                            "brightness", "bell", "bell-off", "lock", "power", "reboot",
                            "logout", "sleep", "search", "settings", "close", "check",
                            "warning", "terminal", "grid", "chevron-right", "chevron-left"
                        ]
                        delegate: Rectangle {
                            id: iconCell
                            required property string modelData
                            width: 132
                            height: 44
                            color: Tokens.surfacePressed
                            border.width: Tokens.borderWidth
                            border.color: Tokens.borderSubtle

                            Row {
                                anchors.centerIn: parent
                                spacing: Tokens.spaceXs
                                TacticalIcon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    iconName: iconCell.modelData
                                    iconSize: 16
                                    color: Tokens.signal
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: iconCell.modelData
                                    color: Tokens.text
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ConfirmDialog {
        anchors.fill: parent
        visible: root.showConfirmDemo
        actionName: "REBOOT"
        message: "Simulated confirmation dialog check. No host OS command will execute on Windows Preview."
        reducedMotion: root.backend.appearance.reducedMotion
        onConfirmed: root.showConfirmDemo = false
        onCancelled: root.showConfirmDemo = false
    }
}
