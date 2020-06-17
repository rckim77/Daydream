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

    func loadArticles(url: URL) -> AnyPublisher<[Article], Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ArticleResponse.self, decoder: customDecoder)
            .map { $0.response.docs }
            .eraseToAnyPublisher()
    }
}
