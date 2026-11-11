# DECISIONS — MARATHON Tactical

Журнал существенных архитектурных и процессных решений проекта (ADR). Фиксируются только значимые решения с указанием причины и рассмотренных альтернатив.

---

## Формат записи

- **ID / Дата / Статус** (`Accepted` / `Superseded`)
- **Контекст** — какая проблема или развилка возникла.
- **Решение** — что выбрано.
- **Альтернативы** — какие варианты отклонены и почему.
- **Последствия** — влияние на дальнейшие этапы.

---

## ADR-001 — Трёхслойная архитектура и приоритет Windows QtQuick Preview

- **Дата:** 2026-11-10
- **Статус:** Accepted
- **Контекст:** Основная разработка ведётся на Windows 11, тогда как целевая среда выполнения — CachyOS Linux с Hyprland и Quickshell.
- **Решение:** Жёстко разделить проект на 3 слоя (`UI` в `ui/` -> `State/Contracts` -> `Adapters` в `preview/mocks/` и `shell/services/`). Компоненты `ui/` не имеют права импортировать `Quickshell.*` или `preview/mocks/`.
- **Альтернативы:**
  1. Писать QML сразу под `Quickshell` без Windows Preview — отклонено, так как блокирует разработку и визуальную проверку на Windows 11.
  2. Поднимать отдельный локальный Python/Node-демон для унификации данных — отклонено как лишний фоновый процесс при наличии нативных интеграций Quickshell/Hyprland.
- **Последствия:** Любой новый экран сначала проверяется в `preview/Main.qml` с детерминированными мок-сценариями, а на этапе подключения к Linux получает парный адаптер в `shell/services/` с той же семантикой (`available`, `loading`, `error`).

---

## ADR-002 — Отложенное определение формата конфигов Hyprland и API Quickshell до этапа D1

- **Дата:** 2026-11-10
- **Статус:** Accepted
- **Контекст:** В разных версиях Hyprland и Quickshell меняются форматы конфигурации (`hyprlang` vs `hyprland.lua`, `windowrule` vs `windowrulev2`) и модульные API Quickshell. На этапе `P0` прямой аудит целевой машины CachyOS ещё не проводился.
- **Решение:** Не фиксировать заранее формат конфигурации Hyprland и конкретные сигнатуры Quickshell API в документации `P0`. Определить их строго по факту на этапе `D1 — Аудит сред` и зафиксировать в `docs/ENVIRONMENT_REPORT.md` (и при необходимости дополнить в этом файле).
- **Альтернативы:** Захардкодить `hyprland.lua` или устаревшие правила заранее — отклонено из-за риска несовместимости с установленной версией на CachyOS.
- **Последствия:** Создание `hypr/` и `shell/services/` заблокировано до подтверждения версий на этапе `D1` (или явной фиксации допущений).

---

## ADR-003 — Регламент навыков агентов и формат передачи состояния (`HANDOFF`)

- **Дата:** 2026-11-10
- **Статус:** Superseded by ADR-004 (в части «Один этап = Один чат» и файлов `HANDOFF.md`)
- **Контекст:** В репозитории настроены локальные Agent Skills (`.agents/skills/`, см. [`AGENT_SKILLS.md`](AGENT_SKILLS.md)), а в [`SKILLS_INSTALL_REPORT.md`](SKILLS_INSTALL_REPORT.md) зафиксировано отсутствие `git` на текущей Windows-машине. Кроме того, шаблон handoff описан как в разделе 11 мастер-промпта, так и в навыке `marathon-git-handoff`.
- **Решение:**
  1. Для экономии контекста в каждом чате выполняется один этап или малый вертикальный срез с загрузкой только 1–2 релевантных навыков (веб-ориентированные шаблонные навыки из комплекта `ui-ux-pro-max-cli` не используются для QML/Hyprland).
  2. `docs/HANDOFF.md` оформляется по каноническому шаблону раздела 11 `MARATHON_TACTICAL_MASTER_PROMPT.md` с обязательным отражением состояния Git/рабочего дерева (при отсутствии `git` это указывается явно, без фиктивных хешей).
