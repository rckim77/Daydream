# [Daydream](https://apps.apple.com/us/app/daydream-explore-cities/id1366747814)
Explore cities around the world

[Download on the App Store](https://apps.apple.com/us/app/daydream-explore-cities/id1366747814)

[Privacy Policy](https://rckim77.github.io/Daydream-Site/)

## Local Setup
Minimum deployment target: iOS 26.0.

Open `Daydream.xcodeproj` in Xcode 26.1.0+ to resolve Swift packages.

Create `Daydream/apiKeys.plist` with:
- `googleAPI`
- `placesNewAPI`

These keys are required for Google Maps/Places powered features.

## Build
```bash
xcodebuild -project Daydream.xcodeproj -scheme Daydream -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1' build
```

## Tests (Swift Testing + xctestplan)
The project includes a shared test plan at `unittests.xctestplan` and a Swift Testing target `DaydreamTests`.

```bash
xcodebuild test -project Daydream.xcodeproj -scheme Daydream -testPlan unittests -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.1' CODE_SIGNING_ALLOWED=NO
```

## CI
Pull requests run tests on GitHub Actions via:
- `.github/workflows/pr-tests.yml`

![Simulator Screen Recording - iPhone 16 Pro - 2025-11-10 at 21 10 26](https://github.com/user-attachments/assets/09f30ccc-917e-4d54-9ffc-237525e0d656)
