# Daydream App Store slides

The editable App Store Slides configs target 5.2.0 with three slides each for iPhone and landscape iPad: Explore cities, Browse top sights, and Dark mode. They use the supplied 5.2.0 inputs and retain the Picasso captions, yellow background, rounded white font, and existing device frames. The AI-powered reviews slide has been removed from both active configs.

## Locations

- Original Picasso project: `/Users/raykim/Desktop/Development/DaydreamAssets/Daydream.pco`
- Editable configs: [iPhone](configs/iphone-en_US.json) and [iPad](configs/ipad-en_US.json)
- Active screenshot inputs: `/Users/raykim/Desktop/Screenshots/DaydreamAppStore/_inputs/v5.2.0/<device>/en_US/`
- Active rendered slides: `/Users/raykim/Desktop/Screenshots/DaydreamAppStore/v5.2.0/<device>/en_US/`
- 5.2.0 screenshot mapping and SHA-256 hashes: [v5.2.0-inputs.json](v5.2.0-inputs.json)
- Previous four-slide 5.2.0 templates and config snapshots: `/Users/raykim/Desktop/Screenshots/DaydreamAppStore/_comparison/v5.2.0-four-slide-templates/`
- Preserved 5.1.0 inputs: `/Users/raykim/Desktop/Screenshots/DaydreamAppStore/_inputs/<device>/en_US/`
- Preserved 5.1.0 slides: `/Users/raykim/Desktop/Screenshots/DaydreamAppStore/v5.1.0/<device>/en_US/`
- Preserved 5.1.0 config snapshots: `/Users/raykim/Desktop/Screenshots/DaydreamAppStore/v5.1.0/_configs/`
- Source mapping and original SHA-256 hashes: [sources.json](sources.json)
- 5.1.0 iPhone screenshot mapping and hashes: [iphone-inputs.json](iphone-inputs.json). The previous iPhone inputs, slides, config, and preview are preserved under `_comparison/iphone-before-refresh/` in the local slide output folder.
- 5.1.0 iPad screenshot mapping and hashes: [ipad-inputs.json](ipad-inputs.json). The previous iPad inputs, slides, config, and preview are preserved under `_comparison/ipad-before-refresh/`. These are historical records; current input provenance is in `v5.2.0-inputs.json`.

iPhone exports `01-explore-cities.png`, `02-browse-top-sights.png`, and `03-dark-mode.png`, in that order. iPad exports `01-explore-cities.png`, `02-dark-mode.png`, and `03-browse-top-sights.png`, in that order. The iPhone captions alternate top/bottom/top; iPad Explore and Browse are above the device, while Dark mode is below on two lines, matching the iPhone caption. The original input filenames are preserved: iPad Browse uses `03-browse-top-sights.png`, and Dark mode uses `04-dark-mode.png`. The iPad Browse wording follows the supplied reference rather than the older “Explore top sights” string stored in Picasso.

## Set up local inputs

From this repo:

```sh
python3 scripts/setup_app_store_slides.py
```

This copies the eight original captures and existing local Apple frame resources to the Screenshots folder, then seeds the active release's input folders from the baseline. Existing inputs are preserved, including screenshots replaced later. The Picasso originals remain unchanged. Raw Apple frames and their license stay outside Git under `_assets/`.

The workflow uses the same App Store Slides checkout as Sudoku: `~/.codex/worktrees/caption-position/app-store-slides-tool`. It supplies named fonts, bottom captions, and device-specific placement. The main tool checkout currently lacks those options. Set `APP_STORE_SLIDES_TOOL_ROOT` to another checkout only when it supports this config schema. No shared tool source was changed for this migration.

## Render and edit

```sh
# Validate both configs and source files
scripts/app_store_slides.sh render --validate-only

# Render all six slides
scripts/app_store_slides.sh render

# Render one updated screenshot
scripts/app_store_slides.sh render --device iphone --slide 01-explore-cities

# Open the editor server; switch between iPhone and iPad inside the editor
scripts/app_store_slides.sh editor
```

Editor: <http://127.0.0.1:4325/?device=iphone&version=v5.2.0&locale=en_US>. The editor saves directly to the tracked JSON configs. Run the render command after editing to produce final opaque RGB PNGs; this renderer's direct editor exports retain an opaque alpha channel.

The render helper uses Xcode 27.1 and the existing bundled Python/Pillow runtime. Override `DEVELOPER_DIR` or `APP_STORE_SLIDES_PYTHON` if those installations move. `--device ipad` limits rendering to iPad. To start a new release, update `version` in both JSON configs and the editor command's `--version` argument; `--version` can also be passed when rendering an output-only preview.

## Replace screenshots

Replace a PNG in `_inputs/v5.2.0/iphone/en_US/` or `_inputs/v5.2.0/ipad/en_US/` while preserving its filename, then render that device or slide. Use portrait iPhone captures near the original 1206×2622 aspect ratio and landscape iPad captures near 2752×2064. The renderer rejects mismatched aspect ratios rather than stretching the content.

The filenames describe each input; the iPad input numbering differs from the sequential output IDs. Update `v5.2.0-inputs.json` when refreshing an input. `sources.json` records the original migration baseline and should remain available for comparison.

Outputs are 1290×2796 for iPhone and 2732×2048 for iPad. The rounded white font and yellow layout follow the supplied references. The background config compensates for the renderer's calibrated RGB conversion to match the reference's sRGB yellow, approximately `#FFC100`. Current Apple iPhone 17 Pro Deep Blue and iPad Pro M4 Space Gray frames replace Picasso's iPhone 16 Pro Black Titanium frame; bezel details and Picasso's subtle text shadow differ slightly.

```sh
asc screenshots validate --path /Users/raykim/Desktop/Screenshots/DaydreamAppStore/v5.2.0/iphone/en_US --device-type IPHONE_67 --output table
asc screenshots validate --path /Users/raykim/Desktop/Screenshots/DaydreamAppStore/v5.2.0/ipad/en_US --device-type IPAD_PRO_3GEN_129 --output table
```

Rendering and editing are local. Screenshot upload is a separate action after the app captures are refreshed and reviewed.

The approved 5.2.0 slides were uploaded on October 20, 2026 to the `en-US` localization of App Store version `6f089405-943f-4a10-8709-258292655165`. Both sets contain exactly three screenshots: iPhone Explore → Browse → Dark mode, and iPad Explore → Dark mode → Browse. All six assets reached `COMPLETE`; their remote order and MD5 checksums matched the local exports. The version remained `PREPARE_FOR_SUBMISSION`. Local verification details are saved in the ignored `build/AppStoreSlides/v5.2.0-upload-verification.json`.

The iPad slides were regenerated and replaced later that day from updated user inputs, preserving their order and two-line Dark mode caption. All three replacement assets reached `COMPLETE`, with order and MD5 checksums verified. The iPhone input files, exports, preview, and config retained their contents and modification times; the remote iPhone screenshot set and asset IDs were unchanged.
