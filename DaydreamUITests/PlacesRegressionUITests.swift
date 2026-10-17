import XCTest
import UIKit

/// Opt-in, live-service regression coverage. Use dedicated simulators; keep captures out of Git.
final class PlacesRegressionUITests: XCTestCase {
    @MainActor
    func testPlacesRegression() throws {
        continueAfterFailure = false
        addUIInterruptionMonitor(withDescription: "App Store review prompt") { alert in
            guard alert.buttons["Not Now"].exists else { return false }
            alert.buttons["Not Now"].tap()
            return true
        }
        let udid = ProcessInfo.processInfo.environment["SIMULATOR_UDID"] ?? ""
        let configURL = URL(fileURLWithPath: "/tmp/daydream-places-qa-\(udid).json")
        guard let data = try? Data(contentsOf: configURL) else {
            throw XCTSkip("Provide an unexpired local Places QA configuration to run live-service checks.")
        }
        let config = try JSONDecoder().decode(Configuration.self, from: data)
        guard config.expiresAt > Date().timeIntervalSince1970 else { throw XCTSkip("Places QA configuration expired.") }
        print("Places QA harness: measured scrolling and visible-intersection taps")
        let output = URL(fileURLWithPath: config.outputDirectory, isDirectory: true)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let app = XCUIApplication(bundleIdentifier: "com.rckim.Daydream")
        app.launchEnvironment["DAYDREAM_UI_CAPTURE_CITIES"] = "Tokyo|Paris|New York City|Hong Kong|Rome"
        if config.simulateReviewFailure == true { app.launchEnvironment["DAYDREAM_UI_CAPTURE_REVIEW_FAILURE"] = "1" }
        if config.forceReviewFallback == true { app.launchEnvironment["DAYDREAM_UI_CAPTURE_REVIEW_FALLBACK"] = "1" }
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        if config.largeText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"] }
        XCUIDevice.shared.orientation = config.landscape ? .landscapeLeft : .portrait
        app.launch()
        defer {
            app.terminate()
            XCUIDevice.shared.orientation = .portrait
        }
        func capture(_ name: String) throws {
            if app.buttons["Not Now"].exists { app.buttons["Not Now"].tap() }
            // Allow presentation/rotation and keyboard animations to finish before judging layout.
            Thread.sleep(forTimeInterval: 1.5)
            try XCUIScreen.main.screenshot().pngRepresentation.write(to: output.appendingPathComponent("\(name).png"))
            try app.debugDescription.write(to: output.appendingPathComponent("\(name).txt"), atomically: true, encoding: .utf8)
        }
        XCTAssertTrue(app.buttons["city-loaded-Tokyo"].waitForExistence(timeout: 90))
        try capture("home")
        if config.skipAutocomplete == true {
            app.buttons["city-loaded-Tokyo"].tap()
        } else {
            app.buttons["city-search-button"].tap()
            XCTAssertTrue(app.textFields.firstMatch.waitForExistence(timeout: 10))
            app.textFields.firstMatch.tap()
            XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 10))
            try capture("search-keyboard")
            XCUIDevice.shared.orientation = config.landscape ? .portrait : .landscapeRight
            XCTAssertTrue(app.textFields.firstMatch.waitForExistence(timeout: 10))
            try capture("search-keyboard-rotated")
            XCTAssertLessThan(app.textFields.firstMatch.frame.maxY, app.keyboards.firstMatch.frame.minY)
            XCUIDevice.shared.orientation = config.landscape ? .landscapeLeft : .portrait
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
        }
        XCTAssertTrue(app.staticTexts["Top Sights"].waitForExistence(timeout: 60))
        Thread.sleep(forTimeInterval: 4)
        try capture("detail")
        let card = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@ AND identifier != %@", "place-card-", "place-card-loading")).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 60))
        // Duo/scroll transforms can report a visible card as not hittable. Use its observed frame,
        // then verify the tap by waiting for the map rather than trusting that accessibility flag.
        for _ in 0..<10 {
            let visible = card.frame.intersection(CGRect(x: app.frame.minX, y: 80, width: app.frame.width, height: app.frame.height - 180))
            if !visible.isNull && visible.height >= min(120, card.frame.height * 0.5) { break }
            let delta = card.frame.maxY > app.frame.maxY - 100
                ? min(card.frame.maxY - (app.frame.maxY - 100) + 12, app.frame.height * 0.4)
                : max(card.frame.minY - 92, -app.frame.height * 0.4)
            let scrollFrame = app.scrollViews.containing(.button, identifier: card.identifier).firstMatch.frame
            let start = app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: scrollFrame.minX - app.frame.minX + 12, dy: app.frame.height * (delta > 0 ? 0.7 : 0.3)))
            start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: 0, dy: -delta)), withVelocity: .slow, thenHoldForDuration: 0.2)
        }
        try capture("discoveries")
        let visibleCard = card.frame.intersection(CGRect(x: app.frame.minX, y: 80, width: app.frame.width, height: app.frame.height - 180))
        XCTAssertFalse(visibleCard.isNull, "Scroll the selected card into the visible content area")
        app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: visibleCard.midX - app.frame.minX, dy: visibleCard.midY - app.frame.minY)).tap()
        XCTAssertTrue(app.buttons["map-close-button"].waitForExistence(timeout: 30))
        // Allow the selected place's review summary and map tiles to finish loading.
        Thread.sleep(forTimeInterval: 6)
        try capture("map")
        if app.buttons["Try Again"].exists {
            try capture("map-load-error")
            app.buttons["Try Again"].tap()
        }
        let reviewsReady = NSPredicate { _, _ in
            app.staticTexts["map-review-summary"].exists || app.buttons["map-review-card"].exists || app.buttons["map-place-details-button"].exists
        }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: reviewsReady, object: nil)], timeout: 30), .completed)
        try capture("map-reviews")
        if app.staticTexts["map-review-disclosure"].exists && !config.largeText {
            XCTAssertTrue(app.staticTexts["map-review-disclosure"].isHittable)
        }
        if app.buttons["map-place-details-button"].exists {
            app.buttons["map-place-details-button"].tap()
            XCTAssertTrue(app.buttons["map-place-details-close"].waitForExistence(timeout: 10))
            if app.buttons["Try Again"].exists {
                try capture("accessible-place-details-error")
                app.buttons["Try Again"].tap()
                let recovered = NSPredicate { _, _ in app.staticTexts["map-review-summary"].exists || app.buttons["map-review-card"].exists }
                XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: recovered, object: nil)], timeout: 30), .completed)
            }
            if config.forceReviewFallback == true { XCTAssertTrue(app.buttons["map-review-card"].firstMatch.waitForExistence(timeout: 30)) }
            try capture("accessible-place-details")
            let end = app.buttons["map-place-open-maps"]
            for _ in 0..<40 {
                if end.isHittable { break }
                app.scrollViews["map-place-details-scroll"].swipeUp()
            }
            XCTAssertTrue(end.isHittable, "All place details and reviews must be reachable by scrolling")
            try capture("accessible-place-details-end")
            app.buttons["map-place-details-close"].tap()
        }
        XCUIDevice.shared.orientation = config.landscape ? .portrait : .landscapeRight
        try capture("map-rotated")
        XCTAssertTrue(app.buttons["map-close-button"].exists)
        if app.buttons["map-place-details-button"].exists {
            app.buttons["map-place-details-button"].tap()
            XCTAssertTrue(app.buttons["map-place-details-close"].waitForExistence(timeout: 10))
            try capture("accessible-place-details-rotated")
            app.buttons["map-place-details-close"].tap()
        }
        if config.allRotations == true {
            for (name, orientation) in [("landscape-left", UIDeviceOrientation.landscapeLeft), ("landscape-right", .landscapeRight), ("upside-down", .portraitUpsideDown), ("portrait", .portrait)] {
                XCUIDevice.shared.orientation = orientation
                try capture("map-" + name)
                XCTAssertTrue(app.buttons["map-close-button"].exists)
                if app.staticTexts["map-review-disclosure"].exists && !config.largeText {
                    XCTAssertTrue(app.staticTexts["map-review-disclosure"].isHittable)
                }
            }
        }
        XCUIDevice.shared.orientation = config.landscape ? .landscapeLeft : .portrait
        app.buttons["map-appearance-button"].tap()
        try capture("map-appearance")
        app.buttons["map-close-button"].tap()
        if config.mapOnly == true { return }
        XCTAssertTrue(app.buttons["home-button"].waitForExistence(timeout: 10))
        app.buttons["home-button"].tap()
        XCTAssertTrue(app.buttons["random-city-button"].waitForExistence(timeout: 10))
        app.buttons["random-city-button"].tap()
        let randomResult = NSPredicate { _, _ in
            app.buttons["home-button"].exists || app.alerts.firstMatch.exists
        }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: randomResult, object: nil)], timeout: 90), .completed)
        if app.alerts.firstMatch.exists {
            try capture("random-city-error")
            XCTAssertTrue(app.alerts.firstMatch.buttons["OK"].isHittable)
            app.alerts.firstMatch.buttons["OK"].tap()
            XCTAssertTrue(app.buttons["random-city-button"].exists)
        } else {
            try capture("random-city")
        }
        if let locationMode = config.locationMode {
            if app.buttons["home-button"].exists { app.buttons["home-button"].tap() }
            app.buttons["current-city-button"].tap()
            if locationMode == "denied" {
                XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 10))
                try capture("location-denied")
                app.buttons["Cancel"].tap()
            } else {
                let permission = XCUIApplication(bundleIdentifier: "com.apple.springboard").buttons["Allow While Using App"]
                if permission.waitForExistence(timeout: 3) {
                    try capture("location-permission")
                    permission.tap()
                }
                XCTAssertTrue(app.buttons["home-button"].waitForExistence(timeout: 90))
                try capture("current-city")
                XCTAssertTrue(app.staticTexts["Top Sights"].exists)
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
    let simulateReviewFailure: Bool?
    let forceReviewFallback: Bool?
    let skipAutocomplete: Bool?
    let mapOnly: Bool?
    let allRotations: Bool?
}
