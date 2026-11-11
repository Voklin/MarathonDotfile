#!/usr/bin/env bash
# Shared path guards and session helper for the isolated profile.
set -euo pipefail

profile_paths() {
    : "${HOME:?HOME must be set}"
    XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
    [[ "$HOME" == /* && "$XDG_CONFIG_HOME" == /* ]] || {
        echo 'ERROR: HOME and XDG_CONFIG_HOME must be absolute paths.' >&2
        return 1
    }
    XDG_CONFIG_HOME="${XDG_CONFIG_HOME%/}"
    [[ -n "$XDG_CONFIG_HOME" && "$HOME" != / ]] || return 1
    TARGET_DIR="$XDG_CONFIG_HOME/marathon-tactical"
    BACKUP_ROOT="$XDG_CONFIG_HOME/marathon-tactical-backups"
    BIN_DIR="$HOME/.local/bin"
    LAUNCHER_BIN="$BIN_DIR/marathon-tactical-session"
    local path
    for path in "$TARGET_DIR" "$BACKUP_ROOT" "$LAUNCHER_BIN"; do
        [[ ! -L "$path" && "$(readlink -m -- "$path")" == "$path" ]] || {
            printf 'ERROR: Refusing symlinked or non-normalized destination: %s\n' "$path" >&2
            return 1
        }
    done
    [[ ! -e "$TARGET_DIR" || -d "$TARGET_DIR" ]] || {
        echo 'ERROR: Profile destination is not a directory.' >&2
        return 1
    }
    [[ ! -e "$LAUNCHER_BIN" || -f "$LAUNCHER_BIN" ]] || {
        echo 'ERROR: Session helper destination is not a regular file.' >&2
        return 1
    }
}

write_session_helper() {
    local output="$1"
    [[ ! -L "$output" ]] || {
        echo 'ERROR: Refusing symlinked session helper.' >&2
        return 1
    }
    {
        printf '#!/usr/bin/env bash\nset -euo pipefail\n'
        printf 'exec Hyprland --config %q "$@"\n' "$TARGET_DIR/hypr/hyprland.conf"
    } > "$output"
    chmod 0755 "$output"
}

latest_profile_backup() {
    local candidate latest=''
    [[ -d "$BACKUP_ROOT" ]] || return 1
    for candidate in "$BACKUP_ROOT"/*; do
        [[ -d "$candidate" && ! -L "$candidate" ]] || continue
        [[ -f "$candidate/hypr/hyprland.conf" && -f "$candidate/shell/shell.qml" ]] || continue
        if [[ -z "$latest" || "$candidate" -nt "$latest" ]]; then
            latest="$candidate"
        fi
    done
    [[ -n "$latest" ]] || return 1
    printf '%s\n' "$latest"
}
