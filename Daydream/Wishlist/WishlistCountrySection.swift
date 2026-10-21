import Foundation

struct WishlistCountrySection: Identifiable, Equatable {
    let country: String
    let cities: [RandomCity]

    var id: String { country }
    var countryCode: String? {
        // Curated countries already have flag codes; searched cities carry their ISO country code.
        if let flag = Self.flags[country] {
            let scalars = flag.unicodeScalars.compactMap { Unicode.Scalar($0.value - 127397) }
            return String(String.UnicodeScalarView(scalars))
        }
        return cities.compactMap(\.countryCode).map { $0.uppercased() }.first {
            $0.utf8.count == 2 && $0.utf8.allSatisfy { (65...90).contains($0) }
        }
    }

    var flag: String? {
        guard let code = countryCode else { return nil }
        return String(String.UnicodeScalarView(code.unicodeScalars.compactMap { Unicode.Scalar(127397 + $0.value) }))
    }

    static func countryName(_ country: String) -> String {
        switch country {
        case "UK": "United Kingdom"
        case "USA": "United States"
        case "UAE": "United Arab Emirates"
        case "Czechia": "Czech Republic"
        default: country
        }
    }

    static func group(_ cities: [RandomCity]) -> [Self] {
        let groups = Dictionary(grouping: cities) { city in
            // The seed data contains both abbreviated and full country names.
            countryName(city.country)
        }
        return groups.map { country, cities in
            Self(country: country, cities: cities.sorted {
                $0.city.localizedStandardCompare($1.city) == .orderedAscending
            })
        }.sorted { $0.country.localizedStandardCompare($1.country) == .orderedAscending }
    }

    // Explicit flags cover the curated dataset without depending on the device's language.
    private static let flags = [
        "Argentina": "🇦🇷", "Australia": "🇦🇺", "Austria": "🇦🇹", "Azerbaijan": "🇦🇿",
        "Belgium": "🇧🇪", "Brazil": "🇧🇷", "Bulgaria": "🇧🇬", "Cambodia": "🇰🇭",
        "Canada": "🇨🇦", "China": "🇨🇳", "Czech Republic": "🇨🇿", "Denmark": "🇩🇰",
        "Dominican Republic": "🇩🇴", "Egypt": "🇪🇬", "France": "🇫🇷", "Germany": "🇩🇪",
        "Greece": "🇬🇷", "Hong Kong": "🇭🇰", "Hungary": "🇭🇺", "India": "🇮🇳",
        "Indonesia": "🇮🇩", "Ireland": "🇮🇪", "Italy": "🇮🇹", "Japan": "🇯🇵",
        "Jordan": "🇯🇴", "Kenya": "🇰🇪", "Macau": "🇲🇴", "Malaysia": "🇲🇾",
        "Mexico": "🇲🇽", "Morocco": "🇲🇦", "Netherlands": "🇳🇱", "New Zealand": "🇳🇿",
        "Peru": "🇵🇪", "Philippines": "🇵🇭", "Poland": "🇵🇱", "Portugal": "🇵🇹",
        "Qatar": "🇶🇦", "Romania": "🇷🇴", "Russia": "🇷🇺", "Saudi Arabia": "🇸🇦",
        "Singapore": "🇸🇬", "South Korea": "🇰🇷", "Spain": "🇪🇸", "Switzerland": "🇨🇭",
        "Taiwan": "🇹🇼", "Thailand": "🇹🇭", "Turkey": "🇹🇷", "United Arab Emirates": "🇦🇪",
        "United Kingdom": "🇬🇧", "United States": "🇺🇸", "Vietnam": "🇻🇳"
    ]
}
