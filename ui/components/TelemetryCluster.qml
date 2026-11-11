pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

RowLayout {
    id: root

    required property var audio
    required property var network
    required property var bluetooth
    required property var battery
    required property var notifications
    property var settings: null
    property bool compact: false
    property bool controlCenterOpen: false
    property bool notificationsOpen: false
    property bool settingsOpen: false
    property bool reducedMotion: false

    signal controlCenterRequested()
    signal notificationsRequested()
    signal settingsRequested()

    readonly property bool showNet: settings ? settings.showNetworkPill : true
    readonly property bool showAud: settings ? settings.showAudioPill : true
    readonly property bool showBat: settings ? settings.showBatteryPill : true

    spacing: Tokens.spaceXs

    // Network telemetry chip
    Rectangle {
        id: netChip
        visible: root.showNet
        readonly property bool isOffline: !root.network || !root.network.available || !root.network.connected
        readonly property string labelStr: {
            if (!root.network || !root.network.available) return "NET:N/A"
            if (!root.network.connected) return "OFFLINE"
            if (root.network.connectionType === "ethernet") return "ETH"
            return root.network.ssid
        }
        Layout.preferredWidth: visible ? (netRow.implicitWidth + Tokens.spaceSm * 2) : 0
        Layout.minimumWidth: Layout.preferredWidth
        Layout.preferredHeight: Tokens.controlHeightSm
        color: isOffline ? Tokens.alertSurface : Tokens.surfacePressed
        border.width: Tokens.borderWidth
        border.color: isOffline ? Tokens.alert : Tokens.borderSubtle

        RowLayout {
            id: netRow
            anchors.centerIn: parent
            spacing: Tokens.spaceXs

            TacticalIcon {
                iconName: netChip.isOffline ? "wifi-off" : (root.network.connectionType === "ethernet" ? "ethernet" : "wifi")
                iconSize: 13
                color: netChip.isOffline ? Tokens.alert : Tokens.signal
            }

            Text {
                visible: !root.compact || netChip.isOffline
                Layout.maximumWidth: 96
                text: netChip.labelStr
                color: netChip.isOffline ? Tokens.alert : Tokens.text
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
                font.bold: netChip.isOffline
                elide: Text.ElideRight
            }
        }
    }

    // Bluetooth telemetry chip (shown only when adapter exists)
    Rectangle {
        visible: root.bluetooth && root.bluetooth.available
        Layout.preferredWidth: visible ? (btRow.implicitWidth + Tokens.spaceSm * 2) : 0
        Layout.minimumWidth: Layout.preferredWidth
        Layout.preferredHeight: Tokens.controlHeightSm
        color: Tokens.surfacePressed
        border.width: Tokens.borderWidth
        border.color: (root.bluetooth && root.bluetooth.powered && root.bluetooth.connectedDevice !== "") ? Tokens.borderStrong : Tokens.borderSubtle

        RowLayout {
            id: btRow
            anchors.centerIn: parent
            spacing: Tokens.space2xs

            TacticalIcon {
                iconName: (root.bluetooth && root.bluetooth.powered) ? "bluetooth" : "bluetooth-off"
                iconSize: 13
                color: (root.bluetooth && root.bluetooth.powered) ? Tokens.signal : Tokens.muted
            }

            Text {
                visible: !root.compact && root.bluetooth && root.bluetooth.powered && root.bluetooth.connectedDevice !== ""
                text: "BT"
                color: Tokens.text
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
            }
        }
    }

    // Audio telemetry chip (click to mute/unmute, scroll to adjust volume)
    Rectangle {
        id: audioChip
        visible: root.showAud
        readonly property bool avail: root.audio && root.audio.available
        readonly property bool isMuted: !avail || root.audio.muted
        Layout.preferredWidth: visible ? (audRow.implicitWidth + Tokens.spaceSm * 2) : 0
        Layout.minimumWidth: Layout.preferredWidth
        Layout.preferredHeight: Tokens.controlHeightSm
        color: audMouse.containsMouse && avail ? Tokens.surfaceElevated : Tokens.surfacePressed
        border.width: activeFocus ? Tokens.focusBorderWidth : Tokens.borderWidth
        border.color: activeFocus ? Tokens.signal : Tokens.borderSubtle
        activeFocusOnTab: avail

        RowLayout {
            id: audRow
            anchors.centerIn: parent
            spacing: Tokens.spaceXs

            TacticalIcon {
                iconName: audioChip.isMuted ? "audio-muted" : "audio"
                iconSize: 13
                color: !audioChip.avail ? Tokens.textDisabled : (audioChip.isMuted ? Tokens.alert : Tokens.signal)
            }

            Text {
                text: !audioChip.avail ? "N/A" : (audioChip.isMuted ? "MUTE" : Math.round(root.audio.volume * 100) + "%")
                color: !audioChip.avail ? Tokens.textDisabled : (audioChip.isMuted ? Tokens.alert : Tokens.text)
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
                font.bold: true
            }
        }

        Keys.onReturnPressed: if (audioChip.avail) root.audio.toggleMute()
        Keys.onSpacePressed: if (audioChip.avail) root.audio.toggleMute()

        MouseArea {
            id: audMouse
            anchors.fill: parent
            enabled: audioChip.avail
            hoverEnabled: true
            cursorShape: audioChip.avail ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.audio.toggleMute()
            onWheel: function(wheel) {
                var step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                root.audio.setVolume(root.audio.volume + step)
                wheel.accepted = true
            }
        }
    }

    // Battery & power indicator
    Rectangle {
        id: batChip
        visible: root.showBat
        readonly property bool avail: root.battery && root.battery.available
        readonly property bool isLow: avail && root.battery.percentage <= 15 && !root.battery.charging
        Layout.preferredWidth: visible ? (batRow.implicitWidth + Tokens.spaceSm * 2) : 0
        Layout.minimumWidth: Layout.preferredWidth
        Layout.preferredHeight: Tokens.controlHeightSm
        color: isLow ? Tokens.alertSurface : Tokens.surfacePressed
        border.width: Tokens.borderWidth
        border.color: isLow ? Tokens.alert : (avail && root.battery.charging ? Tokens.borderStrong : Tokens.borderSubtle)

        RowLayout {
            id: batRow
            anchors.centerIn: parent
            spacing: Tokens.spaceXs

            TacticalIcon {
                visible: batChip.avail
                iconName: (root.battery && root.battery.charging) ? "battery-charging" : "battery"
                iconSize: 13
                color: batChip.isLow ? Tokens.alert : (root.battery && root.battery.charging ? Tokens.signal : Tokens.text)
            }

            Text {
                text: batChip.avail ? (root.battery.percentage + "%") : "AC"
                color: batChip.isLow ? Tokens.alert : (batChip.avail ? Tokens.text : Tokens.muted)
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
                font.bold: batChip.isLow
            }
        }
    }

    // Notifications / DND trigger
    TacticalButton {
        id: notifBtn
        text: (root.notifications && root.notifications.dnd)
            ? "DND"
            : ((root.notifications && root.notifications.unreadCount > 0) ? String(root.notifications.unreadCount) : "0")
        iconName: (root.notifications && root.notifications.dnd) ? "bell-off" : "bell"
        active: root.notificationsOpen
        variant: (root.notifications && root.notifications.unreadCount > 0 && !root.notifications.dnd && !root.notificationsOpen) ? "default" : "ghost"
        Layout.preferredWidth: Math.max(46, text.length * 7 + 30)
        Layout.minimumWidth: Layout.preferredWidth
        Layout.preferredHeight: Tokens.controlHeightSm
        reducedMotion: root.reducedMotion
        onClicked: root.notificationsRequested()
    }

    // Control Center trigger
    TacticalButton {
        id: ctrlBtn
        text: root.compact ? "" : "CTRL"
        iconName: "settings"
        active: root.controlCenterOpen
        variant: root.controlCenterOpen ? "primary" : "default"
        Layout.preferredWidth: root.compact ? 30 : 68
        Layout.minimumWidth: Layout.preferredWidth
        Layout.preferredHeight: Tokens.controlHeightSm
        reducedMotion: root.reducedMotion
        onClicked: root.controlCenterRequested()
    }

    // Settings Hub trigger (Super+,)
    TacticalButton {
        id: hubBtn
        text: root.compact ? "" : "HUB"
        iconName: "grid"
        active: root.settingsOpen
        variant: root.settingsOpen ? "primary" : "ghost"
        Layout.preferredWidth: root.compact ? 28 : 58
        Layout.minimumWidth: Layout.preferredWidth
        Layout.preferredHeight: Tokens.controlHeightSm
        reducedMotion: root.reducedMotion
        onClicked: root.settingsRequested()
    }
}
