import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else { return }

		let window = UIWindow(windowScene: windowScene)
		if isRunningTests {
            // fixes CI crash due to SearchViewController
			window.rootViewController = UIViewController()
		} else {
			window.rootViewController = SearchViewController()
		}
		self.window = window
		window.makeKeyAndVisible()
	}

	private var isRunningTests: Bool {
		ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
	}
}
