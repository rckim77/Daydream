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
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUserInputCityAndSelectFirstAutocorrectTableViewCell() {

        let app = XCUIApplication()

        snapshot("01SearchVC")

        let searchField = app.searchFields["e.g., Tokyo"]
        searchField.tap()

        snapshot("02AutocorrectVC")

        searchField.typeText("tokyo")

        app/*@START_MENU_TOKEN@*/.tables["Search results"].staticTexts["Tokyo"]/*[[".otherElements[\"Double-tap to dismiss\"].tables[\"Search results\"]",".cells.staticTexts[\"Tokyo\"]",".staticTexts[\"Tokyo\"]",".tables[\"Search results\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()

        sleep(4)

        snapshot("03SearchDetailVC")
    }
    
}
