#!/usr/bin/env bash
# MARATHON Tactical — Safe Isolated Uninstaller / Rollback Script
# Removes ONLY ~/.config/marathon-tactical/ and ~/.local/bin/marathon-tactical-session.

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET_DIR="${XDG_CONFIG_HOME}/marathon-tactical"
BACKUP_ROOT="${XDG_CONFIG_HOME}/marathon-tactical-backups"
LAUNCHER_BIN="${HOME}/.local/bin/marathon-tactical-session"

DRY_RUN=0
AUTO_YES=0
RESTORE_LATEST=0

usage() {
    cat <<'EOF'
MARATHON Tactical — Safe Uninstaller & Rollback

Usage:
  bash scripts/uninstall.sh [--dry-run] [--restore-backup] [--yes] [--help]

Options:
  --dry-run         Preview removals/restoration without modifying files.
  --restore-backup  Restore most recent backup from ~/.config/marathon-tactical-backups/ if available.
  --yes             Skip confirmation prompt.
  --help            Show help.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        --restore-backup) RESTORE_LATEST=1; shift ;;
        --yes|-y) AUTO_YES=1; shift ;;
        --help|-h) usage; exit 0 ;;
        *) echo "ERROR: Unknown option '$1'" >&2; exit 2 ;;
    esac
done

run_or_dry() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[DRY-RUN] %s\n' "$*"
    else
        "$@"
    fi
}

echo "[MARATHON] Target removal dir : $TARGET_DIR"
echo "[MARATHON] Session helper     : $LAUNCHER_BIN"
echo "[MARATHON] Note: ~/.config/hypr/ is never modified by MARATHON Tactical."

if [[ "$DRY_RUN" -eq 0 && "$AUTO_YES" -eq 0 ]]; then
    printf 'Remove MARATHON Tactical isolated profile? [y/N] '
    read -r reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        echo "[MARATHON] Cancelled. Nothing removed."
        exit 0
    fi
fi

if [[ -d "$TARGET_DIR" ]]; then
    run_or_dry rm -rf "${TARGET_DIR:?}"
else
    echo "[MARATHON] $TARGET_DIR already absent."
fi

if [[ -f "$LAUNCHER_BIN" ]]; then
    run_or_dry rm -f "$LAUNCHER_BIN"
fi

if [[ "$RESTORE_LATEST" -eq 1 && -d "$BACKUP_ROOT" ]]; then
    latest="$(ls -1dt "$BACKUP_ROOT"/* 2>/dev/null | head -n 1 || true)"
    if [[ -n "$latest" && -d "$latest" ]]; then
        echo "[MARATHON] Restoring backup: $latest -> $TARGET_DIR"
        run_or_dry cp -a "$latest" "$TARGET_DIR"
    else
        echo "[MARATHON] No backup archive found in $BACKUP_ROOT."
    fi
fi

echo "[MARATHON] Uninstall step finished cleanly."
if [[ -d "${XDG_CONFIG_HOME}/marathon-tactical-app-backups" ]]; then
    echo "[MARATHON] Optional app theme backups detected in ${XDG_CONFIG_HOME}/marathon-tactical-app-backups/"
    echo "           Run 'bash scripts/apply-themes.sh --restore' to restore pre-MARATHON app configs."
fi

