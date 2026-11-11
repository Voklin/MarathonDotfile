import QtQuick
import QtTest
import "../ui/tokens"
import "../ui/contracts"
import "../ui/screens"
import "../preview/mocks"
import "../preview/scenarios"

Item {
    id: testRoot
    width: 1366
    height: 768

    MockBackend {
        id: backend
    }

    ShellContracts {
        id: fallbackContracts
    }

    Stage2HarnessScreen {
        id: harnessScreen
        anchors.fill: parent
        backend: backend
    }

    SignalSpy {
        id: audioOsdSpy
        target: backend.audio
        signalName: "osdTriggered"
    }

    SignalSpy {
        id: brightnessOsdSpy
        target: backend.brightness
        signalName: "osdTriggered"
    }

    TestCase {
        name: "MarathonStage2Suite"
        when: windowShown

        function init() {
            backend.resetDefaults()
            audioOsdSpy.clear()
            brightnessOsdSpy.clear()
        }

        function test_design_tokens_and_motion() {
            compare(Tokens.background.toString(), "#080b0a")
            compare(Tokens.surface.toString(), "#141c18")
            compare(Tokens.signal.toString(), "#c9ff16")
            compare(Tokens.text.toString(), "#f0f4e8")
            compare(Tokens.alert.toString(), "#ff4268")
            compare(Tokens.motionMs(150, false), 150)
            compare(Tokens.motionMs(150, true), 0)
        }

        function test_fallback_contracts_safe_defaults() {
            compare(fallbackContracts.workspaces.available, false)
            compare(fallbackContracts.battery.available, false)
            compare(fallbackContracts.brightness.available, false)
            compare(fallbackContracts.notifications.unreadCount, 0)
            compare(fallbackContracts.launcher.filteredEntries().length, 0)
        }

        function test_all_ten_scenarios_deterministic() {
            var expectedIds = ["S01", "S02", "S03", "S04", "S05", "S06", "S07", "S08", "S09", "S10"]
            compare(ScenarioCatalog.scenarios.length, 10)
            for (var i = 0; i < expectedIds.length; ++i) {
                var sid = expectedIds[i]
                backend.applyScenario(sid)
                compare(backend.activeScenarioId, sid)
            }

            backend.applyScenario("S06")
            compare(backend.network.connected, false)
            verify(backend.network.errorMessage.length > 0)

            backend.applyScenario("S08")
            compare(backend.battery.available, false)
            compare(backend.brightness.available, false)
            compare(backend.bluetooth.available, false)

            backend.applyScenario("S09")
            verify(backend.notifications.items.length >= 15)

            backend.applyScenario("S10")
            verify(backend.workspaces.monitors.length >= 2)
            compare(backend.activeWindow.fullscreen, true)
        }

        function test_audio_and_brightness_clamping_signals() {
            backend.audio.setVolume(1.8)
            compare(backend.audio.volume, 1.0)
            compare(audioOsdSpy.count, 1)

            backend.audio.toggleMute()
            compare(backend.audio.muted, true)
            compare(audioOsdSpy.count, 2)

            backend.brightness.setLevel(-1.0)
            compare(backend.brightness.level, 0.05)
            compare(brightnessOsdSpy.count, 1)
        }

        function test_launcher_filter_and_recent_history() {
            backend.launcher.setQuery("ghostty")
            var res = backend.launcher.filteredEntries()
            verify(res.length >= 1)
            compare(res[0].id, "ghostty")

            backend.launcher.setQuery("")
            backend.launcher.launchEntry("btop")
            compare(backend.launcher.recentIds[0], "btop")
        }

        function test_session_confirmation_and_lock() {
            backend.session.requestAction("reboot")
            compare(backend.session.pendingAction, "reboot")
            backend.session.cancelAction()
            compare(backend.session.pendingAction, "")

            backend.session.requestAction("lock")
            compare(backend.session.locked, true)
            compare(backend.session.unlock("wrong"), false)
            compare(backend.session.locked, true)
            compare(backend.session.unlock("marathon"), true)
            compare(backend.session.locked, false)
        }
    }
}

