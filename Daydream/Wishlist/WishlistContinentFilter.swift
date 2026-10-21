import Foundation

enum WishlistContinentFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case asia = "Asia"
    case northAmerica = "N. America"
    case southAmerica = "S. America"
    case europe = "Europe"
    case africa = "Africa"
    case oceania = "Oceania"

    var id: Self { self }

    var name: String {
        switch self {
        case .northAmerica: "North America"
        case .southAmerica: "South America"
        default: rawValue
        }
    }

    func sections(from sections: [WishlistCountrySection]) -> [WishlistCountrySection] {
        guard self != .all else { return sections }
        return sections.filter { section in
            guard let code = section.countryCode else { return false }
            return Self.continent(for: code) == self
        }
    }

    static func continent(for countryCode: String) -> Self? {
        let code = countryCode.uppercased()
        guard code != "AQ" else { return nil }
        let region = Locale.Region(code)
        // UN regions group Central America and the Caribbean under North America.
        switch region.continent?.identifier {
        case "142": return .asia
        case "150": return .europe
        case "002": return .africa
        case "009": return .oceania
        case "019": return region.subcontinent?.identifier == "005" ? .southAmerica : .northAmerica
        default: return nil
        }
    }
}
