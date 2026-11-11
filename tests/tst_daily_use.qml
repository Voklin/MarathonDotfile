import QtQuick
import QtTest
import "../ui/logic/DesktopParsing.js" as Parsing
import "../preview/mocks" as Mocks
import "../ui/components" as Ui

TestCase {
    name: "DailyUseRegression"
    Mocks.AudioMock { id: audio }
    function test_nmcli_escaped_fields() {
        compare(Parsing.terseFields("*:Office\\:5G:80:WPA2"), ["*", "Office:5G", "80", "WPA2"])
        compare(Parsing.terseFields("a\\\\b:x"), ["a\\b", "x"])
        compare(Parsing.terseFields("*:Сеть:99:"), ["*", "Сеть", "99", ""])
    }
    function test_bus_probe_fails_closed() {
        compare(Parsing.nameAvailable(0, "b false"), true)
        compare(Parsing.nameAvailable(0, "b true"), false)
        compare(Parsing.nameAvailable(1, "b false"), false)
        compare(Parsing.nameAvailable(0, "garbage"), false)
    }
    function test_suspend_capability() {
        compare(Parsing.canSuspend(0, 's "yes"'), true)
        compare(Parsing.canSuspend(0, 's "challenge"'), true)
        compare(Parsing.canSuspend(1, 's "yes"'), false)
        compare(Parsing.canSuspend(0, 's "na"'), false)
    }
    function test_select_input() {
        audio.selectSource("mic-usb")
        compare(audio.sources.filter(function(s) { return s.active })[0].id, "mic-usb")
    }

    Mocks.TrayMock { id: tray }
    Mocks.KeyboardMock { id: keyboard }
    Ui.TrayStrip { id: strip; tray: tray; keyboard: keyboard; compact: true }

    function test_tray_contract_and_overflow() {
        compare(strip.shownItems.length, 2)
        compare(strip.hiddenCount, 1)
        strip.expanded = true
        compare(strip.shownItems.length, 3)
        compare(strip.hiddenCount, 0)
        strip.expanded = false
        tray.activate("telegram")
        compare(tray.lastAction, "activate:telegram")
        tray.secondaryActivate("nm-applet")
        compare(tray.lastAction, "secondary:nm-applet")
        tray.available = false
        compare(strip.allItems.length, 0)
        tray.available = true
    }

    function test_keyboard_layout_indicator() {
        compare(keyboard.shortCode, "EN")
        keyboard.nextLayout()
        compare(keyboard.shortCode, "RU")
        keyboard.nextLayout()
        compare(keyboard.shortCode, "EN")
    }
}
