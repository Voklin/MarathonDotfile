# MARATHON Tactical — Keybindings Reference

Актуальная карта горячих клавиш для изолированного профиля Hyprland ([`hypr/modules/binds.conf`](../hypr/modules/binds.conf)).

> **Примечание безопасности по клавише `Super`:** одиночный перехват `Super_L` (`bindr = SUPER, SUPER_L`) **не** включён по умолчанию без живой проверки на CachyOS, чтобы гарантированно не сломать сочетания `Super + <клавиша>`. Безопасные триггеры лаунчера по умолчанию — `Super + Space` и `Super + D`. Раскомментировать `bindr` допускается только после проверки на реальной Wayland-сессии.

---

## 1. Оболочка MARATHON Tactical и встроенные утилиты (Quickshell & Lock)

| Сочетание | Действие | Механизм |
|---|---|---|
| `Super + Space` / `Super + D` | Application Launcher (+ калькулятор, конвертер, `>` команды, `@` буфер) | `global, marathon-tactical:launcher` |
| `Super + C` | Control Center (+ MPRIS плеер, Night Light, Game Mode) | `global, marathon-tactical:control-center` |
| `Super + N` | Notification Center | `global, marathon-tactical:notifications` |
| `Super + ,` | GUI Settings Hub (17 секций + синхронизация тем приложений) | `global, marathon-tactical:settings` |
| `Super + Shift + V` | Clipboard Vault (`cliphist` + pin + search + delete) | `global, marathon-tactical:clipboard` |
| `Print` / `Super + Shift + S` | Capture Suite (`grim` / `slurp` / `satty` + `hyprpicker`) | `global, marathon-tactical:capture` |
| `Super + M` | System Monitor & Per-App Audio Mixer (PipeWire) | `global, marathon-tactical:sysmon` |
| `Super + A` | Calendar, Pomodoro Timer & Persistent Scratchpad | `global, marathon-tactical:calendar` |
| `Super + /` / `Super + F1` | Interactive Keybinds Briefing & Quick-Start | `global, marathon-tactical:cheatsheet` |
| `Super + Shift + N` | Быстрое переключение Night Light (`hyprsunset`) | `global, marathon-tactical:nightlight` |
| `Super + X` / `Super + Shift + E` | Session Menu | `global, marathon-tactical:session` |
| `Super + L` | Немедленная блокировка экрана | `hyprlock --config ~/.config/marathon-tactical/hypr/hyprlock.conf` |
| `Super + Shift + R` | Перезапуск оболочки Quickshell | `pkill -x quickshell; quickshell -p ...` |

> Дополнительные точки входа: клик по модулю часов в Top HUD открывает **Calendar & Pomodoro**, кнопки `CLIPBOARD`, `CAPTURE`, `MONITOR`, `KEYBINDS` доступны прямо в Control Center, а безопасные команды (`clipboard`, `capture`, `sysmon`, `calendar`, `cheatsheet`, `night-light`, `game-mode`, `open-settings`) — во вкладке `CMDS` или по префиксу `>` в Launcher.

---

## 2. Системные приложения и аварийный контроль

| Сочетание | Действие |
|---|---|
| `Super + Return` | Основной терминал (`$terminal` / `ghostty`) |
| `Super + Shift + Return` | Резервный терминал (`$terminalFallback` / `alacritty`) |
| `Super + E` | Графический файловый менеджер (`$fileManager` / `dolphin`) |
| `Super + T` | Консольный файловый менеджер (`$terminal -e yazi`) |
| `Super + B` | Браузер (`$browser` / `firefox`) |
| `Super + Shift + Ctrl + BackSpace` | Аварийный выход из изолированной сессии Hyprland |

---

## 3. Управление окнами и тайлингом

| Сочетание | Действие |
|---|---|
| `Super + Q` | Закрыть активное окно (`killactive`) |
| `Super + V` | Переключить плавающий / тайлинговый режим (`togglefloating`) |
| `Super + F` | Истинный полноэкранный режим (`fullscreen, 0`) — автоматически скрывает Top HUD |
| `Super + Shift + F` | Развернуть с сохранением панели (`fullscreen, 1`) |
| `Super + P` | Переключить `pseudo` в Dwindle |
| `Super + S` | Изменить направление сплита (`togglesplit`) |
| `Super + [H/J/K/[ ]/Arrows]` | Смена фокуса (влево/вниз/вверх/вправо; `Super+L` зарезервирован за Lock) |
| `Super + Shift + [H/J/K/[ ]/Arrows]` | Перемещение окна по сетке |
| `Super + Alt + [H/J/K/L/Arrows]` | Пошаговое изменение размера окна |
| `Super + LMB (drag)` | Перемещение окна мышью |
| `Super + RMB (drag)` | Изменение размера окна мышью |

---

## 4. Рабочие пространства (Workspaces) и мультимониторность

| Сочетание | Действие |
|---|---|
| `Super + 1` … `Super + 9` | Переключиться на рабочее пространство `1`–`9` |
| `Super + Shift + 1` … `Super + Shift + 9` | Перенести активное окно на рабочее пространство `1`–`9` |
| `Super + Scroll Up/Down` | Переключение соседних рабочих пространств на текущем мониторе |

---

## 5. Аппаратные клавиши звука и яркости

| Клавиша | Действие |
|---|---|
| `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` | Изменить громкость (`wpctl`, ±5%) + автоматический HUD OSD через PipeWire |
| `XF86AudioMute` / `XF86AudioMicMute` | Отключить звук / микрофон (`wpctl`) + OSD |
| `XF86MonBrightnessUp` / `XF86MonBrightnessDown` | Яркость подсветки (`brightnessctl`, ±5%) + IPC OSD (`qs ipc call marathon refreshBrightnessOsd`) |

---

## 6. Умный Launcher (`=` калькулятор, конвертер, команды и буфер)

- `Tab`: переключение между вкладками `APPS` и `CMDS`.
- Ввод выражения вроде `= (12 + 8) * 3`, `24 px to rem`, `16 gib to mib`, `72 f to c` или `#C9FF16`: мгновенный расчёт / конвертация прямо в списке результатов; `Enter` копирует результат в буфер обмена.
- Префикс `>`: прямая фильтрация безопасного белого списка команд (`>night`, `>sysmon`, `>btop`, `>clip`, `>settings`).
- Префикс `@`: поиск по истории буфера обмена и копирование выбранного элемента по `Enter`.
- `Up` / `Down` / `Left` / `Right`: навигация; `Escape`: закрытие оверлея с возвратом фокуса Hyprland.
