//
//  NetworkService.swift
//  Daydream
//
//  Created by Raymond Kim on 3/18/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import GooglePlaces
import Combine

typealias SightsAndEateries = ([Place], [Eatery])

// swiftlint:disable type_body_length
class NetworkService {

    private let customDecoder = JSONCustomDecoder()

    /// Can be used to return one or more Google Place objects (e.g., sights, fallback restaurants) filtered by the parameters
    /// set in the input url. Must pass in a URL created from a GooglePlaceTextSearchRoute.
    func loadPlaces(url: URL) -> AnyPublisher<[Place], Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ResultsCollection.self, decoder: customDecoder)
            .map { $0.results }
            .eraseToAnyPublisher()
    }

    func loadEateries(place: Place, urlRequest: URLRequest, fallbackUrl: URL) -> AnyPublisher<[Eatable], Error> {
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { [weak self] response -> [Eatable] in
                guard let eateries = try? self?.customDecoder.decode(EateryCollection.self, from: response.data) else {
                    throw NetworkError.malformedJSON
                }
                return eateries.businesses as [Eatable]
            }
            .tryCatch { [weak self] error -> AnyPublisher<[Eatable], Error> in
                guard let networkError = error as? NetworkError,
                    let strongSelf = self,
                    networkError == .malformedJSON else {
                    throw error
                }
                return strongSelf.loadPlaces(url: fallbackUrl)
                    .map { $0 as [Eatable] }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func loadArticles(url: URL) -> AnyPublisher<[Article], Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ArticleResponse.self, decoder: customDecoder)
            .map { $0.response.docs }
            .eraseToAnyPublisher()
    }

    /// Note: Returns on the main queue and with errors erased.
    static func loadImage(url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: UIImage())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
