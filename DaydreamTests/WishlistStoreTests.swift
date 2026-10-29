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

    @Test("detail routes keep the original favorite identity despite Places naming differences")
    func detailSourceIdentity() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            store.toggle(paris)
            let placeCity = RandomCity(city: "Paris Centre", country: "France", latitude: 48.86, longitude: 2.36,
                                       radius: 10, placeID: "paris-place", countryCode: "FR")
            let detailCity = store.resolve(placeCity, sourceCity: paris)
            #expect(store.contains(detailCity))
            store.toggle(detailCity)
            #expect(!store.contains(paris))
            store.toggle(detailCity)
            #expect(WishlistStore(defaults: defaults).cities == [paris])
        }
    }

    @Test("searched cities reuse curated identities and favorites across slightly different centers")
    func searchedCuratedIdentity() throws {
        try withDefaults { defaults in
            let url = try #require(Bundle.main.url(forResource: "randomCitiesJSON", withExtension: "json"))
            let curated = try JSONDecoder().decode([RandomCity].self, from: Data(contentsOf: url))
            let newYork = try #require(curated.first { $0.city == "New York City" })
            let store = WishlistStore(defaults: defaults)
            let search = RandomCity(city: "New York", country: "United States", latitude: newYork.latitude + 0.001,
                                    longitude: newYork.longitude, radius: 10, placeID: "new-york-place", countryCode: "US")
            let resolved = store.resolve(search)
            #expect(resolved.id == newYork.id)
            store.toggle(resolved)
            #expect(store.contains(newYork))
            let restored = WishlistStore(defaults: defaults)
            restored.toggle(restored.resolve(search))
            #expect(restored.cities.isEmpty)
        }
    }

    @Test("cities outside discovery retain their place IDs and flags across launches")
    func searchedCityPersistence() throws {
        try withDefaults { defaults in
            let reykjavik = RandomCity(city: "Reykjavík", country: "Iceland", latitude: 64.1466, longitude: -21.9426,
                                      radius: 10, placeID: "reykjavik-place", countryCode: "IS")
            let store = WishlistStore(defaults: defaults)
            store.toggle(store.resolve(reykjavik))
            let restored = WishlistStore(defaults: defaults)
            #expect(restored.cities == [reykjavik])
            #expect(restored.countrySections.first?.flag == "🇮🇸")
            let updatedPlace = RandomCity(city: "Reykjavik", country: "Iceland", latitude: 64.15, longitude: -21.95,
                                         radius: 10, placeID: "reykjavik-place", countryCode: "IS")
            let detailCity = restored.resolve(updatedPlace)
            #expect(restored.contains(detailCity))
            restored.toggle(detailCity)
            #expect(WishlistStore(defaults: defaults).cities.isEmpty)
        }
    }

    @Test("city matching distinguishes distant namesakes and folds accents for nearby saved cities")
    func searchedNamesakes() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            let saved = RandomCity(city: "San José", country: "Costa Rica", latitude: 9.93, longitude: -84.08, radius: 10)
            store.toggle(saved)
            let nearby = RandomCity(city: "San Jose", country: "Costa Rica", latitude: 9.931, longitude: -84.081, radius: 10)
            #expect(store.resolve(nearby).id == saved.id)
            let distant = RandomCity(city: "San Jose", country: "Costa Rica", latitude: 10.5, longitude: -85.0, radius: 10)
            #expect(store.resolve(distant).id == distant.id)
            #expect(!store.contains(store.resolve(distant)))
        }
    }

    @Test("favorites saved before detail support still decode with the same identity")
    func legacyFavoriteCompatibility() throws {
        try withDefaults { defaults in
            let json = #"[{"city":"Paris","country":"France","latitude":48.85,"longitude":2.35,"radius":10}]"#
            defaults.set(Data(json.utf8), forKey: "wishlist.cities.v1")
            let store = WishlistStore(defaults: defaults)
            #expect(store.cities == [paris])
            #expect(store.cities.first?.placeID == nil)
            #expect(store.contains(store.resolve(paris)))
        }
    }

    @Test("deleting from a continent filter preserves hidden favorites and reflects later additions")
    func filteredDeletion() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            store.toggle(paris)
            store.toggle(tokyo)
            let visibleSections = WishlistContinentFilter.europe.sections(from: store.countrySections)
            let france = try #require(visibleSections.first)
            store.remove([france.cities[0]])
            #expect(WishlistContinentFilter.europe.sections(from: store.countrySections).isEmpty)
            #expect(store.contains(tokyo))
            #expect(WishlistStore(defaults: defaults).cities == [tokyo])
            store.toggle(paris)
            #expect(WishlistContinentFilter.europe.sections(from: store.countrySections).first?.cities == [paris])
        }
    }

    @Test("saving a sight or eatery also saves its city and restores both together")
    func placeAutoSavesCity() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            store.togglePlace(placeID: "tower", kind: .sight, in: paris)
            store.togglePlace(placeID: "cafe", kind: .eatery, in: paris)
            #expect(store.cities == [paris])
            let restored = WishlistStore(defaults: defaults)
            #expect(restored.contains(paris))
            #expect(restored.places(in: paris) == [
                WishlistPlace(placeID: "tower", kind: .sight),
                WishlistPlace(placeID: "cafe", kind: .eatery)
            ])
        }
    }

    @Test("removing the last place keeps its city favorited across relaunch")
    func removeLastPlace() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            store.togglePlace(placeID: "tower", kind: .sight, in: paris)
            store.togglePlace(placeID: "tower", kind: .sight, in: paris)
            let restored = WishlistStore(defaults: defaults)
            #expect(restored.contains(paris))
            #expect(restored.places(in: paris).isEmpty)
        }
    }

    @Test("place identity is unique within a city and remains scoped to that city")
    func placeIdentityAndCityScope() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            store.togglePlace(placeID: "shared", kind: .sight, in: paris)
            store.togglePlace(placeID: "shared", kind: .eatery, in: tokyo)
            #expect(store.contains(placeID: "shared", in: paris))
            #expect(store.contains(placeID: "shared", in: tokyo))
            // The same place appearing in another carousel toggles the existing bookmark.
            store.togglePlace(placeID: "shared", kind: .eatery, in: paris)
            #expect(store.places(in: paris).isEmpty)
            #expect(store.places(in: tokyo).count == 1)
        }
    }

    @Test("removing a city removes its places without changing another city")
    func cascadingCityRemoval() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            store.togglePlace(placeID: "tower", kind: .sight, in: paris)
            store.togglePlace(placeID: "cafe", kind: .eatery, in: tokyo)
            store.remove([paris])
            let restored = WishlistStore(defaults: defaults)
            #expect(restored.cities == [tokyo])
            #expect(restored.places(in: paris).isEmpty)
            #expect(restored.contains(placeID: "cafe", in: tokyo))
            // Re-adding a removed city must not resurrect its old bookmarks.
            restored.toggle(paris)
            #expect(restored.places(in: paris).isEmpty)
            restored.toggle(tokyo)
            #expect(WishlistStore(defaults: defaults).places(in: tokyo).isEmpty)
        }
    }

    @Test("adding places migrates legacy city favorites without losing them")
    func migrateLegacyCities() throws {
        try withDefaults { defaults in
            defaults.set(try JSONEncoder().encode([tokyo, paris]), forKey: "wishlist.cities.v1")
            let store = WishlistStore(defaults: defaults)
            store.togglePlace(placeID: "tower", kind: .sight, in: paris)
            let restored = WishlistStore(defaults: defaults)
            #expect(restored.cities == [tokyo, paris])
            #expect(restored.contains(placeID: "tower", in: paris))
            #expect(defaults.data(forKey: "wishlist.v2") != nil)
            restored.remove([tokyo, paris])
            let empty = WishlistStore(defaults: defaults)
            #expect(empty.cities.isEmpty, "A migrated empty wishlist must not resurrect legacy favorites")
            #expect(empty.placesByCity.isEmpty)
        }
    }

    @Test("empty place IDs cannot create bookmarks or automatically favorite a city")
    func invalidPlaceID() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            store.togglePlace(placeID: "  ", kind: .sight, in: paris)
            #expect(store.cities.isEmpty)
            #expect(store.placesByCity.isEmpty)
        }
    }

    @Test("bookmark storage contains only the place ID and user category")
    func bookmarkStorageFields() throws {
        try withDefaults { defaults in
            let store = WishlistStore(defaults: defaults)
            store.togglePlace(placeID: "tower", kind: .sight, in: paris)
            let data = try #require(defaults.data(forKey: "wishlist.v2"))
            let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
            let cities = try #require(json["placesByCity"] as? [String: [[String: Any]]])
            let bookmark = try #require(cities[paris.id]?.first)
            #expect(Set(bookmark.keys) == ["placeID", "kind"])
        }
    }

}
