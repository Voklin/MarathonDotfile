# MARATHON Tactical

Самостоятельная тактическая оболочка рабочего стола для **CachyOS Linux (Hyprland + Quickshell)**, разрабатываемая и визуально верифицируемая на **Windows 11 (QtQuick Preview + Mock Backends)**.

> Проект вдохновлён атмосферой тактического футуризма (чёрные матовые поверхности, кислотно-лаймовые акценты, жёсткая сетчатая геометрия `4/8 px`), но все ассеты, иконки, обои и палитра созданы с нуля и не используют закрытые материалы третьих сторон.

---

## Архитектура (`UI / State / Adapters`)

1. **`ui/` (чистый QtQuick без системных зависимостей):**
   - [`ui/tokens/Tokens.qml`](ui/tokens/Tokens.qml) — единая таблица цветов (`#080B0A`, `#141C18`, `#C9FF16`, `#F0F4E8`, `#FF4268`), отступов, радиусов, шрифтов и политики `reducedMotion`.
   - [`ui/animations/`](ui/animations/) — переходы и `PanelReveal`.
   - [`ui/contracts/ShellContracts.qml`](ui/contracts/ShellContracts.qml) — дефолтные безопасные контракты 11 подсистем (`available` / `loading` / `errorMessage`).
   - [`ui/components/`](ui/components/) — библиотека HUD-примитивов, `TopHudBar`, `LauncherPanel`, `ControlCenterPanel`, `NotificationCenterPanel`, `NotificationToastStack`, `OsdOverlay`, `SessionMenuPanel`, `LockScreenOverlay`.
   - [`ui/screens/`](ui/screens/) — композиционные экраны `DesktopShellScreen` и `ComponentGalleryScreen`.
2. **`preview/` (Windows 11 QtQuick Preview поверх `PySide6`):**
   - [`preview/mocks/`](preview/mocks/) — детерминированные моки с 100% паритетом API.
   - [`preview/scenarios/ScenarioCatalog.qml`](preview/scenarios/ScenarioCatalog.qml) — сценарии `S01`–`S10` (normal, QHD, compact `1366x768` low-battery, HiDPI `1.5x`, Cyrillic/CJK long title, offline network, muted audio, desktop missing sensors, 16-notification flood, multi-monitor fullscreen).
3. **`shell/` (CachyOS Live Quickshell Layer):**
   - [`shell/shell.qml`](shell/shell.qml) — `ShellRoot`, `GlobalShortcut`, `IpcHandler` (`qs ipc call marathon ...`), `LazyLoader` для скрытых оверлеев.
   - [`shell/services/`](shell/services/) — событийные адаптеры на `Quickshell.Hyprland`, `Quickshell.Services.Pipewire`, `Quickshell.Bluetooth`, `Quickshell.Services.UPower`, `DesktopEntries`, `NotificationServer` (с проверкой отсутствия конфликтующего D-Bus демона), `nmcli monitor` и `brightnessctl` через массивы аргументов без POSIX shell-обёрток.
4. **`hypr/` (Изолированный профиль Hyprland Lua):**
   - [`hypr/hyprland.lua`](hypr/hyprland.lua) + `hypr/modules/*.lua` (современный Lua-конфиг Hyprland `>= 0.55` на API `hl.*` + `hypr/user-settings.lua`) + [`hypr/hyprlock.conf`](hypr/hyprlock.conf) (реальная PAM-блокировка).
5. **`design/` (Оригинальная векторная графика):**
   - [`design/icons/`](design/icons/) — 28 авторских геометрических SVG (`16x16`), синхронизированных с `TacticalIcon.qml`.
   - [`design/wallpapers/`](design/wallpapers/) — 4K/1080p геометрические обои и экран блокировки.
   - [`design/typography/FONTS.md`](design/typography/FONTS.md) — открытые шрифты (SIL OFL 1.1).

---

## Быстрый старт на Windows 11 (QtQuick Preview & Тесты)

Требуется установленный Python с `PySide6` (`Qt 6`):

