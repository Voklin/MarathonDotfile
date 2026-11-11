#!/usr/bin/env python3
"""MARATHON Tactical — Windows QtQuick Preview & Screenshot Runner."""

import argparse
import sys
import time
from pathlib import Path

from PySide6.QtCore import QEventLoop, QMetaObject, QTimer, QUrl, Q_ARG
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickWindow


REPO_ROOT = Path(__file__).resolve().parent.parent
PREVIEW_QML = REPO_ROOT / "preview" / "Main.qml"


def wait_ms(ms: int) -> None:
    loop = QEventLoop()
    QTimer.singleShot(ms, loop.quit)
    loop.exec()


def main() -> int:
    parser = argparse.ArgumentParser(description="Run MARATHON Tactical Windows QtQuick Preview")
    parser.add_argument("--scenario", default="S01", help="Initial scenario ID (S01..S10)")
    parser.add_argument("--view", default="shell", choices=["shell", "gallery"], help="Preview view mode")
    parser.add_argument("--panel", default="", help="Optional overlay panel to open (launcher, launcher-grid, control, notifications, session, settings, clipboard, capture, sysmon, calendar, cheatsheet, confirm, osd, toast, lock)")
    parser.add_argument("--section", default="", help="Optional Settings Hub section to open directly (profile, appearance, hud, compositor, displays, connections, config, ...)")
    parser.add_argument("--faction", default="RUNNER", help="Corporate faction theme (RUNNER, CYBERACME, TRAXUS, SEKIGUCHI)")
    parser.add_argument(
        "--screenshot-dir",
        type=Path,
        default=None,
        help="Capture PNG screenshots for listed scenarios and exit cleanly",
    )
    parser.add_argument(
        "--scenarios",
        nargs="+",
        default=["S01", "S02", "S03", "S05", "S06", "S08", "S10"],
        help="Scenario IDs to capture when --screenshot-dir is provided",
    )
    parser.add_argument(
        "--hide-toolbar",
        action="store_true",
        help="Hide preview control toolbar inside Main.qml",
    )
    args = parser.parse_args()

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.addImportPath(str(REPO_ROOT))

    warnings: list[str] = []
    engine.warnings.connect(lambda errs: warnings.extend([e.toString() for e in errs]))

    engine.load(QUrl.fromLocalFile(str(PREVIEW_QML)))
    if not engine.rootObjects():
        print("ERROR: Failed to load preview/Main.qml:", warnings, file=sys.stderr)
        return 1

    win = engine.rootObjects()[0]
    assert isinstance(win, QQuickWindow)
    win.setProperty("showHarnessBar", not args.hide_toolbar)
    win.setProperty("viewMode", args.view)
    QMetaObject.invokeMethod(win, "setFactionTheme", Q_ARG("QVariant", args.faction))
    QMetaObject.invokeMethod(win, "selectScenario", Q_ARG("QVariant", args.scenario))
    if args.section:
        QMetaObject.invokeMethod(win, "setSettingsSection", Q_ARG("QVariant", args.section))
    elif args.panel:
        QMetaObject.invokeMethod(win, "setActivePanel", Q_ARG("QVariant", args.panel))

    if args.screenshot_dir is None:
        return app.exec()

    out_dir: Path = args.screenshot_dir
    out_dir.mkdir(parents=True, exist_ok=True)
    wait_ms(250)

    for sid in args.scenarios:
        QMetaObject.invokeMethod(win, "selectScenario", Q_ARG("QVariant", sid))
        sim_w = int(win.property("simulatedWidth") or 1366)
        sim_h = int(win.property("simulatedHeight") or 768)
        # Render cleanly at realistic window bounds while fitting host
        target_w = min(sim_w, 1600)
        target_h = min(sim_h + (0 if args.hide_toolbar else 48), 960)
        win.resize(target_w, target_h)
        wait_ms(120)
        QMetaObject.invokeMethod(win, "setFactionTheme", Q_ARG("QVariant", args.faction))
        if args.section:
            QMetaObject.invokeMethod(win, "setSettingsSection", Q_ARG("QVariant", args.section))
        elif args.panel:
            QMetaObject.invokeMethod(win, "setActivePanel", Q_ARG("QVariant", args.panel))
        wait_ms(420)
        img = win.grabWindow()
        out_path = out_dir / f"{sid}.png"
        if not img.save(str(out_path)):
            print(f"ERROR: Failed to save {out_path}", file=sys.stderr)
            return 2
        print(f"Saved {out_path} ({img.width()}x{img.height()})")

    if warnings:
        print("QML WARNINGS:", file=sys.stderr)
        for w in warnings:
            print(" ", w, file=sys.stderr)
        return 3

    print("PREVIEW_SWEEP_OK: 0 QML warnings")
    return 0


if __name__ == "__main__":
    sys.exit(main())
