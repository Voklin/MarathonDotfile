# ENVIRONMENT_REPORT — MARATHON Tactical (`D1`)

Отчёт по аудиту сред разработки и целевого окружения (этап `D1`).  
Дата аудита: `2026-11-10`  
Статус: **Windows 11 — проверено; CachyOS — `NOT RUN — requires CachyOS`**

> Все факты ниже для Windows 11 подтверждены прямым запуском команд в текущей сессии. Любые параметры целевой машины CachyOS/Hyprland/Quickshell, не проверенные напрямую, явно отмечены как `UNCONFIRMED — requires CachyOS`.

---

## 1. Среда разработки: Windows 11 (Проверено)

### 1.1. ОС, оболочка и дисплеи

| Параметр | Подтверждённое значение | Способ проверки |
|---|---|---|
| ОС | `Microsoft Windows NT 10.0.26100.0` | `[System.Environment]::OSVersion.VersionString` |
| PowerShell | `5.1.26100.9711` | `$PSVersionTable.PSVersion.ToString()` |
| Основной монитор (`Screen 0`) | `P275MR+`, логическое `2048x1152`, `dpr=1.25` (физическое `2560x1440`), `200.0 Hz` | `PySide6.QtGui.QGuiApplication.screens()` |
| Второй монитор (`Screen 1`) | `AF24H1`, логическое `1920x1080`, `dpr=1.0`, `60.0 Hz` | `PySide6.QtGui.QGuiApplication.screens()` |
| GPU (WMI/CIM) | `UNCONFIRMED in sandbox` (`Get-CimInstance Win32_VideoController` заблокирован sandbox-изоляцией) | `Get-CimInstance` |

**Вывод по дисплеям:** рабочая станция уже имеет разнородную двухмониторную конфигурацию с дробным HiDPI (`1.25x` + `1.0x`), что позволяет тестировать масштабирование на реальных экранах в дополнение к программным профилям `1366x768`, `1920x1080` и `2560x1440`.

### 1.2. Qt / QML инструментарий

Отдельный C++/Qt SDK (`C:\Qt`, `%ProgramFiles%\Qt`, `%LOCALAPPDATA%\Programs\Qt`) **не установлен**, а `qml`/`qmllint` отсутствуют в системном `PATH`. Однако через пользовательский Python установлен полный стек **Qt 6.12.0 (`PySide6 6.12.0`)** и `PyQt6 6.11.0`:

