import Foundation
import GooglePlaces

extension API.PlaceSearch {
    @MainActor
    static func fetchWishlistPlaceBy(placeID: String) async throws -> MapPlace {
        try Task.checkCancellation()
        // The Swift SDK's async fetch can hop off-main inside its Obj-C bridge. Start the
        // callback API on main and return only value data needed for the bookmark and map.
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
