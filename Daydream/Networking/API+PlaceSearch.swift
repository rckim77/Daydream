//
//  API+PlaceSearch.swift
//  Daydream
//
//  Created by Raymond Kim on 6/17/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces
import GooglePlacesSwift

enum APIError: Error {
    case biasError
    case bundleError
    case fetchCurrentCityError
    case missingViewport
    case noResults
}

extension API {
    enum PlaceSearch {

        enum PlaceSearchType {
            case sights, eateries
        }
        
        /// Picks a random city and fetches its place data, including the country for its backdrop.
        static func fetchRandomCity() async throws -> Place {
            guard let path = Bundle.main.path(forResource: "randomCitiesJSON", ofType: "json") else {
                throw APIError.bundleError
            }

            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let randomCities = try JSONCustomDecoder().decode([RandomCity].self, from: data)
            let randomIndex = Int(arc4random_uniform(UInt32(randomCities.count)))
            
            guard let place = await API.PlaceSearch.fetchCityBy(randomCities[randomIndex]) else {
                throw APIError.noResults
            }
            
            return place
        }

        @MainActor
        static func fetchCurrentCityBy(_ coordinate: CLLocationCoordinate2D) async throws -> Place {
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let restriction = CircularCoordinateRegion(center: center, radius: 1000)
            let placeProps: [PlaceProperty] = [.displayName, .formattedAddress, .coordinate, .placeID, .addressComponents]
            let request = SearchNearbyRequest(
                locationRestriction: restriction,
                placeProperties: placeProps,
                includedPrimaryTypes: [.locality],
                maxResultCount: 2
            )

            switch await PlacesClient.shared.responseForSearchNearby(with: request) {
            case .success(let response):
                if let place = response.places?.first {
                    return place
                } else {
                    throw APIError.noResults
                }
            case .failure(let error):
                print("=== fetchCurrentCityBy(coordinate:) call failed: \(error.localizedDescription)")
                throw APIError.fetchCurrentCityError
            }
        }
        
        /// Fetches city details, including address components for the country backdrop, using PlacesCache.
        @MainActor
        static func fetchPlaceBy(placeId: String) async throws -> Place {
            if let cachedPlace = PlacesCache.shared.get(forKey: placeId) {
                return cachedPlace
            }

            let request = FetchPlaceRequest(
                placeID: placeId,
                placeProperties: [.placeID, .coordinate, .displayName, .formattedAddress, .addressComponents, .reviewSummary]
            )
            switch await PlacesClient.shared.fetchPlace(with: request) {
            case .success(let place):
                PlacesCache.shared.set(place, forKey: placeId)
                return place
            case .failure(let error):
                print("=== fetchPlaceBy(placeId:) call failed: \(error.localizedDescription)")
                throw error
            }
        }

        @MainActor
        static func fetchCityPlaceID(_ city: RandomCity) async -> String? {
            guard !Task.isCancelled else { return nil }

            // Call the callback API directly so the SDK starts Nearby Search on the main thread.
            return await withCheckedContinuation { continuation in
                let center = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)
                let request = GMSPlaceSearchNearbyRequest(
                    locationRestriction: GMSPlaceCircularLocationOption(center, city.radius * 1000),
                    placeProperties: [GMSPlaceProperty.placeID.rawValue]
                )
                request.includedPrimaryTypes = ["locality"]
                request.maxResultCount = 2

                GMSPlacesClient.shared().searchNearby(with: request) { response, error in
                    if let error {
                        print("=== fetchCityPlaceID(name:) call failed: \(error.localizedDescription)")
                    }
                    continuation.resume(returning: error == nil ? response?.places?.first?.placeID : nil)
                }
            }
        }

        // Keep the SDK request lifetime on the main actor, including teardown after awaiting its response.
        @MainActor
        static func fetchCityBy(_ city: RandomCity) async -> Place? {
            let center = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)
            let restriction = CircularCoordinateRegion(center: center, radius: city.radius * 1000)
            let placeProps: [PlaceProperty] = [.displayName, .formattedAddress, .coordinate, .placeID, .addressComponents]
            let request = SearchNearbyRequest(
                locationRestriction: restriction,
                placeProperties: placeProps,
                includedPrimaryTypes: [.locality],
                maxResultCount: 2
            )

            switch await PlacesClient.shared.responseForSearchNearby(with: request) {
            case .success(let response):
                return response.places?.first
            case .failure(let error):
                print("=== fetchCityBy(name:) call failed: \(error.localizedDescription)")
                return nil
            }
        }
        
        @MainActor
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
                    placeProps = [.displayName, .placeID, .coordinate]
                    includedTypes = [.touristAttraction, .park, .museum]
                    excludedTypes = [.restaurant, .bar, .cafe, .bakery]
                case .eateries:
                    placeProps = [.displayName, .placeID, .coordinate, .priceLevel]
                    includedTypes = [.restaurant, .bar, .bakery]
                    excludedTypes = [.touristAttraction, .park, .museum, .stadium]
                }
                let request = SearchNearbyRequest(
                    locationRestriction: restriction,
                    placeProperties: placeProps,
                    includedTypes: includedTypes,
                    excludedTypes: excludedTypes,
                    maxResultCount: maxResultCount
                )
                switch await PlacesClient.shared.responseForSearchNearby(with: request) {
                case .success(let response):
                    return response.places ?? []
                case .failure(let error):
                    print(error.localizedDescription)
                    throw error
                }
            case .failure(let error):
                print("=== fetchPlacesFor(placeId:type:maxResultCount:) call failed: \(error.localizedDescription)")
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
