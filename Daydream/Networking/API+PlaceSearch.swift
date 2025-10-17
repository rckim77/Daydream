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

enum APIError: Error {
    case biasError, bundleError, noResults
}

extension API {
    enum PlaceSearch {
        
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
                placeProperties: [.placeID, .coordinate, .photos, .displayName]
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
                placeProperties: [.placeID, .coordinate, .reviews, .formattedAddress]
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
        
        /// Returns at most 7 results.
        static func fetchPlacesFor(city: String) async throws -> [Place] {
            // this is unfortunately a required param even though we don't need one...
            guard let neutralBias = RectangularCoordinateRegion(
                northEast: CLLocationCoordinate2D(latitude: 85, longitude: 180),
                southWest: CLLocationCoordinate2D(latitude: -85, longitude: 0)
            ) else {
                throw APIError.biasError
            }
            let query = "top sights in \(city)"
            let request = SearchByTextRequest(textQuery: query,
                                              placeProperties: [.photos, .displayName, .placeID, .coordinate],
                                              locationBias: neutralBias,
                                              maxResultCount: 7)
            switch await PlacesClient.shared.searchByText(with: request) {
            case .success(let places):
                return places
            case .failure(let error):
                print(error.localizedDescription)
                throw error
            }
        }
        
        /// Returns at most 7 results.
        static func fetchEateriesFor(city: String) async throws -> [Place] {
            // this is unfortunately a required param even though we don't need one...
            guard let neutralBias = RectangularCoordinateRegion(
                northEast: CLLocationCoordinate2D(latitude: 85, longitude: 180),
                southWest: CLLocationCoordinate2D(latitude: -85, longitude: 0)
            ) else {
                throw APIError.biasError
            }
            let query = "top restaurants in \(city)"
            let request = SearchByTextRequest(textQuery: query,
                                              placeProperties: [.photos, .displayName, .placeID, .coordinate, .priceLevel],
                                              locationBias: neutralBias,
                                              maxResultCount: 7)
            switch await PlacesClient.shared.searchByText(with: request) {
            case .success(let places):
                return places
            case .failure(let error):
                print(error.localizedDescription)
                throw error
            }
        }
    }
}
