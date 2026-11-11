# Hyprland Diagnostics & Syntax Compatibility Reference

Verify exact syntax against the installed CachyOS version (`hyprctl version`) and `https://wiki.hypr.land/`.

## 1. Version & Format Check Commands (CachyOS)

```bash
hyprctl version
Hyprland --version
ls -la ~/.config/hypr/
systemctl is-active sshd
```

- **Legacy / `hyprlang` (`hyprland.conf`)**: Uses `keyword = value`, category blocks (`general { ... }`), `windowrulev2 = ...` (or unified `windowrule` in newer pre-Lua releases; check `hyprctl` warnings/wiki for exact release).
- **Lua (`hyprland.lua`)**: Newer Hyprland transitions (`v0.55+`+) support Lua tables/API (`hl.window_rule(...)`, `hl.dispatch(...)`). Do NOT emit Lua syntax on a `hyprlang`-only build or vice versa without checking `hyprctl version`.
- **Isolated launch**: Prefer passing explicit `-c /path/to/marathon-hypr.conf` (or verified Lua entrypoint flag) in an opt-in launcher script rather than replacing `~/.config/hypr/hyprland.conf`.

## 2. Four-Layer Diagnostic Algorithm

When a MARATHON Tactical session fails to start or misbehaves on CachyOS, isolate the failing layer in order before editing files:

| Layer | Symptom Signals | Diagnostic Probes | Corrective Path |
|---|---|---|---|
| **A. Hyprland Config Syntax** | Immediate exit, yellow/red config error banner, invalid keyword/windowrule warnings | Run config check / launch debug log (`Hyprland -c <profile>` from TTY or inspect `$XDG_RUNTIME_DIR/hypr/*/hyprland.log`) | Fix syntax for detected Hyprland version; revert to known-good profile if needed. |
| **B. GPU / DRM / Driver** | Black screen, atomic modesetting errors, tearing/flicker, hybrid-GPU failure (`amdgpu` / `nvidia` / `intel`) | Check `lspci -k \| grep -EA3 'VGA\|3D'`, `journalctl -b -p err`, DRM connectors in `/sys/class/drm/*/status` | Verify kernel modesetting / vendor Wayland env vars without stripping existing drivers. |
| **C. Wayland / Portal / DM** | Login loop in SDDM/GDM/Greetd, missing screen sharing, XWayland apps failing | Check `XDG_SESSION_TYPE`, `WAYLAND_DISPLAY`, `systemctl --user status xdg-desktop-portal-hyprland`, DM logs | Fix portal/environment handoff; keep original DM session untouched as fallback. |
| **D. Quickshell Startup / IPC** | Hyprland compositor runs and keybinds work, but Top HUD/Launcher/Notifications are missing | Check `pgrep -a quickshell`, run `quickshell -p <entry>` in terminal/log, verify `HYPRLAND_INSTANCE_SIGNATURE` and D-Bus `org.freedesktop.Notifications` owner | Fix QML import/runtime error or stop conflicting notification daemon in the isolated session only. |

## 3. Emergency Recovery Checklist

1. Switch to TTY (`Ctrl+Alt+F3`), log in, or connect via SSH.
2. Verify existing `~/.config/hypr/` is untouched (or restore from timestamped backup directory).
3. Kill only the isolated test process if frozen (`pkill -x Hyprland` only if explicitly authorized for that test TTY), then select the original session at the display manager.

