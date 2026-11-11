pragma ComponentBehavior: Bound
import QtQuick
import "../tokens"

Row {
    id: root

    required property var workspaces
    property string monitorFilter: ""
    property bool reducedMotion: false

    spacing: Tokens.spaceXs

    readonly property var visibleItems: {
        var src = (workspaces && workspaces.items) ? workspaces.items : []
        if (monitorFilter === "") return src
        var out = []
        for (var i = 0; i < src.length; ++i) {
            if (!src[i].monitor || src[i].monitor === monitorFilter) out.push(src[i])
        }
        return out.length > 0 ? out : src
    }

    Repeater {
        model: root.visibleItems
        delegate: Rectangle {
            id: wsCell
            required property var modelData
            readonly property bool hovered: wsMouse.containsMouse

            width: wsCell.modelData.active ? 34 : 28
            height: Tokens.controlHeightSm
            color: {
                if (wsCell.modelData.active) return Tokens.signal
                if (wsCell.modelData.urgent) return Tokens.alertSurface
                if (wsCell.hovered) return Tokens.surfaceElevated
                if (wsCell.modelData.occupied) return Tokens.surface
                return Tokens.surfacePressed
            }
            border.width: activeFocus ? Tokens.focusBorderWidth : Tokens.borderWidth
            border.color: {
                if (activeFocus) return Tokens.signal
                if (wsCell.modelData.urgent) return Tokens.alert
                if (wsCell.modelData.active) return Tokens.signal
                if (wsCell.modelData.occupied) return Tokens.borderStrong
                return Tokens.borderSubtle
            }
            activeFocusOnTab: true

            Behavior on width {
                NumberAnimation {
                    duration: Tokens.motionMs(Tokens.durationFast, root.reducedMotion)
                    easing.type: Tokens.easingType
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Tokens.motionMs(Tokens.durationFast, root.reducedMotion)
                }
            }

            Text {
                anchors.centerIn: parent
                text: wsCell.modelData.name
                color: {
                    if (wsCell.modelData.active) return Tokens.textOnSignal
                    if (wsCell.modelData.urgent) return Tokens.alert
                    if (wsCell.modelData.occupied) return Tokens.text
                    return Tokens.muted
                }
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontLabel
                font.bold: wsCell.modelData.active || wsCell.modelData.urgent
            }

            // Active workspace Marathon brutalist corner notch & registration dot
            Rectangle {
                visible: wsCell.modelData.active
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 2
                width: 3
                height: 3
                color: Tokens.textOnSignal
            }

            Canvas {
                visible: wsCell.modelData.active
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 6
                height: 6
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.fillStyle = Tokens.textOnSignal.toString()
                    ctx.beginPath()
                    ctx.moveTo(width, 0)
                    ctx.lineTo(width, height)
                    ctx.lineTo(0, height)
                    ctx.closePath()
                    ctx.fill()
                }
            }

            // Bottom occupancy indicator strip for non-active occupied workspaces
            Rectangle {
                visible: !wsCell.modelData.active && (wsCell.modelData.occupied || wsCell.modelData.urgent)
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 3
                anchors.rightMargin: 3
                height: 2
                color: wsCell.modelData.urgent ? Tokens.alert : Tokens.signalMuted
            }

            Keys.onReturnPressed: root.workspaces.switchWorkspace(wsCell.modelData.id)
            Keys.onSpacePressed: root.workspaces.switchWorkspace(wsCell.modelData.id)

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.workspaces.switchWorkspace(wsCell.modelData.id)
            }
        }
    }
}

