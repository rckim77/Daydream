//
//  Routes.swift
//  Daydream
//
//  Created by Raymond Kim on 6/9/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation
import CoreLocation

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
