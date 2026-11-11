import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property PwNode defaultSink: Pipewire.defaultAudioSink
    readonly property PwNode defaultSource: Pipewire.defaultAudioSource

    readonly property var hardwareSinks: {
        var out = []
        if (!Pipewire.nodes || !Pipewire.nodes.values) return out
        var nodes = Pipewire.nodes.values
        for (var i = 0; i < nodes.length; ++i) {
            var n = nodes[i]
            if (n && n.isSink && !n.isStream && n.audio) out.push(n)
        }
        return out
    }

    readonly property var hardwareSources: {
        var out = []
        var nodes = Pipewire.nodes ? Pipewire.nodes.values : []
        for (var i = 0; i < nodes.length; ++i) {
            var n = nodes[i]
            if (n && !n.isSink && !n.isStream && n.audio) out.push(n)
        }
        return out
    }
    readonly property var sources: hardwareSources.map(function(n) {
        return { id: String(n.id), name: String(n.description || n.name), active: defaultSource !== null && n.id === defaultSource.id }
    })
    function selectSource(id) {
        for (var i = 0; i < hardwareSources.length; ++i) {
            if (String(hardwareSources[i].id) === String(id)) {
                Pipewire.preferredDefaultAudioSource = hardwareSources[i]
                return
            }
        }
    }

    readonly property var trackedObjects: {
        var objs = []
        if (defaultSink) objs.push(defaultSink)
        if (defaultSource) objs.push(defaultSource)
        for (var i = 0; i < hardwareSinks.length; ++i) {
            objs.push(hardwareSinks[i])
        }
        return objs.concat(hardwareSources)
    }

    property PwObjectTracker tracker: PwObjectTracker {
        objects: root.trackedObjects
    }

    property bool _settled: false
    property Timer settleTimer: Timer {
        interval: 450
        running: Pipewire.ready
        repeat: false
        onTriggered: root._settled = true
    }

    readonly property bool available: Pipewire.ready && defaultSink !== null && defaultSink.audio !== null
    property bool loading: !Pipewire.ready
    property string errorMessage: (!Pipewire.ready) ? "" : (defaultSink ? "" : "PIPEWIRE DEFAULT SINK ABSENT")

    readonly property real volume: (available && defaultSink.audio) ? Math.max(0.0, Math.min(1.0, defaultSink.audio.volume)) : 0.0
    readonly property bool muted: (available && defaultSink.audio) ? (defaultSink.audio.muted === true) : true
    readonly property string sinkName: {
        if (!defaultSink) return "NO AUDIO DEVICE"
        var desc = defaultSink.description || defaultSink.nickname || defaultSink.name || "Audio Sink"
        return String(desc)
    }

    readonly property var sinks: {
        var out = []
        for (var i = 0; i < hardwareSinks.length; ++i) {
            var s = hardwareSinks[i]
            out.push({
                id: String(s.id),
                name: String(s.description || s.nickname || s.name || ("Sink " + s.id)),
                description: String(s.name || ""),
                active: defaultSink !== null && s.id === defaultSink.id
            })
        }
        return out
    }

    readonly property bool micAvailable: Pipewire.ready && defaultSource !== null && defaultSource.audio !== null
    readonly property bool micMuted: (micAvailable && defaultSource.audio) ? (defaultSource.audio.muted === true) : true
    readonly property real micVolume: (micAvailable && defaultSource.audio) ? Math.max(0.0, Math.min(1.0, defaultSource.audio.volume)) : 0.0

    signal osdTriggered(string kind, real level, bool muted, string detail)

    property Connections sinkAudioConn: Connections {
        target: (root.defaultSink && root.defaultSink.audio) ? root.defaultSink.audio : null
        function onVolumeChanged() {
            if (root._settled && root.available) root.osdTriggered("audio", root.volume, root.muted, root.sinkName)
        }
        function onMutedChanged() {
            if (root._settled && root.available) root.osdTriggered("audio", root.volume, root.muted, root.sinkName)
        }
    }

    property Connections sourceAudioConn: Connections {
        target: (root.defaultSource && root.defaultSource.audio) ? root.defaultSource.audio : null
        function onMutedChanged() {
            if (root._settled && root.micAvailable) root.osdTriggered("mic", root.micVolume, root.micMuted, "INPUT SOURCE")
        }
    }

    function setVolume(nextVolume) {
        if (!available || !defaultSink.audio) return
        var clamped = Math.max(0.0, Math.min(1.0, nextVolume))
        defaultSink.audio.volume = clamped
        if (clamped > 0.0 && defaultSink.audio.muted) defaultSink.audio.muted = false
        osdTriggered("audio", clamped, defaultSink.audio.muted, sinkName)
    }

    function toggleMute() {
        if (!available || !defaultSink.audio) return
        defaultSink.audio.muted = !defaultSink.audio.muted
        osdTriggered("audio", volume, defaultSink.audio.muted, sinkName)
    }

    function selectSink(id) {
        if (!available) return
        for (var i = 0; i < hardwareSinks.length; ++i) {
            if (String(hardwareSinks[i].id) === String(id)) {
                Pipewire.preferredDefaultAudioSink = hardwareSinks[i]
                return
            }
        }
    }

    function toggleMicMute() {
        if (!micAvailable || !defaultSource.audio) return
        defaultSource.audio.muted = !defaultSource.audio.muted
        osdTriggered("mic", micVolume, defaultSource.audio.muted, "INPUT SOURCE")
    }

    function setMicVolume(nextVolume) {
        if (!micAvailable || !defaultSource.audio) return
        var clamped = Math.max(0.0, Math.min(1.0, nextVolume))
        defaultSource.audio.volume = clamped
        osdTriggered("mic", clamped, micMuted, "INPUT SOURCE")
    }
}

