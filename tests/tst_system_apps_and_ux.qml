import QtQuick
import QtTest
import "../ui/tokens"
import "../ui/components"
import "../ui/screens"
import "../preview/mocks"

Item {
    id: testRoot
    width: 1366
    height: 768

    MockBackend {
        id: backend
    }

    DesktopShellScreen {
        id: desktopShell
        anchors.fill: parent
        backend: backend
    }

    LauncherPanel {
        id: launcherPanel
        anchors.fill: parent
        launcher: backend.launcher
        settings: backend.settings
        utilities: backend.utilities
        open: false
        reducedMotion: true
    }

    ClipboardPanel {
        id: clipboardPanel
        anchors.fill: parent
        utilities: backend.utilities
        open: false
        reducedMotion: true
    }

    CapturePanel {
        id: capturePanel
        anchors.fill: parent
        utilities: backend.utilities
        open: false
        reducedMotion: true
    }

    SystemMonitorPanel {
        id: sysMonPanel
        anchors.fill: parent
        utilities: backend.utilities
        audio: backend.audio
        open: false
        reducedMotion: true
    }

    CalendarNotesPanel {
        id: calendarPanel
        anchors.fill: parent
        utilities: backend.utilities
        appearance: backend.appearance
        open: false
        reducedMotion: true
    }

    CheatsheetPanel {
        id: cheatsheetPanel
        anchors.fill: parent
        settings: backend.settings
        utilities: backend.utilities
        open: false
        reducedMotion: true
    }

    SignalSpy {
        id: inlineCopySpy
        target: launcherPanel
        signalName: "inlineResultCopied"
    }

    SignalSpy {
        id: cheatActionSpy
        target: cheatsheetPanel
        signalName: "triggerActionRequested"
    }

    TestCase {
        name: "MarathonSystemAppsAndUxSuite"
        when: windowShown

        function init() {
            backend.resetDefaults()
            backend.settings.resetAllDefaults()
            Tokens.resetVisualDefaults()
            desktopShell.closeAllPanels()
            launcherPanel.open = false
            clipboardPanel.open = false
            capturePanel.open = false
            sysMonPanel.open = false
            calendarPanel.open = false
            cheatsheetPanel.open = false
            inlineCopySpy.clear()
            cheatActionSpy.clear()
        }

        function cleanup() {
            backend.settings.resetAllDefaults()
            Tokens.resetVisualDefaults()
        }

        function test_launcher_inline_calculator_units_colors_and_prefixes() {
            // Recursive-descent math evaluator
            var calc = launcherPanel.computeInlineResult("= (12 + 8) * 3")
            verify(calc !== null)
            compare(calc.kind, "CALC")
            compare(calc.title, "60")

            var fnCalc = launcherPanel.computeInlineResult("= sqrt(144) + 2^3")
            verify(fnCalc !== null)
            compare(fnCalc.title, "20")

            // Rejection of unsafe/arbitrary identifiers
            compare(launcherPanel.computeInlineResult("= process.exit(1)"), null)

            // Unit conversions
            var rem = launcherPanel.computeInlineResult("32px to rem")
            verify(rem !== null)
            compare(rem.kind, "UNIT")
            compare(rem.title, "2 REM")

            var mib = launcherPanel.computeInlineResult("16 gib in mib")
            verify(mib !== null)
            compare(mib.title, "16384 MIB")

            // Hex color converter
            var col = launcherPanel.computeInlineResult("=#C9FF16")
            verify(col !== null)
            compare(col.kind, "COLOR")
            verify(col.title.indexOf("rgb(201, 255, 22)") !== -1)
            verify(col.detail.indexOf("rgba(c9ff16ff)") !== -1)

            // Activation copies result to Utilities clipboard
            launcherPanel.open = true
            backend.launcher.setQuery("= 6 * 7")
            launcherPanel.refreshList()
            verify(launcherPanel.inlineComputation !== null)
            launcherPanel.activateCurrent()
            compare(inlineCopySpy.count, 1)
            compare(backend.utilities.lastCopiedText, "42")

            // Safe '>' command filter prefix
            backend.launcher.setQuery(">night")
            launcherPanel.refreshList()
            verify(launcherPanel.filteredItems.length >= 1)
            compare(launcherPanel.filteredItems[0].id, "toggle-nightlight")
        }

        function test_clipboard_vault_search_pin_copy_delete() {
            clipboardPanel.open = true
            verify(clipboardPanel.filteredItems.length >= 5)

            // Filter by query
            clipboardPanel.searchQuery = "pacman"
            compare(clipboardPanel.filteredItems.length, 1)

            clipboardPanel.searchQuery = ""
            var targetId = clipboardPanel.filteredItems[clipboardPanel.filteredItems.length - 1].id
            backend.utilities.togglePinClipboard(targetId)
            clipboardPanel.filterKind = "PINNED"
            var foundPinned = false
            for (var i = 0; i < clipboardPanel.filteredItems.length; ++i) {
                if (clipboardPanel.filteredItems[i].id === targetId) foundPinned = true
            }
            verify(foundPinned)

            clipboardPanel.filterKind = "ALL"
            clipboardPanel.selectedIndex = 0
            clipboardPanel.activateSelected()
            verify(backend.utilities.lastCopiedText !== "")

            var beforeDel = backend.utilities.clipboardItems.length
            backend.utilities.deleteClipboardItem(targetId)
            compare(backend.utilities.clipboardItems.length, beforeDel - 1)
        }

        function test_capture_suite_and_color_picker() {
            capturePanel.open = true
            var initialCaps = backend.utilities.recentCaptures.length
            capturePanel.annotateAfterCapture = true
            backend.utilities.captureRegion(capturePanel.annotateAfterCapture)
            compare(backend.utilities.recentCaptures.length, initialCaps + 1)
            verify(backend.utilities.recentCaptures[0].mode.indexOf("SATTY") !== -1)

            var prevColor = backend.utilities.lastPickedColor
            backend.utilities.pickColor()
            verify(backend.utilities.lastPickedColor !== prevColor)
            compare(backend.utilities.lastCopiedText, backend.utilities.lastPickedColor)
        }

        function test_sysmon_lifecycle_kill_and_per_app_audio_mixer() {
            compare(backend.utilities.monitorActive, false)
            sysMonPanel.open = true
            compare(backend.utilities.monitorActive, true)

            sysMonPanel.procFilter = "firefox"
            verify(sysMonPanel.filteredProcesses.length >= 1)
            compare(sysMonPanel.filteredProcesses[0].name, "firefox")

            var pidToKill = sysMonPanel.filteredProcesses[0].pid
            var countBefore = backend.utilities.processes.length
            backend.utilities.killProcess(pidToKill)
            compare(backend.utilities.processes.length, countBefore - 1)

            // Per-app PipeWire audio stream mixer
            var streamId = backend.utilities.audioStreams[0].id
            backend.utilities.setStreamVolume(streamId, 0.35)
            compare(Math.round(backend.utilities.audioStreams[0].volume * 100), 35)
            backend.utilities.toggleStreamMute(streamId)
            compare(backend.utilities.audioStreams[0].muted, true)

            sysMonPanel.open = false
            compare(backend.utilities.monitorActive, false)
        }

        function test_calendar_pomodoro_scratchpad_and_shell_routing() {
            calendarPanel.open = true
            compare(calendarPanel.calendarCells.length, 42)
            var origMonth = calendarPanel.viewMonth
            calendarPanel.stepMonth(1)
            compare(calendarPanel.viewMonth, (origMonth + 1) % 12)
            calendarPanel.jumpToday()
            compare(calendarPanel.viewMonth, origMonth)

            backend.utilities.setPomodoroPreset(5, "BREAK")
            compare(backend.utilities.pomodoroMode, "BREAK")
            compare(backend.utilities.pomodoroRemainingSec, 300)
            backend.utilities.togglePomodoro()
            compare(backend.utilities.pomodoroRunning, true)
            backend.utilities.resetPomodoro()
            compare(backend.utilities.pomodoroRunning, false)
            compare(backend.utilities.pomodoroRemainingSec, 300)

            backend.utilities.setScratchpadText("DEPLOY CHECKLIST OK")
            compare(backend.utilities.scratchpadText, "DEPLOY CHECKLIST OK")

            // Verify shell routing of all new panels + Control Center media/toggles
            desktopShell.openPanel("clipboard")
            compare(desktopShell.clipboardOpen, true)
            desktopShell.openPanel("capture")
            compare(desktopShell.clipboardOpen, false)
            compare(desktopShell.captureOpen, true)
            desktopShell.openPanel("sysmon")
            compare(desktopShell.sysmonOpen, true)
            desktopShell.openPanel("calendar")
            compare(desktopShell.calendarOpen, true)
            desktopShell.openPanel("cheatsheet")
            compare(desktopShell.cheatsheetOpen, true)

            desktopShell.handleSafeCommand("toggle-nightlight")
            compare(backend.utilities.nightLightEnabled, true)
            backend.utilities.setNightLightTemp(3400)
            compare(backend.utilities.nightLightTemp, 3400)

            desktopShell.handleSafeCommand("toggle-gamemode")
            compare(backend.utilities.gameModeEnabled, true)
        }

        function test_cheatsheet_mpris_media_and_app_theme_sync() {
            cheatsheetPanel.open = true
            verify(cheatsheetPanel.combinedBindings.length >= 20)
            cheatsheetPanel.searchQuery = "clipboard"
            verify(cheatsheetPanel.combinedBindings.length >= 1)
            cheatsheetPanel.triggerActionRequested("open-clipboard")
            compare(cheatActionSpy.count, 1)

            // MPRIS media deck mock transitions
            compare(backend.media.playing, true)
            backend.media.togglePlay()
            compare(backend.media.playing, false)
            var trackBefore = backend.media.trackTitle
            backend.media.next()
            verify(backend.media.trackTitle !== trackBefore)

            // App theme live palette synchronization
            compare(backend.settings.appThemeSyncEnabled, true)
            backend.settings.setSetting("customAccentHex", "#00F0FF")
            verify(backend.settings.generatedAppThemesPreview.indexOf("#00F0FF") !== -1)
        }
    }
}
