//
//  NetworkService.swift
//  Daydream
//
//  Created by Raymond Kim on 3/18/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import Alamofire
import GooglePlaces
import SwiftyJSON

class NetworkService {
    func loadTopSights(with place: GMSPlace, success: @escaping(_ pointsOfInterest: [PointOfInterest]) -> Void,
                       failure: @escaping(_ error: Error) -> Void) {
        let url = createUrl(with: place, and: "point_of_interest")

        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                // POSTLAUNCH: - refactor into a JSON init method
                let results = json["results"].arrayValue.map({ json -> PointOfInterest in
                    let name = json["name"].stringValue
                    let placeId = json["place_id"].stringValue
                    let viewportRaw = json["geometry"]["viewport"]
                    let northeastRaw = viewportRaw["northeast"]
                    let southwestRaw = viewportRaw["southwest"]
                    let viewport = Viewport(northeastLat: northeastRaw["lat"].doubleValue,
                                            northeastLng: northeastRaw["lng"].doubleValue,
                                            southeastLat: southwestRaw["lat"].doubleValue,
                                            southeastLng: southwestRaw["lng"].doubleValue)
                    
                    return PointOfInterest(name: name, viewport: viewport, placeId: placeId)
                })

                success(results)
            case .failure(let error):
                failure(error)
            }

        }
    }

    func loadTopEateries(with place: GMSPlace, success: @escaping(_ eateries: [Eatery]) -> Void, failure: @escaping(_ error: Error) -> Void) {
        let url = createUrl(with: place, and: "eateries")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(AppDelegate.yelpAPIKey)"
        ]

        Alamofire.request(url, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let results = json["businesses"].arrayValue.map({ json -> Eatery in
                    let name = json["name"].stringValue
                    let imageUrl = json["image_url"].stringValue
                    let url = json["url"].stringValue
                    return Eatery(name: name, imageUrl: imageUrl, url: url)
                })

                success(results)
            case .failure(let error):
                failure(error)
            }
        }
    }

    private func createUrl(with place: GMSPlace, and type: String) -> String {
        if type == "point_of_interest" {
            let keyParam = AppDelegate.googleAPIKey
            let placeName = place.name.split(separator: " ")
            var queryParam = "tourist+spots+in"
            placeName.forEach({ word in
                queryParam += "+" + word
            })

            let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(queryParam)&key=\(keyParam)"

            return url
        } else if type == "eateries" {
            let latitude = place.coordinate.latitude
            let longitude = place.coordinate.longitude
            let url = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)"

            return url
        } else {
            return ""
        }
    }
}