| Инструмент / Модуль | Статус / Версия | Расположение / Примечание |
|---|---|---|
| `PySide6` (`QtCore.qVersion()`) | `6.12.0` (`Qt 6.12.0`) | `C:\Users\Voklin\AppData\Roaming\Python\Python315\site-packages\PySide6` |
| `PyQt6` / `PyQt6-Qt6` | `6.11.0` / `6.11.2` | Установлен параллельно (предпочтение для Preview — `PySide6` из-за комплекта утилит QML) |
| `pyside6-qml.exe` | **Доступен** (не в `PATH`) | `C:\Users\Voklin\AppData\Roaming\Python\Python315\Scripts\pyside6-qml.exe` (smoke `--apptype core`: exit code `0`) |
| `pyside6-qmllint.exe` | **Доступен** (не в `PATH`) | `C:\Users\Voklin\AppData\Roaming\Python\Python315\Scripts\pyside6-qmllint.exe` (smoke: exit code `0`) |
| `pyside6-qmlformat.exe` / `pyside6-qmlls.exe` / `pyside6-svgtoqml.exe` | **Доступны** (не в `PATH`) | `C:\Users\Voklin\AppData\Roaming\Python\Python315\Scripts\` |
| `PySide6.QtQuickTest` (`QUICK_TEST_MAIN`) | **Доступен** | Поддерживает запуск QML `TestCase` (`QtTest`) |
| Offscreen / Window capture (`QQuickWindow.grabWindow()`) | **Проверено** | Рендер тестового окна `640x120` -> `800x150` (`dpr=1.25`), `5127` байт PNG, `warnings=[]` |
| QML-модули | **Проверено** | Загружаются без ошибок: `QtQuick`, `QtQuick.Layouts`, `QtQuick.Controls`, `QtQuick.Shapes`, `QtQuick.Effects`, `QtQuick.VectorImage`, `QtQuick.Window`, `QtTest`; также присутствуют `Qt5Compat`, `QtMultimedia`, `QtNetwork` |

> **Важное ограничение совместимости:** локальный Qt — `6.12.0`, тогда как на CachyOS версия Qt6/Quickshell может быть ниже (например, `6.8`–`6.10`). В `ui/` запрещено завязываться на экспериментальные API, появившиеся только в Qt `6.12`, без проверки на CachyOS.

### 1.3. Общие инструменты разработки, Git, Python, Node, шрифты

| Инструмент | Статус / Версия | Примечание |
|---|---|---|
| Python (`python`) | `3.15.0` (`C:\Python315\python.exe`) | Также присутствует `C:\WINDOWS\py.exe`; `python3` указывает на `WindowsApps` |
| Node.js / npm / npx | `v24.22.0` / `11.19.1` | Доступны в `PATH` |
| OpenSSH (`ssh`) | `OpenSSH_for_Windows_9.5p2, LibreSSL 3.8.2` | `C:\WINDOWS\System32\OpenSSH\ssh.exe` |
| Chocolatey (`choco`) | `2.7.4` | Доступен |
| `winget` | Алиас в `WindowsApps` | Внутри terminal sandbox вызов заблокирован (`The file cannot be accessed by the system`) |
| VS Code (`code`) | `AppData\Local\Programs\Microsoft VS Code\bin\code.cmd` | Внутри sandbox запуск CLI блокируется из-за `EPERM` при доступе к профилю/расширениям |
| **Git (`git`)** | **ОТСУТСТВУЕТ** | Не найден в `PATH`, `C:\Program Files\Git`, `C:\Program Files (x86)\Git`, `%LOCALAPPDATA%\Programs\Git`; каталог `.git/` не инициализирован |
| `gh` / `scoop` / `cmake` / `ninja` | **ОТСУТСТВУЮТ** | Не найдены в `PATH` |
| WSL (`wsl`) | Бинарник есть, **дистрибутивы не установлены** | `wsl --list --verbose` сообщает, что подсистема WSL не установлена |
| `PyYAML` (в Python 3.15) | **Отсутствует** | Сторонние Python-пакеты в систему не доставлялись |
| Системные шрифты (для fallback в Preview) | `Bahnschrift` (все начертания), `Consolas`, `Segoe UI`, `Segoe UI Variable`, `Segoe Fluent Icons` | Специализированные шрифты (`JetBrains Mono`, `Space Grotesk`, `IBM Plex` и т.п.) не установлены — подбор и лицензирование отложены до `D5` |

### 1.4. Состояние репозитория и Agent Skills

- **Содержимое workspace:** `AGENTS.md`, `skills-lock.json`, `docs/` (`AGENT_SKILLS.md`, `SKILLS_INSTALL_REPORT.md`, `PRODUCT_SPEC.md`, `ARCHITECTURE.md`, `DESIGN_SYSTEM.md`, `DECISIONS.md`, `STATUS.md`, `HANDOFF.md`), `.agents/skills/`. Каталоги кода (`ui/`, `preview/`, `shell/`, `hypr/`, `scripts/`, `tests/`) ещё не создавались.
- **Проверка `.agents/skills/`:** подтверждено наличие **17** каталогов навыков с `SKILL.md`:
  - 5 проектных: `hyprland-expert`, `marathon-design-system`, `marathon-git-handoff`, `qtquick-preview`, `quickshell-expert`;
  - 6 целевых внешних: `frontend-design`, `requesting-code-review`, `skill-creator`, `systematic-debugging`, `ui-ux-pro-max`, `verification-before-completion`;
  - 6 шаблонных навыков из `ui-ux-pro-max-cli`: `banner-design`, `brand`, `design`, `design-system`, `slides`, `ui-styling` (не активируются для QML/Hyprland согласно [`AGENT_SKILLS.md`](AGENT_SKILLS.md)).

---

## 2. Зафиксированные зависимости проекта

### 2.1. Контур Windows 11 (разработка и Preview)
- **Обязательно:** `Python >= 3.12` (подтверждено `3.15.0`) + `PySide6` (`6.12.0` подтверждено; содержит Qt6 QML/Quick, `pyside6-qml`, `pyside6-qmllint`, `QtQuickTest`).
- **Рекомендуется (не установлено):** `Git for Windows` (для локального `git status` / атомарных коммитов и привязки `skills-lock.json` к GitHub).

### 2.2. Целевой контур CachyOS (требует проверки на стенде)
Полный список зависимостей на Linux будет подтверждён после запуска команд из раздела 3:
- Композитор и оболочка: `hyprland`, `quickshell`, совместимые модули `qt6-*` (`qt6-declarative`, `qt6-wayland`, `qt6-svg` и др. — уточняется по `pacman -Qi quickshell`).
- Системные утилиты/демоны (только по факту наличия на стенде): `hyprlock` (или доступный lock-механизм), `pipewire` + `wireplumber` (`wpctl`), `networkmanager` (`nmcli`), `bluez`, `upower`, `brightnessctl` (если есть `/sys/class/backlight`), `xdg-desktop-portal-hyprland`, `polkit` agent.

---

## 3. Целевая среда CachyOS (`NOT RUN — requires CachyOS`)

Доступ к целевой машине/стенду CachyOS в текущей сессии **не подтверждён и не выполнялся**. Все пункты ниже имеют статус **`UNCONFIRMED — requires CachyOS`**:

| Область | Что требуется подтвердить | Текущий статус |
|---|---|---|
| ОС и ядро | Версия CachyOS, ядро, архитектура | `UNCONFIRMED — requires CachyOS` |
| Hyprland | Точная версия, формат конфига (`hyprland.conf` vs `hyprland.lua`), синтаксис `windowrule` / `windowrulev2`, текущие файлы в `~/.config/hypr/` | `UNCONFIRMED — requires CachyOS` |
| Quickshell | Версия `quickshell`, путь/формат запуска, доступные модули (`Quickshell.Hyprland`, `Pipewire`, `Notifications`, `SystemTray`, `Mpris`) | `UNCONFIRMED — requires CachyOS` |
| Дисплейный менеджер и сессии | Активный DM (`sddm`/`gdm`/`greetd`/TTY), содержимое `/usr/share/wayland-sessions/` | `UNCONFIRMED — requires CachyOS` |
| GPU, мониторы, порталы | Видеодрайвер (NVIDIA/AMD/Intel), раскладка мониторов, `xdg-desktop-portal-hyprland` | `UNCONFIRMED — requires CachyOS` |
| Сервисы и D-Bus | PipeWire/WirePlumber, NetworkManager, BlueZ, UPower, владелец `org.freedesktop.Notifications` (нет ли `dunst`/`mako`/`swaync`), `/sys/class/backlight`, `/sys/class/power_supply` | `UNCONFIRMED — requires CachyOS` |
| Удалённый доступ | Наличие `sshd`/VPN/активной сессии, чтобы установка гарантированно их не затронула | `UNCONFIRMED — requires CachyOS` |

### Команды безопасного read-only аудита для запуска на CachyOS

```bash
# 1. ОС, пакеты, версии Hyprland и Quickshell
cat /etc/os-release
uname -a
command -v hyprland hyprctl quickshell hyprlock wpctl pactl nmcli bluetoothctl upower brightnessctl
hyprctl version 2>&1 || hyprland --version 2>&1
quickshell --version 2>&1
pacman -Q hyprland quickshell hyprlock qt6-base qt6-declarative qt6-wayland qt6-svg xdg-desktop-portal-hyprland 2>&1

