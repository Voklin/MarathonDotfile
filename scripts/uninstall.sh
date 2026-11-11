#!/usr/bin/env bash
# MARATHON Tactical — Safe Isolated Uninstaller / Rollback Script
# Removes ONLY ~/.config/marathon-tactical/ and ~/.local/bin/marathon-tactical-session.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/profile-common.sh"

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

profile_paths

# Validate recovery before removing anything, including in noninteractive mode.
latest=''
if [[ "$RESTORE_LATEST" -eq 1 ]]; then
    latest="$(latest_profile_backup)" || {
        echo "ERROR: No valid profile backup found in $BACKUP_ROOT. Nothing removed." >&2
        exit 1
    }
fi

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
    read -r reply || reply=''
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        echo "[MARATHON] Cancelled. Nothing removed."
        exit 0
    fi
fi

if [[ "$RESTORE_LATEST" -eq 1 ]]; then
    echo "[MARATHON] Restore $latest -> $TARGET_DIR (current profile will be backed up)"
    if [[ "$DRY_RUN" -eq 0 ]]; then
        stage="$(mktemp -d "$XDG_CONFIG_HOME/.marathon-stage.XXXXXXXX")"
        saved=''
        cleanup() {
            local status=$?
            trap - EXIT
            [[ ! -d "$stage" ]] || rm -rf -- "${stage:?}"
            if [[ ! -e "$TARGET_DIR" && -n "$saved" ]]; then
                mv -- "$saved" "$TARGET_DIR"
            fi
            exit "$status"
        }
        trap cleanup EXIT
        trap 'exit 130' INT
        trap 'exit 143' TERM
        cp -a -- "$latest/." "$stage/"
        write_session_helper "$stage/.session-helper"
        mkdir -p "$BIN_DIR"
        if [[ -d "$TARGET_DIR" ]]; then
            saved="$(mktemp -d "$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)-XXXXXXXX")"
            rmdir -- "$saved"
            mv -- "$TARGET_DIR" "$saved"
            echo "[MARATHON] Current profile saved: $saved"
        fi
        mv -- "$stage" "$TARGET_DIR"
        mv -f -- "$TARGET_DIR/.session-helper" "$LAUNCHER_BIN"
    fi
else
    if [[ -d "$TARGET_DIR" ]]; then
        run_or_dry rm -rf -- "${TARGET_DIR:?}"
    fi
    if [[ -f "$LAUNCHER_BIN" ]]; then
        run_or_dry rm -f -- "$LAUNCHER_BIN"
    fi
fi

echo "[MARATHON] Uninstall step finished cleanly."
if [[ -d "${XDG_CONFIG_HOME}/marathon-tactical-app-backups" ]]; then
    echo "[MARATHON] Optional app theme backups detected in ${XDG_CONFIG_HOME}/marathon-tactical-app-backups/"
    echo "           Run 'bash scripts/apply-themes.sh --restore' to restore pre-MARATHON app configs."
fi

