//
//  Place.swift
//  Daydream
//
//  Created by Raymond Kim on 3/28/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import CoreLocation

class Place: Placeable {
    var placeableId: String
    var placeableName: String
    var placeableFormattedAddress: String?
    var placeableCoordinate: CLLocationCoordinate2D

    init(placeID: String, name: String, formattedAddress: String?, coordinate: CLLocationCoordinate2D) {
        self.placeableId = placeID
        self.placeableName = name
        self.placeableFormattedAddress = formattedAddress
        self.placeableCoordinate = coordinate
    }
}
