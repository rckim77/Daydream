# Daydream iOS App

Daydream is an iOS app written in Swift and SwiftUI that helps users explore cities around the world. The app integrates with Google Maps and Google Places APIs to provide location-based information and city exploration experiences.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Environment Requirements
- **macOS REQUIRED**: This is an iOS project that requires macOS with Xcode installed. Cannot be built on Linux/Windows.
- Install Xcode from the Mac App Store (latest stable version recommended)
- Install Xcode Command Line Tools: `xcode-select --install`
- Install SwiftLint for code quality: `brew install swiftlint`

### Bootstrap and Build Process
- **IMPORTANT**: This project uses Swift Package Manager (SPM) for dependencies
- Open `Daydream.xcodeproj` (NOT .xcworkspace as there isn't one)
- Dependencies are managed via SPM and will be resolved automatically by Xcode
- **API Keys Setup (REQUIRED)**: 
  - Create `Daydream/apiKeys.plist` with your actual API keys (note: not in Shared/ directory)
  - Required API keys:
    - Google API key (for Maps SDK)
    - Google Places New API key (for Places Swift SDK)
  - Format should match exactly:
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
      <key>googleAPI</key>
      <string>YOUR_GOOGLE_API_KEY</string>
      <key>placesNewAPI</key>
      <string>YOUR_GOOGLE_PLACES_NEW_API_KEY</string>
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
- Select a simulator (iPhone 15 Pro or newer recommended)
- Press Cmd+R or click the Run button
- **First launch**: App will show CitiesView with random cities and search functionality
- **Without API keys**: App will launch but location-based features and city data will not work

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
1. **Cities View Flow**: Launch app → View random cities → Tap on a city card → Verify city detail screen loads
2. **Search Flow**: Launch app → Tap search bar → Search for "Tokyo" → Select city from autocomplete → Verify city detail screen loads
3. **Random City**: Launch app → Tap random city button (dice icon) → Verify random city loads correctly
4. **Map Interaction**: On city detail → Tap "Get Directions" on a place card → Verify MapViewController opens with location
5. **Place Cards**: On city detail → Scroll through sights and eateries carousels → Verify place cards display correctly
6. **Feedback**: Tap feedback button → Verify feedback sheet appears with options
7. **Navigation**: Test back navigation and home button functionality

### Build Validation
- Always run `swiftlint` before committing changes
- Always build successfully before creating PR
- Test on both iPhone and iPad simulators when making UI changes

### API Key Testing
- Without proper API keys, the app launches but location features fail silently
- Test with valid Google API key to ensure map functionality works
- Test with valid Google Places New API key to ensure city data and place searches work

## Common Tasks

### Project Structure
```
Daydream/
├── AppDelegate.swift              # App initialization, API key loading, TipKit setup
├── SceneDelegate.swift            # Scene setup, sets SearchViewController as root
├── Cities/                        # Main cities browsing interface (SwiftUI)
│   ├── CitiesView.swift          # Main view showing random cities
│   ├── CityCardView.swift        # Individual city card component
│   ├── CityCardButtonStyle.swift # Button styling for city cards
│   ├── SearchToolbar.swift       # Search bar and toolbar
│   ├── SearchViewController.swift # UIKit wrapper for CitiesView
│   ├── FeedbackSheet.swift       # Feedback modal
│   ├── FeedbackButton.swift      # Feedback button component
│   └── GettingStartedTip.swift   # TipKit getting started tip
├── CityDetail/                    # City detail and map views (SwiftUI)
│   ├── CityDetailView.swift      # Detail view for a selected city
│   ├── MapViewController.swift   # UIKit map view with Google Maps
│   ├── MapViewControllerRepresentable.swift # SwiftUI wrapper for MapViewController
│   ├── MapCardView.swift         # Map card component
│   ├── MapReviewContext.swift    # Context for map review state
│   ├── PlaceCardCarousel/        # Carousel of place cards
│   │   ├── PlacesCarouselView.swift # Main carousel view
│   │   ├── PlaceCardView.swift   # Individual place card
│   │   └── PriceLevelView.swift  # Price level indicator
│   └── Map Reviews/              # Map review components
│       ├── MapReviewsCarousel.swift # Review carousel
│       ├── ReviewCard.swift      # Individual review card
│       ├── ReviewStars.swift     # Star rating component
│       └── ReviewSummaryCard.swift # Review summary
├── Models/                        # Data models
│   ├── RandomCity.swift          # Random city model
│   ├── CityRoute.swift           # City route navigation model
│   └── IdentifiablePlace.swift  # Wrapper for Google Places
├── Networking/                    # API client layer
│   ├── API.swift                 # API namespace
│   ├── API+PlaceSearch.swift     # Google Places API integration
│   └── JSONCustomDecoder.swift   # Custom JSON decoder
├── Shared/                        # Shared utilities and components
│   ├── randomCitiesJSON.json     # Predefined random cities data
│   ├── Extensions/               # Swift extensions
│   │   ├── Extensions.swift      # General Swift extensions
│   │   ├── GoogleExtensions.swift # Google SDK extensions
│   │   └── View+Extensions.swift # SwiftUI view extensions
│   ├── Buttons/                  # Reusable button components
│   │   ├── RandomCityButton.swift # Random city button
│   │   └── HomeButton.swift      # Home navigation button
│   ├── ExpiringCache.swift       # Generic expiring cache
│   ├── ImageCache.swift          # Image caching
│   ├── PlacesCache.swift         # Places data caching
│   ├── Protocols.swift           # Common protocols
│   ├── ShadowView.swift          # Shadow view component
│   ├── SearchActionStyle.swift   # Search action styling
│   ├── TopScrollTransition.swift # Scroll transition modifier
│   └── UIDevice+Helpers.swift    # UIDevice extensions
└── Assets.xcassets               # Images and app icons
```

### Key Dependencies (Swift Package Manager)
- **Google Maps SDK** (ios-maps-sdk): Map display and interaction
- **Google Places Swift SDK** (ios-places-sdk/GooglePlacesSwift): Location search, autocomplete, and place details
- **SnapKit** (5.7.1): Auto Layout DSL for UI constraints (used in UIKit components)

### Important Files for Common Changes
- **Cities browsing**: `Cities/CitiesView.swift`, `Cities/CityCardView.swift`
- **Search functionality**: `Cities/SearchToolbar.swift`, `Cities/SearchViewController.swift`
- **City details**: `CityDetail/CityDetailView.swift`, `CityDetail/PlaceCardCarousel/PlacesCarouselView.swift`
- **Map functionality**: `CityDetail/MapViewController.swift`, `CityDetail/MapViewControllerRepresentable.swift`
- **Map reviews**: Files in `CityDetail/Map Reviews/` directory
- **API integration**: `Networking/API+PlaceSearch.swift`
- **Data models**: Files in `Models/` directory
- **Shared components**: Files in `Shared/Buttons/`, `Shared/Extensions/`
- **App configuration**: `Info.plist`, `AppDelegate.swift`, `SceneDelegate.swift`

### Debugging Tips
- Check Console for API key related errors if location features don't work
- Use Xcode's View Debugger for SwiftUI layout issues
- Enable Network logging to debug API calls
- Use SwiftUI preview for rapid UI iteration (where available)
- Check `randomCitiesJSON.json` if random city feature isn't working

### Performance Considerations
- App uses image caching (`ImageCache.swift`, `ExpiringCache.swift`) for performance
- Places data is cached (`PlacesCache.swift`) to reduce API calls
- App supports both light and dark mode with automatic switching
- UI adapts to horizontal size class for iPad support
- Random cities are preloaded from JSON for instant display

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
- `Networking/API.swift` - Main API namespace
- `Networking/API+PlaceSearch.swift` - Google Places API integration (search, details, nearby, photos)
- `Networking/JSONCustomDecoder.swift` - Custom JSON decoding utilities
- The app uses Google Places Swift SDK which provides Place objects directly
- API calls are cached where appropriate to reduce network usage

### View Architecture
- **CitiesView** (SwiftUI): Main entry point showing random cities in cards
- **CityDetailView** (SwiftUI): Shows city details with place carousels
- **MapViewController** (UIKit/GoogleMaps): Map view wrapped in SwiftUI via MapViewControllerRepresentable
- Navigation uses SwiftUI NavigationStack for modern navigation
- Mix of SwiftUI and UIKit where Google Maps requires UIKit
- SearchViewController wraps CitiesView for compatibility with SceneDelegate

### Data Flow
1. **Random Cities**: CitiesView loads RandomCity objects from `randomCitiesJSON.json` → User taps card → Navigates to CityDetailView
2. **Search**: User taps search → SearchToolbar appears → Google Places autocomplete → User selects → Navigates to CityDetailView
3. **City Details**: CityDetailView receives Place → Fetches nearby sights and eateries → Displays in PlacesCarouselView
4. **Map View**: User taps place card → MapViewController presented → Shows place on map with reviews

### Memory Management
- Uses `ExpiringCache` and `ImageCache` for caching with expiration
- PlacesCache for Google Places SDK data caching
- Implements weak references in closures to prevent retain cycles
- SwiftUI manages view lifecycle automatically
- Timer-based cleanup for cached data where needed

### UI Patterns
- **SwiftUI First**: Primary UI is built with SwiftUI (CitiesView, CityDetailView, all cards and components)
- **UIKit Interop**: MapViewController uses UIKit for Google Maps SDK, wrapped with UIViewControllerRepresentable
- **SnapKit**: Used for Auto Layout in UIKit components (MapViewController)
- **Custom Components**: ShadowView, TopScrollTransition modifier, custom button styles
- **Responsive Design**: Adapts to horizontal size class for iPad (different padding, spacing, card sizes)
- **TipKit Integration**: Uses iOS 17+ TipKit for onboarding tips (GettingStartedTip)
- **Dark Mode**: Full support throughout app with automatic switching
- **Navigation**: SwiftUI NavigationStack with programmatic navigation via CityRoute

### Common Gotchas
- API keys must be in `apiKeys.plist` in root Daydream/ directory (NOT in Shared/)
- API keys use different key names: `googleAPI` and `placesNewAPI`
- App uses Google Places Swift SDK (newer SDK) not the older GooglePlaces
- MapViewController is UIKit wrapped in SwiftUI - coordinate changes carefully
- Random cities JSON must have valid lat/lng coordinates for proper loading
- SwiftUI previews may not work for views requiring API keys
- Image loading uses custom cache with expiration - clear cache if images don't update
- TipKit requires iOS 17+ - check availability when modifying tips
- SearchViewController is a UIKit wrapper for SwiftUI CitiesView for SceneDelegate compatibility

## Troubleshooting

### Build Issues
- **"Package resolution failed"**: Clean DerivedData and restart Xcode
- **"Command CodeSign failed"**: Check provisioning profiles and certificates
- **"Missing API keys"**: Verify `apiKeys.plist` exists in `Daydream/` directory
- **SPM timeout**: Network issues - retry after checking connection

### Runtime Issues  
- **App launches but no cities load**: Check Google Places New API key and permissions
- **No map display**: Check Google API key and enable Maps SDK for iOS
- **No search results**: Check Google Places New API key and Places API permissions
- **Random city feature fails**: Verify `randomCitiesJSON.json` exists and has valid data
- **Feedback sheet not working**: Check iOS version compatibility (requires iOS 15+ for sheet modifiers)

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
- `AppDelegate.swift` for API key loading issues and TipKit initialization
- `Networking/API+PlaceSearch.swift` for API call failures
- `PlacesCache.swift` and caching files for data loading issues
- `randomCitiesJSON.json` for random city feature issues
- `CityDetailView.swift` for city detail display issues
- `MapViewController.swift` for map-related issues
- SwiftUI view modifiers for UI layout problems