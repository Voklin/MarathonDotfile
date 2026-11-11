#!/usr/bin/env bash
# MARATHON Tactical — isolated Quickshell lifecycle helper.
# Starts / restarts / stops ONLY the MARATHON instance (tracked by pidfile and
# verified against its own config path). Never uses `pkill quickshell`, so other
# Quickshell profiles of the same user are untouched.
#
# Usage: shell-ctl.sh start|restart|stop|status|log

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/marathon-tactical"
SHELL_QML="${XDG_CONFIG_HOME}/marathon-tactical/shell/shell.qml"
PIDFILE="${RUNTIME_DIR}/quickshell.pid"
LOG_DIR="${XDG_STATE_HOME}/marathon-tactical"
LOG_FILE="${LOG_DIR}/quickshell.log"
MAX_LOG_BYTES=1048576

mkdir -p -- "$RUNTIME_DIR" "$LOG_DIR"
chmod 700 -- "$RUNTIME_DIR" 2>/dev/null || true

own_pid() {
    # Prints the pid only if it is alive AND its cmdline references our shell.qml.
    [[ -f "$PIDFILE" ]] || return 1
    local pid
    pid="$(head -c 16 -- "$PIDFILE" | tr -cd '0-9')"
    [[ -n "$pid" && -r "/proc/$pid/cmdline" ]] || return 1
    tr '\0' ' ' < "/proc/$pid/cmdline" | grep -qF -- "$SHELL_QML" || return 1
    printf '%s\n' "$pid"
}

rotate_log() {
    if [[ -f "$LOG_FILE" ]] && (( $(stat -c %s -- "$LOG_FILE") > MAX_LOG_BYTES )); then
        mv -f -- "$LOG_FILE" "${LOG_FILE}.1"
    fi
}

do_start() {
    if own_pid >/dev/null; then echo "already running (pid $(own_pid))"; return 0; fi
    command -v quickshell >/dev/null 2>&1 || { echo "ERROR: quickshell not installed" >&2; return 1; }
    [[ -f "$SHELL_QML" ]] || { echo "ERROR: missing $SHELL_QML" >&2; return 1; }
    rotate_log
    printf '=== start %s ===\n' "$(date -Is)" >> "$LOG_FILE"
    nohup quickshell -p "$SHELL_QML" >> "$LOG_FILE" 2>&1 &
    printf '%s\n' "$!" > "$PIDFILE"
    echo "started (pid $!) log: $LOG_FILE"
}

do_stop() {
    local pid
    if ! pid="$(own_pid)"; then rm -f -- "$PIDFILE"; echo "not running"; return 0; fi
    kill -TERM -- "$pid" 2>/dev/null || true
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        kill -0 -- "$pid" 2>/dev/null || break
        sleep 0.2
    done
    if kill -0 -- "$pid" 2>/dev/null; then kill -KILL -- "$pid" 2>/dev/null || true; fi
    rm -f -- "$PIDFILE"
    echo "stopped (pid $pid)"
}

case "${1:-}" in
    start) do_start ;;
    stop) do_stop ;;
    restart) do_stop; do_start ;;
    status) if pid="$(own_pid)"; then echo "running (pid $pid)"; else echo "not running"; exit 3; fi ;;
    log) tail -n 200 -- "$LOG_FILE" 2>/dev/null || echo "no log yet: $LOG_FILE" ;;
    *) echo "Usage: $0 start|restart|stop|status|log" >&2; exit 2 ;;
esac
