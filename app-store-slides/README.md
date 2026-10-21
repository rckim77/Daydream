# App Store slides

Each `vX.Y.Z/` folder contains its tracked `configs/`, screenshot `inputs/`, and
`sources.json` (input hashes). The highest numbered version is selected by default.

Exports stay in `~/Desktop/Screenshots/DaydreamAppStore/<version>/`.
Device frames and licenses stay local in that root's `_assets/`; neither is committed.

From the Daydream repo:

```sh
scripts/app_store_slides.sh validate
scripts/app_store_slides.sh render
scripts/app_store_slides.sh editor
```

Use `--version v5.2.0` to select a set. After replacing an input, run `sources`.
For a new set, copy a version folder, update its configs' version, then run `sources`
and `validate`. The editor uses port 4325 (`--port` overrides it).

Requires the shared `~/Desktop/Development/app-store-slides-tool` checkout and local
Apple frames. Rendering does not upload anything.
