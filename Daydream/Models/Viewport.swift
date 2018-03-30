//
//  Viewport.swift
//  Daydream
//
//  Created by Raymond Kim on 3/17/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import CoreLocation

struct Viewport: Codable {
    var northeastLat: CLLocationDegrees
    var northeastLng: CLLocationDegrees
    var southwestLat: CLLocationDegrees
    var southwestLng: CLLocationDegrees
}
