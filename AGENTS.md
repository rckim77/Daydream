# AGENTS.md

This file guides coding agents working in this repository.

## Project Summary
- App: **Daydream** (iOS)
- Purpose: explore cities worldwide, view city details, nearby sights/eateries, and map/reviews.
- Stack: Swift, SwiftUI + UIKit interoperability, Google Places SDK (Swift), Google Maps SDK, SnapKit, TipKit.
- Xcode: `26.1.0` (per `README.md`).
- Minimum deployment target in project: iOS 18.0 for main app target.

## Repository Map
- `Daydream/` app source
- `Daydream/Cities/` discovery/home UI (`CitiesView`, cards, search toolbar, feedback)
- `Daydream/CityDetail/` city detail UI, map card, place carousels, map reviews
- `Daydream/Networking/` API namespace and Google Places data fetching
- `Daydream/Models/` domain models (`RandomCity`, `CityRoute`, etc.)
- `Daydream/Shared/` reusable UI, extensions, caches, location manager, JSON data
- `Daydream/Shared/randomCitiesJSON.json` seed city dataset used for random city flows
- `Daydream.xcodeproj/` project/scheme/package resolution

## Local Setup Requirements
1. Open `Daydream.xcodeproj` in Xcode 26.1.0+ to resolve Swift packages.
2. Provide local API keys file at:
   - `Daydream/apiKeys.plist`
3. `apiKeys.plist` must decode to:
   - `placesNewAPI` (String)
   - `googleAPI` (String)
4. Ensure location permission strings remain present in `Info.plist` for location-based features.

If keys are missing, app launch continues but Places/Maps calls will fail or return no useful data.

## Build, Run, Validate
Use these from repo root:

```bash
xcodebuild -project Daydream.xcodeproj -scheme Daydream -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

There is currently no configured test target in the shared scheme (`Testables` is empty). For validation, prefer build + focused manual checks.

Optional lint (if installed locally):

```bash
swiftlint
```

Lint config: `.swiftlint.yml` (notably relaxed for identifier length, nesting, body length, and trailing whitespace).

## Architecture Notes
- App launches through `AppDelegate`/`SceneDelegate` (UIKit lifecycle), with `SearchViewController` embedding SwiftUI (`UIHostingController`).
- `CurrentLocationManager` is an `@Observable` object injected into SwiftUI environment.
- Network/data access is namespaced under `API.PlaceSearch`.
- Heavy use of async flows with `Task {}` and `async/await`.
- Caching is already implemented for Places and images (`PlacesCache`, `ImageCache`) and should be reused rather than bypassed.
- Mixed UI stack is intentional:
  - SwiftUI for most screens
  - UIKit + Google Maps (`MapViewController`) where SDK integration is easier

## Coding Conventions To Follow
- Preserve existing file organization; place new code in the nearest existing feature folder.
- Keep `API` namespace pattern for new network/data calls (`API+Feature.swift` style extensions).
- Prefer existing shared utilities/extensions over duplicating logic.
- Maintain iOS availability fallbacks where used (for example iOS 26 button style branches).
- Avoid introducing new third-party dependencies unless explicitly requested.
- Keep changes scoped; do not refactor unrelated modules in the same patch.

## Safety and Secrets
- Never commit real API keys or secrets.
- Do not modify `GoogleService-Info.plist` or signing/bundle settings unless requested.
- Avoid changing `Info.plist` permission text unless the feature requires it.

## Manual Regression Checklist (when UI/behavior changes)
1. Launch app to `CitiesView` without crash.
2. Search a city and open `CityDetailView`.
3. Verify Top Sights / Top Eateries load.
4. Open map detail sheet and confirm marker/reviews render.
5. Trigger current-location flow (with simulator location enabled).
6. Verify random city flow still navigates and renders image background.

## Agent Workflow Expectations
- If you cannot run validation locally, state that clearly and list unverified paths.
- After adding or changing code, build/compile the app when feasible and proactively fix any compiler issues. If it's a trivial code change (e.g., change SF symbol icon) or a change you have extremely high confidence that it will compile, you can skip building.
- Prefer explicit build commands for reliability (e.g., `xcodebuild -project Daydream.xcodeproj -scheme Daydream -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1'`).
- Default verification settings: use project `Daydream.xcodeproj`, scheme `Daydream`, and simulator destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1` unless the prompt says otherwise.
- Preferred commands:
  - Build on simulator: `xcodebuild -project Daydream.xcodeproj -scheme Daydream -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1' build`
  - Run full tests: `xcodebuild -project Daydream.xcodeproj -scheme Daydream -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1' test`
  - Run one test suite: `xcodebuild -project Daydream.xcodeproj -scheme Daydream -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1' -only-testing:DaydreamTests/ExampleViewStateTests test`
  - Discover targets/schemes quickly: `xcodebuild -list -project Daydream.xcodeproj`
