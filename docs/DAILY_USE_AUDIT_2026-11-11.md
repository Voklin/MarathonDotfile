# Аудит пригодности MARATHON Tactical для повседневной работы

Дата: 2026-11-11. База: `b7862c561ebcbf2bf76763b65b41807627b50d9f`.

## Вывод

В проекте уже много UI и утилит, но готовность к комфортной ежедневной работе не подтверждена. Главные препятствия — незавершённые подключения Wi-Fi/Bluetooth, отсутствующий системный трей, ошибки Linux-команд в уведомлениях и меню сна, а также недостаточно защищённое применение тем. До расширения визуальных возможностей следует закрыть эти сценарии и выполнить приёмку на CachyOS.

Это аудит кода, документации и доступных автотестов на Windows. Реальные устройства, запуск сессии, screen sharing, Linux API и внешний вид живой оболочки не проверялись. Точные установленные версии Hyprland/Quickshell целевой машины неизвестны. Код продукта в ходе аудита не изменялся.

## P1 — исправить до повседневного использования

### A01. Проверка владельца уведомлений не выполняет заявленную функцию

Источник: `shell/services/NotificationsAdapter.qml:19–38`, `scripts/doctor.sh:57`.

Используется `busctl --user get-name-owner ...`. В проверенном upstream systemd такой команды нет: GetNameOwner — метод интерфейса D-Bus, который вызывается через `busctl call`. Любой ненулевой код, включая неверную команду или проблему шины, интерпретируется как отсутствие владельца, после чего включается NotificationServer. Это обход предусмотренной защиты от конфликта; окончательное поведение при занятом имени зависит от Quickshell. Doctor использует ту же неверную проверку и может ошибочно сообщить готовность.

Дополнительно `ownerTimeout` объявлен, но не запускается (`running`, `start`, `restart` отсутствуют): ограничение времени фактически не работает.

Исправление: проверить NameHasOwner/GetNameOwner штатным D-Bus вызовом, различать «имя свободно» и ошибку диагностики; запускать timeout, не включать сервер после ошибки/таймаута. Приёмка: свободное имя, занятое имя, отсутствующий busctl, недоступный user bus, зависание.

