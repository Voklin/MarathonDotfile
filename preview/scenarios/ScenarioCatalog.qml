pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property var scenarios: [
        { id: "S01", label: "S01 // STANDARD 1080P", width: 1920, height: 1080, scale: 1.0, description: "Baseline alignment, active workspaces, 65% audio, Wi-Fi, 82% battery" },
        { id: "S02", label: "S02 // WIDE QHD 1440P", width: 2560, height: 1440, scale: 1.0, description: "Wide viewport bounds, QHD spacing and charging telemetry" },
        { id: "S03", label: "S03 // COMPACT 1366x768", width: 1366, height: 768, scale: 1.0, description: "Compact laptop layout + critical low battery (14%)" },
        { id: "S04", label: "S04 // HIDPI 1.5X", width: 1280, height: 720, scale: 1.5, description: "1920x1080 scaled at 1.5x logical viewport" },
        { id: "S05", label: "S05 // LONG UNICODE", width: 1366, height: 768, scale: 1.0, description: "90+ char Cyrillic/CJK/Unicode title elision test" },
        { id: "S06", label: "S06 // NETWORK OFFLINE", width: 1366, height: 768, scale: 1.0, description: "Network error & offline fallback verification" },
        { id: "S07", label: "S07 // AUDIO MUTED 0%", width: 1366, height: 768, scale: 1.0, description: "Audio & mic muted boundaries + OSD trigger" },
        { id: "S08", label: "S08 // MISSING SENSORS", width: 1366, height: 768, scale: 1.0, description: "Desktop rig: no battery, no backlight, no Bluetooth" },
        { id: "S09", label: "S09 // NOTIF FLOOD (16)", width: 1920, height: 1080, scale: 1.0, description: "16 notifications with mixed urgency & action buttons" },
        { id: "S10", label: "S10 // WORKSPACE MATRIX", width: 1920, height: 1080, scale: 1.0, description: "Dual monitor, urgent workspace, fullscreen HUD policy" }
    ]

    function findScenario(scenarioId) {
        for (var i = 0; i < scenarios.length; ++i) {
            if (scenarios[i].id === scenarioId) return scenarios[i]
        }
        return scenarios[0]
    }
}

