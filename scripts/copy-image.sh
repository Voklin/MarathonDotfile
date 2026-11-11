#!/usr/bin/env bash
# MARATHON Tactical — Safe PNG Clipboard Copy Helper (no sh -c)

set -euo pipefail

if [[ $# -lt 1 || -z "${1:-}" ]]; then
    echo "Usage: copy-image.sh <png-path>" >&2
    exit 2
fi

IMG_PATH="$1"
if [[ ! -f "$IMG_PATH" ]]; then
    echo "ERROR: Screenshot file not found: $IMG_PATH" >&2
    exit 1
fi

if ! command -v wl-copy >/dev/null 2>&1; then
    echo "ERROR: wl-copy not found in PATH" >&2
    exit 1
fi

wl-copy --type image/png < "$IMG_PATH"