- **Альтернативы:** Вести два дублирующих файла handoff (`HANDOFF.md` в корне и `docs/HANDOFF.md`) — отклонено, чтобы избежать рассинхронизации между чатами.
- **Последствия:** Заменено на ADR-004 после утверждения владельцем единого непрерывного рабочего процесса.

---

## ADR-004 — Непрерывная работа в одном чате и файлы `DEVELOPMENT_STATUS.md` / `REVIEW_HANDOFF.md`

- **Дата:** 2026-11-10
- **Статус:** Accepted
- **Контекст:** Первоначальный [`AGENTS.md`](../AGENTS.md) фиксировал правило «Один этап = Один чат» и файлы `STATUS.md`/`HANDOFF.md` (этапы `P0`–`D7`), тогда как актуальный Master Development Prompt и подтверждённое решение владельца задают последовательное выполнение этапов **1–10** в одном непрерывном чате с отчётностью через `docs/DEVELOPMENT_STATUS.md` и `docs/REVIEW_HANDOFF.md`.
- **Решение:**
  1. Обновить [`AGENTS.md`](../AGENTS.md) для непрерывной последовательной работы по этапам 1–10 в одном чате с сохранением всех технических и безопасностных ограничений (`UI / State / Adapters`, централизованные токены, запрет перезаписи `~/.config/hypr/`, честная маркировка `NOT RUN — requires CachyOS`).
  2. Вести актуальный прогресс и краткий контекст в [`DEVELOPMENT_STATUS.md`](DEVELOPMENT_STATUS.md), а отчёты для внешнего аудита — в [`REVIEW_HANDOFF.md`](REVIEW_HANDOFF.md).
  3. Сохранить [`STATUS.md`](STATUS.md) и [`HANDOFF.md`](HANDOFF.md) как исторические артефакты этапов `P0`/`D1` с пометкой о переходе на `DEVELOPMENT_STATUS.md`.
- **Альтернативы:** Оставить жёсткое требование «Один этап = Один чат» — отклонено владельцем.
- **Последствия:** Этапы 2–6 и доступная на Windows часть 8–10 могут выполняться последовательно после проверок на каждом этапе; интеграционные этапы 7 и 9 (на CachyOS) по-прежнему блокируются до подключения к реальному стенду CachyOS.

---

## ADR-005 — Windows QtQuick Preview и QML tooling поверх `PySide6 6.12.0`

- **Дата:** 2026-11-10
- **Статус:** Accepted
- **Контекст:** По итогам аудита Windows 11 ([`ENVIRONMENT_REPORT.md`](ENVIRONMENT_REPORT.md)) отдельный Qt C++ SDK и глобальные `qml`/`qmllint` в `PATH` отсутствуют, но установлен `PySide6 6.12.0` (`Qt 6.12.0`) с полным набором QML-модулей, `pyside6-qml.exe`, `pyside6-qmllint.exe`, `PySide6.QtQuickTest` и `QQuickWindow.grabWindow()`.
- **Решение:**
  1. Использовать `PySide6 6.12.0` как официальный движок Windows Preview (`preview/`) и проверки QML (`pyside6-qmllint.exe`, `PySide6.QtQuickTest`), предоставив кросс-платформенный Python-лаунчер для интерактивного запуска и пакетной съёмки скриншотов.
  2. Писать QML-код в `ui/` и `preview/` строго на базовых стабильных модулях Qt 6 (`QtQuick`, `QtQuick.Layouts`, `QtQuick.Controls`, `QtQuick.Shapes`, `QtQuick.Window`), избегая Qt 6.12-эксклюзивных API до проверки версии Qt на CachyOS.
- **Альтернативы:** Требовать от пользователя ручной установки 3–5 ГБ Qt C++ SDK — отклонено, так как `PySide6 6.12.0` уже установлен и полностью закрывает интерактивный Preview, линтинг, автотесты и захват скриншотов.
- **Последствия:** Превью и визуальная регрессия работают на Windows 11 из коробки без установки сторонних программ; при этом `ui/` остаётся 100% чистым QML без Python-логики внутри компонентов.

