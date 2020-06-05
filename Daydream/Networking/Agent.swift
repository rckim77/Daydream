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

    /// Contains both a parsed value and the raw response object for, say, status code validation or logging.
    struct Response<T> {
        let value: T
        let response: URLResponse
    }

    /// Use this function to execute requests with an optional decoder if you need a custom decoder.
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher() // without this, it'll return a mess of nested types
    }
}
