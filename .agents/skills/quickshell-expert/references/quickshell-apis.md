# Quickshell API & Service Patterns Reference

Always verify exact type signatures against the installed Quickshell version on CachyOS and `https://quickshell.org/docs/` before finalizing Linux adapters.

## Core Modules & Patterns

| Concern | Quickshell Module | Key Objects / Patterns | Missing-Service / Lifecycle Guard |
|---|---|---|---|
| Shell Root & Screens | `Quickshell` | `ShellRoot`, `Variants { model: Quickshell.screens }`, `Scope` | Scope per-monitor panels cleanly; handle `screens` hotplug add/remove without global singletons overwriting per-screen state. |
| Layer-Shell Windows | `Quickshell.Wayland` | `PanelWindow`, `anchors`, `exclusiveZone`, `WlrLayer`, `WlrKeyboardFocus` | Release keyboard grab immediately when closing Launcher / Session Menu; disable `exclusiveZone` if HUD auto-hides on fullscreen. |
| Hyprland IPC | `Quickshell.Hyprland` | `Hyprland`, `Hyprland.workspaces`, `Hyprland.monitors`, `Hyprland.focusedWorkspace`, `Hyprland.dispatch(...)` | Guard `Hyprland.focusedWorkspace` and active toplevel for `null`; never poll `hyprctl` on a timer. |
| Audio | `Quickshell.Services.Pipewire` | `Pipewire`, `PwNode`, `PwObjectTracker { objects: [Pipewire.defaultAudioSink] }` | Track nodes with `PwObjectTracker` so audio properties populate reactively; guard `defaultAudioSink == null` and `audio == null`. |
| Media | `Quickshell.Services.Mpris` | `Mpris.players`, `MprisPlayer` | Check player capability flags (`canPlay`, `canPause`, `canGoNext`, etc.) before invoking control methods. |
| Notifications | `Quickshell.Services.Notifications` | `NotificationServer`, `trackedNotifications`, `Notification` | Confirm no competing notification daemon (`dunst`, `mako`, `swaync`) owns `org.freedesktop.Notifications` before starting `NotificationServer`. |
| System Tray | `Quickshell.Services.SystemTray` | `SystemTray.items`, `SystemTrayItem`, `QsMenuAnchor` | Fallback cleanly when `item.menu` is null or `onlyMenu` is true; support secondary click / menu anchor positioning per screen. |

## Binding Loop Prevention

- Never bind a property both declaratively and imperatively to the same source without breaking the cycle (e.g., binding `Slider.value: adapter.volume` while `onValueChanged` writes back `adapter.setVolume(value)` unless gated by `pressed` or using `onMoved`).
- Never compute parent `implicitWidth` from a child whose `width` depends on `parent.width`.
- Use explicit user-intent signals (`onMoved`, `onClicked`, `Keys.onPressed`) to mutate adapter state, and let reactive bindings flow strictly downward from adapter -> UI.

## Resource & Performance Hygiene

- Gate expensive popups (Launcher, Control Center, Notification Center, Lock overlay) behind `Loader.active` or `LazyLoader` so hidden overlays allocate minimal memory and stop animations.
- Connect `Timer.running` to `visible && !reducedMotion` where timers are strictly required (e.g., clock tick every 1000ms or 60000ms, OSD auto-dismiss one-shot timer).
- Prefer `opacity` and `transform` animations; avoid continuous `Canvas` repaints, unbounded blur chains, or per-frame shadow effects.

