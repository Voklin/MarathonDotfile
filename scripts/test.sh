#!/usr/bin/env bash
# MARATHON Tactical — Unified Verification Runner

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

PYTHON_BIN="${PYTHON_BIN:-python3}"
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    PYTHON_BIN="python"
fi

"$PYTHON_BIN" scripts/check_qml.py
"$PYTHON_BIN" tests/test_contracts_and_assets.py
MARATHON_TEST_BASH="$BASH" "$PYTHON_BIN" tests/test_installer.py
"$PYTHON_BIN" tests/run_tests.py

if command -v bash >/dev/null 2>&1; then
    bash -n scripts/install.sh
    bash -n setup.sh
    bash -n scripts/profile-common.sh
    bash -n scripts/uninstall.sh
    bash -n scripts/doctor.sh
    bash -n scripts/test.sh
    bash -n scripts/copy-image.sh
    bash -n scripts/session-daemons.sh
    bash -n scripts/apply-themes.sh
    bash -n scripts/shell-ctl.sh
    bash -n scripts/onboarding.sh
    bash scripts/install.sh --dry-run >/dev/null
    bash scripts/uninstall.sh --dry-run >/dev/null
    bash scripts/apply-themes.sh --dry-run >/dev/null
    echo "Bash syntax & --dry-run PASS."
fi

