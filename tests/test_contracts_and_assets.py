#!/usr/bin/env python3
"""Contract parity, asset integrity, and Hyprland/shell safety checks for MARATHON Tactical."""

import re
import sys
import unittest
from pathlib import Path
import xml.etree.ElementTree as ET


REPO_ROOT = Path(__file__).resolve().parent.parent

CONTRACT_PAIRS = [
    ("WorkspacesMock.qml", "WorkspacesAdapter.qml"),
    ("ActiveWindowMock.qml", "ActiveWindowAdapter.qml"),
    ("AudioMock.qml", "AudioAdapter.qml"),
    ("NetworkMock.qml", "NetworkAdapter.qml"),
    ("BluetoothMock.qml", "BluetoothAdapter.qml"),
    ("BatteryMock.qml", "BatteryAdapter.qml"),
    ("BrightnessMock.qml", "BrightnessAdapter.qml"),
    ("NotificationsMock.qml", "NotificationsAdapter.qml"),
    ("SessionMock.qml", "SessionAdapter.qml"),
    ("LauncherMock.qml", "LauncherAdapter.qml"),
    ("AppearanceMock.qml", "AppearanceAdapter.qml"),
    ("SettingsMock.qml", "SettingsAdapter.qml"),
    ("MediaMock.qml", "MediaAdapter.qml"),
    ("UtilitiesMock.qml", "UtilitiesAdapter.qml"),
    ("TrayMock.qml", "TrayAdapter.qml"),
    ("KeyboardMock.qml", "KeyboardAdapter.qml"),
]

PROP_RE = re.compile(r"^\s*(?:readonly\s+)?property\s+\S+\s+(\w+)\s*:", re.MULTILINE)
SIGNAL_RE = re.compile(r"^\s*signal\s+(\w+)\s*\(", re.MULTILINE)
FUNC_RE = re.compile(r"^\s*function\s+(\w+)\s*\(", re.MULTILINE)

EXPECTED_ICONS = {
    "audio", "audio-muted", "mic", "mic-muted", "wifi", "wifi-off",
    "ethernet", "bluetooth", "bluetooth-off", "battery", "battery-charging",
    "brightness", "bell", "bell-off", "lock", "power", "reboot",
    "logout", "sleep", "search", "settings", "close", "check",
    "warning", "terminal", "grid", "chevron-right", "chevron-left",
    "clipboard", "capture", "play", "pause", "calendar", "cpu",
    "palette", "help",
}


