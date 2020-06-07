//
//  Place.swift
//  Daydream
//
//  Created by Raymond Kim on 3/28/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import CoreLocation

class Place: Placeable {
    let placeableId: String
    let placeableName: String
    var placeableFormattedAddress: String?
    var placeableFormattedPhoneNumber: String?
    var placeableRating: Float?
    var placeableCoordinate: CLLocationCoordinate2D
    var placeableViewport: Viewport?
    var placeableMapUrl: String?
    var placeableReviews: [Reviewable]?
    var placeableBusinessStatus: PlaceBusinessStatus?

    init(placeID: String,
         name: String,
         formattedAddress: String? = nil,
         formattedPhoneNumber: String? = nil,
         rating: Float? = nil,
         coordinate: CLLocationCoordinate2D,
         viewport: Viewport? = nil,
         mapUrl: String? = nil,
         reviews: [Reviewable]? = nil,
         businessStatus: String? = nil) {
        self.placeableId = placeID
        self.placeableName = name
        self.placeableFormattedAddress = formattedAddress
        self.placeableFormattedPhoneNumber = formattedPhoneNumber
        self.placeableRating = rating
        self.placeableCoordinate = coordinate
        self.placeableViewport = viewport
        self.placeableMapUrl = mapUrl
        self.placeableReviews = reviews
        if let businessStatus = businessStatus {
            self.placeableBusinessStatus = PlaceBusinessStatus(rawValue: businessStatus)
        }
    }
}

extension Place: Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.placeableId == rhs.placeableId &&
            lhs.placeableName == rhs.placeableName
    }
}

extension Place: Eatable {
    var type: EateryType {
        .google
    }

    var id: String? {
        placeableId
    }

    var name: String {
        placeableName
    }

    var eatableImageUrl: String? {
        nil
    }

    var eatableUrl: String? {
        nil
    }

    var priceIndicator: String? {
        nil
    }
}
