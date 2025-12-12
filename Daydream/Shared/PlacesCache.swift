//
//  PlacesCache.swift
//  Daydream
//
//  Created by Ray Kim on 11/9/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import Foundation
import GooglePlacesSwift
import Synchronization

/// Reference type wrapper for `Place` object, used in `PlacesCache`
final class PlaceObject: NSObject {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
}

/// Uses `placeId` String as hash key.
/// The cache uses a `Mutex` primitive to ensure safe access to the cache across
/// threads without the overhead of an actor. Whereas an actor shines when adopting
/// an asynchronous process, mutexes work better for synchronous, immediate access.
final class PlacesCache {
    static let shared = PlacesCache()
    
    private let cache = Mutex<NSCache<NSString, PlaceObject>>(NSCache<NSString, PlaceObject>())
    
    private init() {}
    
    func set(_ place: Place, forKey key: String) {
        let placeObject = PlaceObject(place: place)
        cache.withLock { cache in
            cache.setObject(placeObject, forKey: key as NSString)
        }
    }
    
    func get(forKey key: String) -> Place? {
        cache.withLock { cache in
            guard let object = cache.object(forKey: key as NSString) else {
                return nil
            }
            return object.place
        }
    }
    
    func clear() -> Void {
        cache.withLock { cache in
            cache.removeAllObjects()
        }
    }
}
