import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property bool reducedMotion: false
    property bool hudAutoHideOnFullscreen: true
    property real uiScale: 1.0
    property string clockText: "23:42:08"
    property string dateText: "TUE 10 NOV"
    property string uptimeText: "02h 14m"
    property string sysLabel: "SYS // ONLINE"
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

    function toggleReducedMotion() {
        reducedMotion = !reducedMotion
    }

    function toggleHudAutoHide() {
        hudAutoHideOnFullscreen = !hudAutoHideOnFullscreen
    }
}

