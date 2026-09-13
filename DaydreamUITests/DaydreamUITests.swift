import XCTest

final class DaydreamUITests: XCTestCase {
    @MainActor
    func testCaptureMainScreen() throws {
        continueAfterFailure = false
        let environment = ProcessInfo.processInfo.environment
        let path = environment["DAYDREAM_VISUAL_QA_CONFIG_PATH"]
            ?? "/tmp/daydream-visualqa-config-\(environment["SIMULATOR_UDID"] ?? "").json"
        guard let data = FileManager.default.contents(atPath: path) else {
            throw XCTSkip("Run scripts/capture_visual_qa_snapshots.sh to enable capture.")
        }
        let config = try JSONDecoder().decode(CaptureConfiguration.self, from: data)
        guard config.enabled, config.expiresAt > Date().timeIntervalSince1970 else {
            throw XCTSkip("Visual QA configuration is disabled or expired.")
        }
        XCUIDevice.shared.orientation = config.orientation == "landscape" ? .landscapeLeft : .portrait
        let app = XCUIApplication(bundleIdentifier: "com.rckim.Daydream")
        for locale in config.localeProfiles {
            app.launchEnvironment["DAYDREAM_UI_CAPTURE_CITIES"] = "Tokyo|Paris|New York City|Hong Kong|Rome"
            app.launchArguments = ["-AppleLanguages", "(\(locale.language))", "-AppleLocale", locale.locale]
            app.launch()
            defer { app.terminate() }
            // Wait for real Google photos, including cards below the fold, before capturing.
            let loaded = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "city-loaded-"))
            let deadline = Date().addingTimeInterval(120)
            while loaded.count < 5 && Date() < deadline { Thread.sleep(forTimeInterval: 0.5) }
            XCTAssertEqual(loaded.count, 5, "All five city photos must load before capture.")
            XCTAssertTrue(app.staticTexts["Where do you want to go?"].exists)
            Thread.sleep(forTimeInterval: 1)
            let directory = URL(fileURLWithPath: config.outputDirectory, isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try XCUIScreen.main.screenshot().pngRepresentation.write(
                to: directory.appendingPathComponent("\(locale.casePrefix)--home.png"), options: .atomic
            )
        }
    }
}

private struct CaptureConfiguration: Decodable {
    let enabled: Bool
    let outputDirectory: String
    let orientation: String
    let localeProfiles: [LocaleProfile]
    let expiresAt: TimeInterval

    struct LocaleProfile: Decodable {
        let language: String
        let locale: String
        let casePrefix: String
    }
}
