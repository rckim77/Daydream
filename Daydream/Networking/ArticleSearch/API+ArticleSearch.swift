//
//  API+ArticleSearch.swift
//  Daydream
//
//  Created by Raymond Kim on 6/17/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation
import Combine

extension API {
    enum ArticleSearch {
        static func loadArticlesFor(city: String) -> AnyPublisher<[Article], Error>? {
            guard let url = ArticleSearch.NYTimesRoute(city: city)?.url else {
                return nil
            }
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: ArticleResponse.self, decoder: JSONCustomDecoder())
                .map { $0.response.docs }
                .eraseToAnyPublisher()
        }
    }
}
