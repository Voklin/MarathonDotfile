pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    property string text: "ACTION"
    property string iconName: ""
    property string variant: "default" // "default" | "primary" | "danger" | "ghost"
    property bool active: false
    property bool enabledState: true
    property bool reducedMotion: false

    signal clicked()

    readonly property bool hovered: mouseArea.containsMouse && enabledState
    readonly property bool pressed: (mouseArea.pressed || keyPressed) && enabledState
    property bool keyPressed: false

    clip: true
    activeFocusOnTab: enabledState
    implicitWidth: Math.max(Tokens.controlHeightMd, contentRow.implicitWidth + Tokens.spaceLg)
    implicitHeight: Tokens.controlHeightMd
    radius: Tokens.cornerRadius

    color: {
        if (!enabledState) return Tokens.surfacePressed
        if (variant === "primary" || active) {
            return pressed ? Tokens.signalMuted : Tokens.signal
        }
        if (variant === "danger") {
            return pressed ? Tokens.alert : (hovered ? Tokens.alertSubtle : Tokens.alertSurface)
        }
        if (variant === "ghost") {
            return pressed ? Tokens.surfacePressed : (hovered ? Tokens.surfaceElevated : "transparent")
        }
        return pressed ? Tokens.surfacePressed : (hovered ? Tokens.surfaceElevated : Tokens.surface)
    }

    border.width: activeFocus ? Tokens.focusBorderWidth : Tokens.borderWidth
    border.color: {
        if (!enabledState) return Tokens.borderSubtle
        if (activeFocus) return Tokens.signal
        if (variant === "primary" || active) return Tokens.signal
        if (variant === "danger") return Tokens.alert
        if (hovered) return Tokens.borderStrong
        return variant === "ghost" ? Tokens.borderSubtle : Tokens.border
    }

    Behavior on color {
        ColorAnimation {
            duration: Tokens.motionMs(Tokens.durationFast, root.reducedMotion)
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        width: Math.min(implicitWidth, Math.max(0, root.width - Tokens.spaceSm))
        spacing: (root.iconName !== "" && root.text !== "") ? Tokens.spaceXs : 0

        TacticalIcon {
            visible: root.iconName !== ""
            Layout.alignment: Qt.AlignVCenter
            iconName: root.iconName
            iconSize: 14
            color: labelTxt.color
        }

        Text {
            id: labelTxt
            visible: root.text !== ""
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: root.text
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontLabel
            font.bold: root.variant === "primary" || root.active || root.variant === "danger"
            color: {
                if (!root.enabledState) return Tokens.textDisabled
                if (root.variant === "primary" || root.active) return Tokens.textOnSignal
                if (root.variant === "danger") return root.pressed ? Tokens.textOnSignal : Tokens.alert
                return Tokens.text
            }
        }
    }

    Keys.onPressed: function(event) {
        if (!root.enabledState) return
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.keyPressed = true
            event.accepted = true
        }
    }
    Keys.onReleased: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            if (root.keyPressed) {
                root.keyPressed = false
                if (root.enabledState) root.clicked()
            }
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
            root.clicked()
        }
    }
}
