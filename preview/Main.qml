pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../ui/tokens"
import "../ui/screens"
import "mocks"
import "scenarios"

Window {
    id: root

    property string initialScenario: "S01"
    property string viewMode: "shell" // "shell" | "gallery"
    property string initialPanel: ""
    property string initialSection: ""
    property bool showHarnessBar: true
    property int simulatedWidth: 1366
    property int simulatedHeight: 768
    property real simulatedScale: 1.0

    width: 1440
    height: 900
    minimumWidth: 960
    minimumHeight: 600
    visible: true
    color: Tokens.background
    title: "MARATHON Tactical // Windows QtQuick Preview (" + mockBackend.activeScenarioId + ")"

    MockBackend {
        id: mockBackend
    }

    function setFactionTheme(factionId) {
        Tokens.setFaction(factionId)
        mockBackend.appearance.setFaction(Tokens.factionId)
    }

    function setActivePanel(panelName) {
        if (panelName === "") {
            stageScreen.closeAllPanels()
        } else if (panelName === "osd") {
            stageScreen.closeAllPanels()
            mockBackend.audio.setVolume(0.75)
        } else if (panelName === "confirm") {
            stageScreen.openPanel("session")
            mockBackend.session.requestAction("reboot")
        } else if (panelName === "toast") {
            stageScreen.closeAllPanels()
            mockBackend.notifications.pushNotification("TELEMETRY", "Tactical Alert", "Substation Uplink Event Triggered", "critical", [{ id: "ack", label: "ACK" }])
        } else {
            stageScreen.openPanel(panelName)
        }
    }

    function setSettingsSection(sectionId) {
        stageScreen.openSettingsSection(sectionId)
    }

    function selectScenario(scenarioId) {
        var meta = ScenarioCatalog.findScenario(scenarioId)
        mockBackend.applyScenario(meta.id)
        simulatedWidth = meta.width
        simulatedHeight = meta.height
        simulatedScale = meta.scale
    }

    Component.onCompleted: {
        selectScenario(initialScenario)
        if (initialSection !== "") stageScreen.openSettingsSection(initialSection)
        else if (initialPanel !== "") stageScreen.openPanel(initialPanel)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: harnessBar
            visible: root.showHarnessBar
            Layout.fillWidth: true
            height: visible ? 48 : 0
            color: Tokens.surfacePressed
            border.width: Tokens.borderWidth
            border.color: Tokens.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Tokens.spaceMd
                anchors.rightMargin: Tokens.spaceMd
                spacing: Tokens.spaceSm

                Text {
                    text: "PREVIEW // " + mockBackend.activeScenarioId + " (" + root.simulatedWidth + "x" + root.simulatedHeight + ")"
                    color: Tokens.signal
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontLabel
                    font.bold: true
                }

                Rectangle { width: Tokens.borderWidth; height: 22; color: Tokens.border }

                Row {
                    spacing: Tokens.spaceXs
                    Repeater {
                        model: ScenarioCatalog.scenarios
                        delegate: Rectangle {
                            id: scenDel
                            required property var modelData
                            readonly property bool active: mockBackend.activeScenarioId === scenDel.modelData.id
                            width: 28
                            height: Tokens.controlHeightSm
                            color: scenDel.active ? Tokens.signal : Tokens.surface
                            border.width: Tokens.borderWidth
                            border.color: scenDel.active ? Tokens.signal : Tokens.border

                            Text {
                                anchors.centerIn: parent
                                text: scenDel.modelData.id
                                color: scenDel.active ? Tokens.textOnSignal : Tokens.text
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: scenDel.active
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectScenario(scenDel.modelData.id)
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Repeater {
                    model: [
                        { id: "clipboard", label: "CLIP" },
                        { id: "capture", label: "CAP" },
                        { id: "sysmon", label: "MON" },
                        { id: "calendar", label: "CAL" },
                        { id: "cheatsheet", label: "KEYS" },
                        { id: "faction", label: "CORP:" + Tokens.factionId },
                        { id: "settings", label: "HUB" },
                        { id: "view", label: root.viewMode === "gallery" ? "VIEW:LIB" : "VIEW:SHELL" },
                        { id: "motion", label: mockBackend.appearance.reducedMotion ? "MOTION:REDUCED" : "MOTION:ON" },
                        { id: "fs", label: mockBackend.activeWindow.fullscreen ? "FS:ON" : "FS:OFF" },
                        { id: "osd", label: "+OSD" },
                        { id: "notif", label: "+NOTIF" }
                    ]
                    delegate: Rectangle {
                        id: trigDel
                        required property var modelData
                        readonly property bool highlighted: (trigDel.modelData.id === "view" && root.viewMode === "gallery")
                            || trigDel.modelData.id === "faction"
                            || (trigDel.modelData.id === "settings" && stageScreen.settingsOpen)
                            || (trigDel.modelData.id === "clipboard" && stageScreen.clipboardOpen)
                            || (trigDel.modelData.id === "capture" && stageScreen.captureOpen)
                            || (trigDel.modelData.id === "sysmon" && stageScreen.sysmonOpen)
                            || (trigDel.modelData.id === "calendar" && stageScreen.calendarOpen)
                            || (trigDel.modelData.id === "cheatsheet" && stageScreen.cheatsheetOpen)
                        width: trigTxt.implicitWidth + Tokens.spaceSm
                        height: Tokens.controlHeightSm
                        color: trigDel.highlighted ? Tokens.signal : Tokens.surface
                        border.width: Tokens.borderWidth
                        border.color: trigDel.highlighted ? Tokens.signal : Tokens.borderStrong

                        Text {
                            id: trigTxt
                            anchors.centerIn: parent
                            text: trigDel.modelData.label
                            color: trigDel.highlighted ? Tokens.textOnSignal : Tokens.text
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.fontMicro
                            font.bold: trigDel.highlighted
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var id = trigDel.modelData.id
                                if (id === "faction") {
                                    Tokens.cycleFaction()
                                    mockBackend.appearance.setFaction(Tokens.factionId)
                                }
                                else if (id === "clipboard" || id === "capture" || id === "sysmon" || id === "calendar" || id === "cheatsheet" || id === "settings") {
                                    const alreadyOpen = (id === "clipboard" && stageScreen.clipboardOpen)
                                        || (id === "capture" && stageScreen.captureOpen)
                                        || (id === "sysmon" && stageScreen.sysmonOpen)
                                        || (id === "calendar" && stageScreen.calendarOpen)
                                        || (id === "cheatsheet" && stageScreen.cheatsheetOpen)
                                        || (id === "settings" && stageScreen.settingsOpen)
                                    if (alreadyOpen) stageScreen.closeAllPanels()
                                    else stageScreen.openPanel(id)
                                }
                                else if (id === "view") root.viewMode = (root.viewMode === "shell" ? "gallery" : "shell")
                                else if (id === "motion") mockBackend.appearance.toggleReducedMotion()
                                else if (id === "fs") mockBackend.activeWindow.toggleFullscreen()
                                else if (id === "osd") mockBackend.audio.setVolume(Math.min(1.0, mockBackend.audio.volume + 0.05))
                                else if (id === "notif") mockBackend.notifications.pushNotification("PREVIEW", "Telemetry Pulse", "Manual test event from preview harness", "normal", [])
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: stageHost
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            readonly property real fitRatio: Math.min(
                1.0,
                Math.min(
                    Math.max(100, width - Tokens.spaceLg) / Math.max(1, root.simulatedWidth),
                    Math.max(100, height - Tokens.spaceLg) / Math.max(1, root.simulatedHeight)
                )
            )

            Rectangle {
                id: desktopFrame
                anchors.centerIn: parent
                width: root.simulatedWidth
                height: root.simulatedHeight
                scale: stageHost.fitRatio
                color: Tokens.background
                border.width: Tokens.borderWidth
                border.color: Tokens.borderStrong

                DesktopShellScreen {
                    id: stageScreen
                    anchors.fill: parent
                    visible: root.viewMode === "shell"
                    backend: mockBackend
                }

                ComponentGalleryScreen {
                    id: galleryScreen
                    anchors.fill: parent
                    visible: root.viewMode === "gallery"
                    backend: mockBackend
                }
            }
        }
    }
}
