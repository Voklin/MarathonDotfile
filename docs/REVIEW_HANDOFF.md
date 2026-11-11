# MARATHON Tactical — Review Handoff

## Publication verification — 2026-11-11

Owner explicitly requested publishing the current audit-remediation snapshot to GitHub. Fresh verification before push: 63 QtQuick tests PASS, 7 contract/asset tests PASS, 16 installer/script tests PASS and 1 symlink test SKIP (Windows WinError 1314); QML lint and syntax PASS (96 files). `git diff --check` passed. Windows script tests use test doubles for unsupported POSIX operations; these results do not establish live CachyOS readiness. No release is created.

## Daily-use audit & remediation (A01–A12) — 2026-11-11

All 12 findings (`A01`–`A12`) from [`DAILY_USE_AUDIT_2026-11-11.md`](DAILY_USE_AUDIT_2026-11-11.md) and [`DAILY_USE_FIX_PLAN.md`](DAILY_USE_FIX_PLAN.md) have been remediated locally (`ADR-009` in [`DECISIONS.md`](DECISIONS.md)):
- **A01 / A02 (D-Bus probes):** `NotificationsAdapter.qml` and `scripts/doctor.sh` now call `org.freedesktop.DBus.NameHasOwner` with an active `ownerTimeout` and fail-closed parser (`Parsing.nameAvailable`); `SessionAdapter.qml` calls `org.freedesktop.login1.Manager.CanSuspend` (`Parsing.canSuspend` accepts `"yes"` / `"challenge"`).
- **A03 / A06 / A08 (Wi-Fi, Bluetooth & `nmcli` escape parser):** `Parsing.terseFields()` handles escaped `:` and `\\` in SSIDs; `NetworkAdapter.qml` queries `IP4.ADDRESS`, connects open/saved networks directly, and falls back to `nm-connection-editor` for new secured/hidden networks; `BluetoothAdapter.qml` launches `blueman-manager`; `scripts/session-daemons.sh` starts `nm-applet --indicator` and `blueman-applet` when present; `SettingsSystemSections.qml` exposes explicit manager buttons and IPv4 sublabel.
- **A04 / A07 / A09 (SystemTray, Audio input source, XKB layout indicator):** Contract matrix expanded to **16 1:1 Mock <-> Adapter pairs** (`TrayMock`/`TrayAdapter` over `Quickshell.Services.SystemTray` and `KeyboardMock`/`KeyboardAdapter` over `hyprctl devices -j` + `activelayout` events). Added `ui/components/TrayStrip.qml` in `TopHudBar.qml` (with overflow toggle and `EN`/`RU` layout badge), `us,ru` + `grp:alt_shift_toggle` in `hypr/modules/input.conf`, and `sources` / `selectSource(id)` in `AudioMock`/`AudioAdapter` + `SettingsSystemSections.qml`.
- **A05 (Theme backup & symlink safety):** `scripts/apply-themes.sh` pre-validates all paths and manifests, uses `mktemp -d` for collision-free backups, replaces symlinks and managed CSS/conf atomically via temporary files + `mv -Tf` (never following existing symlinks on write), and marks restored snapshots `.restored` without deleting them.
- **A10 / A11 / A12 (Isolated lifecycle, bounded state, onboarding):** Added `scripts/shell-ctl.sh` (`start|restart|stop|status|log` verifying PID + `/proc/<pid>/cmdline` and rotating `~/.local/state/marathon-tactical/quickshell.log` at 1 MiB) and replaced `pkill -x quickshell` in `hypr/modules/binds.conf`; added `shell/services/StateStore.qml` (`atomicWrites: true`, `<=64 KiB`, storing only MRU IDs, `dnd` flag, and clipboard pin IDs); added `scripts/onboarding.sh` (`--check` and opt-in `--session-file` staging) and `firefox`/`neovim`/`network-manager-applet`/`blueman` in `scripts/packages-cachyos.txt`.
- **Fresh checks on Windows 11:** `python scripts/check_qml.py` (**96 QML files PASS**: 63 `ui/preview` + 33 `shell`, 0 violations), `python tests/run_tests.py` (**63/63 PASS**, including `DailyUseRegression` in `tests/tst_daily_use.qml`), `python tests/test_contracts_and_assets.py` (**7/7 PASS** across 16 contracts), and Windows QtQuick Preview PNG renders visually inspected (`TopHudBar` with `TrayStrip` + `EN` badge, `SettingsHub` Audio & Connections). Live CachyOS runtime checks remain **`NOT RUN — requires CachyOS`**.

