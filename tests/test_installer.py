"""Behavioral installer tests; all mutations stay inside a temporary HOME."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = os.environ.get("MARATHON_TEST_BASH") or shutil.which("bash")


def shell_path(path):
    value = str(path).replace("\\", "/")
    if os.name == "nt" and len(value) > 1 and value[1] == ":":
        return "/" + value[0].lower() + value[2:]
    return value


@unittest.skipUnless(BASH, "Bash required (or set MARATHON_TEST_BASH)")
class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="marathon-installer-")
        self.addCleanup(self.tmp.cleanup)
        self.bash = BASH
        if os.name == "nt" and Path(BASH).name.lower() == "sh.exe":
            # Invoke as bash, not sh: sh mode does not read BASH_ENV.
            self.bash = str(Path(self.tmp.name) / "bash.exe")
            shutil.copy2(BASH, self.bash)
        self.home = Path(self.tmp.name) / "home with spaces"
        self.home.mkdir()
        self.config = self.home / ".config"
        self.config.mkdir()
        self.target = self.config / "marathon-tactical"
        self.launcher = self.home / ".local/bin/marathon-tactical-session"
        (self.config / "hypr").mkdir()
        (self.config / "hypr/hyprland.conf").write_text("KEEP ORIGINAL\n")
        self.env = dict(os.environ, HOME=shell_path(self.home),
                        XDG_CONFIG_HOME=shell_path(self.config))
        if os.name == "nt":
            self.env["PATH"] = str(Path(BASH).parent) + os.pathsep + os.environ.get("PATH", "")
        self.env.pop("BASH_ENV", None)
        # BASH_ENV also supplies deterministic test doubles for failure tests.
        self.helper = Path(self.tmp.name) / "test-env.sh"
        self.helper.write_text("chmod() { return 0; }\n" if os.name == "nt" else "", encoding="utf-8")
        self.env["BASH_ENV"] = shell_path(self.helper)

    def run_script(self, script, *args, input="", ok=True):
        result = subprocess.run([self.bash, shell_path(ROOT / script), *args],
                                input=input.encode("utf-8"), capture_output=True,
                                env=self.env, cwd=self.tmp.name, timeout=45)
        result.stdout = result.stdout.decode("utf-8")
        result.stderr = result.stderr.decode("utf-8")
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def snapshot(self):
        return {str(p.relative_to(self.home)): (p.read_bytes() if p.is_file() else None)
                for p in self.home.rglob("*")}

    def install(self):
        self.run_script("scripts/install.sh", "--yes")

    def test_dry_run_and_cancel_do_not_write(self):
        before = self.snapshot()
        self.run_script("scripts/install.sh", "--dry-run")
        self.run_script("scripts/install.sh", input="n\n")
        self.assertEqual(self.snapshot(), before)

    def test_update_preserves_settings_and_unique_backups(self):
        with self.helper.open("a", encoding="utf-8") as stream:
            stream.write('date() { printf "20261111-120000\\n"; }\n')
        self.install()
        (self.target / "settings.json").write_text('{"accent":"lime"}')
        (self.target / "scratchpad.txt").write_text("MY NOTES")
        (self.target / "hypr/user-settings.conf").write_text("# MY BINDS")
        (self.target / "apps/generated/ghostty-colors").write_text("MY COLORS")
        self.install()
        self.install()
        self.assertEqual((self.target / "scratchpad.txt").read_text(), "MY NOTES")
        self.assertEqual((self.target / "hypr/user-settings.conf").read_text(), "# MY BINDS")
        self.assertEqual((self.target / "apps/generated/ghostty-colors").read_text(), "MY COLORS")
        self.assertIn("lime", (self.target / "settings.json").read_text())
        backups = list((self.config / "marathon-tactical-backups").iterdir())
        self.assertEqual(len(backups), 2)
        self.assertEqual((self.config / "hypr/hyprland.conf").read_text(), "KEEP ORIGINAL\n")

    def test_restore_without_backup_does_not_remove_profile(self):
        self.install()
        before = self.snapshot()
        result = self.run_script("scripts/uninstall.sh", "--restore-backup", "--yes", ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_restore_recreates_launcher_and_previous_profile(self):
        self.install()
        (self.target / "settings.json").write_text("OLD SETTINGS")
        self.install()
        (self.target / "settings.json").write_text("NEW SETTINGS")
        self.run_script("scripts/uninstall.sh", "--restore-backup", "--yes")
        self.assertEqual((self.target / "settings.json").read_text(), "OLD SETTINGS")
        self.assertTrue(self.launcher.is_file())
        self.run_script_path_syntax(self.launcher)
        stub = Path(self.tmp.name) / "Hyprland"
        stub.write_text(f'#!{shell_path(self.bash)}\nprintf "%s\\n" "$@"\n', encoding="utf-8")
        stub.chmod(0o755)
        self.env["PATH"] = self.tmp.name + os.pathsep + self.env["PATH"]
        result = subprocess.run([self.bash, shell_path(self.launcher), "test argument"],
                                capture_output=True, env=self.env, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.decode().splitlines(),
                         ["--config", shell_path(self.target / "hypr/hyprland.conf"), "test argument"])

    def run_script_path_syntax(self, path):
        result = subprocess.run([self.bash, "-n", shell_path(path)], capture_output=True, text=True, env=self.env)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_uninstall_dry_run_and_removal(self):
        self.install()
        before = self.snapshot()
        self.run_script("scripts/uninstall.sh", "--dry-run", "--yes")
        self.assertEqual(self.snapshot(), before)
        self.run_script("scripts/uninstall.sh", "--yes")
        self.assertFalse(self.target.exists())
        self.assertFalse(self.launcher.exists())
        self.assertTrue((self.config / "hypr/hyprland.conf").is_file())

    def test_relative_config_root_rejected_before_writes(self):
        self.env["XDG_CONFIG_HOME"] = "relative-config"
        result = self.run_script("scripts/install.sh", "--yes", ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.target.exists())

    def test_syntax(self):
        for path in [ROOT / "setup.sh", *sorted((ROOT / "scripts").glob("*.sh"))]:
            with self.subTest(path=path):
                self.assertNotIn(b"\r\n", path.read_bytes())
                self.run_script_path_syntax(path)

    def menu_environment(self):
        if os.name != "nt" and os.geteuid() == 0:
            self.skipTest("Interactive installer intentionally refuses root")
        if os.name == "nt":
            with self.helper.open("a", encoding="utf-8") as stream:
                stream.write('uname() { printf "Linux\\n"; }\n')

    def test_menu_eof_invalid_input_cancel_and_dry_run(self):
        self.menu_environment()
        before = self.snapshot()
        self.run_script("setup.sh", input="")
        result = self.run_script("setup.sh", input="bad\n0\n")
        self.assertIn("1–7", result.stdout)
        self.run_script("setup.sh", input="1\nn\nn\n0\n")
        self.run_script("setup.sh", input="1\nn\n")
        self.run_script("setup.sh", "--dry-run")
        self.assertEqual(self.snapshot(), before)

    def test_menu_install_default_does_not_apply_app_themes(self):
        self.menu_environment()
        result = self.run_script("setup.sh", input="1\nn\ny\n0\n")
        self.assertTrue((self.target / "shell/shell.qml").is_file(), result.stdout)
        self.assertFalse((self.config / "ghostty").exists())
        self.assertIn("Завершено", result.stdout)

    def test_menu_child_failure_is_reported(self):
        self.menu_environment()
        with self.helper.open("a", encoding="utf-8") as stream:
            stream.write('chmod() { return 23; }\n')
        result = self.run_script("setup.sh", input="1\nn\ny\n0\n")
        self.assertIn("ERROR", result.stdout)
        self.assertNotIn("Завершено", result.stdout)
        self.assertFalse(self.target.exists())

    def test_non_linux_menu_is_rejected(self):
        if os.name != "nt":
            self.skipTest("Requires non-Linux host")
        result = self.run_script("setup.sh", input="0\n", ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Linux", result.stderr)

    def test_launcher_directory_rejected(self):
        self.launcher.mkdir(parents=True)
        before = self.snapshot()
        result = self.run_script("scripts/install.sh", "--yes", ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_copy_failure_preserves_existing_installation(self):
        self.install()
        before = self.snapshot()
        with self.helper.open("a", encoding="utf-8") as stream:
            stream.write('cp() { return 24; }\n')
        result = self.run_script("scripts/install.sh", "--yes", ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_symlink_profile_rejected_without_touching_destination(self):
        outside = self.home / "unrelated"
        outside.mkdir()
        (outside / "keep.txt").write_text("KEEP")
        try:
            self.target.symlink_to(outside, target_is_directory=True)
        except OSError as error:
            self.skipTest(f"Host cannot create symlinks: {error}")
        for script in ("scripts/install.sh", "scripts/uninstall.sh"):
            result = self.run_script(script, "--yes", ok=False)
            self.assertNotEqual(result.returncode, 0)
        self.assertEqual((outside / "keep.txt").read_text(), "KEEP")


if __name__ == "__main__":
    unittest.main(verbosity=2)
