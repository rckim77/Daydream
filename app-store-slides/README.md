# Daydream App Store slides

The editable App Store Slides configs reproduce the four Picasso themes for iPhone and landscape iPad: Explore cities, Browse top sights, Dark mode, and AI-powered reviews. iPhone uses the four replacement captures supplied on October 15, 2026; iPad uses the four replacement captures supplied on October 16, 2026.

## Locations

- Original Picasso project: `/Users/raykim/Desktop/Development/DaydreamAssets/Daydream.pco`
- Editable configs: [iPhone](configs/iphone-en_US.json) and [iPad](configs/ipad-en_US.json)
- Screenshot inputs: `/Users/raykim/Desktop/Screenshots/DaydreamAppStore/_inputs/<device>/en_US/`
- Rendered slides: `/Users/raykim/Desktop/Screenshots/DaydreamAppStore/v5.1.0/<device>/en_US/`
- Source mapping and original SHA-256 hashes: [sources.json](sources.json)
- Current iPhone screenshot mapping and hashes: [iphone-inputs.json](iphone-inputs.json). The previous iPhone inputs, slides, config, and preview are preserved under `_comparison/iphone-before-refresh/` in the local slide output folder.
- Current iPad screenshot mapping and hashes: [ipad-inputs.json](ipad-inputs.json). The previous iPad inputs, slides, config, and preview are preserved under `_comparison/ipad-before-refresh/`. The supplied `02-ai-powered-previews-ipad.png` maps to the existing `02-ai-powered-reviews` slide; captions and layout are unchanged.

Each config keeps its device's original slide order. The iPhone captions alternate top/bottom; iPad Explore and Browse are above the device, while AI reviews and Dark mode are below. iPad Dark mode stays on one line. The iPad Browse wording follows the supplied reference rather than the older “Explore top sights” string stored in Picasso.

## Set up local inputs

From this repo:

```sh
python3 scripts/setup_app_store_slides.py
```

This copies the eight original captures and existing local Apple frame resources to the Screenshots folder. Existing inputs are preserved, including screenshots replaced later. The Picasso originals remain unchanged. Raw Apple frames and their license stay outside Git under `_assets/`.

The workflow uses the same App Store Slides checkout as Sudoku: `~/.codex/worktrees/caption-position/app-store-slides-tool`. It supplies named fonts, bottom captions, and device-specific placement. The main tool checkout currently lacks those options. Set `APP_STORE_SLIDES_TOOL_ROOT` to another checkout only when it supports this config schema. No shared tool source was changed for this migration.

## Render and edit

```sh
# Validate both configs and source files
scripts/app_store_slides.sh render --validate-only

# Render all eight slides
scripts/app_store_slides.sh render

# Render one updated screenshot
scripts/app_store_slides.sh render --device iphone --slide 01-explore-cities

# Open the editor server; switch between iPhone and iPad inside the editor
scripts/app_store_slides.sh editor
```

Editor: <http://127.0.0.1:4325/?device=iphone&version=v5.1.0&locale=en_US>. The editor saves directly to the tracked JSON configs. Run the render command after editing to produce final opaque RGB PNGs; this renderer's direct editor exports retain an opaque alpha channel.

The render helper uses Xcode 27.1 and the existing bundled Python/Pillow runtime. Override `DEVELOPER_DIR` or `APP_STORE_SLIDES_PYTHON` if those installations move. `--device ipad` limits rendering to iPad. To start a new release, update `version` in both JSON configs and the editor command's `--version` argument; `--version` can also be passed when rendering an output-only preview.

## Replace screenshots

Replace a PNG in `_inputs/iphone/en_US/` or `_inputs/ipad/en_US/` while preserving its filename, then render that device or slide. Use portrait iPhone captures near the original 1206×2622 aspect ratio and landscape iPad captures near 2752×2064. The renderer rejects mismatched aspect ratios rather than stretching the content.

The filenames describe each slide; iPad order differs from iPhone. Update the provenance when refreshing an input. `sources.json` records the original migration baseline and should remain available for comparison.

Outputs are 1290×2796 for iPhone and 2732×2048 for iPad. The rounded white font and yellow layout follow the supplied references. The background config compensates for the renderer's calibrated RGB conversion to match the reference's sRGB yellow, approximately `#FFC100`. Current Apple iPhone 17 Pro Deep Blue and iPad Pro M4 Space Gray frames replace Picasso's iPhone 16 Pro Black Titanium frame; bezel details and Picasso's subtle text shadow differ slightly.

```sh
asc screenshots validate --path /Users/raykim/Desktop/Screenshots/DaydreamAppStore/v5.1.0/iphone/en_US --device-type IPHONE_67 --output table
asc screenshots validate --path /Users/raykim/Desktop/Screenshots/DaydreamAppStore/v5.1.0/ipad/en_US --device-type IPAD_PRO_3GEN_129 --output table
```

Rendering and editing are local. Screenshot upload is a separate action after the app captures are refreshed and reviewed.
