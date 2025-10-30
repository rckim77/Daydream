//
//  API+PlaceSearch.swift
//  Daydream
//
//  Created by Raymond Kim on 6/17/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlacesSwift
import MapKit

enum APIError: Error {
    case biasError, bundleError, imageDataError, missingViewport, noResults
}

extension API {
    enum PlaceSearch {

        enum PlaceSearchType {
            case sights, eateries
        }
        
        /// Convenience function that will pick a random city, fetch `Place` data, and also return
        /// a `UIImage` representation of the first photo if present.
        static func fetchRandomCity() async throws -> (Place, UIImage?) {
            guard let path = Bundle.main.path(forResource: "randomCitiesJSON", ofType: "json") else {
                throw APIError.bundleError
            }

            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let randomCities = try JSONCustomDecoder().decode([RandomCity].self, from: data)
            let randomIndex = Int(arc4random_uniform(UInt32(randomCities.count)))
            let fullCityName = "\(randomCities[randomIndex].city), \(randomCities[randomIndex].country)"
            
            guard let place = await API.PlaceSearch.fetchCityBy(name: fullCityName) else {
                throw APIError.noResults
            }
            
            if let photo = place.photos?.first {
                let image = await API.PlaceSearch.fetchImageBy(photo: photo)
                return (place, image)
            } else {
                return (place, nil)
            }
        }
        
        static func fetchPlaceAndImageBy(name: String) async throws -> (Place, UIImage) {
            guard let place = await API.PlaceSearch.fetchCityBy(name: name) else {
                throw APIError.noResults
            }
            
            if let photo = place.photos?.first {
                let image = await API.PlaceSearch.fetchImageBy(photo: photo)
                guard let image = image else {
                    throw APIError.noResults
                }
                return (place, image)
            } else {
                throw APIError.noResults
            }
        }
        
        
        static func fetchPlaceAndImageBy(placeId: String) async throws -> (Place, UIImage) {
            let fetchPlaceRequest = FetchPlaceRequest(
                placeID: placeId,
                placeProperties: [.placeID, .coordinate, .photos, .displayName, .reviewSummary]
            )
            
            switch await PlacesClient.shared.fetchPlace(with: fetchPlaceRequest) {
            case .success(let place):
                if let photo = place.photos?.first {
                    let image = await API.PlaceSearch.fetchImageBy(photo: photo)
                    guard let image = image else {
                        throw APIError.noResults
                    }
                    return (place, image)
                } else {
                    throw APIError.noResults
                }
            case .failure(let error):
                print(error.localizedDescription)
                throw APIError.noResults
            }
        }
        
        static func fetchCityBy(name: String) async -> Place? {
            // this is unfortunately a required param even though we don't need one...
            guard let neutralBias = RectangularCoordinateRegion(
                northEast: CLLocationCoordinate2D(latitude: 85, longitude: 180),
                southWest: CLLocationCoordinate2D(latitude: -85, longitude: 0)
            ) else {
                return nil
            }
            let request = SearchByTextRequest(
                textQuery: name,
                placeProperties: [.displayName, .formattedAddress, .coordinate, .photos, .placeID, .addressComponents],
                locationBias: neutralBias
            )
            
            switch await PlacesClient.shared.searchByText(with: request) {
            case .success(let places):
                return places.first
            case .failure(let error):
                print(error.localizedDescription)
                return nil
            }
        }
        
        static func fetchPlaceWithReviewsBy(placeId: String) async -> Place? {
            let fetchPlaceRequest = FetchPlaceRequest(
                placeID: placeId,
                placeProperties: [.placeID, .coordinate, .reviews, .reviewSummary, .formattedAddress]
            )
            
            switch await PlacesClient.shared.fetchPlace(with: fetchPlaceRequest) {
            case .success(let place):
                return place
            case .failure(let error):
                print(error.localizedDescription)
                return nil
            }
        }
        
        static func fetchImageBy(photo: Photo) async -> UIImage? {
            let fetchPhotoRequest = FetchPhotoRequest(photo: photo, maxSize: photo.maxSize)
            switch await PlacesClient.shared.fetchPhoto(with: fetchPhotoRequest) {
            case .success(let image):
                return image
            case .failure(let error):
                print(error.localizedDescription)
                return nil
            }
        }
        
        static func fetchPlacesFor(placeId: String, type: PlaceSearch.PlaceSearchType, maxResultCount: Int) async throws -> [Place] {
            let fetchPlaceRequest = FetchPlaceRequest(
                placeID: placeId,
                placeProperties: [.placeID, .coordinate, .viewportInfo]
            )
            
            switch await PlacesClient.shared.fetchPlace(with: fetchPlaceRequest) {
            case .success(let place):
                let restriction = API.PlaceSearch.getPlaceRestriction(location: place.location, viewport: place.viewportInfo)
                let placeProps: [PlaceProperty]
                let includedTypes: Set<PlaceType>
                let excludedTypes: Set<PlaceType>
                switch type {
                    case .sights:
                        placeProps = [.photos, .displayName, .placeID, .coordinate, .reviewSummary]
                        includedTypes = [.touristAttraction, .park, .museum]
                        excludedTypes = [.restaurant]
                    case .eateries:
                        placeProps = [.photos, .displayName, .placeID, .coordinate, .priceLevel, .reviewSummary]
                        includedTypes = [.restaurant]
                        excludedTypes = [.touristAttraction, .park, .museum]
                }
                let request = SearchNearbyRequest(
                    locationRestriction: restriction,
                    placeProperties: placeProps,
                    includedTypes: includedTypes,
                    excludedTypes: excludedTypes,
                    maxResultCount: maxResultCount
                )
                switch await PlacesClient.shared.searchNearby(with: request) {
                case .success(let places):
                    return places
                case .failure(let error):
                    print(error.localizedDescription)
                    throw error
                }
            case .failure(let error):
                print(error.localizedDescription)
                throw error
            }
        }

        static func getPlaceRestriction(location: CLLocationCoordinate2D, viewport: RectangularCoordinateRegion?) -> CircularCoordinateRegion {
            if let viewport = viewport { // calculate radius from viewport

                func haversine(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> CLLocationDistance {
                    let R = 6_371_000.0
                    let dLat = (b.latitude - a.latitude) * .pi/180
                    let dLon = (b.longitude - a.longitude) * .pi/180
                    let lat1 = a.latitude * .pi/180
                    let lat2 = b.latitude * .pi/180
                    let h = pow(sin(dLat/2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon/2), 2)
                    return 2 * R * asin(min(1, sqrt(h))) // meters
                }

                let dNE = haversine(location, viewport.northEast)
                let dSW = haversine(location, viewport.southWest)
                let farthest = max(dNE, dSW)

                // Use ~70 – 80% of that to stay within the city
                let estRadius = 0.75 * farthest

                // Clamp between min and max
                let minRadius: CLLocationDistance = 3000 // km
                let maxRadius: CLLocationDistance = 10000
                let radius = max(minRadius, min(maxRadius, estRadius))
                return CircularCoordinateRegion(center: location, radius: radius)
            } else {
                return CircularCoordinateRegion(center: location, radius: 5000)
            }
        }
    }
}
