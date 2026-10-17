import XCTest

/// Opt-in reproduction for the Nearby request teardown crash; uses live SDK calls.
final class PlacesRequestStressUITests: XCTestCase {
    @MainActor
    func testRepeatedCityLoading() throws {
        continueAfterFailure = false
        let udid = ProcessInfo.processInfo.environment["SIMULATOR_UDID"] ?? ""
        guard let data = FileManager.default.contents(atPath: "/tmp/daydream-places-stress-\(udid).json") else {
            throw XCTSkip("Provide a local stress configuration to run repeated live SDK requests.")
        }
        let config = try JSONDecoder().decode(Configuration.self, from: data)
        guard config.expiresAt > Date().timeIntervalSince1970 else { throw XCTSkip("Stress configuration expired.") }
        guard (1...10).contains(config.iterations) else { throw XCTSkip("Choose 1–10 stress iterations.") }
        let app = XCUIApplication(bundleIdentifier: "com.rckim.Daydream")
        app.launchEnvironment["DAYDREAM_UI_CAPTURE_CITIES"] = "Tokyo|Paris|New York City|Hong Kong|Rome|London"
        if config.largeText {
            app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        }
        let output = URL(fileURLWithPath: config.outputDirectory, isDirectory: true)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        for iteration in 1...config.iterations {
            app.launch()
            let loaded = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "city-loaded-"))
            let ready = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in loaded.count == 6 }, object: nil)
            XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 90), .completed)
            try XCUIScreen.main.screenshot().pngRepresentation.write(to: output.appendingPathComponent("launch-\(iteration).png"))
            app.terminate()
        }
    }
}

private struct Configuration: Decodable {
    let expiresAt: TimeInterval
    let outputDirectory: String
    let iterations: Int
    let largeText: Bool
}
