pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Item {
    id: root

    required property var backend
    required property string activeSection
    property string searchQuery: ""
    property bool reducedMotion: false

    readonly property var s: backend ? backend.settings : null
    readonly property int contentHeight: {
        if (activeSection === "audio") return secAudio.implicitHeight
        if (activeSection === "connections") return secConnections.implicitHeight
        if (activeSection === "config") return secConfig.implicitHeight
        if (activeSection === "about") return secAbout.implicitHeight
        return 0
    }
    implicitHeight: contentHeight
    height: contentHeight
    property bool confirmResetAll: false
    property string jsonSnapshot: ""
    property string configPreviewTab: "hypr" // "hypr" | "apps" | "json"

    // =========================================================================
    // 14. AUDIO, BRIGHTNESS & POWER
    // =========================================================================
    ColumnLayout {
        id: secAudio
        visible: root.activeSection === "audio"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        TacticalSlider {
            Layout.fillWidth: true
            label: root.backend && root.backend.audio && root.backend.audio.available
                ? ("OUTPUT // " + root.backend.audio.sinkName)
                : "OUTPUT // PIPEWIRE UNAVAILABLE"
            iconName: (root.backend && root.backend.audio && root.backend.audio.muted) ? "audio-muted" : "audio"
            value: root.backend && root.backend.audio ? root.backend.audio.volume : 0.0
            mutedState: root.backend && root.backend.audio ? root.backend.audio.muted : true
            enabledState: root.backend && root.backend.audio ? root.backend.audio.available : false
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.backend && root.backend.audio) root.backend.audio.setVolume(v) }
            onIconClicked: { if (root.backend && root.backend.audio) root.backend.audio.toggleMute() }
        }

        TacticalSlider {
            Layout.fillWidth: true
            label: (root.backend && root.backend.audio && root.backend.audio.micAvailable)
                ? "INPUT // DEFAULT MICROPHONE"
                : "INPUT // NO MIC SOURCE"
            iconName: (root.backend && root.backend.audio && root.backend.audio.micMuted) ? "mic-muted" : "mic"
            value: root.backend && root.backend.audio ? root.backend.audio.micVolume : 0.0
            mutedState: root.backend && root.backend.audio ? root.backend.audio.micMuted : true
            enabledState: root.backend && root.backend.audio ? root.backend.audio.micAvailable : false
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.backend && root.backend.audio) root.backend.audio.setMicVolume(v) }
            onIconClicked: { if (root.backend && root.backend.audio) root.backend.audio.toggleMicMute() }
        }

        Repeater {
            model: root.backend && root.backend.audio ? root.backend.audio.sources : []
            delegate: TacticalButton {
                required property var modelData
                Layout.fillWidth: true
                text: "MIC // " + modelData.name
                active: modelData.active
                iconName: modelData.active ? "check" : "mic"
                onClicked: root.backend.audio.selectSource(modelData.id)
            }
        }

        Rectangle {
            visible: root.backend && root.backend.audio && root.backend.audio.available
            Layout.fillWidth: true
            implicitHeight: sinksCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.borderSubtle

            ColumnLayout {
                id: sinksCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "PIPEWIRE OUTPUT SINK ROUTING"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                Repeater {
                    model: root.backend && root.backend.audio ? root.backend.audio.sinks : []
                    delegate: TacticalButton {
                        id: sinkItem
                        required property var modelData
                        Layout.fillWidth: true
                        text: sinkItem.modelData.name
                        iconName: sinkItem.modelData.active ? "check" : "audio"
                        active: sinkItem.modelData.active
                        variant: sinkItem.modelData.active ? "primary" : "default"
                        implicitHeight: Tokens.controlHeightSm
                        reducedMotion: root.reducedMotion
                        onClicked: if (root.backend && root.backend.audio) root.backend.audio.selectSink(sinkItem.modelData.id)
                    }
                }
            }
        }

        HudDivider { Layout.fillWidth: true }

        TacticalSlider {
            Layout.fillWidth: true
            label: (root.backend && root.backend.brightness && root.backend.brightness.available)
                ? ("BACKLIGHT // " + root.backend.brightness.deviceName)
                : "BACKLIGHT // NO CONTROLLER"
            iconName: "brightness"
            value: root.backend && root.backend.brightness ? root.backend.brightness.level : 0.0
            minValue: 0.05
            enabledState: root.backend && root.backend.brightness ? root.backend.brightness.available : false
            reducedMotion: root.reducedMotion
            onValueEdited: function(v) { if (root.backend && root.backend.brightness) root.backend.brightness.setLevel(v) }
        }

        SettingsChoiceGroup {
            Layout.fillWidth: true
            label: "Power Profile (UPower / power-profiles-daemon)"
            sublabel: (root.backend && root.backend.battery && root.backend.battery.available)
                ? (root.backend.battery.percentage + "% " + root.backend.battery.stateLabel)
                : "AC DIRECT (NO BATTERY)"
            enabledState: root.backend && root.backend.battery ? root.backend.battery.available : false
            selectedId: root.backend && root.backend.battery ? root.backend.battery.powerProfile : "balanced"
            options: [
                { id: "power-saver", label: "POWER SAVER" },
                { id: "balanced", label: "BALANCED" },
                { id: "performance", label: "PERFORMANCE" }
            ]
            reducedMotion: root.reducedMotion
            onOptionSelected: function(id) { if (root.backend && root.backend.battery) root.backend.battery.setPowerProfile(id) }
        }
    }

    // =========================================================================
    // 15. CONNECTIONS (WI-FI NETWORKS & BLUETOOTH DEVICES)
    // =========================================================================
    ColumnLayout {
        id: secConnections
        visible: root.activeSection === "connections"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        TacticalButton {
            Layout.fillWidth: true
            text: "WI-FI SETUP / PASSWORD / HIDDEN NETWORK"
            iconName: "wifi"
            onClicked: root.backend.network.openManager()
        }
        TacticalButton {
            Layout.fillWidth: true
            text: "BLUETOOTH PAIR / PIN / TRUST"
            iconName: "bluetooth"
            onClicked: root.backend.bluetooth.openManager()
        }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Wi-Fi Radio (NetworkManager)"
            sublabel: {
                if (!root.backend || !root.backend.network || !root.backend.network.available) return "NETWORKMANAGER UNAVAILABLE"
                if (root.backend.network.errorMessage !== "") return root.backend.network.errorMessage
                if (root.backend.network.connected) return root.backend.network.ssid + " (" + root.backend.network.signalStrength + "%) // " + root.backend.network.ipAddress
                return root.backend.network.wifiEnabled ? "RADIO ON // DISCONNECTED" : "RADIO DISABLED"
            }
            iconName: (root.backend && root.backend.network && root.backend.network.connected) ? "wifi" : "wifi-off"
            checked: root.backend && root.backend.network ? root.backend.network.wifiEnabled : false
            enabledState: root.backend && root.backend.network ? root.backend.network.available : false
            reducedMotion: root.reducedMotion
            onToggled: if (root.backend && root.backend.network) root.backend.network.toggleWifi()
        }

        Rectangle {
            visible: root.backend && root.backend.network && root.backend.network.available && root.backend.network.wifiEnabled
            Layout.fillWidth: true
            implicitHeight: wifiCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surface
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            ColumnLayout {
                id: wifiCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "AVAILABLE WI-FI NETWORKS"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                Repeater {
                    model: root.backend && root.backend.network ? root.backend.network.networks : []
                    delegate: Rectangle {
                        id: netRow
                        required property var modelData
                        Layout.fillWidth: true
                        height: 34
                        color: netRow.modelData.connected ? Tokens.surfaceElevated : Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: netRow.modelData.connected ? Tokens.signal : Tokens.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceXs
                            spacing: Tokens.spaceSm

                            TacticalIcon {
                                iconName: "wifi"
                                iconSize: 14
                                color: netRow.modelData.connected ? Tokens.signal : Tokens.muted
                            }

                            Text {
                                Layout.fillWidth: true
                                text: netRow.modelData.ssid
                                color: Tokens.text
                                font.family: Tokens.fontUi
                                font.pixelSize: Tokens.fontBody
                                font.bold: netRow.modelData.connected
                                elide: Text.ElideRight
                            }

                            StatusPill {
                                text: netRow.modelData.secured ? "WPA" : "OPEN"
                                tone: "neutral"
                            }

                            Text {
                                text: netRow.modelData.signalStrength + "%"
                                color: Tokens.signal
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                            }

                            TacticalButton {
                                text: netRow.modelData.connected ? "DISCONNECT" : "CONNECT"
                                variant: netRow.modelData.connected ? "danger" : "primary"
                                implicitHeight: 24
                                implicitWidth: 94
                                reducedMotion: root.reducedMotion
                                onClicked: {
                                    if (!root.backend || !root.backend.network) return
                                    if (netRow.modelData.connected) root.backend.network.disconnect()
                                    else root.backend.network.connectNetwork(netRow.modelData.ssid)
                                }
                            }
                        }
                    }
                }
            }
        }

        HudDivider { Layout.fillWidth: true }

        TacticalToggle {
            Layout.fillWidth: true
            label: "Bluetooth Controller"
            sublabel: {
                if (!root.backend || !root.backend.bluetooth || !root.backend.bluetooth.available) return "BLUETOOTH ADAPTER ABSENT"
                if (!root.backend.bluetooth.powered) return "RADIO POWERED OFF"
                return root.backend.bluetooth.connectedDevice !== "" ? ("CONNECTED // " + root.backend.bluetooth.connectedDevice) : "POWERED // IDLE"
            }
            iconName: (root.backend && root.backend.bluetooth && root.backend.bluetooth.powered) ? "bluetooth" : "bluetooth-off"
            checked: root.backend && root.backend.bluetooth ? root.backend.bluetooth.powered : false
            enabledState: root.backend && root.backend.bluetooth ? root.backend.bluetooth.available : false
            reducedMotion: root.reducedMotion
            onToggled: if (root.backend && root.backend.bluetooth) root.backend.bluetooth.togglePower()
        }

        Rectangle {
            visible: root.backend && root.backend.bluetooth && root.backend.bluetooth.available && root.backend.bluetooth.powered
            Layout.fillWidth: true
            implicitHeight: btCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surface
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            ColumnLayout {
                id: btCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "BLUETOOTH DEVICES"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                Repeater {
                    model: root.backend && root.backend.bluetooth ? root.backend.bluetooth.devices : []
                    delegate: Rectangle {
                        id: btRow
                        required property var modelData
                        Layout.fillWidth: true
                        height: 34
                        color: btRow.modelData.connected ? Tokens.surfaceElevated : Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: btRow.modelData.connected ? Tokens.signal : Tokens.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceXs
                            spacing: Tokens.spaceSm

                            TacticalIcon {
                                iconName: "bluetooth"
                                iconSize: 14
                                color: btRow.modelData.connected ? Tokens.signal : Tokens.muted
                            }

                            Text {
                                Layout.fillWidth: true
                                text: btRow.modelData.name
                                color: Tokens.text
                                font.family: Tokens.fontUi
                                font.pixelSize: Tokens.fontBody
                                font.bold: btRow.modelData.connected
                                elide: Text.ElideRight
                            }

                            Text {
                                visible: btRow.modelData.battery >= 0
                                text: "BAT " + btRow.modelData.battery + "%"
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                            }

                            TacticalButton {
                                text: btRow.modelData.connected ? "DISCONNECT" : "CONNECT"
                                variant: btRow.modelData.connected ? "danger" : "primary"
                                implicitHeight: 24
                                implicitWidth: 94
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.backend && root.backend.bluetooth) root.backend.bluetooth.toggleDevice(btRow.modelData.address)
                            }
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // 16. CONFIG & ISOLATED OVERRIDES
    // =========================================================================
    ColumnLayout {
        id: secConfig
        visible: root.activeSection === "config"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: pathCol.implicitHeight + Tokens.spaceSm * 2
            radius: Tokens.cornerRadius
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.borderStrong

            ColumnLayout {
                id: pathCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                Text {
                    text: "ISOLATED PERSISTENCE PATHS (NEVER TOUCHES ~/.config/hypr/)"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }
                Text {
                    Layout.fillWidth: true
                    text: "SHELL JSON : " + (root.s ? root.s.settingsFilePath : "-")
                    color: Tokens.text
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    elide: Text.ElideMiddle
                }
                Text {
                    Layout.fillWidth: true
                    text: "HYPR CONF  : " + (root.s ? root.s.hyprOverridePath : "-")
                    color: Tokens.text
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    elide: Text.ElideMiddle
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spaceXs

            TacticalButton {
                Layout.fillWidth: true
                text: "APPLY & RELOAD HYPRLAND"
                iconName: "check"
                variant: "primary"
                implicitHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: if (root.s) root.s.applyAll()
            }

            TacticalButton {
                text: "RELOAD DISK"
                implicitHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: if (root.s) root.s.reloadConfig()
            }

            TacticalButton {
                text: "EXPORT JSON"
                implicitHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: {
                    if (root.s) {
                        root.jsonSnapshot = root.s.exportSettingsJson()
                        root.configPreviewTab = "json"
                    }
                }
            }

            TacticalButton {
                text: root.confirmResetAll ? "CONFIRM RESET ALL!" : "RESET ALL"
                variant: "danger"
                implicitHeight: Tokens.controlHeightSm
                reducedMotion: root.reducedMotion
                onClicked: {
                    if (!root.confirmResetAll) {
                        root.confirmResetAll = true
                    } else {
                        root.confirmResetAll = false
                        if (root.s) root.s.resetAllDefaults()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            radius: Tokens.cornerRadius
            color: Tokens.background
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.spaceSm
                spacing: Tokens.spaceXs

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs
                    Text {
                        Layout.fillWidth: true
                        text: root.configPreviewTab === "json"
                            ? "EXPORTED JSON SNAPSHOT"
                            : (root.configPreviewTab === "apps"
                                ? "LIVE SYNCED EXTERNAL APP THEMES (apps/generated/)"
                                : "LIVE GENERATED hypr/user-settings.conf")
                        color: Tokens.signal
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontMicro
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    TacticalButton {
                        text: "HYPR"
                        active: root.configPreviewTab === "hypr"
                        variant: active ? "primary" : "default"
                        implicitHeight: 20
                        reducedMotion: root.reducedMotion
                        onClicked: root.configPreviewTab = "hypr"
                    }
                    TacticalButton {
                        text: "APPS THEME"
                        active: root.configPreviewTab === "apps"
                        variant: active ? "primary" : "default"
                        implicitHeight: 20
                        reducedMotion: root.reducedMotion
                        onClicked: root.configPreviewTab = "apps"
                    }
                    TacticalButton {
                        visible: root.jsonSnapshot !== ""
                        text: "JSON"
                        active: root.configPreviewTab === "json"
                        variant: active ? "primary" : "default"
                        implicitHeight: 20
                        reducedMotion: root.reducedMotion
                        onClicked: root.configPreviewTab = "json"
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: codeTxt.implicitHeight
                    clip: true

                    Text {
                        id: codeTxt
                        width: parent.width
                        text: {
                            if (root.configPreviewTab === "json") return root.jsonSnapshot
                            if (root.configPreviewTab === "apps") return (root.s && root.s.generatedAppThemesPreview) ? root.s.generatedAppThemesPreview : ""
                            return root.s ? root.s.generatedHyprConf : ""
                        }
                        color: Tokens.text
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontMicro
                        wrapMode: Text.WrapAnywhere
                    }
                }
            }
        }
    }

    // =========================================================================
    // 17. DIAGNOSTICS & ABOUT
    // =========================================================================
    ColumnLayout {
        id: secAbout
        visible: root.activeSection === "about"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spaceSm

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: diagCol.implicitHeight + Tokens.spaceMd * 2
            radius: Tokens.cornerRadius
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.borderStrong

            ColumnLayout {
                id: diagCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceMd
                spacing: Tokens.spaceXs

                Text {
                    text: "SUBSYSTEM ADAPTER HEALTH MATRIX (16 CONTRACTS)"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                }

                Repeater {
                    model: root.backend ? [
                        { name: "Workspaces", obj: root.backend.workspaces },
                        { name: "ActiveWindow", obj: root.backend.activeWindow },
                        { name: "Audio (PipeWire)", obj: root.backend.audio },
                        { name: "Network (NM)", obj: root.backend.network },
                        { name: "Bluetooth (BlueZ)", obj: root.backend.bluetooth },
                        { name: "Battery (UPower)", obj: root.backend.battery },
                        { name: "Brightness", obj: root.backend.brightness },
                        { name: "Notifications", obj: root.backend.notifications },
                        { name: "Session / PAM", obj: root.backend.session },
                        { name: "Launcher", obj: root.backend.launcher },
                        { name: "Appearance", obj: root.backend.appearance },
                        { name: "Settings Hub", obj: root.backend.settings },
                        { name: "Media (MPRIS)", obj: root.backend.media },
                        { name: "Utilities (Wayland)", obj: root.backend.utilities },
                        { name: "Tray (SNI)", obj: root.backend.tray },
                        { name: "Keyboard (XKB)", obj: root.backend.keyboard }
                    ] : []
                    delegate: Rectangle {
                        id: diagRow
                        required property var modelData
                        required property int index
                        readonly property bool avail: diagRow.modelData.obj ? !!diagRow.modelData.obj.available : false
                        readonly property string err: (diagRow.modelData.obj && diagRow.modelData.obj.errorMessage) ? diagRow.modelData.obj.errorMessage : ""
                        Layout.fillWidth: true
                        height: 26
                        color: (diagRow.index % 2 === 0) ? Tokens.surfaceZebra : Tokens.surface

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceSm
                            spacing: Tokens.spaceSm

                            Text {
                                Layout.preferredWidth: 150
                                text: diagRow.modelData.name
                                color: Tokens.text
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                            }
                            StatusPill {
                                text: diagRow.avail ? "AVAILABLE" : "UNAVAILABLE"
                                tone: diagRow.avail ? "signal" : "warning"
                                showDot: diagRow.avail
                            }
                            Text {
                                Layout.fillWidth: true
                                text: diagRow.err !== "" ? diagRow.err : "NOMINAL"
                                color: diagRow.err !== "" ? Tokens.alert : Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: aboutCol.implicitHeight + Tokens.spaceMd * 2
            radius: Tokens.cornerRadius
            color: Tokens.surface
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            ColumnLayout {
                id: aboutCol
                anchors.fill: parent
                anchors.margins: Tokens.spaceMd
                spacing: Tokens.spaceXs

                Text {
                    text: "MARATHON TACTICAL // SETTINGS HUB v1.1"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontLabel
                    font.bold: true
                }
                Text {
                    Layout.fillWidth: true
                    text: "Modular 3-layer desktop shell (UI / State / Adapters) for CachyOS + Hyprland + Quickshell, with Windows QtQuick Preview parity and isolated config persistence. Inspired by the multi-section live Settings Hub architecture of ryoku-dev/ryoku."
                    color: Tokens.text
                    font.family: Tokens.fontUi
                    font.pixelSize: Tokens.fontBody
                    wrapMode: Text.Wrap
                }
                Text {
                    Layout.fillWidth: true
                    text: "License: MIT (code & original SVG/wallpapers) // Typography: SIL OFL 1.1 // Keybind: SUPER + ,"
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
