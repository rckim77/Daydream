import XCTest

/// A single opt-in smoke check against the live Places service.
final class PlacesReviewsOverlayUITests: XCTestCase {
    @MainActor
    func testGoogleReviewsOverlay() throws {
        guard ProcessInfo.processInfo.environment["DAYDREAM_LIVE_PLACES_UI_TESTS"] == "1" else {
            throw XCTSkip("Set DAYDREAM_LIVE_PLACES_UI_TESTS=1 in the test runner to enable.")
        }
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: "com.rckim.Daydream")
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US",
                               "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"]
        app.launchEnvironment["DAYDREAM_UI_CAPTURE_CITIES"] = "Tokyo|Paris|New York City|Hong Kong|Rome"
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        defer { app.terminate() }
        addUIInterruptionMonitor(withDescription: "Store review prompt") { alert in
            guard alert.buttons["Not Now"].exists else { return false }
            alert.buttons["Not Now"].tap()
            return true
        }

        func tapWhenVisible(_ element: XCUIElement) {
            for _ in 0..<5 {
                if app.buttons["Not Now"].exists { app.buttons["Not Now"].tap() }
                if element.isHittable { break }
                // Scroll at the edge so the embedded map does not consume the gesture.
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.8))
                    .press(forDuration: 0.05, thenDragTo:
                        app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.25)))
            }
            XCTAssertTrue(element.isHittable)
            element.tap()
        }

        let city = app.buttons["city-loaded-Tokyo"]
        XCTAssertTrue(city.waitForExistence(timeout: 30))
        if app.buttons["xmark.circle.fill"].exists { app.buttons["xmark.circle.fill"].tap() }
        tapWhenVisible(city)
        let place = app.buttons.matching(NSPredicate(
            format: "identifier BEGINSWITH %@ AND identifier != %@", "place-card-", "place-card-loading"
        )).firstMatch
        XCTAssertTrue(place.waitForExistence(timeout: 20))
        tapWhenVisible(place)

        let overlay = app.descendants(matching: .any).matching(identifier: "map-reviews-overlay").firstMatch
        XCTAssertTrue(overlay.waitForExistence(timeout: 10))
        let loaded = NSPredicate { _, _ in overlay.value as? String == "loaded" }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: loaded, object: nil)], timeout: 20), .completed)
        app.buttons["map-close-button"].tap()
        XCTAssertTrue(app.staticTexts["Top Sights"].waitForExistence(timeout: 5))
    }
}
