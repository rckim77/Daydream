//
//  CurrentLocationManager.swift
//  Daydream
//
//  Created by Ray Kim on 11/15/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import CoreLocation
import Foundation

final class CurrentLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var location: CLLocationCoordinate2D?
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    private func requestAuth() {
        // if already determined, update status
        authStatus = manager.authorizationStatus
        manager.requestWhenInUseAuthorization()
    }
    
    func requestCurrentLocation() {
        let status = manager.authorizationStatus
        authStatus = status

        switch status {
        case .authorizedWhenInUse:
            manager.requestLocation()
        case .notDetermined:
            requestAuth()
        default: // could not get location for a variety of reasons
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            // when the user authorizes for use, immediately request location
            requestCurrentLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last?.coordinate
    }
    
    // Common errors: kCLErrorDomain code=0 (location unknown), code=1 (denied), code=2 (network)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        let errorMessage = error.localizedDescription
        print(errorMessage)
    }
}
