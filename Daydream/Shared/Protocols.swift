//
//  Protocols.swift
//  Daydream
//
//  Created by Raymond Kim on 3/27/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import CoreLocation

protocol RandomCitySelectable {
    func getRandomCity() -> RandomCity?
}

extension RandomCitySelectable {
    func getRandomCity() -> RandomCity? {
        guard let path = Bundle.main.path(forResource: "randomCitiesJSON", ofType: "json") else {
            return nil
        }

        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let randomCities = try JSONCustomDecoder().decode([RandomCity].self, from: data)
            let randomIndex = Int(arc4random_uniform(UInt32(randomCities.count)))
            return randomCities[randomIndex]
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
