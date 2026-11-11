# Agent Skills — MARATHON Tactical

Руководство по установленным и собственным навыкам Google Antigravity в пространстве `.agents/skills/` для проекта **MARATHON Tactical**.

Все навыки установлены **локально в проект** (`.agents/skills/`), без глобальной установки и без изменения системных настроек Windows или конфигурации Hyprland.

---

## 1. Назначение и триггеры активации (11 целевых навыков)

### 1.1. Собственные навыки проекта (5)

| Навык | Назначение | Когда должен активироваться | Не использовать для |
|---|---|---|---|
| `quickshell-expert` | Разработка и отладка Quickshell-оболочки, `PanelWindow`, `Variants` (multi-monitor), Hyprland IPC, PipeWire, MPRIS, Notifications, SystemTray и Linux-адаптеров в `shell/services/`. | Работа с `shell/`, `shell.qml`, Wayland layer-shell, системными сервисами Linux, отладка binding loops и утечек ресурсов в Quickshell. | Windows Mock Preview (`qtquick-preview`), конфиги Hyprland (`hyprland-expert`), стилистика токенов (`marathon-design-system`). |
| `hyprland-expert` | Настройка, изоляция и диагностика Hyprland на CachyOS/Arch Linux: определение версии, синтаксис `hyprlang` / `hyprland.lua`, мониторы, window rules, workspaces, tiling/floating, анимации, кейбинды, безопасный запуск и rollback. | Редактирование `hypr/`, `docs/KEYBINDINGS.md`, настройка изолированной сессии, диагностика проблем запуска Hyprland / DRM / Wayland / Quickshell. | Компоненты QML (`quickshell-expert`, `qtquick-preview`). |
| `qtquick-preview` | Разработка и визуальная проверка QML на Windows 11 через `preview/Main.qml`, Mock Backend (`preview/mocks/`), воспроизводимые сценарии (`preview/scenarios/`), контракты mock/live, размеры, HiDPI и анимации. | Запуск или доработка Windows Preview, создание/обновление моков и сценариев (`1366x768`, `1920x1080`, `2560x1440`, HiDPI, сбои датчиков/сети/звука), проверка визуальных дефектов без Linux. | Linux live-адаптеры (`quickshell-expert`) и конфигурация Hyprland (`hyprland-expert`). |
| `marathon-design-system` | Единые дизайн-токены (`ui/tokens/`), тактический визуальный язык, контрастность, клавиатурная навигация, состояния (`hover`/`active`/`disabled`/`focus`), `reducedMotion`, оригинальные SVG и визуальное ревью по скриншотам для 8 ключевых поверхностей (Top HUD, Workspace Indicator, Launcher, Control Center, Notification Center, OSD, Session Menu, Lock Screen). | Проектирование, стилизация или аудит любого QML-компонента, токенов, SVG-иконок и скриншотов UI. При наличии `DESIGN_SYSTEM.md` / `docs/DESIGN_SYSTEM.md` приоритет у него. | Логика Linux-сервисов (`quickshell-expert`) или конфиг Hyprland (`hyprland-expert`). |
| `marathon-git-handoff` | Экономия контекста и передача состояния между чатами Antigravity по правилу «один малый вертикальный срез = один чат», шаблон `HANDOFF.md` и шаблон отчёта для ревью в ChatGPT. | Начало или завершение изолированной задачи, проверка `git status`, формирование `HANDOFF.md` / `docs/HANDOFF.md` или `Code Review Handoff`. | Сама реализация QML, дизайна или Hyprland. |

### 1.2. Готовые внешние навыки (6)

| Навык | Источник | Назначение | Когда должен активироваться |
|---|---|---|---|
| `frontend-design` | `anthropics/skills` | Проработка выразительной визуальной композиции, типографики и иерархии без шаблонных решений. | Вспомогательный навык при улучшении композиции UI строго поверх `marathon-design-system`. |
| `ui-ux-pro-max` | `nextlevelbuilder/ui-ux-pro-max-skill` | Поисковая база UX-паттернов, доступности, типографики и layout-рекомендаций (`scripts/search.py`). | Вспомогательный навык для сложных UX-задач (навигация Launcher/Control Center, доступность, плотность) без замены палитры MARATHON Tactical. |
| `systematic-debugging` | `obra/superpowers` | Строгий многофазный поиск первопричины (root-cause analysis) до внесения правок. | При любых багах, падениях QML/Quickshell, ошибках сборок и непредсказуемом поведении. |
| `verification-before-completion` | `obra/superpowers` | Запрет на заявления о завершении без свежего запуска проверяющих команд и фактического вывода. | Перед объявлением любой задачи выполненной, перед отчётом или коммитом. |
| `requesting-code-review` | `obra/superpowers` | Подготовка чистого контекста для независимого ревью изменений по diff/требованиям. | После завершения значимого модуля/этапа и перед отправкой диффа на ревью. |
| `skill-creator` | `anthropics/skills` | Создание, аудит, валидация и оптимизация описаний Agent Skills. | **Только** при создании, редактировании или проверке файлов `.agents/skills/*/SKILL.md`. |

### 1.3. Сопутствующие навыки из пакета `ui-ux-pro-max-cli@2.15.0`

При запуске официального установщика `npx ui-ux-pro-max-cli init --ai antigravity` (версия `2.15.0`) CLI автоматически развернул вместе с `ui-ux-pro-max` ещё 6 шаблонных навыков в `.agents/skills/`: `banner-design`, `brand`, `design`, `design-system`, `slides`, `ui-styling`.

