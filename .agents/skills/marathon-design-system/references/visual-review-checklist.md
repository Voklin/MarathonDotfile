# MARATHON Tactical Component & Visual Review Checklist

## Eight Core Shell Surfaces

| Surface | Tactical Role & Key Visual Rules |
|---|---|
| **Top HUD** | Compact asymmetric bar; restrained `#C9FF16` on active workspace/telemetry only; auto-hide option for fullscreen; crisp 1px lower border. |
| **Workspace Indicator** | Segmented tactical pills/blocks; clearly distinguishes `active`, `occupied`, `empty`, and `urgent` (`#FF4268`), supports keyboard/click activation. |
| **Launcher** | High-contrast centered/offset tactical palette; instant keyboard focus in search input, arrow/Enter/Escape navigation, clear empty/no-results state. |
| **Control Center** | Modular grid of toggles/sliders (audio, brightness, Wi-Fi, Bluetooth, DND); explicit "unavailable" badge when controller is absent. |
| **Notification Center** | Chronological tactical stack with urgency strip (`#FF4268` only for critical), clear-all/dismiss controls, bounded scrollable height. |
| **OSD** | Lightweight non-blocking overlay for volume/brightness/mute; tabular percentage, segmented bar, fast auto-dismiss, static under `reducedMotion`. |
| **Session Menu** | Explicit action grid (`Lock`, `Logout`, `Reboot`, `Shutdown`); destructive actions require confirmation step accented with `#FF4268`. |
| **Lock Screen** | Full-screen `#080B0A` surface, tabular tactical clock, masked input field with high-contrast focus/error feedback, safe fallback if Hyprlock unavailable. |

## Screenshot Inspection Checklist

Inspect every Windows Preview or CachyOS screenshot for:

1. **Palette discipline**: 80–90% dark surfaces (`#080B0A` / `#141C18`); `#C9FF16` never floods whole panels; `#FF4268` appears only on errors/alerts/destructive actions.
2. **Contrast & typography**: All primary/secondary text and technical labels readable at 100% and 150%+ scaling; tabular numerals do not jitter width as values change (`0%` -> `100%`).
3. **Geometry & spacing**: Consistent 4/8 px rhythm, sharp/crisp edges, aligned dividers, zero soft drop-shadow fuzz or generic rounded SaaS pill bloat.
4. **Interactive states**: Capture/verify `hover`, `active`, `focus` (high-visibility focus ring), `disabled` (clearly muted, non-interactive), and `error`/`empty`.
5. **Overflow resilience**: Long window titles (`S05`) elide cleanly; `1366x768` (`S03`) shows zero horizontal clipping or collision.
6. **Original assets**: Zero copyrighted Marathon logos/textures; all custom SVGs align cleanly to pixel grid.

