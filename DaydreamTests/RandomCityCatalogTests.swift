import Foundation
import Testing

@testable import Daydream

@Suite("RandomCityCatalog")
struct RandomCityCatalogTests {
    private func catalog(_ cities: [RandomCity]) throws -> RandomCityCatalog {
        try RandomCityCatalog(data: JSONEncoder().encode(cities))
    }

    private func city(_ name: String, country: String = "France") -> RandomCity {
        RandomCity(city: name, country: country, latitude: 48.85, longitude: 2.35, radius: 10)
    }

    @Test("empty catalogs produce no random city or discovery cards")
    func emptyCatalog() throws {
        let catalog = try catalog([])
        #expect(catalog.randomCity == nil)
        #expect(catalog.discoveryCities(count: 8).isEmpty)
    }

    @Test("short catalogs finish with the available distinct city names")
    func shortAndDuplicateCatalog() throws {
        let paris = city("Paris")
        let lyon = city("Lyon")
        let catalog = try catalog([paris, paris, city("Paris", country: "USA"), lyon])
        let selected = catalog.discoveryCities(count: 8)
        #expect(selected.count == 2)
        #expect(Set(selected.map(\.city)) == ["Paris", "Lyon"])
        #expect(catalog.randomCity != nil)
    }

    @Test("discovery respects its limit and preserves capture order without duplicates")
    func preferredCities() throws {
        let catalog = try catalog((0..<12).map { city("City \($0)") })
        let selected = catalog.discoveryCities(count: 8, preferredNames: ["City 3", "missing", "City 3", "City 1"])
        #expect(selected.count == 8)
        #expect(Set(selected.map(\.city)).count == 8)
        #expect(Array(selected.prefix(2)).map(\.city) == ["City 3", "City 1"])
        #expect(catalog.discoveryCities(count: 0).isEmpty)
    }

    @Test("unreadable or missing catalogs fail instead of entering selection")
    func invalidCatalog() {
        #expect(throws: (any Error).self) {
            _ = try RandomCityCatalog(data: Data("invalid JSON".utf8))
        }
        #expect(throws: (any Error).self) {
            _ = try RandomCityCatalog.load(bundle: Bundle(for: NSObject.self))
        }
    }

    @Test("the shipped catalog supplies eight distinct discovery cities")
    func bundledCatalog() throws {
        let catalog = try RandomCityCatalog.load()
        #expect(catalog.discoveryCities(count: 8).count == 8)
        #expect(catalog.randomCity != nil)
    }
}
