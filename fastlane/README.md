fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios release_new_major_version
```
fastlane ios release_new_major_version
```
Deploy a new major version to the App Store (major functionality with potential breaking changes)
### ios release_new_minor_version
```
fastlane ios release_new_minor_version
```
Deploy a new minor version to the App Store (minor functionality with backwards compatibility)
### ios release_new_patch_version
```
fastlane ios release_new_patch_version
```
Deploy a new patch version to the App Store (bug fixes with backwards compatibility)
### ios release_new_build_only
```
fastlane ios release_new_build_only
```
Deploy a new build only to the App Store; no version changes
### ios screenshots
```
fastlane ios screenshots
```
Generate screenshots with custom settings

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
