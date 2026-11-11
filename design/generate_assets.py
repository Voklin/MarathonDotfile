#!/usr/bin/env python3
"""Generate original geometric SVG icons and tactical wallpapers for MARATHON Tactical."""

import sys
from pathlib import Path
from PySide6.QtCore import QByteArray
from PySide6.QtGui import QGuiApplication, QImage, QPainter
from PySide6.QtSvg import QSvgRenderer


DESIGN_DIR = Path(__file__).resolve().parent
ICONS_DIR = DESIGN_DIR / "icons"
WALLPAPERS_DIR = DESIGN_DIR / "wallpapers"

# Central palette matching ui/tokens/Tokens.qml
BG = "#080B0A"
BG_ALT = "#0B100E"
GRID_SUB = "#121C17"
GRID_MAIN = "#1B2A22"
BORDER = "#354D24"
SIGNAL = "#C9FF16"
MUTED = "#99A89C"
TEXT = "#F0F4E8"


SVG_ICON_PATHS: dict[str, str] = {
    "grid": (
        '<rect x="2.5" y="2.5" width="4.5" height="4.5"/>'
        '<rect x="9" y="2.5" width="4.5" height="4.5"/>'
        '<rect x="2.5" y="9" width="4.5" height="4.5"/>'
        '<rect x="9" y="9" width="4.5" height="4.5"/>'
    ),
    "audio": (
        '<polygon points="2.5,6 5.5,6 9,3 9,13 5.5,10 2.5,10"/>'
        '<polyline points="11.5,5.5 13,8 11.5,10.5"/>'
        '<polyline points="13.5,3.5 15,8 13.5,12.5"/>'
    ),
    "audio-muted": (
        '<polygon points="2.5,6 5.5,6 9,3 9,13 5.5,10 2.5,10"/>'
        '<line x1="11" y1="5.5" x2="14.5" y2="10.5"/>'
        '<line x1="14.5" y1="5.5" x2="11" y2="10.5"/>'
    ),
    "mic": (
        '<rect x="6" y="2" width="4" height="7"/>'
        '<polyline points="4,7.5 4,10.5 12,10.5 12,7.5"/>'
        '<line x1="8" y1="10.5" x2="8" y2="14"/>'
        '<line x1="5.5" y1="14" x2="10.5" y2="14"/>'
    ),
    "mic-muted": (
        '<rect x="6" y="2" width="4" height="7"/>'
        '<polyline points="4,7.5 4,10.5 12,10.5 12,7.5"/>'
        '<line x1="8" y1="10.5" x2="8" y2="14"/>'
        '<line x1="5.5" y1="14" x2="10.5" y2="14"/>'
        '<line x1="2.5" y1="2.5" x2="13.5" y2="13.5"/>'
    ),
    "wifi": (
        '<polyline points="2,5.5 8,3 14,5.5"/>'
        '<polyline points="4,8.5 8,6.8 12,8.5"/>'
        '<rect x="7" y="11" width="2" height="2" fill="currentColor" stroke="none"/>'
    ),
    "wifi-off": (
        '<polyline points="2,5.5 8,3 14,5.5"/>'
        '<polyline points="4,8.5 8,6.8 12,8.5"/>'
        '<rect x="7" y="11" width="2" height="2" fill="currentColor" stroke="none"/>'
        '<line x1="2.5" y1="2.5" x2="13.5" y2="13.5"/>'
    ),
    "ethernet": (
        '<rect x="2.5" y="3" width="11" height="8"/>'
        '<rect x="5" y="5" width="1.5" height="3" fill="currentColor" stroke="none"/>'
        '<rect x="7.5" y="5" width="1.5" height="3" fill="currentColor" stroke="none"/>'
        '<rect x="10" y="5" width="1.5" height="3" fill="currentColor" stroke="none"/>'
        '<line x1="8" y1="11" x2="8" y2="14"/>'
        '<line x1="4" y1="14" x2="12" y2="14"/>'
    ),
    "bluetooth": (
        '<polyline points="4.5,5 12,10.5 8,14 8,2 12,5.5 4.5,11"/>'
    ),
    "bluetooth-off": (
        '<polyline points="4.5,5 12,10.5 8,14 8,2 12,5.5 4.5,11"/>'
        '<line x1="2.5" y1="2.5" x2="13.5" y2="13.5"/>'
    ),
    "battery": (
        '<rect x="2" y="4.5" width="11" height="7"/>'
        '<rect x="13" y="6.5" width="1.5" height="3" fill="currentColor" stroke="none"/>'
        '<rect x="4" y="6.5" width="7" height="3" fill="currentColor" stroke="none"/>'
    ),
    "battery-charging": (
        '<rect x="2" y="4.5" width="11" height="7"/>'
        '<rect x="13" y="6.5" width="1.5" height="3" fill="currentColor" stroke="none"/>'
        '<polyline points="8.5,5.5 6,8 8.5,8 6.5,10.5"/>'
    ),
    "brightness": (
        '<rect x="5.5" y="5.5" width="5" height="5"/>'
        '<line x1="8" y1="1.5" x2="8" y2="3.5"/>'
        '<line x1="8" y1="12.5" x2="8" y2="14.5"/>'
        '<line x1="1.5" y1="8" x2="3.5" y2="8"/>'
        '<line x1="12.5" y1="8" x2="14.5" y2="8"/>'
        '<line x1="3.3" y1="3.3" x2="4.6" y2="4.6"/>'
        '<line x1="11.4" y1="11.4" x2="12.7" y2="12.7"/>'
        '<line x1="12.7" y1="3.3" x2="11.4" y2="4.6"/>'
        '<line x1="4.6" y1="11.4" x2="3.3" y2="12.7"/>'
    ),
    "bell": (
        '<polygon points="4,11 4.5,5.5 8,3 11.5,5.5 12,11"/>'
        '<line x1="2.5" y1="11" x2="13.5" y2="11"/>'
        '<rect x="7" y="12.5" width="2" height="1.5" fill="currentColor" stroke="none"/>'
    ),
    "bell-off": (
        '<polygon points="4,11 4.5,5.5 8,3 11.5,5.5 12,11"/>'
        '<line x1="2.5" y1="11" x2="13.5" y2="11"/>'
        '<rect x="7" y="12.5" width="2" height="1.5" fill="currentColor" stroke="none"/>'
        '<line x1="2.5" y1="2.5" x2="13.5" y2="13.5"/>'
    ),
    "lock": (
        '<rect x="3.5" y="7" width="9" height="6.5"/>'
        '<polyline points="5.5,7 5.5,4 8,2.5 10.5,4 10.5,7"/>'
        '<rect x="7.2" y="9.5" width="1.6" height="2" fill="currentColor" stroke="none"/>'
    ),
    "power": (
        '<line x1="8" y1="2" x2="8" y2="8"/>'
        '<polyline points="4.5,4.5 3,7.5 4.5,11.5 8,13.5 11.5,11.5 13,7.5 11.5,4.5"/>'
    ),
    "reboot": (
        '<polyline points="12.5,5.5 10.5,3 5,3 3,8 5,13 11,13 13,9.5"/>'
        '<polyline points="10,6 13.5,6 13.5,2.5"/>'
    ),
    "logout": (
        '<polyline points="9,2.5 3,2.5 3,13.5 9,13.5"/>'
        '<line x1="6.5" y1="8" x2="13.5" y2="8"/>'
        '<polyline points="11,5.5 13.5,8 11,10.5"/>'
    ),
    "sleep": (
        '<polygon points="10.5,2.5 6,4.5 4.5,9 7,13 12,13 8.5,10 8.5,6"/>'
    ),
    "search": (
        '<polygon points="4,3 9,3 10.5,4.5 10.5,9.5 9,11 4,11 2.5,9.5 2.5,4.5"/>'
        '<line x1="10.2" y1="10.2" x2="14" y2="14"/>'
    ),
    "settings": (
        '<rect x="5.5" y="5.5" width="5" height="5"/>'
        '<rect x="7" y="2" width="2" height="2" fill="currentColor" stroke="none"/>'
        '<rect x="7" y="12" width="2" height="2" fill="currentColor" stroke="none"/>'
        '<rect x="2" y="7" width="2" height="2" fill="currentColor" stroke="none"/>'
        '<rect x="12" y="7" width="2" height="2" fill="currentColor" stroke="none"/>'
    ),
    "close": (
        '<line x1="3.5" y1="3.5" x2="12.5" y2="12.5"/>'
        '<line x1="12.5" y1="3.5" x2="3.5" y2="12.5"/>'
    ),
    "check": (
        '<polyline points="3,8.5 6.5,12 13,4.5"/>'
    ),
    "warning": (
        '<polygon points="8,2.5 14,13.5 2,13.5"/>'
        '<rect x="7.3" y="6.5" width="1.4" height="3.5" fill="currentColor" stroke="none"/>'
        '<rect x="7.3" y="11" width="1.4" height="1.4" fill="currentColor" stroke="none"/>'
    ),
    "terminal": (
        '<rect x="2" y="3" width="12" height="10"/>'
        '<polyline points="4.5,6 7,8 4.5,10"/>'
        '<line x1="8.5" y1="10" x2="11.5" y2="10"/>'
    ),
    "chevron-right": (
        '<polyline points="5.5,3.5 10.5,8 5.5,12.5"/>'
    ),
    "chevron-left": (
        '<polyline points="10.5,3.5 5.5,8 10.5,12.5"/>'
    ),
    "clipboard": (
        '<rect x="3.5" y="3.5" width="9" height="10.5"/>'
        '<rect x="6" y="2" width="4" height="2" fill="currentColor" stroke="none"/>'
        '<line x1="5.5" y1="7" x2="10.5" y2="7"/>'
        '<line x1="5.5" y1="10" x2="9" y2="10"/>'
    ),
    "capture": (
        '<polyline points="2.5,5.5 2.5,2.5 5.5,2.5"/>'
        '<polyline points="10.5,2.5 13.5,2.5 13.5,5.5"/>'
        '<polyline points="13.5,10.5 13.5,13.5 10.5,13.5"/>'
        '<polyline points="5.5,13.5 2.5,13.5 2.5,10.5"/>'
        '<rect x="6" y="6" width="4" height="4"/>'
    ),
    "play": (
        '<polygon points="4.5,3 13,8 4.5,13"/>'
    ),
    "pause": (
        '<rect x="4" y="3" width="2.5" height="10" fill="currentColor" stroke="none"/>'
        '<rect x="9.5" y="3" width="2.5" height="10" fill="currentColor" stroke="none"/>'
    ),
    "calendar": (
        '<rect x="2.5" y="3.5" width="11" height="10"/>'
        '<line x1="5.5" y1="2" x2="5.5" y2="4.5"/>'
        '<line x1="10.5" y1="2" x2="10.5" y2="4.5"/>'
        '<line x1="2.5" y1="6.5" x2="13.5" y2="6.5"/>'
        '<rect x="5" y="8.5" width="2" height="2" fill="currentColor" stroke="none"/>'
        '<rect x="9" y="8.5" width="2" height="2" fill="currentColor" stroke="none"/>'
    ),
    "cpu": (
        '<rect x="4.5" y="4.5" width="7" height="7"/>'
        '<rect x="6.8" y="6.8" width="2.4" height="2.4" fill="currentColor" stroke="none"/>'
        '<line x1="6.5" y1="2" x2="6.5" y2="4.5"/>'
        '<line x1="9.5" y1="2" x2="9.5" y2="4.5"/>'
        '<line x1="6.5" y1="11.5" x2="6.5" y2="14"/>'
        '<line x1="9.5" y1="11.5" x2="9.5" y2="14"/>'
        '<line x1="2" y1="6.5" x2="4.5" y2="6.5"/>'
        '<line x1="2" y1="9.5" x2="4.5" y2="9.5"/>'
        '<line x1="11.5" y1="6.5" x2="14" y2="6.5"/>'
        '<line x1="11.5" y1="9.5" x2="14" y2="9.5"/>'
    ),
    "palette": (
        '<polygon points="3,4 13,4 13,10 9,10 9,13 3,13"/>'
        '<rect x="5" y="6" width="2" height="2" fill="currentColor" stroke="none"/>'
        '<rect x="9" y="6" width="2" height="2" fill="currentColor" stroke="none"/>'
    ),
    "help": (
        '<rect x="2.5" y="2.5" width="11" height="11"/>'
        '<polyline points="6,6.2 6,5 10,5 10,7.5 8,8.5 8,9.8"/>'
        '<rect x="7.3" y="11" width="1.4" height="1.4" fill="currentColor" stroke="none"/>'
    ),
}


