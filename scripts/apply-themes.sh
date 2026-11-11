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
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}-<unique-id>"

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

# Validate all targets BEFORE any mutation. Final file symlinks are supported;
# symlinked parent directories and directory-valued files are rejected.
validate_target() {
    local dest="$XDG_CONFIG_HOME/$1" parent
    parent="$(dirname "$dest")"
    [[ "$XDG_CONFIG_HOME" == /* && "$XDG_CONFIG_HOME" != / ]] || return 1
    [[ "$(readlink -m -- "$parent")" == "$parent" ]] || {
        log "ERROR: symlinked/non-normalized parent: $parent"; return 1;
    }
    [[ ! -d "$dest" || -L "$dest" ]] || {
        log "ERROR: refusing directory as config file: $dest"; return 1;
    }
}
allowed_path() {
    local entry
    for entry in "${LINKS[@]}" "${MANAGED_WRITES[@]}"; do
        [[ "${entry%%|*}" != "$1" ]] || return 0
    done
    return 1
}
for entry in "${LINKS[@]}" "${MANAGED_WRITES[@]}"; do
    validate_target "${entry%%|*}"
done
[[ ! -L "$BACKUP_ROOT" && "$(readlink -m -- "$BACKUP_ROOT")" == "$BACKUP_ROOT" ]] || {
    log 'ERROR: unsafe backup root'; exit 1;
}
if [[ "$DRY_RUN" -eq 0 ]]; then
    lock="$XDG_CONFIG_HOME/.marathon-themes.lock"
    mkdir -p "$XDG_CONFIG_HOME"
    mkdir "$lock" 2>/dev/null || { log "ERROR: another theme operation or stale lock: $lock"; exit 1; }
    trap 'rmdir -- "$lock"' EXIT
fi
if [[ "$RESTORE_MODE" -eq 1 ]]; then
    latest=''
    for candidate in "$BACKUP_ROOT"/*; do
        [[ -d "$candidate" && ! -L "$candidate" && -f "$candidate/.ready" && ! -e "$candidate/.restored" ]] || continue
        if [[ -z "$latest" || "$candidate" -nt "$latest" ]]; then latest="$candidate"; fi
    done
    [[ -n "$latest" && -f "$latest/manifest.txt" && ! -L "$latest/manifest.txt" ]] || {
        log 'ERROR: no pending valid theme backup'; exit 1;
    }
    # Validate the entire manifest and snapshot before restoring any file.
    while IFS='|' read -r status rel; do
        allowed_path "$rel" && validate_target "$rel" || { log 'ERROR: invalid manifest path'; exit 1; }
        case "$status" in
            EXISTED) [[ -e "$latest/files/$rel" || -L "$latest/files/$rel" ]] || exit 1 ;;
            CREATED) ;;
            *) log 'ERROR: invalid manifest status'; exit 1 ;;
        esac
    done < "$latest/manifest.txt"
    if [[ "$AUTO_YES" -eq 0 && "$DRY_RUN" -eq 0 ]]; then
        printf 'Restore app themes from %s? [y/N] ' "$latest"
        read -r reply || reply=''
        [[ "$reply" =~ ^[Yy]$ ]] || exit 0
    fi
    while IFS='|' read -r status rel; do
        dest="$XDG_CONFIG_HOME/$rel"
        if [[ "$DRY_RUN" -eq 1 ]]; then log "DRY-RUN restore $status $dest"; continue; fi
        if [[ "$status" == EXISTED ]]; then
            mkdir -p "$(dirname "$dest")"
            tmp="$(mktemp "$(dirname "$dest")/.marathon-restore.XXXXXXXX")"
            rm -f -- "$tmp"
            cp -a -- "$latest/files/$rel" "$tmp"
            mv -Tf -- "$tmp" "$dest"
        else
            rm -f -- "$dest"
        fi
    done < "$latest/manifest.txt"
    if [[ "$DRY_RUN" -eq 0 ]]; then : > "$latest/.restored"; fi
    log 'App theme restore complete; snapshot retained and marked restored.'
    exit 0
fi

log "Source app configs : $SOURCE_APPS"
log "Target config root : $XDG_CONFIG_HOME"
log "Backup destination : $BACKUP_DIR"

if [[ "$DRY_RUN" -eq 0 && "$AUTO_YES" -eq 0 ]]; then
    printf 'Deploy MARATHON app configs into %s (backing up existing files first)? [y/N] ' "$XDG_CONFIG_HOME"
    read -r reply || reply=''
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        log "Cancelled by user. Zero changes written."
        exit 0
    fi
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
    mkdir -p "$BACKUP_ROOT"
    BACKUP_DIR="$(mktemp -d "$BACKUP_ROOT/${TIMESTAMP}-XXXXXXXX")"
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

# Complete snapshot of every target before replacing the first one.
for entry in "${LINKS[@]}" "${MANAGED_WRITES[@]}"; do
    backup_target "${entry%%|*}"
done
if [[ "$DRY_RUN" -eq 0 ]]; then : > "$BACKUP_DIR/.ready"; fi

for entry in "${LINKS[@]}"; do
    rel="${entry%%|*}"
    src="${SOURCE_APPS}/${entry#*|}"
    dest="${XDG_CONFIG_HOME}/${rel}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[DRY-RUN] symlink %s -> %s\n' "$dest" "$src"
    else
        mkdir -p "$(dirname "$dest")"
        tmp="$(mktemp "$(dirname "$dest")/.marathon-link.XXXXXXXX")"
        rm -f -- "$tmp"
        ln -s -- "$src" "$tmp"
        mv -Tf -- "$tmp" "$dest"
    fi
done

for rel in "${MANAGED_WRITES[@]}"; do
    dest="${XDG_CONFIG_HOME}/${rel}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[DRY-RUN] write managed %s\n' "$dest"
    else
        mkdir -p "$(dirname "$dest")"
        tmp="$(mktemp "$(dirname "$dest")/.marathon-write.XXXXXXXX")"
        case "$rel" in
            gtk-3.0/gtk.css)
                cat > "$tmp" <<EOF
/* MARATHON Tactical — GTK 3.0 Managed Entrypoint (Live Synced Palette) */
@import "${SOURCE_APPS}/generated/gtk-colors.css";
@import "${SOURCE_APPS}/gtk-3.0/widgets.css";
EOF
                ;;
            gtk-4.0/gtk.css)
                cat > "$tmp" <<EOF
/* MARATHON Tactical — GTK 4.0 Managed Entrypoint (Live Synced Palette) */
@import "${SOURCE_APPS}/generated/gtk-colors.css";
@import "${SOURCE_APPS}/gtk-4.0/widgets.css";
EOF
                ;;
            qt6ct/qt6ct.conf)
                sed "s|~/.config/marathon-tactical/apps/generated/qt6ct-colors.conf|${SOURCE_APPS}/generated/qt6ct-colors.conf|g" \
                    "${SOURCE_APPS}/qt6ct/qt6ct.conf" > "$tmp"
                ;;
        esac
        mv -Tf -- "$tmp" "$dest"
    fi
done

if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN complete. No files modified."
else
    log "External app themes deployed. Revert anytime with: bash $0 --restore"
fi
