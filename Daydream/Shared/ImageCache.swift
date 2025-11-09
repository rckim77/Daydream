//
//  ImageCache.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlacesSwift

/// Uses `Photo` hashValue as hash key (converted from `Int` to `String`).
final class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
}

final class PlaceObject: NSObject {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
}

/// Uses `placeId` String as hash key.
final class PlacesCache {
    static let shared = PlacesCache()
    
    private let cache = NSCache<NSString, PlaceObject>()
    
    private init() {}
    
    func set(_ place: Place, forKey key: String) {
        let placeObject = PlaceObject(place: place)
        cache.setObject(placeObject, forKey: key as NSString)
    }
    
    func get(forKey key: String) -> Place? {
        guard let object = cache.object(forKey: key as NSString) else {
            return nil
        }
        return object.place
    }
}