## Current Stage
Stages 1–10 + Post-MVP GUI Settings Hub implemented on Windows 11 (`DONE Offline / CachyOS Verification Pending` — ready for live on-device verification on CachyOS Linux).

## Console Installer — 2026-11-11

- Scope: `setup.sh`, `scripts/profile-common.sh`, staging/unique backup in `install.sh`, preflight rollback and session-helper recovery in `uninstall.sh`, bounded version probes in `doctor.sh`, LF attributes, docs and isolated installer tests.
- Verification: 14 installer tests executed on Windows bundled Bash: **13 PASS / 1 SKIP** (OS denies symlink creation); `chmod` is stubbed, Linux menu environment simulated. Existing contract/asset suite: **7 PASS**. Bash syntax checks included in installer tests.
- Target-system validation: **NOT RUN — requires CachyOS** (permissions, app-theme symlinks, packages, Hyprland/Quickshell and actual GUI session). Installer does not install packages, register DM sessions or launch the compositor.
- After local implementation, the owner explicitly authorized committing and pushing this slice to GitHub. No release publication requested. See [`INSTALLER.md`](INSTALLER.md).

## Implemented Features
- **Design System & Pure UI (`ui/`):** Centralized reactive tokens ([`Tokens.qml`](../ui/tokens/Tokens.qml)), motion animations (`reducedMotion` & motion-multiplier-aware [`PanelReveal.qml`](../ui/animations/PanelReveal.qml)), 12 safe fallback contracts ([`ShellContracts.qml`](../ui/contracts/ShellContracts.qml)), reusable HUD, panel & Settings Hub components ([`ui/components/`](../ui/components/) including `SettingsHubPanel`, `SettingsShellSections`, `SettingsHyprSections`, `SettingsSystemSections`, `SettingsChoiceGroup`, `SettingsStepper`, `RunnerEmblemCard`), and `DesktopShellScreen` / `ComponentGalleryScreen` ([`ui/screens/`](../ui/screens/)).
- **GUI Settings Hub (17 Sections, 5 Groups):** Live cross-section search (`Ctrl+F` / `Ctrl+K` / `/`), faction & custom hex accents, surface themes (`TACTICAL`, `DEEP_VOID`, `STEALTH_SLATE`), radius/border/motion tokens, Top/Bottom HUD edge & 9 module toggles, wallpaper/crosshair matrix selector, Launcher/Toast/OSD/Lock/Session controls, Hyprland compositor/gaps/decorations/animations, monitor mode/scale/transform/position controls, keyboard/pointer/touchpad settings, default apps & custom bind builder, Hyprland `>=0.53` `match:` window rule builder, autostart/env/GPU controls, Audio/Power/Connections management, live generated `user-settings.conf` preview + JSON snapshot export, and 12-contract diagnostics matrix.
- **Windows QtQuick Preview (`preview/`):** 12 deterministic mock services ([`preview/mocks/`](../preview/mocks/), including [`SettingsMock.qml`](../preview/mocks/SettingsMock.qml)), 10 edge-case scenarios `S01`–`S10` ([`ScenarioCatalog.qml`](../preview/scenarios/ScenarioCatalog.qml)), interactive toolbar (`HUB` trigger) & `--section` CLI / automated screenshot exporter ([`run_preview.py`](../preview/run_preview.py)).
- **CachyOS Live Quickshell Layer (`shell/`):** [`shell.qml`](../shell/shell.qml) (`ShellRoot`, `GlobalShortcut` incl. `Super+,` `marathon-tactical:settings`, `IpcHandler` incl. `toggleSettings` / `openSettingsSection`), 12 live adapters ([`shell/services/`](../shell/services/), including [`SettingsAdapter.qml`](../shell/services/SettingsAdapter.qml)) matching mock contracts 1:1, `SettingsWindow`, `BackdropWindow`, D-Bus `org.freedesktop.Notifications` conflict check prior to enabling `NotificationServer`, `LazyLoader` overlay lifecycle, array-arg `Process` calls (zero shell interpolation wrappers).
- **Isolated Hyprland Profile (`hypr/`):** Modular `hyprlang` (`>=0.53` `match:` rules) in [`hyprland.conf`](../hypr/hyprland.conf) + `hypr/modules/*.conf` + isolated GUI-managed [`hypr/user-settings.conf`](../hypr/user-settings.conf), real PAM lockscreen in [`hyprlock.conf`](../hypr/hyprlock.conf), conflict-free default launcher triggers (`Super+Space` / `Super+D`, `Super+,`, [`KEYBINDINGS.md`](KEYBINDINGS.md)).
- **Original Vector & Raster Assets (`design/`):** 28 pixel-grid SVGs ([`design/icons/`](../design/icons/)), SIL OFL 1.1 typography guide ([`FONTS.md`](../design/typography/FONTS.md)), 4K & 1080p SVG/PNG geometric wallpapers ([`design/wallpapers/`](../design/wallpapers/)) generated by [`generate_assets.py`](../design/generate_assets.py).
- **Release Tooling & Docs (`scripts/`, `tests/`, `README.md`, `LICENSE`):** Safe isolated installer with `--dry-run`, `settings.json` preservation & `user-settings.conf` provisioning (`install.sh`), rollback uninstaller (`uninstall.sh`), read-only diagnostics (`doctor.sh`), unified test runner (`test.sh`), test plan ([`TEST_PLAN.md`](TEST_PLAN.md)), and automated test suites (`tests/`).

