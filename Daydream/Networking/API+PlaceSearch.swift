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
        struct TextSearch {
            enum QueryType {
                case touristSpots, restaurants, placeByName
            }

            private let baseUrlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query="

            let url: URL

            init?(name: String, location: CLLocationCoordinate2D? = nil, queryType: QueryType) {
                guard let keyParam = AppDelegate.getAPIKeys()?.googleAPI else {
                    return nil
                }
                // e.g., İstanbul -> Istanbul
                let placeNameStripped = name.folding(options: .diacriticInsensitive, locale: .current)
                let placeWords = placeNameStripped.split(separator: " ")
                var queryParam = ""

                switch queryType {
                case .placeByName:
                    break
                case .touristSpots:
                    queryParam = "tourist+spots+in"
                case .restaurants:
                    queryParam = "restaurants+in"
                }

                placeWords.forEach { word in
                    queryParam += "+" + word
                }

                let urlString: String

                if let location = location {
                    let locationParam = "\(location.latitude),\(location.longitude)"
                    let radiusParam = "10000"
                    urlString = "\(baseUrlString)\(queryParam)&location=\(locationParam)&radius=\(radiusParam)&key=\(keyParam)"
                } else {
                    urlString = "\(baseUrlString)\(queryParam)&key=\(keyParam)"
                }

                guard let url = URL(string: urlString) else {
                    return nil
                }
                self.url = url
            }
        }

        /// Can be used to return multiple Google Place objects (e.g., sights, fallback restaurants) based on the city name, optional location,
        /// and query type.
        static func loadPlaces(name: String, location: CLLocationCoordinate2D? = nil, queryType: TextSearch.QueryType) -> AnyPublisher<[Place], Error>? {
            guard let url = TextSearch(name: name, location: location, queryType: queryType)?.url else {
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
                              queryType: TextSearch.QueryType,
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

        /// Load photo as UIImage using Google Places SDK
        static func loadGooglePhoto(placeId: String) -> Future<UIImage, Error> {
            return Future<UIImage, Error> { promise in
                guard let photoField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue)) else {
                    promise(.failure(NetworkError.malformedPhotoField))
                    return
                }

                GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeId, placeFields: photoField, sessionToken: nil) { place, error in
                    if let place = place {
                        if let photoMetadata = place.photos?.first {
                            GMSPlacesClient.shared().loadPlacePhoto(photoMetadata) { image, error in
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
    }
}
