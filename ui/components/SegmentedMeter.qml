pragma ComponentBehavior: Bound
import QtQuick
import "../tokens"

Item {
    id: root

    property real value: 0.5 // 0.0 .. 1.0
    property int segments: 12
    property string tone: "signal" // "signal" | "alert" | "muted"
    property bool enabledState: true
    property bool reducedMotion: false

    implicitWidth: 160
    implicitHeight: 12

    readonly property int filledCount: Math.round(Math.max(0.0, Math.min(1.0, value)) * segments)

    Row {
        id: segRow
        anchors.fill: parent
        spacing: Tokens.space2xs

        Repeater {
            model: root.segments
            delegate: Rectangle {
                id: segDel
                required property int index
                readonly property bool isLit: segDel.index < root.filledCount
                width: Math.max(2, (segRow.width - (root.segments - 1) * Tokens.space2xs) / root.segments)
                height: segRow.height
                border.width: Tokens.borderWidth
                border.color: {
                    if (!root.enabledState) return Tokens.borderSubtle
                    if (segDel.isLit) {
                        if (root.tone === "alert") return Tokens.alert
                        if (root.tone === "muted") return Tokens.muted
                        return Tokens.signal
                    }
                    return Tokens.borderSubtle
                }
                color: {
                    if (!root.enabledState) return Tokens.surfacePressed
                    if (segDel.isLit) {
                        if (root.tone === "alert") return Tokens.alert
                        if (root.tone === "muted") return Tokens.muted
                        return Tokens.signal
                    }
                    return Tokens.surfacePressed
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Tokens.motionMs(Tokens.durationFast, root.reducedMotion)
                    }
                }
            }
        }
    }
}