---

## ADR-006 — Стратегия Stage 7: Hyprland `>=0.53` (`hyprlang`), реальный `hyprlock` PAM и событийные Quickshell-адаптеры

- **Дата:** 2026-11-11
- **Статус:** Accepted
- **Контекст:** По официальной документации `wiki.hypr.land` и `quickshell.org/docs` на этапе 7 зафиксированы:
  1. В Hyprland `>=0.53` прежние правила `windowrulev2`/`layerrule` удалены и заменены унифицированным синтаксисом `match:`; в `0.55+` появляется переходный формат `hyprland.lua` при временной обратной совместимости `.conf`.
  2. На текущей Windows-машине отсутствует доступ к стенду CachyOS для запуска `hyprctl version` и `quickshell --version`.
  3. Продакшен-блокировка экрана на Linux требует реальной PAM-аутентификации (хардкодный пароль мока допустим только в Windows Preview).
- **Решение:**
  1. Оформить изолированный профиль [`hypr/hyprland.conf`](../hypr/hyprland.conf) на современном `hyprlang` (`>=0.53` `match:` синтаксис) в отдельной директории `~/.config/marathon-tactical/` (без перезаписи `~/.config/hypr/`), а в `doctor.sh`/`install.sh` заложить явную проверку версии `Hyprland` перед запуском.
  2. Использовать безопасные сочетания `Super+Space` / `Super+D` для Launcher по умолчанию (одиночный `bindr SUPER_L` оставлен закомментированным opt-in до проверки на CachyOS).
  3. На Linux делегировать реальную блокировку и PAM-проверку утилите `hyprlock` ([`hypr/hyprlock.conf`](../hypr/hyprlock.conf)) в единой палитре MARATHON Tactical вместо фейкового пароля в QML.
  4. В [`shell/services/`](../shell/services/) реализовать 11 адаптеров с 100% паритетом контракта моков, проверкой единственного владельца `org.freedesktop.Notifications` перед запуском `NotificationServer`, `Quickshell.LazyLoader` для отложенной загрузки оверлеев и массивами аргументов `Process` без `sh -c`.
- **Последствия:** Конфиги и live-адаптеры готовы к развёртыванию на CachyOS, но все runtime-проверки Hyprland/Quickshell/PipeWire/D-Bus честно помечены как `NOT RUN — requires CachyOS` вплоть до запуска на живом стенде.

---

## ADR-007 — Пост-MVP GUI Settings Hub (17 секций) и изолированное хранение переопределений

- **Дата:** 2026-11-11
- **Статус:** Accepted
- **Контекст:** По завершении базовых этапов 1–10 владелец запросил расширенный графический центр настроек в стиле `ryoku-dev/ryoku` для управления темой, HUD, обоями, композитором Hyprland, мониторами, вводом, биндами, правилами окон, автозапуском и соединениями прямо из UI.
- **Решение:**
  1. Сохранить строгую 3-слойную архитектуру (`UI / State / Adapters`): расширить [`ui/tokens/Tokens.qml`](../ui/tokens/Tokens.qml) реактивными токенами (`surfaceTheme`, `customAccentHex`, `cornerRadius`, `borderThickness`, `motionMultiplier`, `hudBarHeight`), добавить 12-й контракт [`SettingsMock.qml`](../preview/mocks/SettingsMock.qml) / [`SettingsAdapter.qml`](../shell/services/SettingsAdapter.qml) со 100% паритетом API и без разбросанных hex-литералов в компонентах `ui/`/`shell/`.
  2. Реализовать [`SettingsHubPanel`](../ui/components/SettingsHubPanel.qml) (17 секций в 5 группах + живой кросс-секционный поиск) с точками входа `Super + ,`, кнопка `HUB` на HUD, `SETTINGS` в Control Center, команда `open-settings` в Launcher и IPC `toggleSettings` / `openSettingsSection`.
  3. Записывать пользовательские настройки оболочки только в `~/.config/marathon-tactical/settings.json`, а генерируемые Hyprland-переопределения (`general`, `decoration`, `animations`, `input`, `monitor`, `$terminal`/`$fileManager`/`$browser`, custom `bind`, `windowrule match:`, `exec-once`, `env`) — только в `~/.config/marathon-tactical/hypr/user-settings.conf` (источник в конце [`hypr/hyprland.conf`](../hypr/hyprland.conf)) через нативный `Quickshell.Io.FileView.setText()` и `hyprctl reload` без запуска отдельных Python/Node-демонов и без изменения `~/.config/hypr/`.
