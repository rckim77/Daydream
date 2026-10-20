# Daydream App Store slides

## Authoring and outputs

- `configs/`: canonical editable JSON (captions, placement, colors, frames, and source selection).
- `sources.json`: current input mapping, dimensions, hashes, and capture provenance notes.
- `project.json`: current screenshot set and editor port.
- `toolchain.json`: reviewed source hashes for the shared renderer/editor in `~/Desktop/Development/app-store-slides-tool`.
- Generated exports: `~/Desktop/Screenshots/DaydreamAppStore/v5.2.0/<device>/<locale>/`.

Curated PNG inputs are tracked in Git under `inputs/<device>/<locale>/` alongside the configs. The old Screenshots input path is a compatibility link to these files.

Licensed Apple frame PNGs and licenses stay local under `~/Desktop/Screenshots/DaydreamAppStore/_assets/`; do not add them to Git. Preserve these local assets when cloning or moving the project. Re-import missing frames from Apple Design Resources with the shared tool helpers. Config paths support `~` and paths relative to the config file.

## Commands

From the app repository:

```sh
scripts/app_store_slides.sh validate
scripts/app_store_slides.sh render
scripts/app_store_slides.sh render --device iphone --locale en_US
scripts/app_store_slides.sh editor
# After deliberately replacing an input, review it and refresh the manifest:
scripts/app_store_slides.sh sources
```

`render --validate-only` also validates without rendering. `--slide ID`, `--version VERSION`, and `--output PATH` support focused renders and disposable previews. Rendering exports opaque RGB PNGs. Editor writes go directly to canonical configs; run `render` after editing for final exports. `normalize` strips only fully opaque alpha from existing exports without changing RGB pixels. This helper never captures, resets, or modifies a simulator.

Use Xcode 27.1 by default. Override `APP_STORE_SLIDES_TOOL_ROOT` only with a checkout matching the content pins; override `APP_STORE_SLIDES_PYTHON` with a Python containing Pillow if the bundled runtime moves. Tool updates should be reviewed and validated before changing the pin. The current pin includes the shared tool integration prepared alongside this organization; that companion tool change must also be retained when setting up another machine.

## Screenshot history and releases

The six 5.2.0 PNGs use the latest user-supplied screenshots. The original migration mappings are historical records under `history/`; their retired Picasso paths are not runtime dependencies. `python3 scripts/setup_app_store_slides.py` now verifies the current independent sources. Existing 5.1.0 outputs/comparisons remain outside Git.

Screenshot-set versions describe the assets, independently of the app release version. Record an app release reusing a set in release metadata rather than copying images or silently relabeling captures. Keep one current capture run and one useful comparison; do not delete historical evidence without approval. Exports, capture runs, temporary previews, licensed frame sources, and restore archives stay outside Git. Rendering does not authorize upload.
