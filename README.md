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

Map place details use Google's horizontal `PlaceDetailsCompactView` with standard content. The card uses its content height, sits above the bottom safe area, and keeps map attribution clear. Custom `Review` cards and the raw review fetch are no longer used.

Nearby sight/eatery cards use Google's compact Place Details component for photos, names, prices and attribution, with a separate **View map** button for Daydream's map/reviews. The component owns its photo loading and cache lifetime. Cards use explicit supported widths and grow for accessibility text. Photo loading is owned by the Places UI Kit components; the app no longer fetches raw city images.

All discovery cards on iPhone and iPad use the advanced vertical compact component with media-only content, no action buttons, 20-point corners, and Daydream's city-name overlay. They keep the component's natural height and use 6-point spacing on iPhone and 20-point spacing on iPad so attribution stays visible. Each component receives its current column's explicit width, while the grid measures and places it without imposing a row height; this keeps cached SDK content within its column after rotation. Forcing a shorter height hides the attribution on iPad; the horizontal variant uses a small thumbnail instead of a full-width photo. The old custom city-card views and raw photo-loading helpers have been removed. Opening a city card fetches only place data and reuses `PlacesCache`.

Discovery shows eight city cards in two columns on every device and in every orientation, including accessibility text sizes. Cards fill their available column width; their minimum loading height scales down with narrow columns so the SDK cards can retain their natural height. Compact SDK spacing removes the extra gap above the attribution row; a three-point bottom inset balances the visible text within the footer. The default attribution text and info control are preserved, with the border drawn around the complete card.

For reviews, the project owning the existing Places key needs billing and **Places UI Kit API** (`placewidgets.googleapis.com`). Keep **Places API (New)** (`places.googleapis.com`) for the app's other place-data calls. If the key has API restrictions, inspect whether both required APIs are allowed; retain the iOS application restriction for `com.rckim.Daydream`. Follow Google's [UI Kit setup](https://developers.google.com/maps/documentation/places/ios-sdk/places-ui-kit-get-started) and [key restriction guidance](https://developers.google.com/maps/api-security-best-practices). Configuration must be checked by the project owner; an opaque authentication error does not identify the missing setting. No Cloud configuration is applied by this app or its tests.


For App Store Connect, run `ASC_BYPASS_KEYCHAIN=1 asc ...` from the repo root. Local `.asc/config.json` is ignored by Git and selects Daydream (`1366747814`) using the existing shared API key outside the repo. Repos without a local configuration use `~/.asc/config.json`; specify their app ID explicitly. API keys and credential configurations must stay untracked.

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

App Store marketing slides use the [App Store Slides workflow](app-store-slides/README.md), with editable iPhone and landscape iPad configs and replaceable local screenshot inputs. Run `scripts/app_store_slides.sh render` to generate slides or `scripts/app_store_slides.sh editor` to edit them.

The opt-in [Visual QA suite](visual-qa/README.md) uses the shared private `app-visual-qa-tool` with required base and additional configurations: four iOS 27 main-screen captures for quick checks, then six additional captures covering iOS 26 and landscape iPad mini. Only the SE is dark. Its dedicated `VisualQA` scheme stays separate from regular unit tests.

## Adaptive layouts

Discovery always uses two columns. City details place the overview and map beside sights/eateries when the available space is wider than tall and at least 760 points wide; portrait layouts stack the map above the carousels. City details use a single column at accessibility text sizes. The overview width stays capped for readability on larger windows, while landscape carousels extend to the window’s trailing edge. The same view instances remain in place during resizing to preserve photos, the map camera, and streamed summaries. Regular-height, two-column landscape layouts stretch the map and use wider photo cards. Native photo components keep their intrinsic height so their content and attribution remain visible. Cards retain a minimum height of 220 points; shorter windows scroll vertically instead of compressing them. The city backdrop fills all safe areas with a gradient of the country’s dominant flag colors, softened by adaptive material. Palettes live in the on-device `CountryFlagPalette` table keyed by country code, cover all seeded countries, and use a neutral fallback when a country is missing or unsupported. Search, card, random-city, and current-location requests include address components for the country code; no extra palette or photo request is needed.

Map details fill their presentation edge to edge, with reviews and map content kept clear of local safe areas. Close, map appearance, and Google Maps information use native toolbar items that adapt to iPhone Duo's vertical toolbar. Landscape maps use a centered form sheet on iOS 27 and the system form sheet on iOS 26. iPhone supports both landscape orientations. Nearby results have a consistent limit of 12 so folding does not replace the data set or trigger a new request.

Discovery and city details use system toolbar items for search, random city, current location, and help/home. Search is a native icon-only button on every supported release. On iOS 27.1, the toolbar adapts to iPhone Duo's vertical layout.

The Duo-specific adapters require the Xcode 27.1 SDK. Runtime availability checks retain the horizontal fallback on iOS 26 and iOS 27.0.

For iPhone Duo validation, exercise home, city detail, and an open map/reviews sheet while folding and unfolding, then rotate and repeat. Also check compact iPhone and large text. Reuse existing simulators and preserve their app data; static screenshots alone do not verify a fold transition.
