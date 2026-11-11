#!/usr/bin/env python3
"""Static QML lint, layer boundary, and design-token guard for MARATHON Tactical."""

import re
import shutil
import subprocess
import sys
import sysconfig
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
HEX_RE = re.compile(r'["\']#[0-9A-Fa-f]{6,8}["\']')
QUICKSHELL_RE = re.compile(r"\bimport\s+Quickshell\b")
MOCK_IMPORT_RE = re.compile(r"preview[/\\]mocks|preview\.mocks")
SHELL_EXEC_RE = re.compile(r"\bsh\s+-c\b")


def find_qt_tool(*names: str) -> str | None:
    for name in names:
        found = shutil.which(name)
        if found:
            return found

    candidates = []
    for scheme in ("nt_user", "posix_user", "nt", "posix_prefix"):
        p = sysconfig.get_path("scripts", scheme)
        if p:
            candidates.append(Path(p))
    candidates.append(Path(sys.executable).parent / "Scripts")

    for base in candidates:
        for name in names:
            cand = base / name
            if cand.is_file():
                return str(cand)
    return None


def main() -> int:
    core_qml: list[Path] = []
    for folder in ("ui", "preview"):
        d = REPO_ROOT / folder
        if d.is_dir():
            core_qml.extend(sorted(d.rglob("*.qml")))

    shell_dir = REPO_ROOT / "shell"
    shell_qml = sorted(shell_dir.rglob("*.qml")) if shell_dir.is_dir() else []
    all_qml = core_qml + shell_qml

    if not all_qml:
        print("ERROR: No QML files found.", file=sys.stderr)
        return 1

    violations: list[str] = []

    for qml in all_qml:
        rel = qml.relative_to(REPO_ROOT).as_posix()
        text = qml.read_text(encoding="utf-8")

        if rel.startswith("ui/"):
            if QUICKSHELL_RE.search(text):
                violations.append(f"{rel}: forbidden Quickshell import inside ui/")
            if MOCK_IMPORT_RE.search(text):
                violations.append(f"{rel}: forbidden preview/mocks import inside ui/")
            if not rel.startswith("ui/tokens/"):
                for match in HEX_RE.finditer(text):
                    violations.append(f"{rel}: hardcoded hex literal {match.group(0)} outside ui/tokens/")

        if rel.startswith("shell/"):
            if MOCK_IMPORT_RE.search(text):
                violations.append(f"{rel}: forbidden preview/mocks import inside shell/")
            for match in HEX_RE.finditer(text):
                violations.append(f"{rel}: hardcoded hex literal {match.group(0)} in shell/ (use Tokens)")

        if rel == "preview/Main.qml":
            for match in HEX_RE.finditer(text):
                violations.append(f"{rel}: hardcoded hex literal {match.group(0)} in preview/Main.qml")

        if SHELL_EXEC_RE.search(text):
            violations.append(f"{rel}: forbidden 'sh -c' invocation")

    if violations:
        print("ARCHITECTURAL / TOKEN VIOLATIONS:", file=sys.stderr)
        for v in violations:
            print("  -", v, file=sys.stderr)
        return 2

    print(
        f"Layer & token check PASS ({len(all_qml)} QML files checked: "
        f"{len(core_qml)} ui/preview + {len(shell_qml)} shell, 0 violations)."
    )

    qmllint = find_qt_tool("pyside6-qmllint", "pyside6-qmllint.exe", "qmllint", "qmllint6")
    if not qmllint:
        print("WARNING: qmllint not found; lint step skipped.", file=sys.stderr)
        return 0

    lint_targets = list(core_qml)
    has_quickshell = shutil.which("quickshell") is not None or shutil.which("qs") is not None
    if has_quickshell and shell_qml:
        lint_targets.extend(shell_qml)

    cmd = [qmllint, "-I", str(REPO_ROOT), *[str(p) for p in lint_targets]]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.stdout.strip():
        print(res.stdout.strip())
    if res.stderr.strip():
        print(res.stderr.strip(), file=sys.stderr)
    if res.returncode != 0:
        print(f"ERROR: qmllint exited with code {res.returncode}", file=sys.stderr)
        return res.returncode

    print(f"qmllint PASS ({qmllint}, {len(lint_targets)} files, 0 errors).")

    if shell_qml and not has_quickshell:
        qmlformat = find_qt_tool("pyside6-qmlformat", "pyside6-qmlformat.exe", "qmlformat", "qmlformat6")
        if qmlformat:
            fmt_cmd = [qmlformat, "--dry-run", *[str(p) for p in shell_qml]]
            fmt_res = subprocess.run(fmt_cmd, capture_output=True, text=True)
            if fmt_res.returncode != 0:
                if fmt_res.stdout.strip():
                    print(fmt_res.stdout.strip())
                if fmt_res.stderr.strip():
                    print(fmt_res.stderr.strip(), file=sys.stderr)
                return fmt_res.returncode
            print(f"QML syntax PASS ({qmlformat} --dry-run, {len(shell_qml)} shell/ files, 0 syntax errors).")
        print("NOTE: shell/ Quickshell-module type & runtime verification: NOT RUN — requires CachyOS.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
