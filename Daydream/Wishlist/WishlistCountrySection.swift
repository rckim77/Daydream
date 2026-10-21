import Foundation

struct WishlistCountrySection: Identifiable, Equatable {
    let country: String
    let cities: [RandomCity]

    var id: String { country }
    var flag: String? { Self.flags[country] }

    static func group(_ cities: [RandomCity]) -> [Self] {
        let groups = Dictionary(grouping: cities) { city in
            // The seed data contains both abbreviated and full country names.
            switch city.country {
            case "UK": "United Kingdom"
            case "USA": "United States"
            case "UAE": "United Arab Emirates"
            default: city.country
            }
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
