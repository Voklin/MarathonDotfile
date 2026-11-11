pragma Singleton
import QtQuick

QtObject {
    id: tokens

    // Corporate Faction Theme selector ("RUNNER" | "CYBERACME" | "TRAXUS" | "SEKIGUCHI" | "NUCAL" | "MIDA")
    property string factionId: "RUNNER"
    readonly property var factions: [
        { id: "RUNNER", label: "RUNNER // LIME", corp: "UESC // RUNNER" },
        { id: "CYBERACME", label: "CYAC // CYAN", corp: "CYBERACME // SYS" },
        { id: "TRAXUS", label: "TRAXUS // ORANGE", corp: "TRAXUS // HEAVY" },
        { id: "SEKIGUCHI", label: "SEKGEN // MINT", corp: "SEKIGUCHI // BIO" }
    ]

    // Runner Emblem & Calling Card System (Emblem Graphic + User-Editable Name & Custom Title)
    property string emblemId: "U73_CRUCIFORM"
    property string runnerName: "RUNNER"
    property string runnerTitle: "OPERATOR"
    readonly property var emblems: [
        { id: "U73_CRUCIFORM", code: "U73 // PURE", motif: "cruciform" },
        { id: "S50_BOWTIE", code: "BA-SR-001", motif: "bowtie" },
        { id: "M03_HEXCORE", code: "M03 // FD4", motif: "hexcore" },
        { id: "N35_CHECKER", code: "N35 // KX8", motif: "checker" },
        { id: "TRAXUS_ORBIT", code: "TRX // 090", motif: "orbit" },
        { id: "ONI_SIGNAL", code: "CYAC // ONI", motif: "pill_plus" }
    ]

    readonly property var activeEmblem: {
        for (var i = 0; i < emblems.length; ++i) {
            if (emblems[i].id === emblemId) return emblems[i]
        }
        return emblems[0]
    }

    function setEmblem(nextId) {
        var upper = (nextId || "U73_CRUCIFORM").toUpperCase()
        for (var i = 0; i < emblems.length; ++i) {
            if (emblems[i].id === upper) {
                emblemId = upper
                return
            }
        }
    }

    function cycleEmblem() {
        for (var i = 0; i < emblems.length; ++i) {
            if (emblems[i].id === emblemId) {
                emblemId = emblems[(i + 1) % emblems.length].id
                return
            }
        }
        emblemId = emblems[0].id
    }

    function setRunnerName(nextName) {
        var trimmed = (nextName || "").trim()
        runnerName = trimmed !== "" ? trimmed : "RUNNER"
    }

    function setRunnerTitle(nextTitle) {
        var trimmed = (nextTitle || "").trim()
        runnerTitle = trimmed !== "" ? trimmed : "OPERATOR"
    }

    function setFaction(nextId) {
        var upper = (nextId || "RUNNER").toUpperCase()
        if (upper === "RUNNER" || upper === "CYBERACME" || upper === "TRAXUS" || upper === "SEKIGUCHI") {
            factionId = upper
        }
    }

    function cycleFaction() {
        var order = ["RUNNER", "CYBERACME", "TRAXUS", "SEKIGUCHI"]
        var idx = order.indexOf(factionId)
        factionId = order[(idx + 1) % order.length]
    }

    // Visual customization state (driven by Settings Hub; defaults match DESIGN_SYSTEM.md)
    property string surfaceTheme: "TACTICAL" // "TACTICAL" | "DEEP_VOID" | "STEALTH_SLATE"
    property string customAccentHex: ""
    property int cornerRadius: 0
    property int borderThickness: 1
    property real uiScale: 1.0
    property real motionMultiplier: 1.0
    property int hudBarHeight: 38

    readonly property var surfaceThemes: [
        { id: "TACTICAL", label: "TACTICAL", desc: "Baseline Marathon Void (#080B0A / #141C18)" },
        { id: "DEEP_VOID", label: "DEEP VOID", desc: "Ultra-dark stealth contrast (#040605 / #0D1210)" },
        { id: "STEALTH_SLATE", label: "STEALTH SLATE", desc: "Cool dark tactical slate (#0B0E11 / #161B21)" }
    ]

    readonly property var accentSwatches: [
        { id: "", label: "FACTION", hex: "" },
        { id: "#C9FF16", label: "ACID LIME", hex: "#C9FF16" },
        { id: "#00F0FF", label: "CYAC CYAN", hex: "#00F0FF" },
        { id: "#FF8800", label: "TRAXUS ORG", hex: "#FF8800" },
        { id: "#39FF88", label: "SEKGEN MNT", hex: "#39FF88" },
        { id: "#F2B705", label: "AMBER OPS", hex: "#F2B705" },
        { id: "#FF5E7E", label: "ROSE PULSE", hex: "#FF5E7E" },
        { id: "#A78BFA", label: "VIOLET UESC", hex: "#A78BFA" }
    ]

    function isValidHexColor(hex) {
        return /^#[0-9A-Fa-f]{6}$/.test((hex || "").trim())
    }

    function setSurfaceTheme(nextTheme) {
        var upper = (nextTheme || "TACTICAL").toUpperCase()
        if (upper === "TACTICAL" || upper === "DEEP_VOID" || upper === "STEALTH_SLATE") {
            surfaceTheme = upper
        }
    }

    function setCustomAccent(hex) {
        var clean = (hex || "").trim().toUpperCase()
        if (clean === "") {
            customAccentHex = ""
            return true
        }
        if (isValidHexColor(clean)) {
            customAccentHex = clean
            return true
        }
        return false
    }

    function setCornerRadius(px) {
        var v = Math.round(Number(px))
        if (!isNaN(v)) cornerRadius = Math.max(0, Math.min(8, v))
    }

    function setBorderThickness(px) {
        var v = Math.round(Number(px))
        if (!isNaN(v)) borderThickness = Math.max(1, Math.min(3, v))
    }

    function setUiScale(val) {
        var v = Number(val)
        if (!isNaN(v)) uiScale = Math.max(0.85, Math.min(1.5, Math.round(v * 20) / 20.0))
    }

    function setMotionMultiplier(val) {
        var v = Number(val)
        if (!isNaN(v)) motionMultiplier = Math.max(0.5, Math.min(1.5, Math.round(v * 10) / 10.0))
    }

    function setHudBarHeight(px) {
        var v = Math.round(Number(px))
        if (!isNaN(v)) hudBarHeight = Math.max(30, Math.min(52, v))
    }

    function resetVisualDefaults() {
        factionId = "RUNNER"
        surfaceTheme = "TACTICAL"
        customAccentHex = ""
        cornerRadius = 0
        borderThickness = 1
        uiScale = 1.0
        motionMultiplier = 1.0
        hudBarHeight = 38
    }

    // Core MARATHON Tactical palette (docs/DESIGN_SYSTEM.md baseline + corporate faction accents + Settings Hub overrides)
    readonly property color background: surfaceTheme === "DEEP_VOID" ? "#040605"
        : (surfaceTheme === "STEALTH_SLATE" ? "#0B0E11" : "#080B0A")
    readonly property color voidBg: background
    readonly property color surface: surfaceTheme === "DEEP_VOID" ? "#0D1210"
        : (surfaceTheme === "STEALTH_SLATE" ? "#161B21" : "#141C18")
    readonly property color surfaceZebra: surfaceTheme === "DEEP_VOID" ? "#080C0A"
        : (surfaceTheme === "STEALTH_SLATE" ? "#11161C" : "#0F1512")
    readonly property color surfaceElevated: surfaceTheme === "DEEP_VOID" ? "#141C18"
        : (surfaceTheme === "STEALTH_SLATE" ? "#1E262E" : "#1A241F")
    readonly property color surfacePressed: surfaceTheme === "DEEP_VOID" ? "#070A09"
        : (surfaceTheme === "STEALTH_SLATE" ? "#0F1318" : "#0E1411")
    readonly property color surfaceOverlay: "#E6080B0A"
    readonly property color keycapBg: "#24302A"
    readonly property color rankBronze: "#9E7356"
    readonly property color rankBronzeDark: "#241913"

    readonly property color factionSignal: factionId === "CYBERACME" ? "#00F0FF"
        : (factionId === "TRAXUS" ? "#FF8800"
        : (factionId === "SEKIGUCHI" ? "#39FF88" : "#C9FF16"))
    readonly property color signal: isValidHexColor(customAccentHex) ? customAccentHex : factionSignal
    readonly property color signalMuted: isValidHexColor(customAccentHex)
        ? Qt.darker(signal, 1.35)
        : (factionId === "CYBERACME" ? "#00A8B5"
            : (factionId === "TRAXUS" ? "#C46800"
            : (factionId === "SEKIGUCHI" ? "#24B55D" : "#8FB812")))
    readonly property color signalSubtle: isValidHexColor(customAccentHex)
        ? Qt.rgba(signal.r, signal.g, signal.b, 0.15)
        : (factionId === "CYBERACME" ? "#2600F0FF"
            : (factionId === "TRAXUS" ? "#26FF8800"
            : (factionId === "SEKIGUCHI" ? "#2639FF88" : "#26C9FF16")))
    readonly property color signalBorder: isValidHexColor(customAccentHex)
        ? Qt.rgba(signal.r, signal.g, signal.b, 0.40)
        : (factionId === "CYBERACME" ? "#6600F0FF"
            : (factionId === "TRAXUS" ? "#66FF8800"
            : (factionId === "SEKIGUCHI" ? "#6639FF88" : "#66C9FF16")))

    readonly property color text: "#F0F4E8"
    readonly property color textOnSignal: (0.299 * signal.r + 0.587 * signal.g + 0.114 * signal.b) > 0.52 ? "#080B0A" : "#F0F4E8"
    readonly property color muted: "#99A89C"
    readonly property color textDisabled: "#67756A"

    readonly property color border: surfaceTheme === "STEALTH_SLATE" ? "#2B3A4A"
        : (factionId === "CYBERACME" ? "#1A4A52"
        : (factionId === "TRAXUS" ? "#523414"
        : (factionId === "SEKIGUCHI" ? "#1C4D30" : "#354D24")))
    readonly property color borderSubtle: surfaceTheme === "STEALTH_SLATE" ? "#1D2630"
        : (factionId === "CYBERACME" ? "#122E33"
        : (factionId === "TRAXUS" ? "#33200D"
        : (factionId === "SEKIGUCHI" ? "#13301F" : "#223118")))
    readonly property color borderStrong: surfaceTheme === "STEALTH_SLATE" ? "#41566C"
        : (factionId === "CYBERACME" ? "#28727D"
        : (factionId === "TRAXUS" ? "#7D4F1E"
        : (factionId === "SEKIGUCHI" ? "#2B7549" : "#4E7036")))

    readonly property color alert: "#FF4268"
    readonly property color alertSurface: "#2D1119"
    readonly property color alertSubtle: "#29FF4268"
    readonly property color warning: "#F2B705"

    // 4/8 px spacing rhythm
    readonly property int space2xs: 2
    readonly property int spaceXs: 4
    readonly property int spaceSm: 8
    readonly property int spaceMd: 12
    readonly property int spaceLg: 16
    readonly property int spaceXl: 24
    readonly property int space2xl: 32

    // Tactical geometry
    readonly property int borderWidth: borderThickness
    readonly property int focusBorderWidth: 2
    readonly property int radiusNone: cornerRadius
    readonly property int radiusSharp: Math.max(2, cornerRadius)
    readonly property int radiusSm: Math.max(4, cornerRadius)

    // Layout dimensions
    readonly property int hudHeight: hudBarHeight
    readonly property int hudInset: 8
    readonly property int hudCompactBreakpoint: 1440
    readonly property int controlHeightSm: 26
    readonly property int controlHeightMd: 32
    readonly property int controlHeightLg: 40
    readonly property int launcherWidth: 640
    readonly property int controlCenterWidth: 420
    readonly property int notificationCenterWidth: 380
    readonly property int osdWidth: 280
    readonly property int sessionMenuWidth: 480
    readonly property int settingsHubWidth: 1020
    readonly property int settingsHubHeight: 670
    readonly property int clipboardWidth: 640
    readonly property int clipboardHeight: 540
    readonly property int captureWidth: 560
    readonly property int captureHeight: 460
    readonly property int sysMonWidth: 780
    readonly property int sysMonHeight: 600
    readonly property int calendarNotesWidth: 720
    readonly property int calendarNotesHeight: 520
    readonly property int cheatsheetWidth: 860
    readonly property int cheatsheetHeight: 580

    function colorHex(c) {
        function h2(v) {
            var n = Math.max(0, Math.min(255, Math.round(v * 255)))
            var s = n.toString(16).toUpperCase()
            return s.length < 2 ? ("0" + s) : s
        }
        return "#" + h2(c.r) + h2(c.g) + h2(c.b)
    }

    function paletteSnapshot() {
        return {
            factionId: factionId,
            surfaceTheme: surfaceTheme,
            background: colorHex(background),
            surface: colorHex(surface),
            surfaceZebra: colorHex(surfaceZebra),
            surfaceElevated: colorHex(surfaceElevated),
            surfacePressed: colorHex(surfacePressed),
            signal: colorHex(signal),
            signalMuted: colorHex(signalMuted),
            text: colorHex(text),
            textOnSignal: colorHex(textOnSignal),
            muted: colorHex(muted),
            border: colorHex(border),
            borderStrong: colorHex(borderStrong),
            alert: colorHex(alert),
            warning: colorHex(warning),
            cornerRadius: cornerRadius,
            borderThickness: borderThickness
        }
    }

    // Typography (verified open-source stack on CachyOS, native crisp fallbacks on Windows)
    function pickFont(candidates, fallback) {
        var fams = Qt.fontFamilies()
        for (var i = 0; i < candidates.length; ++i) {
            if (fams.indexOf(candidates[i]) !== -1) return candidates[i]
        }
        return fallback
    }

    readonly property string fontUi: Qt.platform.os === "windows"
        ? pickFont(["Bahnschrift", "Segoe UI Variable", "Segoe UI"], "sans-serif")
        : pickFont(["Space Grotesk", "Inter", "IBM Plex Sans", "Noto Sans"], "sans-serif")
    readonly property string fontMono: Qt.platform.os === "windows"
        ? pickFont(["JetBrains Mono", "Consolas", "Cascadia Mono"], "monospace")
        : pickFont(["JetBrains Mono", "JetBrainsMono Nerd Font", "IBM Plex Mono", "DejaVu Sans Mono"], "monospace")
    readonly property int fontMicro: 10
    readonly property int fontLabel: 11
    readonly property int fontBody: 13
    readonly property int fontTitle: 15
    readonly property int fontHeading: 20
    readonly property int fontHero: 44

    // Motion & reducedMotion policy (100-200ms)
    readonly property int durationInstant: 0
    readonly property int durationFast: 100
    readonly property int durationNormal: 150
    readonly property int durationPanel: 200
    readonly property int easingType: Easing.OutCubic

    function motionMs(ms, reducedMotion) {
        return reducedMotion ? durationInstant : Math.round(ms * motionMultiplier)
    }
}
