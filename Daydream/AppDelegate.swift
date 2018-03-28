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
    static let yelpAPIKey = "Zvdn64KWWEH-ViFv95YV-38j5BXwRcuaE4G_9VYlfSqrWGa_TBS3bW_kf1YxJyrDjVtXkSb4eav0W3iZ1km00j39vAbvGIbs5iP4ok3uEC2XIH_h79eNAV_fIUyrWnYx"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSPlacesClient.provideAPIKey(AppDelegate.googleAPIKey)
        GMSServices.provideAPIKey(AppDelegate.googleAPIKey)
        return true
    }

}
