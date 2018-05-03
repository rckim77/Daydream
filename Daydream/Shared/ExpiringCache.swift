//
//  ImageCache.swift
//  Daydream
//
//  Created by Raymond Kim on 4/30/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit

// Default time interval is 1 hour
private let kDefaultTimeInterval: TimeInterval = 60

// Expiring, thread safe, in memory cache using a concurrent queue with dispatch barriers.
// More performant than a serial queue with async/sync calls and more Swift-y than
// NSCache since our cache values don't have to conform to AnyObject.
class ExpiringCache<K: Hashable, V: Any> {

    private let duration: TimeInterval
    private let queue = DispatchQueue(label: "ImageCache.Queue", attributes: .concurrent)
    private var cache: [K: CacheValue<V>] = [:]
    private var observer: NSObjectProtocol!
    private var timer: Timer!

    init(duration: TimeInterval = kDefaultTimeInterval) {
        self.duration = duration

        observer = NotificationCenter.default.addObserver(forName: .UIApplicationDidReceiveMemoryWarning,
                                                          object: nil,
                                                          queue: nil) { [weak self] _ in
            print("added observer")
            self?.emptyCache()
        }

        print("initiating timer")
        timer = Timer(timeInterval: duration, repeats: true, block: { [weak self] _ in
            print("it's been a minute, check if expired")
            self?.checkIfExpired()
        })

        DispatchQueue.main.async {
            print("added timer to run loop on main thread")
            RunLoop.current.add(self.timer, forMode: .defaultRunLoopMode)
        }
    }

    func getValue(for key: K, completion: @escaping ((V?) -> Void)) {
        print("getting value async")
        queue.async { [weak self] in
            completion(self?.cache[key]?.value)
        }
    }

    func setValue(_ value: V, for key: K) {
        guard cache[key] != nil else { return }

        // Dispatch barriers allow you to run async and sync calls on the same
        // concurrent queue without risking thread-unsafe behavior by guaranteeing
        // read calls execute before any write calls and pending read
        // calls execute only after write calls finish executing.
        queue.async(flags: .barrier) { [weak self] in
            self?.cache[key] = CacheValue(value)
        }
    }

    private func removeValue(for key: K) {
        queue.async(flags: .barrier) { [ weak self] in
            self?.cache[key] = nil
        }
    }

    private func emptyCache() {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeAll()
        }
    }

    private func checkIfExpired() {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            let keys = strongSelf.queue.sync(execute: {
                return strongSelf.cache.keys
            })

            for key in keys {
                if let value = strongSelf.cache[key], value.isExpired(strongSelf.duration) {
                    print("removing value \(value) for key \(key)")
                    strongSelf.removeValue(for: key)
                }
            }
        }
    }

    deinit {
        print("removing observer")
        NotificationCenter.default.removeObserver(observer,
                                                  name: .UIApplicationDidReceiveMemoryWarning,
                                                  object: nil)
    }
}

private struct CacheValue<V> {
    var value: V
    var date = Date()

    func isExpired(_ duration: TimeInterval) -> Bool {
        return abs(date.timeIntervalSinceNow) > duration
    }
}

// By adding a custom convenience init inside an extension, we preserve the default
// compiler-generated init.
extension CacheValue {
    init(_ value: V) {
        self.value = value
    }
}
