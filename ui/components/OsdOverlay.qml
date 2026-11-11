pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Item {
    id: root

    required property var audio
    required property var brightness
    property var settings: null
    property bool reducedMotion: false

    readonly property bool osdEnabled: settings ? settings.osdEnabled : true
    readonly property int osdTimeoutMs: settings ? settings.osdDurationMs : 1600

    property bool active: false
    property string kind: "audio"
    property real level: 0.0
    property bool muted: false
    property string detail: ""

    implicitWidth: Tokens.osdWidth
    implicitHeight: 68
    width: Tokens.osdWidth
    height: 68
    visible: osdEnabled && (active || osdCard.opacity > 0.01)

    function trigger(nextKind, nextLevel, nextMuted, nextDetail) {
        if (!osdEnabled) return
        kind = nextKind
        level = nextLevel
        muted = nextMuted
        detail = nextDetail || ""
        active = true
        hideTimer.restart()
    }

    Connections {
        target: root.audio
        function onOsdTriggered(k, lvl, m, det) {
            root.trigger(k, lvl, m, det)
        }
    }

    Connections {
        target: root.brightness
        function onOsdTriggered(k, lvl, m, det) {
            root.trigger(k, lvl, m, det)
        }
    }

    Timer {
        id: hideTimer
        interval: root.osdTimeoutMs
        repeat: false
        onTriggered: root.active = false
    }

    Rectangle {
        id: osdCard
        anchors.fill: parent
        color: Tokens.surface
        border.width: Tokens.borderWidth
        border.color: root.muted ? Tokens.alert : Tokens.signal
        opacity: root.active ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.motionMs(Tokens.durationNormal, root.reducedMotion)
                easing.type: Tokens.easingType
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.spaceSm
            spacing: Tokens.spaceXs

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceSm

                TacticalIcon {
                    iconName: {
                        if (root.kind === "brightness") return "brightness"
                        if (root.kind === "mic") return root.muted ? "mic-muted" : "mic"
                        return root.muted ? "audio-muted" : "audio"
                    }
                    iconSize: 16
                    color: root.muted ? Tokens.alert : Tokens.signal
                }

                Text {
                    Layout.fillWidth: true
                    text: root.kind.toUpperCase() + (root.detail !== "" ? (" // " + root.detail) : "")
                    color: Tokens.text
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: 44
                    horizontalAlignment: Text.AlignRight
                    text: root.muted ? "MUTE" : (Math.round(root.level * 100) + "%")
                    color: root.muted ? Tokens.alert : Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontLabel
                    font.bold: true
                }
            }

            SegmentedMeter {
                Layout.fillWidth: true
                Layout.preferredHeight: 14
                value: root.muted ? 0.0 : root.level
                segments: 14
                tone: root.muted ? "alert" : "signal"
                reducedMotion: root.reducedMotion
            }
        }
    }
}

