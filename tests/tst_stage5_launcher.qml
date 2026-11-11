import QtQuick
import QtTest
import "../ui/components"
import "../preview/mocks"

Item {
    id: testRoot
    width: 1366
    height: 768

    MockBackend {
        id: backend
    }

    LauncherPanel {
        id: launcherPanel
        anchors.fill: parent
        launcher: backend.launcher
        open: false
        reducedMotion: true
    }

    SignalSpy {
        id: closeSpy
        target: launcherPanel
        signalName: "closeRequested"
    }

    SignalSpy {
        id: launchSpy
        target: launcherPanel
        signalName: "entryLaunched"
    }

    SignalSpy {
        id: safeCmdSpy
        target: launcherPanel
        signalName: "safeCommandTriggered"
    }

    TestCase {
        name: "MarathonStage5LauncherSuite"
        when: windowShown

        function init() {
            backend.resetDefaults()
            launcherPanel.open = false
            closeSpy.clear()
            launchSpy.clear()
            safeCmdSpy.clear()
        }

        function test_search_keyboard_nav_and_launch() {
            launcherPanel.open = true
            verify(launcherPanel.filteredItems.length >= 10)
            compare(launcherPanel.selectedIndex, 0)

            keyClick(Qt.Key_Down)
            compare(launcherPanel.selectedIndex, 1)
            keyClick(Qt.Key_Up)
            compare(launcherPanel.selectedIndex, 0)

            keyClick(Qt.Key_N)
            keyClick(Qt.Key_V)
            keyClick(Qt.Key_I)
            keyClick(Qt.Key_M)
            compare(launcherPanel.filteredItems.length, 1)
            compare(launcherPanel.filteredItems[0].id, "nvim")

            keyClick(Qt.Key_Return)
            compare(launchSpy.count, 1)
            compare(closeSpy.count, 1)
            compare(backend.launcher.recentIds[0], "nvim")
        }

        function test_empty_state_and_escape_closes_immediately() {
            launcherPanel.open = true
            keyClick(Qt.Key_Z)
            keyClick(Qt.Key_Z)
            keyClick(Qt.Key_Z)
            compare(launcherPanel.filteredItems.length, 0)

            keyClick(Qt.Key_Escape)
            compare(closeSpy.count, 1)
        }

        function test_tab_switches_to_safe_commands_no_arbitrary_shell() {
            launcherPanel.open = true
            keyClick(Qt.Key_Tab)
            compare(launcherPanel.activeTab, "commands")
            verify(launcherPanel.filteredItems.length >= 4)

            keyClick(Qt.Key_Return)
            compare(safeCmdSpy.count, 1)
        }

        function test_grid_matrix_mode_2d_navigation() {
            launcherPanel.layoutMode = "grid"
            launcherPanel.open = true
            compare(launcherPanel.selectedIndex, 0)

            keyClick(Qt.Key_Right)
            compare(launcherPanel.selectedIndex, 1)
            keyClick(Qt.Key_Down)
            compare(launcherPanel.selectedIndex, 3)
            keyClick(Qt.Key_Left)
            compare(launcherPanel.selectedIndex, 2)
            keyClick(Qt.Key_Up)
            compare(launcherPanel.selectedIndex, 0)

            launcherPanel.layoutMode = "list"
        }
    }
}

