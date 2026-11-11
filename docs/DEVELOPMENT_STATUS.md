# MARATHON Tactical — Development Status

## Аудит повседневной готовности и исправления A01–A12 — 2026-11-11

Все 12 пунктов из [`DAILY_USE_AUDIT_2026-11-11.md`](DAILY_USE_AUDIT_2026-11-11.md) и [`DAILY_USE_FIX_PLAN.md`](DAILY_USE_FIX_PLAN.md) реализованы в коде (`ADR-009` в [`DECISIONS.md`](DECISIONS.md)):
- **A01/A02:** fail-closed D-Bus вызовы `NameHasOwner` и `login1.Manager.CanSuspend` с таймаутами + парсер [`ui/logic/DesktopParsing.js`](../ui/logic/DesktopParsing.js) и негативные тесты.
- **A03/A06/A08:** `Parsing.terseFields()` для экранированных SSID (`\:`, `\\`), IPv4-адрес интерфейса, `nm-applet --indicator` и `blueman-applet` в [`scripts/session-daemons.sh`](../scripts/session-daemons.sh), делегирование паролей/PIN в `nm-connection-editor` и `blueman-manager`.
- **A04/A07/A09:** 16 контрактов Mock <-> Adapter (добавлены `TrayMock`/`TrayAdapter` и `KeyboardMock`/`KeyboardAdapter`), [`ui/components/TrayStrip.qml`](../ui/components/TrayStrip.qml) с индикатором раскладки `EN/RU` в `TopHudBar`, раскладка `us,ru` (`Alt+Shift`) в `hypr/modules/input.conf`, выбор входного микрофона (`sources` / `selectSource`) в `AudioMock`/`AudioAdapter` и `SettingsSystemSections.qml`.
- **A05/A10/A11/A12:** уникальные бэкапы `mktemp -d` и запись без следования симлинкам (`mv -Tf`) в [`scripts/apply-themes.sh`](../scripts/apply-themes.sh); изолированный lifecycle [`scripts/shell-ctl.sh`](../scripts/shell-ctl.sh) вместо глобального `pkill -x quickshell`; bounded-хранилище [`shell/services/StateStore.qml`](../shell/services/StateStore.qml) (`<=64 KiB`, только ID без секретов и содержимого буфера); проверяемый [`scripts/onboarding.sh`](../scripts/onboarding.sh) (`--check` / opt-in `--session-file`).
- **Свежие проверки на Windows 11:** `96` QML-файлов (`check_qml.py` PASS), `63/63` QtQuickTest PASS (`tests/run_tests.py`), `7/7` contract/asset PASS (`tests/test_contracts_and_assets.py`), просмотрены PNG-рендеры HUD и Settings Hub. Живой Linux runtime — **`NOT RUN — requires CachyOS`**.

- **Текущий этап:** `Daily-Use Audit Remediation (A01–A12)` (`DONE Offline / CachyOS Verification Pending`)
- **Предыдущий этап:** `Post-MVP Extension: GUI Settings Hub` (`DONE Offline / CachyOS Pending`)

## Таблица этапов (1–12)

