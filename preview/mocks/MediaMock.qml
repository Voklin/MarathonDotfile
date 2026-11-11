import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property string activePlayerId: "spotify"
    property var players: [
        {
            id: "spotify",
            identity: "SPOTIFY",
            trackTitle: "Sector 04 Extraction (Original Synth Mix)",
            artist: "UESC Telemetry Collective",
            album: "TAU CETI IV // ARCHIVE",
            artUrl: "",
            playing: true,
            position: 84,
            length: 236,
            canPlay: true,
            canPause: true,
            canNext: true,
            canPrev: true
        },
        {
            id: "mpv",
            identity: "MPV PLAYER",
            trackTitle: "Wayland Compositor Latency Capture.mkv",
            artist: "MARATHON LAB",
            album: "LOCAL MEDIA",
            artUrl: "",
            playing: false,
            position: 42,
            length: 410,
            canPlay: true,
            canPause: true,
            canNext: false,
            canPrev: false
        }
    ]

    readonly property var _activeObj: {
        for (var i = 0; i < players.length; ++i) {
            if (players[i].id === activePlayerId) return players[i]
        }
        return players.length > 0 ? players[0] : null
    }

    readonly property bool hasPlayer: available && _activeObj !== null
    readonly property string identity: _activeObj ? _activeObj.identity : ""
    readonly property string trackTitle: _activeObj ? _activeObj.trackTitle : ""
    readonly property string artist: _activeObj ? _activeObj.artist : ""
    readonly property string album: _activeObj ? _activeObj.album : ""
    readonly property string artUrl: _activeObj ? _activeObj.artUrl : ""
    readonly property bool playing: _activeObj ? _activeObj.playing : false
    readonly property real position: _activeObj ? _activeObj.position : 0
    readonly property real length: _activeObj ? _activeObj.length : 0
    readonly property bool canPlay: _activeObj ? _activeObj.canPlay : false
    readonly property bool canPause: _activeObj ? _activeObj.canPause : false
    readonly property bool canNext: _activeObj ? _activeObj.canNext : false
    readonly property bool canPrev: _activeObj ? _activeObj.canPrev : false

    property Timer _mockTick: Timer {
        interval: 1000
        repeat: true
        running: root.available && root.hasPlayer && root.playing
        onTriggered: {
            var next = []
            for (var i = 0; i < root.players.length; ++i) {
                var p = root.players[i]
                if (p.id === root.activePlayerId && p.playing) {
                    var pos = p.position + 1
                    if (p.length > 0 && pos >= p.length) pos = 0
                    next.push(Object.assign({}, p, { position: pos }))
                } else {
                    next.push(p)
                }
            }
            root.players = next
        }
    }

    function selectPlayer(id) {
        if (!available) return
        activePlayerId = id || ""
    }

    function togglePlay() {
        if (!available || !_activeObj) return
        var targetId = _activeObj.id
        var next = []
        for (var i = 0; i < players.length; ++i) {
            var p = players[i]
            next.push(p.id === targetId ? Object.assign({}, p, { playing: !p.playing }) : p)
        }
        players = next
    }

    function next() {
        if (!available || !_activeObj || !_activeObj.canNext) return
        var targetId = _activeObj.id
        var nextList = []
        for (var i = 0; i < players.length; ++i) {
            var p = players[i]
            if (p.id === targetId) {
                nextList.push(Object.assign({}, p, {
                    trackTitle: "Cryo Uplink Protocol // Track 02",
                    artist: "CyberAcme Audio",
                    position: 0,
                    playing: true
                }))
            } else {
                nextList.push(p)
            }
        }
        players = nextList
    }

    function previous() {
        if (!available || !_activeObj || !_activeObj.canPrev) return
        var targetId = _activeObj.id
        var nextList = []
        for (var i = 0; i < players.length; ++i) {
            var p = players[i]
            if (p.id === targetId) {
                nextList.push(Object.assign({}, p, {
                    trackTitle: "Sector 04 Extraction (Original Synth Mix)",
                    artist: "UESC Telemetry Collective",
                    position: 0,
                    playing: true
                }))
            } else {
                nextList.push(p)
            }
        }
        players = nextList
    }

    function seekBy(seconds) {
        if (!available || !_activeObj) return
        var targetId = _activeObj.id
        var nextList = []
        for (var i = 0; i < players.length; ++i) {
            var p = players[i]
            if (p.id === targetId) {
                var maxLen = p.length > 0 ? p.length : 9999
                var nextPos = Math.max(0, Math.min(maxLen, p.position + seconds))
                nextList.push(Object.assign({}, p, { position: nextPos }))
            } else {
                nextList.push(p)
            }
        }
        players = nextList
    }
}
