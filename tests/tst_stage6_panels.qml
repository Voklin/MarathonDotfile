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

    ControlCenterPanel {
        id: ccPanel
        anchors.fill: parent
        backend: backend
        open: false
        reducedMotion: true
    }

    NotificationCenterPanel {
        id: notifPanel
        anchors.fill: parent
        notifications: backend.notifications
        open: false
        reducedMotion: true
    }

    OsdOverlay {
        id: osd
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        audio: backend.audio
        brightness: backend.brightness
        reducedMotion: true
    }

    SessionMenuPanel {
        id: sessionPanel
        anchors.fill: parent
        session: backend.session
        open: false
        reducedMotion: true
    }

    LockScreenOverlay {
        id: lockScreen
        anchors.fill: parent
        session: backend.session
        appearance: backend.appearance
        reducedMotion: true
    }

    TestCase {
        name: "MarathonStage6PanelsSuite"
        when: windowShown

        function init() {
            backend.resetDefaults()
            ccPanel.open = false
            notifPanel.open = false
            sessionPanel.open = false
            osd.active = false
        }

        function test_control_center_missing_sensors_and_actions() {
            backend.applyScenario("S08")
            ccPanel.open = true
            compare(backend.battery.available, false)
            compare(backend.brightness.available, false)
            compare(backend.bluetooth.available, false)

            backend.audio.setVolume(0.45)
            compare(osd.active, true)
            compare(osd.kind, "audio")
            compare(osd.level, 0.45)
        }

        function test_notification_flood_dnd_and_clear() {
            backend.applyScenario("S09")
            notifPanel.open = true
            compare(backend.notifications.items.length, 16)
            verify(backend.notifications.popupItems.length > 0)

            backend.notifications.toggleDnd()
            compare(backend.notifications.dnd, true)
            compare(backend.notifications.popupItems.length, 0)

            backend.notifications.clearAll()
            compare(backend.notifications.items.length, 0)
        }

        function test_session_confirmation_and_lock_screen() {
            sessionPanel.open = true
            backend.session.requestAction("shutdown")
            compare(backend.session.pendingAction, "shutdown")
            backend.session.confirmAction()
            compare(backend.session.pendingAction, "")
            verify(backend.session.statusMessage.indexOf("SIMULATED") !== -1)

            backend.session.lock()
            compare(lockScreen.visible, true)
            compare(backend.session.unlock("marathon"), true)
            compare(lockScreen.visible, false)
        }

        function test_brightness_osd_trigger() {
            backend.brightness.setLevel(0.90)
            compare(osd.active, true)
            compare(osd.kind, "brightness")
            compare(osd.level, 0.90)
        }
    }
}

