import QtQuick

QtObject {
    id: root

    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property real volume: 0.65
    property bool muted: false
    property string sinkName: "UESC Tactical Headset (Analog)"
    property var sinks: [
        { id: "sink-headset", name: "UESC Tactical Headset", description: "Analog Stereo", active: true },
        { id: "sink-speakers", name: "Laptop Built-in Audio", description: "Internal Speaker", active: false },
        { id: "sink-hdmi", name: "HDMI / DisplayPort Out", description: "External Monitor", active: false }
    ]
    property bool micAvailable: true
    property bool micMuted: false
    property real micVolume: 0.80

    signal osdTriggered(string kind, real level, bool muted, string detail)

    function setVolume(nextVolume) {
        if (!available) return
        volume = Math.max(0.0, Math.min(1.0, nextVolume))
        if (volume > 0 && muted) muted = false
        osdTriggered("audio", volume, muted, sinkName)
    }

    function toggleMute() {
        if (!available) return
        muted = !muted
        osdTriggered("audio", volume, muted, sinkName)
    }

    function selectSink(id) {
        if (!available) return
        var next = []
        for (var i = 0; i < sinks.length; ++i) {
            var s = sinks[i]
            var active = (s.id === id)
            if (active) sinkName = s.name + " (" + s.description + ")"
            next.push({ id: s.id, name: s.name, description: s.description, active: active })
        }
        sinks = next
    }

    function toggleMicMute() {
        if (!available || !micAvailable) return
        micMuted = !micMuted
        osdTriggered("mic", micVolume, micMuted, "INTERNAL MIC")
    }

    function setMicVolume(nextVolume) {
        if (!available || !micAvailable) return
        micVolume = Math.max(0.0, Math.min(1.0, nextVolume))
        osdTriggered("mic", micVolume, micMuted, "INTERNAL MIC")
    }
}