| Этап | Название | Статус | Доказательство / Комментарий |
|---|---|---|---|
| 1 | Аудит | `DONE (Windows) / CachyOS Pending` | [`ENVIRONMENT_REPORT.md`](ENVIRONMENT_REPORT.md): подтверждены Windows 11, 2 дисплея, `PySide6 6.12.0` (`Qt 6.12.0`), `pyside6-qmllint`, `QtQuickTest`, 17 навыков; CachyOS — `NOT RUN — requires CachyOS` |
| 2 | Каркас | `DONE` | [`ui/tokens/Tokens.qml`](../ui/tokens/Tokens.qml), [`ui/animations/`](../ui/animations/), [`ui/contracts/ShellContracts.qml`](../ui/contracts/ShellContracts.qml), [`preview/mocks/`](../preview/mocks/), [`preview/scenarios/ScenarioCatalog.qml`](../preview/scenarios/ScenarioCatalog.qml) (`S01`–`S10`), [`scripts/check_qml.py`](../scripts/check_qml.py) |
| 3 | Библиотека компонентов | `DONE` | Переиспользуемые примитивы в [`ui/components/`](../ui/components/) (`SettingsChoiceGroup`, `SettingsStepper`, `RunnerEmblemCard` и др.) + [`ComponentGalleryScreen.qml`](../ui/screens/ComponentGalleryScreen.qml) + `TacticalButton` (`clip`/`elide`) |
| 4 | Tactical HUD | `DONE` | `WorkspaceIndicator`, `ActiveWindowModule`, `ClockModule` (кликабельный с бейджем Pomodoro), `TelemetryCluster`, `TopHudBar`, `DesktopShellScreen` |
| 5 | Launcher | `DONE` | `LauncherPanel` (`LIST`/`GRID`, MRU недавние, вкладка `CMDS`, inline математический/единичный/hex калькулятор `=`, префиксы `>` и `@`, `↑/↓/←/→/Tab/Enter/Escape`) |
| 6 | Системные панели и утилиты | `DONE` | `ControlCenterPanel` (2x2 Quick Controls + MPRIS плеер + кнопки утилит), `ClipboardPanel`, `CapturePanel`, `SystemMonitorPanel` (+ PipeWire per-app mixer), `CalendarNotesPanel` (+ Pomodoro + Scratchpad), `CheatsheetPanel`, `NotificationCenterPanel`, `OsdOverlay`, `SessionMenuPanel`, `LockScreenOverlay` |
| 7 | Linux Integration | `DONE Offline / CachyOS Pending` | [`shell/`](../shell/) (14 live-адаптеров + `shell.qml` + `shell/utilities/` + `SettingsWindow` + `BackdropWindow`) + [`hypr/`](../hypr/) (`hyprland.conf`, `hypridle.conf`, `user-settings.conf`, модули `>=0.53` `match:`, `hyprlock.conf`) + [`KEYBINDINGS.md`](KEYBINDINGS.md) + `ADR-006`/`ADR-007`/`ADR-008`; рантайм на CachyOS — `NOT RUN — requires CachyOS` |
| 8 | Оформление | `DONE` | [`design/`](../design/): 36 авторских геометрических SVG (`design/icons/`), `FONTS.md` (SIL OFL 1.1), 4K/1080p обои SVG+PNG (`design/wallpapers/`), живой кастомизатор + [`apps/`](../apps/) (14 стилизованных конфигов + `apps/generated/` живых палитр) |
| 9 | Тестирование | `DONE Offline / CachyOS Pending` | [`tests/test_contracts_and_assets.py`](../tests/test_contracts_and_assets.py) (`7/7 OK`), [`tests/run_tests.py`](../tests/run_tests.py) (`55/55 PASS`, включая `MarathonSystemAppsAndUxSuite`), [`TEST_PLAN.md`](TEST_PLAN.md); CachyOS интеграционные проверки — `NOT RUN — requires CachyOS` |
| 10 | Релиз и скрипты | `DONE Offline / CachyOS Pending` | [`scripts/install.sh`](../scripts/install.sh) (`--dry-run` + `--apply-app-themes` + backup + isolated `~/.config/marathon-tactical/`), [`scripts/apply-themes.sh`](../scripts/apply-themes.sh) (`--dry-run` / `--restore`), [`scripts/session-daemons.sh`](../scripts/session-daemons.sh), [`scripts/copy-image.sh`](../scripts/copy-image.sh), [`scripts/packages-cachyos.txt`](../scripts/packages-cachyos.txt), [`scripts/uninstall.sh`](../scripts/uninstall.sh), [`scripts/doctor.sh`](../scripts/doctor.sh) |
| 11 | Post-MVP GUI Settings Hub | `DONE Offline / CachyOS Pending` | [`SettingsHubPanel.qml`](../ui/components/SettingsHubPanel.qml) (17 секций в 5 группах + синхронизация тем приложений + матрица здоровья `14 CONTRACTS`) |
| 12 | System Apps & UX Expansion | `DONE Offline / CachyOS Pending` | Двойной контур (встроенные QML-утилиты + внешние конфиги `apps/`), 14 контрактов, 36 SVG-иконок, расширение `preview/` и 6 новых тестов `tst_system_apps_and_ux.qml`, визуальный аудит PNG-скриншотов |

