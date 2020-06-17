//
//  Routes.swift
//  Daydream
//
//  Created by Raymond Kim on 6/9/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation
import CoreLocation

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

    init?(place: Place) {
        let latitude = place.coordinate.latitude
        let longitude = place.coordinate.longitude
        let urlString = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&categories=restaurants"

        guard let yelpAPIKey = AppDelegate.getAPIKeys()?.yelpAPI,
            let url = URL(string: urlString) else {
            return nil
        }
        self.yelpAPIKey = yelpAPIKey
        self.url = url

        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")
        self.urlRequest = urlRequest
    }
}

struct NYTimesRoute {
    let url: URL
    let apiKey: String

    init?(city: String) {
        guard let apiKey = AppDelegate.getAPIKeys()?.nyTimesAPI else {
            return nil
        }
        let urlString = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=\(city)&page=1&api-key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        self.url = url
        self.apiKey = apiKey
    }
}
