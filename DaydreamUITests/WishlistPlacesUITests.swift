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
        app.launchEnvironment["DAYDREAM_UI_CAPTURE_CITIES"] = "Tokyo|Osaka|Paris|New York City|Hong Kong|Rome|Montreal|Lisbon"
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
                let frame = element.frame
                if frame.minY >= window.frame.height * 0.12,
                   frame.maxY <= window.frame.height * 0.8, element.isHittable { return }
                // Scroll beside the embedded map and horizontally scrolling place cards.
                let start: CGFloat = frame.midY > window.frame.midY ? 0.8 : 0.3
                let end: CGFloat = frame.midY > window.frame.midY ? 0.3 : 0.8
                window.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: start))
                    .press(forDuration: 0.05, thenDragTo:
                        window.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: end)))
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
            let identifier = button.identifier
            // Places photo updates can invalidate the original first-match accessibility snapshot.
            let saved = NSPredicate { _, _ in app.buttons[identifier].value as? String == "Saved" }
            XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: saved, object: nil)],
                                         timeout: 10), .completed)
        }

        func openWishlist() {
            let button = app.buttons["wishlist-button"]
            XCTAssertTrue(button.waitForExistence(timeout: 10))
            button.tap()
            XCTAssertTrue(app.navigationBars["Wishlist"].waitForExistence(timeout: 5))
        }

        func waitForCountry(_ header: XCUIElement, value: String) {
            XCTAssertTrue(header.waitForExistence(timeout: 5), "Country headers remain available when collapsed")
            let predicate = NSPredicate(format: "value == %@", value)
            XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: header)],
                                         timeout: 5), .completed)
        }

        func removalAlert() -> XCUIElement {
            let alert = app.alerts["Are you sure?"]
            XCTAssertTrue(alert.waitForExistence(timeout: 5))
            XCTAssertTrue(alert.staticTexts["Unfavoriting Tokyo will also clear all of its favorited sights and eateries."].exists)
            return alert
        }

        func revealCityRemoval(_ header: XCUIElement) {
            header.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5))
                .press(forDuration: 0.05, thenDragTo:
                    header.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.5)))
            app.buttons["Remove city"].tap()
        }

        func rowTapTargets(_ row: XCUIElement) throws -> [(name: String, offset: CGVector)] {
            let cell = app.cells.containing(.button, identifier: row.identifier).firstMatch
            XCTAssertTrue(cell.exists)
            let frame = row.frame
            XCTAssertEqual(frame.minX, cell.frame.minX, accuracy: 1, "The button includes leading cell padding")
            XCTAssertEqual(frame.maxX, cell.frame.maxX, accuracy: 1, "The button includes trailing cell padding")
            XCTAssertEqual(frame.height, cell.frame.height, accuracy: 1, "The button includes vertical cell padding")
            XCTAssertGreaterThanOrEqual(frame.height, 44)
            let text = row.staticTexts.allElementsBoundByIndex.first
            // A single city label can merge into its button. Tokyo's observed text is inside
            // the leading 100 points; retain one accessible control and tap that same region.
            let textFrame = text?.frame ?? CGRect(x: frame.minX + 16, y: frame.minY,
                                                  width: 84, height: frame.height)
            let textX = (textFrame.midX - frame.minX) / frame.width
            // The trailing decorative icon occupies 44 points, inside 16-point padding.
            let blankEnd = frame.maxX - 60
            XCTAssertGreaterThan(blankEnd - textFrame.maxX, 4, "The fixture must expose blank space beside its text")
            let blankX = ((textFrame.maxX + blankEnd) / 2 - frame.minX) / frame.width
            return [
                ("text", CGVector(dx: textX, dy: 0.5)),
                ("blank space", CGVector(dx: blankX, dy: 0.5)),
                ("trailing icon", CGVector(dx: 0.90, dy: 0.5)),
                ("edge padding", CGVector(dx: 0.99, dy: 0.5))
            ]
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
                let delta = max(-0.75, min(0.75, (window.frame.midX - frame.midX) / carousel.frame.width))
                let start: CGFloat = delta < 0 ? 0.875 : 0.125
                carousel.coordinate(withNormalizedOffset: CGVector(dx: start, dy: 0.5))
                    .press(forDuration: 0.05, thenDragTo:
                        carousel.coordinate(withNormalizedOffset: CGVector(dx: start + delta, dy: 0.5)),
                        withVelocity: .slow, thenHoldForDuration: 0.1)
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

        reveal(cityHeart)
        cityHeart.tap()
        removalAlert().buttons["Cancel"].tap()
        waitForSaved(cityHeart)
        waitForSaved(sight)
        waitForSaved(eatery)

        app.buttons["home-button"].tap()
        let discoveryHeart = app.buttons["wishlist-toggle-Tokyo"]
        XCTAssertTrue(discoveryHeart.waitForExistence(timeout: 10))
        reveal(discoveryHeart)
        discoveryHeart.tap()
        removalAlert().buttons["Cancel"].tap()
        waitForSaved(discoveryHeart)
        for cityName in ["Osaka", "Paris"] {
            let heart = app.buttons["wishlist-toggle-\(cityName)"]
            XCTAssertTrue(heart.waitForExistence(timeout: 10))
            reveal(heart)
            heart.tap()
            waitForSaved(heart)
        }
        openWishlist()
        try capture("wishlist-before-check")
        let tokyo = app.buttons["wishlist-city-section-Tokyo"]
        XCTAssertTrue(tokyo.waitForExistence(timeout: 10))
        let osaka = app.buttons["wishlist-city-section-Osaka"]
        let paris = app.buttons["wishlist-city-section-Paris"]
        let japan = app.buttons["wishlist-country-Japan"]
        let france = app.buttons["wishlist-country-France"]
        XCTAssertTrue(osaka.waitForExistence(timeout: 5))
        XCTAssertTrue(paris.waitForExistence(timeout: 5))
        waitForCountry(japan, value: "Expanded")
        let savedSight = app.buttons["wishlist-place-\(sightID)"]
        let savedEatery = app.buttons["wishlist-place-\(eateryID)"]
        XCTAssertTrue(savedSight.waitForExistence(timeout: 10))
        XCTAssertTrue(savedEatery.waitForExistence(timeout: 10))
        let loaded = NSPredicate { _, _ in savedSight.isEnabled && savedEatery.isEnabled }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: loaded, object: nil)],
                                     timeout: 30), .completed)
        XCTAssertFalse(savedSight.label.contains("Saved sight"), "Wishlist should show the live place name")
        XCTAssertFalse(savedEatery.label.contains("Saved eatery"), "Wishlist should show the live place name")
        XCTAssertFalse(app.staticTexts["Sights"].exists)
        XCTAssertFalse(app.staticTexts["Eateries"].exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Sights:")).firstMatch.exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Eateries:")).firstMatch.exists)
        XCTAssertFalse(app.staticTexts["Google Maps"].exists, "Wishlist has no repeated per-place attribution captions")
        XCTAssertFalse(app.buttons["wishlist-explore-Tokyo"].exists, "City icons are decorative parts of the row")
        XCTAssertFalse(app.buttons["wishlist-place-map-\(sightID)"].exists, "Map icons are decorative parts of the row")
        try capture("03-wishlist-expanded")

        japan.tap()
        try capture("04-wishlist-collapsed")
        waitForCountry(japan, value: "Collapsed")
        XCTAssertFalse(tokyo.exists)
        XCTAssertFalse(osaka.exists)
        XCTAssertFalse(savedSight.exists)
        XCTAssertFalse(savedEatery.exists)
        XCTAssertTrue(france.exists)
        XCTAssertTrue(paris.exists, "Collapsing Japan must preserve France's visible cities")

        app.buttons["Europe"].tap()
        XCTAssertFalse(japan.exists)
        XCTAssertTrue(paris.exists)
        app.buttons["All"].tap()
        waitForCountry(japan, value: "Collapsed")
        XCTAssertFalse(tokyo.exists, "Country collapse state survives continent filtering")
        XCTAssertFalse(osaka.exists)
        japan.tap()
        waitForCountry(japan, value: "Expanded")
        XCTAssertTrue(osaka.waitForExistence(timeout: 5))
        XCTAssertTrue(savedSight.waitForExistence(timeout: 5))

        france.tap()
        try capture("france-collapsed")
        waitForCountry(france, value: "Collapsed")
        XCTAssertFalse(paris.exists, "A country without a footer can collapse to its header")
        XCTAssertTrue(tokyo.exists)
        XCTAssertTrue(osaka.exists)
        XCTAssertTrue(savedSight.exists)
        france.tap()
        waitForCountry(france, value: "Expanded")
        XCTAssertTrue(paris.waitForExistence(timeout: 5))
        XCTAssertTrue(tokyo.exists)

        for target in try rowTapTargets(tokyo) {
            print("Wishlist full-row city tap: \(target.name)")
            tokyo.coordinate(withNormalizedOffset: target.offset).tap()
            XCTAssertTrue(cityHeart.waitForExistence(timeout: 10), "Every city-row area opens city details")
            waitForSaved(cityHeart)
            app.buttons["home-button"].tap()
            XCTAssertTrue(app.navigationBars["Wishlist"].waitForExistence(timeout: 10))
            waitForCountry(japan, value: "Expanded")
            XCTAssertTrue(osaka.exists)
            XCTAssertTrue(savedSight.waitForExistence(timeout: 5), "Opening a city never collapses its country")
        }

        for row in [savedSight, savedEatery] {
            XCTAssertTrue(row.waitForExistence(timeout: 10))
            let enabled = NSPredicate(format: "enabled == true")
            XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: enabled, object: row)],
                                         timeout: 30), .completed)
            for target in try rowTapTargets(row) {
                print("Wishlist full-row place tap: \(row.identifier), \(target.name)")
                row.coordinate(withNormalizedOffset: target.offset).tap()
                let overlay = app.descendants(matching: .any).matching(identifier: "map-reviews-overlay").firstMatch
                XCTAssertTrue(overlay.waitForExistence(timeout: 15))
                let reviewsLoaded = NSPredicate { _, _ in overlay.value as? String == "loaded" }
                XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: reviewsLoaded, object: nil)],
                                             timeout: 30), .completed)
                app.buttons["map-close-button"].tap()
                XCTAssertTrue(tokyo.waitForExistence(timeout: 10))
            }
        }

        app.terminate()
        app.launch()
        openWishlist()
        XCTAssertTrue(savedSight.waitForExistence(timeout: 10), "Sight persists across relaunch")
        XCTAssertTrue(savedEatery.waitForExistence(timeout: 10), "Eatery persists across relaunch")

        revealCityRemoval(tokyo)
        let wishlistAlert = removalAlert()
        try capture("05-city-removal-confirmation")
        wishlistAlert.buttons["Cancel"].tap()
        XCTAssertTrue(savedSight.waitForExistence(timeout: 5), "Cancelling city removal preserves its sights")
        XCTAssertTrue(savedEatery.waitForExistence(timeout: 5), "Cancelling city removal preserves its eateries")

        savedSight.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo:
                savedSight.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.5)))
        app.buttons["Remove"].tap()
        XCTAssertFalse(savedSight.exists)
        XCTAssertTrue(savedEatery.exists)

        revealCityRemoval(tokyo)
        removalAlert().buttons["Remove city"].tap()
        XCTAssertFalse(tokyo.exists)
        XCTAssertFalse(savedSight.exists)
        XCTAssertFalse(savedEatery.exists)
        XCTAssertTrue(osaka.exists, "Removing Tokyo preserves another city in Japan")
        XCTAssertTrue(paris.exists, "Removing Tokyo preserves cities in other countries")
        waitForCountry(japan, value: "Expanded")
    }
}

private struct Configuration: Decodable {
    let enabled: Bool
    let expiresAt: TimeInterval
    let outputDirectory: String?
}