- **Альтернативы:**
  1. Редактировать `~/.config/hypr/hyprland.conf` или писать отдельные скрипты-демоны на Python — отклонено инвариантами безопасности [`AGENTS.md`](../AGENTS.md).
  2. Делать отдельные статические окна без live-токенов — отклонено, так как реактивные `Tokens` мгновенно обновляют превью и живую оболочку.
- **Последствия:** Весь UI, реактивные токены, генерация `user-settings.conf`, Windows Preview (`--section`) и `tst_settings_hub.qml` проверены на Windows 11; живая запись `FileView.setText()` и применение `hyprctl reload` / `hyprctl monitors -j` на CachyOS помечены `NOT RUN — requires CachyOS`.

---

## ADR-008 — Стандартные системные утилиты, пользовательский UX и живая синхронизация тем приложений

- **Дата:** 2026-11-11
- **Статус:** Accepted
- **Контекст:** Одной верхней панели и базовых меню недостаточно для комфортного ежедневного использования Wayland-сессии; кроме того, терминалы, CLI-мониторы и GTK/Qt-приложения должны визуально соответствовать палитре MARATHON Tactical и реагировать на смену фракции/акцента, не нарушая изолированность профиля и без лишних Python/Node-демонов.
- **Решение:**
  1. **Двойной контур приложений:**
     - **Встроенные QML-утилиты и UX-оверлеи** (`ClipboardPanel`, `CapturePanel`, `SystemMonitorPanel` + поприложений PipeWire Audio Mixer, `CalendarNotesPanel` с Pomodoro и заметками, `CheatsheetPanel`, MPRIS Media Deck + Night Light + Game Mode в Control Center, а также безопасный inline-парсер математики, единиц и hex-цветов и префиксы `>` / `@` в `LauncherPanel`) на базе новых контрактов `Media` и `Utilities` (итого 14 контрактов Mock <-> Adapter).
     - **Стилизованные внешние конфиги в [`apps/`](../apps/)** (`ghostty`, `kitty`, `alacritty`, `foot`, `starship`, `fastfetch`, `btop`, `yazi`, `gtk-3.0`, `gtk-4.0`, `qt6ct`, `mpv`, `imv`, `zathura`) с динамически генерируемыми цветовыми схемами в `~/.config/marathon-tactical/apps/generated/` из [`SettingsAdapter`](../shell/services/SettingsAdapter.qml) поверх `Tokens.paletteSnapshot()` (без разбросанных hex-литералов в `shell/`).
  2. **Изоляция и явный Opt-In:** внешние конфиги устанавливаются внутрь `~/.config/marathon-tactical/apps/`, а развёртывание симлинков в `~/.config/*` выполняется только явным запуском [`scripts/apply-themes.sh`](../scripts/apply-themes.sh) (или `--apply-app-themes` в `install.sh`) с отдельным резервным копированием в `~/.config/marathon-tactical-app-backups/<timestamp>/` и полным `--restore`.
  3. **Отсутствие лишнего polling и `sh -c`:** системный монитор (`UtilitiesAdapter`) читает `/proc/stat`, `/proc/meminfo`, `/proc/loadavg`, `df`, `ps` строго пока открыт (`monitorActive === true`), копирование изображений и текста идёт без `sh -c` (`wl-copy --` и `scripts/copy-image.sh`), а inline-калькулятор в `LauncherPanel` написан как чистый рекурсивный спуск без `eval`/`Function`.
