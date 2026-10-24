//
//  RandomCity.swift
//  Daydream
//
//  Created by Raymond Kim on 6/16/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

struct RandomCity: Codable, Hashable, Identifiable {
    let city: String
    let country: String
    /// center latitude of city
    let latitude: Double
    /// center longitude of city
    let longitude: Double
    /// in kilometers
    let radius: Double
    /// Available for cities saved from Places search.
    let placeID: String?
    let countryCode: String?

    init(city: String, country: String, latitude: Double, longitude: Double, radius: Double,
         placeID: String? = nil, countryCode: String? = nil) {
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.placeID = placeID
        self.countryCode = countryCode
    }

    var id: String { "\(country)|\(city)|\(latitude)|\(longitude)" }
}
