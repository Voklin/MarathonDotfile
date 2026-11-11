pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var settings
    property var utilities: null
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()
    signal triggerActionRequested(string actionId)

    property string categoryFilter: "ALL"
    property string searchQuery: ""

    readonly property var combinedBindings: {
        var out = []
        var base = (settings && settings.keybindCatalog) ? settings.keybindCatalog : []
        for (var i = 0; i < base.length; ++i) {
            out.push(base[i])
        }
        var custom = (settings && settings.customKeybinds) ? settings.customKeybinds : []
        for (var j = 0; j < custom.length; ++j) {
            var kb = custom[j]
            if (kb && kb.enabled) {
                out.push({
                    category: "CUSTOM",
                    chord: String(kb.mods || "") + " + " + String(kb.key || ""),
                    action: "User Bind (" + String(kb.dispatcher || "exec") + ")",
                    target: String(kb.arg || "")
                })
            }
        }
        // Launcher Smart-Prefix UX Tips
        out.push({ category: "LAUNCHER", chord: "=EXPR", action: "Inline Calculator & Units (px<>rem, gb<>mb, c<>f)", target: "launcher =32px to rem" })
        out.push({ category: "LAUNCHER", chord: "=#RRGGBB", action: "Color Palette Converter (RGB / HSL / Hypr rgba)", target: "launcher =#C9FF16" })
        out.push({ category: "LAUNCHER", chord: ">CMD", action: "Safe System Command Filter Prefix", target: "launcher >settings" })
        out.push({ category: "LAUNCHER", chord: "@", action: "Jump Straight to Clipboard Vault", target: "launcher @" })

        var q = (searchQuery || "").trim().toLowerCase()
        var filtered = []
        for (var k = 0; k < out.length; ++k) {
            var row = out[k]
            if (categoryFilter !== "ALL" && row.category !== categoryFilter) continue
            if (q === ""
                || String(row.chord).toLowerCase().indexOf(q) !== -1
                || String(row.action).toLowerCase().indexOf(q) !== -1
                || String(row.target).toLowerCase().indexOf(q) !== -1
                || String(row.category).toLowerCase().indexOf(q) !== -1) {
                filtered.push(row)
            }
        }
        return filtered
    }

    onOpenChanged: {
        if (open) {
            categoryFilter = "ALL"
            searchQuery = ""
            keySearch.text = ""
            keySearch.focusInput()
        }
    }

    Keys.onEscapePressed: function(event) {
        if (root.open) {
            root.closeRequested()
            event.accepted = true
        }
    }

    visible: open || cheatReveal.opacity > 0.01

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
        id: cheatReveal
        anchors.centerIn: parent
        width: Math.min(Tokens.cheatsheetWidth, parent.width - Tokens.spaceXl)
        height: Math.min(Tokens.cheatsheetHeight, parent.height - Tokens.spaceXl)
        shown: root.open
        reducedMotion: root.reducedMotion

        MouseArea { anchors.fill: cheatCard }

        TacticalPanel {
            id: cheatCard
            anchors.fill: parent
            code: "BRIEFING // OPERATOR MANUAL"
            title: "KEYBINDS, APPS & QUICK-START ACTIONS"
            statusText: root.combinedBindings.length + " SHORTCUTS"
            statusTone: "signal"

            // Quick-start shell actions bar
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: quickCol.implicitHeight + Tokens.spaceSm * 2
                color: Tokens.surfacePressed
                border.width: Tokens.borderWidth
                border.color: Tokens.borderStrong

                ColumnLayout {
                    id: quickCol
                    anchors.fill: parent
                    anchors.margins: Tokens.spaceSm
                    spacing: Tokens.spaceXs

                    Text {
                        text: "QUICK-START SUITE LAUNCHERS"
                        color: Tokens.signal
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.fontMicro
                        font.bold: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spaceXs

                        Repeater {
                            model: [
                                { id: "open-clipboard", label: "CLIPBOARD", icon: "clipboard" },
                                { id: "open-capture", label: "CAPTURE", icon: "capture" },
                                { id: "open-sysmon", label: "MONITOR", icon: "cpu" },
                                { id: "open-calendar", label: "CALENDAR", icon: "calendar" },
                                { id: "open-settings", label: "SETTINGS", icon: "settings" },
                                { id: "toggle-nightlight", label: "NIGHT LIGHT", icon: "brightness" }
                            ]
                            delegate: TacticalButton {
                                id: qsBtn
                                required property var modelData
                                Layout.fillWidth: true
                                text: qsBtn.modelData.label
                                iconName: qsBtn.modelData.icon
                                implicitHeight: Tokens.controlHeightSm
                                reducedMotion: root.reducedMotion
                                onClicked: {
                                    root.triggerActionRequested(qsBtn.modelData.id)
                                    if (qsBtn.modelData.id !== "toggle-nightlight") {
                                        root.closeRequested()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Filter search + category tabs
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceXs

                TacticalTextField {
                    id: keySearch
                    Layout.fillWidth: true
                    placeholderText: "SEARCH SHORTCUTS, TOOLS OR =CALCULATOR TIPS..."
                    onTextChanged: root.searchQuery = keySearch.text
                    onEscapePressed: root.closeRequested()
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: Tokens.spaceXs

                    Repeater {
                        model: ["ALL", "SHELL", "APPS", "LAUNCHER", "TILING", "WORKSPACES", "HARDWARE", "CUSTOM"]
                        delegate: TacticalButton {
                            id: catBtn
                            required property string modelData
                            text: catBtn.modelData
                            active: root.categoryFilter === catBtn.modelData
                            variant: active ? "primary" : "default"
                            implicitHeight: Tokens.controlHeightSm
                            reducedMotion: root.reducedMotion
                            onClicked: root.categoryFilter = catBtn.modelData
                        }
                    }
                }
            }

            // Keybind table
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.combinedBindings
                clip: true
                spacing: 3

                delegate: Rectangle {
                    id: kbRow
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 36
                    color: (kbRow.index % 2 === 0) ? Tokens.background : Tokens.surfaceZebra
                    border.width: Tokens.borderWidth
                    border.color: Tokens.borderSubtle

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Tokens.spaceSm
                        anchors.rightMargin: Tokens.spaceSm
                        spacing: Tokens.spaceSm

                        StatusPill {
                            Layout.preferredWidth: 84
                            text: kbRow.modelData.category || "BIND"
                            tone: kbRow.modelData.category === "SHELL" ? "signal" : "neutral"
                        }

                        Rectangle {
                            Layout.preferredWidth: 184
                            height: 24
                            color: Tokens.keycapBg
                            border.width: Tokens.borderWidth
                            border.color: Tokens.borderStrong

                            Text {
                                anchors.centerIn: parent
                                text: kbRow.modelData.chord || ""
                                color: Tokens.signal
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: kbRow.modelData.action || ""
                            color: Tokens.text
                            font.family: Tokens.fontUi
                            font.pixelSize: Tokens.fontBody
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.preferredWidth: 230
                            horizontalAlignment: Text.AlignRight
                            text: kbRow.modelData.target || ""
                            color: Tokens.muted
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.fontMicro
                            elide: Text.ElideMiddle
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "TIP: OPEN WITH SUPER+/ OR F1 ANYTIME // PRESS ESC TO DISMISS"
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
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
