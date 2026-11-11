# Отчёт об установке и настройке Agent Skills — MARATHON Tactical

Дата настройки: `2026-11-10`  
Рабочий каталог (workspace): `C:\Users\Voklin\Documents\dotfile`  
Среда выполнения: Windows 11

---

## 1. Версии инструментов и окружение

| Инструмент | Обнаруженная версия / Статус | Примечание |
|---|---|---|
| Node.js | `v24.22.0` | Доступен |
| npm | `11.19.1` | Доступен |
| npx | `11.19.1` | Доступен (при сетевых вызовах и обращении к глобальному npm-кешу требуется выполнение вне sandbox) |
| `skills` CLI (`npx skills`) | `1.8.0` | Загружен через `npx --yes skills`; требует `git` для клонирования удалённых GitHub-репозиториев |
| `ui-ux-pro-max-cli` | `2.15.0` | Загружен через `npx --yes ui-ux-pro-max-cli`; содержит встроенные шаблоны (offline templates) |
| Python | `3.15.0` (`python`) | `python3` не настроен в системе; пакет `PyYAML` (`yaml`) не установлен |
| Git | **Отсутствует** | `git` не найден в `PATH` и стандартных путях установки; `.git/` в корне проекта отсутствует |
| Глобальные каталоги навыков (`~/.agents`, `~/.gemini/antigravity/skills`) | Отсутствуют (`False`) | Глобальная установка не выполнялась |

---

## 2. Выполненные команды

| № | Команда | Результат | Комментарий |
|---|---|---|---|
| 1 | `git --version`, `node --version`, `npm --version`, `npx --version` | `git`: не найден; Node `v24.22.0`, npm/npx `11.19.1` | Предварительная проверка окружения |
| 2 | `npx skills --help` (sandbox) -> `npx --yes skills --help` (вне sandbox) | Ошибка/зависание в sandbox -> Успех вне sandbox | В sandbox заблокирована сеть; вне sandbox выведена справка `skills@1.8.0` |
| 3 | `npx --yes skills add anthropics/skills --skill frontend-design -a antigravity -y` | **Ошибка** (`exit code 1`) | `[SKILLS_GIT_CLONE_FAILED] Failed to clone https://github.com/anthropics/skills.git: Error: spawn git ENOENT` |
| 4 | `npx --yes ui-ux-pro-max-cli init --ai antigravity` | **Успех** (`exit code 0`) | Установлен `ui-ux-pro-max` и 6 сопутствующих шаблонных навыков пакета `2.15.0` в `.agents/skills/` |
| 5 | Запрос последних коммитов GitHub API + загрузка zip-архивов `anthropics/skills` и `obra/superpowers` во временный scratch-каталог | **Успех** (`exit code 0`) | Получены ревизии `2c5958ecac7cee2b583967a2c4981d0f4a75c579` (`anthropics/skills`) и `22f0b463e7a5e579904dd6211a520321035526f7` (`obra/superpowers`); удалённые скрипты не запускались |
| 6 | `npx --yes skills add "<scratch>\anthropics-skills\..." --skill frontend-design --skill skill-creator -a antigravity --copy -y` | **Успех** (`exit code 0`) | Установлены только 2 целевых навыка в `.agents/skills/` |
| 7 | `npx --yes skills add "<scratch>\obra-superpowers\..." --skill systematic-debugging --skill verification-before-completion --skill requesting-code-review -a antigravity --copy -y` | **Успех** (`exit code 0`) | Установлены только 3 целевых навыка в `.agents/skills/` |
| 8 | Создание 5 собственных навыков (`quickshell-expert`, `hyprland-expert`, `qtquick-preview`, `marathon-design-system`, `marathon-git-handoff`) и справочников `references/` | **Успех** | Написаны на английском, с валидным YAML frontmatter и разделением `SKILL.md` / `references/` |
| 9 | `python .agents\skills\skill-creator\scripts\quick_validate.py <dir>` | **Ошибка** (`ModuleNotFoundError: No module named 'yaml'`) | В Python `3.15.0` отсутствует сторонний модуль `PyYAML` |
| 10 | `python "...\scratch\validate_skills.py"` (stdlib Python) | **Успех** (`ALL CHECKS PASSED`) | Проверены все 17 каталогов в `.agents/skills/`: `SKILL.md`, frontmatter, уникальность имён, отсутствие `<`/`>`, целостность ссылок на `references/` |
| 11 | `npx --yes skills ls --json` | **Успех** (`exit code 0`) | Подтверждены `scope: "project"` и присутствие всех навыков в `.agents/skills/` для `Antigravity` |
| 12 | `python .agents\skills\ui-ux-pro-max\scripts\search.py "desktop tactical dark dashboard" --domain style -n 3` | **Успех** (`exit code 0`) | Подтверждена работоспособность Python-скрипта поиска `ui-ux-pro-max` |
| 13 | Субагент-проверка обнаружения и активации в Antigravity (`self` subagent в workspace) | **Успех** | Подтверждено обнаружение целевых навыков из `.agents/skills/` и успешная активация/чтение `marathon-design-system` и `verification-before-completion` |

