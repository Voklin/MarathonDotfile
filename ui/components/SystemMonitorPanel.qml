pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var utilities
    property var audio: null
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()

    property string activeTab: "processes" // "processes" | "audio"
    property string procFilter: ""
    property int pendingKillPid: -1

    readonly property var filteredProcesses: {
        var list = (utilities && utilities.processes) ? utilities.processes : []
        var q = (procFilter || "").trim().toLowerCase()
        if (q === "") return list
        var out = []
        for (var i = 0; i < list.length; ++i) {
            var p = list[i]
            if (String(p.name || "").toLowerCase().indexOf(q) !== -1
                || String(p.pid || "").indexOf(q) !== -1
                || String(p.user || "").toLowerCase().indexOf(q) !== -1) {
                out.push(p)
            }
        }
        return out
    }

    onOpenChanged: {
        if (utilities) utilities.setMonitorActive(open)
        if (open) {
            pendingKillPid = -1
            procSearch.text = ""
            procFilter = ""
            monitorCard.forceActiveFocus()
        }
    }

    Keys.onEscapePressed: function(event) {
        if (root.open) {
            root.closeRequested()
            event.accepted = true
        }
    }

    visible: open || monReveal.opacity > 0.01

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
        id: monReveal
        anchors.centerIn: parent
        width: Math.min(Tokens.sysMonWidth, parent.width - Tokens.spaceXl)
        height: Math.min(Tokens.sysMonHeight, parent.height - Tokens.spaceXl)
        shown: root.open
        reducedMotion: root.reducedMotion

        MouseArea { anchors.fill: monitorCard }

        TacticalPanel {
            id: monitorCard
            anchors.fill: parent
            focus: true
            code: "TELEMETRY // SYSTEM MONITOR"
            title: "HARDWARE, PROCESSES & AUDIO MIXER"
            statusText: root.utilities ? ("LOAD " + root.utilities.loadAvg) : "OFFLINE"
            statusTone: (root.utilities && root.utilities.cpuUsage > 0.85) ? "alert" : "signal"

            // Top 3 Hardware Telemetry Metric Cards (CPU, RAM, DISK)
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceSm

                // CPU Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: cpuCol.implicitHeight + Tokens.spaceSm * 2
                    color: Tokens.surfacePressed
                    border.width: Tokens.borderWidth
                    border.color: (root.utilities && root.utilities.cpuUsage > 0.85) ? Tokens.alert : Tokens.borderStrong

                    ColumnLayout {
                        id: cpuCol
                        anchors.fill: parent
                        anchors.margins: Tokens.spaceSm
                        spacing: Tokens.spaceXs

                        RowLayout {
                            Layout.fillWidth: true
                            TacticalIcon { iconName: "cpu"; iconSize: 14; color: Tokens.signal }
                            Text {
                                Layout.fillWidth: true
                                text: "CPU LOAD"
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                            }
                            Text {
                                text: root.utilities
                                    ? (Math.round(root.utilities.cpuUsage * 100) + "%" + (root.utilities.cpuTempC > 0 ? (" · " + root.utilities.cpuTempC + "°C") : ""))
                                    : "--"
                                color: Tokens.signal
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontLabel
                                font.bold: true
                            }
                        }

                        SegmentedMeter {
                            Layout.fillWidth: true
                            value: root.utilities ? root.utilities.cpuUsage : 0.0
                            segments: 12
                            tone: (root.utilities && root.utilities.cpuUsage > 0.85) ? "alert" : "signal"
                            reducedMotion: root.reducedMotion
                        }
                    }
                }

                // RAM Card
                Rectangle {
                    id: ramCard
                    Layout.fillWidth: true
                    readonly property real ramFrac: (root.utilities && root.utilities.ramTotalGib > 0)
                        ? Math.min(1.0, root.utilities.ramUsedGib / root.utilities.ramTotalGib)
                        : 0.0
                    implicitHeight: ramCol.implicitHeight + Tokens.spaceSm * 2
                    color: Tokens.surfacePressed
                    border.width: Tokens.borderWidth
                    border.color: Tokens.borderStrong

                    ColumnLayout {
                        id: ramCol
                        anchors.fill: parent
                        anchors.margins: Tokens.spaceSm
                        spacing: Tokens.spaceXs

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: "MEMORY"
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                            }
                            Text {
                                text: root.utilities
                                    ? (root.utilities.ramUsedGib.toFixed(1) + "/" + root.utilities.ramTotalGib.toFixed(0) + "G")
                                    : "--"
                                color: Tokens.text
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontLabel
                                font.bold: true
                            }
                        }

                        SegmentedMeter {
                            Layout.fillWidth: true
                            value: ramCard.ramFrac
                            segments: 12
                            tone: ramCard.ramFrac > 0.85 ? "alert" : "signal"
                            reducedMotion: root.reducedMotion
                        }
                    }
                }

                // Disk Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: diskCol.implicitHeight + Tokens.spaceSm * 2
                    color: Tokens.surfacePressed
                    border.width: Tokens.borderWidth
                    border.color: Tokens.borderStrong

                    ColumnLayout {
                        id: diskCol
                        anchors.fill: parent
                        anchors.margins: Tokens.spaceSm
                        spacing: Tokens.spaceXs

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: "STORAGE (/)"
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                            }
                            Text {
                                text: root.utilities ? (root.utilities.diskUsedPct + "%") : "--"
                                color: (root.utilities && root.utilities.diskUsedPct > 85) ? Tokens.alert : Tokens.text
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontLabel
                                font.bold: true
                            }
                        }

                        SegmentedMeter {
                            Layout.fillWidth: true
                            value: root.utilities ? (root.utilities.diskUsedPct / 100.0) : 0.0
                            segments: 12
                            tone: (root.utilities && root.utilities.diskUsedPct > 85) ? "alert" : "signal"
                            reducedMotion: root.reducedMotion
                        }
                    }
                }
            }

            // Tab switcher & action buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceXs

                TacticalButton {
                    text: "PROCESSES (" + root.filteredProcesses.length + ")"
                    iconName: "cpu"
                    active: root.activeTab === "processes"
                    variant: active ? "primary" : "default"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.activeTab = "processes"
                }

                TacticalButton {
                    text: "APP AUDIO MIXER (" + (root.utilities && root.utilities.audioStreams ? root.utilities.audioStreams.length : 0) + ")"
                    iconName: "audio"
                    active: root.activeTab === "audio"
                    variant: active ? "primary" : "default"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: root.activeTab = "audio"
                }

                Item { Layout.fillWidth: true }

                TacticalButton {
                    text: "REFRESH"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: if (root.utilities) root.utilities.refreshSystemMetrics()
                }

                TacticalButton {
                    text: "LAUNCH BTOP"
                    iconName: "terminal"
                    variant: "primary"
                    implicitHeight: Tokens.controlHeightSm
                    reducedMotion: root.reducedMotion
                    onClicked: {
                        if (root.utilities) root.utilities.launchExternalMonitor()
                        root.closeRequested()
                    }
                }
            }

            // Tab 1: Processes
            ColumnLayout {
                visible: root.activeTab === "processes"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Tokens.spaceXs

                TacticalTextField {
                    id: procSearch
                    Layout.fillWidth: true
                    placeholderText: "FILTER BY PROCESS NAME, PID OR USER..."
                    onTextChanged: {
                        root.procFilter = procSearch.text
                        root.pendingKillPid = -1
                    }
                    onEscapePressed: root.closeRequested()
                }

                // Header columns
                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    color: Tokens.surfaceElevated
                    border.width: Tokens.borderWidth
                    border.color: Tokens.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Tokens.spaceSm
                        anchors.rightMargin: Tokens.spaceSm
                        spacing: Tokens.spaceSm

                        Text { Layout.preferredWidth: 60; text: "PID"; color: Tokens.muted; font.family: Tokens.fontMono; font.pixelSize: Tokens.fontMicro; font.bold: true }
                        Text { Layout.fillWidth: true; text: "COMMAND"; color: Tokens.muted; font.family: Tokens.fontMono; font.pixelSize: Tokens.fontMicro; font.bold: true }
                        Text { Layout.preferredWidth: 64; horizontalAlignment: Text.AlignRight; text: "CPU %"; color: Tokens.muted; font.family: Tokens.fontMono; font.pixelSize: Tokens.fontMicro; font.bold: true }
                        Text { Layout.preferredWidth: 74; horizontalAlignment: Text.AlignRight; text: "MEM"; color: Tokens.muted; font.family: Tokens.fontMono; font.pixelSize: Tokens.fontMicro; font.bold: true }
                        Text { Layout.preferredWidth: 92; horizontalAlignment: Text.AlignRight; text: "SIGNAL"; color: Tokens.muted; font.family: Tokens.fontMono; font.pixelSize: Tokens.fontMicro; font.bold: true }
                    }
                }

                ListView {
                    id: procList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.filteredProcesses
                    clip: true
                    spacing: 2

                    delegate: Rectangle {
                        id: procRow
                        required property var modelData
                        required property int index
                        readonly property bool isArmed: root.pendingKillPid === procRow.modelData.pid

                        width: procList.width
                        height: 36
                        color: (procRow.index % 2 === 0) ? Tokens.background : Tokens.surfaceZebra
                        border.width: Tokens.borderWidth
                        border.color: procRow.isArmed ? Tokens.alert : Tokens.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Tokens.spaceSm
                            anchors.rightMargin: Tokens.spaceXs
                            spacing: Tokens.spaceSm

                            Text {
                                Layout.preferredWidth: 60
                                text: String(procRow.modelData.pid)
                                color: Tokens.muted
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                            }

                            Text {
                                Layout.fillWidth: true
                                text: String(procRow.modelData.name)
                                color: Tokens.text
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontLabel
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.preferredWidth: 64
                                horizontalAlignment: Text.AlignRight
                                text: Number(procRow.modelData.cpuPct).toFixed(1) + "%"
                                color: procRow.modelData.cpuPct > 25 ? Tokens.warning : Tokens.signal
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                                font.bold: true
                            }

                            Text {
                                Layout.preferredWidth: 74
                                horizontalAlignment: Text.AlignRight
                                text: procRow.modelData.memMb + " MB"
                                color: Tokens.text
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontMicro
                            }

                            TacticalButton {
                                text: procRow.isArmed ? "CONFIRM" : "TERM"
                                variant: "danger"
                                implicitWidth: 92
                                implicitHeight: 24
                                reducedMotion: root.reducedMotion
                                onClicked: {
                                    if (!procRow.isArmed) {
                                        root.pendingKillPid = procRow.modelData.pid
                                    } else {
                                        root.pendingKillPid = -1
                                        if (root.utilities) root.utilities.killProcess(procRow.modelData.pid)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Tab 2: Per-Application PipeWire Audio Mixer
            ColumnLayout {
                visible: root.activeTab === "audio"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Tokens.spaceSm

                TacticalSlider {
                    visible: root.audio !== null
                    Layout.fillWidth: true
                    label: (root.audio && root.audio.available) ? ("MASTER // " + root.audio.sinkName) : "MASTER // UNAVAILABLE"
                    iconName: (root.audio && root.audio.muted) ? "audio-muted" : "audio"
                    value: root.audio ? root.audio.volume : 0.0
                    mutedState: root.audio ? root.audio.muted : true
                    enabledState: root.audio ? root.audio.available : false
                    reducedMotion: root.reducedMotion
                    onValueEdited: function(v) { if (root.audio) root.audio.setVolume(v) }
                    onIconClicked: { if (root.audio) root.audio.toggleMute() }
                }

                EmptyState {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !(root.utilities && root.utilities.audioStreams && root.utilities.audioStreams.length > 0)
                    code: "IDLE STREAMS"
                    title: "NO ACTIVE PER-APP AUDIO STREAMS"
                    detail: "START PLAYBACK IN FIREFOX, SPOTIFY OR MPV TO ADJUST STREAM GAIN"
                    iconName: "audio"
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.utilities && root.utilities.audioStreams && root.utilities.audioStreams.length > 0
                    model: root.utilities ? root.utilities.audioStreams : []
                    clip: true
                    spacing: Tokens.spaceXs

                    delegate: TacticalSlider {
                        id: streamDel
                        required property var modelData
                        width: ListView.view.width
                        label: streamDel.modelData.appName.toUpperCase() + " // " + streamDel.modelData.mediaTitle
                        iconName: streamDel.modelData.muted ? "audio-muted" : "audio"
                        value: streamDel.modelData.volume
                        mutedState: streamDel.modelData.muted
                        reducedMotion: root.reducedMotion
                        onValueEdited: function(v) { if (root.utilities) root.utilities.setStreamVolume(streamDel.modelData.id, v) }
                        onIconClicked: { if (root.utilities) root.utilities.toggleStreamMute(streamDel.modelData.id) }
                    }
                }
            }

            // Footer
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spaceSm
                Text {
                    Layout.fillWidth: true
                    text: root.utilities && root.utilities.diskSummary !== "--"
                        ? ("DISK /: " + root.utilities.diskSummary + (root.utilities.statusNote !== "" ? (" // " + root.utilities.statusNote) : ""))
                        : (root.utilities ? root.utilities.statusNote : "")
                    color: Tokens.muted
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.fontMicro
                    elide: Text.ElideRight
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
