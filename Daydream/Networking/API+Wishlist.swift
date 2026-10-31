import Foundation
import GooglePlaces

extension API.PlaceSearch {
    @MainActor
    static func fetchWishlistPlaceBy(placeID: String) async throws -> MapPlace {
        try Task.checkCancellation()
        // Use the main-thread callback API to avoid the Swift SDK's async bridge thread hop.
        return try await withCheckedThrowingContinuation { continuation in
            let request = GMSFetchPlaceRequest(
                placeID: placeID,
                placeProperties: [GMSPlaceProperty.placeID.rawValue, GMSPlaceProperty.name.rawValue,
                                  GMSPlaceProperty.coordinate.rawValue],
                sessionToken: nil
            )
            GMSPlacesClient.shared().fetchPlace(with: request) { place, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let place, let name = place.name {
                    continuation.resume(returning: MapPlace(
                        placeID: place.placeID ?? placeID, displayName: name, location: place.coordinate
                    ))
                } else {
                    continuation.resume(throwing: APIError.noResults)
                }
            }
        }
    }
}
