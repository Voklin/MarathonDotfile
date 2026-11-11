pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    property string label: "CHOICE"
    property string sublabel: ""
    property var options: [] // [{ id: "...", label: "..." }]
    property string selectedId: ""
    property bool enabledState: true
    property bool reducedMotion: false
    property bool highlighted: false

    signal optionSelected(string id)

    implicitWidth: 340
    implicitHeight: contentCol.implicitHeight + Tokens.spaceSm * 2
    radius: Tokens.cornerRadius
    color: highlighted ? Tokens.surfaceElevated : (enabledState ? Tokens.surface : Tokens.surfacePressed)
    border.width: Tokens.borderWidth
    border.color: highlighted ? Tokens.signal : (enabledState ? Tokens.border : Tokens.borderSubtle)

    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: Tokens.spaceSm
        spacing: Tokens.spaceXs

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spaceSm

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
                text: root.sublabel
                color: Tokens.muted
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: Tokens.spaceXs

            Repeater {
                model: root.options
                delegate: TacticalButton {
                    id: optBtn
                    required property var modelData
                    readonly property bool isSelected: String(optBtn.modelData.id) === String(root.selectedId)
                    text: optBtn.modelData.label
                    active: optBtn.isSelected
                    variant: optBtn.isSelected ? "primary" : "default"
                    enabledState: root.enabledState
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.optionSelected(String(optBtn.modelData.id))
                }
            }
        }
    }
}
