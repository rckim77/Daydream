import Foundation
import Testing

@testable import Daydream

@Suite("Wishlist continent filters")
struct WishlistContinentFilterTests {
    @Test("filters offer All and the six inhabited continents")
    func availableFilters() {
        #expect(WishlistContinentFilter.allCases == [.all, .asia, .northAmerica, .southAmerica, .europe, .africa, .oceania])
        #expect(WishlistContinentFilter.northAmerica.name == "North America")
        #expect(WishlistContinentFilter.southAmerica.name == "South America")
    }

    @Test("country classification includes Central America, the Caribbean, and countries outside discovery")
    func countryClassification() {
        let countries: [WishlistContinentFilter: [String]] = [
            .asia: ["JP", "CN", "HK", "MO", "IN", "TR", "AZ"],
            .northAmerica: ["US", "CA", "MX", "CR", "PA", "DO", "PR", "JM"],
            .southAmerica: ["BR", "AR", "PE", "CL", "CO"],
            .europe: ["FR", "GB", "DE", "CH", "RU", "IS"],
            .africa: ["EG", "MA", "KE", "ZA"],
            .oceania: ["AU", "NZ", "FJ"]
        ]
        for (continent, codes) in countries {
            for code in codes {
                #expect(WishlistContinentFilter.continent(for: code) == continent, "Unexpected continent for \(code)")
            }
        }
        #expect(WishlistContinentFilter.continent(for: "jp") == .asia)
        #expect(WishlistContinentFilter.continent(for: "AQ") == nil)
        #expect(WishlistContinentFilter.continent(for: "ZZ") == nil)
    }

    @Test("every curated country has a continent, including abbreviated country names")
    func curatedCoverage() throws {
        let url = try #require(Bundle.main.url(forResource: "randomCitiesJSON", withExtension: "json"))
        let cities = try JSONDecoder().decode([RandomCity].self, from: Data(contentsOf: url))
        for section in WishlistCountrySection.group(cities) {
            let code = try #require(section.countryCode, "Missing country code for \(section.country)")
            #expect(WishlistContinentFilter.continent(for: code) != nil, "Missing continent for \(section.country)")
        }
    }

    @Test("filtering preserves sorted country groups and excludes other continents")
    func groupedFiltering() {
        let cities = [
            RandomCity(city: "Tokyo", country: "Japan", latitude: 35, longitude: 139, radius: 10),
            RandomCity(city: "Lyon", country: "France", latitude: 45, longitude: 4, radius: 10),
            RandomCity(city: "Paris", country: "France", latitude: 48, longitude: 2, radius: 10),
            RandomCity(city: "London", country: "UK", latitude: 51, longitude: 0, radius: 10),
            RandomCity(city: "Reykjavík", country: "Iceland", latitude: 64, longitude: -21, radius: 10, countryCode: "IS")
        ]
        let sections = WishlistCountrySection.group(cities)
        let europe = WishlistContinentFilter.europe.sections(from: sections)
        #expect(europe.map(\.country) == ["France", "Iceland", "United Kingdom"])
        #expect(europe.first?.cities.map(\.city) == ["Lyon", "Paris"])
        #expect(WishlistContinentFilter.asia.sections(from: sections).map(\.country) == ["Japan"])
        #expect(WishlistContinentFilter.africa.sections(from: sections).isEmpty)
        #expect(WishlistContinentFilter.all.sections(from: sections) == sections)
    }

    @Test("All retains unclassified cities and Antarctica without adding a continent filter for them")
    func unclassifiedCities() {
        let cities = [
            RandomCity(city: "Unknown", country: "Other destinations", latitude: 0, longitude: 0, radius: 10),
            RandomCity(city: "Station", country: "Antarctica", latitude: -80, longitude: 0, radius: 10, countryCode: "AQ")
        ]
        let sections = WishlistCountrySection.group(cities)
        #expect(WishlistContinentFilter.all.sections(from: sections) == sections)
        for filter in WishlistContinentFilter.allCases where filter != .all {
            #expect(filter.sections(from: sections).isEmpty)
        }
    }
}
