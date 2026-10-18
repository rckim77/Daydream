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
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
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
        let card = app.buttons.matching(NSPredicate(
            format: "label == %@ OR (identifier BEGINSWITH %@ AND identifier != %@)",
            "Sensō-ji", "place-card-", "place-card-loading"
        )).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 60))
        if config.requirePhotos == true {
            let placeID = String(card.identifier.dropFirst("place-card-".count))
            let media = app.descendants(matching: .any).matching(identifier: "place-media-" + placeID).firstMatch
            let mediaLoaded = NSPredicate { _, _ in media.value as? String == "loaded" }
            XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: mediaLoaded, object: nil)], timeout: 40), .completed)
            XCTAssertTrue(media.images["PlaceDetailsCompactVerticalViewPhoto"].firstMatch.exists)
        }
        func reveal(_ target: XCUIElement, minimumVisibleHeight: CGFloat) {
            for _ in 0..<30 {
                if app.buttons["Not Now"].exists { app.buttons["Not Now"].tap() }
                let safe = CGRect(x: app.frame.minX, y: app.frame.minY + 80,
                                  width: app.frame.width, height: app.frame.height - 180)
                let visible = target.frame.intersection(safe)
                if !visible.isNull && visible.height >= min(minimumVisibleHeight, target.frame.height) { return }
                let delta = target.frame.maxY > safe.maxY
                    ? min(target.frame.maxY - safe.maxY + 12, app.frame.height * 0.4)
                    : max(target.frame.minY - safe.minY - 12, -app.frame.height * 0.4)
                let start = app.coordinate(withNormalizedOffset: .zero)
                    .withOffset(CGVector(dx: 12, dy: app.frame.height * (delta > 0 ? 0.7 : 0.3)))
                start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: 0, dy: -delta)), withVelocity: .slow, thenHoldForDuration: 0.2)
            }
        }
        if config.requirePhotos == true {
            let placeID = String(card.identifier.dropFirst("place-card-".count))
            let media = app.descendants(matching: .any).matching(identifier: "place-media-" + placeID).firstMatch
            reveal(media, minimumVisibleHeight: 160)
            try capture("nearby-photos")
        }
        reveal(card, minimumVisibleHeight: 100)
        try capture("discoveries")
        // StoreKit can present after the screenshot begins, outside XCTest's alert monitor.
        if app.buttons["Not Now"].waitForExistence(timeout: 2) { app.buttons["Not Now"].tap() }
        // Streaming summary text may have changed the layout while taking the capture.
        reveal(card, minimumVisibleHeight: 100)
        let visible = card.frame.intersection(CGRect(x: app.frame.minX, y: app.frame.minY + 80,
                                                   width: app.frame.width, height: app.frame.height - 180))
        XCTAssertFalse(visible.isNull)
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: visible.midX - app.frame.minX, dy: visible.midY - app.frame.minY)).tap()
        if !app.buttons["map-close-button"].waitForExistence(timeout: 5) {
            card.tap()
        }
        XCTAssertTrue(app.buttons["map-close-button"].waitForExistence(timeout: 30))
        try capture("map-initial")
        let overlay = app.descendants(matching: .any).matching(identifier: "map-reviews-overlay").firstMatch
        XCTAssertTrue(overlay.waitForExistence(timeout: 30))
        let completed = NSPredicate { _, _ in ["loaded", "unavailable"].contains(overlay.value as? String ?? "") }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: completed, object: nil)], timeout: 40), .completed)
        try capture("portrait")
        if config.requireReviews == true {
            XCTAssertEqual(overlay.value as? String, "loaded", "Live UI Kit authorization must succeed")
            let reviewsTab = app.buttons["PlaceDetailsTabBarButtonReviews"]
            XCTAssertTrue(reviewsTab.waitForExistence(timeout: 10))
            reviewsTab.tap()
            let reviewText = app.staticTexts.matching(identifier: "PlaceDetailsReviewsView").firstMatch
            XCTAssertTrue(reviewText.waitForExistence(timeout: 20))
            XCTAssertGreaterThan(reviewText.label.count, 20, "Require actual review text, not only a loaded overview")
            try capture("reviews")
            let disclosure = app.staticTexts["Reviews aren't verified"]
            let content = app.scrollViews["map-reviews-component"]
            for _ in 0..<40 {
                if disclosure.isHittable { break }
                content.swipeUp(velocity: .fast)
            }
            XCTAssertTrue(disclosure.isHittable, "The end of Google's reviews must remain reachable")
            try capture("reviews-end")
            for _ in 0..<40 {
                if reviewsTab.isHittable { break }
                content.swipeDown(velocity: .fast)
            }
            content.swipeUp(velocity: .slow)
            try capture("reviews-reading")
        }
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
    let requireReviews: Bool?
    let requirePhotos: Bool?
}
