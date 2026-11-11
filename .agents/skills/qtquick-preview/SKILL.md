---
name: qtquick-preview
description: >-
  Build, run, and inspect MARATHON Tactical QML UI components on Windows 11
  using QtQuick Preview (preview/Main.qml), Mock Backends (preview/mocks/), and
  reproducible preview scenarios (preview/scenarios/) without Linux, Hyprland,
  or Quickshell. Do not use for Linux live adapters (quickshell-expert) or
  Hyprland configs (hyprland-expert).
---

# QtQuick Windows Preview & Mock Backend

## Purpose and Activation

Use this skill when developing or testing QML UI components on Windows 11, creating `preview/Main.qml` harnesses, writing `preview/mocks/` adapters or `preview/scenarios/` presets, verifying mock/live contract parity, testing viewport scaling/animations, or capturing screenshots for visual review.

Read [preview-scenarios.md](./references/preview-scenarios.md) for the full 10-scenario test matrix and visual defect checklist.

## Step-by-Step Workflow

1. **Check available Qt tooling on Windows** (do not fail or block if absent):
   - Probe `qml`, `qml6`, `qmlscene`, `qmllint`, or Qt Design Studio paths.
   - If Qt Preview tools are missing, continue writing valid, clean QML/mock files and report the exact missing tool and install/run command in your output.
2. **Verify or implement the Mock Backend contract (`preview/mocks/`)**:
   - Mirror the exact properties, signals, enums, and methods of the Linux `shell/services/` contract (`available`, `loading`, `error`, plus domain properties and action slots).
   - Map destructive session commands (`logout`, `reboot`, `poweroff`, `lock`) strictly to simulated state updates or preview toast notifications — never invoke OS power actions.
3. **Wire mock/live adapter switching**:
   - Shared components in `ui/` accept adapter objects or bound properties via `required property` / dependency injection and never import `Quickshell` or `preview/mocks/` directly.
   - `preview/Main.qml` injects `preview/mocks/`; `shell/shell.qml` injects `shell/services/`.
4. **Configure reproducible scenarios (`preview/scenarios/`)**:
   - Drive `preview/Main.qml` with deterministic scenario presets (resolution, scale factor, `reducedMotion`, mock state payloads, and interactive signal triggers like OSD popups or incoming notifications).
5. **Run preview, exercise states, and inspect visuals**:
   - Launch `qml preview/Main.qml` (or `qmlscene` / Qt Design Studio) if available, switch through scenarios, verify Qt property bindings and signal emission (`workspaceRequested`, `volumeChanged`, etc.), test animation transitions (`reducedMotion` on vs off), and capture screenshots for visual defect inspection.

## Mock Backend & Adapter Contract Requirements

```qml
// Example Mock Adapter pattern (preview/mocks/AudioMock.qml)
import QtQuick

QtObject {
    id: root
    property bool available: true
    property bool loading: false
    property string errorMessage: ""
    property real volume: 0.65       // 0.0 .. 1.0
    property bool muted: false
    property string sinkName: "TACTICAL_OUT // HEADSET"

    signal osdTriggered(string kind, real level, bool muted)

    function setVolume(nextVolume) {
        if (!available) return
        volume = Math.max(0.0, Math.min(1.0, nextVolume))
        osdTriggered("audio", volume, muted)
    }

    function toggleMute() {
        if (!available) return
        muted = !muted
        osdTriggered("audio", volume, muted)
    }
}
```

- **Deterministic presets**: Every scenario must load identically across runs (no unseeded random values or wall-clock drift breaking screenshot comparisons).
- **Interactive state triggers**: Include harness controls in `preview/Main.qml` to emit transient events (OSD spike, urgent notification burst, workspace switch, service error toggle) and switch `1366x768`, `1920x1080`, `2560x1440`, and HiDPI scaling cleanly.

## Strict Constraints & Prohibitions

1. **Never import `Quickshell` (or any `Quickshell.*` module)** inside shared `ui/` components.
2. **Never claim that a passing Windows QtQuick Preview guarantees runtime behavior on CachyOS/Linux** (always label Linux checks `NOT RUN — requires CachyOS`).
3. **Never substitute mock preview checks for real Linux/Quickshell integration tests**.
4. **Never require Hyprland, Wayland, or Quickshell to be installed on Windows**.
5. **Never block progress if Qt Preview is not yet installed**: write clean, standard Qt6 QML (`import QtQuick`, `QtQuick.Layouts`, `QtQuick.Controls`), run any available static check, and clearly state the missing Qt runtime dependency.

## Context Optimization

- Inspect only the target `ui/` component, its corresponding mock in `preview/mocks/`, and `preview/Main.qml`.
- Load [preview-scenarios.md](./references/preview-scenarios.md) when adding scenarios or performing a screenshot defect sweep.

## Definition of Done

- Shared `ui/` component builds cleanly with zero `Quickshell` or direct mock imports.
- Mock adapter matches live contract (`available`/`loading`/`error`, properties, signals).
- Reproducible scenarios cover normal, edge, and failure states listed in [preview-scenarios.md](./references/preview-scenarios.md).
- Windows Preview run (or missing Qt toolchain report) and visual inspection results are accurately documented.

## Brief Report Format

- **Preview Harness & Files**: `preview/` and mock files added or updated.
- **Scenarios Verified**: list of tested presets/viewports (or `NOT RUN` with missing Qt tool details).
- **Contract Parity**: confirmation of shared `ui/` isolation and mock/live property/signal alignment.
- **Visual Findings & Next Step**: layout/clipping/motion observations; Linux integration still `NOT RUN — requires CachyOS`.