- **Альтернативы:**
  1. Запустить фоновый Python-демон для генерации тем и мониторинга — отклонено [`AGENTS.md`](../AGENTS.md) и `ADR-001`.
  2. Автоматически перезаписывать `~/.config/gtk-*`, `~/.config/ghostty` и т.д. при `install.sh` без спроса — отклонено инвариантом безопасного opt-in и отката.
- **Последствия:** Весь UI, 14-контрактный паритет, 36 SVG-иконок и автотесты проверяются на Windows 11 в `PySide6 6.12.0`; живые интеграции Wayland (`grim`, `slurp`, `satty`, `cliphist`, `hyprpicker`, `hypridle`, `hyprsunset`, MPRIS, PipeWire `Output/Audio` streams) на CachyOS помечены `NOT RUN — requires CachyOS`.

---

## ADR-009 — Закрытие аудита повседневной работы (`A01`–`A12`)

- **Дата:** 2026-11-11
- **Статус:** Accepted
- **Контекст:** Аудит [`DAILY_USE_AUDIT_2026-11-11.md`](DAILY_USE_AUDIT_2026-11-11.md) выявил 12 блокеров и неудобств ежедневной работы (`A01`–`A12`): неверные CLI-вызовы D-Bus (`get-name-owner`, `systemctl can-suspend`), отсутствие секрет-агентов/менеджеров для новых защищённых Wi-Fi и Bluetooth pairing, отсутствие контракта системного трея (`StatusNotifierItem`), выбор только выходного аудио без микрофона, простой `split(":")` на terse-выводе `nmcli`, отсутствие видимого индикатора активной раскладки (`EN/RU`), риск перезаписи по симлинку и коллизии секундных бэкапов в `apply-themes.sh`, глобальный `pkill -x quickshell`, потерю MRU/DND/pinned-клипборда при перезапуске и отсутствие проверяемого onboarding сессии.
- **Решение:**
  1. **Fail-closed D-Bus probes (`A01`, `A02`):** вызывать `busctl --user --timeout=2 call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus NameHasOwner s org.freedesktop.Notifications` (включать `NotificationServer` только при `code === 0` и ответе `"b false"`, с активным `ownerTimeout`) и `busctl --system --timeout=3 call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager CanSuspend` (разрешать сон при `"yes"`/`"challenge"`). Разбор вынесен в чистую библиотеку [`ui/logic/DesktopParsing.js`](../ui/logic/DesktopParsing.js) с негативными автотестами.
  2. **Сеть, Bluetooth и escape-парсер (`A03`, `A06`, `A08`):** реализовать посимвольный парсер `Parsing.terseFields()` с поддержкой `\:` и `\\`, опрос `IP4.ADDRESS` для активного интерфейса, прямое подключение открытых/сохранённых сетей с автоматическим переходом в `nm-connection-editor` при отсутствии профиля, запуск `nm-applet --indicator` и `blueman-applet` в [`scripts/session-daemons.sh`](../scripts/session-daemons.sh) и явные кнопки менеджеров в `SettingsSystemSections.qml`.
  3. **Новые контракты `Tray` и `Keyboard` + выбор микрофона (`A04`, `A07`, `A09`):** расширить матрицу до **16 контрактов** (`TrayMock`/`TrayAdapter` поверх `Quickshell.Services.SystemTray` и `KeyboardMock`/`KeyboardAdapter` поверх `hyprctl devices -j` + события `activelayout`), добавить компактный [`ui/components/TrayStrip.qml`](../ui/components/TrayStrip.qml) с индикатором `EN`/`RU` в `TopHudBar`, а в `AudioMock`/`AudioAdapter` добавить `sources` и `selectSource(id)` (`Pipewire.preferredDefaultAudioSource`).
  4. **Атомарный деплой и откат тем (`A05`):** в [`scripts/apply-themes.sh`](../scripts/apply-themes.sh) использовать `mktemp -d` для уникальных каталогов бэкапа, полную предвалидацию путей и manifest до мутаций, запись и симлинки только через временный файл + `mv -Tf` (без записи по существующему симлинку) и пометку `.restored` без удаления снимка.
  5. **Изолированный lifecycle и bounded-состояние (`A10`, `A11`, `A12`):** заменить `pkill -x quickshell` на [`scripts/shell-ctl.sh`](../scripts/shell-ctl.sh) с проверкой PID и `/proc/<pid>/cmdline` конкретного `shell.qml` и ротацией лога `~/.local/state/marathon-tactical/quickshell.log`; добавить [`shell/services/StateStore.qml`](../shell/services/StateStore.qml) (`atomicWrites: true`, лимит `<=64 KiB`, только несекретные ID: до 6 `recentIds` лаунчера, флаг `dnd` и до 50 числовых `pinnedIds` буфера обмена без сохранения текстов уведомлений и содержимого буфера); добавить [`scripts/onboarding.sh`](../scripts/onboarding.sh) (`--check` и opt-in `--session-file` staging).
