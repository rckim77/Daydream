# AGENTS.md

This file guides coding agents working in this repository.

## Project Summary
- App: **Daydream** (iOS)
- Purpose: explore cities worldwide, view city details, nearby sights/eateries, and map/reviews.
- Stack: Swift, SwiftUI + UIKit interoperability, Google Places SDK (Swift), Google Maps SDK, SnapKit, TipKit.
- Local release verification uses Xcode 27 RC (`27A266a`) and the iOS 27 SDK. Read current build settings and package pins when compatibility matters.
- Minimum deployment target in project: iOS 26.0 across all app and test configurations.

## Repository Map
- `Daydream/` app source
- `Daydream/Cities/` discovery/home UI (`CitiesView`, cards, search toolbar, feedback)
- `Daydream/CityDetail/` city detail UI, map card, place carousels, map reviews
- `Daydream/Networking/` API namespace and Google Places data fetching
- `Daydream/Models/` domain models (`RandomCity`, `CityRoute`, etc.)
- `Daydream/Shared/` reusable UI, extensions, caches, location manager, JSON data
- `Daydream/Shared/randomCitiesJSON.json` seed city dataset used for random city flows
- `Daydream.xcodeproj/` project/scheme/package resolution

## Setup and validation
- See `README.md` for API key setup and build/test commands. Default local destination: `platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0`, project `Daydream.xcodeproj`, scheme `Daydream`, test plan `unittests`.
- Missing `Daydream/Shared/apiKeys.plist` lets the app launch but prevents useful Maps/Places results. Keep the `googleAPI` and `placesNewAPI` keys local and untracked.
- Match verification to the change. Compile code and dependency changes, run relevant existing tests, and inspect affected UI flows. Documentation-only edits need instruction/link checks.
- For SDK or release validation, exercise the full regression scenarios below on iOS 27 and a supported iOS 26 runtime. Report unavailable runtimes and unverified paths explicitly; a build does not prove runtime behavior.
- SwiftLint is optional when installed; use `.swiftlint.yml`.

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
- Preserve availability handling for APIs newer than the minimum deployment target; do not reintroduce unreachable pre-iOS 26 branches.
- Avoid introducing new third-party dependencies unless explicitly requested.
- Keep changes scoped; do not refactor unrelated modules in the same patch.

## Safety and Secrets
- Never commit real API keys or secrets.
- Do not modify `GoogleService-Info.plist` or signing/bundle settings unless requested.
- Avoid changing `Info.plist` permission text unless the feature requires it.

## Regression scenarios
Select affected scenarios for focused changes; use the full set for dependency or release validation.
1. Launch app to `CitiesView` without crash.
2. Search a city and open `CityDetailView`.
3. Verify Top Sights / Top Eateries load.
4. Open map detail sheet and confirm marker/reviews render.
5. Trigger current-location flow (with simulator location enabled).
6. Verify random city flow still navigates and renders image background.

## Agent Workflow Expectations
- If you cannot run validation locally, state that clearly and list unverified paths.
- After adding or changing code, build/compile the app when feasible and proactively fix any compiler issues. If it's a trivial code change (e.g., change SF symbol icon) or a change you have extremely high confidence that it will compile, you can skip building.
- Device commands (when requested):
  - Build for Ray K's device: `xcodebuild -project Daydream.xcodeproj -scheme Daydream -destination 'id=00008150-000E2CA1110A401C' build`
  - Install/launch with `xcrun devicectl` using the built app’s bundle identifier (`com.rckim.Daydream` in the current project) after a successful device build.
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
- If I ask to build and run on device, do not build for the simulator first. Make it as fast as possible.
- When adding unit tests, prefer Swift Testing (`import Testing`, `@Test`, `#expect`) over XCTest where possible.
- When code changes are covered by existing unit tests, run the relevant unit tests before finishing.
- For debug-only features (UI/actions hidden in release distribution builds), do not add unit tests.
- For new SwiftUI work, do not encapsulate child UI pieces as private `var` view properties; inline child UI composition in the main `body` unless a reusable standalone view type is needed.
- Prefer one main SwiftUI view type (`struct ...: View`) per Swift file.
- If a SwiftUI view grows beyond a manageable size and contains composable subviews, extract those subviews into separate SwiftUI files instead of keeping multiple main view types in one file.
- For SwiftUI view state objects, prefer modern Observation (`@MainActor` + `@Observable` final class) over plain structs/legacy observable patterns.
- When a SwiftUI view has a corresponding view state object (for example, `CityDetailView` and `CityDetailViewState`), add new view `@State` values to the view state object when that ownership model still makes sense.
- Whenever adding a new view state object, also add a corresponding `...ViewStateTests.swift` suite using Swift Testing and run that suite to verify the new tests pass before completing the task.
- Keep accessibility support practical and simple: add clear labels/identifiers for interactive UI, but avoid over-engineering fine-grained conditional label logic (for example, separate singular/plural variants) unless explicitly needed.
- For sufficiently complex code paths, add a short human-readable code comment that explains intent and flow.

## Documentation Sync
- Keep affected documentation aligned with feature and SDK changes, including `README.md` and `AGENTS.md`. Minor edits do not require a documentation sweep.

## Context and skills
- User instructions take precedence over skill guidelines. Continue authorized work using repository context for routine choices; ask only when missing information materially affects the result.
- Read skill references for the feature or failure being addressed. Prefer current Apple guidance for SDK-specific behavior when available; examples do not authorize unrelated modernization.
- If a skill blocks completion or requires confirmation, identify the exact instruction and explain why it applies.
- `Daydream/CityDetail/SummaryView.swift` prompts Apple's on-device Foundation Models. Astra guidance applies to coding instructions; changes to that product prompt need their own on-device evaluation.
