//
//  DaydreamUITests.swift
//  DaydreamUITests
//
//  Created by Raymond Kim on 3/28/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import XCTest

class DaydreamUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUserInputCityAndSelectFirstAutocorrectTableViewCell() {

        let app = XCUIApplication()

        snapshot("01SearchVC")

        let searchField = app.searchFields["e.g., Tokyo"]

        searchField.tap()

        sleep(2)

        searchField.typeText("tokyo")

        snapshot("02AutocorrectVC")

        app.tables["Search results"].staticTexts["Tokyo"].tap()

        sleep(4)

        snapshot("03SearchDetailVC")

        app.tables.otherElements["poi1Card"].tap()

        sleep(4)

        snapshot("04MapVC")

        app.buttons["mapCloseIconSoftShadow"].tap()

        app.tables.otherElements["poi2Card"].tap()

        sleep(2)

        app.buttons["nightIcon"].tap()

        sleep(1)

        snapshot("05MapVCDark")
    }
    
}
