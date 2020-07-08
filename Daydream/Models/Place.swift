//
//  Place.swift
//  Daydream
//
//  Created by Raymond Kim on 3/28/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import CoreLocation
import GooglePlaces

struct Place: Equatable {
    let placeId: String
    let name: String
    let formattedAddress: String
    let mapUrl: String?
    let coordinate: CLLocationCoordinate2D
    let photos: [PhotoReference]?

    // NOTE: Place Detail request optionally returns phone number, rating, reviews.
    // Documentation: https://developers.google.com/places/web-service/details
    let internationalPhoneNumber: String?
    let rating: Float?
    let reviews: [Review]
    let businessStatus: PlaceBusinessStatus?
    
    // MARK: - Convenience vars
    
    var photoRef: String? {
        photos?.first?.photoReference
    }
}

extension Place: Decodable {
    enum CodingKeys: String, CodingKey {
        case placeId
        case name
        case formattedAddress
        case mapUrl = "url"
        case geometry
        case photos
        case internationalPhoneNumber
        case rating
        case reviews
        case businessStatus
    }

    enum GeometryKeys: String, CodingKey {
        case location
    }

    enum LocationKeys: String, CodingKey {
        case lat, lng
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        placeId = try values.decode(String.self, forKey: .placeId)
        name = try values.decode(String.self, forKey: .name)
        formattedAddress = try values.decode(String.self, forKey: .formattedAddress)
        internationalPhoneNumber = try? values.decode(String.self, forKey: .internationalPhoneNumber)
        mapUrl = try? values.decode(String.self, forKey: .mapUrl)

        let geometry = try values.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
        let location = try geometry.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        let lat = try location.decode(Double.self, forKey: .lat)
        let lng = try location.decode(Double.self, forKey: .lng)
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)

        if let reviews = try? values.decode([Review].self, forKey: .reviews) {
            self.reviews = reviews
        } else {
            self.reviews = []
        }

        photos = try? values.decode([PhotoReference].self, forKey: .photos)
        rating = try? values.decode(Float.self, forKey: .rating)
        businessStatus = try? values.decode(PlaceBusinessStatus.self, forKey: .businessStatus)
    }

    init?(from gmsPlace: GMSPlace) {
        guard let id = gmsPlace.placeID,
            let placeName = gmsPlace.name,
            let placeFormattedAddress = gmsPlace.formattedAddress else {
            return nil
        }
        placeId = id
        name = placeName
        formattedAddress = placeFormattedAddress
        internationalPhoneNumber = gmsPlace.phoneNumber
        mapUrl = nil
        coordinate = gmsPlace.coordinate
        photos = nil
        rating = gmsPlace.rating
        reviews = []
        businessStatus = PlaceBusinessStatus(gmsBusinessStatus: gmsPlace.businessStatus)
    }
}

extension Place: Eatable {
    var type: EateryType {
        .google
    }

    var eatableId: String? {
        placeId
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