## Architecture Changes
- `ADR-001`–`ADR-007` documented in [`DECISIONS.md`](DECISIONS.md): strict 3-layer separation (`UI / State / Adapters`), `PySide6 6.12.0` Windows preview tooling, Hyprland `>=0.53` `match:` profile isolated to `~/.config/marathon-tactical/`, real PAM `hyprlock` delegation, safe `Super+Space`/`Super+D` launcher defaults, and post-MVP GUI Settings Hub isolated persistence (`settings.json` + `hypr/user-settings.conf`).

## Changed Files
- `README.md`, `LICENSE`
- `docs/DEVELOPMENT_STATUS.md`, `docs/REVIEW_HANDOFF.md`, `docs/DECISIONS.md`, `docs/ENVIRONMENT_REPORT.md`, `docs/KEYBINDINGS.md`, `docs/TEST_PLAN.md`, `docs/STATUS.md`, `docs/HANDOFF.md`
- `ui/` (`ui/tokens/`, `ui/animations/`, `ui/contracts/`, `ui/components/`, `ui/screens/`)
- `preview/` (`preview/Main.qml`, `preview/run_preview.py`, `preview/mocks/`, `preview/scenarios/`)
- `shell/` (`shell/shell.qml`, `shell/services/`, `shell/panels/`, `shell/settings/`, `shell/launcher/`, `shell/control-center/`, `shell/notifications/`, `shell/osd/`)
- `hypr/` (`hypr/hyprland.conf`, `hypr/hyprlock.conf`, `hypr/user-settings.conf`, `hypr/modules/*.conf`)
- `design/` (`design/generate_assets.py`, `design/icons/*.svg`, `design/typography/FONTS.md`, `design/wallpapers/*.svg`, `design/wallpapers/*.png`)
- `scripts/` (`check_qml.py`, `install.sh`, `uninstall.sh`, `doctor.sh`, `test.sh`)
- `tests/` (`run_tests.py`, `test_contracts_and_assets.py`, `tst_stage2.qml`, `tst_stage3_components.qml`, `tst_stage4_hud.qml`, `tst_stage5_launcher.qml`, `tst_stage6_panels.qml`, `tst_stage8_visual.qml`, `tst_settings_hub.qml`)

