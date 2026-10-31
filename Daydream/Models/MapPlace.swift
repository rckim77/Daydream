import CoreLocation
import Foundation
import GooglePlacesSwift

struct MapPlace: Identifiable, Sendable {
    let id = UUID()
    let placeID: String?
    let displayName: String?
    let location: CLLocationCoordinate2D

    init(place: Place) {
        placeID = place.placeID
        displayName = place.displayName
        location = place.location
    }

    init(placeID: String, displayName: String, location: CLLocationCoordinate2D) {
        self.placeID = placeID
        self.displayName = displayName
        self.location = location
    }
}
