//
//  Agent.swift
//  Daydream
//
//  Created by Raymond Kim on 6/4/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation
import Combine

/// Abstraction for the initial steps for most network calls that deserialize JSON from a URL or URL request.
struct Agent {

    /// Use this function to execute requests with an optional decoder if you need to use
    /// a custom one. In the future, you can use a tryMap instead of map to get access to
    /// the response object to do things such as status code validation.
    static func run<T: Decodable>(_ url: URL, _ decoder: JSONDecoder = JSONCustomDecoder()) -> AnyPublisher<T, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    /// Use this function to execute requests with an optional decoder if you need to use
    /// a custom one. In the future, you can use a tryMap instead of map to get access to
    /// the response object to do things such as status code validation.
    static func run<T: Decodable>(_ urlRequest: URLRequest, _ decoder: JSONDecoder = JSONCustomDecoder()) -> AnyPublisher<T, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
