//
//  Routes.swift
//  Daydream
//
//  Created by Raymond Kim on 6/9/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

struct GooglePlaceDetailsRoute {
    let url: URL

    init?(placeId: String) {
        guard let keyParam = AppDelegate.getAPIKeys()?.googleAPI else {
            return nil
        }
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&key=\(keyParam)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        self.url = url
    }
}

struct GooglePlaceTextSearchRoute {
    enum QueryType {
        case touristSpots, restaurants, placeByName
    }

    let url: URL

    init?(name: String, location: CLLocationCoordinate2D? = nil, queryType: QueryType) {
        guard let keyParam = AppDelegate.getAPIKeys()?.googleAPI else {
            return nil
        }
        // e.g., İstanbul -> Istanbul
        let placeNameStripped = name.folding(options: .diacriticInsensitive, locale: .current)
        let placeWords = placeNameStripped.split(separator: " ")
        var queryParam = ""

        switch queryType {
        case .placeByName:
            break
        case .touristSpots:
            queryParam = "tourist+spots+in"
        case .restaurants:
            queryParam = "restaurants+in"
        }

        placeWords.forEach { word in
            queryParam += "+" + word
        }

        let urlString: String

        if let location = location {
            let locationParam = "\(location.latitude),\(location.longitude)"
            let radiusParam = "10000"
            // swiftlint:disable line_length
            urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(queryParam)&location=\(locationParam)&radius=\(radiusParam)&key=\(keyParam)"
        } else {
            urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(queryParam)&key=\(keyParam)"
        }

        guard let url = URL(string: urlString) else {
            return nil
        }
        self.url = url
    }
}

struct YelpBusinessesRoute {
    let url: URL
    let urlRequest: URLRequest
    let yelpAPIKey: String

    init?(place: Placeable) {
        let latitude = place.placeableCoordinate.latitude
        let longitude = place.placeableCoordinate.longitude
        let urlString = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&categories=restaurants"

        guard let yelpAPIKey = AppDelegate.getAPIKeys()?.yelpAPI,
            let url = URL(string: urlString) else {
            return nil
        }
        self.yelpAPIKey = yelpAPIKey
        self.url = url

        let headers: HTTPHeaders = ["Authorization": "Bearer \(yelpAPIKey)"]

        guard let urlRequest = try? URLRequest(url: url, method: .get, headers: headers) else {
            return nil
        }
        self.urlRequest = urlRequest
    }
}
