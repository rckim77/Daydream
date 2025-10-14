//
//  AppDelegate.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacesSwift
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /// Temporary variable to hold a shortcut item from the launching or activation of the app.
    private var shortcutItemToProcess: UIApplicationShortcutItem?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let keys = AppDelegate.getAPIKeys() {
            _ = PlacesClient.provideAPIKey(keys.placesNewAPI)
            GMSPlacesClient.provideAPIKey(keys.googleAPI)
            GMSServices.provideAPIKey(keys.googleAPI)
        }

        // If launchOptions contains the appropriate launch options key, a Home screen quick action
        // is responsible for launching the app. Store the action for processing once the app has
        // completed initialization.
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            shortcutItemToProcess = shortcutItem
        }
        
        window?.rootViewController = SearchViewController()
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // Alternatively, a shortcut item may be passed in through this delegate method if the app was
        // still in memory when the Home screen quick action was used. Again, store it for processing.
        shortcutItemToProcess = shortcutItem
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if var topVC = window?.rootViewController, shortcutItemToProcess != nil {
            while let presentedVC = topVC.presentedViewController {
                topVC = presentedVC
            }
            if let topVC = topVC as? SearchViewController {
                topVC.randomButtonTapped()
            } else if let topVC = topVC as? SearchDetailViewController {
                topVC.randomCityButtonTapped()
            }

            // Reset the shortcut item so it's never processed twice.
            shortcutItemToProcess = nil
        }
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
    let placesNewAPI: String
    let googleAPI: String
    let yelpAPI: String
}
