---
name: hyprland-expert
description: >-
  Configure, isolate, and troubleshoot Hyprland on CachyOS/Arch Linux for
  MARATHON Tactical (version/syntax detection including hyprlang and
  hyprland.lua, monitors, window rules, workspaces, tiling/floating, animations,
  keybindings, IPC, safe isolated profiles, backups, rollback, and startup
  diagnostics). Do not use for QML component layout (quickshell-expert).
---

# Hyprland Configuration & Diagnostics Expert (CachyOS)

## Purpose and Activation

Use this skill when designing, auditing, or troubleshooting `hypr/` profile configs, isolated Hyprland session startup, monitor/workspace/window rules, keybindings (`docs/KEYBINDINGS.md`), or session recovery on CachyOS/Arch Linux.

Read [diagnostics-and-syntax.md](./references/diagnostics-and-syntax.md) when diagnosing startup failures or checking `hyprlang` vs `hyprland.lua` syntax differences.

## Step-by-Step Workflow

1. **Detect installed environment before editing**:
   - Inspect installed Hyprland version (`hyprctl version` / `Hyprland --version`), display manager (`systemctl status` / running DM), GPU/DRM drivers, and active session type.
   - Verify syntax compatibility against `https://wiki.hypr.land/` for that exact version — never assume `hyprland.conf` (`hyprlang`) vs `hyprland.lua` or `windowrule` vs `windowrulev2`.
2. **Design isolated profile configuration**:
   - Store project configs in dedicated repository paths (`hypr/`) and isolated target directories/filenames rather than overwriting `~/.config/hypr/`.
   - Define `monitor`, workspaces, tiling/floating rules, keybindings, reduced-motion animation toggle, and controlled `exec-once` launch for Quickshell (`quickshell -p ...`).
3. **Plan backup and recovery first**:
   - Back up ONLY files explicitly targeted by an opt-in install script.
   - Keep the previous user session selectable in the display manager, keep TTY switching (`Ctrl+Alt+F2..F6`) working, and document an exact one-command rollback.
4. **Preserve remote access**:
   - Verify SSH (`sshd`) and remote desktop/VPN services remain untouched and active. Never test by killing the active remote GUI session.
5. **Validate safely**:
   - Check config parsing/dry-run where supported; test in an isolated session or separate profile only with explicit user approval.

## Strict Safety Rules & Prohibitions

1. **Never overwrite a working `~/.config/hypr/` configuration** without explicit user permission.
2. **Never terminate or restart the active GUI user session** (risk of severing remote access or losing unsaved work).
3. **Never alter or replace the display manager** or `/usr/share/wayland-sessions/` without explicit user approval and documented removal steps.
4. **Never disable SSH, firewall ports, or remote access services** (`sshd`, VNC/RDP, Tailscale).
5. **Always define a verified recovery path** (TTY access, backup restore, revert command) before applying system changes.
6. **Never assume configuration format** (`hyprland.conf` vs `hyprland.lua`, `windowrule` syntax) without first verifying the installed Hyprland version.
7. **Never execute destructive or risky system changes automatically** (`rm -rf`, `pacman -Rns`, full system upgrades, or unattended DM restarts).

## Key Technical Domains

- **Multi-monitor & Hotplug**: Explicit `monitor` entries (`name` or `desc:...`), fallback catch-all rule (`monitor = , preferred, auto, 1`), monitor-pinned workspaces, and fullscreen coordination with Top HUD.
- **Window & Layer Rules**: Float dialogs/utilities cleanly, preserve fullscreen/screen-sharing compatibility (`xdg-desktop-portal-hyprland`), and match exact case-sensitive `class`/`title` filters supported by the detected Hyprland version.
- **Tiling, Floating & Keybindings**: Conflict-free bindings covering focus, move/resize, float toggle, workspace switching, terminal, launcher, lock (`hyprlock` if supported + fallback), and session menu; keep `docs/KEYBINDINGS.md` synced.
- **Animations**: Fast, low-overshoot tactical curves with a clean switch to disable animations when `reducedMotion` or low-FPS mode is requested.
- **IPC Integration**: Expose clean `$HYPRLAND_INSTANCE_SIGNATURE` events for Quickshell; avoid shell scripts polling `hyprctl`.

## Context Optimization

- Read only the relevant `hypr/` modules, `docs/KEYBINDINGS.md`, and `docs/ENVIRONMENT_REPORT.md`.
- Consult [diagnostics-and-syntax.md](./references/diagnostics-and-syntax.md) only when checking syntax variants or triaging boot/session issues.

## Definition of Done

- Target Hyprland version and syntax format verified (or explicitly marked `NOT RUN — requires CachyOS` when authoring offline on Windows).
- Profile remains completely isolated from existing user dotfiles.
- Backup, rollback, and remote-access preservation steps are documented and verified.

## Brief Report Format

- **Target Version & Format**: detected Hyprland version and config syntax (`hyprlang` / `hyprland.lua` / unverified on Windows).
- **Changed Files**: `hypr/` configs and `docs/` updates.
- **Safety & Recovery**: isolation mechanism, backup scope, rollback command.
- **Checks**: syntax/session tests run vs `NOT RUN — requires CachyOS`.

