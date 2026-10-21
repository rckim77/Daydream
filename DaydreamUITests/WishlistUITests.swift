import XCTest

final class WishlistUITests: XCTestCase {
    @MainActor
    func testSaveRestoreAndRemoveCities() throws {
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: "com.rckim.Daydream")
        app.launchEnvironment["DAYDREAM_UI_CAPTURE_CITIES"] = "Tokyo|Paris|New York City|Hong Kong|Rome|Montreal|Lisbon|Antalya"
        app.launchEnvironment["DAYDREAM_UI_WISHLIST_SUITE"] = "Daydream.UITests.\(UUID().uuidString)"
        app.launchEnvironment["DAYDREAM_UI_SKIP_CITY_LOADING"] = "1"
        // Keep personal review history intact and prevent StoreKit prompts from interrupting the flow.
        app.launchArguments = ["-reviewsViewedCount", "0", "-lastReviewedAppVersion", "5.3.0"]
        app.launch()
        defer { app.terminate() }

        let wishlist = app.buttons["wishlist-button"]
        XCTAssertTrue(wishlist.waitForExistence(timeout: 15))
        wishlist.tap()
        XCTAssertTrue(app.staticTexts["Your next adventure starts here"].waitForExistence(timeout: 5))
        capture("wishlist-empty")
        app.buttons["Explore Cities"].tap()

        let tokyo = app.buttons["wishlist-toggle-Tokyo"]
        XCTAssertTrue(tokyo.waitForExistence(timeout: 15))
        tokyo.tap()
        XCTAssertEqual(tokyo.value as? String, "Saved")
        // A heart must save without opening the city or requiring the photo to finish loading.
        XCTAssertTrue(wishlist.exists)
        app.buttons["wishlist-toggle-Paris"].tap()
        capture("wishlist-home")
        wishlist.tap()
        XCTAssertTrue(app.buttons["wishlist-city-Tokyo"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["wishlist-city-Paris"].exists)
        capture("wishlist-saved")

        app.terminate()
        app.launch()
        XCTAssertTrue(wishlist.waitForExistence(timeout: 15))
        XCTAssertEqual(app.buttons["wishlist-toggle-Tokyo"].value as? String, "Saved")
        wishlist.tap()
        let savedTokyo = app.buttons["wishlist-city-Tokyo"]
        XCTAssertTrue(savedTokyo.waitForExistence(timeout: 5))
        if ProcessInfo.processInfo.environment["DAYDREAM_LIVE_PLACES_UI_TESTS"] == "1" {
            savedTokyo.tap()
            let home = app.buttons["home-button"]
            XCTAssertTrue(home.waitForExistence(timeout: 30))
            capture("wishlist-city-detail")
            home.tap()
            XCTAssertTrue(savedTokyo.waitForExistence(timeout: 5))
        }
        savedTokyo.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(savedTokyo.exists)
        app.buttons["Edit"].tap()
        capture("wishlist-edit")
        app.buttons["Done"].tap()
        app.buttons["wishlist-city-Paris"].swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["Your next adventure starts here"].waitForExistence(timeout: 5))
        app.buttons["Explore Cities"].tap()
        XCTAssertEqual(app.buttons["wishlist-toggle-Tokyo"].value as? String, "Not saved")
        XCTAssertEqual(app.buttons["wishlist-toggle-Paris"].value as? String, "Not saved")
    }

    @MainActor
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
