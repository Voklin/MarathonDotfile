# STATUS — MARATHON Tactical

> **ИСТОРИЧЕСКИЙ АРТЕФАКТ (этапы P0–D7).** Актуальный статус: [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) и [REVIEW_HANDOFF.md](REVIEW_HANDOFF.md) (см. ADR-004 в [DECISIONS.md](DECISIONS.md)).


Актуальный статус реализации этапов проекта **MARATHON Tactical**.

- **Текущий завершённый этап:** `P0 — Проектная документация и статус` (часть `D1` для Windows 11 выполнена; часть `D1` для CachyOS — `NOT RUN — requires CachyOS`)
- **Следующий этап (Next Stage):** **`D1` (добор данных CachyOS при наличии доступа)** / **`D2 — Каркас проекта и Windows Preview`** (разблокирован на Windows через `PySide6 6.12.0`)

---

## Таблица этапов

| Этап | Название | Статус | Доказательство выполнения | Примечание / Блокеры |
|---|---|---|---|---|
| `P0` | Проектная документация и статус | `DONE` | Созданы `AGENTS.md`, `docs/PRODUCT_SPEC.md`, `docs/ARCHITECTURE.md`, `docs/DESIGN_SYSTEM.md`, `docs/DECISIONS.md`, `docs/STATUS.md`, `docs/HANDOFF.md`; проверка структуры и перекрёстных ссылок пройдена | `NOT COMMITTED` — `git` отсутствует на хосте Windows |
| `D1` | Аудит сред | `IN PROGRESS` | Создан [`ENVIRONMENT_REPORT.md`](ENVIRONMENT_REPORT.md): подтверждены Windows 11, 2 дисплея (`2048x1152@1.25` + `1920x1080@1.0`), `PySide6 6.12.0` (`Qt 6.12.0`, `pyside6-qml`, `pyside6-qmllint`, `QtQuickTest`, `QQuickWindow.grabWindow()`), 17 навыков, отсутствие `git` | Linux-часть: `NOT RUN — requires CachyOS`; подготовлены безопасные read-only команды аудита |
| `D2` | Каркас проекта и Windows Preview | `NOT STARTED` | — | **Готов к старту на Windows:** `PySide6 6.12.0` проверен в `D1` |
| `D3` | Независимая сессия Hyprland/Quickshell | `NOT STARTED` | — | Заблокирован до подтверждения данных CachyOS в `D1` (`ADR-002`) |
| `D4a` | Tactical HUD | `NOT STARTED` | — | Требует `D2` (для Windows Preview) и `D3` (для Linux) |
| `D4b` | Launcher | `NOT STARTED` | — | — |
| `D4c` | Control Center | `NOT STARTED` | — | — |
| `D4d` | Notifications / OSD / Session Menu / Lock | `NOT STARTED` | — | — |
| `D5` | Визуальная доводка | `NOT STARTED` | — | Авторские SVG, лицензированные шрифты/обои, ревью скриншотов |
| `D6` | Стабилизация | `NOT STARTED` | — | Требует реального стенда CachyOS |
| `D7` | Релиз | `NOT STARTED` | — | Dry-run/install/uninstall/doctor, changelog, тег только после одобрения владельца |

---

## Текущие ограничения среды

- **Хост разработки:** Windows 11 (`NT 10.0.26100.0`), Python `3.15.0`, Node.js `v24.22.0`, `PySide6 6.12.0` (`Qt 6.12.0`), `PyQt6 6.11.0`, OpenSSH `9.5p2`, `choco 2.7.4`.
- **Qt/QML на Windows:** standalone `C:\Qt` отсутствует и `PySide6\Scripts` не добавлен в `PATH`, но `pyside6-qml.exe`, `pyside6-qmllint.exe`, `QtQuickTest` и offscreen/window `grabWindow()` проверены и работают (подробнее в [`ENVIRONMENT_REPORT.md`](ENVIRONMENT_REPORT.md)).
- **Git:** бинарный файл `git` не найден в `PATH` и стандартных путях установки, каталог `.git/` не инициализирован.
- **CachyOS:** целевой стенд не проверялся (`NOT RUN — requires CachyOS`).

