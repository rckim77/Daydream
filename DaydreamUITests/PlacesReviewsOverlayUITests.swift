import XCTest

/// Opt-in live-service coverage for the provided reviews overlay; no credentials in configuration.
final class PlacesReviewsOverlayUITests: XCTestCase {
    @MainActor
    func testGoogleReviewsOverlay() throws {
        continueAfterFailure = false
        print("Provided reviews overlay QA revision 5")
        let udid = ProcessInfo.processInfo.environment["SIMULATOR_UDID"] ?? ""
        let configURL = URL(fileURLWithPath: "/tmp/daydream-reviews-ui-\(udid).json")
        guard let data = try? Data(contentsOf: configURL) else {
            throw XCTSkip("Provide a current local reviews UI configuration to run this live-service check.")
        }
        let config = try JSONDecoder().decode(Configuration.self, from: data)
        guard config.expiresAt > Date().timeIntervalSince1970 else { throw XCTSkip("Reviews UI configuration expired.") }
        let output = URL(fileURLWithPath: config.outputDirectory, isDirectory: true)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let app = XCUIApplication(bundleIdentifier: "com.rckim.Daydream")
        app.launchEnvironment["DAYDREAM_UI_CAPTURE_CITIES"] = "Tokyo|Paris|New York City|Hong Kong|Rome"
        if config.largeText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        defer { app.terminate(); XCUIDevice.shared.orientation = .portrait }
        addUIInterruptionMonitor(withDescription: "Store review prompt") { alert in
            guard alert.buttons["Not Now"].exists else { return false }
            alert.buttons["Not Now"].tap()
            return true
        }
        func capture(_ name: String) throws {
            if app.buttons["Not Now"].exists { app.buttons["Not Now"].tap() }
            Thread.sleep(forTimeInterval: 1)
            try XCUIScreen.main.screenshot().pngRepresentation.write(to: output.appendingPathComponent(name + ".png"))
            try app.debugDescription.write(to: output.appendingPathComponent(name + ".txt"), atomically: true, encoding: .utf8)
        }
        XCTAssertTrue(app.buttons["city-loaded-Tokyo"].waitForExistence(timeout: 90))
        app.buttons["city-loaded-Tokyo"].tap()
        let card = app.buttons.containing(.staticText, identifier: "Sensō-ji").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 60))
        for _ in 0..<10 {
            let safe = CGRect(x: app.frame.minX, y: 80, width: app.frame.width, height: app.frame.height - 180)
            let visible = card.frame.intersection(safe)
            if !visible.isNull && visible.height >= min(100, card.frame.height * 0.5) { break }
            let delta = card.frame.maxY > app.frame.maxY - 100
                ? min(card.frame.maxY - (app.frame.maxY - 100) + 12, app.frame.height * 0.4)
                : max(card.frame.minY - 92, -app.frame.height * 0.4)
            let start = app.coordinate(withNormalizedOffset: .zero)
                .withOffset(CGVector(dx: 12, dy: app.frame.height * (delta > 0 ? 0.7 : 0.3)))
            start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: 0, dy: -delta)), withVelocity: .slow, thenHoldForDuration: 0.2)
        }
        let visible = card.frame.intersection(CGRect(x: app.frame.minX, y: 80, width: app.frame.width, height: app.frame.height - 180))
        try capture("discoveries")
        // StoreKit can present after the screenshot begins, outside XCTest's alert monitor.
        if app.buttons["Not Now"].waitForExistence(timeout: 2) {
            app.buttons["Not Now"].tap()
            try capture("discoveries")
        }
        XCTAssertFalse(visible.isNull)
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: visible.midX, dy: visible.midY)).tap()
        XCTAssertTrue(app.buttons["map-close-button"].waitForExistence(timeout: 30))
        try capture("map-initial")
        let overlay = app.descendants(matching: .any).matching(identifier: "map-reviews-overlay").firstMatch
        XCTAssertTrue(overlay.waitForExistence(timeout: 30))
        let completed = NSPredicate { _, _ in ["loaded", "unavailable"].contains(overlay.value as? String ?? "") }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: completed, object: nil)], timeout: 40), .completed)
        try capture("portrait")
        if app.buttons["map-reviews-retry"].exists {
            app.buttons["map-reviews-retry"].tap()
            XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: completed, object: nil)], timeout: 40), .completed)
            try capture("retry")
        }
        for (name, orientation) in [("landscape-left", UIDeviceOrientation.landscapeLeft), ("landscape-right", .landscapeRight), ("upside-down", .portraitUpsideDown)] {
            XCUIDevice.shared.orientation = orientation
            try capture(name)
            XCTAssertTrue(app.buttons["map-close-button"].isHittable)
            XCTAssertTrue(overlay.exists)
            if app.buttons["map-reviews-retry"].exists {
                XCTAssertTrue(app.buttons["map-reviews-retry"].isHittable)
            }
            XCTAssertLessThan(overlay.frame.height, app.frame.height * 0.7)
            XCTAssertGreaterThanOrEqual(overlay.frame.width, min(250, app.frame.width - 24))
        }
        XCUIDevice.shared.orientation = .portrait
        app.buttons["map-appearance-button"].tap()
        try capture("map-appearance")
        // The unchanged Google license alert is excluded: rendering its long text stalls maximum-AX runs.
        app.buttons["map-close-button"].tap()
        XCTAssertTrue(app.staticTexts["Top Sights"].waitForExistence(timeout: 10))
    }
}

private struct Configuration: Decodable {
    let outputDirectory: String
    let expiresAt: TimeInterval
    let largeText: Bool
}
