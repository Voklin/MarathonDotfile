#!/usr/bin/env bash
# MARATHON Tactical — first-login onboarding (A12).
#  * Verifies the apps referenced by the profile ($terminal/$browser/...) exist.
#  * --session-file: OPT-IN. Generates a login-screen session entry into the
#    user's own staging dir and prints the manual sudo install + rollback
#    commands. This script never writes system paths, never touches the display
#    manager and never ends the current session.

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TARGET_DIR="${XDG_CONFIG_HOME}/marathon-tactical"
HYPR_CONF="${TARGET_DIR}/hypr/hyprland.conf"
STAGE_DIR="${XDG_DATA_HOME}/marathon-tactical"
SESSION_NAME="marathon-tactical.desktop"
SYS_SESSION_DIR="/usr/local/share/wayland-sessions"

mode="check"
case "${1:-}" in
    ""|--check) mode="check" ;;
    --session-file) mode="session" ;;
    --help|-h) echo "Usage: $0 [--check | --session-file]"; exit 0 ;;
    *) echo "ERROR: unknown option '$1'" >&2; exit 2 ;;
esac

conf_var() {
    # Reads `$name = value` from the isolated profile only.
    local name="$1"
    [[ -f "$HYPR_CONF" ]] || return 0
    sed -n "s/^\\\$${name}[[:space:]]*=[[:space:]]*\\([^#]*\\).*/\\1/p" -- "$HYPR_CONF" | head -n 1 | awk '{print $1}'
}

if [[ "$mode" == check ]]; then
    missing=0
    for var in terminal browser fileManager editor; do
        app="$(conf_var "$var")"
        if [[ -z "$app" ]]; then
            printf '  [ ?? ] $%-12s not set in %s\n' "$var" "$HYPR_CONF"
            continue
        fi
        if command -v -- "$app" >/dev/null 2>&1; then
            printf '  [ OK ] $%-12s %s\n' "$var" "$app"
        else
            printf '  [MISS] $%-12s %s  -> install it or edit %s\n' "$var" "$app" "$HYPR_CONF"
            missing=$((missing + 1))
        fi
    done
    for helper in nm-applet blueman-applet pavucontrol hyprlock; do
        if command -v -- "$helper" >/dev/null 2>&1; then printf '  [ OK ] helper %s\n' "$helper"
        else printf '  [MISS] helper %s (see scripts/packages-cachyos.txt)\n' "$helper"; missing=$((missing + 1)); fi
    done
    printf '\nMissing: %d. Nothing was installed or changed.\n' "$missing"
    exit 0
fi

# --session-file (opt-in): stage only.
LAUNCHER="$(command -v marathon-tactical-session 2>/dev/null || true)"
[[ -n "$LAUNCHER" ]] || LAUNCHER="$HOME/.local/bin/marathon-tactical-session"
mkdir -p -- "$STAGE_DIR"
cat > "${STAGE_DIR}/${SESSION_NAME}" <<EOF
[Desktop Entry]
Name=MARATHON Tactical (Hyprland)
Comment=Isolated MARATHON Tactical Hyprland profile
Exec=${LAUNCHER}
Type=Application
DesktopNames=Hyprland
EOF
cat <<EOF
Staged: ${STAGE_DIR}/${SESSION_NAME}
Review it, then install MANUALLY (your current session and DM config are untouched):
  sudo install -Dm644 '${STAGE_DIR}/${SESSION_NAME}' '${SYS_SESSION_DIR}/${SESSION_NAME}'
Rollback:
  sudo rm -f '${SYS_SESSION_DIR}/${SESSION_NAME}'
Whether your display manager reads ${SYS_SESSION_DIR} must be checked on the target system.
EOF
