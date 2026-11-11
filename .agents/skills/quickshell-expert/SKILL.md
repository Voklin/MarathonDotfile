---
name: quickshell-expert
description: >-
  Develop and debug Quickshell and QML shell integrations for MARATHON Tactical
  on Linux (PanelWindow, multi-monitor Variants, Hyprland IPC, PipeWire, MPRIS,
  Notifications, SystemTray, and Linux live adapters in shell/services/). Do not
  use for Windows-only mock previews (qtquick-preview) or Hyprland config files
  (hyprland-expert).
---

# Quickshell & QML Shell Expert

## Purpose and Activation

Use this skill when building or fixing Linux shell modules under `shell/`, Quickshell entrypoints (`shell.qml`), Wayland layer-shell panels, multi-monitor bindings, or live service adapters (`shell/services/`). Keep pure visual primitives under `ui/` completely free of `Quickshell` imports.

Read [quickshell-apis.md](./references/quickshell-apis.md) only when inspecting specific Quickshell module APIs, fallback patterns, or binding-loop anti-patterns.

## Step-by-Step Workflow

1. **Verify target environment and docs**: Check the installed Quickshell version on CachyOS (`qs --version` or `quickshell --version`) and consult `https://quickshell.org/docs/` before using any non-trivial Quickshell type or singleton. If running on Windows, implement against verified contracts and mark Linux runtime tests `NOT RUN — requires CachyOS`.
2. **Define or inspect the State/Adapter contract**: Confirm the shared properties, methods, and signals required by the UI component (`Workspaces`, `ActiveWindow`, `Audio`, `Network`, `Battery`, `Brightness`, `Notifications`, `Session`, `Launcher`, `Appearance`).
3. **Keep UI and Linux logic separate**:
   - Place reusable visual controls in `ui/` importing only `QtQuick`, `QtQuick.Layouts`, and `QtQuick.Controls`.
   - Place Quickshell windows (`PanelWindow`, `Variants`) and live adapters in `shell/`.
4. **Implement event-driven service adapters**: Bind directly to Quickshell signals/models (`Quickshell.Hyprland`, `Quickshell.Services.Pipewire`, `Mpris`, `Notifications`, `SystemTray`). Guard every optional object for `null`/unavailable state.
5. **Audit bindings, lifecycle, and performance**: Ensure lazy instantiation for hidden overlays (`Loader` / `active`), pause timers when hidden, prevent binding loops, and support `reducedMotion`.
6. **Verify**: Run available QML syntax/type checks (`qmllint` if installed) locally and prepare exact CachyOS verification commands.

## Recommended Component & Service Structure

```qml
// ui/components/WorkspaceStrip.qml  (Pure UI: zero Quickshell imports)
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property var workspacesModel   // Uniform contract: [{ id, name, active, urgent, occupied }]
    required property bool serviceAvailable
    signal workspaceRequested(int workspaceId)

    spacing: 4
    // Render fallback badge when !serviceAvailable; emit workspaceRequested(id) on click/key.
}
```

```qml
// shell/panels/TopHudWindow.qml  (Thin Quickshell shell layer)
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services" as Services
import "../../ui/components" as Ui

Variants {
    model: Quickshell.screens
    PanelWindow {
        required property var modelData
        screen: modelData
        anchors { top: true; left: true; right: true }
        implicitHeight: 36

        Ui.WorkspaceStrip {
            workspacesModel: Services.HyprlandAdapter.workspacesForScreen(modelData.name)
            serviceAvailable: Services.HyprlandAdapter.available
            onWorkspaceRequested: (id) => Services.HyprlandAdapter.focusWorkspace(id)
        }
    }
}
```

### Service-Layer Interaction Rules

- **Single contract parity**: `shell/services/*Adapter.qml` must expose the exact property names, enums, error/loading flags, and action methods implemented by `preview/mocks/*Mock.qml`.
- **Degrade gracefully**: Missing PipeWire sink, absent battery, disabled NetworkManager, or inactive MPRIS player must surface `available: false` and safe defaults — never throw uncaught null-reference errors.
- **Controlled processes only**: When no native Quickshell API exists (e.g., `brightnessctl` or `nmcli`), use Quickshell `Process` with explicit argument arrays, exit-code checks, and timeouts. Never pass unescaped strings to `sh -c`.

## Technical Rules & Prohibitions

1. **Never invent Quickshell APIs**, singleton names, properties, or signals.
2. **Verify uncertain or version-sensitive calls** against `https://quickshell.org/docs/` and the installed CachyOS Quickshell build.
3. **Never use deprecated Qt5/Quickshell constructs** without confirming compatibility with the target Qt6/Quickshell version.
4. **Never poll the system frequently**: avoid short-interval `Timer` loops calling external tools (`hyprctl`, `pactl`, `wpctl`).
5. **Prefer reactive bindings and signals** (`Connections`, IPC events, `PwObjectTracker`, `ObjectModel`). Any unavoidable fallback timer must be configurable and paused when hidden.
6. **Never import `Quickshell.*` inside `ui/`** shared visual components.
7. **Never spawn persistent custom backend daemons** (Python/Rust/Node IPC servers) where native Quickshell/Hyprland/D-Bus integrations suffice.

## Context Optimization

- Read only the specific `ui/` component, adapter contract, and `shell/` module for the current slice.
- Load [quickshell-apis.md](./references/quickshell-apis.md) only when checking module imports or service patterns.
- Do not scan unrelated Hyprland or theme files unless modifying shared contracts.

## Definition of Done

- Shared `ui/` files contain zero `Quickshell` imports.
- Live adapter exposes explicit `available`, `loading`, and `error` states matching the mock contract.
- Multi-monitor `Variants` / screen scoping and hidden-state resource cleanup are handled.
- Event-driven updates verified by code inspection; any unrun Linux runtime tests are explicitly marked `NOT RUN — requires CachyOS`.

## Brief Report Format

- **Scope & Files**: modified `shell/` and adapter files.
- **Contract & Fallbacks**: adapter properties/signals and missing-service behavior.
- **Checks**: QML lint/static checks executed + Linux runtime checks marked `NOT RUN` if on Windows.
- **Risks / Next Verification**: APIs needing CachyOS confirmation against installed Quickshell version.

