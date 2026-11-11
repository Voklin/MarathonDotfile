pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    property string label: "SETTING"
    property string sublabel: ""
    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property real stepSize: 1
    property int decimals: 0
    property string unit: ""
    property bool enabledState: true
    property bool reducedMotion: false
    property bool highlighted: false

    signal valueEdited(real nextValue)

    function stepBy(delta) {
        if (!enabledState) return
        var factor = Math.pow(10, decimals)
        var next = Math.round((value + delta) * factor) / factor
        next = Math.max(minValue, Math.min(maxValue, next))
        valueEdited(next)
    }

    activeFocusOnTab: enabledState
    implicitWidth: 320
    implicitHeight: sublabel !== "" ? 50 : 40
    radius: Tokens.cornerRadius
    color: highlighted ? Tokens.surfaceElevated : (enabledState ? Tokens.surface : Tokens.surfacePressed)
    border.width: activeFocus ? Tokens.focusBorderWidth : Tokens.borderWidth
    border.color: {
        if (!enabledState) return Tokens.borderSubtle
        if (activeFocus || highlighted) return Tokens.signal
        return Tokens.border
    }

    Keys.onLeftPressed: stepBy(-stepSize)
    Keys.onRightPressed: stepBy(stepSize)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.spaceSm
        anchors.rightMargin: Tokens.spaceSm
        spacing: Tokens.spaceSm

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.label
                color: root.enabledState ? Tokens.text : Tokens.textDisabled
                font.family: Tokens.fontUi
                font.pixelSize: Tokens.fontBody
                font.bold: root.highlighted
                elide: Text.ElideRight
            }

            Text {
                visible: root.sublabel !== ""
                Layout.fillWidth: true
                text: root.sublabel
                color: root.enabledState ? Tokens.muted : Tokens.textDisabled
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
                elide: Text.ElideRight
            }
        }

        RowLayout {
            spacing: Tokens.spaceXs

            TacticalButton {
                text: "-"
                implicitWidth: 28
                implicitHeight: Tokens.controlHeightSm
                enabledState: root.enabledState && root.value > root.minValue + 0.0001
                reducedMotion: root.reducedMotion
                onClicked: root.stepBy(-root.stepSize)
            }

            Rectangle {
                implicitWidth: Math.max(66, valText.implicitWidth + Tokens.spaceMd)
                implicitHeight: Tokens.controlHeightSm
                radius: Tokens.cornerRadius
                color: Tokens.surfacePressed
                border.width: Tokens.borderWidth
                border.color: Tokens.borderStrong

                Text {
                    id: valText
                    anchors.centerIn: parent
                    text: (root.decimals > 0 ? root.value.toFixed(root.decimals) : String(Math.round(root.value))) + (root.unit !== "" ? (" " + root.unit) : "")
                    color: root.enabledState ? Tokens.signal : Tokens.textDisabled
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontLabel
                    font.bold: true
                }
            }

            TacticalButton {
                text: "+"
                implicitWidth: 28
                implicitHeight: Tokens.controlHeightSm
                enabledState: root.enabledState && root.value < root.maxValue - 0.0001
                reducedMotion: root.reducedMotion
                onClicked: root.stepBy(root.stepSize)
            }
        }
    }
}
