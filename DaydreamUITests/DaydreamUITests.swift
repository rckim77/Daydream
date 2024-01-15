//
//  DaydreamUITests.swift
//  DaydreamUITests
//
//  Created by Raymond Kim on 5/18/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import XCTest

class DaydreamUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

//    func testUserInputCityAndSelectFirstAutocorrectTableViewCell() {
//        let app = XCUIApplication()
//        app.launchEnvironment = ["isUITest": "true"]
//        setupSnapshot(app)
//        app.launch()
//
//        snapshot("01SearchVC")
//
//        let searchField = app.searchFields["e.g., Tokyo"]
//
//        searchField.tap()
//
//        sleep(2)
//
//        searchField.typeText("Tokyo")
//
//        snapshot("02AutocorrectVC")
//
//        app.tables["Search results"].staticTexts["Tokyo"].tap()
//
//        sleep(5)
//
//        snapshot("03SearchDetailVC")
//
//        app.cells["sightsCell"].staticTexts.element(boundBy: 0).tap()
//
//        sleep(4)
//
//        snapshot("04MapVC")
//
//        app.buttons["map-close-button"].tap()
//
//        app.cells["sightsCell"].staticTexts.element(boundBy: 1).tap()
//
//        sleep(2)
//
//        app.buttons["map-dark-mode-button"].tap()
//
//        sleep(5)
//
//        snapshot("05MapVCDark")
//    }
}
