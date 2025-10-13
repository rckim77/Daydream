//
//  JSONCustomDecoder.swift
//  Daydream
//
//  Created by Raymond Kim on 6/16/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation

final class JSONCustomDecoder: JSONDecoder, @unchecked Sendable {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
