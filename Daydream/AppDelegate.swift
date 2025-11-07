//
//  AppDelegate.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlacesSwift
import GoogleMaps
import TipKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		if let keys = AppDelegate.getAPIKeys() {
			_ = PlacesClient.provideAPIKey(keys.placesNewAPI)
			GMSServices.provideAPIKey(keys.googleAPI)
		}
        
        try? Tips.configure()
        
		return true
	}

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
		configuration.delegateClass = SceneDelegate.self
		return configuration
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
}
