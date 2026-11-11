pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

RowLayout {
    id: root

    required property var activeWindow
    property bool compact: false

    spacing: Tokens.spaceSm
    clip: true

    TextMetrics {
        id: appMetrics
        font.family: Tokens.fontMono
        font.pixelSize: Tokens.fontMicro
        text: root.activeWindow ? root.activeWindow.appId.toUpperCase() : ""
    }

    Rectangle {
        visible: root.activeWindow && root.activeWindow.available && root.activeWindow.appId !== "" && !root.compact
        Layout.preferredWidth: visible ? Math.min(130, appMetrics.advanceWidth + Tokens.spaceSm * 2) : 0
        Layout.minimumWidth: visible ? Math.min(72, appMetrics.advanceWidth + Tokens.spaceSm * 2) : 0
        Layout.preferredHeight: 20
        color: Tokens.surfacePressed
        border.width: Tokens.borderWidth
        border.color: Tokens.borderSubtle

        Text {
            id: appBadgeTxt
            anchors.centerIn: parent
            width: Math.max(20, parent.width - Tokens.spaceSm)
            horizontalAlignment: Text.AlignHCenter
            text: appMetrics.text
            color: Tokens.muted
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontMicro
            elide: Text.ElideRight
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.minimumWidth: 60
        text: (root.activeWindow && root.activeWindow.available && root.activeWindow.title !== "")
            ? root.activeWindow.title
            : "IDLE // NO ACTIVE WINDOW"
        color: (root.activeWindow && root.activeWindow.available) ? Tokens.text : Tokens.muted
        font.family: Tokens.fontUi
        font.pixelSize: Tokens.fontBody
        elide: Text.ElideRight
    }

    StatusPill {
        visible: root.activeWindow && root.activeWindow.floating
        Layout.preferredWidth: visible ? implicitWidth : 0
        Layout.minimumWidth: visible ? implicitWidth : 0
        text: "FLT"
        tone: "signal"
    }

    StatusPill {
        visible: root.activeWindow && root.activeWindow.fullscreen
        Layout.preferredWidth: visible ? implicitWidth : 0
        Layout.minimumWidth: visible ? implicitWidth : 0
        text: "FS"
        tone: "warning"
    }
}
