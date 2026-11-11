pragma ComponentBehavior: Bound
import QtQuick
import "../tokens"

Rectangle {
    id: root

    property string text: "ONLINE"
    property string tone: "signal" // "signal" | "neutral" | "alert" | "warning" | "muted"
    property bool showDot: false

    implicitWidth: row.implicitWidth + Tokens.spaceMd
    implicitHeight: Tokens.spaceLg + Tokens.spaceXs
    radius: Tokens.radiusNone
    border.width: Tokens.borderWidth
    border.color: {
        if (tone === "alert") return Tokens.alert
        if (tone === "warning") return Tokens.warning
        if (tone === "signal") return Tokens.borderStrong
        if (tone === "muted") return Tokens.borderSubtle
        return Tokens.border
    }
    color: {
        if (tone === "alert") return Tokens.alertSurface
        if (tone === "warning") return Tokens.surfaceElevated
        if (tone === "signal") return Tokens.signalSubtle
        return Tokens.surfacePressed
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Tokens.spaceXs

        Rectangle {
            visible: root.showDot
            anchors.verticalCenter: parent.verticalCenter
            width: Tokens.spaceXs
            height: Tokens.spaceXs
            color: labelText.color
        }

        Text {
            id: labelText
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontMicro
            font.bold: true
            color: {
                if (root.tone === "alert") return Tokens.alert
                if (root.tone === "warning") return Tokens.warning
                if (root.tone === "signal") return Tokens.signal
                if (root.tone === "muted") return Tokens.muted
                return Tokens.text
            }
        }
    }
}