- **Последствия:** Все 12 пунктов закрыты в коде и покрыты регрессионными проверками на Windows 11 (`96` QML-файлов, `63/63` QtQuickTest PASS, `7/7` contract/asset PASS); живые проверки D-Bus/NetworkManager/BlueZ/SystemTray/Hyprland на CachyOS остаются помечены `NOT RUN — requires CachyOS`.

---

## ADR-010 — Переход профиля Hyprland на `hyprland.lua` (`hl.*` API) и автодокачка зависимостей в установщике

- **Дата:** 2026-11-11
- **Статус:** Accepted
- **Контекст:** В современном Hyprland (`>=0.55`) основным форматом конфигурации является Lua (`hyprland.lua` с пространством имён `hl.*`: `hl.config`, `hl.monitor`, `hl.workspace_rule`, `hl.window_rule`, `hl.layer_rule`, `hl.curve`, `hl.animation`, `hl.bind`, `hl.dsp.*`, `hl.env`, `hl.on("hyprland.start", ...)`). Кроме того, владелец запросил автоматическое докачивание отсутствующих зависимостей в установщике (`setup.sh` / `scripts/install.sh`).
- **Решение:**
  1. Перевести точку входа и все модули композитора на нативный Lua-формат: [`hypr/hyprland.lua`](../hypr/hyprland.lua), [`hypr/user-settings.lua`](../hypr/user-settings.lua) и `hypr/modules/{env,monitors,input,appearance,animations,rules,binds,autostart}.lua` (сохранив `hyprlock.conf` и `hypridle.conf` для соответствующих утилит).
  2. Обновить генератор изолированных переопределений в [`SettingsAdapter.qml`](../shell/services/SettingsAdapter.qml) и [`SettingsMock.qml`](../preview/mocks/SettingsMock.qml) на запись валидного Lua-кода в `~/.config/marathon-tactical/hypr/user-settings.lua` с экранированием строковых литералов (`_luaQuote`).
  3. Добавить в [`scripts/profile-common.sh`](../scripts/profile-common.sh), [`scripts/install.sh`](../scripts/install.sh) и [`setup.sh`](../setup.sh) функцию `install_missing_dependencies`, которая сверяет пакеты из [`scripts/packages-cachyos.txt`](../scripts/packages-cachyos.txt) через `pacman -Qi`, разделяет отсутствующие пакеты на официальные репозитории (`pacman -Si` -> `sudo pacman -S --needed --noconfirm`) и AUR (`paru`/`yay -S --needed --noconfirm`), поддерживает `--dry-run`, `--install-deps`, `--no-deps`, `--deps-only` и не выполняет `pacman -Rns` или полное обновление системы.
- **Последствия:** Весь профиль Hyprland и генератор GUI Settings Hub работают на едином современном Lua API `hl.*`; установщик автоматически докачивает недостающие пакеты на CachyOS/Arch Linux; тесты на Windows 11 (`63/63` QtQuickTest PASS, `7/7` contract/asset PASS) подтверждены, а живой запуск `Hyprland --config ~/.config/marathon-tactical/hypr/hyprland.lua` на CachyOS помечен `NOT RUN — requires CachyOS`.
