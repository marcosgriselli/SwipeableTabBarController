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
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }
    
    private struct Tab {
        let index: Int
        let navBarTitle: String

        private init(index: Int, navBarTitle: String) {
            self.index = index
            self.navBarTitle = navBarTitle
        }
        
        static let comments = Tab(index: 0, navBarTitle: "Comments")
        static let team = Tab(index: 1, navBarTitle: "Team")
        static let settings = Tab(index: 2, navBarTitle: "Settings")
        
    }

    private func assertTabSelected(_ tab: Tab, in app: XCUIApplication, file: StaticString = #file, line: UInt = #line) {
        let tabBar = app.tabBars.firstMatch
        let navigationBar = app.navigationBars[tab.navBarTitle]
        XCTAssert(navigationBar.waitForExistence(timeout: 2), file: file, line: line)
        XCTAssert(navigationBar.isHittable, file: file, line: line)
        XCTAssert(tabBar.buttons.allElementsBoundByIndex[tab.index].isSelected, file: file, line: line)
    }

    /// Tests navigation with swiping and tapping.
    func testTabBarInteractions() {
        let app = XCUIApplication()
        app.launch()
        
        /// We want to keep tests updated with the ammount of view controllers on the
        /// tabBar. If we add a new view controller the tests should navigate to it as well.
        let tabBar = app.tabBars.firstMatch
        XCTAssertEqual(tabBar.buttons.allElementsBoundByIndex.count, 3, "Unexpected number of view controllers on the TabBar. Please update tests to reflect these changes.")
        
        /// Assert that the tabBarItem is selected and that the new view controller
        /// exists and its ready to interact with.
        /// This is a simple test but it will be useful for unexpected states.
        app.swipeRight()
        assertTabSelected(.comments, in: app)
        app.swipeLeft()
        assertTabSelected(.team, in: app)
        app.swipeLeft()
        assertTabSelected(.settings, in: app)
        app.tabBars.buttons.element(boundBy: 0).tap()
        assertTabSelected(.comments, in: app)
        app.tabBars.buttons.element(boundBy: 1).tap()
        assertTabSelected(.team, in: app)
        app.tabBars.buttons.element(boundBy: 2).tap()
        assertTabSelected(.settings, in: app)

        // Tests Cycling tabBar
        app.swipeLeft()
        assertTabSelected(.comments, in: app)
        app.swipeRight()
        assertTabSelected(.settings, in: app)
        app.swipeRight()
        assertTabSelected(.team, in: app)
    }

    func testRapidSelectedIndexTransitionsRemainInteractive() {
        assertRapidProgrammaticTransitionsRemainInteractive("StressSelectedIndexTransitions")
    }

    func testRapidSelectedViewControllerTransitionsRemainInteractive() {
        assertRapidProgrammaticTransitionsRemainInteractive("StressSelectedViewControllerTransitions")
    }

    private func assertRapidProgrammaticTransitionsRemainInteractive(_ launchArgument: String) {
        let app = XCUIApplication()
        app.launchArguments = [launchArgument]
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 4))
        XCTAssertEqual(tabBar.buttons.allElementsBoundByIndex.count, 3, "Unexpected number of view controllers on the TabBar. Please update tests to reflect these changes.")

        Thread.sleep(forTimeInterval: 2)

        app.tabBars.buttons.element(boundBy: Tab.settings.index).tap()
        assertTabSelected(.settings, in: app)

        app.tabBars.buttons.element(boundBy: Tab.comments.index).tap()
        assertTabSelected(.comments, in: app)

        app.swipeLeft()
        assertTabSelected(.team, in: app)
    }
}
