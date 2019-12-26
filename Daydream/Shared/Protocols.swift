//
//  Protocols.swift
//  Daydream
//
//  Created by Raymond Kim on 3/27/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

protocol Placeable: class {
    var placeableId: String? { get }
    var placeableName: String? { get }
    var placeableFormattedAddress: String? { get }
    var placeableFormattedPhoneNumber: String? { get }
    var placeableRating: Float? { get }
    var placeableCoordinate: CLLocationCoordinate2D { get }
    var placeableViewport: Viewport? { get }
    var placeableMapUrl: String? { get }
    var placeableReviews: [Reviewable]? { get }
}

protocol Reviewable: class {
    var author: String { get }
    var rating: Int { get }
    var review: String? { get }
    var authorUrl: String? { get }
    var authorProfileUrl: String? { get }
}

protocol RandomCitySelectable {
    func getRandomCity() -> String?
}

extension RandomCitySelectable {
    func getRandomCity() -> String? {
        guard let path = Bundle.main.path(forResource: "randomCitiesJSON", ofType: "json") else {
            return nil
        }

        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let json = JSON(data).arrayValue
            let randomInt = Int(arc4random_uniform(UInt32(json.count)))
            let city = json[randomInt]["city"].stringValue

            return city
        } catch {
            return nil
        }
    }
}

protocol ImageViewFadeable {
    func fadeInImage(_ image: UIImage, forImageView imageView: UIImageView)
}

extension ImageViewFadeable {
    func fadeInImage(_ image: UIImage, forImageView imageView: UIImageView) {
        imageView.alpha = 0
        imageView.image = image
        UIView.animate(withDuration: 0.6) {
            imageView.alpha = 1
        }
    }
}

protocol Loggable {
    func logEvent(contentType: String, _ title: String?)
    func logSearchEvent(searchTerm: String, placeId: String)
    func logErrorEvent(_ error: Error?)
}
