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
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
}
