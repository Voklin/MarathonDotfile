pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    required property var session
    required property var appearance
    property var settings: null
    property bool reducedMotion: appearance ? appearance.reducedMotion : false
    readonly property bool lockActive: session ? session.locked : false
    readonly property bool showSpecimen: settings ? settings.lockShowHostSpecimen : true

    visible: lockActive || opacity > 0.01
    opacity: lockActive ? 1.0 : 0.0
    color: Tokens.voidBg

    Behavior on opacity {
        NumberAnimation {
            duration: Tokens.motionMs(Tokens.durationPanel, root.reducedMotion)
            easing.type: Tokens.easingType
        }
    }

    onLockActiveChanged: {
        if (lockActive) passInput.focusInput()
    }

    // Perimeter tactical lock framing (synced with design/wallpapers/marathon-lock-3840x2160.svg)
    Rectangle {
        id: frameRect
        anchors.fill: parent
        anchors.margins: Tokens.spaceXl
        color: "transparent"
        border.width: Tokens.borderWidth
        border.color: Tokens.borderSubtle

        // Four corner registration brackets
        Rectangle { width: 22; height: 2; color: Tokens.signal; anchors.top: parent.top; anchors.left: parent.left }
        Rectangle { width: 2; height: 22; color: Tokens.signal; anchors.top: parent.top; anchors.left: parent.left }

        Rectangle { width: 22; height: 2; color: Tokens.signal; anchors.top: parent.top; anchors.right: parent.right }
        Rectangle { width: 2; height: 22; color: Tokens.signal; anchors.top: parent.top; anchors.right: parent.right }

        Rectangle { width: 22; height: 2; color: Tokens.borderStrong; anchors.bottom: parent.bottom; anchors.left: parent.left }
        Rectangle { width: 2; height: 22; color: Tokens.borderStrong; anchors.bottom: parent.bottom; anchors.left: parent.left }

        Rectangle { width: 22; height: 2; color: Tokens.borderStrong; anchors.bottom: parent.bottom; anchors.right: parent.right }
        Rectangle { width: 2; height: 22; color: Tokens.borderStrong; anchors.bottom: parent.bottom; anchors.right: parent.right }

        // Top Marathon 2-row Pixel-Checkerboard Decal Ribbon (from Grey Decal Sheet)
        Canvas {
            id: topCheckerDecal
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: 240
            height: 10
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = ((root.session && root.session.authError !== "") ? Tokens.alert : Tokens.borderStrong).toString()
                for (var i = 0; i < 40; ++i) {
                    var y = (i % 2 === 0) ? 0 : 5
                    ctx.fillRect(i * 6, y, 5, 4)
                }
            }
        }
    }

    // Top status strip
    RowLayout {
        anchors.top: frameRect.top
        anchors.left: frameRect.left
        anchors.right: frameRect.right
        anchors.margins: Tokens.spaceMd
        spacing: Tokens.spaceSm

        StatusPill {
            text: "LOCK // SECURE SESSION"
            tone: (root.session && root.session.authError !== "") ? "alert" : "signal"
            showDot: true
        }

        Item { Layout.fillWidth: true }

        Text {
            visible: root.showSpecimen
            text: (root.session ? (root.session.userName || "RUNNER").toUpperCase() : "RUNNER")
                + "@"
                + (root.session ? (root.session.hostName || "HOST").toUpperCase() : "HOST")
            color: Tokens.muted
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontMicro
        }
    }

    // Bottom status strip (Marathon Runner Shell perimeter telemetry)
    RowLayout {
        anchors.bottom: frameRect.bottom
        anchors.left: frameRect.left
        anchors.right: frameRect.right
        anchors.margins: Tokens.spaceMd
        spacing: Tokens.spaceSm

        Text {
            text: "SECTOR // 04-TAU.IV // PAM.GUARD"
            color: Tokens.muted
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontMicro
        }

        Item { Layout.fillWidth: true }

        Text {
            text: "AUTH.PROTOCOL // HYPRLOCK-VERIFY"
            color: Tokens.signalMuted
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontMicro
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(460, parent.width - Tokens.space2xl * 2)
        spacing: Tokens.spaceMd

        // Runner Calling Card & Emblem Banner (Marathon + Destiny 2 Nameplate)
        RunnerEmblemCard {
            visible: root.showSpecimen
            Layout.fillWidth: true
            compact: false
            showSelector: false
            runnerName: root.session ? (root.session.userName || "RUNNER") : "RUNNER"
            reducedMotion: root.reducedMotion
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spaceMd

            Rectangle {
                width: 24
                height: 2
                color: Tokens.borderStrong
            }

            Text {
                text: root.appearance ? root.appearance.clockText : "00:00:00"
                color: Tokens.text
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontHero
                font.bold: true
            }

            Rectangle {
                width: 24
                height: 2
                color: Tokens.borderStrong
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: (root.appearance ? root.appearance.dateText : "")
                + " // "
                + (root.appearance ? root.appearance.sysLabel : "SYS // LOCKED")
            color: Tokens.muted
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontLabel
        }

        TacticalPanel {
            Layout.fillWidth: true
            code: "PASSKEY // PAM"
            title: "UNLOCK WORKSTATION"
            statusText: (root.session && root.session.authError !== "") ? "REJECTED" : "GUARDED"
            statusTone: (root.session && root.session.authError !== "") ? "alert" : "signal"
            alertState: root.session && root.session.authError !== ""

            TacticalTextField {
                id: passInput
                Layout.fillWidth: true
                passwordMode: true
                placeholderText: "ENTER PASSPHRASE (PREVIEW: marathon)..."
                errorText: root.session ? root.session.authError : ""
                onTextSubmitted: {
                    if (root.session.unlock(passInput.text)) {
                        passInput.text = ""
                    }
                }
            }

            TacticalButton {
                Layout.fillWidth: true
                text: "AUTHENTICATE"
                iconName: "lock"
                variant: "primary"
                reducedMotion: root.reducedMotion
                onClicked: {
                    if (root.session.unlock(passInput.text)) {
                        passInput.text = ""
                    }
                }
            }
        }
    }
}
