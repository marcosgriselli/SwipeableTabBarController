//
//  TabBarController.swift
//  SwipeableTabBarController
//
//  Created by Marcos Griselli on 2/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import SwipeableTabBarController
import UIKit

class TabBarController: SwipeableTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewControllers = viewControllers {
            selectedViewController = viewControllers[1]
        }
        
        /// Set the animation type for swipe
        swipeAnimatedTransitioning?.animationType = SwipeAnimationType.sideBySide
        
        /// Set the animation type for tap
        tapAnimatedTransitioning?.animationType = SwipeAnimationType.push

        /// if you want cycling switch tab, set true 'isCyclingEnabled'
        isCyclingEnabled = true

        /// Disable custom transition on tap.
        //tapAnimatedTransitioning = nil
        
        /// Set swipe to only work when strictly horizontal.
//        diagonalSwipeEnabled = true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Handle didSelect viewController method here
    }
}

class IssueViewController: UIViewController {
    var currentVC = 0
    var x = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.timerFunc()
        }
    }
    
    func timerFunc() {
        guard x < 30 else {
            return
        }
        let random = Int.random(in: 0...2)
        print(x, ": ", random)
        x += 1
        tabBarController?.selectedIndex = random
    }
}
