import Foundation

enum CountryFlagPalette {
    static let fallback: [UInt32] = [0x586576, 0xA3ADBA]

    static func colors(for countryCode: String?) -> [UInt32] {
        let code = countryCode?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let red: UInt32 = 0xCE1126
        let white: UInt32 = 0xFFFFFF
        let blue: UInt32 = 0x003DA5
        let green: UInt32 = 0x00843D
        let yellow: UInt32 = 0xFEDD00
        let black: UInt32 = 0x171717

        switch code {
        case "US", "GB", "AU", "NZ", "FR", "NL", "CZ", "SK", "HR", "RS", "DO", "CU", "CR", "PA", "PR", "IS", "NO", "LU":
            return [blue, white, red]
        case "RU", "SI":
            return [white, blue, red]
        case "AT", "CA", "PE", "LV":
            return [red, white, red]
        case "JP":
            return [white, red, white]
        case "DK", "CH", "TR", "HK", "SG", "ID", "MC", "PL", "TN", "GE":
            return [red, white]
        case "CN", "VN":
            return [red, yellow]
        case "TW":
            return [red, blue, white]
        case "KR":
            return [white, red, blue, black]
        case "TH":
            return [red, white, blue, white, red]
        case "MY", "PH":
            return [blue, red, white, yellow]
        case "KH":
            return [blue, red, white, red, blue]
        case "IN", "NE":
            return [0xFF9933, white, green]
        case "IE", "CI":
            return [green, white, 0xFF883E]
        case "IT", "MX", "HU", "IR", "BG":
            return [green, white, red]
        case "DE", "BE":
            return [black, red, yellow]
        case "RO", "MD", "TD", "AD", "CO", "EC", "VE":
            return [blue, yellow, red]
        case "ES":
            return [red, yellow, red]
        case "PT", "CM", "SN", "GH", "ET", "BO", "LT", "MM":
            return [green, yellow, red]
        case "BR":
            return [green, yellow, blue]
        case "AR", "UY":
            return [0x74ACDF, white, 0x74ACDF]
        case "GR", "FI", "IL", "HN", "GT", "SV":
            return [blue, white]
        case "SE", "UA", "KZ":
            return [blue, yellow]
        case "AZ":
            return [0x00B5E2, red, green]
        case "SA", "PK", "NG", "DZ":
            return [green, white]
        case "MO":
            return [green, white, yellow]
        case "MA", "BD":
            return [red, green]
        case "QA":
            return [0x8A1538, white]
        case "AE", "JO", "KW", "PS", "OM", "SD":
            return [red, green, white, black]
        case "KE":
            return [black, red, green, white]
        case "EG":
            return [red, white, yellow, black]
        case "ZA":
            return [red, green, yellow, black, white, blue]
        case "JM":
            return [green, yellow, black]
        default:
            return fallback
        }
    }
}
