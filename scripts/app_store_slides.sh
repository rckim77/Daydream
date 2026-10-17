#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="${APP_STORE_SLIDES_TOOL_ROOT:-$HOME/.codex/worktrees/caption-position/app-store-slides-tool}"
PYTHON="${APP_STORE_SLIDES_PYTHON:-$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode_27.1RC.app/Contents/Developer}"

action="${1:-render}"
if [[ "$#" -gt 0 ]]; then shift; fi
device=all
args=()
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --device)
      [[ "$#" -ge 2 ]] || { echo '--device requires iphone, ipad, or all' >&2; exit 1; }
      device="$2"; shift 2 ;;
    *) args+=("$1"); shift ;;
  esac
done
case "$device" in all|iphone|ipad) ;; *) echo 'Device must be iphone, ipad, or all' >&2; exit 1 ;; esac

case "$action" in
  editor)
    [[ "$device" != all ]] || device=iphone
    exec "$TOOL/Scripts/editor.sh" \
      --config-dir "$REPO/app-store-slides/configs" \
      --slides-root "$HOME/Desktop/Screenshots/DaydreamAppStore" \
      --version v5.1.0 --device "$device" --locale en_US --no-render --port 4325 \
      ${args[@]+"${args[@]}"}
    ;;
  render)
    devices=(iphone ipad)
    [[ "$device" == all ]] || devices=("$device")
    for selected in "${devices[@]}"; do
      config="$REPO/app-store-slides/configs/$selected-en_US.json"
      "$TOOL/Scripts/render.sh" --config "$config" --device "$selected" --locale en_US ${args[@]+"${args[@]}"}
      # The caption-position renderer exports opaque RGBA. Strip only that alpha channel.
      if [[ " $* ${args[*]-} " != *" --validate-only "* ]]; then
        "$PYTHON" - "$config" ${args[@]+"${args[@]}"} <<'PY'
import argparse
import json
from pathlib import Path
import sys
from PIL import Image

config = json.loads(Path(sys.argv[1]).read_text())
parser = argparse.ArgumentParser(add_help=False)
parser.add_argument('--version')
parser.add_argument('--output')
parser.add_argument('--slide')
options, _ = parser.parse_known_args(sys.argv[2:])
for device in config['devices']:
    folder = Path(options.output or config['outputRoot']) / (options.version or config['version']) / device / config['defaultLocale']
    for path in folder.glob('*.png'):
        if options.slide and path.stem != options.slide:
            continue
        with Image.open(path) as image:
            if 'A' not in image.getbands():
                continue
            if image.getchannel('A').getextrema() != (255, 255):
                raise ValueError(f'Unexpected transparent slide: {path}')
            image.convert('RGB').save(path, icc_profile=image.info.get('icc_profile'))
    print(f'Opaque RGB slides ready: {folder}')
PY
      fi
    done
    ;;
  *) echo 'Usage: scripts/app_store_slides.sh render|editor [--device iphone|ipad|all] [tool options]' >&2; exit 1 ;;
esac
