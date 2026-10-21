import Foundation
import Observation
import SwiftUI

/// Stores only Daydream's curated city data. Photos and Google place responses remain transient.
@MainActor
@Observable
final class WishlistStore {
    private(set) var cities: [RandomCity]

    @ObservationIgnored private let defaults: UserDefaults
    private static let storageKey = "wishlist.cities.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let saved = defaults.data(forKey: Self.storageKey)
            .flatMap { try? JSONDecoder().decode([RandomCity].self, from: $0) } ?? []
        var seen = Set<RandomCity.ID>()
        cities = saved.filter { seen.insert($0.id).inserted }
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

    func remove(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
        persist()
    }

    func move(from offsets: IndexSet, to destination: Int) {
        cities.move(fromOffsets: offsets, toOffset: destination)
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
