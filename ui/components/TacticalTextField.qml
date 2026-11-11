pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: "SEARCH..."
    property string promptPrefix: ">"
    property string errorText: ""
    property bool passwordMode: false
    property bool enabledState: true
    property alias inputItem: input

    signal textSubmitted()
    signal escapePressed()

    function focusInput() {
        input.forceActiveFocus()
    }

    function clearInput() {
        input.text = ""
        input.forceActiveFocus()
    }

    implicitWidth: 320
    implicitHeight: errorText !== "" ? (Tokens.controlHeightLg + 18) : Tokens.controlHeightLg
    radius: Tokens.cornerRadius
    color: enabledState ? Tokens.surfacePressed : Tokens.surface
    border.width: input.activeFocus ? Tokens.focusBorderWidth : Tokens.borderWidth
    border.color: {
        if (!enabledState) return Tokens.borderSubtle
        if (errorText !== "") return Tokens.alert
        if (input.activeFocus) return Tokens.signal
        return Tokens.border
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.spaceSm
        anchors.rightMargin: Tokens.spaceSm
        anchors.topMargin: Tokens.spaceXs
        anchors.bottomMargin: Tokens.spaceXs
        spacing: Tokens.space2xs

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Tokens.spaceSm

            Text {
                text: root.promptPrefix
                color: root.errorText !== "" ? Tokens.alert : (input.activeFocus ? Tokens.signal : Tokens.muted)
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontTitle
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: input.text === ""
                    text: root.placeholderText
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontBody
                    elide: Text.ElideRight
                }

                TextInput {
                    id: input
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    enabled: root.enabledState
                    color: root.enabledState ? Tokens.text : Tokens.textDisabled
                    selectionColor: Tokens.signal
                    selectedTextColor: Tokens.textOnSignal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontBody
                    echoMode: root.passwordMode ? TextInput.Password : TextInput.Normal
                    clip: true
                    onAccepted: root.textSubmitted()
                    Keys.onEscapePressed: function(event) {
                        root.escapePressed()
                        event.accepted = true
                    }
                }
            }

            TacticalButton {
                visible: input.text !== "" && root.enabledState
                text: "CLR"
                variant: "ghost"
                implicitHeight: Tokens.controlHeightSm
                implicitWidth: 40
                onClicked: root.clearInput()
            }
        }

        Text {
            visible: root.errorText !== ""
            Layout.fillWidth: true
            text: root.errorText
            color: Tokens.alert
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontMicro
            elide: Text.ElideRight
        }
    }
}

