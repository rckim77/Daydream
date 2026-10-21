#if DEBUG
import SwiftUI

/// Captures the real wishlist with isolated fixtures and no Google requests.
struct WishlistCaptureView: View {
    @State private var wishlist: WishlistStore
    @State private var path = ["wishlist"]
    let initialContinent: WishlistContinentFilter
    let appearance: ColorScheme?

    private init(defaults: UserDefaults, cities: [RandomCity], continent: WishlistContinentFilter, appearance: ColorScheme?) {
        let store = WishlistStore(defaults: defaults)
        for city in cities where !store.contains(city) { store.toggle(city) }
        _wishlist = State(initialValue: store)
        initialContinent = continent
        self.appearance = appearance
    }

    static func fromEnvironment() -> Self? {
        let environment = ProcessInfo.processInfo.environment
        guard environment["DAYDREAM_UI_CAPTURE_WISHLIST"] == "1",
              let suite = environment["DAYDREAM_UI_WISHLIST_SUITE"], suite.hasPrefix("Daydream.UITests."),
              let defaults = UserDefaults(suiteName: suite),
              let url = Bundle.main.url(forResource: "randomCitiesJSON", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode([RandomCity].self, from: data) else { return nil }

        let names = (environment["DAYDREAM_UI_CAPTURE_SAVED_CITIES"] ?? "").components(separatedBy: "|")
        let cities = names.compactMap { name in catalog.first { $0.city == name } }
        let continent = environment["DAYDREAM_UI_CAPTURE_CONTINENT"].flatMap(WishlistContinentFilter.init(rawValue:)) ?? .all
        let appearance: ColorScheme? = switch environment["DAYDREAM_UI_CAPTURE_APPEARANCE"] {
        case "light": .light
        case "dark": .dark
        default: nil
        }
        return Self(defaults: defaults, cities: cities, continent: continent, appearance: appearance)
    }

    var body: some View {
        NavigationStack(path: $path) {
            // Keep native Back navigation without loading discovery.
            Color(uiColor: .systemGroupedBackground)
                .navigationDestination(for: String.self) { _ in
                    WishlistView(wishlist: wishlist, initialContinent: initialContinent)
                }
        }
        .preferredColorScheme(appearance)
    }
}
#endif
