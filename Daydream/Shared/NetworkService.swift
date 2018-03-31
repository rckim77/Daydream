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

    func loadTopSights(with place: Placeable, success: @escaping(_ pointsOfInterest: [Placeable]) -> Void,
                       failure: @escaping(_ error: Error?) -> Void) {
        let url = createUrl(with: place, and: "point_of_interest")

        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                // POSTLAUNCH: - refactor into a JSON init method
                guard let results = json["results"].array else {
                    failure(nil)
                    return
                }

                let pointsOfInterest = results.flatMap { result -> Place? in
                    guard let name = result["name"].string,
                        let placeId = result["place_id"].string,
                        let centerLat = result["geometry"]["location"]["lat"].double,
                        let centerLng = result["geometry"]["location"]["lng"].double,
                        let northeastLat = result["geometry"]["viewport"]["northeast"]["lat"].double,
                        let northeastLng = result["geometry"]["viewport"]["northeast"]["lng"].double,
                        let southwestLat = result["geometry"]["viewport"]["southwest"]["lat"].double,
                        let southwestLng = result["geometry"]["viewport"]["southwest"]["lng"].double else {
                        return nil
                    }

                    let formattedAddress = result["formatted_address"].string
                    let coordinate = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng)
                    let viewport = Viewport(northeastLat: northeastLat,
                                            northeastLng: northeastLng,
                                            southwestLat: southwestLat,
                                            southwestLng: southwestLng)
                    
                    return Place(placeID: placeId, name: name, formattedAddress: formattedAddress, coordinate: coordinate, viewport: viewport)
                }

                success(pointsOfInterest)
            case .failure(let error):
                failure(error)
            }

        }
    }

    func loadTopEateries(with place: Placeable, success: @escaping(_ eateries: [Eatery]) -> Void,
                         failure: @escaping(_ error: Error?) -> Void) {
        let url = createUrl(with: place, and: "eateries")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(AppDelegate.yelpAPIKey)"
        ]

        Alamofire.request(url, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let results = json["businesses"].array else {
                    failure(nil)
                    return
                }

                let eateries = results.flatMap { result -> Eatery? in
                    guard let name = result["name"].string,
                        let imageUrl = result["image_url"].string,
                        let url = result["url"].string else { return nil }

                    return Eatery(name: name, imageUrl: imageUrl, url: url)
                }

                success(eateries)
            case .failure(let error):
                failure(error)
            }
        }
    }

    func loadPhoto(with placeId: String, success: @escaping(_ photo: UIImage) -> Void,
                   failure: @escaping(_ error: Error) -> Void) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) in
            if let firstPhoto = photos?.results.first {
                GMSPlacesClient.shared().loadPlacePhoto(firstPhoto) { photo, error in
                    if let photo = photo {
                        success(photo)
                    } else if let error = error {
                        failure(error)
                    }
                }
            } else if let error = error {
                failure(error)
            }
        }
    }

    func getPlaceId(with placeName: String, success: @escaping(_ place: Place) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        let url = createUrlWithPlaceName(placeName)

        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let result = json["results"].array?.first,
                    let placeId = result["place_id"].string else {
                    failure(nil)
                    return
                }

                NetworkService().getPlace(with: placeId, success: { place in
                    success(place)
                }, failure: { error in
                    failure(error)
                })
            case .failure(let error):
                failure(error)
            }
        }
    }

    func getPlace(with placeId: String, success: @escaping(_ place: Place) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        let url = createUrlWithPlaceId(placeId)

        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let result = json["result"].dictionary,
                    let placeID = result["place_id"]?.string,
                    let name = result["name"]?.string,
                    let formattedAddress = result["formatted_address"]?.string,
                    let latitude = result["geometry"]?["location"]["lat"].double,
                    let longitude = result["geometry"]?["location"]["lng"].double else {
                    failure(nil)
                    return
                }

                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                let place = Place(placeID: placeID, name: name, formattedAddress: formattedAddress, coordinate: coordinate)

                success(place)
            case .failure(let error):
                failure(error)
            }
        }
    }

    func getSummaryFor(_ city: String, success: @escaping(_ summary: String) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        let url = createUrlFor(city)

        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let query = json["query"].dictionary else { return }
            case .failure(let error):
                failure(error)
            }
        }
    }

    private func createUrl(with place: Placeable, and type: String) -> String {
        if type == "point_of_interest" {
            let keyParam = AppDelegate.googleAPIKey
            let placeName = place.placeableName.split(separator: " ")
            var queryParam = "tourist+spots+in"
            placeName.forEach { word in
                queryParam += "+" + word
            }

            let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(queryParam)&key=\(keyParam)"

            return url
        } else if type == "eateries" {
            let latitude = place.placeableCoordinate.latitude
            let longitude = place.placeableCoordinate.longitude
            let url = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)"

            return url
        } else {
            return ""
        }
    }

    private func createUrlWithPlaceName(_ placeName: String) -> String {
        let keyParam = AppDelegate.googleAPIKey
        let placeWords = placeName.split(separator: " ")
        var placeNameParam = placeWords[0]
        for i in 1..<placeWords.count {
            placeNameParam += "+" + placeWords[i]
        }
        
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(placeNameParam)&key=\(keyParam)"

        return url
    }

    private func createUrlWithPlaceId(_ placeId: String) -> String {
        let keyParam = AppDelegate.googleAPIKey
        let placeIdParam = placeId
        let url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeIdParam)&key=\(keyParam)"

        return url
    }

    private func createUrlFor(_ city: String) -> String {
        let cityWords = city.split(separator: " ")
        var cityParam = cityWords[0]
        for i in 1..<cityWords.count {
            cityParam += "+" + cityWords[i]
        }

        let url = "https://en.wikivoyage.org/w/api.php?action=query&titles=\(cityParam)&prop=extracts&explaintext&format=jsonfm"

        return url
    }
}
