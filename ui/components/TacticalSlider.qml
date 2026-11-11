pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    property string label: "LEVEL"
    property string iconName: "audio"
    property real value: 0.5 // 0.0 .. 1.0
    property real minValue: 0.0
    property real maxValue: 1.0
    property real stepSize: 0.05
    property bool mutedState: false
    property bool enabledState: true
    property bool reducedMotion: false

    signal valueEdited(real nextValue)
    signal iconClicked()

    readonly property real clampedNorm: Math.max(0.0, Math.min(1.0, (value - minValue) / Math.max(0.0001, maxValue - minValue)))

    activeFocusOnTab: enabledState
    implicitWidth: 280
    implicitHeight: 54
    radius: Tokens.cornerRadius
    color: Tokens.surface
    border.width: activeFocus ? Tokens.focusBorderWidth : Tokens.borderWidth
    border.color: activeFocus ? Tokens.signal : (enabledState ? Tokens.border : Tokens.borderSubtle)

    function commitNormalized(norm) {
        if (!enabledState) return
        var clamped = Math.max(0.0, Math.min(1.0, norm))
        var mapped = minValue + clamped * (maxValue - minValue)
        valueEdited(Math.round(mapped * 100) / 100.0)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Tokens.spaceSm
        spacing: Tokens.spaceXs

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spaceSm

            Rectangle {
                width: 22
                height: 22
                color: iconMouse.containsMouse && root.enabledState ? Tokens.surfaceElevated : "transparent"
                border.width: Tokens.borderWidth
                border.color: root.enabledState ? Tokens.borderSubtle : "transparent"

                TacticalIcon {
                    anchors.centerIn: parent
                    iconName: root.iconName
                    iconSize: 14
                    color: !root.enabledState ? Tokens.textDisabled : (root.mutedState ? Tokens.alert : Tokens.signal)
                }

                MouseArea {
                    id: iconMouse
                    anchors.fill: parent
                    enabled: root.enabledState
                    hoverEnabled: true
                    cursorShape: root.enabledState ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.iconClicked()
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.label
                color: root.enabledState ? Tokens.text : Tokens.textDisabled
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontLabel
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                width: 52
                horizontalAlignment: Text.AlignRight
                text: !root.enabledState ? "N/A" : (root.mutedState ? "MUTE" : Math.round(root.value * 100) + "%")
                color: !root.enabledState ? Tokens.textDisabled : (root.mutedState ? Tokens.alert : Tokens.signal)
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontLabel
                font.bold: true
            }
        }

        Item {
            id: trackBox
            Layout.fillWidth: true
            height: 16

            SegmentedMeter {
                anchors.fill: parent
                value: root.mutedState ? 0.0 : root.clampedNorm
                segments: 16
                tone: root.mutedState ? "muted" : "signal"
                enabledState: root.enabledState
                reducedMotion: root.reducedMotion
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.enabledState
                cursorShape: root.enabledState ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                onPressed: function(mouse) {
                    root.forceActiveFocus()
                    root.commitNormalized(mouse.x / Math.max(1, width))
                }
                onPositionChanged: function(mouse) {
                    if (pressed) root.commitNormalized(mouse.x / Math.max(1, width))
                }
                onWheel: function(wheel) {
                    var delta = wheel.angleDelta.y > 0 ? root.stepSize : -root.stepSize
                    root.commitNormalized(root.clampedNorm + delta)
                    wheel.accepted = true
                }
            }
        }
    }

    Keys.onLeftPressed: commitNormalized(clampedNorm - stepSize)
    Keys.onRightPressed: commitNormalized(clampedNorm + stepSize)
}

