//
//  CityRoute.swift
//  Daydream
//
//  Created by Ray Kim on 11/1/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import Foundation
import GooglePlacesSwift

struct CityRoute: Identifiable, Hashable {
    let id = UUID()
    /// Used for zoom transition
    let name: String
    let place: Place
    let wishlistCity: RandomCity?

    init(name: String, place: Place, wishlistCity: RandomCity? = nil) {
        self.name = name
        self.place = place
        self.wishlistCity = wishlistCity
    }
}
