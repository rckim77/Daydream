//
//  PlaceSearchRoutes.swift
//  Daydream
//
//  Created by Raymond Kim on 6/17/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation
import CoreLocation

extension API.PlaceSearch {
    struct TextSearchRoute {
        enum QueryType {
            case touristSpots, restaurants, placeByName
        }

        private let baseUrlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query="

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
                urlString = "\(baseUrlString)\(queryParam)&location=\(locationParam)&radius=\(radiusParam)&key=\(keyParam)"
            } else {
                urlString = "\(baseUrlString)\(queryParam)&key=\(keyParam)"
            }

            guard let url = URL(string: urlString) else {
                return nil
            }
            self.url = url
        }
    }

    struct PlaceDetailsRoute {
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
}