- В рамках MARATHON Tactical **не активируйте** их для QML/Hyprland-задач (они ориентированы на веб/Tailwind/баннеры/презентации и расходуют лишний контекст).
- Для дизайн-системы проекта используйте исключительно `marathon-design-system` (и утверждённый `DESIGN_SYSTEM.md` при наличии).

---

## 2. Правила совместного использования и матрица сочетаний

1. **Никогда не активируйте все 11 навыков одновременно** — загружайте только 1–2 релевантных навыка под текущий срез задачи.
2. **Приоритет дизайн-правил**: `docs/DESIGN_SYSTEM.md` (или `DESIGN_SYSTEM.md`) → `marathon-design-system` → вспомогательно `frontend-design` / `ui-ux-pro-max`. Внешние дизайн-навыки не могут переопределять палитру (`#080B0A`, `#141C18`, `#C9FF16`, `#F0F4E8`, `#FF4268`) или заменять QML на веб-стек.
3. **`skill-creator` изолирован**: используется только при доработке самой системы навыков.

| Тип задачи | Рекомендуемые навыки |
|---|---|
| QML-компонент / Quickshell-панель | `quickshell-expert` |
| Настройка окон / профиля Hyprland | `hyprland-expert` |
| Windows Preview / Mock Backend | `qtquick-preview` |
| Визуальное оформление HUD/компонентов | `marathon-design-system` + `frontend-design` |
| Сложный UX / доступность / навигация | `marathon-design-system` + `ui-ux-pro-max` |
| Отладка бага или сбоя | `systematic-debugging` |
| Проверка результата перед сдачей | `verification-before-completion` |
| Подготовка ревью изменений | `requesting-code-review` |
| Начало / завершение чата и handoff | `marathon-git-handoff` |

---

## 3. Способы ручной активации

Google Antigravity автоматически обнаруживает навыки из `.agents/skills/` (по имени и `description` из YAML frontmatter) через progressive disclosure. При необходимости можно активировать навык явно:

1. **Прямое указание в запросе Antigravity**:
   - Пример: `Используй навык qtquick-preview и marathon-design-system для реализации Top HUD на Windows Preview.`
2. **Явное чтение файла инструкций**:
   - Попросить агента прочитать `.agents/skills/<skill-name>/SKILL.md` (и при необходимости файлы из `references/`).
3. **Запуск локальных вспомогательных скриптов вручную**:
   - Например, поиск по базе `ui-ux-pro-max`: `python .agents/skills/ui-ux-pro-max/scripts/search.py "dark tactical hud" --domain ux`

---

## 4. Источники внешних навыков

| Навык | Репозиторий / Пакет | Способ установки |
|---|---|---|
| `frontend-design`, `skill-creator` | `https://github.com/anthropics/skills` | `npx skills` (из-за отсутствия `git` на хосте — через локальный архив зафиксированного коммита; см. `docs/SKILLS_INSTALL_REPORT.md`) |
| `systematic-debugging`, `verification-before-completion`, `requesting-code-review` | `https://github.com/obra/superpowers` | `npx skills` (через локальный архив зафиксированного коммита; см. `docs/SKILLS_INSTALL_REPORT.md`) |
| `ui-ux-pro-max` (+ 6 bundled templates) | `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` (`ui-ux-pro-max-cli@2.15.0`) | `npx --yes ui-ux-pro-max-cli init --ai antigravity` |

---

## 5. Инструкции по обновлению

> Перед обновлением проверьте `git status` и при наличии локальных правок сделайте резервную копию нужного каталога. Не перезаписывайте собственные навыки (`quickshell-expert`, `hyprland-expert`, `qtquick-preview`, `marathon-design-system`, `marathon-git-handoff`).

1. **На машине с установленным Git**:
   ```powershell
   npx --yes skills add anthropics/skills --skill frontend-design --skill skill-creator -a antigravity --copy -y
   npx --yes skills add obra/superpowers --skill systematic-debugging --skill verification-before-completion --skill requesting-code-review -a antigravity --copy -y
   ```
   (После этого `skills-lock.json` будет привязан напрямую к GitHub-репозиториям и позволит запускать `npx skills update -p -y`.)
2. **Обновление `ui-ux-pro-max`**:
   ```powershell
   npx --yes ui-ux-pro-max-cli update
   ```
   Или точечная переустановка в проект (`init --ai antigravity --force` после проверки различий).

---

## 6. Инструкции по удалению

1. **Удаление навыков, управляемых `skills` CLI**:
   ```powershell
   npx --yes skills remove <skill-name> -a antigravity -y
   ```
2. **Удаление `ui-ux-pro-max`**:
   ```powershell
   npx --yes ui-ux-pro-max-cli uninstall
   ```
3. **Точечное удаление любого локального навыка**:
   - Удалить только целевую папку `.agents/skills/<skill-name>/` (не удаляя чужие каталоги).

---

## 7. Правила экономии контекста

1. **Progressive Disclosure**: Antigravity держит в системном списке только `name` и `description` навыков; полный `SKILL.md` читается только при активации.
2. **Вынос справочников в `references/`**: файлы внутри `references/` (например, `quickshell-apis.md`, `diagnostics-and-syntax.md`, `preview-scenarios.md`, `visual-review-checklist.md`) читаются **только** при работе с соответствующим разделом.
3. **Один срез — один чат**: используйте `marathon-git-handoff`, открывайте только файлы текущей задачи, не перечитывайте всю историю и весь репозиторий.
4. **Не дублировать правила**: не копируйте полную документацию Quickshell/Hyprland внутрь чата и не смешивайте несвязанные навыки.

