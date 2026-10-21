//
//  RandomCity.swift
//  Daydream
//
//  Created by Raymond Kim on 6/16/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

struct RandomCity: Codable, Equatable, Identifiable {
    let city: String
    let country: String
    /// center latitude of city
    let latitude: Double
    /// center longitude of city
    let longitude: Double
    /// in kilometers
    let radius: Double

    /// Keep identity stable across launches and distinguish cities with the same name.
    var id: String { "\(country)|\(city)|\(latitude)|\(longitude)" }
}
