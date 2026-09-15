#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_ROOT="${APP_VISUAL_QA_TOOL_ROOT:-$(git -C "$PROJECT_ROOT" rev-parse --path-format=absolute --git-common-dir)/../../app-visual-qa-tool}"
if [[ ! -f "$TOOL_ROOT/scripts/app_visual_qa.py" ]]; then
  echo "Set APP_VISUAL_QA_TOOL_ROOT to your app-visual-qa-tool checkout. See visual-qa/README.md." >&2
  exit 1
fi
exec python3 "$TOOL_ROOT/scripts/app_visual_qa.py" --config "$PROJECT_ROOT/visual-qa/config.json" "$@"
