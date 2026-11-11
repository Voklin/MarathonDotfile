pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../tokens"

Rectangle {
    id: root

    required property var appearance
    property var settings: null
    property var utilities: null
    property bool compact: false
    property bool calendarOpen: false

    signal clicked()

    readonly property bool showSeconds: settings ? settings.showClockSeconds : true
    readonly property bool showDate: settings ? settings.showDateInClock : true
    readonly property string formattedClock: {
        var raw = appearance ? appearance.clockText : "00:00:00"
        return showSeconds ? raw : raw.slice(0, 5)
    }
    readonly property bool showPomodoroPill: utilities && (utilities.pomodoroRunning || (utilities.pomodoroRemainingSec > 0 && utilities.pomodoroRemainingSec < utilities.pomodoroTotalSec))
    readonly property string pomodoroCompact: {
        if (!utilities) return ""
        var s = Math.max(0, Math.floor(utilities.pomodoroRemainingSec))
        var m = Math.floor(s / 60)
        var r = s % 60
        return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
    }

    implicitWidth: clockRow.implicitWidth + Tokens.spaceSm
    implicitHeight: Tokens.controlHeightSm
    radius: Tokens.cornerRadius
    color: root.calendarOpen
        ? Tokens.surfaceElevated
        : (clockMouse.containsMouse ? Tokens.surfacePressed : "transparent")
    border.width: (root.calendarOpen || clockMouse.containsMouse) ? Tokens.borderWidth : 0
    border.color: root.calendarOpen ? Tokens.signal : Tokens.borderStrong

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    RowLayout {
        id: clockRow
        anchors.centerIn: parent
        spacing: Tokens.spaceXs

        Rectangle {
            width: 4
            height: 14
            color: root.calendarOpen ? Tokens.signal : (root.showPomodoroPill ? Tokens.warning : Tokens.signal)
        }

        Text {
            text: root.formattedClock
            color: Tokens.text
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontLabel
            font.bold: true
        }

        Text {
            visible: !root.compact && root.showDate
            text: root.appearance ? ("| " + root.appearance.dateText) : ""
            color: Tokens.muted
            font.family: Tokens.fontMono
            font.pixelSize: Tokens.fontMicro
        }

        Rectangle {
            visible: root.showPomodoroPill
            width: pomoTxt.implicitWidth + 8
            height: 16
            color: Tokens.signal
            Text {
                id: pomoTxt
                anchors.centerIn: parent
                text: root.pomodoroCompact
                color: Tokens.textOnSignal
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.fontMicro
                font.bold: true
            }
        }
    }
}
