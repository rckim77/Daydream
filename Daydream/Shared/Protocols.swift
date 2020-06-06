//
//  Protocols.swift
//  Daydream
//
//  Created by Raymond Kim on 3/27/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import Firebase

enum PlaceBusinessStatus: String {
    case operational = "OPERATIONAL"
    case closedTemporarily = "CLOSED_TEMPORARILY"
    case closedPermanently = "CLOSED_PERMANENTLY"

    var displayValue: String {
        switch self {
        case .operational:
            return "operational"
        case .closedTemporarily:
            return "closed temporarily"
        case .closedPermanently:
            return "closed permanently"
        }
    }

    var displayColor: UIColor {
        switch self {
        case .operational:
            return .systemGreen
        case .closedTemporarily:
            return .systemOrange
        case .closedPermanently:
            return .systemRed
        }
    }

    var imageName: String? {
        switch self {
        case .closedTemporarily:
            return "exclamationmark.triangle.fill"
        case .closedPermanently:
            return "nosign"
        case .operational:
            return nil
        }
    }
}

protocol Placeable: class {
    var placeableId: String { get }
    var placeableName: String { get }
    var placeableFormattedAddress: String? { get }
    var placeableFormattedPhoneNumber: String? { get }
    var placeableRating: Float? { get }
    var placeableCoordinate: CLLocationCoordinate2D { get }
    var placeableViewport: Viewport? { get }
    var placeableMapUrl: String? { get }
    var placeableReviews: [Reviewable]? { get }
    var placeableBusinessStatus: PlaceBusinessStatus? { get }
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
        UIView.animate(withDuration: 0.5) {
            imageView.alpha = 1
        }
    }
}

protocol Loggable {
    func logEvent(contentType: String, _ title: String?)
    func logSearchEvent(searchTerm: String, placeId: String)
    func logErrorEvent(_ error: Error?)
}

extension Loggable {
    func logEvent(contentType: String, _ title: String?) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(String(describing: title))",
            AnalyticsParameterContentType: contentType
        ])
    }

    func logSearchEvent(searchTerm: String, placeId: String) {
        Analytics.logEvent(AnalyticsEventSearch, parameters: [
            AnalyticsParameterSearchTerm: searchTerm,
            AnalyticsParameterLocation: placeId
        ])
    }

    func logErrorEvent(_ error: Error?) {
        Analytics.logEvent("DaydreamAppError", parameters: [
            "Error": String(describing: error)
        ])
    }
}
