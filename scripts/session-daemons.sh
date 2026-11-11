#!/usr/bin/env bash
# MARATHON Tactical — Safe Wayland Session Helper Daemons
# Launches clipboard watcher, hypridle (isolated config), and polkit agent ONLY if
# installed and not already running. Never touches ~/.config/hypr/.

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET_DIR="${XDG_CONFIG_HOME}/marathon-tactical"
HYPRIDLE_CONF="${TARGET_DIR}/hypr/hypridle.conf"

start_detached() {
    nohup "$@" >/dev/null 2>&1 &
}

# 1. Clipboard watchers (text + image -> cliphist)
if command -v wl-paste >/dev/null 2>&1 && command -v cliphist >/dev/null 2>&1; then
    if ! pgrep -u "$UID" -f "wl-paste --type text --watch cliphist store" >/dev/null 2>&1; then
        start_detached wl-paste --type text --watch cliphist store
    fi
    if ! pgrep -u "$UID" -f "wl-paste --type image --watch cliphist store" >/dev/null 2>&1; then
        start_detached wl-paste --type image --watch cliphist store
    fi
fi

# 2. Idle lock / DPMS daemon using isolated profile config
if command -v hypridle >/dev/null 2>&1 && [[ -f "$HYPRIDLE_CONF" ]]; then
    if ! pgrep -u "$UID" -x hypridle >/dev/null 2>&1; then
        start_detached hypridle -c "$HYPRIDLE_CONF"
    fi
fi

# 3. Polkit authentication agent (first installed candidate if none active)
if ! pgrep -u "$UID" -f "polkit-.*-authentication-agent" >/dev/null 2>&1; then
    for agent in \
        "/usr/lib/polkit-kde-authentication-agent-1" \
        "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1" \
        "/usr/libexec/polkit-gnome-authentication-agent-1" \
        "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"; do
        if [[ -x "$agent" ]]; then
            start_detached "$agent"
            break
        fi
    done
fi
