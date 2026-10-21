import CoreLocation
import Foundation
import Observation

/// Stores city metadata only. Photos and Google place responses remain transient.
@MainActor
@Observable
final class WishlistStore {
    private(set) var cities: [RandomCity]
    private(set) var countrySections: [WishlistCountrySection]

    @ObservationIgnored private let defaults: UserDefaults
    private static let storageKey = "wishlist.cities.v1"
    private static let curatedCities: [RandomCity] = {
        guard let url = Bundle.main.url(forResource: "randomCitiesJSON", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cities = try? JSONDecoder().decode([RandomCity].self, from: data) else { return [] }
        return cities
    }()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let saved = defaults.data(forKey: Self.storageKey)
            .flatMap { try? JSONDecoder().decode([RandomCity].self, from: $0) } ?? []
        var seen = Set<RandomCity.ID>()
        let uniqueCities = saved.filter { seen.insert($0.id).inserted }
        cities = uniqueCities
        countrySections = WishlistCountrySection.group(uniqueCities)
    }

    func contains(_ city: RandomCity) -> Bool {
        cities.contains { $0.id == city.id }
    }

    func resolve(_ city: RandomCity, sourceCity: RandomCity? = nil) -> RandomCity {
        // Preserve a card/list route's identity even when Places uses a different city name or center.
        if let sourceCity { return sourceCity }
        if let placeID = city.placeID,
           let saved = cities.first(where: { $0.placeID == placeID }) { return saved }

        let location = CLLocation(latitude: city.latitude, longitude: city.longitude)
        let candidates = (cities + Self.curatedCities).filter {
            WishlistCountrySection.countryName($0.country) == WishlistCountrySection.countryName(city.country)
                && Self.matchingName($0.city) == Self.matchingName(city.city)
        }
        // Searches can return a slightly different center; reuse the saved/curated identity within its city radius.
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
        } else {
            cities.insert(city, at: 0)
        }
        persist()
    }

    func remove(_ removedCities: [RandomCity]) {
        // Section offsets differ from storage order, so remove by stable city identity.
        let removedIDs = Set(removedCities.map(\.id))
        cities.removeAll { removedIDs.contains($0.id) }
        persist()
    }

    private func persist() {
        countrySections = WishlistCountrySection.group(cities)
        guard let data = try? JSONEncoder().encode(cities) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