---

## 3. Статус навыков и источники установки

### 3.1. Целевые готовые навыки (6/6 установлены)

| Навык | Статус | Источник | Ревизия / Версия | Примечание |
|---|---|---|---|---|
| `frontend-design` | Установлен | `https://github.com/anthropics/skills` (`skills/frontend-design`) | `2c5958ecac7cee2b583967a2c4981d0f4a75c579` (`2026-11-06T22:32:28Z`) | Установлен через `npx skills add <verified-local-archive> --copy -y` (обход `spawn git ENOENT`) |
| `skill-creator` | Установлен | `https://github.com/anthropics/skills` (`skills/skill-creator`) | `2c5958ecac7cee2b583967a2c4981d0f4a75c579` (`2026-11-06T22:32:28Z`) | Включает `scripts/quick_validate.py`, `agents/`, `references/` |
| `systematic-debugging` | Установлен | `https://github.com/obra/superpowers` (`skills/systematic-debugging`) | `22f0b463e7a5e579904dd6211a520321035526f7` (`2026-11-03T22:17:07Z`) | Включает вспомогательные `.md`/`.sh`/`.ts` файлы |
| `verification-before-completion` | Установлен | `https://github.com/obra/superpowers` (`skills/verification-before-completion`) | `22f0b463e7a5e579904dd6211a520321035526f7` (`2026-11-03T22:17:07Z`) | Полный `SKILL.md` проверен |
| `requesting-code-review` | Установлен | `https://github.com/obra/superpowers` (`skills/requesting-code-review`) | `22f0b463e7a5e579904dd6211a520321035526f7` (`2026-11-03T22:17:07Z`) | Включает `code-reviewer.md` |
| `ui-ux-pro-max` | Установлен | `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` (`ui-ux-pro-max-cli`) | `2.15.0` | Установлен командой `npx --yes ui-ux-pro-max-cli init --ai antigravity`; содержит `data/` и `scripts/search.py` |

### 3.2. Собственные навыки проекта (5/5 созданы)

| Навык | Статус | Вспомогательные файлы | Основные требования |
|---|---|---|---|
| `quickshell-expert` | Создан | `references/quickshell-apis.md` | Разделение UI/сервисов, запрет выдуманных API, событийная модель вместо polling |
| `hyprland-expert` | Создан | `references/diagnostics-and-syntax.md` | Проверка версии перед синтаксисом (`hyprlang` vs `hyprland.lua`), изоляция сессии, rollback, 4-уровневая диагностика |
| `qtquick-preview` | Создан | `references/preview-scenarios.md` | Windows 11 Preview без Quickshell, Mock Backend parity, 10 сценариев от `1366x768` до `2560x1440` и HiDPI |
| `marathon-design-system` | Создан | `references/visual-review-checklist.md` | Токены (`#080B0A`, `#141C18`, `#C9FF16`, `#F0F4E8`, `#FF4268`), приоритет `DESIGN_SYSTEM.md`, 8 компонентов, процедура ревью скриншотов |
| `marathon-git-handoff` | Создан | — (шаблоны встроены в `SKILL.md`) | Форматы `HANDOFF.md` и `Code Review Handoff`, 8-шаговый workflow, запрет авто-коммитов/push |

### 3.3. Сопутствующие каталоги `ui-ux-pro-max-cli@2.15.0`

Установщик `npx ui-ux-pro-max-cli init --ai antigravity` (версия `2.15.0`) дополнительно развернул в `.agents/skills/` 6 шаблонных навыков из своего дистрибутива: `banner-design`, `brand`, `design`, `design-system`, `slides`, `ui-styling`. Они не удалялись (чтобы не нарушать целостность вывода официального CLI), проверены валидатором на отсутствие конфликтов имён и задокументированы в `docs/AGENT_SKILLS.md` как неактивируемые по умолчанию.

---

## 4. Ошибки и способы их устранения

