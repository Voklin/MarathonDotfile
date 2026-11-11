#!/usr/bin/env python3
"""Run MARATHON Tactical QtQuickTest suites via PySide6."""

import os
import sys
from pathlib import Path
from PySide6.QtQuickTest import QUICK_TEST_MAIN


TESTS_DIR = Path(__file__).resolve().parent


def main() -> int:
    os.environ.setdefault("QT_FORCE_STDERR_LOGGING", "1")
    argv = list(sys.argv)
    if "-o" not in argv:
        argv.extend(["-o", "-,txt"])
    return int(QUICK_TEST_MAIN("marathon_tactical", argv, str(TESTS_DIR)))


if __name__ == "__main__":
    sys.exit(main())
