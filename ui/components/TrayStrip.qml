pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

// System tray + active keyboard layout strip for the Tactical HUD.
// Data comes only through the `tray` / `keyboard` contracts (no Quickshell imports).
RowLayout {
    id: root

    property var tray: null
    property var keyboard: null
    property bool compact: false
    readonly property int maxVisible: compact ? 2 : 6
    property bool expanded: false

    // Emitted for right-click; the shell layer maps it to a native menu window.
    signal menuRequested(string itemId, real x, real y)

    readonly property var allItems: (tray && tray.available && tray.items) ? tray.items : []
    readonly property var shownItems: expanded ? allItems : allItems.slice(0, maxVisible)
    readonly property int hiddenCount: Math.max(0, allItems.length - shownItems.length)

    spacing: Tokens.spaceXs
    visible: allItems.length > 0 || (keyboard && keyboard.available)

    Repeater {
        model: root.shownItems
        delegate: Rectangle {
            id: cell
            required property var modelData
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            radius: Tokens.radiusSharp
            color: area.containsMouse ? Tokens.surfacePressed : "transparent"
            border.width: modelData.status === "attention" ? Tokens.borderWidth : 0
            border.color: Tokens.alert

            Image {
                id: icon
                anchors.centerIn: parent
                width: 16
                height: 16
                sourceSize: Qt.size(16, 16)
                source: cell.modelData.icon || ""
                visible: status === Image.Ready
                opacity: cell.modelData.status === "passive" ? 0.5 : 1.0
            }
            Text {
                anchors.centerIn: parent
                visible: !icon.visible
                text: String(cell.modelData.title || "?").substring(0, 1).toUpperCase()
                color: cell.modelData.status === "attention" ? Tokens.alert : Tokens.text
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontLabel
                font.bold: true
            }
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: function(mouse) {
                    if (!root.tray) return
                    if (mouse.button === Qt.RightButton) {
                        const p = cell.mapToItem(null, 0, cell.height)
                        root.menuRequested(cell.modelData.id, p.x, p.y)
                    } else if (mouse.button === Qt.MiddleButton) {
                        root.tray.secondaryActivate(cell.modelData.id)
                    } else {
                        root.tray.activate(cell.modelData.id)
                    }
                }
                onWheel: function(wheel) {
                    if (root.tray) root.tray.scroll(cell.modelData.id, wheel.angleDelta.y)
                }
            }
        }
    }

    TacticalButton {
        visible: root.hiddenCount > 0 || (root.expanded && root.allItems.length > root.maxVisible)
        text: root.expanded ? "−" : ("+" + root.hiddenCount)
        variant: "ghost"
        Layout.preferredHeight: 22
        Layout.preferredWidth: implicitWidth
        onClicked: root.expanded = !root.expanded
    }

    TacticalButton {
        id: layoutBadge
        visible: root.keyboard && root.keyboard.available
        text: root.keyboard ? root.keyboard.shortCode : "--"
        variant: "ghost"
        Layout.preferredHeight: 22
        Layout.preferredWidth: Math.max(32, implicitWidth)
        onClicked: if (root.keyboard) root.keyboard.nextLayout()
    }
}