1. **Зависание `npx` внутри sandbox**: стандартный terminal sandbox не имеет сетевого доступа. Исправлено повторным запуском только необходимых `npx` и загрузочных команд с `BypassSandbox: true`.
2. **Ошибка `[SKILLS_GIT_CLONE_FAILED] ... Error: spawn git ENOENT`**: в системе отсутствует `git`, из-за чего `npx skills add anthropics/skills ...` и `obra/superpowers` не смогли выполнить `git clone`. Исправлено получением зафиксированных SHA коммитов через официальный GitHub API, скачиванием официальных `.zip`-архивов в изолированный scratch-каталог (без запуска скачанных скриптов) и установкой целевых навыков через `npx --yes skills add <local-path> ... -a antigravity --copy -y`.
3. **Ошибка валидатора `quick_validate.py` (`ModuleNotFoundError: No module named 'yaml'`)**: системный Python `3.15.0` не содержит `PyYAML`. Сторонние пакеты в систему не устанавливались; полная проверка frontmatter, уникальности имён и относительных ссылок выполнена через автономный stdlib-скрипт в scratch-каталоге (`validate_skills.py`).

---

## 5. Проверенные сценарии

- Проверка отсутствия глобальных каталогов навыков (`C:\Users\Voklin\.agents`, `C:\Users\Voklin\.gemini\antigravity\skills` — `False`).
- Проверка наличия `SKILL.md`, корректности YAML frontmatter, длины `name`/`description`, отсутствия `<`/`>` и совпадения `name` с именем каталога для всех 17 каталогов (включая все 11 целевых).
- Проверка отсутствия конфликтующих имён навыков во всём `.agents/skills/`.
- Проверка целостности всех относительных ссылок на `./references/*` в собственных `SKILL.md`.
- Проверка обнаружения проектов через `npx --yes skills ls --json`.
- Smoke-тест поискового скрипта `ui-ux-pro-max` (`scripts/search.py`) на Python `3.15.0`.
- Реальный тест обнаружения и активации в Antigravity через новый контекст субагента (`self` subagent): подтверждено обнаружение локальных навыков и чтение `marathon-design-system/SKILL.md` (токены `#080B0A`, `#C9FF16`, приоритет `DESIGN_SYSTEM.md`) и `verification-before-completion`.
- Проверка неизменности исходного `MARATHON_TACTICAL_MASTER_PROMPT.md` и отсутствия изменений Hyprland/Windows системных настроек.

---

## 6. Добавленные и изменённые файлы

- `.agents/skills/frontend-design/...` (установлен из `anthropics/skills`)
- `.agents/skills/skill-creator/...` (установлен из `anthropics/skills`)
- `.agents/skills/systematic-debugging/...` (установлен из `obra/superpowers`)
- `.agents/skills/verification-before-completion/...` (установлен из `obra/superpowers`)
- `.agents/skills/requesting-code-review/...` (установлен из `obra/superpowers`)
- `.agents/skills/ui-ux-pro-max/...` (+ `banner-design`, `brand`, `design`, `design-system`, `slides`, `ui-styling` от `ui-ux-pro-max-cli@2.15.0`)
- `.agents/skills/quickshell-expert/SKILL.md` и `references/quickshell-apis.md`
- `.agents/skills/hyprland-expert/SKILL.md` и `references/diagnostics-and-syntax.md`
- `.agents/skills/qtquick-preview/SKILL.md` и `references/preview-scenarios.md`
- `.agents/skills/marathon-design-system/SKILL.md` и `references/visual-review-checklist.md`
- `.agents/skills/marathon-git-handoff/SKILL.md`
- `skills-lock.json` (создан `npx skills add` при установке 5 навыков)
- `docs/AGENT_SKILLS.md`
- `docs/SKILLS_INSTALL_REPORT.md`

`MARATHON_TACTICAL_MASTER_PROMPT.md` не изменялся.

---

## 7. Нерешённые проблемы и ограничения

1. **Отсутствует `git` на Windows 11**:
   - Невозможно проверить `git status` или выполнить прямое обновление через `npx skills add <owner/repo>` без предварительной установки Git.
   - `skills-lock.json` содержит локальные пути из scratch-каталога (`sourceType: "local"`) вместо `github` URL; после установки Git (или на CachyOS) рекомендуется повторно выполнить команды `npx skills add ...` для перепривязки `skills-lock.json`.
2. **Отсутствует `PyYAML` в Python `3.15.0`**: встроенный скрипт `.agents/skills/skill-creator/scripts/quick_validate.py` не запускается без установки `pyyaml`.
3. **Инструменты Qt Preview, Quickshell и Hyprland на этом хосте не проверялись**: разработка самой оболочки и аудит сред (`P0` / `D1`) в этой задаче не запускались.

