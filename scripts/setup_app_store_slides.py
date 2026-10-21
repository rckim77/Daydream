#!/usr/bin/env python3
"""Verify the repository-owned PNG inputs; no retired document format is needed."""
from pathlib import Path
import subprocess

repo = Path(__file__).resolve().parents[1]
subprocess.run([str(repo / "scripts/app_store_slides.sh"), "validate"], check=True)
