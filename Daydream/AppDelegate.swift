//
//  AppDelegate.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static let googleAPIKey = "AIzaSyCRTEmO9WvcWJ-n5GJ1FLCiHK7FOK-wgZ0"
    static let yelpAPIKey = "ENTER YELP API KEY"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSPlacesClient.provideAPIKey(AppDelegate.googleAPIKey)
        GMSServices.provideAPIKey(AppDelegate.googleAPIKey)
        return true
    }

}
