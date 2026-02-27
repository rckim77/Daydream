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
- Before large edits, inspect related files for existing patterns.
- After edits, run at least a project build; report failures with exact command/output summary.
- If you cannot run validation locally, state that clearly and list unverified paths.
