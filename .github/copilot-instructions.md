# Daydream iOS App

Daydream is an iOS app written in Swift that helps users explore cities around the world. The app integrates with Google Maps/Places, Yelp, and NY Times APIs to provide location-based information and experiences.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Environment Requirements
- **macOS REQUIRED**: This is an iOS project that requires macOS with Xcode installed. Cannot be built on Linux/Windows.
- Install Xcode from the Mac App Store (latest stable version recommended)
- Install Xcode Command Line Tools: `xcode-select --install`
- Install SwiftLint for code quality: `brew install swiftlint`

### Bootstrap and Build Process
- **IMPORTANT**: The README mentions CocoaPods but this project actually uses Swift Package Manager (SPM)
- Open `Daydream.xcodeproj` (NOT .xcworkspace as there isn't one)
- Dependencies are managed via SPM and will be resolved automatically by Xcode
- **API Keys Setup (REQUIRED)**: 
  - Copy `Daydream/Shared/apiKeys.plist.template` to `Daydream/Shared/apiKeys.plist`
  - Edit the copied file and replace placeholder values with your actual API keys:
    - Google API key (with Maps SDK and Places API enabled)
    - Yelp Fusion API key
    - NY Times Article Search API key
  - Format should match exactly:
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
      <key>googleAPI</key>
      <string>YOUR_GOOGLE_API_KEY</string>
      <key>yelpAPI</key>
      <string>YOUR_YELP_API_KEY</string>
      <key>nyTimesAPI</key>
      <string>YOUR_NY_TIMES_API_KEY</string>
  </dict>
  </plist>
  ```

### Build Commands
- **Build the app**: `xcodebuild -project Daydream.xcodeproj -scheme Daydream build` -- NEVER CANCEL: Takes 3-5 minutes. Set timeout to 10+ minutes.
- **Clean build**: `xcodebuild -project Daydream.xcodeproj -scheme Daydream clean build` -- NEVER CANCEL: Takes 5-8 minutes. Set timeout to 15+ minutes.
- **Build for simulator**: `xcodebuild -project Daydream.xcodeproj -scheme Daydream -sdk iphonesimulator build` -- NEVER CANCEL: Takes 3-5 minutes. Set timeout to 10+ minutes.

### Testing
- **Run UI Tests**: `xcodebuild -project Daydream.xcodeproj -scheme DaydreamUITests -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test` -- NEVER CANCEL: Takes 5-10 minutes. Set timeout to 20+ minutes.
- **Unit Tests**: This project primarily uses UI tests. No separate unit test target found.

### Running the App
- Open `Daydream.xcodeproj` in Xcode
- Select a simulator (iPhone 15 Pro recommended)
- Press Cmd+R or click the Run button
- **First launch**: App will show search interface for exploring cities
- **Without API keys**: App will launch but location-based features will not work

### Code Quality
- **Linting**: `swiftlint` -- Takes 30-60 seconds. Always run before committing.
- **Auto-fix linting**: `swiftlint --fix` -- Takes 30-60 seconds.
- **Specific file linting**: `swiftlint lint --path Daydream/FileName.swift`
- **SwiftLint Configuration**: Uses `.swiftlint.yml` with disabled rules for trailing_whitespace, identifier_name, function_body_length, type_body_length, and nesting.
- **Line limit**: 158 characters as configured in .swiftlint.yml

## Validation

### CRITICAL: Build Time Expectations
- **Initial build**: 5-8 minutes for clean build -- NEVER CANCEL: Set timeout to 15+ minutes
- **Incremental builds**: 1-3 minutes -- NEVER CANCEL: Set timeout to 10+ minutes  
- **SPM dependency resolution**: 2-5 minutes first time -- NEVER CANCEL: Set timeout to 10+ minutes
- **UI tests**: 5-10 minutes full suite -- NEVER CANCEL: Set timeout to 20+ minutes
- **SwiftLint**: 30-60 seconds for full project scan

### Manual Testing Scenarios
After making changes, ALWAYS test these core user scenarios:
1. **Search Flow**: Launch app → Search for "Tokyo" → Select city from autocomplete → Verify city detail screen loads with map
2. **Random City**: Launch app → Tap random city button → Verify random city loads correctly  
3. **Map Interaction**: Navigate to city detail → Tap on a sight → Verify map opens with location details
4. **Review Display**: On map screen → Verify review cards cycle through automatically
5. **Dark Mode**: Toggle dark mode button on map → Verify UI updates correctly

### Build Validation
- Always run `swiftlint` before committing changes
- Always build successfully before creating PR
- UI tests should pass (but are currently commented out in test file)

### API Key Testing
- Without proper API keys, the app launches but location features fail silently
- Test with valid Google API key to ensure map functionality works
- Test with valid Yelp API key to ensure restaurant data loads
- Test with valid NY Times API key to ensure article search works

## Common Tasks

### Project Structure
```
Daydream/
├── AppDelegate.swift              # App initialization and API key loading
├── SearchViewController.swift     # Main search interface
├── SearchDetailViewController.swift # City detail screen
├── MapViewController.swift        # Map view with reviews
├── Models/                        # Data models (Place, Eatery, Review, etc.)
├── Networking/                    # API clients (Google, Yelp, NY Times)
├── CardCells/                     # UI components for city details
├── Search/                        # Search-related view controllers
├── Shared/                        # Utilities, extensions, constants
│   ├── randomCitiesJSON.json     # Predefined cities for random selection
│   ├── style.json                # Google Maps dark mode styling
│   ├── apiKeys.plist             # API keys (you must create this)
│   └── Extensions.swift          # UI and utility extensions
└── Assets.xcassets               # Images and app icons
```

### Key Dependencies (Swift Package Manager)
- **Google Maps SDK** (8.4.0): Map display and interaction
- **Google Places SDK** (8.5.0): Location search and autocomplete  
- **SnapKit** (5.7.1): Auto Layout DSL for UI constraints

### Important Files for Common Changes
- **Search logic**: `SearchViewController.swift`, `SearchDetailViewController.swift`
- **Map functionality**: `MapViewController.swift`
- **API integration**: Files in `Networking/` directory
- **Data models**: Files in `Models/` directory
- **UI components**: Files in `CardCells/` directory
- **App configuration**: `Info.plist`, `AppDelegate.swift`

### Debugging Tips
- Check Console for API key related errors if location features don't work
- Use Xcode's View Debugger for UI layout issues
- Enable Network logging to debug API calls
- UI test code is commented out but available in `DaydreamUITests.swift` for reference

### Performance Considerations
- App uses image caching (`ExpiringCache.swift`) for performance
- Review cards have automatic cycling disabled during UI tests
- App supports both light and dark mode with automatic switching

## Environment Limitations

### What Works on macOS Only
- Building and running the app (requires Xcode)
- UI testing in simulator
- Debugging with Xcode tools
- Installing dependencies via SPM

### What Doesn't Work on Linux/Windows
- Cannot build or run iOS apps
- Cannot install Xcode or iOS simulators  
- Cannot test actual app functionality
- SPM dependencies won't resolve without Xcode

### Alternative Validation on Non-macOS
- Static analysis with SwiftLint (if installed via package manager)
- Code review of Swift syntax and structure
- Validation of JSON and plist file formats
- Documentation review and updates

## Common Code Patterns and Frequently Modified Files

### Networking Layer
When modifying API integrations, always check these files:
- `Networking/API.swift` - Main API namespace and common types
- `Networking/PlaceSearch/` - Google Places API integration
- `Networking/EaterySearch/` - Yelp API integration  
- `Networking/ArticleSearch/` - NY Times API integration
- Each API directory contains Routes and implementation files

### View Controller Relationships
- `SearchViewController` → `SearchDetailViewController` → `MapViewController`
- Always check delegate patterns when modifying view transitions
- Search uses Google Places autocomplete
- Detail view loads place data and displays in cards
- Map view shows location with cycling review cards

### Data Flow
1. **Search**: User input → Google Places autocomplete → Place selection
2. **Detail**: Place data → API calls for sights/eateries → Display in cards
3. **Map**: Place selection → Map display → Review cycling → User interaction

### Memory Management
- Uses `ExpiringCache` for image caching (1 hour default)
- Implements weak references in closures to prevent retain cycles
- Timer-based cleanup for cached data

### UI Patterns
- Uses SnapKit for Auto Layout constraints
- Custom card-based UI with `ShadowView` and `GradientView`
- Supports dynamic type and accessibility
- Dark mode support throughout

### Common Gotchas
- API keys must be in exact format in `apiKeys.plist`
- UI tests are currently commented out but code exists
- Review card cycling is disabled during UI testing
- Image loading uses custom cache with expiration
- App uses programmatic UI (no storyboards except LaunchScreen)

## Troubleshooting

### Build Issues
- **"Package resolution failed"**: Clean DerivedData and restart Xcode
- **"Command CodeSign failed"**: Check provisioning profiles and certificates
- **"Missing API keys"**: Verify `apiKeys.plist` exists in `Daydream/Shared/`
- **SPM timeout**: Network issues - retry after checking connection

### Runtime Issues  
- **App launches but no map**: Check Google API key and enable Maps SDK
- **No search results**: Check Google Places API key and enable Places API
- **No restaurant data**: Check Yelp API key format and permissions
- **No article data**: Check NY Times API key format

### Common Command Sequences
```bash
# Full validation workflow
swiftlint
xcodebuild -project Daydream.xcodeproj -scheme Daydream clean build
# Launch in Xcode and test manually

# Clean build after dependency changes
rm -rf ~/Library/Developer/Xcode/DerivedData/Daydream-*
xcodebuild -project Daydream.xcodeproj -scheme Daydream clean build

# Check project status
xcodebuild -project Daydream.xcodeproj -list
```

### Files to Check First When Debugging
- Console output for runtime errors
- `AppDelegate.swift` for API key loading issues  
- Network layer files for API call failures
- `ExpiringCache.swift` for image loading issuesg UI testing
- Image loading uses custom cache with expiration
- App uses programmatic UI (no storyboards except LaunchScreen)