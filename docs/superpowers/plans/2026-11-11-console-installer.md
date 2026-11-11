# Console Installer Implementation Plan

> **For agentic workers:** execute inline using executing-plans; no commit or push in this task.

**Goal:** консольное меню установки, диагностики и отката MARATHON Tactical.
**Architecture:** `setup.sh` вызывает существующие Bash-скрипты массивами аргументов. Общие проверки путей и генерация session helper переиспользуются установкой и откатом.
**Tech Stack:** Bash, Python unittest для subprocess-сценариев с временным HOME.
**Spec:** `docs/CONSOLE_INSTALLER_DESIGN.md` (утверждён пользователем).

## Global Constraints

- Изолированный профиль, темы только opt-in, без автоматической установки пакетов или запуска сессии.
- Меню не работает от root; dry-run не записывает файлы.
- Действующие конфиги Hyprland и Quickshell, display manager и удалённый доступ не меняются.
- CachyOS runtime: `NOT RUN — requires CachyOS`.

## Review Focus

- EOF / отмена / неверный ввод: отсутствие неожиданных изменений.
- Пути с пробелами и симлинки: отказ от опасных целей, корректная команда запуска.
- Отсутствующая резервная копия: отказ до удаления профиля.
- Быстрые повторные обновления: резервные копии не перезаписываются.
- Восстановление: сохранение настроек и работоспособный session helper.

## Task 1: Безопасная установка и восстановление

Files: `scripts/install.sh`, `scripts/uninstall.sh`, `scripts/profile-common.sh`, `tests/test_installer.py`.

- [x] Написать и запустить regression-тесты временного HOME для dry-run, install/update/restore, отсутствующего backup, launcher и опасных путей.
- [x] Реализовать общую валидацию путей, уникальные backup и восстановление launcher; сохранить настройки и команды существующего CLI.
- [x] Запустить сценарии и проверить сохранность посторонних конфигов.

## Task 2: Консольное меню и документация

Files: `setup.sh`, `tests/test_installer.py`, `README.md`, `docs/DEVELOPMENT_STATUS.md`, `docs/REVIEW_HANDOFF.md`.

- [x] Добавить failing-тесты меню, EOF, отмены, dry-run и дочерней ошибки.
- [x] Реализовать меню с отдельным opt-in тем, итоговым планом, проверкой Linux/root и выводом зависимостей без установки.
- [x] Запустить Bash syntax / функциональные тесты, существующие контрактные проверки; обновить документацию с фактическими ограничениями.

## Execution decisions

Работа выполняется в текущей папке: пользователь утвердил локальную реализацию, других изменений кода нет. Git commit/push не выполняются. Тесты используют отдельную копию скриптов и временный HOME, а не настройки пользователя.

Фактическая проверка: regression-тесты сначала воспроизвели потерю launcher и удаление при отсутствии backup; после реализации — 13 PASS / 1 SKIP из 14. Симлинки Windows запрещает, chmod заглушён; runtime CachyOS не проверен. Дополнительно проверен сбой копирования до замены профиля и реальный запуск launcher с тестовым исполняемым Hyprland, проверяющим аргументы.
