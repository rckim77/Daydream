//
//  EaterySearchRoutes.swift
//  Daydream
//
//  Created by Raymond Kim on 6/17/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation

extension API.EaterySearch {
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
}
