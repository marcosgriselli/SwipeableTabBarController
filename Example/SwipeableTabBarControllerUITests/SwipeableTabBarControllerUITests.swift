//
//  SwipeableTabBarControllerUITests.swift
//  SwipeableTabBarControllerUITests
//
//  Created by Marcos Griselli on 04/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest

class SwipeableTabBarControllerUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicInteractions() {
        let app = XCUIApplication()
        app.launch()
        app.swipeRight()
        app.swipeLeft()
        app.swipeLeft()
        app.tabBars.buttons.element(boundBy: 0).tap()
        app.tabBars.buttons.element(boundBy: 1).tap()
        app.tabBars.buttons.element(boundBy: 2).tap()
    }
}
