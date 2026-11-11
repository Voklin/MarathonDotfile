# MARATHON Tactical — Test Plan

Документ фиксирует стратегию верификации с чётким разделением проверок на стороне разработки (**Windows 11 + PySide6**) и целевом стенде (**CachyOS Linux + Hyprland + Quickshell**).

> **Политика честности (`AGENTS.md` / `ADR-002`):** ни одна проверка на Windows не считается заменой запуска на живом Hyprland/Quickshell. Невыполненные на Linux проверки явно маркируются статусом `NOT RUN — requires CachyOS`.

---

## 1. Проверки, выполняемые на Windows 11 (и воспроизводимые на Linux)

| Набор / Скрипт | Что проверяет | Команда |
|---|---|---|
| **Static Layer, Tokens & QML Lint** | Изоляция `ui/` (запрет `Quickshell` / `preview/mocks`), централизация цветов (`#RRGGBB` только в `ui/tokens/Tokens.qml`), отсутствие команд вида shell wrapper в QML, `pyside6-qmllint` по `ui/` и `preview/` (0 ошибок/предупреждений), `pyside6-qmlformat --dry-run` синтаксис `shell/` | `python scripts/check_qml.py` |
| **Contract Parity, Assets & Config Guard** | 1-в-1 совпадение свойств/сигналов/методов всех 11 пар `Mock <-> Adapter`, валидность 28 SVG-иконок и PNG-заголовков 4K/1080p обоев, отсутствие `windowrulev2`/голого перехвата `SUPER_L`/перезаписи `~/.config/hypr/`, наличие проверки владельца `org.freedesktop.Notifications` | `python tests/test_contracts_and_assets.py` |
| **QtQuickTest QML Suites** | Unit/UI тесты: дизайн-токены (`reducedMotion`), сценарии `S01`–`S10`, слайдеры/кнопки/диалоги, компактный/широкий HUD (`1366x768` vs `2560x1440`), fullscreen auto-hide, поиск/клавиатура Launcher (`↑/↓/Tab/Enter/Esc`), Control Center degraded states, flood/DND уведомлений, OSD, Lock Screen | `python tests/run_tests.py` |
| **Visual Preview Sweep** | Детерминированный рендеринг и осмотр скриншотов PNG при 0 QML warnings | `python preview/run_preview.py --scenarios S01 S02 S03 S04 S05 S06 S07 S08 S09 S10 --hide-toolbar --screenshot-dir <dir>` |

---

## 2. Приёмочные проверки на CachyOS (`NOT RUN — requires CachyOS`)

Перед первым боевым запуском или установкой в `~/.config/marathon-tactical/` на живом стенде CachyOS выполнить последовательно:

### 2.1. Аудит и диагностика без изменений системы
1. `bash scripts/doctor.sh` — проверяет версии `Hyprland`, `quickshell` (`qs`), `hyprlock`, `wpctl`, `brightnessctl`, `nmcli`, шрифты `JetBrains Mono`/`Inter`, статус `org.freedesktop.Notifications` и сохранность `sshd`.
2. `bash scripts/install.sh --dry-run` — проверяет перечень копируемых файлов и целевой изолированный путь `~/.config/marathon-tactical/` без единой записи на диск.

### 2.2. Изолированная проверка Hyprland и Quickshell (`NOT RUN — requires CachyOS`)
1. Проверить парсинг конфига без перезаписи пользовательского `~/.config/hypr/`: запустить изолированный профиль из второго TTY или вложенной/тестовой сессии `Hyprland --config ~/.config/marathon-tactical/hypr/hyprland.conf`.
2. Убедиться, что `quickshell -p ~/.config/marathon-tactical/shell/shell.qml` стартует с `0` QML errors, а `top HUD` отображается на всех подключённых мониторах.
3. **Launcher:** `Super+Space` / `Super+D` открывает Launcher с фокусом ввода; поиск реальных `.desktop` работает; запуск `Exec` (включая поля с `%u`/`%U`) корректен; `Super+Return`, `Super+1..9` продолжают работать.
4. **Control Center & Системные сервисы:** изменение громкости и переключение sink (PipeWire), изменение яркости (либо статус `N/A` на десктопе без backlight), переключение Wi-Fi (`nmcli monitor`), Bluetooth (`Quickshell.Bluetooth`), UPower профиль, DND.
5. **Notification Center & D-Bus:** `notify-send "MARATHON" "Telemetry test" --urgency=critical` появляется как toast + в истории при отсутствии другого демона уведомлений; при активном `dunst`/`mako`/`swaync` конфликт фиксируется корректно без падения оболочки.
6. **OSD:** физические клавиши `XF86Audio*` / `XF86MonBrightness*` отображают и автоматически скрывают OSD без перехвата клавиатурного фокуса.
7. **Lock & Session:** `Super+L` запускает `hyprlock` с реальной PAM-аутентификацией; опасные действия (`Logout`/`Reboot`/`Shutdown`) требуют подтверждения.
8. **Fullscreen & Multi-monitor:** `Super+F` скрывает Top HUD на мониторе с fullscreen-окном; подключение/отключение второго монитора корректно пересоздаёт/удаляет бар на этом экране.
9. **Crash Recovery:** при принудительном перезапуске Quickshell (`pkill -x quickshell`) пользователь сохраняет управление окнами Hyprland, терминалом (`Super+Return`) и горячими клавишами, а `Super+Shift+R` восстанавливает панель.

