//
//  ImageCache.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import Synchronization
import UIKit

/// Uses `Photo` hashValue as hash key (converted from `Int` to `String`).
/// The cache uses a `Mutex` primitive to ensure safe access to the cache across
/// threads without the overhead of an actor. Whereas an actor shines when adopting
/// an asynchronous process, mutexes work better for synchronous, immediate access.
final class ImageCache {
    static let shared = ImageCache()
    
    private let cache = Mutex<NSCache<NSString, UIImage>>(NSCache<NSString, UIImage>())
    
    private init() {}
    
    func set(_ image: UIImage, forKey key: String) {
        cache.withLock { cache in
            cache.setObject(image, forKey: key as NSString)
        }
    }
    
    func get(forKey key: String) -> UIImage? {
        cache.withLock { cache in
            return cache.object(forKey: key as NSString)
        }
    }
    
    func clear() -> Void {
        cache.withLock { cache in
            cache.removeAllObjects()
        }
    }
}
