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

        app/*@START_MENU_TOKEN@*/.tables["Search results"].staticTexts["Tokyo"]/*[[".otherElements[\"Double-tap to dismiss\"].tables[\"Search results\"]",".cells.staticTexts[\"Tokyo\"]",".staticTexts[\"Tokyo\"]",".tables[\"Search results\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()

        sleep(4)

        snapshot("03SearchDetailVC")

        app.tables/*@START_MENU_TOKEN@*/.otherElements["poi1Card"]/*[[".cells.otherElements[\"poi1Card\"]",".otherElements[\"poi1Card\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

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
