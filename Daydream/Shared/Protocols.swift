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