```powershell
# Статический аудит границ слоёв, токенов и qmllint / qmlformat
python scripts/check_qml.py

# Контрактные тесты (Mock <-> Linux Adapter), ассеты, инварианты конфигов
python tests/test_contracts_and_assets.py

# Модульные и UI тесты QtQuickTest
python tests/run_tests.py

# Интерактивный Windows Preview (с переключателем сценариев S01..S10)
python preview/run_preview.py --scenario S01

# Просмотр библиотеки компонентов
python preview/run_preview.py --view gallery
```

---

## Консольный установщик на CachyOS

Распакуйте проект и откройте терминал в его каталоге. Запускайте от обычного пользователя **без sudo**:

```bash
bash setup.sh
```

Мастер показывает состояние зависимостей и предлагает установку/обновление (с автоматической докачкой отсутствующих зависимостей из `scripts/packages-cachyos.txt` через `pacman -S --needed` и `paru`/`yay`), dry-run, диагностику, восстановление тем, откат профиля и удаление. Перед установкой он показывает итоговый план. Применение тем внешних приложений — отдельный выбор, по умолчанию выключенный.

Проверка плана без записи:

```bash
bash setup.sh --dry-run
```

Профиль устанавливается в `~/.config/marathon-tactical/`, команда сессии — в `~/.local/bin/marathon-tactical-session`. Мастер требует стандартный `XDG_CONFIG_HOME=$HOME/.config`, поскольку профиль Hyprland использует этот путь. Обновление сначала копирует новые файлы во временный каталог и сохраняет предыдущий профиль в уникальную резервную копию. Сохраняются `settings.json`, `scratchpad.txt`, `hypr/user-settings.lua` и сгенерированные палитры приложений. Симлинки в пути назначения отклоняются.

Запуск графической сессии выполняется вручную после проверки совместимости. Текущая сессия, действующие конфиги Hyprland/Quickshell, службы и display manager автоматически не меняются.

Откат и удаление из исходного каталога проекта:

```bash
# Сначала восстановить темы приложений, если вы их применяли
bash scripts/apply-themes.sh --restore

# Восстановить последний профиль и команду запуска; текущий тоже сохраняется
bash scripts/uninstall.sh --restore-backup

# Или удалить только профиль и команду запуска, сохранив резервные копии
bash scripts/uninstall.sh
```

Отсутствие подходящей резервной копии при `--restore-backup` приводит к отказу **до удаления** текущего профиля. POSIX-права доступа, пакетный состав и живая сессия требуют проверки на CachyOS. Подробнее: [`docs/INSTALLER.md`](docs/INSTALLER.md).

## Изолированный запуск и проверка на CachyOS Linux

Ни один скрипт не перезаписывает ваш рабочий `~/.config/hypr/` и не отключает `sshd`.

```bash
# 1. Проверить среду, конфликты уведомлений и версии (только чтение)
bash scripts/doctor.sh

# 2. Проверить план установки без изменений на диске
bash scripts/install.sh --dry-run

# 3. Установить в изолированный каталог ~/.config/marathon-tactical/
bash scripts/install.sh

# 4. Запустить MARATHON Quickshell вручную в текущей Hyprland-сессии:
quickshell -p ~/.config/marathon-tactical/shell/shell.qml

# Или запустить изолированную Hyprland-сессию со свободного TTY (Ctrl+Alt+F3):
~/.local/bin/marathon-tactical-session
```

Откат и удаление:

```bash
bash scripts/uninstall.sh --dry-run
bash scripts/uninstall.sh --restore-backup
```

Карта горячих клавиш: [`docs/KEYBINDINGS.md`](docs/KEYBINDINGS.md).
План тестирования и разделение Windows vs CachyOS: [`docs/TEST_PLAN.md`](docs/TEST_PLAN.md).

---

## Лицензия

Код, документация и авторская геометрия распространяются по лицензии [MIT](LICENSE). Открытые системные шрифты используют собственные лицензии (`SIL OFL 1.1`, см. [`design/typography/FONTS.md`](design/typography/FONTS.md)).

