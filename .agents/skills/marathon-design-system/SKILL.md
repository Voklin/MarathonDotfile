---
name: marathon-design-system
description: >-
  Enforce the MARATHON Tactical visual design system, centralized QML tokens,
  tactical HUD aesthetics, accessibility/contrast, keyboard states, reduced
  motion, original SVG iconography, and screenshot review across Top HUD,
  Workspace Indicator, Launcher, Control Center, Notification Center, OSD,
  Session Menu, and Lock Screen. Do not use for Linux service wiring
  (quickshell-expert) or Hyprland configs (hyprland-expert).
---

# MARATHON Tactical Design System

## Purpose and Activation

Use this skill whenever designing, styling, or visually reviewing QML components, design tokens (`ui/tokens/`), custom SVGs (`design/icons/`), or any of the 8 core shell surfaces: **Top HUD**, **Workspace Indicator**, **Launcher**, **Control Center**, **Notification Center**, **OSD**, **Session Menu**, and **Lock Screen**.

**Precedence Rule**: Check whether `docs/DESIGN_SYSTEM.md` or `DESIGN_SYSTEM.md` exists in the repository FIRST. If present, that approved document takes strict precedence over the default baseline tokens listed below.

Read [visual-review-checklist.md](./references/visual-review-checklist.md) when auditing interactive states, contrast compliance, or reviewing rendered screenshots.

## Baseline Design Tokens (Default Until `DESIGN_SYSTEM.md` Exists)

| Role | Token Name | Hex | Usage Rule |
|---|---|---|---|
| Background | `void` / `background` | `#080B0A` | Primary backdrop; 80–90% of visual area remains dark neutral. |
| Surface | `surface` | `#141C18` | Elevated HUD panels, cards, popups, input fields. |
| Primary Accent | `signal` / `primary` | `#C9FF16` | Restrained acid-lime reserved for active workspace, focus ring, key telemetry/signals. |
| Primary Text | `text` | `#F0F4E8` | High-contrast body, headers, and numeric readouts. |
| Alert | `alert` | `#FF4268` | Strictly errors, urgent alerts, destructive confirmations (Session Menu). |
| Secondary / Border *(repo baseline)* | `muted` / `border` | `#99A89C` / `#354D24` | Secondary labels and crisp 1px tactical panel borders. |

## Visual Language & Strict Requirements

1. **Centralized tokens only**: Define all colors, spacing (4/8 px base grid), typography sizes, radii, borders, and animation durations in `ui/tokens/`.
2. **Never duplicate hex colors or magic spacing numbers** inside individual QML components.
3. **Tactical futuristic geometry**: Sharp or minimally chamfered/rounded corners, thin 1px structural borders, asymmetric HUD framing, segmented indicators, and restrained technical micro-labels (`SYS / ONLINE`, `WS / 01`) without sacrificing legibility.
4. **No standard web aesthetics or glow spam**: Reject soft SaaS cards, heavy drop shadows, glassmorphism gradients, neon bloom on every control, or emoji icons.
5. **High contrast**: Verify >= 4.5:1 for normal text (`#F0F4E8` on `#141C18`, and dark `#080B0A` text when placed on `#C9FF16` primary fills) and >= 3:1 for meaningful icons and active borders.
6. **Complete state coverage**: Every interactive control must explicitly style `normal`, `hover`, `active` (pressed), `focus` (visible keyboard outline), and `disabled`, plus `error`, `loading`, and `empty` states where applicable.
7. **Full keyboard navigation**: Support `Tab`/`Shift+Tab`, arrow keys, `Enter`, and `Escape` with predictable focus order.
8. **Controlled animations & `reducedMotion`**: Prefer short `opacity`/`transform` transitions; obey a global `reducedMotion` flag (static or instant fade, zero continuous repaints).
9. **Laptop & multi-DPI responsiveness**: Maintain crisp layout from `1366x768` up to `2560x1440+` and `100%–200%` scaling.
10. **Original assets & IP safety**: Never copy protected Bungie Marathon logos, wallpapers, fonts, or game assets without verified distribution licenses. Author original geometric SVGs (`design/icons/`) and use verified open-licensed typography (tabular numerals for clocks/telemetry).

## Relationship with Companion Design Skills

- **Primary Authority**: `DESIGN_SYSTEM.md` (if present) -> `marathon-design-system`.
- **Subordinate Helpers**: Invoke `frontend-design` (composition polish) or `ui-ux-pro-max` (ergonomics/accessibility/layout queries) ONLY as secondary helpers. Never allow them to replace the MARATHON Tactical palette, introduce web/Tailwind idioms into QML, or dilute the tactical geometry.

## Screenshot Visual Review Procedure

Never declare any UI component "visually ready" without inspecting an actual rendered screenshot (from Windows QtQuick Preview first, and later CachyOS stand):

1. Capture screenshots across normal, compact (`1366x768`), HiDPI, long-title, and error/alert states.
2. Inspect the rendered images directly using [visual-review-checklist.md](./references/visual-review-checklist.md).
3. Fix any clipping, contrast failure, missing focus state, or off-palette color before marking the UI slice complete.

## Context Optimization

- Read `DESIGN_SYSTEM.md` (if present), `ui/tokens/`, and only the target component file.
- Load [visual-review-checklist.md](./references/visual-review-checklist.md) only during component state audits or screenshot review.

## Definition of Done

- Zero hardcoded hex literals or arbitrary spacing outside `ui/tokens/`.
- Keyboard navigation, visible focus, `hover`/`active`/`disabled`, and `reducedMotion` are implemented.
- Screenshot(s) inspected against the tactical visual checklist (or exact preview blocker reported if Qt runtime is absent).

## Brief Report Format

- **Component & Tokens Used**: target surface (from the 8 core components) and token references.
- **States & Accessibility**: contrast, keyboard nav, `reducedMotion`, and responsive range covered.
- **Screenshot Review**: inspected image path(s) and findings (or `NOT RUN` reason).

