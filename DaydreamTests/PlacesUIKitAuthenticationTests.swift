import GooglePlacesSwift
import SwiftUI
import XCTest
@testable import Daydream

/// Read-only, opt-in comparison of Place Details and Places UI Kit using the same existing key.
final class PlacesUIKitAuthenticationTests: XCTestCase {
    @MainActor
    func testExistingPlacesConfiguration() async throws {
        let udid = ProcessInfo.processInfo.environment["SIMULATOR_UDID"] ?? ""
        guard let data = FileManager.default.contents(atPath: "/tmp/daydream-places-auth-probe-\(udid).json") else {
            throw XCTSkip("Provide a local configuration to inspect the existing UI Kit authentication result.")
        }
        let configuration = try JSONDecoder().decode(Configuration.self, from: data)
        guard configuration.expiresAt > Date().timeIntervalSince1970 else { throw XCTSkip("Diagnostic configuration expired.") }
        let keys = try XCTUnwrap(AppDelegate.getAPIKeys())
        let initialized = PlacesClient.provideAPIKey(keys.placesNewAPI)
        let identifier = "ChIJ8T1GpMGOGGARDYGSgpooDWw"
        let control = await PlacesClient.shared.fetchPlace(with: FetchPlaceRequest(
            placeID: identifier, placeProperties: [.placeID, .displayName]
        ))
        var report: [String: Any] = [
            "bundleIdentifier": Bundle.main.bundleIdentifier ?? "missing",
            "sdkVersion": PlacesClient.sdkVersion,
            "keyRegistrationSucceeded": initialized,
            "mapsAndPlacesUseSameKey": keys.googleAPI == keys.placesNewAPI
        ]
        switch control {
        case .success: report["placeDetailsControlSucceeded"] = true
        case .failure(let error):
            report["placeDetailsControlSucceeded"] = false
            report["placeDetailsControlError"] = sanitized(String(describing: error), keys: keys)
        }

        let completed = expectation(description: "UI Kit returned place details or an error")
        var callbackReceived = false
        var succeeded = false
        let component = GooglePlacesSwift.PlaceDetailsView(
            query: .constant(PlaceDetailsQuery(identifier: .placeID(identifier))),
            configuration: PlaceDetailsConfiguration(content: GooglePlacesSwift.PlaceDetailsView.standardContent, theme: PlacesMaterialTheme()),
            placeDetailsCallback: { result in
                guard !callbackReceived else { return }
                callbackReceived = true
                succeeded = result.place != nil && result.error == nil
                report["uiKitSucceeded"] = succeeded
                if let error = result.error {
                    let nsError = error as NSError
                    report["errorType"] = String(reflecting: type(of: error))
                    report["error"] = self.sanitized(String(describing: error), keys: keys)
                    report["errorDomain"] = nsError.domain
                    report["errorCode"] = nsError.code
                    report["errorUserInfoKeys"] = nsError.userInfo.keys.sorted()
                    report["errorDescription"] = self.sanitized(nsError.localizedDescription, keys: keys)
                    if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                        report["underlyingDomain"] = underlying.domain
                        report["underlyingCode"] = underlying.code
                        report["underlyingDescription"] = self.sanitized(underlying.localizedDescription, keys: keys)
                    }
                }
                completed.fulfill()
            }
        )
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(rootView: component)
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        await fulfillment(of: [completed], timeout: 30)
        report["callbackReceived"] = callbackReceived
        let output = URL(fileURLWithPath: configuration.outputDirectory, isDirectory: true)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
            .write(to: output.appendingPathComponent("places-ui-kit-authentication.json"))
        XCTAssertTrue(succeeded, "UI Kit failed with the existing configuration; see the sanitized local diagnostic report.")
    }

    private func sanitized(_ value: String, keys: APIKeys) -> String {
        value.replacingOccurrences(of: keys.placesNewAPI, with: "[REDACTED]")
            .replacingOccurrences(of: keys.googleAPI, with: "[REDACTED]")
    }
}

private struct Configuration: Decodable {
    let expiresAt: TimeInterval
    let outputDirectory: String
}
