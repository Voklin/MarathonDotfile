#!/usr/bin/env bash
# MARATHON Tactical — Read-Only CachyOS Environment & Safety Diagnostics

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET_DIR="${XDG_CONFIG_HOME}/marathon-tactical"

printf '====================================================================\n'
printf 'MARATHON Tactical // CachyOS & Wayland Diagnostics (read-only)\n'
printf '====================================================================\n'

printf '\n[1] OS & Runtime Environment\n'
if [[ -f /etc/os-release ]]; then
    grep -E '^(NAME|PRETTY_NAME|VERSION_ID)=' /etc/os-release || true
else
    uname -a
fi
printf '  XDG_SESSION_TYPE=%s\n' "${XDG_SESSION_TYPE:-unset}"
printf '  WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-unset}"
printf '  HYPRLAND_INSTANCE_SIGNATURE=%s\n' "${HYPRLAND_INSTANCE_SIGNATURE:-unset}"

printf '\n[2] Remote Access Preservation (sshd)\n'
if command -v systemctl >/dev/null 2>&1; then
    printf '  sshd: %s\n' "$(systemctl is-active sshd 2>/dev/null || echo inactive/unknown)"
else
    printf '  systemctl not available\n'
fi

printf '\n[3] Required & Optional Binaries\n'
for cmd in Hyprland hyprctl quickshell qs hyprlock hypridle hyprpicker hyprsunset wpctl pactl brightnessctl nmcli bluetoothctl upower busctl notify-send grim slurp satty cliphist wl-copy wl-paste ghostty kitty alacritty btop yazi starship fastfetch mpv imv zathura qt6ct python3; do
    if command -v "$cmd" >/dev/null 2>&1; then
        ver="$("$cmd" --version 2>/dev/null | head -n 1 || echo "installed")"
        printf '  [OK]   %-14s %s\n' "$cmd" "$ver"
    else
        printf '  [MISS] %-14s not in PATH\n' "$cmd"
    fi
done

printf '\n[4] Notification Daemon Conflict Check (org.freedesktop.Notifications)\n'
if command -v busctl >/dev/null 2>&1; then
    owner="$(busctl --user get-name-owner org.freedesktop.Notifications 2>/dev/null || true)"
    if [[ -n "$owner" ]]; then
        printf '  [WARN] org.freedesktop.Notifications already owned by: %s\n' "$owner"
        printf '         MARATHON NotificationsAdapter will disable NotificationServer instead of fighting.\n'
    else
        printf '  [OK]   org.freedesktop.Notifications is unowned -> ready for MARATHON NotificationServer.\n'
    fi
fi

printf '\n[5] Verified Open-Source Fonts\n'
if command -v fc-list >/dev/null 2>&1; then
    for fam in "JetBrains Mono" "Space Grotesk" "Inter" "IBM Plex Mono"; do
        count="$(fc-list ":family=${fam}" file 2>/dev/null | wc -l || echo 0)"
        printf '  %-16s matched font files: %s\n' "$fam" "$count"
    done
fi

printf '\n[6] Profile Isolation Status\n'
printf '  Repo path            : %s\n' "$REPO_ROOT"
printf '  Isolated install dir : %s (%s)\n' "$TARGET_DIR" "$([[ -d "$TARGET_DIR" ]] && echo present || echo not installed)"
printf '  User ~/.config/hypr  : %s\n' "$([[ -d "$XDG_CONFIG_HOME/hypr" ]] && echo untouched/present || echo absent)"

printf '\n[7] Repository Static & Test Checks\n'
if command -v python3 >/dev/null 2>&1; then
    (cd "$REPO_ROOT" && python3 scripts/check_qml.py)
    (cd "$REPO_ROOT" && python3 tests/test_contracts_and_assets.py)
else
    echo "  python3 not installed"
fi

