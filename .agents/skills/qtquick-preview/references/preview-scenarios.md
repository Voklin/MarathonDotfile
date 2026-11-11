# Windows Preview Scenarios & Visual Defect Matrix

## Required Reproducible Scenarios

All MARATHON Tactical preview harnesses (`preview/Main.qml` + `preview/scenarios/`) must support switching through these 10 baseline scenarios without restarting the app:

| ID | Scenario | Viewport / Scale | Mock Payload & Signals to Exercise | Target Defects to Catch |
|---|---|---|---|---|
| `S01` | Standard Desktop | `1920x1080`, `1.0x` | Normal active workspaces, audio 65%, Wi-Fi connected, battery 82% | Baseline alignment, spacing rhythm, token contrast |
| `S02` | Wide QHD | `2560x1440`, `1.0x` | Multi-workspace + expanded Control Center / Notification Center | Max-width bounds, HUD anchor drift, awkward dead space |
| `S03` | Compact Laptop | `1366x768`, `1.0x` | Full Top HUD with tray icons, workspaces, active title, clock, metrics | Horizontal overflow, HUD item collision, clipped popups |
| `S04` | HiDPI Scaling | `1920x1080` @ `1.5x` / `2.0x` | Scaled logical viewport (`1280x720` / `960x540` effective) | Subpixel border blur, truncated labels, oversized icons |
| `S05` | Long Window Titles | `1366x768` & `1920x1080` | 90+ char titles, CJK/Cyrillic/Unicode symbols, long app IDs | Missing `Text.ElideRight`, title overlapping status cluster |
| `S06` | Offline / No Network | Any | `network.available = false` / disconnected + error reason string | Unhandled null bindings, blank/broken indicator instead of clear offline state |
| `S07` | Audio Boundaries | Any | Toggle `0%` muted -> `100%` (and over-boost if supported) + `AudioMock.osdTriggered` | Slider thumb clipping, label width jitter (`0%` vs `100%`), OSD timer race |
| `S08` | Missing Sensors | Any | Desktop rig (`battery.available = false`, `brightness.available = false`, `bluetooth.available = false`) | Dead sliders/toggles shown as interactive, layout collapse when items hide |
| `S09` | Notification Flood | Any | 15+ queued notifications (mixed urgency, long body, action buttons) + DND toggle | Unbounded popup height overflowing screen, missing scroll/clear-all, laggy list |
| `S10` | Workspace Matrix | Any | Empty, occupied, focused, urgent, fullscreen-active, and dual-monitor workspace sets | Missing state differentiation, fullscreen HUD auto-hide failure, urgent alert invisibility |

## Visual & Animation Defect Checklist

- **Layout & Geometry**: No text overlapping borders, no clipped focus outlines, zero scrollbars bleeding outside HUD panels.
- **Signals & Bindings**: Clicking/keyboarding a workspace pill or volume slider updates mock state without console binding-loop warnings.
- **Animations & `reducedMotion`**: Toggling `reducedMotion = true` eliminates slide/overshoot animations cleanly and leaves zero half-transparent stuck overlays.
- **Mock Safety**: Triggering Session Menu actions (`Lock`, `Logout`, `Reboot`, `Shutdown`) displays confirmation modal + simulated preview feedback without executing real host commands.

