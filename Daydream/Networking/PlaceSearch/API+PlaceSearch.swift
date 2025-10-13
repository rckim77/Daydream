//
//  API+PlaceSearch.swift
//  Daydream
//
//  Created by Raymond Kim on 6/17/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import CoreLocation
import Combine
import GooglePlaces

extension API {
    enum PlaceSearch {
        /// Can be used to return multiple Google Place objects (e.g., sights, fallback restaurants) based on the city name, optional location,
        /// and query type.
        static func loadPlaces(name: String, location: CLLocationCoordinate2D? = nil, queryType: TextSearchRoute.QueryType) -> AnyPublisher<[Place], Error>? {
            guard let url = TextSearchRoute(name: name, location: location, queryType: queryType)?.url else {
                return nil
            }
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: ResultsCollection.self, decoder: JSONCustomDecoder())
                .map { $0.results }
                .eraseToAnyPublisher()
        }

        /// Convenience method to return one Google place. Uses loadPlaces(name:location:queryType:) and ensures the first element is returned.
        static func loadPlace(name: String,
                              location: CLLocationCoordinate2D? = nil,
                              queryType: TextSearchRoute.QueryType,
                              receiveOnMainQueue: Bool = true) -> AnyPublisher<Place, Error>? {
            let publisher = PlaceSearch.loadPlaces(name: name, location: location, queryType: queryType)?
                .tryMap { places -> Place in
                    guard let firstPlace = places.first else {
                        throw NetworkError.insufficientResults
                    }
                    return firstPlace
                }

            if receiveOnMainQueue {
                return publisher?.receive(on: DispatchQueue.main).eraseToAnyPublisher()
            } else {
                return publisher?.eraseToAnyPublisher()
            }
        }

        /// Returns a Place object with at least one review.
        static func loadPlaceWithReviews(placeId: String) -> AnyPublisher<Place, Error>? {
            guard let url = PlaceDetailsRoute(placeId: placeId)?.url else {
                return nil
            }
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: PlaceCollection.self, decoder: JSONCustomDecoder())
                .tryMap { collection -> Place in
                    guard !collection.result.reviews.isEmpty else {
                        throw NetworkError.insufficientResults
                    }
                    return collection.result
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        /// Load photo based on photo reference provided by place request. Doesn't use Google Places SDK.
        static func loadGooglePhoto(photoRef: String?, maxHeight: Int) -> AnyPublisher<UIImage, Error>? {
            guard let photoRef = photoRef, let url = PlacePhotosRoute(photoRef: photoRef, maxHeight: maxHeight)?.url else {
                return nil
            }
            
            return URLSession.shared.dataTaskPublisher(for: url)
                    .tryMap { output -> UIImage in
                        guard let image = UIImage(data: output.data) else {
                            throw NetworkError.noImage
                        }
                        return image
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }

        static func loadGooglePhotoSDK(placeId: String) -> Future<UIImage, Error> {
            return Future<UIImage, Error> { promise in
                let placeProps = [GMSPlaceProperty.photos.rawValue]
                let request = GMSFetchPlaceRequest(placeID: placeId, placeProperties: placeProps, sessionToken: nil)
                GMSPlacesClient.shared().fetchPlace(with: request) { place, error in
                    if let place = place {
                        if let photoMetadata = place.photos?.first {
                            let request = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: .init(width: 300, height: 300))
                            GMSPlacesClient.shared().fetchPhoto(with: request) { image, error in
                                if let image = image {
                                    promise(.success(image))
                                } else if let error = error {
                                    promise(.failure(error))
                                } else {
                                    promise(.failure(NetworkError.unknown))
                                }
                            }
                        } else {
                            promise(.failure(NetworkError.photoMetadataMissing))
                        }
                    } else if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.failure(NetworkError.unknown))
                    }
                }
            }
        }

        /// Returns a map url that opens a Google Maps view.
        static func getMapUrl(placeId: String) -> AnyPublisher<URL, Error>? {
            guard let url = PlaceDetailsRoute(placeId: placeId)?.url else {
                return nil
            }
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: PlaceCollection.self, decoder: JSONCustomDecoder())
                .tryMap { collection -> URL in
                    guard let mapUrlString = collection.result.mapUrl, let url = URL(string: mapUrlString) else {
                        throw NetworkError.noMapUrl
                    }
                    return url
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}
