#!/usr/bin/env bash
# MARATHON Tactical — Safe Isolated Installer for CachyOS / Arch Linux
# Installs cleanly into ~/.config/marathon-tactical/ without overwriting ~/.config/hypr/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "$SCRIPT_DIR/profile-common.sh"

DRY_RUN=0
AUTO_YES=0
APPLY_APP_THEMES=0
INSTALL_DEPS=1
DEPS_ONLY=0

usage() {
    cat <<'EOF'
MARATHON Tactical — Isolated Profile Installer (CachyOS / Hyprland Lua + Quickshell)

Usage:
  bash scripts/install.sh [--dry-run] [--install-deps] [--no-deps] [--deps-only] [--apply-app-themes] [--yes] [--help]

Options:
  --dry-run           Print planned operations and dependency status without writing any files.
  --install-deps      Automatically download and install missing packages from scripts/packages-cachyos.txt (default).
  --no-deps           Skip automatic package installation and only deploy the isolated profile files.
  --deps-only         Only check and install missing packages from scripts/packages-cachyos.txt.
  --apply-app-themes  Also deploy styled app configs (~/.config/ghostty, kitty, btop, yazi, gtk, qt6ct, mpv, imv, zathura, starship, fastfetch) with automatic backup.
  --yes               Skip interactive confirmation prompt (still never overwrites ~/.config/hypr/).
  --help              Show this help message.

Safety Guarantees:
  - Installs ONLY into ~/.config/marathon-tactical/ and ~/.local/bin/marathon-tactical-session
  - Uses `pacman -S --needed` (and paru/yay for AUR); never runs `pacman -Rns` or full system upgrade.
  - Never modifies ~/.config/hypr/, ~/.config/quickshell/, display managers, or sshd.
  - Backs up any previous ~/.config/marathon-tactical/ installation before updating.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --install-deps)
            INSTALL_DEPS=1
            shift
            ;;
        --no-deps)
            INSTALL_DEPS=0
            shift
            ;;
        --deps-only)
            INSTALL_DEPS=1
            DEPS_ONLY=1
            shift
            ;;
        --apply-app-themes)
            APPLY_APP_THEMES=1
            shift
            ;;
        --yes|-y)
            AUTO_YES=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$1'" >&2
            usage >&2
            exit 2
            ;;
    esac
done

profile_paths

log() {
    printf '[MARATHON] %s\n' "$*"
}

run_or_dry() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[DRY-RUN] %s\n' "$*"
    else
        "$@"
    fi
}

log "Repository source : $REPO_ROOT"
log "Isolated target   : $TARGET_DIR"
log "Session helper    : $LAUNCHER_BIN"
log "User ~/.config/hypr/ stays untouched."

# Verify required source directories exist
for d in ui shell hypr design apps scripts; do
    if [[ ! -d "$REPO_ROOT/$d" ]]; then
        echo "ERROR: Missing source directory '$REPO_ROOT/$d'" >&2
        exit 1
    fi
done

if [[ "$DEPS_ONLY" -eq 1 ]]; then
    install_missing_dependencies "$REPO_ROOT/scripts/packages-cachyos.txt" "$DRY_RUN"
    exit 0
fi

# Non-destructive dependency & Hyprland version audit
check_cmd() {
    local cmd="$1"
    local role="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        printf '  [OK]   %-14s (%s) -> %s\n' "$cmd" "$role" "$(command -v "$cmd")"
    else
        printf '  [MISS] %-14s (%s)\n' "$cmd" "$role"
    fi
}

log "Checking target binaries (read-only)..."
check_cmd Hyprland "compositor (required)"
check_cmd hyprctl "Hyprland IPC"
check_cmd quickshell "shell runtime (required)"
check_cmd qs "Quickshell IPC CLI"
check_cmd hyprlock "PAM lockscreen"
check_cmd wpctl "PipeWire CLI"
check_cmd brightnessctl "Backlight CLI"
check_cmd nmcli "NetworkManager CLI"
check_cmd busctl "D-Bus probe"
check_cmd grim "Wayland screenshot (optional)"
check_cmd slurp "Region selector (optional)"
check_cmd satty "Screenshot annotator (optional)"
check_cmd cliphist "Clipboard history (optional)"
check_cmd wl-copy "Clipboard copy (optional)"
check_cmd hyprpicker "Color picker (optional)"
check_cmd hypridle "Idle lock daemon (optional)"
check_cmd hyprsunset "Night light (optional)"
check_cmd ghostty "Primary terminal (optional)"
check_cmd btop "TUI monitor (optional)"
check_cmd yazi "TUI file manager (optional)"

