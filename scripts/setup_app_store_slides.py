#!/usr/bin/env python3
"""Seed local slide inputs without overwriting screenshots replaced in the editor."""

import hashlib
import json
import os
from pathlib import Path
import shutil


repo = Path(__file__).resolve().parents[1]
manifest = json.loads((repo / "app-store-slides/sources.json").read_text())
project = Path(manifest["sourceProject"])
output = Path.home() / "Desktop/Screenshots/DaydreamAppStore"
tool = Path(os.environ.get("APP_STORE_SLIDES_TOOL_ROOT", str(Path.home() / ".codex/worktrees/caption-position/app-store-slides-tool")))

for entry in manifest["inputs"]:
    source = project / entry["source"]
    destination = Path(entry["destination"])
    if destination.exists():
        print(f"Preserving existing input: {destination.name} ({entry['device']})")
        continue
    if hashlib.sha256(source.read_bytes()).hexdigest() != entry["sha256"]:
        raise SystemExit(f"Original Picasso capture changed: {source}")
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)

for name in [
    "iPhone 17 Pro - Deep Blue - Portrait.png",
    "iPad Pro 13 - M4 - Space Gray - Landscape.png",
    "Apple-Design-Resources-License.rtf",
]:
    source = tool / "Assets/Frames" / name
    if name.endswith(".rtf") and not source.exists():
        source = repo.parent / "app-store-slides-tool/Assets/Frames" / name
    destination = output / "_assets" / name
    if not destination.exists():
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)

print(f"Local screenshots and licensed frames ready: {output}")
