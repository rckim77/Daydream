import XCTest

/// Opt-in live Places verification with an isolated wishlist domain and optional screenshots.
final class WishlistPlacesUITests: XCTestCase {
    @MainActor
    func testSavedPlacesAndCollapsibleCities() throws {
        let configURL = URL(fileURLWithPath: "/tmp/daydream-wishlist-ui-config.json")
        guard let data = try? Data(contentsOf: configURL),
              let config = try? JSONDecoder().decode(Configuration.self, from: data),
              config.enabled, config.expiresAt > Date().timeIntervalSince1970 else {
            throw XCTSkip("Enable the focused wishlist UI run with /tmp/daydream-wishlist-ui-config.json.")
        }
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: "com.rckim.Daydream")
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US",
                               "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL",
                               "-reviewsViewedCount", "0"]
        app.launchEnvironment["DAYDREAM_UI_CAPTURE_CITIES"] = "Tokyo|Paris|New York City|Hong Kong|Rome|Montreal|Lisbon|Antalya"
        app.launchEnvironment["DAYDREAM_WISHLIST_TEST_SUITE"] = "Daydream.WishlistUITests.\(UUID().uuidString)"
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        defer { app.terminate() }
        let window = app.windows.firstMatch

        func capture(_ name: String) throws {
            guard let outputDirectory = config.outputDirectory else { return }
            let directory = URL(fileURLWithPath: outputDirectory, isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try XCUIScreen.main.screenshot().pngRepresentation.write(
                to: directory.appendingPathComponent("\(name).png"), options: .atomic)
            try app.debugDescription.write(to: directory.appendingPathComponent("\(name)-hierarchy.txt"),
                                           atomically: true, encoding: .utf8)
        }

        func reveal(_ element: XCUIElement) {
            for _ in 0..<7 {
                if element.isHittable { return }
                // Scroll beside the embedded map and horizontally scrolling place cards.
                window.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.8))
                    .press(forDuration: 0.05, thenDragTo:
                        window.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.25)))
            }
            XCTAssertTrue(element.isHittable, "Expected control to be visible: \(element.identifier)")
        }

        func raiseForCapture(_ element: XCUIElement) {
            // Hittable controls can still sit behind the translucent bottom toolbar.
            for _ in 0..<3 {
                guard element.frame.maxY > window.frame.height * 0.8 else { return }
                window.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.7))
                    .press(forDuration: 0.05, thenDragTo:
                        window.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.48)))
            }
        }

        func waitForSaved(_ button: XCUIElement) {
            let saved = NSPredicate(format: "value == %@", "Saved")
            XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: saved, object: button)],
                                         timeout: 5), .completed)
        }

        func openWishlist() {
            let button = app.buttons["wishlist-button"]
            XCTAssertTrue(button.waitForExistence(timeout: 10))
            button.tap()
            XCTAssertTrue(app.navigationBars["Wishlist"].waitForExistence(timeout: 5))
        }

        let city = app.buttons["city-loaded-Tokyo"]
        XCTAssertTrue(city.waitForExistence(timeout: 45))
        if app.buttons["xmark.circle.fill"].exists { app.buttons["xmark.circle.fill"].tap() }
        reveal(city)
        city.tap()
        let cityHeart = app.buttons["city-detail-wishlist-button"]
        XCTAssertTrue(cityHeart.waitForExistence(timeout: 10))
        XCTAssertEqual(cityHeart.value as? String, "Not saved")

        let sight = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "place-wishlist-sight-")).firstMatch
        XCTAssertTrue(sight.waitForExistence(timeout: 30))
        let sightID = String(sight.identifier.dropFirst("place-wishlist-sight-".count))
        reveal(sight)
        raiseForCapture(sight)
        // Google's SDK owns photo loading and can finish after the place callback.
        Thread.sleep(forTimeInterval: 3)
        raiseForCapture(sight)
        try capture("before-sight-tap")
        XCTAssertLessThan(sight.frame.maxY, window.frame.height * 0.85)
        sight.tap()
        waitForSaved(sight)
        XCTAssertEqual(cityHeart.value as? String, "Saved", "Saving a sight must save its city")
        raiseForCapture(sight)
        try capture("01-saved-sight")

        let firstEatery = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "place-wishlist-eatery-")).firstMatch
        XCTAssertTrue(firstEatery.waitForExistence(timeout: 30))
        reveal(firstEatery)
        raiseForCapture(firstEatery)
        // Prefer observed eateries for captures; Nearby can also return multi-use businesses.
        let restaurant = app.buttons.matching(NSPredicate(
            format: "identifier BEGINSWITH %@ AND (label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@)",
            "place-wishlist-eatery-", "Ichiran", "Kura Sushi", "Tsujihan", "pain", "Age.3"
        )).firstMatch
        let eatery = restaurant.exists ? restaurant : firstEatery
        if restaurant.exists {
            let carousel = try XCTUnwrap(app.scrollViews.containing(.button, identifier: restaurant.identifier)
                .allElementsBoundByIndex.last)
            for _ in 0..<8 {
                let frame = restaurant.frame
                if frame.minX >= 16, frame.maxX <= window.frame.width - 16, restaurant.isHittable { break }
                carousel.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5))
                    .press(forDuration: 0.05, thenDragTo:
                        carousel.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: 0.5)))
            }
            XCTAssertTrue(restaurant.isHittable, "Preferred restaurant must be reachable in its carousel")
        }
        print("Wishlist UI selected eatery: \(eatery.label)")
        let eateryID = String(eatery.identifier.dropFirst("place-wishlist-eatery-".count))
        raiseForCapture(eatery)
        eatery.tap()
        waitForSaved(eatery)
        raiseForCapture(eatery)
        try capture("02-saved-eatery")

        app.buttons["home-button"].tap()
        openWishlist()
        try capture("wishlist-before-check")
        let explore = app.buttons["wishlist-explore-Tokyo"]
        XCTAssertTrue(explore.waitForExistence(timeout: 10), "Cities with saved places begin expanded")
        let savedSight = app.buttons["wishlist-place-\(sightID)"]
        let savedEatery = app.buttons["wishlist-place-\(eateryID)"]
        XCTAssertTrue(savedSight.waitForExistence(timeout: 10))
        XCTAssertTrue(savedEatery.waitForExistence(timeout: 10))
        let loaded = NSPredicate { _, _ in savedSight.isEnabled && savedEatery.isEnabled }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: loaded, object: nil)],
                                     timeout: 30), .completed)
        XCTAssertFalse(savedSight.label.contains("Saved sight"), "Wishlist should show the live place name")
        XCTAssertFalse(savedEatery.label.contains("Saved eatery"), "Wishlist should show the live place name")
        try capture("03-wishlist-expanded")

        let header = app.descendants(matching: .any).matching(identifier: "wishlist-city-section-Tokyo").firstMatch
        XCTAssertTrue(header.waitForExistence(timeout: 5))
        header.tap()
        XCTAssertFalse(explore.exists)
        XCTAssertFalse(savedSight.exists)
        try capture("04-wishlist-collapsed")
        header.tap()
        XCTAssertTrue(explore.waitForExistence(timeout: 5))
        XCTAssertTrue(savedSight.waitForExistence(timeout: 5))

        savedSight.tap()
        let overlay = app.descendants(matching: .any).matching(identifier: "map-reviews-overlay").firstMatch
        XCTAssertTrue(overlay.waitForExistence(timeout: 15))
        let reviewsLoaded = NSPredicate { _, _ in overlay.value as? String == "loaded" }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: reviewsLoaded, object: nil)],
                                     timeout: 30), .completed)
        app.buttons["map-close-button"].tap()
        XCTAssertTrue(explore.waitForExistence(timeout: 10))

        app.terminate()
        app.launch()
        openWishlist()
        XCTAssertTrue(savedSight.waitForExistence(timeout: 10), "Sight persists across relaunch")
        XCTAssertTrue(savedEatery.waitForExistence(timeout: 10), "Eatery persists across relaunch")

        savedSight.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo:
                savedSight.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.5)))
        app.buttons["Remove"].tap()
        XCTAssertFalse(savedSight.exists)
        XCTAssertTrue(savedEatery.exists)

        header.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo:
                header.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.5)))
        app.buttons["Remove city"].tap()
        let removeCity = app.buttons["Remove Tokyo and saved places"]
        XCTAssertTrue(removeCity.waitForExistence(timeout: 5))
        removeCity.tap()
        XCTAssertTrue(app.staticTexts["Your next adventure starts here"].waitForExistence(timeout: 5))
    }
}

private struct Configuration: Decodable {
    let enabled: Bool
    let expiresAt: TimeInterval
    let outputDirectory: String?
}
