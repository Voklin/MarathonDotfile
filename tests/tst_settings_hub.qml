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

    SettingsHubPanel {
        id: hubPanel
        anchors.fill: parent
        backend: backend
        open: false
        reducedMotion: true
    }

    TestCase {
        name: "MarathonSettingsHubSuite"
        when: windowShown

        function init() {
            backend.resetDefaults()
            backend.settings.resetAllDefaults()
            backend.settings.setSection("profile")
            backend.settings.setSearchQuery("")
            desktopShell.closeAllPanels()
            hubPanel.open = false
        }

        function cleanup() {
            backend.settings.resetAllDefaults()
            Tokens.resetVisualDefaults()
        }

        function test_all_sections_navigation_and_search_filtering() {
            desktopShell.openPanel("settings")
            compare(desktopShell.settingsOpen, true)

            hubPanel.open = true
            compare(hubPanel.visible, true)
            compare(hubPanel.sections.length, 17)

            for (var i = 0; i < hubPanel.sections.length; ++i) {
                var sec = hubPanel.sections[i]
                hubPanel.selectSection(sec.id)
                compare(backend.settings.activeSection, sec.id)
                compare(hubPanel.activeMeta.id, sec.id)
            }

            backend.settings.setSearchQuery("touchpad")
            verify(hubPanel.searchMatches.length >= 1)
            compare(hubPanel.searchMatches[0].sectionId, "input")

            // First ESC clears active search query before closing hub
            keyClick(Qt.Key_Escape)
            compare(backend.settings.searchQuery, "")
            compare(hubPanel.open, true)
        }

        function test_visual_tokens_live_reactivity_and_reset() {
            var baseBg = Tokens.background.toString()
            backend.settings.setSetting("surfaceTheme", "DEEP_VOID")
            verify(Tokens.background.toString() !== baseBg)

            backend.settings.setSetting("surfaceTheme", "STEALTH_SLATE")
            compare(Tokens.surfaceTheme, "STEALTH_SLATE")

            var cyanSwatch = Tokens.accentSwatches[2].hex
            backend.settings.setSetting("customAccentHex", cyanSwatch)
            compare(Tokens.customAccentHex, cyanSwatch)
            verify(backend.settings.generatedHyprConf.indexOf("00f0ffff") !== -1)

            backend.settings.setSetting("cornerRadius", 4)
            compare(Tokens.cornerRadius, 4)

            backend.settings.setSetting("borderThickness", 2)
            compare(Tokens.borderWidth, 2)

            backend.settings.setSetting("hudHeight", 44)
            compare(Tokens.hudHeight, 44)

            backend.settings.setSetting("motionMultiplier", 0.5)
            compare(Tokens.motionMs(200, false), 100)

            backend.settings.resetSection("appearance")
            compare(Tokens.surfaceTheme, "TACTICAL")
            compare(Tokens.customAccentHex, "")
            compare(Tokens.cornerRadius, 0)
            compare(Tokens.borderWidth, 1)
        }

        function test_hud_edge_wallpaper_and_overlay_settings() {
            backend.applyScenario("S10")
            compare(desktopShell.hudAllMonitors, true)
            backend.settings.setSetting("hudPosition", "bottom")
            compare(desktopShell.hudPos, "bottom")

            backend.settings.setSetting("hudMultiMonitorAll", false)
            compare(desktopShell.hudAllMonitors, false)

            backend.settings.setSetting("wallpaperAccentSync", true)
            backend.settings.setSetting("wallpaperId", "grid-4k")
            compare(Tokens.factionId, "CYBERACME")

            backend.settings.setSetting("toastPosition", "bottom-right")
            compare(desktopShell.toastAnchor, "bottom-right")

            backend.settings.setSetting("toastMaxVisible", 2)
            compare(backend.settings.toastMaxVisible, 2)

            backend.settings.setSetting("osdEnabled", false)
            compare(backend.settings.osdEnabled, false)
        }

        function test_hyprland_compositor_displays_binds_rules_autostart_generation() {
            backend.settings.setSetting("hyprLayout", "master")
            backend.settings.setSetting("hyprGapsIn", 10)
            backend.settings.setSetting("hyprRounding", 4)
            backend.settings.setSetting("hyprBlurEnabled", true)
            backend.settings.setSetting("kbLayout", "us,ru")
            backend.settings.setSetting("defaultTerminal", "kitty")
            backend.settings.setSetting("bareSuperLauncher", true)

            var conf = backend.settings.generatedHyprConf
            verify(conf.indexOf("layout = master") !== -1)
            verify(conf.indexOf("gaps_in = 10") !== -1)
            verify(conf.indexOf("rounding = 4") !== -1)
            verify(conf.indexOf("kb_layout = us,ru") !== -1)
            verify(conf.indexOf("$terminal = kitty") !== -1)
            verify(conf.indexOf("SUPER_L, global, marathon-tactical:launcher") !== -1)

            backend.settings.updateDisplayConfig("eDP-1", { scale: 1.5, transform: 1, mode: "1920x1080@60" })
            verify(backend.settings.generatedHyprConf.indexOf("monitor = eDP-1, 1920x1080@60, 0x0, 1.50, transform, 1") !== -1)

            backend.settings.addCustomKeybind("SUPER+SHIFT", "M", "exec", "btop")
            verify(backend.settings.generatedHyprConf.indexOf("bind = SUPER+SHIFT, M, exec, btop") !== -1)
            var addedKbId = backend.settings.customKeybinds[backend.settings.customKeybinds.length - 1].id
            backend.settings.toggleCustomKeybind(addedKbId)
            compare(backend.settings.generatedHyprConf.indexOf("bind = SUPER+SHIFT, M, exec, btop"), -1)
            backend.settings.removeCustomKeybind(addedKbId)

            backend.settings.addWindowRule("float-mpv", "class", "^(mpv)$", true, true, true)
            conf = backend.settings.generatedHyprConf
            verify(conf.indexOf("name = float-mpv") !== -1)
            verify(conf.indexOf("match:class = ^(mpv)$") !== -1)
            verify(conf.indexOf("pin = on") !== -1)

            backend.settings.addAutostart("Wayvnc", "wayvnc")
            backend.settings.addEnvVar("QT_QPA_PLATFORM", "wayland")
            conf = backend.settings.generatedHyprConf
            verify(conf.indexOf("exec-once = wayvnc") !== -1)
            verify(conf.indexOf("env = QT_QPA_PLATFORM,wayland") !== -1)
        }

        function test_json_export_apply_and_launcher_safe_command() {
            var jsonStr = backend.settings.exportSettingsJson()
            var parsed = JSON.parse(jsonStr)
            compare(parsed.hudPosition, "top")
            compare(parsed.hyprLayout, "dwindle")
            compare(parsed.kbLayout, "us")

            backend.settings.setSetting("hudHeight", 42)
            compare(backend.settings.dirty, true)
            backend.settings.applyAll()
            compare(backend.settings.dirty, false)

            var hasOpenSettingsCmd = false
            for (var i = 0; i < backend.launcher.safeCommands.length; ++i) {
                if (backend.launcher.safeCommands[i].id === "open-settings") {
                    hasOpenSettingsCmd = true
                    break
                }
            }
            verify(hasOpenSettingsCmd)

            desktopShell.handleSafeCommand("open-settings")
            compare(desktopShell.settingsOpen, true)
        }
    }
}
