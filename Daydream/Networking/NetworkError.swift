//
//  NetworkError.swift
//  Daydream
//
//  Created by Raymond Kim on 6/4/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case malformedJSON
    case jsonDecoding
    case insufficientResults
    case malformedPhotoField
    case photoMetadataMissing
    case routeError
    case noMapUrl
    case invalidPlaceFields
    case unknown // e.g., 3rd party function returns nil data and nil error
}