def generate_icons() -> None:
    ICONS_DIR.mkdir(parents=True, exist_ok=True)
    for name, body in SVG_ICON_PATHS.items():
        svg = (
            '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16" '
            'fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="square" '
            'stroke-linejoin="miter">\n'
            f"  {body}\n"
            "</svg>\n"
        )
        (ICONS_DIR / f"{name}.svg").write_text(svg, encoding="utf-8")

    readme = (
        "# MARATHON Tactical — Original Geometric SVG Icons\n\n"
        f"Total icons: **{len(SVG_ICON_PATHS)}** (`16x16` integer/pixel-snapped viewBox, `1.4px` stroke, miter joins).\n\n"
        "- Zero proprietary Bungie Marathon or third-party trademark glyphs.\n"
        "- Uses `currentColor` so icons adapt cleanly across QML themes or Hyprland tools.\n"
        "- Synced 1-to-1 with [`ui/components/TacticalIcon.qml`](../../ui/components/TacticalIcon.qml).\n"
    )
    (ICONS_DIR / "README.md").write_text(readme, encoding="utf-8")


def build_desktop_wallpaper_svg(w: int, h: int, lock_variant: bool = False) -> str:
    grid_step = 128 if w >= 3000 else 64
    sub_lines = []
    for x in range(0, w + 1, grid_step):
        sub_lines.append(f'<line x1="{x}.5" y1="0" x2="{x}.5" y2="{h}"/>')
    for y in range(0, h + 1, grid_step):
        sub_lines.append(f'<line x1="0" y1="{y}.5" x2="{w}" y2="{y}.5"/>')

    # Crosshair intersection markers on major 4x4 grid intervals
    crosshairs = []
    major_step = grid_step * 4
    for x in range(major_step, w, major_step):
        for y in range(major_step, h, major_step):
            crosshairs.append(f'<line x1="{x - 6}" y1="{y}.5" x2="{x + 6}" y2="{y}.5"/>')
            crosshairs.append(f'<line x1="{x}.5" y1="{y - 6}" x2="{x}.5" y2="{y + 6}"/>')

    margin = int(w * 0.03)
    cx = int(w * 0.5)
    cy = int(h * 0.5)
    diag_offset = int(h * 0.24)
    scale = 2 if w >= 3000 else 1

    # Perimeter vertical ruler ticks (left and right flanks)
    ruler_ticks = []
    for ry in range(margin + grid_step, h - margin, grid_step // 2):
        tlen = (16 if (ry % grid_step == 0) else 8) * scale
        ruler_ticks.append(f'<line x1="{margin}" y1="{ry}.5" x2="{margin + tlen}" y2="{ry}.5"/>')
        ruler_ticks.append(f'<line x1="{w - margin - tlen}" y1="{ry}.5" x2="{w - margin}" y2="{ry}.5"/>')

    # 2-row stepped pixel-checkerboard decal helper (from Bungie Grey Decal Sheet)
    def checker_decal(x0: int, y0: int, cells: int, color: str, opacity: float = 0.85) -> str:
        rects = []
        cw = 7 * scale
        ch = 5 * scale
        for i in range(cells):
            ry = y0 if (i % 2 == 0) else (y0 + ch + scale)
            rects.append(f'<rect x="{x0 + i * (cw + scale)}" y="{ry}" width="{cw}" height="{ch}" fill="{color}" opacity="{opacity}"/>')
        return "".join(rects)

    # Bowtie hourglass + dimension arrow helper (<--- S50-R ---> ►◄ from Grey Decal Sheet)
    def bowtie_decal(x0: int, y0: int, color: str, opacity: float = 0.80) -> str:
        s = scale
        return (
            f'<polygon points="{x0},{y0} {x0 + 14 * s},{y0 + 8 * s} {x0},{y0 + 16 * s}" fill="{color}" opacity="{opacity}"/>'
            f'<polygon points="{x0 + 28 * s},{y0} {x0 + 14 * s},{y0 + 8 * s} {x0 + 28 * s},{y0 + 16 * s}" fill="{color}" opacity="{opacity}"/>'
            f'<line x1="{x0 + 38 * s}" y1="{y0 + 8 * s}" x2="{x0 + 130 * s}" y2="{y0 + 8 * s}" stroke="{color}" stroke-width="{1.5 * s}" opacity="{opacity}"/>'
        )

    tactical_frame = ""
    if not lock_variant:
        top_checker = checker_decal(margin, margin, 18, SIGNAL, 0.85)
        top_bowtie = bowtie_decal(margin + 160 * scale, margin - 2 * scale, BORDER, 0.85)
        bot_checker = checker_decal(w - margin - 160 * scale, h - margin - 12 * scale, 18, BORDER, 0.80)
        bot_bowtie = bowtie_decal(margin, h - margin - 16 * scale, SIGNAL, 0.70)

        tactical_frame = f"""
  <!-- Perimeter telemetry ruler ticks -->
  <g stroke="{BORDER}" stroke-width="{scale}">
    {"".join(ruler_ticks)}
  </g>

  <!-- Asymmetric architectural diagonal guides -->
  <polyline points="{w - margin - diag_offset},{margin} {w - margin},{margin} {w - margin},{margin + diag_offset}"
            fill="none" stroke="{GRID_MAIN}" stroke-width="{2 * scale}"/>
  <polyline points="{margin},{h - margin - diag_offset} {margin},{h - margin} {margin + diag_offset},{h - margin}"
            fill="none" stroke="{GRID_MAIN}" stroke-width="{2 * scale}"/>

  <!-- Subtle diagonal structural beam on right flank -->
  <line x1="{int(w * 0.72)}" y1="{h}" x2="{int(w * 0.96)}" y2="{int(h * 0.28)}"
        stroke="{BG_ALT}" stroke-width="{max(24, w // 96)}"/>
  <line x1="{int(w * 0.72)}" y1="{h}" x2="{int(w * 0.96)}" y2="{int(h * 0.28)}"
        stroke="{GRID_MAIN}" stroke-width="{1.5 * scale}"/>

  <!-- Minimal center geometric reticle + corner target brackets -->
  <rect x="{cx - 180 * scale}" y="{cy - 180 * scale}" width="{360 * scale}" height="{360 * scale}"
        fill="none" stroke="{GRID_SUB}" stroke-width="{1.5 * scale}"/>
  <polyline points="{cx - 196 * scale},{cy - 140 * scale} {cx - 196 * scale},{cy - 196 * scale} {cx - 140 * scale},{cy - 196 * scale}"
            fill="none" stroke="{BORDER}" stroke-width="{2 * scale}"/>
  <polyline points="{cx + 140 * scale},{cy + 196 * scale} {cx + 196 * scale},{cy + 196 * scale} {cx + 196 * scale},{cy + 140 * scale}"
            fill="none" stroke="{BORDER}" stroke-width="{2 * scale}"/>
  <line x1="{cx - 14 * scale}" y1="{cy}.5" x2="{cx + 14 * scale}" y2="{cy}.5" stroke="{BORDER}" stroke-width="{1.5 * scale}"/>
  <line x1="{cx}.5" y1="{cy - 14 * scale}" x2="{cx}.5" y2="{cy + 14 * scale}" stroke="{BORDER}" stroke-width="{1.5 * scale}"/>

  <!-- Top-left Marathon Development Decal Stamp (2-row Pixel Checkerboard + Bowtie + S50-R) -->
  {top_checker}
  {top_bowtie}
  <text x="{margin}" y="{margin + 28 * scale}" fill="{SIGNAL}" opacity="0.85"
        font-family="monospace" font-size="{max(12, w // 160)}" font-weight="bold" letter-spacing="2">S+ // BA-SR-001 // U73-PURE</text>
  <text x="{margin}" y="{margin + 44 * scale}" fill="{MUTED}" opacity="0.65"
        font-family="monospace" font-size="{max(10, w // 200)}" letter-spacing="2">S50-R // Ao+RT8 // GRAPHIC_REALISM</text>

  <!-- Bottom-left & bottom-right technical decal stamps -->
  {bot_bowtie}
  <text x="{margin + 140 * scale}" y="{h - margin - 4 * scale}" fill="{MUTED}" opacity="0.60"
        font-family="monospace" font-size="{max(10, w // 200)}" letter-spacing="2">N35 // KX8 // MAG_LOCK</text>
  {bot_checker}
  <text x="{w - margin}" y="{h - margin + 16 * scale}" text-anchor="end" fill="{MUTED}" opacity="0.55"
        font-family="monospace" font-size="{max(11, w // 190)}" letter-spacing="2">GRID:{grid_step}PX // TARGET:CACHYOS-HYPR</text>
"""
    else:
        lock_top_checker = checker_decal(cx - 110 * scale, margin + 8 * scale, 26, SIGNAL, 0.75)
        lock_bot_checker = checker_decal(cx - 110 * scale, h - margin - 18 * scale, 26, BORDER, 0.75)
        lock_bowtie = bowtie_decal(margin + 24 * scale, h - margin - 26 * scale, BORDER, 0.80)
        tactical_frame = f"""
  <!-- Perimeter telemetry ruler ticks -->
  <g stroke="{BORDER}" stroke-width="{scale}">
    {"".join(ruler_ticks)}
  </g>

  <!-- Clean quiet Lock Screen framing with Marathon pixel-checkerboard decals -->
  <rect x="{margin}" y="{margin}" width="{w - margin * 2}" height="{h - margin * 2}"
        fill="none" stroke="{GRID_SUB}" stroke-width="2"/>
  <polyline points="{margin},{margin + 32 * scale} {margin},{margin} {margin + 32 * scale},{margin}" fill="none" stroke="{SIGNAL}" stroke-width="{2 * scale}" opacity="0.85"/>
  <polyline points="{w - margin - 32 * scale},{margin} {w - margin},{margin} {w - margin},{margin + 32 * scale}" fill="none" stroke="{SIGNAL}" stroke-width="{2 * scale}" opacity="0.85"/>
  <polyline points="{margin},{h - margin - 32 * scale} {margin},{h - margin} {margin + 32 * scale},{h - margin}" fill="none" stroke="{BORDER}" stroke-width="{2 * scale}"/>
  <polyline points="{w - margin - 32 * scale},{h - margin} {w - margin},{h - margin} {w - margin},{h - margin - 32 * scale}" fill="none" stroke="{BORDER}" stroke-width="{2 * scale}"/>
  {lock_top_checker}
  {lock_bot_checker}
  {lock_bowtie}
  <text x="{margin + 170 * scale}" y="{h - margin - 14 * scale}" fill="{MUTED}" opacity="0.60"
        font-family="monospace" font-size="{max(11, w // 190)}" letter-spacing="2">PAM.LOCK // BA-SR-001 // MAG_LOCK</text>
"""

    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <rect width="{w}" height="{h}" fill="{BG}"/>
  <g stroke="{GRID_SUB}" stroke-width="1">
    {"".join(sub_lines)}
  </g>
  <g stroke="{GRID_MAIN}" stroke-width="1.5">
    {"".join(crosshairs)}
  </g>
  {tactical_frame}
</svg>
"""


def render_svg_to_png(svg_text: str, out_png: Path, w: int, h: int) -> None:
    renderer = QSvgRenderer(QByteArray(svg_text.encode("utf-8")))
    img = QImage(w, h, QImage.Format.Format_ARGB32)
    img.fill(0)
    painter = QPainter(img)
    renderer.render(painter)
    painter.end()
    if not img.save(str(out_png), "PNG"):
        raise RuntimeError(f"Failed to save PNG: {out_png}")


def generate_wallpapers() -> None:
    WALLPAPERS_DIR.mkdir(parents=True, exist_ok=True)
    specs = [
        ("marathon-grid-3840x2160", 3840, 2160, False),
        ("marathon-grid-1920x1080", 1920, 1080, False),
        ("marathon-lock-3840x2160", 3840, 2160, True),
    ]
    for stem, w, h, is_lock in specs:
        svg_text = build_desktop_wallpaper_svg(w, h, lock_variant=is_lock)
        (WALLPAPERS_DIR / f"{stem}.svg").write_text(svg_text, encoding="utf-8")
        render_svg_to_png(svg_text, WALLPAPERS_DIR / f"{stem}.png", w, h)

    readme = (
        "# MARATHON Tactical — Geometric Wallpapers\n\n"
        "- `marathon-grid-3840x2160.svg` / `.png`: 4K low-noise tactical architectural wallpaper (#080B0A backdrop, subtle grid, <0.5% #C9FF16 accent).\n"
        "- `marathon-grid-1920x1080.svg` / `.png`: 1080p native desktop wallpaper.\n"
        "- `marathon-lock-3840x2160.svg` / `.png`: distraction-free lock screen backdrop paired with `hypr/hyprlock.conf`.\n\n"
        "All wallpapers are 100% procedurally generated in-repo by `design/generate_assets.py` (original project work, zero third-party/game IP assets).\n"
    )
    (WALLPAPERS_DIR / "README.md").write_text(readme, encoding="utf-8")


if __name__ == "__main__":
    _app = QGuiApplication(sys.argv)
    generate_icons()
    generate_wallpapers()
    print(f"Generated {len(SVG_ICON_PATHS)} icons and 3 wallpapers under {DESIGN_DIR}")
