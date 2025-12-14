//
//  ImageMutexCache.swift
//  Daydream
//
//  Created by Ray Kim on 12/11/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import Synchronization
import UIKit

/// CURRENTLY UNUSED. The cache uses a `Mutex` primitive to ensure safe access to the cache across
/// threads without the overhead of an actor. Whereas an actor shines when adopting
/// an asynchronous process, mutexes work better for synchronous, immediate access.
final class ImageMutexCache {
    static let shared = ImageMutexCache()
    
    private let cache = Mutex<[String: UIImage]>([:])
    
    private init() {}
    
    func set(_ image: UIImage, forKey key: String) {
        cache.withLock { cache in
            cache[key] = image
        }
    }
    
    func get(forKey key: String) -> UIImage? {
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