if command -v Hyprland >/dev/null 2>&1 && command -v timeout >/dev/null 2>&1; then
    hypr_ver="$(timeout 5 Hyprland --version 2>/dev/null | head -n 1 || true)"
    log "Detected compositor: ${hypr_ver:-unknown}"
    if [[ "$hypr_ver" =~ 0\.([0-9]+) ]]; then
        minor="${BASH_REMATCH[1]}"
        if (( minor < 55 )); then
            log "WARNING: Hyprland < 0.55 detected. Native hyprland.lua requires Hyprland 0.55+."
        fi
    fi
fi

if [[ "$DRY_RUN" -eq 0 && "$AUTO_YES" -eq 0 ]]; then
    printf '\nProceed with isolated installation into %s? [y/N] ' "$TARGET_DIR"
    read -r reply || reply=''
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        log "Installation cancelled by user. Zero changes applied."
        exit 0
    fi
fi

if [[ "$INSTALL_DEPS" -eq 1 ]]; then
    install_missing_dependencies "$REPO_ROOT/scripts/packages-cachyos.txt" "$DRY_RUN"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN: stage ui, shell, hypr, design, apps, scripts; preserve settings and palettes."
    log "DRY-RUN: back up existing profile to $BACKUP_ROOT/<unique-id> before replacement."
    printf '[DRY-RUN] Write session launcher helper: %s\n' "$LAUNCHER_BIN"
else
    # Finish copying before touching a working installation. The stage is a
    # direct, freshly-created child of the already validated config root.
    mkdir -p "$XDG_CONFIG_HOME" "$BIN_DIR"
    stage="$(mktemp -d "$XDG_CONFIG_HOME/.marathon-stage.XXXXXXXX")"
    backup=''
    cleanup() {
        local status=$?
        trap - EXIT
        if [[ -n "$stage" && -d "$stage" && ! -L "$stage" ]]; then
            rm -rf -- "${stage:?}"
        fi
        if [[ ! -e "$TARGET_DIR" && -n "$backup" && -d "$backup" ]]; then
            mv -- "$backup" "$TARGET_DIR"
        fi
        exit "$status"
    }
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    for d in ui shell hypr design apps scripts; do
        cp -a -- "$REPO_ROOT/$d" "$stage/$d"
    done
    for relative in settings.json scratchpad.txt hypr/user-settings.lua apps/generated; do
        if [[ -e "$TARGET_DIR/$relative" ]]; then
            [[ ! -L "$TARGET_DIR/$relative" ]] || {
                log "ERROR: Refusing symlinked user data: $relative"; exit 1;
            }
            if [[ -d "$TARGET_DIR/$relative" ]]; then
                cp -a -- "$TARGET_DIR/$relative/." "$stage/$relative/"
            else
                cp -a -- "$TARGET_DIR/$relative" "$stage/$relative"
            fi
        fi
    done
    chmod 0755 "$stage"/scripts/*.sh
    write_session_helper "$stage/.session-helper"
    if [[ -d "$TARGET_DIR" ]]; then
        mkdir -p "$BACKUP_ROOT"
        backup="$(mktemp -d "$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)-XXXXXXXX")"
        rmdir -- "$backup"
        mv -- "$TARGET_DIR" "$backup"
        log "Previous profile backed up: $backup"
    fi
    mv -- "$stage" "$TARGET_DIR"
    stage=''
    mv -f -- "$TARGET_DIR/.session-helper" "$LAUNCHER_BIN"
fi

if [[ "$APPLY_APP_THEMES" -eq 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
        "$BASH" "$REPO_ROOT/scripts/apply-themes.sh" --dry-run
    else
        "$BASH" "$TARGET_DIR/scripts/apply-themes.sh" --yes
    fi
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN complete. No files were created or modified."
else
    log "Isolated install COMPLETE."
    log "Next steps on CachyOS:"
    log "  1. Run diagnostics: bash $REPO_ROOT/scripts/doctor.sh"
    log "  2. Launch isolated shell inside existing Hyprland test or new TTY:"
    log "     quickshell -p $TARGET_DIR/shell/shell.qml"
    log "     or dedicated session from TTY: $LAUNCHER_BIN"
    if [[ "$APPLY_APP_THEMES" -eq 0 ]]; then
        log "  3. Optional: deploy styled app configs (with backup/restore):"
        log "     bash $TARGET_DIR/scripts/apply-themes.sh --dry-run"
    fi
fi
