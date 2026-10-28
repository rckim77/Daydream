import Foundation

struct RandomCityCatalog {
    let cities: [RandomCity]

    init(data: Data) throws {
        cities = try JSONCustomDecoder().decode([RandomCity].self, from: data)
    }

    static func load(bundle: Bundle = .main) throws -> Self {
        guard let url = bundle.url(forResource: "randomCitiesJSON", withExtension: "json") else {
            throw APIError.bundleError
        }
        return try Self(data: Data(contentsOf: url))
    }

    var randomCity: RandomCity? { cities.randomElement() }

    func discoveryCities(count: Int, preferredNames: [String] = []) -> [RandomCity] {
        var seen = Set<String>()
        let preferred = preferredNames.compactMap { name in cities.first { $0.city == name } }
        // A finite pass handles empty or undersized catalogs without blocking launch.
        return Array((preferred + cities.shuffled()).filter { seen.insert($0.city).inserted }
            .prefix(max(0, count)))
    }
}
