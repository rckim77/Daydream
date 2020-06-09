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

typealias SightsAndEateries = ([Placeable], [Eatery])

// swiftlint:disable type_body_length
class NetworkService {

    enum UrlType {
        case topSights, googleRestaurants, topEateries
    }

    private lazy var customDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// The pointsOfInterest array is guaranteed to return at least three elements if the call succeeds. The eateries array
    func loadSightsAndEateries(place: Placeable, completion: @escaping(Result<SightsAndEateries, Error>) -> Void) {
        loadTopSights(place: place, completion: { result in
            switch result {
            case .success(let places):
                NetworkService().loadTopEateries(place: place, completion: { result in
                    switch result {
                    case .success(let eateries):
                        completion(.success((places, eateries)))
                    case .failure:
                        completion(.success((places, [])))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    func loadTopSights(place: Placeable, completion: @escaping(Result<[Placeable], Error>) -> Void) {
        let url = createUrl(with: place, and: .topSights)

        AF.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                // POSTLAUNCH: - refactor into a JSON init method
                guard let results = json["results"].array, results.count > 2 else {
                    completion(.failure(NetworkError.insufficientResults))
                    return
                }

                let pointsOfInterest = results[0..<3].compactMap { result -> Place? in
                    guard let name = result["name"].string,
                        let placeId = result["place_id"].string,
                        let centerLat = result["geometry"]["location"]["lat"].double,
                        let centerLng = result["geometry"]["location"]["lng"].double,
                        let northeastLat = result["geometry"]["viewport"]["northeast"]["lat"].double,
                        let northeastLng = result["geometry"]["viewport"]["northeast"]["lng"].double,
                        let southwestLat = result["geometry"]["viewport"]["southwest"]["lat"].double,
                        let southwestLng = result["geometry"]["viewport"]["southwest"]["lng"].double,
                        let businessStatus = result["business_status"].string else {
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
                                 viewport: viewport,
                                 businessStatus: businessStatus)
                }

                completion(.success(pointsOfInterest))
            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    func loadTopEateries(place: Placeable, completion: @escaping(Result<[Eatery], Error>) -> Void) {
        guard let yelpAPIKey = AppDelegate.getAPIKeys()?.yelpAPI else {
            completion(.failure(NetworkError.APIKeysFetchFailure))
            return
        }

        let url = createUrl(with: place, and: .topEateries)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(yelpAPIKey)"
        ]

        AF.request(url, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let eateryCollection = try? self.customDecoder.decode(EateryCollection.self, from: data) else {
                    completion(.failure(NetworkError.jsonDecoding))
                    return
                }

                guard eateryCollection.hasSufficientEateries else {
                    completion(.failure(NetworkError.insufficientResults))
                    return
                }

                completion(.success(eateryCollection.businesses))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadGoogleRestaurants(place: Placeable, completion: @escaping(Result<[Eatable], Error>) -> Void) {
        let url = createUrl(with: place, and: .googleRestaurants)

        AF.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                // POSTLAUNCH: - refactor into a JSON init method
                guard let results = json["results"].array, results.count > 2 else {
                    completion(.failure(NetworkError.insufficientResults))
                    return
                }

                let restaurants = results[0..<3].compactMap { result -> Place? in
                    guard let name = result["name"].string,
                        let placeId = result["place_id"].string,
                        let centerLat = result["geometry"]["location"]["lat"].double,
                        let centerLng = result["geometry"]["location"]["lng"].double,
                        let northeastLat = result["geometry"]["viewport"]["northeast"]["lat"].double,
                        let northeastLng = result["geometry"]["viewport"]["northeast"]["lng"].double,
                        let southwestLat = result["geometry"]["viewport"]["southwest"]["lat"].double,
                        let southwestLng = result["geometry"]["viewport"]["southwest"]["lng"].double,
                        let businessStatus = result["business_status"].string else {
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
                                 viewport: viewport,
                                 businessStatus: businessStatus)
                }

                completion(.success(restaurants))
            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    func loadPhoto(placeId: String, completion: @escaping(Result<UIImage, Error>) -> Void) {
        guard let photoField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue)) else {
            completion(.failure(NetworkError.malformedPhotoField))
            return
        }
        GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeId, placeFields: photoField, sessionToken: nil) { place, error in
            if let place = place {
                if let photoMetadata = place.photos?.first {
                    GMSPlacesClient.shared().loadPlacePhoto(photoMetadata) { image, error in
                        if let image = image {
                            completion(.success(image))
                        } else if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.failure(NetworkError.unknown))
                        }
                    }
                } else {
                    completion(.failure(NetworkError.photoMetadataMissing))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NetworkError.unknown))
            }
        }
    }

    func getPlaceId(placeName: String, completion: @escaping(Result<Place, Error>) -> Void) {
        guard let url = createUrlWithPlaceName(placeName) else {
            completion(.failure(NetworkError.APIKeysFetchFailure))
            return
        }

        AF.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let result = json["results"].array?.first,
                    let placeId = result["place_id"].string else {
                    completion(.failure(NetworkError.malformedJSON))
                    return
                }

                NetworkService().getPlace(id: placeId, completion: { result in
                    switch result {
                    case .success(let place):
                        completion(.success(place))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getResultPlaceId(name: String, completion: @escaping(Result<Place, Error>) -> Void) {
        guard let url = createUrlWithPlaceName(name) else {
            completion(.failure(NetworkError.APIKeysFetchFailure))
            return
        }

        AF.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let result = json["results"].array?.first,
                    let placeId = result["place_id"].string else {
                        completion(.failure(NetworkError.malformedJSON))
                    return
                }

                NetworkService().getPlace(id: placeId, completion: { result in
                    switch result {
                    case .success(let place):
                        completion(.success(place))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getPlace(id: String, completion: @escaping(Result<Place, Error>) -> Void) {
        guard let url = createUrlWithPlaceId(id) else {
            completion(.failure(NetworkError.APIKeysFetchFailure))
            return
        }

        AF.request(url).validate().responseJSON { response in
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
                    completion(.failure(NetworkError.malformedJSON))
                    return
                }

                // NOTE: Place Detail request optionally returns phone number, rating, reviews.
                // Documentation: https://developers.google.com/places/web-service/details
                let formattedPhoneNumber = result["international_phone_number"]?.string
                let rating = result["rating"]?.float
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                var reviews: [Review]?
                if let reviewsData = try? result["reviews"]?.rawData() {
                    reviews = try? self.customDecoder.decode([Review].self, from: reviewsData)
                }

                let place = Place(placeID: placeID,
                                  name: name,
                                  formattedAddress: formattedAddress,
                                  formattedPhoneNumber: formattedPhoneNumber,
                                  rating: rating,
                                  coordinate: coordinate,
                                  mapUrl: mapUrl,
                                  reviews: reviews)

                completion(.success(place))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getSummaryFor(_ city: String, completion: @escaping(Result<String, Error>) -> Void) {
        let cityWords = city.split(separator: " ")
        var cityParam = cityWords[0]
        for i in 1..<cityWords.count {
            cityParam += "+" + cityWords[i]
        }

        let url = "https://en.wikivoyage.org/w/api.php?action=query&prop=extracts&explaintext&format=json&titles=\(cityParam)"

        AF.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let query = json["query"]["pages"].dictionary, let pageIdKey = query.keys.first,
                    let extract = query[pageIdKey]?["extract"].string else {
                    return
                }
                completion(.success(extract))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadNewsFor(_ city: String, completion: @escaping(Result<[Article], Error>) -> Void) {
        guard let keyParam = AppDelegate.getAPIKeys()?.nyTimesAPI else {
            return
        }
        let url = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=\(city)&page=1&api-key=\(keyParam)"

        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                if let articleResponse = try? self.customDecoder.decode(ArticleResponse.self, from: data) {
                    completion(.success(articleResponse.response.docs))
                } else {
                    completion(.failure(NetworkError.jsonDecoding))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Convenience methods

    static func loadImage(from urlString: String, completion: @escaping(_ image: UIImage) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }

    /// Note: This returns a Data object because UIImage does not conform to Decodable. To use this, simply initialize a
    /// UIImage at the callsite with the Data object. Returns on the main queue.
//    static func loadCombineImage(urlString: String) -> AnyPublisher<Data, Error> {
//        let url = URL(string: urlString)!
//        return Agent().run(url)
//    }

    // MARK: - Private helper methods

    private func createUrl(with place: Placeable, and type: UrlType) -> String {
        switch type {
        case .topSights:
            guard let keyParam = AppDelegate.getAPIKeys()?.googleAPI else {
                return ""
            }
            let placeName = place.placeableName.split(separator: " ")
            var queryParam = "tourist+spots+in"
            placeName.forEach { word in
                queryParam += "+" + word
            }

            let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(queryParam)&key=\(keyParam)"

            return url
        case .googleRestaurants:
            guard let keyParam = AppDelegate.getAPIKeys()?.googleAPI else {
                return ""
            }
            let placeName = place.placeableName.split(separator: " ")
            var queryParam = "restaurants+in"
            placeName.forEach { word in
                queryParam += "+" + word
            }

            let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(queryParam)&key=\(keyParam)"

            return url
        case .topEateries:
            let latitude = place.placeableCoordinate.latitude
            let longitude = place.placeableCoordinate.longitude
            let url = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&categories=restaurants"

            return url
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
