import QtQuick
import QtTest
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

    TopHudBar {
        id: filteredHud
        width: 1920
        backend: backend
        monitorName: "DP-2"
        visible: false
    }

    TestCase {
        name: "MarathonStage4HudSuite"
        when: windowShown

        function init() {
            backend.resetDefaults()
            desktopShell.width = 1366
            desktopShell.launcherOpen = false
            desktopShell.controlCenterOpen = false
            desktopShell.notificationsOpen = false
            desktopShell.sessionOpen = false
        }

        function test_workspace_switching_and_multimonitor_filter() {
            backend.applyScenario("S10")
            compare(backend.workspaces.monitors.length, 2)
            backend.workspaces.switchWorkspace(4)
            compare(backend.workspaces.activeWorkspaceId, 4)
        }

        function test_fullscreen_auto_hide_policy() {
            backend.applyScenario("S01")
            compare(backend.activeWindow.fullscreen, false)
            backend.activeWindow.toggleFullscreen()
            compare(backend.activeWindow.fullscreen, true)
            backend.appearance.toggleHudAutoHide()
            compare(backend.appearance.hudAutoHideOnFullscreen, false)
        }

        function test_compact_and_wide_breakpoints() {
            filteredHud.width = 1366
            compare(filteredHud.isCompact, true)
            filteredHud.width = 2560
            compare(filteredHud.isCompact, false)
        }

        function test_offline_and_missing_sensors_hud_resilience() {
            backend.applyScenario("S06")
            compare(backend.network.connected, false)
            backend.applyScenario("S08")
            compare(backend.battery.available, false)
            compare(backend.bluetooth.available, false)
        }
    }
}
