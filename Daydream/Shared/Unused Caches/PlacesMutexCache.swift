//
//  PlacesMutexCache.swift
//  Daydream
//
//  Created by Ray Kim on 12/11/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import GooglePlacesSwift
import Synchronization
import UIKit

/// CURRENTLY UNUSED. The cache uses a `Mutex` primitive to ensure safe access to the cache across
/// threads without the overhead of an actor. Whereas an actor shines when adopting
/// an asynchronous process, mutexes work better for synchronous, immediate access.
final class PlacesMutexCache {
    static let shared = PlacesMutexCache()
    
    private let cache = Mutex<[String: Place]>([:])
    
    private init() {}
    
    func set(_ place: Place, forKey key: String) {
        cache.withLock { cache in
            cache[key] = place
        }
    }
    
    func get(forKey key: String) -> Place? {
        cache.withLock { cache in
            return cache[key]
        }
    }
    
    func clear() -> Void {
        cache.withLock { cache in
            cache = [:]
        }
    }
}
