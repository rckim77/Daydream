//
//  API+EaterySearch.swift
//  Daydream
//
//  Created by Raymond Kim on 6/17/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation
import Combine

extension API {
    enum EaterySearch {
        static func loadEateries(place: Place) -> AnyPublisher<[Eatable], Error>? {
            guard let urlRequest = YelpBusinessesRoute(place: place)?.urlRequest else {
                return nil
            }
            return URLSession.shared.dataTaskPublisher(for: urlRequest)
                .tryMap { response -> [Eatable] in
                    guard let eateries = try? JSONCustomDecoder().decode(EateryCollection.self, from: response.data) else {
                        throw NetworkError.malformedJSON
                    }
                    return eateries.businesses as [Eatable]
                }
                .tryCatch { error -> AnyPublisher<[Eatable], Error> in
                    guard let networkError = error as? NetworkError,
                        networkError == .malformedJSON else {
                        throw error
                    }

                    guard let publisher = API.PlaceSearch.loadPlaces(name: place.name, location: place.coordinate, queryType: .restaurants) else {
                        throw NetworkError.loadPlacesReturnedNil
                    }

                    return publisher
                        .map { $0 as [Eatable] }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }
}
