import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property bool reducedMotion: false
    property bool hudAutoHideOnFullscreen: true
    property real uiScale: 1.0

    property SystemClock sysClock: SystemClock {
        id: clockSource
        precision: SystemClock.Seconds
        enabled: true
    }

    readonly property string clockText: Qt.formatDateTime(clockSource.date, "hh:mm:ss")
    readonly property string dateText: Qt.formatDateTime(clockSource.date, "ddd dd MMM").toUpperCase()
    property string uptimeText: "00h 00m"
    readonly property string sysLabel: "SYS // CACHYOS"
    property string faction: "RUNNER"
    property string emblem: "U73_CRUCIFORM"
    property string runnerName: "RUNNER"
    property string runnerTitle: "OPERATOR"

    function setFaction(nextFaction) {
        faction = (nextFaction || "RUNNER").toUpperCase()
    }

    function setEmblem(nextEmblem) {
        emblem = (nextEmblem || "U73_CRUCIFORM").toUpperCase()
    }

    function setRunnerName(nextName) {
        var trimmed = (nextName || "").trim()
        runnerName = trimmed !== "" ? trimmed : "RUNNER"
    }

    function setRunnerTitle(nextTitle) {
        var trimmed = (nextTitle || "").trim()
        runnerTitle = trimmed !== "" ? trimmed : "OPERATOR"
    }

    property FileView uptimeView: FileView {
        path: "/proc/uptime"
        onLoaded: {
            var raw = (uptimeView.text() || "").trim()
            var secs = parseFloat(raw.split(/\s+/)[0] || "0")
            if (!isNaN(secs) && secs >= 0) {
                var hrs = Math.floor(secs / 3600)
                var mins = Math.floor((secs % 3600) / 60)
                root.uptimeText = (hrs < 10 ? "0" : "") + hrs + "h " + (mins < 10 ? "0" : "") + mins + "m"
            }
        }
    }

    function refreshUptime() {
        uptimeView.reload()
    }

    function toggleReducedMotion() {
        reducedMotion = !reducedMotion
    }

    function toggleHudAutoHide() {
        hudAutoHideOnFullscreen = !hudAutoHideOnFullscreen
    }
}

