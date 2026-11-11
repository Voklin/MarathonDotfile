#!/usr/bin/env bash
# MARATHON Tactical — Safe Isolated Installer for CachyOS / Arch Linux
# Installs cleanly into ~/.config/marathon-tactical/ without overwriting ~/.config/hypr/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET_DIR="${XDG_CONFIG_HOME}/marathon-tactical"
BIN_DIR="${HOME}/.local/bin"
LAUNCHER_BIN="${BIN_DIR}/marathon-tactical-session"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${XDG_CONFIG_HOME}/marathon-tactical-backups/${TIMESTAMP}"

DRY_RUN=0
AUTO_YES=0
APPLY_APP_THEMES=0

usage() {
    cat <<'EOF'
MARATHON Tactical — Isolated Profile Installer (CachyOS / Hyprland + Quickshell)

Usage:
  bash scripts/install.sh [--dry-run] [--apply-app-themes] [--yes] [--help]

Options:
  --dry-run           Print planned operations and dependency status without writing any files.
  --apply-app-themes  Also deploy styled app configs (~/.config/ghostty, kitty, btop, yazi, gtk, qt6ct, mpv, imv, zathura, starship, fastfetch) with automatic backup.
  --yes               Skip interactive confirmation prompt (still never overwrites ~/.config/hypr/).
  --help              Show this help message.

Safety Guarantees:
  - Installs ONLY into ~/.config/marathon-tactical/ and ~/.local/bin/marathon-tactical-session
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

if command -v Hyprland >/dev/null 2>&1; then
    hypr_ver="$(Hyprland --version 2>/dev/null | head -n 1 || true)"
    log "Detected compositor: ${hypr_ver:-unknown}"
    if [[ "$hypr_ver" =~ 0\.([0-9]+) ]]; then
        minor="${BASH_REMATCH[1]}"
        if (( minor >= 55 )); then
            log "WARNING: Hyprland 0.55+ detected. Legacy hyprlang compatibility is transitional; test config parsing before daily use."
        fi
    fi
fi

if [[ "$DRY_RUN" -eq 0 && "$AUTO_YES" -eq 0 ]]; then
    printf '\nProceed with isolated installation into %s? [y/N] ' "$TARGET_DIR"
    read -r reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        log "Installation cancelled by user. Zero changes applied."
        exit 0
    fi
fi

if [[ -d "$TARGET_DIR" ]]; then
    log "Backing up previous isolated installation to $BACKUP_DIR"
    run_or_dry mkdir -p "$(dirname "$BACKUP_DIR")"
    run_or_dry cp -a "$TARGET_DIR" "$BACKUP_DIR"
fi

run_or_dry mkdir -p "$TARGET_DIR" "$BIN_DIR"
for d in ui shell hypr design apps scripts; do
    run_or_dry rm -rf "${TARGET_DIR:?}/$d"
    run_or_dry cp -a "$REPO_ROOT/$d" "$TARGET_DIR/$d"
done
if [[ "$DRY_RUN" -eq 0 && -d "$TARGET_DIR/scripts" ]]; then
    chmod 0755 "$TARGET_DIR"/scripts/*.sh 2>/dev/null || true
fi
if [[ -f "$BACKUP_DIR/hypr/user-settings.conf" ]]; then
    log "Preserving existing isolated user-settings.conf overrides"
    run_or_dry cp -a "$BACKUP_DIR/hypr/user-settings.conf" "$TARGET_DIR/hypr/user-settings.conf"
fi
if [[ -f "$BACKUP_DIR/settings.json" ]]; then
    log "Preserving existing isolated settings.json"
    run_or_dry cp -a "$BACKUP_DIR/settings.json" "$TARGET_DIR/settings.json"
fi
if [[ -f "$BACKUP_DIR/scratchpad.txt" ]]; then
    log "Preserving existing isolated scratchpad.txt"
    run_or_dry cp -a "$BACKUP_DIR/scratchpad.txt" "$TARGET_DIR/scratchpad.txt"
fi
if [[ -d "$BACKUP_DIR/apps/generated" ]]; then
    log "Preserving dynamically synced apps/generated/ palettes"
    run_or_dry cp -a "$BACKUP_DIR/apps/generated/." "$TARGET_DIR/apps/generated/"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[DRY-RUN] Write session launcher helper: %s\n' "$LAUNCHER_BIN"
else
    cat > "$LAUNCHER_BIN" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec Hyprland --config "$TARGET_DIR/hypr/hyprland.conf" "\$@"
EOF
    chmod 0755 "$LAUNCHER_BIN"
fi

if [[ "$APPLY_APP_THEMES" -eq 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
        bash "$REPO_ROOT/scripts/apply-themes.sh" --dry-run
    else
        bash "$TARGET_DIR/scripts/apply-themes.sh" --yes
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

