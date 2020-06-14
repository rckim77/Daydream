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
import Combine

typealias SightsAndEateries = ([Place], [Eatery])

// swiftlint:disable type_body_length
class NetworkService {

    private lazy var customDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// Can be used to return any set of Google Place objects (e.g., sights, fallback restaurants) filtered by the parameters
    /// set in the input url.
    func loadPlaces(url: URL) -> AnyPublisher<[Place], Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ResultsCollection.self, decoder: customDecoder)
            .map { $0.results }
            .eraseToAnyPublisher()
    }

    func loadEateries(place: Place, urlRequest: URLRequest, fallbackUrl: URL) -> AnyPublisher<[Eatable], Error> {
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { [weak self] response -> [Eatable] in
                guard let eateries = try? self?.customDecoder.decode(EateryCollection.self, from: response.data) else {
                    throw NetworkError.malformedJSON
                }
                return eateries.businesses as [Eatable]
            }
            .tryCatch { [weak self] error -> AnyPublisher<[Eatable], Error> in
                guard let networkError = error as? NetworkError,
                    let strongSelf = self,
                    networkError == .malformedJSON else {
                    throw error
                }
                return strongSelf.loadPlaces(url: fallbackUrl)
                    .map { $0 as [Eatable] }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Load photo as UIImage using Google Places SDK
    func loadPhoto(placeId: String) -> Future<UIImage, Error> {
        return Future<UIImage, Error> { promise in
            guard let photoField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue)) else {
                promise(.failure(NetworkError.malformedPhotoField))
                return
            }

            GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeId, placeFields: photoField, sessionToken: nil) { place, error in
                if let place = place {
                    if let photoMetadata = place.photos?.first {
                        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata) { image, error in
                            if let image = image {
                                promise(.success(image))
                            } else if let error = error {
                                promise(.failure(error))
                            } else {
                                promise(.failure(NetworkError.unknown))
                            }
                        }
                    } else {
                        promise(.failure(NetworkError.photoMetadataMissing))
                    }
                } else if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.failure(NetworkError.unknown))
                }
            }
        }
    }

    /// Load photo as UIImage using Google Places SDK.
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

    /// Returns a Place object from a name.
    func getPlaceId(placeName: String, completion: @escaping(Result<Place, Error>) -> Void) {
        guard let url = GooglePlaceTextSearchRoute(name: placeName, queryType: .placeByName)?.url else {
            completion(.failure(NetworkError.routeError))
            return
        }

        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                guard let result = try? self.customDecoder.decode(ResultsCollection.self, from: data),
                    let placeId = result.results.first?.placeId else {
                    completion(.failure(NetworkError.jsonDecoding))
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

    /// Returns a Place object from a place id.
    func getPlace(id: String, completion: @escaping(Result<Place, Error>) -> Void) {
        guard let url = GooglePlaceDetailsRoute(placeId: id)?.url else {
            completion(.failure(NetworkError.routeError))
            return
        }

        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                guard let place = try? self.customDecoder.decode(PlaceCollection.self, from: data) else {
                    completion(.failure(NetworkError.jsonDecoding))
                    return
                }
                completion(.success(place.result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Gets city summary text from Wikivoyage (currently unused)
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

    /// Gets articles using the New York Times Article API (currently unused)
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

    /// Note: Returns on the main queue and with errors erased.
    static func loadImage(url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: UIImage())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
