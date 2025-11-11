# Daydream iOS App

Daydream is an iOS app written in Swift (SwiftUI + UIKit hybrid) that helps users explore cities around the world. The app integrates with Google Maps SDK and Google Places Swift SDK to provide location-based information and experiences.

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
  - Create `Daydream/Shared/apiKeys.plist` with your actual API keys:
    - Google API key (for Google Maps SDK)
    - Google Places New API key (for Google Places Swift SDK)
  - Format should match exactly:
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
      <key>googleAPI</key>
      <string>YOUR_GOOGLE_API_KEY</string>
      <key>placesNewAPI</key>
      <string>YOUR_PLACES_NEW_API_KEY</string>
  </dict>
  </plist>
  ```

### Build Commands
- **Build the app**: `xcodebuild -project Daydream.xcodeproj -scheme Daydream build` -- NEVER CANCEL: Takes 3-5 minutes. Set timeout to 10+ minutes.
- **Clean build**: `xcodebuild -project Daydream.xcodeproj -scheme Daydream clean build` -- NEVER CANCEL: Takes 5-8 minutes. Set timeout to 15+ minutes.
- **Build for simulator**: `xcodebuild -project Daydream.xcodeproj -scheme Daydream -sdk iphonesimulator build` -- NEVER CANCEL: Takes 3-5 minutes. Set timeout to 10+ minutes.

### Testing
- **No Test Targets**: This project does not currently have UI tests or unit tests configured.
- Testing is done manually through the simulator or device.

### Running the App
- Open `Daydream.xcodeproj` in Xcode
- Select a simulator (iPhone 16 Pro recommended, requires Xcode 16.1.0+)
- Press Cmd+R or click the Run button
- **First launch**: App will show cities view with curated cities to explore
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
- **SwiftLint**: 30-60 seconds for full project scan

### Manual Testing Scenarios
After making changes, ALWAYS test these core user scenarios:
1. **Cities View**: Launch app → View curated cities → Tap city card → Verify city detail screen loads
2. **Search Flow**: Tap search in toolbar → Type city name → Select from autocomplete → Verify city detail loads
3. **Random City**: Launch app → Tap random city button → Verify random city loads correctly  
4. **City Detail**: Navigate to city detail → View place cards carousel → Tap map card → Verify map opens
5. **Map Interaction**: On map screen → Tap markers → Verify review cards display and update correctly
6. **Dark Mode**: Toggle dark mode button on map → Verify map and UI updates correctly
7. **Feedback**: Tap feedback button → Verify feedback sheet appears with options

### Build Validation
- Always run `swiftlint` before committing changes
- Always build successfully before creating PR
- No automated tests; manual testing required

### API Key Testing
- Without proper API keys, the app launches but location features fail silently
- Test with valid Google Maps API key to ensure map functionality works
- Test with valid Google Places New API key to ensure place search and autocomplete works

## Common Tasks

### Project Structure
```
Daydream/
├── AppDelegate.swift              # App initialization and API key loading
├── SceneDelegate.swift            # Scene setup, hosts SearchViewController
├── Cities/                        # Cities list and search functionality
│   ├── CitiesView.swift          # Main SwiftUI view showing curated cities
│   ├── CityCardView.swift        # City card UI component
│   ├── SearchViewController.swift # UIKit host for CitiesView
│   ├── SearchToolbar.swift       # Search and action buttons toolbar
│   ├── FeedbackButton.swift      # Feedback functionality
│   ├── FeedbackSheet.swift       # Feedback modal sheet
│   └── GettingStartedTip.swift   # TipKit tutorial tip
├── CityDetail/                    # City detail and map views
│   ├── CityDetailView.swift      # SwiftUI city detail screen
│   ├── MapViewController.swift    # UIKit map view with Google Maps
│   ├── MapViewControllerRepresentable.swift # SwiftUI wrapper for map
│   ├── MapCardView.swift         # Map preview card
│   ├── MapReviewContext.swift    # Observable state for map reviews
│   ├── PlaceCardCarousel/        # Place cards carousel
│   │   ├── PlacesCarouselView.swift # Carousel container
│   │   ├── PlaceCardView.swift   # Individual place card
│   │   └── PriceLevelView.swift  # Price level indicator
│   └── Map Reviews/              # Map review UI components
│       ├── MapReviewsCarousel.swift # Reviews carousel
│       ├── ReviewCard.swift      # Individual review card
│       ├── ReviewStars.swift     # Star rating display
│       └── ReviewSummaryCard.swift # Summary card
├── Models/                        # Data models
│   ├── CityRoute.swift           # City navigation model
│   ├── IdentifiablePlace.swift  # Place wrapper for SwiftUI
│   └── RandomCity.swift          # Random city model
├── Networking/                    # API integration
│   ├── API.swift                 # API namespace
│   ├── API+PlaceSearch.swift     # Google Places API integration
│   └── JSONCustomDecoder.swift   # JSON decoder utility
├── Shared/                        # Shared utilities and components
│   ├── Extensions/               # Swift extensions
│   │   ├── Extensions.swift      # General extensions
│   │   ├── GoogleExtensions.swift # Google SDK extensions
│   │   └── View+Extensions.swift # SwiftUI view extensions
│   ├── Buttons/                  # Reusable button components
│   │   ├── HomeButton.swift      # Navigation home button
│   │   └── RandomCityButton.swift # Random city button
│   ├── randomCitiesJSON.json     # Predefined cities data
│   ├── ExpiringCache.swift       # Generic expiring cache
│   ├── ImageCache.swift          # Image caching
│   ├── PlacesCache.swift         # Places API caching
│   ├── Protocols.swift           # Shared protocols
│   ├── SearchActionStyle.swift   # Search action styling
│   ├── ShadowView.swift          # Shadow container view
│   ├── TopScrollTransition.swift # Scroll transition modifier
│   └── UIDevice+Helpers.swift    # Device utility extensions
└── Assets.xcassets               # Images and app icons
```

### Key Dependencies (Swift Package Manager)
- **Google Maps SDK** (10.4.0): Map display and interaction
- **Google Places Swift SDK** (10.4.0): Location search and autocomplete  
- **SnapKit** (5.7.1): Auto Layout DSL for UI constraints

### Important Files for Common Changes
- **Cities view logic**: `CitiesView.swift`, `CityCardView.swift`, `SearchToolbar.swift`
- **City detail view**: `CityDetailView.swift`, `PlacesCarouselView.swift`, `PlaceCardView.swift`
- **Map functionality**: `MapViewController.swift`, `MapViewControllerRepresentable.swift`
- **Map reviews**: Files in `Map Reviews/` directory
- **API integration**: Files in `Networking/` directory
- **Data models**: Files in `Models/` directory
- **Shared components**: Files in `Shared/` directory and subdirectories
- **App configuration**: `Info.plist`, `AppDelegate.swift`, `SceneDelegate.swift`

### Debugging Tips
- Check Console for API key related errors if location features don't work
- Use Xcode's View Debugger for UI layout issues (both SwiftUI and UIKit)
- Enable Network logging to debug Google Places API calls
- Use SwiftUI Previews for rapid iteration on SwiftUI components
- Check `MapReviewContext` state updates for map review display issues

### Performance Considerations
- App uses image caching (`ExpiringCache.swift`, `ImageCache.swift`) for performance
- Places API responses are cached (`PlacesCache.swift`) to reduce API calls
- App supports both light and dark mode with automatic switching
- Uses TipKit framework for user onboarding
- Implements zoom transitions for smooth navigation between views

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

### Architecture
The app uses a hybrid SwiftUI + UIKit architecture:
- **SwiftUI**: Used for most UI components (CitiesView, CityDetailView, all card views, reviews)
- **UIKit**: Used for hosting SwiftUI views and Google Maps integration (SearchViewController, MapViewController)
- **Navigation**: Uses SwiftUI NavigationStack for screen transitions
- **State Management**: Uses SwiftUI @State, @Environment, and observable objects (MapReviewContext)

### Networking Layer
All API integration is through Google SDKs:
- `Networking/API.swift` - Main API namespace
- `Networking/API+PlaceSearch.swift` - Google Places API integration with caching
- Uses Google Places Swift SDK for autocomplete and place details
- Uses Google Maps SDK for map display
- No Yelp or NY Times integrations (removed in recent versions)

### View Controller Relationships
- `SearchViewController` (UIKit) → hosts `CitiesView` (SwiftUI)
- `CitiesView` → navigates to `CityDetailView` via NavigationStack
- `CityDetailView` → contains `MapViewControllerRepresentable` which wraps `MapViewController`
- `MapViewController` (UIKit) → displays Google Maps and hosts SwiftUI review cards
- Uses SwiftUI's `UIHostingController` to embed SwiftUI in UIKit contexts
- Uses `UIViewControllerRepresentable` to embed UIKit (MapViewController) in SwiftUI

### Data Flow
1. **Cities View**: Load curated cities from `randomCitiesJSON.json` → Display city cards → Fetch place data on tap
2. **Search**: User input → Google Places autocomplete → Place selection → Navigate to city detail
3. **City Detail**: Display place data → Fetch nearby places via Google Places API → Show in carousel
4. **Map**: Display selected place on map → User taps markers → Update `MapReviewContext` → Reviews update via SwiftUI bindings
5. **Caching**: API responses cached in `PlacesCache`, images in `ImageCache`

### Memory Management
- Uses `ExpiringCache` for generic caching with configurable TTL (1 hour default)
- Separate caches for images (`ImageCache`) and places (`PlacesCache`)
- Implements weak references in closures to prevent retain cycles
- SwiftUI automatic memory management for view state

### UI Patterns
- **SwiftUI**: Primary UI framework for most components
- **SnapKit**: Used for Auto Layout in UIKit components (MapViewController)
- **Custom Components**: City cards, place cards, review cards all built with SwiftUI
- **Styling**: Custom button styles, shadow views, gradient effects
- **Animations**: Zoom transitions, scroll transitions, card animations
- **Accessibility**: Supports dynamic type and VoiceOver
- **Dark Mode**: Full support with custom styling for map and all UI
- **TipKit**: Onboarding tips using Apple's TipKit framework

### Common Gotchas
- API keys must be in exact format in `apiKeys.plist` with both `googleAPI` and `placesNewAPI` keys
- App uses hybrid SwiftUI/UIKit - be careful with state management across boundaries
- `MapReviewContext` is the bridge for state updates between UIKit MapViewController and SwiftUI reviews
- Image loading uses custom cache with expiration - check `ImageCache` for issues
- Places API responses are cached - clear cache via feedback sheet "Clear Cached Data" if needed
- App uses programmatic UI (no storyboards except LaunchScreen)
- Random cities data comes from `randomCitiesJSON.json` - includes location coordinates
- Dark mode toggle in MapViewController affects map styling dynamically
- Zoom transitions use SwiftUI `matchedGeometryEffect` with namespace

## Troubleshooting

### Build Issues
- **"Package resolution failed"**: Clean DerivedData and restart Xcode
- **"Command CodeSign failed"**: Check provisioning profiles and certificates
- **"Missing API keys"**: Verify `apiKeys.plist` exists in `Daydream/Shared/`
- **SPM timeout**: Network issues - retry after checking connection

### Runtime Issues  
- **App launches but no map**: Check Google Maps API key in `apiKeys.plist`
- **No search results**: Check Google Places New API key (`placesNewAPI`) in `apiKeys.plist`
- **City cards not loading**: Check network connection and Places API quota/permissions
- **Images not loading**: Check `ImageCache` and network connection
- **Reviews not updating**: Check `MapReviewContext` state and marker selection in MapViewController

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
- `API+PlaceSearch.swift` for Places API call failures
- `ExpiringCache.swift`, `ImageCache.swift`, `PlacesCache.swift` for caching issues
- `MapReviewContext.swift` for map review state management
- `MapViewController.swift` for map display and interaction issues
- `CitiesView.swift` for cities loading and navigation issues