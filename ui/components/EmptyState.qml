pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    property string code: "EMPTY"
    property string title: "NO DATA"
    property string detail: ""
    property string iconName: "warning"
    property bool alertTone: false

    implicitWidth: 260
    implicitHeight: col.implicitHeight + Tokens.spaceXl
    color: alertTone ? Tokens.alertSurface : Tokens.surfacePressed
    border.width: Tokens.borderWidth
    border.color: alertTone ? Tokens.alert : Tokens.borderSubtle

    ColumnLayout {
        id: col
        anchors.centerIn: parent
        width: Math.max(120, parent.width - Tokens.spaceXl)
        spacing: Tokens.spaceXs

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spaceSm

            TacticalIcon {
                anchors.verticalCenter: parent.verticalCenter
                iconName: root.iconName
                iconSize: 16
                color: root.alertTone ? Tokens.alert : Tokens.muted
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "[ " + root.code + " ]"
                color: root.alertTone ? Tokens.alert : Tokens.muted
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontLabel
                font.bold: true
            }
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.title
            color: Tokens.text
            font.family: Tokens.fontUi
            font.pixelSize: Tokens.fontBody
            font.bold: true
            wrapMode: Text.Wrap
        }

        Text {
            visible: root.detail !== ""
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.detail
            color: Tokens.muted
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontMicro
            wrapMode: Text.Wrap
        }
    }
}

