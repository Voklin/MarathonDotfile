pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    property string label: "TOGGLE"
    property string sublabel: ""
    property string iconName: ""
    property bool checked: false
    property bool enabledState: true
    property bool reducedMotion: false

    signal toggled(bool nextChecked)

    readonly property bool hovered: mouseArea.containsMouse && enabledState

    activeFocusOnTab: enabledState
    implicitWidth: 220
    implicitHeight: sublabel !== "" ? 46 : Tokens.controlHeightLg
    radius: Tokens.radiusNone
    color: {
        if (!enabledState) return Tokens.surfacePressed
        if (hovered) return Tokens.surfaceElevated
        return Tokens.surface
    }
    border.width: activeFocus ? Tokens.focusBorderWidth : Tokens.borderWidth
    border.color: {
        if (!enabledState) return Tokens.borderSubtle
        if (activeFocus) return Tokens.signal
        if (checked) return Tokens.borderStrong
        return Tokens.border
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.spaceSm
        anchors.rightMargin: Tokens.spaceSm
        spacing: Tokens.spaceSm

        TacticalIcon {
            visible: root.iconName !== ""
            iconName: root.iconName
            iconSize: 16
            color: !root.enabledState ? Tokens.textDisabled : (root.checked ? Tokens.signal : Tokens.muted)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.label
                color: root.enabledState ? Tokens.text : Tokens.textDisabled
                font.family: Tokens.fontUi
                font.pixelSize: Tokens.fontBody
                font.bold: root.checked
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

        Rectangle {
            width: 44
            height: 20
            color: !root.enabledState ? Tokens.surfacePressed : (root.checked ? Tokens.signal : Tokens.surfacePressed)
            border.width: Tokens.borderWidth
            border.color: !root.enabledState ? Tokens.borderSubtle : (root.checked ? Tokens.signal : Tokens.border)

            Behavior on color {
                ColorAnimation {
                    duration: Tokens.motionMs(Tokens.durationFast, root.reducedMotion)
                }
            }

            Text {
                anchors.centerIn: parent
                text: !root.enabledState ? "N/A" : (root.checked ? "ON" : "OFF")
                color: !root.enabledState ? Tokens.textDisabled : (root.checked ? Tokens.textOnSignal : Tokens.muted)
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
                font.bold: true
            }
        }
    }

    function activateToggle() {
        if (!enabledState) return
        toggled(!checked)
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            activateToggle()
            event.accepted = true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabledState
        hoverEnabled: true
        cursorShape: root.enabledState ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            root.forceActiveFocus()
            root.activateToggle()
        }
    }
}

