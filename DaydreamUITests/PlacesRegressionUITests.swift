import XCTest

/// Opt-in, live-service regression coverage. Uses dedicated simulators and keeps captures out of Git.
final class PlacesRegressionUITests: XCTestCase {
    @MainActor
    func testPlacesRegression() throws {
        continueAfterFailure = false
        let udid = ProcessInfo.processInfo.environment["SIMULATOR_UDID"] ?? ""
        let configURL = URL(fileURLWithPath: "/tmp/daydream-places-qa-\(udid).json")
        guard let data = try? Data(contentsOf: configURL) else {
            throw XCTSkip("Provide an unexpired local Places QA configuration to run live-service checks.")
        }
        let config = try JSONDecoder().decode(Configuration.self, from: data)
        guard config.expiresAt > Date().timeIntervalSince1970 else { throw XCTSkip("Places QA configuration expired.") }
        let output = URL(fileURLWithPath: config.outputDirectory, isDirectory: true)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let app = XCUIApplication(bundleIdentifier: "com.rckim.Daydream")
        app.launchEnvironment["DAYDREAM_UI_CAPTURE_CITIES"] = "Tokyo|Paris|New York City|Hong Kong|Rome"
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        if config.largeText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        XCUIDevice.shared.orientation = config.landscape ? .landscapeLeft : .portrait
        app.launch()
        defer { app.terminate(); XCUIDevice.shared.orientation = .portrait }
        func capture(_ name: String) throws {
            // Allow presentation/rotation and keyboard animations to finish before judging layout.
            Thread.sleep(forTimeInterval: 1.5)
            try XCUIScreen.main.screenshot().pngRepresentation.write(to: output.appendingPathComponent("\(name).png"))
            try app.debugDescription.write(to: output.appendingPathComponent("\(name).txt"), atomically: true, encoding: .utf8)
        }
        XCTAssertTrue(app.buttons["city-loaded-Tokyo"].waitForExistence(timeout: 90))
        try capture("home")
        app.buttons["city-search-button"].tap()
        XCTAssertTrue(app.textFields.firstMatch.waitForExistence(timeout: 10))
        app.textFields.firstMatch.tap()
        try capture("search-keyboard")
        app.textFields.firstMatch.typeText("zzzxqvnonexistentcity123456789")
        Thread.sleep(forTimeInterval: 3)
        XCTAssertFalse(app.buttons["AutocompleteWidgetSuggestionButton0"].exists)
        try capture("search-empty")
        app.buttons["Clear search"].tap()
        app.textFields.firstMatch.typeText("Tokyo")
        let tokyo = app.buttons["AutocompleteWidgetSuggestionButton0"]
        XCTAssertTrue(tokyo.waitForExistence(timeout: 30))
        try capture("search-results")
        tokyo.tap()
        XCTAssertTrue(app.staticTexts["Top Sights"].waitForExistence(timeout: 60))
        Thread.sleep(forTimeInterval: 4)
        try capture("detail")
        let card = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@ AND identifier != %@", "place-card-", "place-card-loading")).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 60))
        for _ in 0..<5 where !card.isHittable { app.swipeUp() }
        XCTAssertTrue(card.isHittable)
        try capture("discoveries")
        card.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3)).tap()
        XCTAssertTrue(app.buttons["map-close-button"].waitForExistence(timeout: 30))
        // Allow the selected place's review summary and map tiles to finish loading.
        Thread.sleep(forTimeInterval: 6)
        try capture("map")
        let reviewsReady = NSPredicate { _, _ in
            app.staticTexts["map-review-summary"].exists || app.buttons["map-review-card"].exists
        }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: reviewsReady, object: nil)], timeout: 30), .completed)
        try capture("map-reviews")
        XCUIDevice.shared.orientation = config.landscape ? .portrait : .landscapeRight
        try capture("map-rotated")
        XCTAssertTrue(app.buttons["map-close-button"].isHittable)
        XCUIDevice.shared.orientation = config.landscape ? .landscapeLeft : .portrait
        app.buttons["map-appearance-button"].tap()
        try capture("map-appearance")
        app.buttons["map-close-button"].tap()
        XCTAssertTrue(app.buttons["home-button"].waitForExistence(timeout: 10))
        app.buttons["home-button"].tap()
        XCTAssertTrue(app.buttons["random-city-button"].waitForExistence(timeout: 10))
        app.buttons["random-city-button"].tap()
        XCTAssertTrue(app.buttons["home-button"].waitForExistence(timeout: 90))
        try capture("random-city")
        if let locationMode = config.locationMode {
            app.buttons["home-button"].tap()
            app.buttons["current-city-button"].tap()
            if locationMode == "denied" {
                XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 10))
                try capture("location-denied")
                app.buttons["Cancel"].tap()
            } else {
                XCTAssertTrue(app.buttons["home-button"].waitForExistence(timeout: 90))
                try capture("current-city")
            }
        }
    }
}

private struct Configuration: Decodable {
    let outputDirectory: String
    let expiresAt: TimeInterval
    let landscape: Bool
    let largeText: Bool
    let locationMode: String?
}
