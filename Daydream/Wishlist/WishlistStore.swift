import CoreLocation
import Foundation
import Observation

/// Persists city metadata and place bookmarks, never Google responses or photos.
@MainActor
@Observable
final class WishlistStore {
    private(set) var cities: [RandomCity]
    private(set) var countrySections: [WishlistCountrySection]
    private(set) var placesByCity: [RandomCity.ID: [WishlistPlace]]

    @ObservationIgnored private let defaults: UserDefaults
    private static let storageKey = "wishlist.v2"
    private static let legacyStorageKey = "wishlist.cities.v1"

    private struct Snapshot: Codable {
        let cities: [RandomCity]
        let placesByCity: [RandomCity.ID: [WishlistPlace]]
    }
    private static let curatedCities: [RandomCity] = {
        guard let url = Bundle.main.url(forResource: "randomCitiesJSON", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cities = try? JSONDecoder().decode([RandomCity].self, from: data) else { return [] }
        return cities
    }()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let snapshot = defaults.data(forKey: Self.storageKey)
            .flatMap { try? JSONDecoder().decode(Snapshot.self, from: $0) }
        let saved = snapshot?.cities ?? defaults.data(forKey: Self.legacyStorageKey)
            .flatMap { try? JSONDecoder().decode([RandomCity].self, from: $0) } ?? []
        var seen = Set<RandomCity.ID>()
        let uniqueCities = saved.filter { seen.insert($0.id).inserted }
        cities = uniqueCities
        countrySections = WishlistCountrySection.group(uniqueCities)
        var restoredPlaces: [RandomCity.ID: [WishlistPlace]] = [:]
        for city in uniqueCities {
            var seenPlaceIDs = Set<String>()
            restoredPlaces[city.id] = snapshot?.placesByCity[city.id]?.filter {
                !$0.placeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    && seenPlaceIDs.insert($0.placeID).inserted
            }
        }
        placesByCity = restoredPlaces
    }

    func contains(_ city: RandomCity) -> Bool {
        cities.contains { $0.id == city.id }
    }

    func resolve(_ city: RandomCity, sourceCity: RandomCity? = nil) -> RandomCity {
        // Preserve route identity when Places changes the city name or center.
        if let sourceCity { return sourceCity }
        if let placeID = city.placeID,
           let saved = cities.first(where: { $0.placeID == placeID }) { return saved }

        let location = CLLocation(latitude: city.latitude, longitude: city.longitude)
        let candidates = (cities + Self.curatedCities).filter {
            WishlistCountrySection.countryName($0.country) == WishlistCountrySection.countryName(city.country)
                && Self.matchingName($0.city) == Self.matchingName(city.city)
        }
        // Match nearby centers without merging distant namesakes.
        if let match = candidates.min(by: {
            location.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))
                < location.distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude))
        }), location.distance(from: CLLocation(latitude: match.latitude, longitude: match.longitude)) <= max(1, match.radius) * 1000 {
            return match
        }
        return city
    }

    private static func matchingName(_ name: String) -> String {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
        return normalized == "new york city" ? "new york" : normalized
    }

    func toggle(_ city: RandomCity) {
        if contains(city) {
            cities.removeAll { $0.id == city.id }
            placesByCity[city.id] = nil
        } else {
            cities.insert(city, at: 0)
        }
        persist()
    }

    func remove(_ removedCities: [RandomCity]) {
        // Section offsets differ from storage order, so remove by stable city identity.
        let removedIDs = Set(removedCities.map(\.id))
        cities.removeAll { removedIDs.contains($0.id) }
        placesByCity = placesByCity.filter { !removedIDs.contains($0.key) }
        persist()
    }

    func places(in city: RandomCity) -> [WishlistPlace] {
        placesByCity[city.id] ?? []
    }

    func contains(placeID: String, in city: RandomCity) -> Bool {
        places(in: city).contains { $0.placeID == placeID }
    }

    func togglePlace(placeID: String, kind: WishlistPlace.Kind, in city: RandomCity) {
        guard !placeID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if contains(placeID: placeID, in: city) {
            removePlace(placeID: placeID, from: city)
            return
        }
        // Save the parent and bookmark together so a relaunch cannot leave orphaned places.
        if !contains(city) { cities.insert(city, at: 0) }
        placesByCity[city.id, default: []].append(WishlistPlace(placeID: placeID, kind: kind))
        persist()
    }

    func removePlace(placeID: String, from city: RandomCity) {
        placesByCity[city.id]?.removeAll { $0.placeID == placeID }
        // Removing the last place keeps the city the user has already saved.
        if placesByCity[city.id]?.isEmpty == true { placesByCity[city.id] = nil }
        persist()
    }

    private func persist() {
        countrySections = WishlistCountrySection.group(cities)
        let snapshot = Snapshot(cities: cities, placesByCity: placesByCity)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
