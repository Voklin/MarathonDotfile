#!/usr/bin/env bash
# MARATHON Tactical — Explicit Opt-In External App Theme Deployer & Restorer
# Safely deploys redesigned MARATHON configs into ~/.config/* WITH automatic backup
# to ~/.config/marathon-tactical-app-backups/<timestamp>/ and full --restore support.
# Never modifies ~/.config/hypr/, ~/.config/quickshell/, display managers, or sshd.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET_DIR="${XDG_CONFIG_HOME}/marathon-tactical"
BACKUP_ROOT="${XDG_CONFIG_HOME}/marathon-tactical-app-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

if [[ -d "${TARGET_DIR}/apps" ]]; then
    SOURCE_APPS="${TARGET_DIR}/apps"
else
    SOURCE_APPS="${REPO_ROOT}/apps"
fi

DRY_RUN=0
AUTO_YES=0
RESTORE_MODE=0

usage() {
    cat <<'EOF'
MARATHON Tactical — External App Theme Deployer (Opt-In)

Usage:
  bash scripts/apply-themes.sh [--dry-run] [--yes] [--restore] [--help]

Options:
  --dry-run   Show planned backups, symlinks, and config writes without modifying files.
  --yes       Skip confirmation prompt.
  --restore   Restore the latest backup from ~/.config/marathon-tactical-app-backups/.
  --help      Show this help text.

Covered apps:
  ghostty, kitty, alacritty, foot, btop, yazi, starship, fastfetch,
  gtk-3.0, gtk-4.0, qt6ct, mpv, imv, zathura.
  (~/.config/hypr/ and ~/.config/quickshell/ are NEVER modified.)
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        --yes|-y) AUTO_YES=1; shift ;;
        --restore) RESTORE_MODE=1; shift ;;
        --help|-h) usage; exit 0 ;;
        *) echo "ERROR: Unknown option '$1'" >&2; usage >&2; exit 2 ;;
    esac
done

log() {
    printf '[MARATHON-APPS] %s\n' "$*"
}

if [[ ! -d "$SOURCE_APPS" ]]; then
    echo "ERROR: App configs directory not found: $SOURCE_APPS" >&2
    exit 1
fi

restore_latest() {
    if [[ ! -d "$BACKUP_ROOT" ]]; then
        log "No app backup directory found at $BACKUP_ROOT."
        exit 1
    fi
    local latest
    latest="$(ls -1dt "$BACKUP_ROOT"/* 2>/dev/null | head -n 1 || true)"
    if [[ -z "$latest" || ! -f "$latest/manifest.txt" ]]; then
        log "No valid backup manifest found in $BACKUP_ROOT."
        exit 1
    fi
    log "Restoring from backup: $latest"
    while IFS='|' read -r status rel_path; do
        [[ -z "$status" || -z "$rel_path" ]] && continue
        local dest="${XDG_CONFIG_HOME}/${rel_path}"
        if [[ "$status" == "EXISTED" ]]; then
            local src="${latest}/files/${rel_path}"
            if [[ "$DRY_RUN" -eq 1 ]]; then
                printf '[DRY-RUN] restore %s -> %s\n' "$src" "$dest"
            else
                mkdir -p "$(dirname "$dest")"
                rm -rf "$dest"
                cp -a "$src" "$dest"
            fi
        elif [[ "$status" == "CREATED" ]]; then
            if [[ "$DRY_RUN" -eq 1 ]]; then
                printf '[DRY-RUN] remove MARATHON-created %s\n' "$dest"
            else
                rm -f "$dest"
            fi
        fi
    done < "$latest/manifest.txt"
    log "App theme restore complete."
    exit 0
}

if [[ "$RESTORE_MODE" -eq 1 ]]; then
    restore_latest
fi

