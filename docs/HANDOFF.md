# HANDOFF

> **ИСТОРИЧЕСКИЙ АРТЕФАКТ (этапы P0–D7).** Актуальный статус: [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) и [REVIEW_HANDOFF.md](REVIEW_HANDOFF.md) (см. ADR-004 в [DECISIONS.md](DECISIONS.md)).


- Current milestone: `D1 — Аудит сред` (`IN PROGRESS`: Windows 11 проверен, CachyOS `NOT RUN — requires CachyOS`)
- Completed in this session:
  - Проведён аудит Windows 11 без изменения системных настроек: проверены ОС, два дисплея (`P275MR+` `2048x1152@1.25` и `AF24H1` `1920x1080@1.0`), Python `3.15.0`, Node.js `v24.22.0`, OpenSSH `9.5p2`, `choco 2.7.4`, отсутствие `git` и WSL.
  - Выявлен и проверен стек Qt `6.12.0` через `PySide6 6.12.0` (`pyside6-qml.exe`, `pyside6-qmllint.exe`, `QtQuick`, `QtQuick.Layouts`, `QtQuick.Controls`, `QtQuick.Shapes`, `QtQuick.Effects`, `QtQuick.VectorImage`, `QtTest`, `QQuickWindow.grabWindow()`).
  - Подтверждены все 17 каталогов навыков в `.agents/skills/` и доступные системные шрифты Windows (`Bahnschrift`, `Consolas`, `Segoe UI Variable`).
  - Создан отчёт [`ENVIRONMENT_REPORT.md`](ENVIRONMENT_REPORT.md) с зафиксированными зависимостями и списком read-only команд для последующего аудита CachyOS.
  - Обновлены [`STATUS.md`](STATUS.md) и `docs/HANDOFF.md`.
- Relevant files changed:
  - `docs/ENVIRONMENT_REPORT.md` (created)
  - `docs/STATUS.md` (updated)
  - `docs/HANDOFF.md` (updated)
- Commit: `NOT COMMITTED` (`git` отсутствует на Windows-хосте, `.git/` не инициализирован)
- Tests:
  - `Get-Command` / проверка каталогов Qt и Git — `PASS` (подтверждено отсутствие `git`, `C:\Qt`, WSL; найдены `ssh`, `code`, `node`, `python`, `choco`, `PySide6 6.12.0`)
  - `PySide6` + `pyside6-qmllint.exe` + `QQuickWindow.grabWindow()` smoke test — `PASS` (`qmllint rc: 0`, `Render: ok=True size=800x150 bytes=5127 warnings=[]`)
  - `QtQuick.Shapes` + `Layouts` + `Controls` + `Effects` + `VectorImage` + `QtTest` import check — `PASS` (`errs: []`)
  - `pyside6-qml.exe --apptype core` smoke test — `PASS` (`rc: 0`)
  - Проверка 17 навыков в `.agents/skills/` и параметров экранов `QGuiApplication.screens()` — `PASS` (`17` навыков, `2` экрана)
  - CachyOS / Hyprland / Quickshell / D-Bus checks — `NOT RUN — requires CachyOS`
- Environment: `Windows` (`NT 10.0.26100.0`, `PySide6 6.12.0`; CachyOS не подключался)
- Known issues:
  - `git` отсутствует на Windows-хосте; `.git/` не инициализирован; `skills-lock.json` содержит локальные пути.
  - `PySide6\Scripts` не находится в системном `PATH` (утилиты `qml` / `qmllint` нужно вызывать явно через каталог `Scripts` или Python-обёртки).
  - Наличие и версии Hyprland / Quickshell / сервисов на целевом стенде CachyOS не подтверждены (`NOT RUN — requires CachyOS`).
  - Имеется расхождение регламента между действующим правилом [`AGENTS.md`](../AGENTS.md) («Один этап = Один чат», `STATUS.md`/`HANDOFF.md`, `P0–D7`) и новым промптом пользователя (непрерывная работа в одном чате, `DEVELOPMENT_STATUS.md`/`REVIEW_HANDOFF.md`, этапы `1–10`).
- Decisions made:
  - Без новых ADR: зафиксировано, что `D2` на Windows опирается на подтверждённый `PySide6 6.12.0`, а `D3`/Linux-часть остаётся заблокированной по `ADR-002` до аудита CachyOS.
- Next smallest task:
  - Либо завершить Linux-часть **`D1`** при наличии доступа к CachyOS, либо перейти к **`D2` / Этап 2 (Каркас проекта, дизайн-токены `ui/tokens/`, контракты и Windows QtQuick Preview в `preview/` на `PySide6 6.12.0` + базовые `QtTest`-проверки)**.
- Exact files to inspect next:
  - `AGENTS.md`
  - `docs/ENVIRONMENT_REPORT.md`
  - `docs/ARCHITECTURE.md`
  - `docs/DESIGN_SYSTEM.md`
  - `.agents/skills/qtquick-preview/SKILL.md`
  - `.agents/skills/marathon-design-system/SKILL.md`
- User approval needed:
  - 1) Обновить ли `AGENTS.md` под единый непрерывный чат и структуру документов из нового мастер-промпта (`DEVELOPMENT_STATUS.md` / `REVIEW_HANDOFF.md`) или оставить регламент «Один этап = Один чат»?
  - 2) Есть ли сейчас SSH/локальный доступ к целевому ноутбуку на CachyOS для завершения Linux-аудита `D1`, или пока продолжаем с Windows Preview (`D2`)?
  - 3) Нужно ли устанавливать `Git` на Windows или пока продолжаем без локальных коммитов?
