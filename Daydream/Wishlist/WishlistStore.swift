import Foundation
import Observation

/// Stores only Daydream's curated city data. Photos and Google place responses remain transient.
@MainActor
@Observable
final class WishlistStore {
    private(set) var cities: [RandomCity]
    private(set) var countrySections: [WishlistCountrySection]

    @ObservationIgnored private let defaults: UserDefaults
    private static let storageKey = "wishlist.cities.v1"

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
