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

    ComponentGalleryScreen {
        id: gallery
        anchors.fill: parent
        z: -1
        backend: backend
    }

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        spacing: 8

        TacticalButton {
            id: btn
            text: "TEST"
            property int btnClicks: 0
            onClicked: btnClicks += 1
        }

        TacticalButton {
            id: disabledBtn
            text: "OFF"
            enabledState: false
            property int disabledClicks: 0
            onClicked: disabledClicks += 1
        }

        TacticalToggle {
            id: tog
            checked: false
            onToggled: function(next) { tog.checked = next }
        }

        TacticalSlider {
            id: slider
            value: 0.5
            onValueEdited: function(v) { slider.value = v }
        }

        TacticalTextField {
            id: field
            property int submittedCount: 0
            property int escCount: 0
            onTextSubmitted: submittedCount += 1
            onEscapePressed: escCount += 1
        }
    }

    ConfirmDialog {
        id: confirmDlg
        anchors.fill: parent
        visible: false
        actionName: "REBOOT"
        property int confirmedCount: 0
        property int cancelledCount: 0
        onConfirmed: confirmedCount += 1
        onCancelled: cancelledCount += 1
    }

    TestCase {
        name: "MarathonStage3ComponentsSuite"
        when: windowShown

        function test_button_click_and_disabled() {
            btn.btnClicks = 0
            mouseClick(btn)
            compare(btn.btnClicks, 1)

            btn.forceActiveFocus()
            keyClick(Qt.Key_Return)
            compare(btn.btnClicks, 2)

            disabledBtn.disabledClicks = 0
            mouseClick(disabledBtn)
            compare(disabledBtn.disabledClicks, 0)
        }

        function test_toggle_keyboard_and_mouse() {
            tog.checked = false
            mouseClick(tog)
            compare(tog.checked, true)
            tog.forceActiveFocus()
            keyClick(Qt.Key_Space)
            compare(tog.checked, false)
        }

        function test_slider_keyboard_step() {
            slider.value = 0.5
            slider.forceActiveFocus()
            keyClick(Qt.Key_Right)
            verify(slider.value > 0.5)
            keyClick(Qt.Key_Left)
            compare(slider.value, 0.5)
        }

        function test_textfield_input_and_escape() {
            field.text = ""
            field.focusInput()
            keyClick(Qt.Key_A)
            keyClick(Qt.Key_B)
            compare(field.text, "ab")
            keyClick(Qt.Key_Return)
            compare(field.submittedCount, 1)
            keyClick(Qt.Key_Escape)
            compare(field.escCount, 1)
        }

        function test_confirm_dialog_escape() {
            confirmDlg.visible = true
            confirmDlg.forceActiveFocus()
            keyClick(Qt.Key_Escape)
            compare(confirmDlg.cancelledCount, 1)
            confirmDlg.visible = false
        }

        function test_gallery_renders_cleanly() {
            verify(gallery.width === 1366)
            verify(gallery.height === 768)
        }
    }
}