Основания: [исходники busctl](https://github.com/systemd/systemd/blob/main/src/busctl/busctl.c), [D-Bus GetNameOwner / NameHasOwner](https://dbus.freedesktop.org/doc/dbus-specification.html).

### A02. Сон определяется несуществующей командой

Источник: `shell/services/SessionAdapter.qml:62–71`, `ui/components/SessionMenuPanel.qml:99–101`.

`systemctl can-suspend` не является штатным verb в проверенном upstream systemd. При ненулевом завершении `canSuspend` становится false, кнопка SUSPEND отключается даже на поддерживаемом оборудовании. Это установленный дефект выбора команды; на целевой машине пока не воспроизведён.

Исправление: использовать `org.freedesktop.login1.Manager.CanSuspend()`, учитывать ответы yes/no/challenge/na и политику авторизации; проверить блокировку перед сном и восстановление дисплеев после него.

Основания: [команды systemctl](https://github.com/systemd/systemd/blob/main/src/systemctl/systemctl.c), [login1 CanSuspend](https://www.freedesktop.org/software/systemd/man/latest/org.freedesktop.login1.html).

### A03. Новый защищённый Wi-Fi нельзя полноценно подключить из оболочки

Источник: `shell/services/NetworkAdapter.qml:185–187`, `ui/components/SettingsSystemSections.qml:244–246`, `scripts/session-daemons.sh`.

UI передаёт только SSID в `nmcli device wifi connect`. В собственном сценарии нет запроса секрета, передачи пароля или запуска NetworkManager secret agent. Поликит-агент решает другую задачу. Сохранённые подключения и открытые сети могут работать; новая защищённая сеть потребует внешнего инструмента/агента.

Исправление: завершённый сценарий подключения с обработкой секрета либо явный переход к подходящему внешнему сетевому UI; скрытая сеть, неправильный пароль, повтор, отмена, явный прогресс подключения. Не хранить секреты в settings.json или логах. [Официальная документация nmcli](https://networkmanager.pages.freedesktop.org/NetworkManager/NetworkManager/nmcli.html).

### A04. Нет системного трея, заявленного в MVP

Источник: `docs/PRODUCT_SPEC.md`, `shell/services/LiveBackend.qml`, `shell/panels/TopHudWindow.qml`, `ui/components/TopHudBar.qml`.

Поиск по `ui/` и `shell/` не обнаружил реализации SystemTray. Телеметрия сети/батареи не заменяет значки приложений и их контекстные меню. VPN, мессенджер и другие фоновые приложения могут остаться без привычной точки управления.

Добавить Linux-адаптер трея и чистый UI-контракт: иконки, меню, secondary activation, подсказки, переполнение на узком экране; проверить реальные приложения на целевой машине.

### A05. Применение тем недостаточно защищает исходные пользовательские файлы

Источник: `scripts/apply-themes.sh:14–15,146–159,190–200`.

Два статически подтверждённых риска:

- Каталог backup имеет точность до секунды, а manifest обнуляется через `: >`. Два запуска в одну секунду используют один каталог, перезаписывают manifest и могут смешать первоначальную копию с уже применённой темой. В основном установщике уже применены уникальные каталоги, здесь — ещё нет.
- Для managed CSS используется `cat > "$dest"`. Если существующий gtk.css — симлинк, запись идёт в исходный файл по ссылке. `cp -a` перед этим сохраняет сам симлинк, а не независимую копию его содержимого. Тогда backup тоже ссылается на изменённый файл, и обычный restore прежнее содержимое не вернёт.

Исправление: уникальные backup, независимая сохранность исходных данных, замена managed-файлов без следования симлинкам, валидация manifest/путей и lifecycle восстановленных копий. Проверить повторное применение/восстановление и обрыв операции. Пока эти ветки не прошли Linux-тесты, применение внешних тем не считать готовым.

## P2 — заметные неудобства ежедневного использования

### A06. Bluetooth не имеет полного сценария добавления устройства

`shell/services/BluetoothAdapter.qml:38–54`: есть togglePower и toggleDevice, нет управления обнаружением, pairing/PIN, trust или forget. `SettingsSystemSections.qml` показывает устройства и переключает соединение. Для новых наушников/клавиатуры нужен отдельный менеджер либо полноценный flow с агентом авторизации и обработкой ошибок. Известные устройства могут работать; это не доказывает возможность нового pairing.

### A07. Нет выбора устройства записи

`shell/services/AudioAdapter.qml`: есть список аппаратных выходов и selectSink, для микрофона — только defaultSource, громкость и mute. При нескольких микрофонах пользователь не сможет выбрать нужный из собственной панели. Нужны список входов и selectSource либо явный переход к pavucontrol; отдельно проверить USB/Bluetooth hotplug и восстановление default device.

### A08. Сетевой парсер ломает специальные SSID

`shell/services/NetworkAdapter.qml:64,120`: terse-вывод nmcli разбирается простым split(":"). Это не учитывает экранированный разделитель в SSID: имя вида `Office:5G` будет неправильно разобрано, поля сигнала/защиты съедут. Нужен разбор формата nmcli с escape-последовательностями; тесты на `:`, `\\`, Unicode, скрытые и одинаковые SSID. Свойство ipAddress объявлено, но не заполняется.

### A09. Нет видимого текущего языка ввода

`hypr/modules/input.conf:4`: по умолчанию только us. В Settings Hub уже есть выбор `kbLayout` и `kbOptions`, поэтому настройки раскладок не отсутствуют. Однако текущая активная раскладка не показана в HUD и не отслеживается отдельным состоянием. Для русскоязычной работы нужны понятный первый выбор us/ru, индикатор EN/RU и проверка ввода после блокировки/возобновления.

### A10. Восстановление оболочки слишком широкое, диагностика запуска ограничена

`hypr/modules/autostart.conf` запускает Quickshell напрямую; автоматического восстановления/сбора журнала падения не найдено. `hypr/modules/binds.conf:115` делает `pkill -x quickshell`, затрагивая все одноимённые процессы пользователя, включая другие профили. Нужны перезапуск только своего экземпляра, доступный журнал и команда диагностики запуска. Возможный supervision через штатные механизмы — отдельное решение после проверки целевой среды.

### A11. Повседневное состояние частично теряется при перезапуске

`LauncherAdapter.qml:11`: recentIds хранится только в памяти. `UtilitiesAdapter.qml:34`: pinned clipboard IDs также в памяти. В NotificationsAdapter read/DND/maps не сохраняются на диск; keepOnReload не равен долговечной истории между завершением процесса/перезагрузками. Настройки и scratchpad уже сохраняются — речь именно об остальных состояниях. Нужны явно определённая политика сохранения и ограничения размера/срока хранения; особенно для clipboard.

### A12. Первый вход ещё требует ручного маршрута

`setup.sh` правильно не меняет display manager, но устанавливает только команду для ручного запуска из TTY. Нет проверенного варианта выбора отдельной сессии на login screen. В manifest пакетов нет firefox, хотя `$browser = firefox`; nvim указан как editor, но также не включён. Нужен onboarding с проверкой выбранных приложений и отдельная opt-in инструкция регистрации сессии с backup/rollback, если пользователь этого захочет. Не менять действующую сессию автоматически.

## Что уже есть и не требует повторной разработки

- Launcher с поиском и безопасными командами, клавиатурная навигация.
- Рабочие пространства, базовые бинды, полноэкранные окна, HUD по мониторам.
- Управление выходным звуком, микрофонным mute/громкостью, яркостью при доступном устройстве.
- Settings Hub, локальные настройки и пользовательские Hyprland-overrides.
- Clipboard UI, снимки экрана, заметки/Pomodoro, MPRIS, системный монитор.
- Изолированный installer с dry-run, staging, backup и восстановлением session helper.

Наличие кода не означает приёмку live-адаптеров или визуальную готовность.

## Свежие проверки

| Проверка | Результат |
|---|---|
| `python scripts/check_qml.py` | PASS: 96 файлов; 63 ui/preview lint, 33 shell syntax, 0 нарушений слоёв/токенов |
| `python tests/run_tests.py` | 63 PASS (включая `DailyUseRegression` в `tests/tst_daily_use.qml`) |
| `python tests/test_contracts_and_assets.py` | 7 PASS (16 пар Mock <-> Adapter, инварианты A01/A02/A10/A11/A12) |
| `python tests/test_installer.py` | 17 сценариев (добавлены тесты `apply-themes.sh`, `shell-ctl.sh`, `onboarding.sh`; требует `bash` / `MARATHON_TEST_BASH`) |
| Windows QtQuick Preview скриншоты | PASS: просмотрены рендеры Top HUD (`TrayStrip` + `EN/RU`) и Settings Hub (`Audio & Power` с выбором микрофона, `Connections` с IP и кнопками менеджеров) |
| Реальный Linux, аппаратные устройства, screen sharing, shell restart, lock/suspend/resume | NOT RUN — requires CachyOS |

Зелёные mock/UI-тесты и синтаксический разбор shell/QML не подтверждают существование CLI-команд или правильность Quickshell API на целевой версии.

## Статус исправления A01–A12 — 2026-11-11

Все пункты `A01`–`A12` реализованы в коде по плану [`DAILY_USE_FIX_PLAN.md`](DAILY_USE_FIX_PLAN.md) (см. также `ADR-009` в [`DECISIONS.md`](DECISIONS.md)):

| ID | Статус в коде | Изменённые файлы | Остаток на CachyOS (`NOT RUN — requires CachyOS`) |
|---|---|---|---|
| **A01** | `FIXED (Offline)` | `shell/services/NotificationsAdapter.qml`, `ui/logic/DesktopParsing.js`, `scripts/doctor.sh`, `tests/tst_daily_use.qml` | Проверить живой `busctl --user call ... NameHasOwner` при свободном и занятом `org.freedesktop.Notifications` |
| **A02** | `FIXED (Offline)` | `shell/services/SessionAdapter.qml`, `ui/logic/DesktopParsing.js`, `tests/tst_daily_use.qml` | Проверить `login1.Manager.CanSuspend`, `hyprlock` перед сном и DPMS после пробуждения |
| **A03** | `FIXED (Offline)` | `shell/services/NetworkAdapter.qml`, `scripts/session-daemons.sh`, `ui/components/SettingsSystemSections.qml`, `scripts/packages-cachyos.txt` | Проверить подключение к новой WPA2/WPA3/скрытой сети через `nm-applet` / `nm-connection-editor` |
| **A04** | `FIXED (Offline)` | `preview/mocks/TrayMock.qml`, `shell/services/TrayAdapter.qml`, `ui/components/TrayStrip.qml`, `ui/components/TopHudBar.qml`, `shell/panels/TopHudWindow.qml`, `ui/contracts/ShellContracts.qml` | Проверить иконки, меню и клики реальных SNI-приложений (`nm-applet`, Telegram, VPN) |
| **A05** | `FIXED (Offline)` | `scripts/apply-themes.sh`, `tests/test_installer.py` | Проверить деплой/откат тем с реальными POSIX-симлинками на CachyOS |
| **A06** | `FIXED (Offline)` | `shell/services/BluetoothAdapter.qml`, `preview/mocks/BluetoothMock.qml`, `scripts/session-daemons.sh`, `ui/components/SettingsSystemSections.qml`, `scripts/packages-cachyos.txt` | Проверить первичное сопряжение (PIN/trust) наушников/клавиатуры через `blueman-manager` / `blueman-applet` |
| **A07** | `FIXED (Offline)` | `shell/services/AudioAdapter.qml`, `preview/mocks/AudioMock.qml`, `ui/components/SettingsSystemSections.qml`, `tests/tst_daily_use.qml` | Проверить переключение реальных PipeWire-микрофонов и USB/BT hotplug |
| **A08** | `FIXED (Offline)` | `ui/logic/DesktopParsing.js`, `shell/services/NetworkAdapter.qml`, `preview/mocks/NetworkMock.qml`, `tests/tst_daily_use.qml` | Проверить разбор `nmcli` на живых сетях с `:`, `\`, кириллицей и отображение `IP4.ADDRESS` |
| **A09** | `FIXED (Offline)` | `preview/mocks/KeyboardMock.qml`, `shell/services/KeyboardAdapter.qml`, `ui/components/TrayStrip.qml`, `hypr/modules/input.conf`, `tests/tst_daily_use.qml` | Проверить переключение `us,ru` (`Alt+Shift` и клик по индикатору `EN/RU` в HUD) и ввод в `hyprlock` |
| **A10** | `FIXED (Offline)` | `scripts/shell-ctl.sh`, `hypr/modules/autostart.conf`, `hypr/modules/binds.conf`, `tests/test_contracts_and_assets.py` | Проверить `shell-ctl.sh start|restart|status|log` и ротацию `~/.local/state/marathon-tactical/quickshell.log` |
| **A11** | `FIXED (Offline)` | `shell/services/StateStore.qml`, `shell/services/LauncherAdapter.qml`, `shell/services/NotificationsAdapter.qml`, `shell/services/UtilitiesAdapter.qml` | Проверить сохранение `launcher.json`, `notifications.json` (`dnd`), `clipboard-pins.json` при перезапуске Quickshell |
| **A12** | `FIXED (Offline)` | `scripts/onboarding.sh`, `setup.sh`, `scripts/packages-cachyos.txt`, `tests/test_installer.py` | Проверить `bash scripts/onboarding.sh --check` и opt-in установку/откат `.desktop`-сессии на целевом DM |

## Порядок дальнейшей работы

1. Исправить A01/A02/A05; добавить отрицательные тесты CLI, конфликтующего notification owner, тем-симлинков и повторных backup.
2. Закрыть Wi-Fi и Bluetooth через собственный безопасный flow или явную делегацию внешним менеджерам; добавить трей.
3. Добавить выбор микрофона, индикатор раскладки, изолированный restart и сохранение нужного состояния.
4. На CachyOS зафиксировать версии и пройти матрицу: новый пользователь; два монитора + hotplug; Wi-Fi с паролем; pairing наушников; смена микрофона; звонок со screen sharing; idle lock; suspend/resume; падение/перезапуск Quickshell; update/rollback/theme restore.

Пункты этого аудита — backlog для отдельной реализации, а не разрешение автоматически менять систему или публиковать изменения.
