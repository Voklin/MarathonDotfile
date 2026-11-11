import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property bool available: Mpris.players !== null
    property bool loading: false
    property string errorMessage: available ? "" : "MPRIS D-BUS UNAVAILABLE"
    property string activePlayerId: ""
    property int _tickBump: 0

    readonly property var _rawPlayers: (available && Mpris.players && Mpris.players.values) ? Mpris.players.values : []

    readonly property var _activeRaw: {
        if (_rawPlayers.length === 0) return null
        if (activePlayerId !== "") {
            for (var i = 0; i < _rawPlayers.length; ++i) {
                var p = _rawPlayers[i]
                if (p && String(p.dbusName || p.identity) === activePlayerId) return p
            }
        }
        for (var j = 0; j < _rawPlayers.length; ++j) {
            if (_rawPlayers[j] && _rawPlayers[j].isPlaying) return _rawPlayers[j]
        }
        return _rawPlayers[0] || null
    }

    readonly property var players: {
        var out = []
        for (var i = 0; i < _rawPlayers.length; ++i) {
            var p = _rawPlayers[i]
            if (!p) continue
            var pid = String(p.dbusName || p.identity || ("player-" + i))
            out.push({
                id: pid,
                identity: String(p.identity || "MEDIA").toUpperCase(),
                trackTitle: String(p.trackTitle || "Unknown Track"),
                artist: String(p.trackArtist || ""),
                album: String(p.trackAlbum || ""),
                artUrl: String(p.trackArtUrl || ""),
                playing: p.isPlaying === true,
                position: Number(p.position || 0),
                length: Number(p.length || 0),
                canPlay: p.canPlay === true,
                canPause: p.canPause === true,
                canNext: p.canGoNext === true,
                canPrev: p.canGoPrevious === true
            })
        }
        return out
    }

    readonly property bool hasPlayer: available && _activeRaw !== null
    readonly property string identity: _activeRaw ? String(_activeRaw.identity || "MEDIA").toUpperCase() : ""
    readonly property string trackTitle: _activeRaw ? String(_activeRaw.trackTitle || "Unknown Track") : ""
    readonly property string artist: _activeRaw ? String(_activeRaw.trackArtist || "") : ""
    readonly property string album: _activeRaw ? String(_activeRaw.trackAlbum || "") : ""
    readonly property string artUrl: _activeRaw ? String(_activeRaw.trackArtUrl || "") : ""
    readonly property bool playing: _activeRaw ? (_activeRaw.isPlaying === true) : false
    readonly property real position: {
        var _bump = _tickBump
        return _activeRaw ? Number(_activeRaw.position || 0) : 0
    }
    readonly property real length: _activeRaw ? Number(_activeRaw.length || 0) : 0
    readonly property bool canPlay: _activeRaw ? (_activeRaw.canPlay === true) : false
    readonly property bool canPause: _activeRaw ? (_activeRaw.canPause === true) : false
    readonly property bool canNext: _activeRaw ? (_activeRaw.canGoNext === true) : false
    readonly property bool canPrev: _activeRaw ? (_activeRaw.canGoPrevious === true) : false

    property Timer _posTimer: Timer {
        interval: 1000
        repeat: true
        running: root.hasPlayer && root.playing
        onTriggered: root._tickBump = (root._tickBump + 1) % 100000
    }

    function selectPlayer(id) {
        activePlayerId = id || ""
    }

    function togglePlay() {
        if (!_activeRaw) return
        if (_activeRaw.isPlaying && _activeRaw.canPause) _activeRaw.togglePlaying()
        else if (!_activeRaw.isPlaying && _activeRaw.canPlay) _activeRaw.togglePlaying()
    }

    function next() {
        if (_activeRaw && _activeRaw.canGoNext) _activeRaw.next()
    }

    function previous() {
        if (_activeRaw && _activeRaw.canGoPrevious) _activeRaw.previous()
    }

    function seekBy(seconds) {
        if (_activeRaw && _activeRaw.canSeek) _activeRaw.seek(seconds)
    }
}
