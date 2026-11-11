pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var backend
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()
    signal openNotificationsRequested()
    signal openSessionRequested()
    signal openSettingsRequested()
    signal openClipboardRequested()
    signal openCaptureRequested()
    signal openSysmonRequested()
    signal openCalendarRequested()
    signal openCheatsheetRequested()

    function _formatMediaSec(sec) {
        var s = Math.max(0, Math.floor(Number(sec || 0)))
        var m = Math.floor(s / 60)
        var r = s % 60
        return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
    }

    visible: open || drawerReveal.opacity > 0.01

    onOpenChanged: {
        if (open) drawerCard.forceActiveFocus()
    }

    Keys.onEscapePressed: function(event) {
        if (root.open) {
            root.closeRequested()
            event.accepted = true
        }
    }

    // Transparent dismiss catch layer
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
        width: Math.min(Tokens.controlCenterWidth, parent.width - Tokens.spaceLg)
        height: Math.min(940, parent.height - Tokens.spaceLg)
        shown: root.open
        reducedMotion: root.reducedMotion
        slideOffsetY: -Tokens.spaceMd

        MouseArea {
            anchors.fill: drawerCard
        }

        TacticalPanel {
            id: drawerCard
            anchors.fill: parent
            focus: true
            code: "SYSTEM // CONTROL CENTER"
            title: "TELEMETRY & SUBSYSTEMS"
            statusText: root.backend.appearance.sysLabel
            statusTone: root.backend.network.connected ? "signal" : "warning"

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: contentCol.implicitHeight
                clip: true

                ColumnLayout {
                    id: contentCol
                    width: parent.width
                    spacing: Tokens.spaceSm

                    // Marathon + Destiny 2 Runner Calling Card & Emblem Banner (Emblem + Name + Custom Title)
                    RunnerEmblemCard {
                        Layout.fillWidth: true
                        compact: false
                        showSelector: true
                        reducedMotion: root.reducedMotion
                        onEmblemSelected: function(emblemId) {
                            root.backend.appearance.setEmblem(emblemId)
                        }
                        onNameEdited: function(nextName) {
                            root.backend.appearance.setRunnerName(nextName)
                        }
                        onTitleEdited: function(nextTitle) {
                            root.backend.appearance.setRunnerTitle(nextTitle)
                        }
                    }

                    HudDivider { Layout.fillWidth: true; withTicks: true }

                    // 2x2 Quick Subsystem Matrix (always visible above the fold)
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: Tokens.spaceXs
                        rowSpacing: Tokens.spaceXs

                        TacticalButton {
                            Layout.fillWidth: true
                            text: root.backend.network.connected
                                ? ("WIFI: " + root.backend.network.ssid)
                                : (root.backend.network.wifiEnabled ? "WIFI: SCAN" : "WIFI: OFF")
                            iconName: root.backend.network.connected ? "wifi" : "wifi-off"
                            active: root.backend.network.wifiEnabled && root.backend.network.connected
                            variant: active ? "primary" : "default"
                            enabledState: root.backend.network.available
                            implicitHeight: Tokens.controlHeightMd
                            reducedMotion: root.reducedMotion
                            onClicked: root.backend.network.toggleWifi()
                        }

                        TacticalButton {
                            Layout.fillWidth: true
                            text: root.backend.bluetooth.powered ? "BT: ACTIVE" : "BT: OFF"
                            iconName: root.backend.bluetooth.powered ? "bluetooth" : "bluetooth-off"
                            active: root.backend.bluetooth.powered
                            variant: active ? "primary" : "default"
                            enabledState: root.backend.bluetooth.available
                            implicitHeight: Tokens.controlHeightMd
                            reducedMotion: root.reducedMotion
                            onClicked: root.backend.bluetooth.togglePower()
                        }

                        TacticalButton {
                            Layout.fillWidth: true
                            visible: root.backend && root.backend.utilities
                            text: (root.backend && root.backend.utilities && root.backend.utilities.nightLightEnabled)
                                ? ("NIGHT: " + root.backend.utilities.nightLightTemp + "K")
                                : "NIGHT LIGHT"
                            iconName: "brightness"
                            active: root.backend && root.backend.utilities && root.backend.utilities.nightLightEnabled
                            variant: active ? "primary" : "default"
                            enabledState: root.backend && root.backend.utilities && root.backend.utilities.nightLightAvailable
                            implicitHeight: Tokens.controlHeightMd
                            reducedMotion: root.reducedMotion
                            onClicked: if (root.backend && root.backend.utilities) root.backend.utilities.toggleNightLight()
                        }

                        TacticalButton {
                            Layout.fillWidth: true
                            visible: root.backend && root.backend.utilities
                            text: (root.backend && root.backend.utilities && root.backend.utilities.gameModeEnabled)
                                ? "GAME: ARMED"
                                : "GAME MODE"
                            iconName: "cpu"
                            active: root.backend && root.backend.utilities && root.backend.utilities.gameModeEnabled
                            variant: active ? "primary" : "default"
                            implicitHeight: Tokens.controlHeightMd
                            reducedMotion: root.reducedMotion
                            onClicked: if (root.backend && root.backend.utilities) root.backend.utilities.toggleGameMode()
                        }
                    }

                    SettingsStepper {
                        visible: root.backend && root.backend.utilities && root.backend.utilities.nightLightEnabled
                        Layout.fillWidth: true
                        label: "Night Light Warmth"
                        value: root.backend && root.backend.utilities ? root.backend.utilities.nightLightTemp : 4200
                        minValue: 2500
                        maxValue: 6500
                        stepSize: 200
                        unit: "K"
                        reducedMotion: root.reducedMotion
                        onValueEdited: function(v) { if (root.backend && root.backend.utilities) root.backend.utilities.setNightLightTemp(v) }
                    }

                    // Audio Output + Sink Selector + Mic
                    TacticalSlider {
                        Layout.fillWidth: true
                        label: root.backend.audio.available ? ("AUDIO // " + root.backend.audio.sinkName) : "AUDIO // UNAVAILABLE"
                        iconName: root.backend.audio.muted ? "audio-muted" : "audio"
                        value: root.backend.audio.volume
                        mutedState: root.backend.audio.muted
                        enabledState: root.backend.audio.available
                        reducedMotion: root.reducedMotion
                        onValueEdited: function(v) { root.backend.audio.setVolume(v) }
                        onIconClicked: root.backend.audio.toggleMute()
                    }

                    RowLayout {
                        visible: root.backend.audio.available
                        Layout.fillWidth: true
                        spacing: Tokens.spaceXs

                        Text {
                            Layout.fillWidth: true
                            text: "OUTPUT SINK ROUTING"
                            color: Tokens.muted
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.fontMicro
                            font.bold: true
                        }

                        TacticalButton {
                            visible: root.backend.audio.micAvailable
                            text: root.backend.audio.micMuted ? "MIC:OFF" : "MIC:ON"
                            iconName: root.backend.audio.micMuted ? "mic-muted" : "mic"
                            variant: root.backend.audio.micMuted ? "danger" : "default"
                            implicitHeight: Tokens.controlHeightSm
                            implicitWidth: 96
                            reducedMotion: root.reducedMotion
                            onClicked: root.backend.audio.toggleMicMute()
                        }
                    }

                    ColumnLayout {
                        visible: root.backend.audio.available
                        Layout.fillWidth: true
                        spacing: Tokens.spaceXs

                        Repeater {
                            model: root.backend.audio.sinks
                            delegate: TacticalButton {
                                id: sinkDel
                                required property var modelData
                                Layout.fillWidth: true
                                text: sinkDel.modelData.name
                                iconName: sinkDel.modelData.active ? "check" : "audio"
                                active: sinkDel.modelData.active
                                variant: sinkDel.modelData.active ? "primary" : "default"
                                implicitHeight: Tokens.controlHeightSm
                                reducedMotion: root.reducedMotion
                                onClicked: root.backend.audio.selectSink(sinkDel.modelData.id)
                            }
                        }
                    }

                    // Brightness
                    TacticalSlider {
                        Layout.fillWidth: true
                        label: root.backend.brightness.available
                            ? ("BACKLIGHT // " + root.backend.brightness.deviceName)
                            : "BACKLIGHT // NO INTERFACE"
                        iconName: "brightness"
                        value: root.backend.brightness.level
                        minValue: 0.05
                        enabledState: root.backend.brightness.available
                        reducedMotion: root.reducedMotion
                        onValueEdited: function(v) { root.backend.brightness.setLevel(v) }
                    }

                    // MPRIS Media Deck
                    Rectangle {
                        visible: root.backend && root.backend.media
                        Layout.fillWidth: true
                        implicitHeight: mediaCol.implicitHeight + Tokens.spaceSm * 2
                        color: Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: (root.backend && root.backend.media && root.backend.media.playing) ? Tokens.signal : Tokens.borderSubtle

                        ColumnLayout {
                            id: mediaCol
                            anchors.fill: parent
                            anchors.margins: Tokens.spaceSm
                            spacing: Tokens.spaceXs

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spaceXs

                                Text {
                                    Layout.fillWidth: true
                                    text: (root.backend && root.backend.media && root.backend.media.hasPlayer)
                                        ? ("MEDIA // " + root.backend.media.identity)
                                        : "MEDIA // NO ACTIVE PLAYER"
                                    color: Tokens.signal
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Repeater {
                                    model: (root.backend && root.backend.media && root.backend.media.players && root.backend.media.players.length > 1)
                                        ? root.backend.media.players
                                        : []
                                    delegate: TacticalButton {
                                        id: playerSwitchBtn
                                        required property var modelData
                                        text: playerSwitchBtn.modelData.identity.slice(0, 4)
                                        active: root.backend && root.backend.media && root.backend.media.activePlayerId === playerSwitchBtn.modelData.id
                                        variant: active ? "primary" : "default"
                                        implicitHeight: 20
                                        implicitWidth: 44
                                        reducedMotion: root.reducedMotion
                                        onClicked: if (root.backend && root.backend.media) root.backend.media.selectPlayer(playerSwitchBtn.modelData.id)
                                    }
                                }
                            }

                            Text {
                                visible: root.backend && root.backend.media && root.backend.media.hasPlayer
                                Layout.fillWidth: true
                                text: (root.backend && root.backend.media) ? root.backend.media.trackTitle : ""
                                color: Tokens.text
                                font.family: Tokens.fontUi
                                font.pixelSize: Tokens.fontBody
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                visible: root.backend && root.backend.media && root.backend.media.hasPlayer && root.backend.media.artist !== ""
                                Layout.fillWidth: true
                                text: (root.backend && root.backend.media) ? root.backend.media.artist : ""
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                elide: Text.ElideRight
                            }

                            SegmentedMeter {
                                visible: root.backend && root.backend.media && root.backend.media.hasPlayer && root.backend.media.length > 0
                                Layout.fillWidth: true
                                segments: 16
                                value: (root.backend && root.backend.media && root.backend.media.length > 0)
                                    ? Math.min(1.0, root.backend.media.position / root.backend.media.length)
                                    : 0.0
                                tone: (root.backend && root.backend.media && root.backend.media.playing) ? "signal" : "muted"
                                reducedMotion: root.reducedMotion
                            }

                            RowLayout {
                                visible: root.backend && root.backend.media && root.backend.media.hasPlayer
                                Layout.fillWidth: true
                                spacing: Tokens.spaceXs

                                Text {
                                    text: root.backend && root.backend.media
                                        ? (root._formatMediaSec(root.backend.media.position) + " / " + root._formatMediaSec(root.backend.media.length))
                                        : "00:00 / 00:00"
                                    color: Tokens.muted
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                }

                                Item { Layout.fillWidth: true }

                                TacticalButton {
                                    text: ""
                                    iconName: "chevron-left"
                                    enabledState: root.backend && root.backend.media && root.backend.media.canPrev
                                    implicitWidth: 34
                                    implicitHeight: Tokens.controlHeightSm
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.backend && root.backend.media) root.backend.media.previous()
                                }

                                TacticalButton {
                                    text: (root.backend && root.backend.media && root.backend.media.playing) ? "PAUSE" : "PLAY"
                                    iconName: (root.backend && root.backend.media && root.backend.media.playing) ? "pause" : "play"
                                    variant: "primary"
                                    enabledState: root.backend && root.backend.media && (root.backend.media.playing ? root.backend.media.canPause : root.backend.media.canPlay)
                                    implicitWidth: 84
                                    implicitHeight: Tokens.controlHeightSm
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.backend && root.backend.media) root.backend.media.togglePlay()
                                }

                                TacticalButton {
                                    text: ""
                                    iconName: "chevron-right"
                                    enabledState: root.backend && root.backend.media && root.backend.media.canNext
                                    implicitWidth: 34
                                    implicitHeight: Tokens.controlHeightSm
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.backend && root.backend.media) root.backend.media.next()
                                }
                            }
                        }
                    }

                    HudDivider { Layout.fillWidth: true }

                    // Network & Bluetooth status toggles
                    TacticalToggle {
                        Layout.fillWidth: true
                        label: "WIRELESS NETWORK"
                        sublabel: !root.backend.network.available
                            ? "NETWORKMANAGER UNAVAILABLE"
                            : (root.backend.network.errorMessage !== ""
                                ? root.backend.network.errorMessage
                                : (root.backend.network.connected ? (root.backend.network.ssid + " (" + root.backend.network.signalStrength + "%)") : "DISCONNECTED"))
                        iconName: root.backend.network.connected ? "wifi" : "wifi-off"
                        checked: root.backend.network.wifiEnabled && root.backend.network.connected
                        enabledState: root.backend.network.available
                        reducedMotion: root.reducedMotion
                        onToggled: root.backend.network.toggleWifi()
                    }

                    TacticalToggle {
                        Layout.fillWidth: true
                        label: "BLUETOOTH ADAPTER"
                        sublabel: !root.backend.bluetooth.available
                            ? "HARDWARE ADAPTER ABSENT"
                            : (root.backend.bluetooth.powered
                                ? (root.backend.bluetooth.connectedDevice !== "" ? root.backend.bluetooth.connectedDevice : "POWERED // NO DEVICE")
                                : "RADIO DISABLED")
                        iconName: root.backend.bluetooth.powered ? "bluetooth" : "bluetooth-off"
                        checked: root.backend.bluetooth.powered
                        enabledState: root.backend.bluetooth.available
                        reducedMotion: root.reducedMotion
                        onToggled: root.backend.bluetooth.togglePower()
                    }

                    // Power & Battery telemetry
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: batCol.implicitHeight + Tokens.spaceSm * 2
                        color: Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: (root.backend.battery.available && root.backend.battery.percentage <= 15 && !root.backend.battery.charging)
                            ? Tokens.alert : Tokens.borderSubtle

                        ColumnLayout {
                            id: batCol
                            anchors.fill: parent
                            anchors.margins: Tokens.spaceSm
                            spacing: Tokens.spaceXs

                            RowLayout {
                                Layout.fillWidth: true
                                TacticalIcon {
                                    iconName: root.backend.battery.charging ? "battery-charging" : "battery"
                                    iconSize: 15
                                    color: root.backend.battery.available ? Tokens.signal : Tokens.muted
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: root.backend.battery.available
                                        ? ("POWER // " + root.backend.battery.percentage + "% (" + root.backend.battery.stateLabel + ")")
                                        : "POWER // AC DIRECT (NO BATTERY)"
                                    color: Tokens.text
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontLabel
                                    font.bold: true
                                }
                                Text {
                                    visible: root.backend.battery.available && root.backend.battery.timeRemaining !== ""
                                    text: root.backend.battery.timeRemaining
                                    color: Tokens.muted
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                }
                            }

                            RowLayout {
                                visible: root.backend.battery.available
                                Layout.fillWidth: true
                                spacing: Tokens.spaceXs
                                Repeater {
                                    model: ["power-saver", "balanced", "performance"]
                                    delegate: TacticalButton {
                                        id: profDel
                                        required property string modelData
                                        Layout.fillWidth: true
                                        text: profDel.modelData.toUpperCase()
                                        active: root.backend.battery.powerProfile === profDel.modelData
                                        variant: root.backend.battery.powerProfile === profDel.modelData ? "primary" : "default"
                                        implicitHeight: Tokens.controlHeightSm
                                        reducedMotion: root.reducedMotion
                                        onClicked: root.backend.battery.setPowerProfile(profDel.modelData)
                                    }
                                }
                            }
                        }
                    }

                    HudDivider { Layout.fillWidth: true }

                    // Corporate Faction Theme Selector (Marathon Graphic Realism)
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: factionCol.implicitHeight + Tokens.spaceSm * 2
                        color: Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: Tokens.borderSubtle

                        ColumnLayout {
                            id: factionCol
                            anchors.fill: parent
                            anchors.margins: Tokens.spaceSm
                            spacing: Tokens.spaceXs

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: "FACTION PROTOCOL // " + Tokens.factionId
                                    color: Tokens.signal
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: true
                                }
                                Text {
                                    text: "ACCENT MATRIX"
                                    color: Tokens.muted
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: Tokens.spaceXs
                                rowSpacing: Tokens.spaceXs

                                Repeater {
                                    model: Tokens.factions
                                    delegate: TacticalButton {
                                        id: facBtn
                                        required property var modelData
                                        Layout.fillWidth: true
                                        text: facBtn.modelData.id
                                        active: Tokens.factionId === facBtn.modelData.id
                                        variant: Tokens.factionId === facBtn.modelData.id ? "primary" : "default"
                                        implicitHeight: Tokens.controlHeightSm
                                        reducedMotion: root.reducedMotion
                                        onClicked: {
                                            Tokens.setFaction(facBtn.modelData.id)
                                            root.backend.appearance.setFaction(facBtn.modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Session UI toggles (DND, Reduced Motion, Fullscreen HUD)
                    TacticalToggle {
                        Layout.fillWidth: true
                        label: "DO NOT DISTURB"
                        sublabel: root.backend.notifications.dnd ? "SUPPRESS POPUP TOASTS" : "NOTIFICATIONS LIVE"
                        iconName: root.backend.notifications.dnd ? "bell-off" : "bell"
                        checked: root.backend.notifications.dnd
                        enabledState: root.backend.notifications.available
                        reducedMotion: root.reducedMotion
                        onToggled: root.backend.notifications.toggleDnd()
                    }

                    TacticalToggle {
                        Layout.fillWidth: true
                        label: "REDUCED MOTION"
                        sublabel: root.backend.appearance.reducedMotion ? "STATIC TRANSITIONS (0 MS)" : "SMOOTH HUD MOTION"
                        iconName: "settings"
                        checked: root.backend.appearance.reducedMotion
                        reducedMotion: root.reducedMotion
                        onToggled: root.backend.appearance.toggleReducedMotion()
                    }
                }
            }

            // Tactical utilities quick launcher row
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceXs

                TacticalButton {
                    Layout.fillWidth: true
                    text: "CLIP"
                    iconName: "clipboard"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.openClipboardRequested()
                }
                TacticalButton {
                    Layout.fillWidth: true
                    text: "CAPTURE"
                    iconName: "capture"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.openCaptureRequested()
                }
                TacticalButton {
                    Layout.fillWidth: true
                    text: "MONITOR"
                    iconName: "cpu"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.openSysmonRequested()
                }
                TacticalButton {
                    Layout.fillWidth: true
                    text: "KEYS"
                    iconName: "help"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.openCheatsheetRequested()
                }
            }

            // Bottom quick action bar
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceXs

                TacticalButton {
                    Layout.fillWidth: true
                    text: "NOTIFS (" + root.backend.notifications.items.length + ")"
                    iconName: "bell"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.openNotificationsRequested()
                }

                TacticalButton {
                    text: "SETTINGS"
                    iconName: "settings"
                    variant: "primary"
                    implicitHeight: Tokens.controlHeightSm
                    implicitWidth: 98
                    reducedMotion: root.reducedMotion
                    onClicked: root.openSettingsRequested()
                }

                TacticalButton {
                    text: "SESSION"
                    iconName: "power"
                    variant: "danger"
                    implicitHeight: Tokens.controlHeightSm
                    implicitWidth: 92
                    reducedMotion: root.reducedMotion
                    onClicked: root.openSessionRequested()
                }
            }
        }
    }
}
