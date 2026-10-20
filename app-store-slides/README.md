# Daydream App Store slides

Each version folder contains one complete screenshot set:

```text
app-store-slides/
  README.md
  project.json
  toolchain.json
  v5.2.0/
    configs/                 # Editable captions, layout, colors, and input selection
    inputs/<device>/<locale>/ # Original app screenshot PNGs
    sources.json             # Input paths, dimensions, and SHA-256 hashes
```

The README is a guide, not a runtime dependency. `project.json` selects the active
screenshot-set version and editor port. `toolchain.json` checks the shared renderer
and editor source files against reviewed hashes. Those two settings apply across
versions and stay at the root.

**Checked into Git:** versioned inputs, configs, source manifests, root settings,
and the scripts/documentation. The separate history folder was removed; Git retains
the previous records. The current set contains six supplied 5.2.0 screenshots.

**Local only:** final exports, previews, capture/comparison runs, and licensed Apple
device frames. Exports stay under
`~/Desktop/Screenshots/DaydreamAppStore/<version>/<device>/<locale>/`; frames and
licenses stay in that root's `_assets/`. Re-import missing frames with the shared
tool's Apple Design Resources import helpers. No Picasso document is required.

From the app repository:

```sh
scripts/app_store_slides.sh validate
scripts/app_store_slides.sh render
scripts/app_store_slides.sh editor
scripts/app_store_slides.sh render --version v5.2.0 --device iphone --locale en_US
# After deliberately replacing an input and reviewing it:
scripts/app_store_slides.sh sources --version v5.2.0
```

`--version` selects the source version folder; omitting it uses `project.json`.
`--slide ID` limits a render and `--output PATH` writes a disposable preview.
The editor saves into the selected version's configs. Run `render` afterward for
opaque RGB exports. `render --validate-only` checks without generating images.

For a new screenshot set, copy the previous version folder, update `version` in
its configs, replace the intended inputs, run `sources --version <new-version>`,
and validate before selecting it in `project.json`. Leave older version folders
unchanged. A later app release may reuse an existing screenshot set.

The shared renderer lives at `~/Desktop/Development/app-store-slides-tool`.
Use Xcode 27.1 by default; overrides are `APP_STORE_SLIDES_TOOL_ROOT` and
`APP_STORE_SLIDES_PYTHON` (a Python with Pillow). The pinned shared renderer
integration still needs its separate tool-repo commit when setting up another
machine. This workflow never captures or modifies a simulator, and rendering does
not authorize upload.
