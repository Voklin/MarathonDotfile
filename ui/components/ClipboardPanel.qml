pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var utilities
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()

    property string filterKind: "ALL" // "ALL" | "PINNED" | "URI" | "COLOR"
    property int selectedIndex: 0
    property bool confirmClear: false
    property string searchQuery: ""

    readonly property var filteredItems: {
        if (!utilities || !utilities.clipboardAvailable) return []
        var items = utilities.clipboardItems || []
        var q = (searchQuery || "").trim().toLowerCase()
        var out = []
        for (var i = 0; i < items.length; ++i) {
            var it = items[i]
            if (filterKind === "PINNED" && !it.pinned) continue
            if (filterKind === "URI" && it.kind !== "URI" && it.kind !== "PATH") continue
            if (filterKind === "COLOR" && it.kind !== "COLOR") continue
            if (q === ""
                || String(it.preview || "").toLowerCase().indexOf(q) !== -1
                || String(it.text || "").toLowerCase().indexOf(q) !== -1
                || String(it.kind || "").toLowerCase().indexOf(q) !== -1) {
                out.push(it)
            }
        }
        return out
    }

    function activateSelected() {
        if (filteredItems.length === 0 || selectedIndex < 0 || selectedIndex >= filteredItems.length) return
        var item = filteredItems[selectedIndex]
        if (utilities) utilities.copyClipboardItem(item.id)
        closeRequested()
    }

    function moveSelection(delta) {
        if (filteredItems.length === 0) return
        var next = Math.max(0, Math.min(filteredItems.length - 1, selectedIndex + delta))
        selectedIndex = next
        clipList.positionViewAtIndex(next, ListView.Contain)
    }

    onFilteredItemsChanged: {
        if (selectedIndex >= filteredItems.length) {
            selectedIndex = Math.max(0, filteredItems.length - 1)
        }
    }

    onOpenChanged: {
        if (open) {
            confirmClear = false
            selectedIndex = 0
            filterKind = "ALL"
            clipSearch.text = ""
            searchQuery = ""
            if (utilities) utilities.refreshClipboard()
            clipSearch.focusInput()
        }
    }

    visible: open || clipReveal.opacity > 0.01

    Rectangle {
        anchors.fill: parent
        color: Tokens.surfaceOverlay
        opacity: root.open ? 0.68 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Tokens.motionMs(Tokens.durationPanel, root.reducedMotion) }
        }
        MouseArea {
            anchors.fill: parent
            enabled: root.open
            onClicked: root.closeRequested()
        }
    }

    PanelReveal {
        id: clipReveal
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.min(72, Math.max(Tokens.spaceLg, parent.height * 0.09))
        width: Math.min(Tokens.clipboardWidth, parent.width - Tokens.spaceXl)
        height: Math.min(Tokens.clipboardHeight, parent.height - anchors.topMargin - Tokens.spaceXl)
        shown: root.open
        reducedMotion: root.reducedMotion

        MouseArea { anchors.fill: clipCard }

        TacticalPanel {
            id: clipCard
            anchors.fill: parent
            code: "UTILITY // CLIPBOARD VAULT"
            title: "CLIPHIST MEMORY & PINS"
            statusText: (root.utilities && root.utilities.clipboardAvailable)
                ? (root.filteredItems.length + " ENTRIES")
                : "UNAVAILABLE"
            statusTone: (root.utilities && root.utilities.clipboardAvailable) ? "signal" : "alert"
            alertState: !(root.utilities && root.utilities.clipboardAvailable)

            // Search + category chips
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceXs

                TacticalTextField {
                    id: clipSearch
                    Layout.fillWidth: true
                    placeholderText: "SEARCH CLIPBOARD HISTORY..."
                    enabledState: root.utilities && root.utilities.clipboardAvailable
                    onTextChanged: {
                        root.searchQuery = clipSearch.text
                        root.selectedIndex = 0
                    }
                    onTextSubmitted: root.activateSelected()
                    onEscapePressed: root.closeRequested()

                    Keys.onDownPressed: function(event) {
                        root.moveSelection(1)
                        event.accepted = true
                    }
                    Keys.onUpPressed: function(event) {
                        root.moveSelection(-1)
                        event.accepted = true
                    }
                }

                Repeater {
                    model: [
                        { id: "ALL", label: "ALL" },
                        { id: "PINNED", label: "PIN" },
                        { id: "URI", label: "URI" },
                        { id: "COLOR", label: "HEX" }
                    ]
                    delegate: TacticalButton {
                        id: kindBtn
                        required property var modelData
                        text: kindBtn.modelData.label
                        active: root.filterKind === kindBtn.modelData.id
                        variant: active ? "primary" : "default"
                        implicitWidth: 46
                        implicitHeight: Tokens.controlHeightLg
                        reducedMotion: root.reducedMotion
                        onClicked: {
                            root.filterKind = kindBtn.modelData.id
                            root.selectedIndex = 0
                            clipSearch.focusInput()
                        }
                    }
                }
            }

            // Clipboard entries list or empty state
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                EmptyState {
                    anchors.fill: parent
                    visible: root.filteredItems.length === 0
                    code: !(root.utilities && root.utilities.clipboardAvailable) ? "OFFLINE" : "EMPTY"
                    title: !(root.utilities && root.utilities.clipboardAvailable)
                        ? "CLIPHIST / WL-CLIPBOARD UNAVAILABLE"
                        : "NO CLIPBOARD ENTRIES MATCH FILTER"
                    detail: !(root.utilities && root.utilities.clipboardAvailable)
                        ? (root.utilities ? root.utilities.clipboardError : "Install cliphist and wl-clipboard on CachyOS")
                        : "COPY TEXT OR CHANGE FILTER CHIPS TO INSPECT SAVED BUFFER"
                    iconName: "clipboard"
                    alertTone: !(root.utilities && root.utilities.clipboardAvailable)
                }

                ListView {
                    id: clipList
                    anchors.fill: parent
                    visible: root.filteredItems.length > 0
                    model: root.filteredItems
                    clip: true
                    spacing: Tokens.spaceXs
                    currentIndex: root.selectedIndex

                    delegate: Rectangle {
                        id: clipRow
                        required property var modelData
                        required property int index
                        readonly property bool isSelected: clipRow.index === root.selectedIndex
                        readonly property bool isColor: clipRow.modelData.kind === "COLOR" && Tokens.isValidHexColor(clipRow.modelData.text)

                        width: clipList.width
                        height: 52
                        color: clipRow.isSelected ? Tokens.surfaceElevated : ((clipRow.index % 2 === 0) ? Tokens.background : Tokens.surfaceZebra)
                        border.width: clipRow.isSelected ? Tokens.focusBorderWidth : Tokens.borderWidth
                        border.color: clipRow.isSelected ? Tokens.signal : (clipRow.modelData.pinned ? Tokens.borderStrong : Tokens.borderSubtle)

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selectedIndex = clipRow.index
                            onClicked: {
                                root.selectedIndex = clipRow.index
                                root.activateSelected()
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceSm
                            spacing: Tokens.spaceSm

                            // Left icon or live color swatch
                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                color: clipRow.isColor
                                    ? clipRow.modelData.text
                                    : (clipRow.isSelected ? Tokens.signal : Tokens.surface)
                                border.width: Tokens.borderWidth
                                border.color: clipRow.isSelected ? Tokens.signal : Tokens.border

                                TacticalIcon {
                                    visible: !clipRow.isColor
                                    anchors.centerIn: parent
                                    iconName: "clipboard"
                                    iconSize: 14
                                    color: clipRow.isSelected ? Tokens.textOnSignal : Tokens.signal
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: clipRow.modelData.preview || ""
                                    color: clipRow.isSelected ? Tokens.signal : Tokens.text
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontLabel
                                    font.bold: clipRow.isSelected || clipRow.modelData.pinned
                                    elide: Text.ElideRight
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Tokens.spaceXs

                                    StatusPill {
                                        text: clipRow.modelData.pinned ? "PINNED" : (clipRow.modelData.kind || "TEXT")
                                        tone: clipRow.modelData.pinned ? "signal" : "neutral"
                                    }

                                    Text {
                                        text: (clipRow.modelData.charCount || 0) + " CHARS // " + (clipRow.modelData.timestamp || "")
                                        color: Tokens.muted
                                        font.family: Tokens.fontMono
                                        font.pixelSize: Tokens.fontMicro
                                    }
                                }
                            }

                            TacticalButton {
                                text: clipRow.modelData.pinned ? "UNPIN" : "PIN"
                                active: clipRow.modelData.pinned
                                variant: clipRow.modelData.pinned ? "primary" : "default"
                                implicitWidth: 54
                                implicitHeight: Tokens.controlHeightSm
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.utilities) root.utilities.togglePinClipboard(clipRow.modelData.id)
                            }

                            TacticalButton {
                                text: ""
                                iconName: "close"
                                variant: "danger"
                                implicitWidth: 26
                                implicitHeight: Tokens.controlHeightSm
                                reducedMotion: root.reducedMotion
                                onClicked: if (root.utilities) root.utilities.deleteClipboardItem(clipRow.modelData.id)
                            }
                        }
                    }
                }
            }

            // Footer controls
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceXs

                Text {
                    Layout.fillWidth: true
                    text: root.utilities && root.utilities.statusNote !== "" ? root.utilities.statusNote : "ENTER COPIES & CLOSES // ESC DISMISSES"
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    elide: Text.ElideRight
                }

                TacticalButton {
                    text: root.confirmClear ? "CONFIRM WIPE?" : "CLEAR UNPINNED"
                    variant: root.confirmClear ? "danger" : "default"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        if (!root.confirmClear) {
                            root.confirmClear = true
                        } else {
                            root.confirmClear = false
                            if (root.utilities) root.utilities.clearClipboard()
                        }
                    }
                }

                TacticalButton {
                    text: "CLOSE"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.closeRequested()
                }
            }
        }
    }
}
