#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="${APP_STORE_SLIDES_TOOL_ROOT:-$HOME/Desktop/Development/app-store-slides-tool}"
PYTHON="${APP_STORE_SLIDES_PYTHON:-$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode_27.1.app/Contents/Developer}"
[[ -f "$TOOL/Scripts/render.sh" ]] || { echo "Missing slide renderer in $TOOL" >&2; exit 1; }
[[ -x "$PYTHON" ]] || { echo 'Set APP_STORE_SLIDES_PYTHON to a Python with Pillow installed.' >&2; exit 1; }
if [[ "$#" -eq 0 ]]; then set -- render; fi
export APP_STORE_SLIDES_TOOL_ROOT="$TOOL"
exec "$PYTHON" "$REPO/scripts/app_store_slides.py" "$@"
