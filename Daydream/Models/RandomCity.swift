//
//  RandomCity.swift
//  Daydream
//
//  Created by Raymond Kim on 6/16/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

struct RandomCity: Codable {
    let city: String
    let country: String
    /// center latitude of city
    let latitude: Double
    /// center longitude of city
    let longitude: Double
    /// in kilometers
    let radius: Double
}