# Relative path under XDG_CONFIG_HOME | Source file inside $SOURCE_APPS
LINKS=(
    "ghostty/config|ghostty/config"
    "kitty/kitty.conf|kitty/kitty.conf"
    "alacritty/alacritty.toml|alacritty/alacritty.toml"
    "foot/foot.ini|foot/foot.ini"
    "btop/btop.conf|btop/btop.conf"
    "yazi/yazi.toml|yazi/yazi.toml"
    "yazi/theme.toml|generated/yazi-colors.toml"
    "starship.toml|starship/starship.toml"
    "fastfetch/config.jsonc|fastfetch/config.jsonc"
    "gtk-3.0/settings.ini|gtk-3.0/settings.ini"
    "gtk-4.0/settings.ini|gtk-4.0/settings.ini"
    "qt6ct/colors/marathon-tactical.conf|generated/qt6ct-colors.conf"
    "mpv/mpv.conf|mpv/mpv.conf"
    "mpv/input.conf|mpv/input.conf"
    "imv/config|imv/config"
    "zathura/zathurarc|zathura/zathurarc"
)

MANAGED_WRITES=(
    "gtk-3.0/gtk.css"
    "gtk-4.0/gtk.css"
    "qt6ct/qt6ct.conf"
)

log "Source app configs : $SOURCE_APPS"
log "Target config root : $XDG_CONFIG_HOME"
log "Backup destination : $BACKUP_DIR"

if [[ "$DRY_RUN" -eq 0 && "$AUTO_YES" -eq 0 ]]; then
    printf 'Deploy MARATHON app configs into %s (backing up existing files first)? [y/N] ' "$XDG_CONFIG_HOME"
    read -r reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        log "Cancelled by user. Zero changes written."
        exit 0
    fi
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
    mkdir -p "${BACKUP_DIR}/files"
    : > "${BACKUP_DIR}/manifest.txt"
fi

backup_target() {
    local rel="$1"
    local dest="${XDG_CONFIG_HOME}/${rel}"
    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            printf '[DRY-RUN] backup %s -> %s/files/%s\n' "$dest" "$BACKUP_DIR" "$rel"
        else
            mkdir -p "$(dirname "${BACKUP_DIR}/files/${rel}")"
            cp -a "$dest" "${BACKUP_DIR}/files/${rel}"
            printf 'EXISTED|%s\n' "$rel" >> "${BACKUP_DIR}/manifest.txt"
        fi
    else
        if [[ "$DRY_RUN" -eq 0 ]]; then
            printf 'CREATED|%s\n' "$rel" >> "${BACKUP_DIR}/manifest.txt"
        fi
    fi
}

for entry in "${LINKS[@]}"; do
    rel="${entry%%|*}"
    src="${SOURCE_APPS}/${entry#*|}"
    dest="${XDG_CONFIG_HOME}/${rel}"
    backup_target "$rel"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[DRY-RUN] symlink %s -> %s\n' "$dest" "$src"
    else
        mkdir -p "$(dirname "$dest")"
        ln -sfn "$src" "$dest"
    fi
done

for rel in "${MANAGED_WRITES[@]}"; do
    backup_target "$rel"
    dest="${XDG_CONFIG_HOME}/${rel}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[DRY-RUN] write managed %s\n' "$dest"
    else
        mkdir -p "$(dirname "$dest")"
        case "$rel" in
            gtk-3.0/gtk.css)
                cat > "$dest" <<EOF
/* MARATHON Tactical — GTK 3.0 Managed Entrypoint (Live Synced Palette) */
@import "${SOURCE_APPS}/generated/gtk-colors.css";
@import "${SOURCE_APPS}/gtk-3.0/widgets.css";
EOF
                ;;
            gtk-4.0/gtk.css)
                cat > "$dest" <<EOF
/* MARATHON Tactical — GTK 4.0 Managed Entrypoint (Live Synced Palette) */
@import "${SOURCE_APPS}/generated/gtk-colors.css";
@import "${SOURCE_APPS}/gtk-4.0/widgets.css";
EOF
                ;;
            qt6ct/qt6ct.conf)
                sed "s|~/.config/marathon-tactical/apps/generated/qt6ct-colors.conf|${SOURCE_APPS}/generated/qt6ct-colors.conf|g" \
                    "${SOURCE_APPS}/qt6ct/qt6ct.conf" > "$dest"
                ;;
        esac
    fi
done

if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN complete. No files modified."
else
    log "External app themes deployed. Revert anytime with: bash $0 --restore"
fi
