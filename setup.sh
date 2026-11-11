#!/usr/bin/env bash
# MARATHON Tactical — console installer. Run from a downloaded repository.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<'EOF'
MARATHON Tactical — консольный установщик для CachyOS / Arch Linux

  bash setup.sh                Пошаговое меню
  bash setup.sh --dry-run      План установки и зависимостей без записи файлов
  bash setup.sh --install-deps Только автоматическая докачка отсутствующих зависимостей
  bash setup.sh --help         Справка

Запускайте от обычного пользователя, без sudo (при докачке пакетов pacman запросит sudo).
Отсутствующие пакеты из scripts/packages-cachyos.txt автоматически докачиваются через pacman/paru/yay.
EOF
}

mode=menu
case "${1:-}" in
    --help|-h) usage; exit 0 ;;
    --dry-run) mode=preview ;;
    --install-deps) mode=deps ;;
    '') ;;
    *) usage >&2; exit 2 ;;
esac
[[ $# -le 1 ]] || { usage >&2; exit 2; }

[[ "$(uname -s)" == Linux ]] || {
    echo 'ERROR: Установщик предназначен для Linux. Windows Preview: python preview/run_preview.py' >&2
    exit 1
}
[[ "$EUID" -ne 0 ]] || {
    echo 'ERROR: Запустите bash setup.sh от обычного пользователя, без sudo.' >&2
    exit 1
}

source "$ROOT/scripts/profile-common.sh"
profile_paths

trap 'printf "\nОтменено.\n"; exit 130' INT
trap 'exit 143' TERM

confirm() {
    local answer
    printf '%s [y/N]: ' "$1"
    IFS= read -r answer || return 1
    [[ "$answer" =~ ^([Yy]|[Дд][Аа])$ ]]
}

run_step() {
    # Children run in their own Bash process, preserving their strict error mode.
    local status
    if "$BASH" "$@"; then
        printf '\nЗавершено.\n'
    else
        status=$?
        printf '\nERROR: операция завершилась с кодом %s. Проверьте сообщения выше.\n' "$status"
        return "$status"
    fi
}

show_environment() {
    printf '\n============================================================\n'
    printf ' MARATHON TACTICAL // УСТАНОВКА (HYPRLAND LUA)\n'
    printf '============================================================\n'
    printf 'Профиль: %s\nКоманда сессии: %s\n' "$TARGET_DIR" "$LAUNCHER_BIN"
    printf 'Резервные копии: %s\n' "$BACKUP_ROOT"
    printf 'Конфиги hypr/ и quickshell/, службы и текущая сессия сохраняются.\n'
    if [[ -r /etc/os-release ]]; then
        # Display data, never source a file as shell code.
        grep '^PRETTY_NAME=' /etc/os-release || true
    fi
    local command
    for command in Hyprland hyprctl quickshell qs hyprlock wpctl nmcli; do
        if command -v "$command" >/dev/null 2>&1; then
            printf '  [OK]   %s\n' "$command"
        else
            printf '  [MISS] %s\n' "$command"
        fi
    done
    printf '\nМанифест пакетов для автоматической докачки:\n  %s\n' "$ROOT/scripts/packages-cachyos.txt"
    printf 'Отсутствующие зависимости докачиваются автоматически (pacman -S --needed / paru / yay).\n'
    printf 'Профиль использует современный Lua-конфиг: hypr/hyprland.lua.\n'
    if [[ "$XDG_CONFIG_HOME" != "$HOME/.config" ]]; then
        printf 'ВНИМАНИЕ: профиль Hyprland содержит пути $HOME/.config/marathon-tactical.\n'
        printf 'Для установки используйте стандартный XDG_CONFIG_HOME=$HOME/.config.\n'
    fi
}

show_next_steps() {
    printf '\nЗапускать вручную после проверки doctor и совместимости профиля:\n'
    printf '  quickshell -p %q\n' "$TARGET_DIR/shell/shell.qml"
    printf 'Отдельная сессия из свободного TTY (не завершает текущую автоматически):\n  %q\n' "$LAUNCHER_BIN"
    printf 'Докачка пакетов отдельно: bash %q --deps-only\n' "$ROOT/scripts/install.sh"
    printf 'Удаление: bash %q --yes\n' "$ROOT/scripts/uninstall.sh"
    printf 'Откат профиля: bash %q --restore-backup\n' "$ROOT/scripts/uninstall.sh"
    printf 'Откат тем: bash %q --restore\n' "$ROOT/scripts/apply-themes.sh"
    printf 'Onboarding: bash %q --check  |  opt-in login entry: --session-file\n' "$ROOT/scripts/onboarding.sh"
}

show_environment
if [[ "$mode" == preview ]]; then
    "$BASH" "$ROOT/scripts/install.sh" --dry-run
    exit 0
fi
if [[ "$mode" == deps ]]; then
    "$BASH" "$ROOT/scripts/install.sh" --deps-only
    exit 0
fi

while true; do
    cat <<'EOF'

  1. Установить / обновить изолированный профиль (с автодокачкой зависимостей)
  2. Показать план установки и зависимостей (dry-run)
  3. Диагностика окружения (только чтение)
  4. Восстановить темы приложений из последней копии
  5. Восстановить предыдущий профиль из резервной копии
  6. Удалить изолированный профиль
  7. Команды запуска и восстановления
  0. Выход
EOF
    printf 'Выберите действие: '
    IFS= read -r choice || { printf '\nВыход.\n'; exit 0; }
    case "$choice" in
        1)
            args=("$ROOT/scripts/install.sh" --yes --install-deps)
            themes=no
            if confirm 'Применить темы внешних приложений с резервной копией?'; then
                args+=(--apply-app-themes)
                themes=yes
            fi
            printf '\nПлан: автодокачка пакетов + установка/обновление %s\nТемы приложений: %s\n' "$TARGET_DIR" "$themes"
            printf 'Предыдущий профиль будет сохранён в %s.\n' "$BACKUP_ROOT"
            if [[ "$XDG_CONFIG_HOME" != "$HOME/.config" ]]; then
                printf 'ERROR: Установка через мастер требует стандартного XDG_CONFIG_HOME (см. выше).\n'
                continue
            fi
            if confirm 'Выполнить этот план?'; then
                if run_step "${args[@]}"; then show_next_steps; fi
            else
                printf 'Отменено.\n'
            fi
            ;;
        2) run_step "$ROOT/scripts/install.sh" --dry-run || true ;;
        3) run_step "$ROOT/scripts/doctor.sh" || true ;;
        4)
            if confirm 'Восстановить темы приложений из последней резервной копии?'; then
                run_step "$ROOT/scripts/apply-themes.sh" --restore --yes || true
            fi
            ;;
        5)
            if confirm 'Восстановить предыдущий профиль (текущий тоже будет сохранён)?'; then
                run_step "$ROOT/scripts/uninstall.sh" --restore-backup --yes || true
            fi
            ;;
        6)
            printf 'Темы приложений восстанавливаются отдельно пунктом 4 ДО удаления профиля.\n'
            printf 'План: удалить %s и %s; резервные копии останутся.\n' "$TARGET_DIR" "$LAUNCHER_BIN"
            if confirm 'Удалить изолированный профиль?'; then
                run_step "$ROOT/scripts/uninstall.sh" --yes || true
            fi
            ;;
        7) show_next_steps ;;
        0|q|Q) exit 0 ;;
        *) printf 'Введите номер 1–7 или 0 для выхода.\n' ;;
    esac
done
