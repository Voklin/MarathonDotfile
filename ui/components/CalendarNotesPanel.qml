pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"
import "../animations"

Item {
    id: root

    required property var utilities
    required property var appearance
    property bool open: false
    property bool reducedMotion: false

    signal closeRequested()

    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth() // 0..11
    property int selectedDay: new Date().getDate()
    property int selectedMonth: new Date().getMonth()
    property int selectedYear: new Date().getFullYear()

    readonly property int todayYear: new Date().getFullYear()
    readonly property int todayMonth: new Date().getMonth()
    readonly property int todayDay: new Date().getDate()

    readonly property var monthNames: ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    readonly property var calendarCells: {
        var first = new Date(viewYear, viewMonth, 1)
        // Monday-first grid: Mon=0 .. Sun=6
        var startOffset = (first.getDay() + 6) % 7
        var daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate()
        var cells = []
        for (var i = 0; i < 42; ++i) {
            var dayNum = i - startOffset + 1
            if (dayNum >= 1 && dayNum <= daysInMonth) {
                cells.push({
                    day: dayNum,
                    valid: true,
                    isToday: (viewYear === todayYear && viewMonth === todayMonth && dayNum === todayDay),
                    isSelected: (viewYear === selectedYear && viewMonth === selectedMonth && dayNum === selectedDay)
                })
            } else {
                cells.push({ day: 0, valid: false, isToday: false, isSelected: false })
            }
        }
        return cells
    }

    function formatSec(sec) {
        var s = Math.max(0, Math.floor(sec))
        var m = Math.floor(s / 60)
        var r = s % 60
        return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
    }

    function stepMonth(delta) {
        var m = viewMonth + delta
        var y = viewYear
        if (m < 0) {
            m = 11
            y -= 1
        } else if (m > 11) {
            m = 0
            y += 1
        }
        viewMonth = m
        viewYear = y
    }

    function jumpToday() {
        var d = new Date()
        viewYear = d.getFullYear()
        viewMonth = d.getMonth()
        selectedYear = viewYear
        selectedMonth = viewMonth
        selectedDay = d.getDate()
    }

    onOpenChanged: {
        if (open) {
            if (utilities && scratchEdit.text !== utilities.scratchpadText) {
                scratchEdit.text = utilities.scratchpadText
            }
            calCard.forceActiveFocus()
        }
    }

    Keys.onEscapePressed: function(event) {
        if (root.open) {
            root.closeRequested()
            event.accepted = true
        }
    }

    visible: open || calReveal.opacity > 0.01

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
        id: calReveal
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Tokens.spaceSm
        width: Math.min(Tokens.calendarNotesWidth, parent.width - Tokens.spaceLg)
        height: Math.min(Tokens.calendarNotesHeight, parent.height - Tokens.spaceLg)
        shown: root.open
        reducedMotion: root.reducedMotion

        MouseArea { anchors.fill: calCard }

        TacticalPanel {
            id: calCard
            anchors.fill: parent
            focus: true
            code: "CHRONO // SCHEDULE & FOCUS"
            title: "CALENDAR, POMODORO & SCRATCHPAD"
            statusText: root.appearance ? root.appearance.dateText : "ONLINE"
            statusTone: (root.utilities && root.utilities.pomodoroRunning) ? "signal" : "neutral"

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Tokens.spaceMd

                // Left column: Monthly Calendar
                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.fillHeight: true
                    color: Tokens.surfacePressed
                    border.width: Tokens.borderWidth
                    border.color: Tokens.borderStrong

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Tokens.spaceSm
                        spacing: Tokens.spaceXs

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Tokens.spaceXs

                            TacticalButton {
                                text: ""
                                iconName: "chevron-left"
                                implicitWidth: 28
                                implicitHeight: Tokens.controlHeightSm
                                reducedMotion: root.reducedMotion
                                onClicked: root.stepMonth(-1)
                            }

                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: root.monthNames[root.viewMonth] + " " + root.viewYear
                                color: Tokens.signal
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.fontBody
                                font.bold: true
                            }

                            TacticalButton {
                                text: "TODAY"
                                implicitWidth: 54
                                implicitHeight: Tokens.controlHeightSm
                                reducedMotion: root.reducedMotion
                                onClicked: root.jumpToday()
                            }

                            TacticalButton {
                                text: ""
                                iconName: "chevron-right"
                                implicitWidth: 28
                                implicitHeight: Tokens.controlHeightSm
                                reducedMotion: root.reducedMotion
                                onClicked: root.stepMonth(1)
                            }
                        }

                        // Weekday headers
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 7
                            columnSpacing: 2
                            Repeater {
                                model: ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
                                delegate: Text {
                                    required property string modelData
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    text: modelData
                                    color: Tokens.muted
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: true
                                }
                            }
                        }

                        // 6x7 day matrix
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            columns: 7
                            columnSpacing: 2
                            rowSpacing: 2

                            Repeater {
                                model: root.calendarCells
                                delegate: Rectangle {
                                    id: dayCell
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: !dayCell.modelData.valid
                                        ? "transparent"
                                        : (dayCell.modelData.isToday
                                            ? Tokens.signal
                                            : (dayCell.modelData.isSelected ? Tokens.surfaceElevated : Tokens.background))
                                    border.width: dayCell.modelData.valid ? Tokens.borderWidth : 0
                                    border.color: dayCell.modelData.isSelected ? Tokens.signal : Tokens.borderSubtle

                                    Text {
                                        visible: dayCell.modelData.valid
                                        anchors.centerIn: parent
                                        text: String(dayCell.modelData.day)
                                        color: dayCell.modelData.isToday
                                            ? Tokens.textOnSignal
                                            : (dayCell.modelData.isSelected ? Tokens.signal : Tokens.text)
                                        font.family: Tokens.fontMono
                                        font.pixelSize: Tokens.fontLabel
                                        font.bold: dayCell.modelData.isToday || dayCell.modelData.isSelected
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: dayCell.modelData.valid
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.selectedYear = root.viewYear
                                            root.selectedMonth = root.viewMonth
                                            root.selectedDay = dayCell.modelData.day
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "SELECTED // " + root.selectedYear + "-" + (root.selectedMonth < 9 ? "0" : "") + (root.selectedMonth + 1) + "-" + (root.selectedDay < 10 ? "0" : "") + root.selectedDay
                            color: Tokens.muted
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.fontMicro
                        }
                    }
                }

                // Right column: Pomodoro Focus Timer + Persistent Scratchpad
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Tokens.spaceSm

                    // Pomodoro Focus Card
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: pomoCol.implicitHeight + Tokens.spaceSm * 2
                        color: Tokens.surfacePressed
                        border.width: Tokens.borderWidth
                        border.color: (root.utilities && root.utilities.pomodoroRunning) ? Tokens.signal : Tokens.borderStrong

                        ColumnLayout {
                            id: pomoCol
                            anchors.fill: parent
                            anchors.margins: Tokens.spaceSm
                            spacing: Tokens.spaceXs

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: "FOCUS TIMER // " + (root.utilities ? root.utilities.pomodoroMode : "FOCUS")
                                    color: Tokens.signal
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: true
                                }
                                Text {
                                    text: root.utilities ? root.formatSec(root.utilities.pomodoroRemainingSec) : "25:00"
                                    color: Tokens.text
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontHeading
                                    font.bold: true
                                }
                            }

                            SegmentedMeter {
                                Layout.fillWidth: true
                                segments: 16
                                value: (root.utilities && root.utilities.pomodoroTotalSec > 0)
                                    ? (root.utilities.pomodoroRemainingSec / root.utilities.pomodoroTotalSec)
                                    : 1.0
                                tone: (root.utilities && root.utilities.pomodoroRemainingSec === 0) ? "alert" : "signal"
                                reducedMotion: root.reducedMotion
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Tokens.spaceXs

                                TacticalButton {
                                    text: (root.utilities && root.utilities.pomodoroRunning) ? "PAUSE" : "START"
                                    iconName: (root.utilities && root.utilities.pomodoroRunning) ? "pause" : "play"
                                    variant: "primary"
                                    implicitHeight: Tokens.controlHeightSm
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.utilities) root.utilities.togglePomodoro()
                                }

                                TacticalButton {
                                    text: "RESET"
                                    implicitHeight: Tokens.controlHeightSm
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.utilities) root.utilities.resetPomodoro()
                                }

                                Item { Layout.fillWidth: true }

                                TacticalButton {
                                    text: "25M"
                                    active: root.utilities && root.utilities.pomodoroMode === "FOCUS"
                                    variant: active ? "primary" : "default"
                                    implicitWidth: 42
                                    implicitHeight: Tokens.controlHeightSm
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.utilities) root.utilities.setPomodoroPreset(25, "FOCUS")
                                }
                                TacticalButton {
                                    text: "5M"
                                    active: root.utilities && root.utilities.pomodoroMode === "SHORT BREAK"
                                    variant: active ? "primary" : "default"
                                    implicitWidth: 40
                                    implicitHeight: Tokens.controlHeightSm
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.utilities) root.utilities.setPomodoroPreset(5, "SHORT BREAK")
                                }
                                TacticalButton {
                                    text: "15M"
                                    active: root.utilities && root.utilities.pomodoroMode === "LONG BREAK"
                                    variant: active ? "primary" : "default"
                                    implicitWidth: 42
                                    implicitHeight: Tokens.controlHeightSm
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.utilities) root.utilities.setPomodoroPreset(15, "LONG BREAK")
                                }
                            }
                        }
                    }

                    // Persistent Scratchpad
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Tokens.background
                        border.width: scratchEdit.activeFocus ? Tokens.focusBorderWidth : Tokens.borderWidth
                        border.color: scratchEdit.activeFocus ? Tokens.signal : Tokens.border

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Tokens.spaceSm
                            spacing: Tokens.spaceXs

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: "SCRATCHPAD // AUTO-SAVED NOTES"
                                    color: Tokens.muted
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontMicro
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                                TacticalButton {
                                    text: "COPY"
                                    implicitHeight: 22
                                    reducedMotion: root.reducedMotion
                                    onClicked: if (root.utilities) root.utilities.copyText(scratchEdit.text)
                                }
                                TacticalButton {
                                    text: "CLEAR"
                                    variant: "danger"
                                    implicitHeight: 22
                                    reducedMotion: root.reducedMotion
                                    onClicked: {
                                        scratchEdit.text = ""
                                        if (root.utilities) root.utilities.setScratchpadText("")
                                    }
                                }
                            }

                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentWidth: width
                                contentHeight: Math.max(height, scratchEdit.contentHeight)
                                clip: true

                                TextEdit {
                                    id: scratchEdit
                                    width: parent.width
                                    height: Math.max(parent.height, contentHeight)
                                    text: root.utilities ? root.utilities.scratchpadText : ""
                                    color: Tokens.text
                                    selectionColor: Tokens.signal
                                    selectedTextColor: Tokens.textOnSignal
                                    font.family: Tokens.fontMono
                                    font.pixelSize: Tokens.fontBody
                                    wrapMode: TextEdit.Wrap
                                    onTextChanged: {
                                        if (root.utilities && root.utilities.scratchpadText !== text) {
                                            root.utilities.setScratchpadText(text)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: root.utilities ? root.utilities.statusNote : ""
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
