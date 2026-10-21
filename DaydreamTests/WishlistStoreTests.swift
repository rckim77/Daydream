import Foundation
import Testing

@testable import Daydream

@Suite("WishlistStore")
@MainActor
struct WishlistStoreTests {
    private let paris = RandomCity(city: "Paris", country: "France", latitude: 48.85, longitude: 2.35, radius: 10)
    private let tokyo = RandomCity(city: "Tokyo", country: "Japan", latitude: 35.68, longitude: 139.69, radius: 20)

    private func withDefaults(_ test: (UserDefaults) throws -> Void) throws {
        let name = "Daydream.WishlistTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        try test(defaults)
    }

    @Test("starts empty, saves newest first, and restores after relaunch")
    func saveAndRestore() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            #expect(store.cities.isEmpty)
            store.toggle(paris)
            store.toggle(tokyo)
            #expect(store.contains(paris))
            #expect(store.cities == [tokyo, paris])
            #expect(WishlistStore(defaults: defaults).cities == [tokyo, paris])
        }
    }

    @Test("toggling a saved city removes it and persists the removal")
    func toggleOff() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            store.toggle(paris)
            store.toggle(paris)
            #expect(!store.contains(paris))
            #expect(WishlistStore(defaults: defaults).cities.isEmpty)
        }
    }

    @Test("same-name cities in different countries remain distinct")
    func distinctCities() throws {
        try withDefaults { defaults in
            let otherParis = RandomCity(city: "Paris", country: "United States", latitude: 33.66, longitude: -95.55, radius: 5)
            let store = WishlistStore(defaults: defaults)
            store.toggle(paris)
            store.toggle(otherParis)
            #expect(store.cities.count == 2)
            store.toggle(paris)
            #expect(store.cities == [otherParis])
        }
    }

    @Test("deleting several cities by identity persists")
    func manageList() throws {
        try withDefaults { defaults in
            let rome = RandomCity(city: "Rome", country: "Italy", latitude: 41.9, longitude: 12.5, radius: 10)
            let store = WishlistStore(defaults: defaults)
            store.toggle(paris)
            store.toggle(tokyo)
            store.toggle(rome)
            store.remove([paris, tokyo])
            #expect(WishlistStore(defaults: defaults).cities == [rome])
            store.remove([rome])
            #expect(WishlistStore(defaults: defaults).cities.isEmpty)
        }
    }

    @Test("country sections merge aliases and sort countries and cities alphabetically")
    func countryGrouping() throws {
        try withDefaults { defaults in
            let london = RandomCity(city: "London", country: "UK", latitude: 51.5, longitude: -0.1, radius: 10)
            let edinburgh = RandomCity(city: "Edinburgh", country: "United Kingdom", latitude: 55.95, longitude: -3.19, radius: 10)
            let store = WishlistStore(defaults: defaults)
            for city in [london, paris, edinburgh, tokyo] { store.toggle(city) }
            #expect(store.countrySections.map(\.country) == ["France", "Japan", "United Kingdom"])
            let uk = try #require(store.countrySections.last)
            #expect(uk.flag == "🇬🇧")
            #expect(uk.cities == [edinburgh, london])
            // A section's order differs from persisted insertion order.
            store.remove([uk.cities[0]])
            let restored = WishlistStore(defaults: defaults)
            #expect(!restored.contains(edinburgh))
            #expect(restored.contains(london))
            #expect(restored.countrySections.last?.cities == [london])
            store.remove([london])
            #expect(store.countrySections.map(\.country) == ["France", "Japan"])
        }
    }

    @Test("all curated city countries have flags")
    func curatedCountryFlags() throws {
        let url = try #require(Bundle.main.url(forResource: "randomCitiesJSON", withExtension: "json"))
        let cities = try JSONDecoder().decode([RandomCity].self, from: Data(contentsOf: url))
        for section in WishlistCountrySection.group(cities) {
            #expect(section.flag != nil, "Missing flag for \(section.country)")
        }
    }

    @Test("duplicate stored identities are restored once, preserving order")
    func duplicateRecovery() throws {
        try withDefaults { defaults in
            defaults.set(try JSONEncoder().encode([paris, tokyo, paris]), forKey: "wishlist.cities.v1")
            #expect(WishlistStore(defaults: defaults).cities == [paris, tokyo])
        }
    }

    @Test("unreadable saved data does not crash or get overwritten on launch")
    func invalidDataRecovery() throws {
        try withDefaults { defaults in
            let invalid = Data("invalid".utf8)
            defaults.set(invalid, forKey: "wishlist.cities.v1")
            #expect(WishlistStore(defaults: defaults).cities.isEmpty)
            #expect(defaults.data(forKey: "wishlist.cities.v1") == invalid)
        }
    }
}