## Tests Passed (Windows 11 / PySide6 6.12.0)
- `python scripts/check_qml.py`: `PASS` — 76 QML files checked (53 `ui/`+`preview/` + 23 `shell/`), 0 isolation/token/command violations; `pyside6-qmllint.exe` on 53 `ui/`+`preview/` files = 0 errors; `pyside6-qmlformat.exe --dry-run` on 23 `shell/` files = 0 syntax errors.
- `python tests/test_contracts_and_assets.py`: `PASS` — 6/6 tests passed (12/12 Mock<->Adapter contract parity, 28 SVG icons valid, 3 SVG+PNG wallpapers valid, Hyprland safety invariants, notification single-daemon check, shell script LF & isolation invariants).
- `python tests/run_tests.py`: `PASS` — `47 passed, 0 failed` (`MarathonSettingsHubSuite`, `MarathonStage2Suite`, `MarathonStage3ComponentsSuite`, `MarathonStage4HudSuite`, `MarathonStage5LauncherSuite`, `MarathonStage6PanelsSuite`, `MarathonStage8VisualAndAssetsSuite`).
- `python preview/run_preview.py --hide-toolbar` batch PNG captures (`S01` base, Settings Hub sections across 1080p `S01`/`S02` + narrow `1366x768` `S08`, `ControlCenter`, `Launcher Grid`): `PASS` — 0 QML warnings; screenshots visually inspected.

## Tests Failed
- None on Windows 11.

## Tests Not Executed
- `shell/` QML type-check against `Quickshell.*` C++ modules — `NOT RUN — requires CachyOS`.
- Live Hyprland (`hyprctl version`, `Hyprland --config ...`, `0.53/0.54` vs `0.55+` Lua check), Quickshell startup, PipeWire, NetworkManager, Bluetooth, UPower, `brightnessctl`, D-Bus `org.freedesktop.Notifications`, `hyprlock` PAM, multi-monitor hotplug, and `bash scripts/*.sh` runtime execution — **`NOT RUN — requires CachyOS`**.

## Known Problems
- `git` is absent and `.git/` is not initialized on the Windows development machine.
- `PySide6\Scripts` is not on the Windows user `PATH`; scripts resolve the Python Scripts path automatically.
- Actual CachyOS Hyprland (`hyprlang` vs `0.55+` Lua) and Quickshell module versions remain unverified until deployed on the target CachyOS host (`ADR-002`).

## Performance Concerns
- Hidden panels in `shell/` use `Quickshell.LazyLoader { active: open }`, `SystemClock` replaces polling clock timers, `nmcli monitor` and `Hyprland.onRawEvent` drive reactive updates, and top-level `ToastStack` / `OSD` skip input focus (`WlrKeyboardFocus.None`). Actual memory/CPU measurements in a live Wayland session await CachyOS (`NOT RUN — requires CachyOS`).

## Git Branch
`NOT INITIALIZED` (`git` is not installed and `.git/` is absent on the Windows host).

## Commit / PR
`NOT COMMITTED`.

## Next Milestone
Transfer repository to CachyOS host, execute read-only `bash scripts/doctor.sh` and `bash scripts/install.sh --dry-run`, verify `Hyprland --version` and `quickshell --version`, run isolated launch and on-device checklist in [`TEST_PLAN.md`](TEST_PLAN.md).