- Device commands (when requested):
  - Build for Ray K's device: `xcodebuild -project Daydream.xcodeproj -scheme Daydream -destination 'id=00008150-000E2CA1110A401C' build`
  - Install/launch with `xcrun devicectl` using bundle identifier `com.daydream.app` after a successful device build.
- TestFlight/App Store Connect upload guidance:
  - Always use scheme `Daydream`, configuration `Release`, and destination `generic/platform=iOS` (Any iOS Device, arm64) for archives intended for upload.
  - Increment build version (`CURRENT_PROJECT_VERSION` / `CFBundleVersion`) before upload. Only bump marketing version (`MARKETING_VERSION` / `CFBundleShortVersionString`) when explicitly needed for release planning.
  - Preferred archive command: `xcodebuild -project Daydream.xcodeproj -scheme Daydream -configuration Release -destination 'generic/platform=iOS' -archivePath build/AppStore/Daydream.xcarchive archive`
  - Preferred upload command: `xcodebuild -exportArchive -archivePath build/AppStore/Daydream.xcarchive -exportPath build/AppStore -exportOptionsPlist build/AppStore/ExportOptions.plist -allowProvisioningUpdates`
  - Export options should use `method=app-store-connect` and `destination=upload`.
  - When asked to upload a new TestFlight build, after a successful upload also commit the version/build number change (and related release metadata changes, if any) unless explicitly told not to.
  - After committing that TestFlight version/build bump, push the branch so the repo reflects the uploaded build metadata.
- When removing files or refactoring structure, run a quick build immediately to catch missing references.
- Keep the Xcode project folder-based (no groups); use filesystem-synchronized folders only.
- For device builds, use Ray K’s iPhone device ID `00008150-000E2CA1110A401C` for `xcodebuild -destination` and `xcrun devicectl` install/launch when needed.
- If I ask to build and run on device, do not build for the simulator first. Make it as fast as possible.
- When adding unit tests, prefer Swift Testing (`import Testing`, `@Test`, `#expect`) over XCTest where possible.
- When code changes are covered by existing unit tests, run the relevant unit tests before finishing.
- For debug-only features (UI/actions hidden in release distribution builds), do not add unit tests.
- For new SwiftUI work, do not encapsulate child UI pieces as private `var` view properties; inline child UI composition in the main `body` unless a reusable standalone view type is needed.
- Prefer one main SwiftUI view type (`struct ...: View`) per Swift file.
- If a SwiftUI view grows beyond a manageable size and contains composable subviews, extract those subviews into separate SwiftUI files instead of keeping multiple main view types in one file.
- For SwiftUI view state objects, prefer modern Observation (`@MainActor` + `@Observable` final class) over plain structs/legacy observable patterns.
- When a SwiftUI view has a corresponding view state object (for example, `AssetDetailPageView` and `AssetDetailPageViewState`), add new view `@State` values to the view state object when that ownership model still makes sense.
- Whenever adding a new view state object, also add a corresponding `...ViewStateTests.swift` suite using Swift Testing and run that suite to verify the new tests pass before completing the task.
- Keep accessibility support practical and simple: add clear labels/identifiers for interactive UI, but avoid over-engineering fine-grained conditional label logic (for example, separate singular/plural variants) unless explicitly needed.
- For sufficiently complex code paths, add a short human-readable code comment that explains intent and flow.

## Documentation Sync
- Whenever you make feature changes that may affect documentation in this repo, quickly check markdown files to ensure they're updated as well. For example, if changing SDK versions makes the README.md information out of date, update it. Same goes for other markdown files like AGENTS.md and copilot-instructions.md. Do not check for very minor changes.