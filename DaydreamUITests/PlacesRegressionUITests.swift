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
        if app.buttons["Not Now"].waitForExistence(timeout: 2) {
            app.buttons["Not Now"].tap()
            try capture("discoveries")
        }
        let visibleCard = card.frame.intersection(CGRect(x: app.frame.minX, y: 80, width: app.frame.width, height: app.frame.height - 180))
        XCTAssertFalse(visibleCard.isNull, "Scroll the selected card into the visible content area")
        app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: visibleCard.midX - app.frame.minX, dy: visibleCard.midY - app.frame.minY)).tap()
        XCTAssertTrue(app.buttons["map-close-button"].waitForExistence(timeout: 30))
        let overlay = app.descendants(matching: .any).matching(identifier: "map-reviews-overlay").firstMatch
        XCTAssertTrue(overlay.waitForExistence(timeout: 30))
        let reviewsReady = NSPredicate { _, _ in
            ["loaded", "unavailable"].contains(overlay.value as? String ?? "")
        }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: reviewsReady, object: nil)], timeout: 40), .completed)
        try capture("map-reviews")
        if app.buttons["map-reviews-retry"].exists {
            XCTAssertTrue(app.buttons["map-reviews-retry"].isHittable)
            app.buttons["map-reviews-retry"].tap()
            XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: reviewsReady, object: nil)], timeout: 40), .completed)
            try capture("map-retry")
        }
        XCUIDevice.shared.orientation = config.landscape ? .portrait : .landscapeRight
        try capture("map-rotated")
        XCTAssertTrue(app.buttons["map-close-button"].isHittable)
        XCTAssertTrue(overlay.exists)
        if config.allRotations == true {
            for (name, orientation) in [("landscape-left", UIDeviceOrientation.landscapeLeft), ("landscape-right", .landscapeRight), ("upside-down", .portraitUpsideDown), ("portrait", .portrait)] {
                XCUIDevice.shared.orientation = orientation
                try capture("map-" + name)
                XCTAssertTrue(app.buttons["map-close-button"].isHittable)
                XCTAssertTrue(overlay.exists)
                if app.buttons["map-reviews-retry"].exists {
                    XCTAssertTrue(app.buttons["map-reviews-retry"].isHittable)
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
    let skipAutocomplete: Bool?
    let mapOnly: Bool?
    let allRotations: Bool?
}
