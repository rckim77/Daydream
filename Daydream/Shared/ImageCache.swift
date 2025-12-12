//
//  ImageCache.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import Synchronization
import UIKit

/// Uses `Photo` hashValue as hash key (converted from `Int` to `String`) and
/// `NSCache` to manage thread safety.
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
    
    func clear() -> Void {
        cache.removeAllObjects()
    }
}


