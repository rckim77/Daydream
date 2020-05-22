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

    func loadSightsAndEateries(with place: Placeable,
                               success: @escaping(_ pointsOfInterest: [Placeable], _ eateries: [Eatery]?) -> Void,
                               failure: @escaping(_ error: Error?) -> Void) {
        var sights: [Placeable] = []

        loadTopSights(with: place, success: { [weak self] pointsOfInterest in
            guard let strongSelf = self else {
                failure(nil)
                return
            }

            sights = pointsOfInterest

            strongSelf.loadTopEateries(with: place, success: { eateries in
                success(sights, eateries)
            }, failure: { error in
                failure(error)
            })
        }, failure: { error in
            failure(error)
        })
    }

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

                let pointsOfInterest = results.compactMap { result -> Place? in
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

                    // NOTE: A text search request doesn't return data on address, phone number, nor rating.
                    // Documentation: https://developers.google.com/places/web-service/search
                    let coordinate = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng)
                    let viewport = Viewport(northeastLat: northeastLat,
                                            northeastLng: northeastLng,
                                            southwestLat: southwestLat,
                                            southwestLng: southwestLng)
                    
                    return Place(placeID: placeId,
                                 name: name,
                                 coordinate: coordinate,
                                 viewport: viewport)
                }

                success(pointsOfInterest)
            case .failure(let error):
                failure(error)
            }

        }
    }

    func loadTopEateries(with place: Placeable, success: @escaping(_ eateries: [Eatery]) -> Void,
                         failure: @escaping(_ error: Error?) -> Void) {
        guard let yelpAPIKey = AppDelegate.getAPIKeys()?.yelpAPI else {
            failure(nil)
            return
        }

        let url = createUrl(with: place, and: "eateries")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(yelpAPIKey)"
        ]

        Alamofire.request(url, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let results = json["businesses"].array else {
                    failure(nil)
                    return
                }

                let eateries = results.compactMap { result -> Eatery? in
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
        guard let url = createUrlWithPlaceName(placeName) else {
            failure(nil)
            return
        }

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
        guard let url = createUrlWithPlaceId(placeId) else {
            failure(nil)
            return
        }

        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let result = json["result"].dictionary,
                    let placeID = result["place_id"]?.string,
                    let name = result["name"]?.string,
                    let formattedAddress = result["formatted_address"]?.string,
                    let latitude = result["geometry"]?["location"]["lat"].double,
                    let longitude = result["geometry"]?["location"]["lng"].double,
                    let mapUrl = result["url"]?.string else {
                    failure(nil)
                    return
                }

                // NOTE: Place Detail request optionally returns phone number, rating, reviews.
                // Documentation: https://developers.google.com/places/web-service/details
                let formattedPhoneNumber = result["international_phone_number"]?.string
                let rating = result["rating"]?.float
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                var reviews: [Review]?
                if let reviewsJSON = result["reviews"]?.array {
                    reviews = reviewsJSON.compactMap { review -> Review? in
                        guard let dict = review.dictionary,
                            let author = dict["author_name"]?.string,
                            let rating = dict["rating"]?.int else { return nil }

                        let review = dict["text"]?.string
                        let authorUrl = dict["author_url"]?.string
                        let authorProfileUrl = dict["profile_photo_url"]?.string

                        return Review(author, rating, review, authorUrl, authorProfileUrl)
                    }
                }

                let place = Place(placeID: placeID,
                                  name: name,
                                  formattedAddress: formattedAddress,
                                  formattedPhoneNumber: formattedPhoneNumber,
                                  rating: rating,
                                  coordinate: coordinate,
                                  mapUrl: mapUrl,
                                  reviews: reviews)

                success(place)
            case .failure(let error):
                failure(error)
            }
        }
    }

    func getSummaryFor(_ city: String, success: @escaping(_ summary: String) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        let cityWords = city.split(separator: " ")
        var cityParam = cityWords[0]
        for i in 1..<cityWords.count {
            cityParam += "+" + cityWords[i]
        }

        let url = "https://en.wikivoyage.org/w/api.php?action=query&prop=extracts&explaintext&format=json&titles=\(cityParam)"

        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let query = json["query"]["pages"].dictionary, let pageIdKey = query.keys.first,
                    let extract = query[pageIdKey]?["extract"].string else { return }

                success(extract)
            case .failure(let error):
                failure(error)
            }
        }
    }

    private func createUrl(with place: Placeable, and type: String) -> String {
        if let placeableName = place.placeableName, type == "point_of_interest", let keyParam = AppDelegate.getAPIKeys()?.googleAPI {
            let placeName = placeableName.split(separator: " ")
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

    private func createUrlWithPlaceName(_ placeName: String) -> String? {
        guard let keyParam = AppDelegate.getAPIKeys()?.googleAPI else {
            return nil
        }

        let placeWords = placeName.split(separator: " ")
        var placeNameParam = placeWords[0]
        for i in 1..<placeWords.count {
            placeNameParam += "+" + placeWords[i]
        }
        
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(placeNameParam)&key=\(keyParam)"

        return url
    }

    private func createUrlWithPlaceId(_ placeId: String) -> String? {
        guard let keyParam = AppDelegate.getAPIKeys()?.googleAPI else {
            return nil
        }

        let placeIdParam = placeId
        let url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeIdParam)&key=\(keyParam)"

        return url
    }
}
