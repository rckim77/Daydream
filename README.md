# [Daydream](https://apps.apple.com/us/app/daydream-explore-cities/id1366747814)
Explore cities around the world

[Download on the App Store](https://apps.apple.com/us/app/daydream-explore-cities/id1366747814)

[Privacy Policy](https://rckim77.github.io/Daydream-Site/)

## Local Setup
Minimum deployment target: iOS 26.0.

Local verification uses Xcode 27.1 RC (`27A9275`) with the iOS 27.1 SDK. Open `Daydream.xcodeproj` to resolve Swift packages. Use `DEVELOPER_DIR=/Applications/Xcode_27.1RC.app/Contents/Developer` when multiple Xcode installations are present.

Swift package dependencies: Google Maps 11.2.0, Google Places (including GooglePlacesSwift) 11.2.0, and SnapKit 6.0.0. Google SDK versions are pinned exactly in the project; commit the shared `Package.resolved` alongside dependency updates.

Create `Daydream/Shared/apiKeys.plist` with:
- `googleAPI`
- `placesNewAPI`

These keys are required for Google Maps/Places powered features.

## Build
```bash
xcodebuild -project Daydream.xcodeproj -scheme Daydream -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0' build
```

## Tests (Swift Testing + xctestplan)
The project includes a shared test plan at `unittests.xctestplan` and a Swift Testing target `DaydreamTests`.

```bash
xcodebuild test -project Daydream.xcodeproj -scheme Daydream -testPlan unittests -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0' CODE_SIGNING_ALLOWED=NO
```

For iOS 26 compatibility, also run the plan on an available iOS 26 simulator (locally: `iPhone 17 Pro,OS=26.5`). To target the existing suite, append `-only-testing:DaydreamTests/CityDetailViewStateTests`.

## CI
CI uses the GitHub Actions `xcode-27` runner with Xcode 27.1 and an iPhone 18 Pro running iOS 27.0. Pull requests run tests on GitHub Actions via:
- `.github/workflows/pr-tests.yml`

![Simulator Screen Recording - iPhone 16 Pro - 2025-11-10 at 21 10 26](https://github.com/user-attachments/assets/09f30ccc-917e-4d54-9ffc-237525e0d656)

## Visual QA

The opt-in [Visual QA suite](visual-qa/README.md) uses the shared private `app-visual-qa-tool` with required base and additional configurations: four iOS 27 main-screen captures for quick checks, then six additional captures covering iOS 26 and landscape iPad mini. Only the SE is dark. Its dedicated `VisualQA` scheme stays separate from regular unit tests.

## Adaptive layouts

Discovery uses two columns at window widths of 640 points and above. City details place the overview and map beside sights/eateries at 760 points and above. Accessibility text sizes use a single column. Content widths are capped for readability on larger windows; the same view instances remain in place during resizing to preserve photos, the map camera, and streamed summaries.

Map sheets use Auto Layout and local safe areas on every device. iPhone supports both landscape orientations. Nearby results have a consistent limit of 12 so folding does not replace the data set or trigger a new request.

Discovery and city details use system bottom toolbar items for search, random city, current location, and help/home. On iOS 27.1, these items participate in iPhone Duo's vertical toolbar layout; Search hides its text when `toolbarVerticalEdge` is set. On earlier supported releases, Search retains its icon and text in the horizontal toolbar.

The Duo-specific adapters require the Xcode 27.1 SDK. Runtime availability checks retain the horizontal fallback on iOS 26 and iOS 27.0.

For iPhone Duo validation, exercise home, city detail, and an open map/reviews sheet while folding and unfolding, then rotate and repeat. Also check compact iPhone and large text. Reuse existing simulators and preserve their app data; static screenshots alone do not verify a fold transition.
