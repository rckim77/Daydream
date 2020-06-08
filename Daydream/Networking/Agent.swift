//
//  Agent.swift
//  Daydream
//
//  Created by Raymond Kim on 6/4/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation
import Combine

struct Agent {

    /// Use this function to execute requests with an optional decoder if you need to use
    /// a custom one. In the future, you can use a tryMap instead of map to get access to
    /// the response object to do things such as status code validation.
    func run<T: Decodable>(_ url: URL, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher() // without this, it'll return a mess of nested types
    }
}