class MarathonContractAndAssetTests(unittest.TestCase):
    def test_contract_parity_between_mocks_and_linux_adapters(self) -> None:
        for mock_name, adapter_name in CONTRACT_PAIRS:
            mock_text = (REPO_ROOT / "preview" / "mocks" / mock_name).read_text(encoding="utf-8")
            adapter_text = (REPO_ROOT / "shell" / "services" / adapter_name).read_text(encoding="utf-8")

            mock_props = set(PROP_RE.findall(mock_text))
            adapter_props = set(PROP_RE.findall(adapter_text))
            mock_sigs = set(SIGNAL_RE.findall(mock_text))
            adapter_sigs = set(SIGNAL_RE.findall(adapter_text))
            mock_funcs = set(FUNC_RE.findall(mock_text))
            adapter_funcs = set(FUNC_RE.findall(adapter_text))

            missing_props = sorted(p for p in mock_props if not p.startswith("_") and p not in adapter_props)
            missing_sigs = sorted(s for s in mock_sigs if s not in adapter_sigs)
            missing_funcs = sorted(f for f in mock_funcs if not f.startswith("_") and f not in adapter_funcs)

            self.assertEqual(missing_props, [], f"{adapter_name} missing mock properties: {missing_props}")
            self.assertEqual(missing_sigs, [], f"{adapter_name} missing mock signals: {missing_sigs}")
            self.assertEqual(missing_funcs, [], f"{adapter_name} missing mock methods: {missing_funcs}")

    def test_all_36_original_svg_icons_valid(self) -> None:
        icons_dir = REPO_ROOT / "design" / "icons"
        found = {p.stem for p in icons_dir.glob("*.svg")}
        self.assertEqual(found, EXPECTED_ICONS)
        for name in sorted(EXPECTED_ICONS):
            svg_path = icons_dir / f"{name}.svg"
            root = ET.fromstring(svg_path.read_text(encoding="utf-8"))
            self.assertTrue(root.tag.endswith("svg"))
            self.assertEqual(root.attrib.get("viewBox"), "0 0 16 16")

    def test_wallpapers_exist_with_valid_png_signature(self) -> None:
        wall_dir = REPO_ROOT / "design" / "wallpapers"
        for stem in ("marathon-grid-3840x2160", "marathon-grid-1920x1080", "marathon-lock-3840x2160"):
            svg_file = wall_dir / f"{stem}.svg"
            png_file = wall_dir / f"{stem}.png"
            self.assertTrue(svg_file.is_file(), f"Missing {svg_file}")
            self.assertTrue(png_file.is_file(), f"Missing {png_file}")
            data = png_file.read_bytes()
            self.assertTrue(data.startswith(b"\x89PNG\r\n\x1a\n"), f"Invalid PNG header: {png_file}")
            self.assertGreater(len(data), 1024, f"Unexpectedly tiny wallpaper PNG: {png_file}")

    def test_hyprland_config_safety_invariants(self) -> None:
        lua_files = sorted((REPO_ROOT / "hypr").rglob("*.lua"))
        self.assertGreaterEqual(len(lua_files), 10)
        self.assertTrue((REPO_ROOT / "hypr" / "hyprland.lua").is_file())
        self.assertTrue((REPO_ROOT / "hypr" / "user-settings.lua").is_file())
        self.assertFalse((REPO_ROOT / "hypr" / "hyprland.conf").exists(), "Legacy hyprland.conf must be replaced by hyprland.lua")
        for cfg in lua_files:
            txt = cfg.read_text(encoding="utf-8")
            active_lines = [ln.strip() for ln in txt.splitlines() if ln.strip() and not ln.strip().startswith("--")]
            active_body = "\n".join(active_lines)
            self.assertNotIn("windowrulev2", active_body, f"Deprecated windowrulev2 in {cfg}")
            self.assertNotIn("SUPER_L", active_body, f"Active bare Super_L hijack enabled in {cfg}")
            self.assertNotIn("~/.config/hypr/", active_body, f"Should not target ~/.config/hypr/ directly in {cfg}")
            self.assertNotIn("L_RIGHT", active_body, f"Invalid placeholder keysym in {cfg}")
        hypr_entry = (REPO_ROOT / "hypr" / "hyprland.lua").read_text(encoding="utf-8")
        self.assertIn('require("modules.binds")', hypr_entry)
        self.assertIn('require("user-settings")', hypr_entry)
        rules_lua = (REPO_ROOT / "hypr" / "modules" / "rules.lua").read_text(encoding="utf-8")
        self.assertIn("hl.window_rule", rules_lua)
        self.assertIn("hl.layer_rule", rules_lua)
        for aux_conf in ("hyprlock.conf", "hypridle.conf"):
            self.assertTrue((REPO_ROOT / "hypr" / aux_conf).is_file(), f"Missing {aux_conf}")

    def test_notifications_single_daemon_check_present(self) -> None:
        notif_adapter = (REPO_ROOT / "shell" / "services" / "NotificationsAdapter.qml").read_text(encoding="utf-8")
        session_adapter = (REPO_ROOT / "shell" / "services" / "SessionAdapter.qml").read_text(encoding="utf-8")
        doctor_sh = (REPO_ROOT / "scripts" / "doctor.sh").read_text(encoding="utf-8")
        self.assertIn("org.freedesktop.Notifications", notif_adapter)
        self.assertIn("NameHasOwner", notif_adapter)
        self.assertIn("Parsing.nameAvailable", notif_adapter)
        self.assertNotIn("get-name-owner", notif_adapter)
        self.assertNotIn("get-name-owner", doctor_sh)
        self.assertIn("CanSuspend", session_adapter)
        self.assertIn("Parsing.canSuspend", session_adapter)
        self.assertNotIn("can-suspend", session_adapter)
        for adapter_file in ("LauncherAdapter.qml", "NotificationsAdapter.qml", "UtilitiesAdapter.qml"):
            txt = (REPO_ROOT / "shell" / "services" / adapter_file).read_text(encoding="utf-8")
            self.assertIn("StateStore", txt, f"A11: StateStore missing in {adapter_file}")

    def test_shell_scripts_lf_and_isolation_safety(self) -> None:
        scripts_dir = REPO_ROOT / "scripts"
        for name in (
            "install.sh", "uninstall.sh", "doctor.sh", "test.sh",
            "copy-image.sh", "session-daemons.sh", "apply-themes.sh",
            "shell-ctl.sh", "onboarding.sh",
        ):
            path = scripts_dir / name
            self.assertTrue(path.is_file(), f"Missing script: {name}")
            raw = path.read_bytes()
            self.assertNotIn(b"\r\n", raw, f"CRLF line endings in {name}")
            txt = raw.decode("utf-8")
            self.assertTrue(txt.startswith("#!/usr/bin/env bash\n"), f"Invalid shebang in {name}")
            self.assertIn("set -euo pipefail", txt, f"Missing strict bash flags in {name}")
            self.assertNotIn("/usr/share/wayland-sessions", txt, f"Must not alter DM sessions in {name}")
        install_txt = (scripts_dir / "install.sh").read_text(encoding="utf-8")
        uninstall_txt = (scripts_dir / "uninstall.sh").read_text(encoding="utf-8")
        apply_txt = (scripts_dir / "apply-themes.sh").read_text(encoding="utf-8")
        self.assertIn("--dry-run", install_txt)
        self.assertIn("--install-deps", install_txt)
        self.assertIn("--no-deps", install_txt)
        self.assertIn("--dry-run", uninstall_txt)
        self.assertIn("--dry-run", apply_txt)
        self.assertIn("--restore", apply_txt)
        self.assertIn("marathon-tactical-app-backups", apply_txt)
        binds_txt = (REPO_ROOT / "hypr" / "modules" / "binds.lua").read_text(encoding="utf-8")
        self.assertNotIn("pkill -x quickshell", binds_txt, "A10: restart must target only MARATHON instance")
        ctl_txt = (scripts_dir / "shell-ctl.sh").read_text(encoding="utf-8")
        self.assertNotIn("pkill", ctl_txt.split("\n", 6)[-1])
        onboard_txt = (scripts_dir / "onboarding.sh").read_text(encoding="utf-8")
        self.assertFalse(any(l.lstrip().startswith(("sudo ", "install ")) and not l.startswith("  sudo") for l in onboard_txt.splitlines()), "onboarding must only print sudo commands")
        self.assertIn("marathon-tactical", install_txt)

    def test_external_app_configs_and_generated_palettes_present(self) -> None:
        apps_dir = REPO_ROOT / "apps"
        expected_files = [
            "README.md",
            "ghostty/config",
            "kitty/kitty.conf",
            "alacritty/alacritty.toml",
            "foot/foot.ini",
            "btop/btop.conf",
            "yazi/yazi.toml",
            "yazi/theme.toml",
            "starship/starship.toml",
            "fastfetch/config.jsonc",
            "gtk-3.0/settings.ini",
            "gtk-3.0/gtk.css",
            "gtk-3.0/widgets.css",
            "gtk-4.0/settings.ini",
            "gtk-4.0/gtk.css",
            "gtk-4.0/widgets.css",
            "qt6ct/qt6ct.conf",
            "mpv/mpv.conf",
            "mpv/input.conf",
            "imv/config",
            "zathura/zathurarc",
            "generated/ghostty-colors",
            "generated/kitty-colors.conf",
            "generated/alacritty-colors.toml",
            "generated/foot-colors.ini",
            "generated/btop-marathon.theme",
            "generated/yazi-colors.toml",
            "generated/gtk-colors.css",
            "generated/qt6ct-colors.conf",
        ]
        for rel in expected_files:
            self.assertTrue((apps_dir / rel).is_file(), f"Missing styled app config: apps/{rel}")
        self.assertTrue((REPO_ROOT / "hypr" / "hypridle.conf").is_file())
        self.assertTrue((REPO_ROOT / "scripts" / "packages-cachyos.txt").is_file())


if __name__ == "__main__":
    runner = unittest.main(verbosity=2, exit=False)
    sys.exit(0 if runner.result.wasSuccessful() else 1)