## Незавершённые функции / Ожидает стенда CachyOS
- Живой аудит и интеграционная приёмка на целевой ОС CachyOS (`bash scripts/doctor.sh`, `bash scripts/install.sh --dry-run`, `bash scripts/apply-themes.sh --dry-run`, запуск `Hyprland --config ...`, `quickshell -p ...`, PipeWire streams, MPRIS, `grim`/`slurp`/`satty`/`cliphist`/`hyprpicker`/`hypridle`/`hyprsunset`, запись `~/.config/marathon-tactical/apps/generated/*`) — **`NOT RUN — requires CachyOS`**.

## Консольный установщик — 2026-11-11

- Добавлен `bash setup.sh`: русскоязычное меню установки/обновления, dry-run, диагностики, отката тем/профиля, удаления и команд запуска. Темы включаются отдельно, перед записью показывается план; пакеты не устанавливаются, сессия не запускается.
- Установка использует staging и уникальные резервные копии; ошибка копирования сохраняет текущий профиль. Откат проверяет наличие backup до изменений, сохраняет текущий профиль и восстанавливает session helper. Добавлены проверки путей и LF для Bash через `.gitattributes`.
- `tests/test_installer.py`: 14 тестов, **13 PASS / 1 SKIP** на Windows Bash (проверка симлинков пропущена: WinError 1314). В тестах `chmod` заглушён; Linux для меню моделируется. `tests/test_contracts_and_assets.py`: **7 PASS**. Bash-синтаксис проверен, включая `setup.sh` и общий модуль.
- Инструкция: [`INSTALLER.md`](INSTALLER.md). POSIX permissions, темы с реальными симлинками и Hyprland/Quickshell runtime: **`NOT RUN — requires CachyOS`**. После локальной реализации владелец отдельно разрешил commit/push установщика в GitHub.

## Миграция на Hyprland Lua (`hyprland.lua`) и автодокачка зависимостей — 2026-11-11

- **Hyprland Lua (`ADR-010`):** профиль композитора полностью переведён с `hyprlang` (`.conf`) на современный Lua API (`hl.config`, `hl.monitor`, `hl.window_rule`, `hl.layer_rule`, `hl.curve`, `hl.animation`, `hl.bind`, `hl.dsp.*`, `hl.env`, `hl.on("hyprland.start", ...)`): [`hypr/hyprland.lua`](../hypr/hyprland.lua), [`hypr/user-settings.lua`](../hypr/user-settings.lua) и 8 модулей в [`hypr/modules/`](../hypr/modules/). Генератор переопределений в [`SettingsAdapter.qml`](../shell/services/SettingsAdapter.qml) и [`SettingsMock.qml`](../preview/mocks/SettingsMock.qml) теперь формирует `hypr/user-settings.lua`.
- **Автодокачка зависимостей в установщике:** в [`scripts/profile-common.sh`](../scripts/profile-common.sh), [`scripts/install.sh`](../scripts/install.sh) и [`setup.sh`](../setup.sh) добавлено автоматическое определение и докачивание отсутствующих пакетов из [`scripts/packages-cachyos.txt`](../scripts/packages-cachyos.txt) (`sudo pacman -S --needed --noconfirm` для пакетной базы репозиториев и `paru`/`yay` для AUR-пакетов, с поддержкой `--dry-run`, `--install-deps`, `--no-deps`, `--deps-only`).
- **Проверки на Windows 11:** `96` QML-файлов (`check_qml.py` PASS), `63/63` QtQuickTest PASS (`tests/run_tests.py`), `7/7` contract/asset PASS (`tests/test_contracts_and_assets.py`). Живой рантайм на CachyOS — **`NOT RUN — requires CachyOS`**.

## Архитектурные решения
- `ADR-001`–`ADR-010` зафиксированы в [`DECISIONS.md`](DECISIONS.md).