# 2. Существующая конфигурация Hyprland и дисплейный менеджер (только чтение)
ls -la ~/.config/hypr/ 2>&1
ls -la /usr/share/wayland-sessions/ 2>&1
systemctl status display-manager --no-pager 2>&1

# 3. GPU, мониторы и порталы
lspci -k | grep -EA3 'VGA|3D|Display'
hyprctl monitors all 2>&1 || true
systemctl --user status xdg-desktop-portal xdg-desktop-portal-hyprland --no-pager 2>&1

# 4. Сервисы, питание, подсветка и владелец уведомлений D-Bus
systemctl is-active NetworkManager bluetooth upower sshd 2>&1
systemctl --user is-active pipewire wireplumber 2>&1
pgrep -a -E 'dunst|mako|swaync|waybar|quickshell' || true
busctl --user list 2>&1 | grep -i notif || true
ls -la /sys/class/backlight/ /sys/class/power_supply/ 2>&1
loginctl list-sessions --no-pager 2>&1
```

---

## 4. Риски и влияние на следующие этапы

1. **Этап `D2` (Каркас и Windows Preview) — РАЗБЛОКИРОВАН:**
   - `PySide6 6.12.0` (`Qt 6.12.0`) и `pyside6-qmllint.exe` / `pyside6-qml.exe` / `QQuickWindow.grabWindow()` / `QtQuickTest` проверены и работают на Windows 11.
   - Так как `Scripts` `PySide6` не добавлены в системный `PATH`, скрипты запуска Preview и линтинга в `D2` должны явно находить `pyside6-qmllint.exe` и `PySide6` через Python-окружение (а не полагаться на голый `qml` / `qmllint` в `PATH`).
2. **Этапы `D3` и `D7` (Hyprland и интеграция на CachyOS) — ТРЕБУЮТ ДАННЫХ `CachyOS`:**
   - Согласно [`DECISIONS.md`](DECISIONS.md) (`ADR-002`), конфигурация `hypr/` и live-адаптеры `shell/services/` не должны строиться на догадках о синтаксисе до получения вывода аудита с реального стенда CachyOS.
3. **Отсутствие `git` на Windows:**
   - Версионирование изменений и перепривязка `skills-lock.json` к GitHub временно недоступны на текущем хосте до установки Git.

