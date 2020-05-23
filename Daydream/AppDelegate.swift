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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let keys = AppDelegate.getAPIKeys() {
            GMSPlacesClient.provideAPIKey(keys.googleAPI)
            GMSServices.provideAPIKey(keys.googleAPI)
        }
        return true
    }

    static func getAPIKeys() -> APIKeys? {
        guard let path = Bundle.main.path(forResource: "apiKeys", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path),
            let keys = try? PropertyListDecoder().decode(APIKeys.self, from: xml) else {
                return nil
        }
        return keys
    }
}

struct APIKeys: Codable {
    let googleAPI: String
    let yelpAPI: String
}
