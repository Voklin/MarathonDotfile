#!/usr/bin/env bash
# Shared path guards, dependency installer, and session helper for the isolated profile.
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
        printf 'exec Hyprland --config %q "$@"\n' "$TARGET_DIR/hypr/hyprland.lua"
    } > "$output"
    chmod 0755 "$output"
}

latest_profile_backup() {
    local candidate latest=''
    [[ -d "$BACKUP_ROOT" ]] || return 1
    for candidate in "$BACKUP_ROOT"/*; do
        [[ -d "$candidate" && ! -L "$candidate" ]] || continue
        [[ ( -f "$candidate/hypr/hyprland.lua" || -f "$candidate/hypr/hyprland.conf" ) && -f "$candidate/shell/shell.qml" ]] || continue
        if [[ -z "$latest" || "$candidate" -nt "$latest" ]]; then
            latest="$candidate"
        fi
    done
    [[ -n "$latest" ]] || return 1
    printf '%s\n' "$latest"
}

read_package_manifest() {
    local manifest="$1"
    [[ -f "$manifest" ]] || return 1
    grep -vE '^[[:space:]]*(#|$)' -- "$manifest" | awk '{print $1}'
}

package_installed() {
    local pkg="$1"
    if [[ "$pkg" == "quickshell" ]]; then
        pacman -Qi quickshell >/dev/null 2>&1 || pacman -Qi quickshell-git >/dev/null 2>&1 || command -v quickshell >/dev/null 2>&1
        return $?
    fi
    pacman -Qi -- "$pkg" >/dev/null 2>&1
}

install_missing_dependencies() {
    local manifest="$1"
    local dry_run="${2:-0}"
    if [[ ! -f "$manifest" ]]; then
        printf '[MARATHON] ERROR: Package manifest not found: %s\n' "$manifest" >&2
        return 1
    fi
    if ! command -v pacman >/dev/null 2>&1; then
        printf '[MARATHON] pacman not found in PATH; skipping automatic package installation.\n'
        return 0
    fi

    local pkg
    local -a missing_pkgs=()
    while IFS= read -r pkg; do
        [[ -n "$pkg" ]] || continue
        if ! package_installed "$pkg"; then
            missing_pkgs+=("$pkg")
        fi
    done < <(read_package_manifest "$manifest")

    if [[ "${#missing_pkgs[@]}" -eq 0 ]]; then
        printf '[MARATHON] All dependencies from %s are already installed.\n' "$manifest"
        return 0
    fi

    printf '[MARATHON] Missing dependencies (%d): %s\n' "${#missing_pkgs[@]}" "${missing_pkgs[*]}"

    local -a repo_pkgs=()
    local -a aur_pkgs=()
    for pkg in "${missing_pkgs[@]}"; do
        if pacman -Si -- "$pkg" >/dev/null 2>&1; then
            repo_pkgs+=("$pkg")
        else
            aur_pkgs+=("$pkg")
        fi
    done

    if [[ "${#repo_pkgs[@]}" -gt 0 ]]; then
        if [[ "$dry_run" -eq 1 ]]; then
            printf '[DRY-RUN] sudo pacman -S --needed --noconfirm -- %s\n' "${repo_pkgs[*]}"
        else
            printf '[MARATHON] Downloading and installing repository packages (%d)...\n' "${#repo_pkgs[@]}"
            sudo pacman -S --needed --noconfirm -- "${repo_pkgs[@]}"
        fi
    fi

    if [[ "${#aur_pkgs[@]}" -gt 0 ]]; then
        local aur_helper=""
        if command -v paru >/dev/null 2>&1; then
            aur_helper="paru"
        elif command -v yay >/dev/null 2>&1; then
            aur_helper="yay"
        fi

        if [[ -n "$aur_helper" ]]; then
            if [[ "$dry_run" -eq 1 ]]; then
                printf '[DRY-RUN] %s -S --needed --noconfirm -- %s\n' "$aur_helper" "${aur_pkgs[*]}"
            else
                printf '[MARATHON] Downloading and installing AUR packages via %s (%d)...\n' "$aur_helper" "${#aur_pkgs[@]}"
                "$aur_helper" -S --needed --noconfirm -- "${aur_pkgs[@]}"
            fi
        else
            printf '[MARATHON] WARNING: AUR helper (paru/yay) not found for packages: %s\n' "${aur_pkgs[*]}" >&2
        fi
    fi
}
