import Foundation

struct WishlistPlace: Codable, Equatable, Identifiable {
    enum Kind: String, Codable, CaseIterable {
        case sight
        case eatery
    }

    let placeID: String
    let kind: Kind

    var id: String { placeID }
}
