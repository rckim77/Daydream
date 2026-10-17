# Daydream Visual QA

Use the private [app-visual-qa-tool](https://github.com/rckim77/app-visual-qa-tool) checkout beside the main app checkout, or set `APP_VISUAL_QA_TOOL_ROOT`. Worktree wrappers resolve sibling placement from Git's common directory.

Validated with tool revision `fdcd1f7`.

```bash
export DEVELOPER_DIR=/Applications/Xcode_27RC.app/Contents/Developer
export VISUAL_QA_OUTPUT_ROOT="$HOME/Desktop/Screenshots/DaydreamVisualQA"
bash scripts/capture_visual_qa_snapshots.sh --suite base
bash scripts/capture_visual_qa_snapshots.sh --suite additional
```

Omitting `--suite` selects base. Open `$VISUAL_QA_OUTPUT_ROOT/base/index.html` and `$VISUAL_QA_OUTPUT_ROOT/additional/index.html`. The reports stay separate, so additional capture preserves the base screenshots. Add `--dry-run` to either command to inspect coverage without capture; `--ios 27` narrows the selected suite to that generation.

The shared base devices are iPhone SE (3rd generation), iPhone 17 Pro Max, iPad Pro 11-inch (M5) portrait, and iPad Pro 13-inch (M5) landscape. Only the SE is dark; all other devices are light. Additional coverage adds an iPad mini (A17 Pro) in landscape on both OS versions, without repeating base cases.

Base captures the main screen in English on iOS 27: **4 screenshots**. Additional captures English on all five devices on iOS 26 and the landscape mini on iOS 27: **6 additional screenshots**, 10 combined.

Both configurations are required in `config.json`. Base device definitions live in the shared tool. Additional OS generations, languages by OS, and extra devices are customized here.

Capture runs serially. For a focused check, set `VISUAL_QA_DEVICE_PROFILES='configured-device-id:Dedicated Simulator Name'`. Capture reinstalls the app by default; use dedicated simulators to preserve personal app state. `--suite base --clean` deletes only base artifacts; `--suite additional --refresh-dashboard` rebuilds the additional report without capturing.

The dedicated `VisualQA` scheme and `visualqa.xctestplan` keep captures separate from regular unit tests. The capture test supplies a fixed city order through an opt-in Debug launch environment. Tips are not reset. Images use the real Places/cache path, and the test waits for all five photos. Provide the existing ignored `Daydream/Shared/apiKeys.plist` locally. City detail and map screens are outside this suite.

The opt-in `PlacesRegressionUITests/testPlacesRegression` also exercises empty autocomplete results, city selection, nearby cards, map/reviews, rotation, appearance, and random city navigation. It reads `/tmp/daydream-places-qa-<SIMULATOR_UDID>.json` with `outputDirectory` (absolute path), `expiresAt` (future Unix timestamp), `landscape` and `largeText` (booleans). Optional `locationMode` is `denied` or `allowed`; prepare that simulator's app permission and simulated location before running it. No API keys are supplied by this configuration. Screenshots and hierarchy dumps go to `outputDirectory`.

```bash
xcodebuild test -project Daydream.xcodeproj -scheme VisualQA -testPlan visualqa \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>' \
  -only-testing:DaydreamUITests/PlacesRegressionUITests \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO
```

`PlacesRequestStressUITests/testRepeatedCityLoading` reproduces initial city loading across repeated launches. It is also opt-in: provide `/tmp/daydream-places-stress-<SIMULATOR_UDID>.json` with `outputDirectory`, `expiresAt`, `iterations` (1–10), and `largeText`. Each launch waits for six city photos and writes a screenshot; no live requests run without an unexpired local configuration.

The Places regression can capture additional states using optional booleans: `simulateReviewFailure` (fail the first map details load locally, then retry the live request), `forceReviewFallback` (display the real individual reviews instead of the available AI summary), `skipAutocomplete`, `mapOnly`, and `allRotations`. The first two are Debug-only presentation hooks; they do not change network/cloud settings or release behavior. The suite asserts a visible software keyboard, checks the search field above the rotated keyboard, and scrolls accessibility details to the final Maps action.

For an opt-in UI Kit authentication comparison, provide `/tmp/daydream-places-auth-probe-<SIMULATOR_UDID>.json` with `outputDirectory` and `expiresAt`, then run `-only-testing:DaydreamTests/PlacesUIKitAuthenticationTests` with the `Daydream` scheme / `unittests` plan. It registers the existing Places key, performs a raw Place Details control and mounts the supported UI Kit component with the same place ID. It writes sanitized status/domain/code metadata and fails if UI Kit authentication fails. The test skips without a current local configuration; it does not supply keys, create credentials or change any cloud setting.

Stress configuration may also set `enableZombies: true` for a local lifetime diagnostic. Zombies change object lifetimes, so a passing run is not evidence of a production fix. Leave this off for the normal before/after stress comparison.
