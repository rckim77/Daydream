//
//  CurrentLocationManager.swift
//  Daydream
//
//  Created by Ray Kim on 11/15/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import CoreLocation
import Foundation
import Observation

@Observable
final class CurrentLocationManager: NSObject, CLLocationManagerDelegate {

    private(set) var authStatus: CLAuthorizationStatus = .notDetermined
    var location: CLLocationCoordinate2D?
    private(set) var requestFailureCount = 0
    private(set) var locationUpdateCount = 0
    
    private let manager: CLLocationManager
    
    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
        manager.delegate = self
    }
    
    private func requestAuth() {
        // if already determined, update status
        authStatus = manager.authorizationStatus
        manager.requestWhenInUseAuthorization()
    }
    
    func requestCurrentLocation() -> CLAuthorizationStatus {
        let status = manager.authorizationStatus
        authStatus = status

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .notDetermined:
            requestAuth()
        default: // could not get location for a variety of other reasons
            break
        }
        
        return status
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            // when the user authorizes for use, immediately request location
            _ = requestCurrentLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last?.coordinate
        // An identical coordinate still completes requestLocation; coordinate equality is not an event.
        locationUpdateCount += 1
    }
    
    // Common errors: kCLErrorDomain code=0 (location unknown), code=1 (denied), code=2 (network)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        requestFailureCount += 1
    }
}
