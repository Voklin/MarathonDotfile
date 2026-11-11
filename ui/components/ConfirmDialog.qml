pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    property string actionName: "REBOOT"
    property string message: "Confirm destructive system operation."
    property bool reducedMotion: false

    signal confirmed()
    signal cancelled()

    color: Tokens.surfaceOverlay

    Keys.onEscapePressed: function(event) {
        root.cancelled()
        event.accepted = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelled()
    }

    MouseArea {
        anchors.fill: modalCard
    }

    TacticalPanel {
        id: modalCard
        anchors.centerIn: parent
        width: Math.min(440, parent.width - Tokens.spaceXl)
        code: "CONFIRMATION REQUIRED"
        title: "EXECUTE // " + root.actionName.toUpperCase()
        statusText: "DESTRUCTIVE"
        alertState: true

        Text {
            Layout.fillWidth: true
            text: root.message
            color: Tokens.text
            font.family: Tokens.fontUi
            font.pixelSize: Tokens.fontBody
            wrapMode: Text.Wrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spaceSm

            Item { Layout.fillWidth: true }

            TacticalButton {
                id: cancelBtn
                text: "CANCEL [ESC]"
                variant: "default"
                reducedMotion: root.reducedMotion
                onClicked: root.cancelled()
            }

            TacticalButton {
                id: confirmBtn
                text: "CONFIRM // " + root.actionName.toUpperCase()
                iconName: "warning"
                variant: "danger"
                reducedMotion: root.reducedMotion
                onClicked: root.confirmed()
            }
        }
    }
}
