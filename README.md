# [Daydream](https://apps.apple.com/us/app/daydream-explore-cities/id1366747814)
Explore cities around the world

[Download on the App Store](https://apps.apple.com/us/app/daydream-explore-cities/id1366747814)

[Privacy Policy](https://rckim77.github.io/Daydream-Site/)

## Local Setup
Minimum deployment target: iOS 26.0.

Local release verification uses Xcode 27 RC (`27A266a`) with the iOS 27 SDK. Open `Daydream.xcodeproj` to resolve Swift packages. Use `DEVELOPER_DIR=/Applications/Xcode_27RC.app/Contents/Developer` when multiple Xcode installations are present.

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
CI currently uses Xcode 26.2 and iOS 26.2, independently of local Xcode 27 RC verification. Pull requests run tests on GitHub Actions via:
- `.github/workflows/pr-tests.yml`

![Simulator Screen Recording - iPhone 16 Pro - 2025-11-10 at 21 10 26](https://github.com/user-attachments/assets/09f30ccc-917e-4d54-9ffc-237525e0d656)
